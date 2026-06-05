import { ref, watch } from 'vue';
import { usePage } from '@inertiajs/vue3';

// Track current user to handle per-user address isolation
let currentUsername = null;
const addresses = ref([]);
let stopWatcher = null;

// API base URL for backend
const API_BASE = 'http://localhost:8080/api';

const fetchHeaders = (token) => ({
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
});

const loadAddresses = async (token) => {
    if (!token) return [];
    try {
        const res = await fetch(`${API_BASE}/addresses`, {
            headers: fetchHeaders(token),
        });
        if (res.ok) {
            const data = await res.json();
            return data || [];
        }
    } catch (e) {
        console.error("Failed to load addresses from API", e);
    }
    return [];
};

export function useAddresses(username) {
    const page = usePage();
    const token = page.props.auth?.token || '';

    // If username is provided and different from current, reload addresses
    if (username && username !== currentUsername) {
        currentUsername = username;
        // Load addresses from API
        loadAddresses(token).then(data => {
            addresses.value = data;
        });
    }

    const addAddress = async (addressData) => {
        try {
            const res = await fetch(`${API_BASE}/addresses`, {
                method: 'POST',
                headers: fetchHeaders(token),
                body: JSON.stringify(addressData),
            });
            if (res.ok) {
                const created = await res.json();
                // If the new address is main, reset others locally
                if (created.isMain) {
                    addresses.value.forEach(a => a.isMain = false);
                }
                addresses.value.push(created);
                return true;
            } else {
                const errText = await res.text();
                console.error("Failed to create address:", errText);
                return errText;
            }
        } catch (e) {
            console.error("Failed to add address", e);
            return e.message;
        }
    };

    const updateAddress = async (id, addressData) => {
        try {
            const res = await fetch(`${API_BASE}/addresses/${id}`, {
                method: 'PUT',
                headers: fetchHeaders(token),
                body: JSON.stringify(addressData),
            });
            if (res.ok) {
                const updated = await res.json();
                if (updated.isMain) {
                    addresses.value.forEach(a => a.isMain = false);
                }
                const index = addresses.value.findIndex(a => a.id === id);
                if (index !== -1) {
                    addresses.value[index] = updated;
                }
                return true;
            } else {
                console.error("Failed to update address:", await res.text());
                return false;
            }
        } catch (e) {
            console.error("Failed to update address", e);
            return false;
        }
    };

    const deleteAddress = async (id) => {
        try {
            const res = await fetch(`${API_BASE}/addresses/${id}`, {
                method: 'DELETE',
                headers: fetchHeaders(token),
            });
            if (res.ok) {
                addresses.value = addresses.value.filter(a => a.id !== id);
            } else {
                console.error('Failed to delete address:', await res.text());
            }
        } catch (e) {
            console.error('Error deleting address:', e);
        }
    };

    const setMainAddress = async (id) => {
        // Find the address and update it as main
        const addr = addresses.value.find(a => a.id === id);
        if (addr) {
            await updateAddress(id, { ...addr, isMain: true });
            // Reload to get fresh state
            const fresh = await loadAddresses(token);
            addresses.value = fresh;
        }
    };

    return {
        addresses,
        addAddress,
        updateAddress,
        deleteAddress,
        setMainAddress
    };
}
