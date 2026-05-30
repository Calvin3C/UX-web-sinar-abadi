import { ref, watch } from 'vue';

// Track current user to handle per-user address isolation
let currentUsername = null;
const addresses = ref([]);
let stopWatcher = null;

const loadAddresses = (username) => {
    if (!username) return [];
    try {
        const stored = localStorage.getItem(`customer_addresses_${username}`);
        if (stored) {
            return JSON.parse(stored);
        }
    } catch (e) {
        console.error("Failed to load addresses from localStorage", e);
    }

    // Seed default addresses per user (only on first load)
    const seedData = {
        calvin: [
            {
                id: 1,
                label: 'Ijen Nirwana Green River C3 11',
                isMain: true,
                name: 'Calvin Alexander Sucipto',
                phone: '6282331339737',
                kota: 'Klojen, Kota Malang',
                address: 'Perumahan Ijen Nirwana Cluster Green River Blok C3-11, Klojen, Kota Malang, Jawa Timur 65116 (Ijen Nirwana Green River C3-11)',
                catatan: '',
                pinpoint: true
            }
        ],
        budi: [
            {
                id: 1,
                label: 'Kantor Sinar Abadi',
                isMain: true,
                name: 'Budi Santoso',
                phone: '08123456789',
                kota: 'Lowokwaru, Malang',
                address: 'Jl. Letjen Sutoyo No. 12, Lowokwaru, Malang, Jawa Timur 65141',
                catatan: '',
                pinpoint: false
            }
        ]
    };

    return seedData[username.toLowerCase()] || [];
};

const setupWatcher = (username) => {
    // Stop previous watcher if exists
    if (stopWatcher) stopWatcher();

    // Save to localStorage whenever it changes (user-specific key)
    stopWatcher = watch(addresses, (newVal) => {
        if (username) {
            localStorage.setItem(`customer_addresses_${username}`, JSON.stringify(newVal));
        }
    }, { deep: true });
};

export function useAddresses(username) {
    // If username is provided and different from current, reload addresses
    if (username && username !== currentUsername) {
        currentUsername = username;
        addresses.value = loadAddresses(username);
        setupWatcher(username);
    }

    const addAddress = (addressData) => {
        const newId = addresses.value.length > 0 ? Math.max(...addresses.value.map(a => a.id)) + 1 : 1;
        
        // If it's the first address or user sets it as main, update others
        if (addresses.value.length === 0 || addressData.isMain) {
            addresses.value.forEach(a => a.isMain = false);
            addressData.isMain = true;
        }

        addresses.value.push({ ...addressData, id: newId });
    };

    const updateAddress = (id, updatedData) => {
        const index = addresses.value.findIndex(a => a.id === id);
        if (index !== -1) {
            if (updatedData.isMain) {
                addresses.value.forEach(a => a.isMain = false);
            }
            addresses.value[index] = { ...addresses.value[index], ...updatedData };
        }
    };

    const deleteAddress = (id) => {
        addresses.value = addresses.value.filter(a => a.id !== id);
    };

    const setMainAddress = (id) => {
        addresses.value.forEach(a => {
            a.isMain = (a.id === id);
        });
    };

    return {
        addresses,
        addAddress,
        updateAddress,
        deleteAddress,
        setMainAddress
    };
}
