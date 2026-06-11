<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { router, useForm, Link } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    products: {
        type: Array,
        default: () => [],
    },
    orders: {
        type: Array,
        default: () => [],
    },
    admins: {
        type: Array,
        default: () => [],
    },
    username: {
        type: String,
        required: true,
    },
    stats: {
        type: Object,
        default: () => ({ totalRevenue: 0, salesCount: 0, stockIssuesCount: 0, totalAdmins: 0 }),
    },
    profile: {
        type: Object,
        default: () => ({}),
    },
});

const activeTab = ref('dashboard'); // 'dashboard', 'products', 'validasi', 'histori', 'admins', or 'profile'
const productFilter = ref('aktif'); // 'aktif' or 'habis'
const searchQuery = ref('');
const categoryFilter = ref('');

// Modals State
const isStockModalOpen = ref(false);
const selectedProductId = ref('');
const stockAmount = ref(0);

// Variant Modal State
const isVariantModalOpen = ref(false);
const selectedProductVariants = ref([]);
const newVariantForm = useForm({
    name: '',
    price: 0,
});


const isCreateAdminModalOpen = ref(false);
const newAdminForm = useForm({
    name: '',
    username: '',
    email: '',
    phone: '',
    password: '',
});

const profileForm = useForm({
    name: props.profile?.name || '',
    username: props.profile?.username || '',
    email: props.profile?.email || '',
    phone: props.profile?.phone || '',
    password: '',
});

const saveProfile = () => {
    profileForm.put('/owner/profile', {
        preserveScroll: true,
        onSuccess: () => {
            profileForm.password = '';
        }
    });
};

const formatPrice = (price) => {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(price).replace('Rp', 'Rp ');
};

const formatDate = (dateStr) => {
    if (!dateStr) return '-';
    try {
        const date = new Date(dateStr);
        return date.toLocaleDateString('id-ID', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
        });
    } catch (e) {
        return dateStr;
    }
};

const getStatusClass = (status) => {
    switch (status?.toLowerCase()) {
        case 'pending': return 'pending';
        case 'success': return 'warning';
        case 'verified': return 'warning';
        case 'shipping': return 'pending';
        case 'completed': return 'success';
        case 'cancelled': return 'cancelled';
        default: return 'pending';
    }
};

const getStatusLabel = (status) => {
    switch (status?.toLowerCase()) {
        case 'pending': return 'Menunggu Konfirmasi';
        case 'success': return 'Diproses';
        case 'verified': return 'Diproses';
        case 'shipping': return 'Dikirim';
        case 'completed': return 'Selesai';
        case 'cancelled': return 'Dibatalkan';
        default: return status;
    }
};

// Actions
const openStockModal = (productId, currentStock) => {
    selectedProductId.value = productId;
    stockAmount.value = currentStock;
    isStockModalOpen.value = true;
};

const handleUpdateStock = () => {
    router.put(`/owner/products/${selectedProductId.value}/stock`, {
        amount: stockAmount.value,
    }, {
        onSuccess: () => {
            isStockModalOpen.value = false;
        },
        preserveScroll: true,
    });
};

const openVariantModal = (product) => {
    selectedProductId.value = product.id;
    selectedProductVariants.value = product.variants || [];
    newVariantForm.reset();
    isVariantModalOpen.value = true;
};

const handleAddVariant = () => {
    newVariantForm.post(`/owner/products/${selectedProductId.value}/variants`, {
        preserveScroll: true,
        onSuccess: (page) => {
            // Update variants array from props if possible, or just let page reload handle it
            const prod = page.props.products.find(p => p.id === selectedProductId.value);
            if (prod) {
                selectedProductVariants.value = prod.variants || [];
            }
            newVariantForm.reset();
        }
    });
};

const handleRemoveVariant = (variantId) => {
    if (confirm('Yakin ingin menghapus varian ini?')) {
        router.delete(`/owner/products/${selectedProductId.value}/variants/${variantId}`, {
            preserveScroll: true,
            onSuccess: (page) => {
                const prod = page.props.products.find(p => p.id === selectedProductId.value);
                if (prod) {
                    selectedProductVariants.value = prod.variants || [];
                }
            }
        });
    }
};

// Filtered products based on search and stock filter
const filteredProducts = computed(() => {
    let list = props.products || [];
    
    // Search filter
    if (searchQuery.value.trim()) {
        const q = searchQuery.value.toLowerCase();
        list = list.filter(p => 
            p.name?.toLowerCase().includes(q) || 
            p.id?.toLowerCase().includes(q) ||
            p.category?.toLowerCase().includes(q)
        );
    }
    
    // Category filter
    if (categoryFilter.value) {
        list = list.filter(p => p.category === categoryFilter.value);
    }
    
    // Stock tab filter
    if (productFilter.value === 'habis') {
        list = list.filter(p => (p.stock ?? 0) <= 0);
    } else {
        list = list.filter(p => (p.stock ?? 0) > 0);
    }
    
    return list;
});

const uniqueCategories = computed(() => {
    if (!props.products) return [];
    const categories = new Set(props.products.map(p => p.category).filter(Boolean));
    return Array.from(categories).sort();
});

const orderSearchQuery = ref('');
const orderDateFilter = ref('');
const orderStatusFilter = ref('Semua');

const filteredOrders = computed(() => {
    let ordersToFilter = props.orders || [];
    
    if (orderSearchQuery.value) {
        const q = orderSearchQuery.value.toLowerCase();
        ordersToFilter = ordersToFilter.filter(o => 
            o.id.toLowerCase().includes(q) || 
            (o.items && o.items.some(item => item.name.toLowerCase().includes(q)))
        );
    }
    
    if (orderDateFilter.value) {
        ordersToFilter = ordersToFilter.filter(o => {
            if (!o.createdAt) return false;
            // Handle ISO date format YYYY-MM-DD
            return o.createdAt.startsWith(orderDateFilter.value);
        });
    }

    if (orderStatusFilter.value && orderStatusFilter.value !== 'Semua') {
        ordersToFilter = ordersToFilter.filter(o => {
            const s = o.status?.toLowerCase();
            const filterMap = {
                'Menunggu Konfirmasi': ['pending'],
                'Diproses': ['success'],
                'Dikirim': ['shipping'],
                'Dibatalkan': ['cancelled'],
                'Selesai': ['completed']
            };
            const expectedStatuses = filterMap[orderStatusFilter.value] || [];
            return expectedStatuses.includes(s);
        });
    }
    
    return ordersToFilter;
});

const resetOrderFilters = () => {
    orderSearchQuery.value = '';
    orderDateFilter.value = '';
    orderStatusFilter.value = 'Semua';
};



const updateOrderStatus = (orderId, nextStatus) => {
    if (nextStatus === 'cancelled') {
        if (!confirm('Apakah Anda yakin ingin membatalkan pesanan ini?')) {
            return;
        }
    }
    
    router.put(`/owner/orders/${orderId}/status`, { status: nextStatus }, {
        preserveScroll: true,
    });
};


const handleCreateAdmin = () => {
    newAdminForm.post('/owner/admins', {
        onSuccess: () => {
            newAdminForm.reset();
            isCreateAdminModalOpen.value = false;
        },
        preserveScroll: true,
    });
};

const isEditAdminModalOpen = ref(false);
const editAdminForm = useForm({
    username: '',
    name: '',
    phone: '',
    email: '',
    password: '',
});

const openEditAdminModal = (admin) => {
    editAdminForm.username = admin.username;
    editAdminForm.name = admin.name;
    editAdminForm.phone = admin.phone || '';
    editAdminForm.email = admin.email || '';
    editAdminForm.password = '';
    isEditAdminModalOpen.value = true;
};

const handleUpdateAdmin = () => {
    editAdminForm.put(`/owner/admins/${editAdminForm.username}`, {
        onSuccess: () => {
            isEditAdminModalOpen.value = false;
        },
        preserveScroll: true,
    });
};

const handleDeleteAdmin = (adminUsername) => {
    if (confirm(`Apakah Anda yakin ingin menghapus staf admin "${adminUsername}"?`)) {
        router.delete(`/owner/admins/${adminUsername}`, {
            preserveScroll: true,
        });
    }
};
</script>

<template>
    <AppLayout>
        <section class="section active" style="padding-top: 40px; background: #f8fafc; min-height: 100vh;">
            <div class="container">
                <div style="display: grid; grid-template-columns: 280px 1fr; gap: 32px; align-items: start;">
                    
                    <!-- Sidebar -->
                    <div style="background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 24px;">
                        <!-- Profile -->
                        <div 
                            class="d-flex align-center gap-4 mb-4" 
                            @click="activeTab = 'profile'" 
                            style="cursor: pointer; padding: 12px; border-radius: 8px; transition: background 0.2s; margin: -12px -12px 16px -12px;"
                            :style="activeTab === 'profile' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent; hover: background: #f8fafc;'"
                        >
                            <div style="width: 48px; height: 48px; background: #e11d48; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 800; box-shadow: 0 4px 10px rgba(225, 29, 72, 0.4);">
                                {{ username ? username.charAt(0).toUpperCase() : 'O' }}
                            </div>
                            <div>
                                <h3 style="font-size: 16px; font-weight: 800; margin: 0; color: #0f172a;">{{ username }}</h3>
                                <div style="font-size: 13px; color: #64748b;">Sistem Kontrol Utama</div>
                            </div>
                        </div>
                        
                        <div style="height: 1px; background: #e2e8f0; margin: 16px 0;"></div>
                        
                        <!-- Menu -->
                        <div style="display: flex; flex-direction: column; gap: 8px;">
                            <div 
                                @click="activeTab = 'dashboard'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'dashboard' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'dashboard' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Dashboard Owner</span>
                                <div v-if="activeTab === 'dashboard'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>

                            <div 
                                @click="activeTab = 'products'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'products' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'products' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Stok Produk</span>
                                <div v-if="activeTab === 'products'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                            
                            <div 
                                @click="activeTab = 'validasi'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'validasi' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'validasi' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Validasi Pembayaran</span>
                                <div v-if="activeTab === 'validasi'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                            
                            <div 
                                @click="activeTab = 'histori'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'histori' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'histori' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Histori Transaksi</span>
                                <div v-if="activeTab === 'histori'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                            
                            <div 
                                @click="activeTab = 'admins'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'admins' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'admins' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Kelola Staf Admin</span>
                                <div v-if="activeTab === 'admins'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                        </div>
                    </div>

                    <!-- Main Content -->
                    <div>
                        <!-- Tab Profil Saya -->
                        <div v-if="activeTab === 'profile'" style="background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 24px;">
                            <h3 style="font-size: 20px; font-weight: 800; color: #0f172a; margin-top: 0; margin-bottom: 24px;">Profil Saya</h3>
                            
                            <form @submit.prevent="saveProfile">
                                <div v-if="$page.props.flash.success" style="background: #ecfdf5; color: #065f46; padding: 12px; border-radius: 8px; margin-bottom: 24px; border: 1px solid #10b981; font-weight: 600; font-size: 14px;">
                                    {{ $page.props.flash.success }}
                                </div>
                                <div v-if="$page.props.flash.error" style="background: #fef2f2; color: #b91c1c; padding: 12px; border-radius: 8px; margin-bottom: 24px; border: 1px solid #ef4444; font-weight: 600; font-size: 14px;">
                                    {{ $page.props.flash.error }}
                                </div>
                                <div v-if="profileForm.errors.username" style="background: #fef2f2; color: #b91c1c; padding: 12px; border-radius: 8px; margin-bottom: 24px; border: 1px solid #ef4444; font-weight: 600; font-size: 14px;">
                                    {{ profileForm.errors.username }}
                                </div>
                                
                                <div class="form-group mb-4">
                                    <label class="form-label" style="font-size: 14px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Nama Lengkap</label>
                                    <input type="text" v-model="profileForm.name" style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;" required>
                                </div>
                                <div class="form-group mb-4">
                                    <label class="form-label" style="font-size: 14px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Username</label>
                                    <input type="text" v-model="profileForm.username" style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;" required>
                                </div>
                                <div class="form-group mb-4">
                                    <label class="form-label" style="font-size: 14px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Email</label>
                                    <input type="email" v-model="profileForm.email" style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;">
                                </div>
                                <div class="form-group mb-4">
                                    <label class="form-label" style="font-size: 14px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Nomor HP</label>
                                    <input type="text" v-model="profileForm.phone" style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;">
                                </div>
                                <div class="form-group mb-6">
                                    <label class="form-label" style="font-size: 14px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Password Baru <span style="font-weight: 400; color: #94a3b8;">(Kosongkan jika tidak ingin mengubah)</span></label>
                                    <input type="password" v-model="profileForm.password" style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;" placeholder="Min. 3 karakter">
                                </div>
                                
                                <button type="submit" style="padding: 12px 24px; background: #e11d48; color: white; border-radius: 8px; font-weight: 700; border: none; cursor: pointer;" :disabled="profileForm.processing">Simpan Perubahan</button>
                            </form>
                        </div>
                        
                        <template v-else>
                        <!-- Tab 0: Dashboard Owner (Stats Only) -->
                        <div v-if="activeTab === 'dashboard'" class="stats-grid mb-6">
                            <div class="stat-card">
                                <span class="stat-title">Omzet Finansial</span>
                                <span class="stat-value" style="color:var(--color-primary)">
                                    {{ formatPrice(stats.totalRevenue) }}
                                </span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-title">Transaksi Selesai</span>
                                <span class="stat-value">{{ stats.salesCount }}</span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-title" style="color: var(--color-warning);">Butuh Restock</span>
                                <span class="stat-value" style="color: var(--color-warning);">{{ stats.stockIssuesCount }}</span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-title">Staf Administrator</span>
                                <span class="stat-value">{{ stats.totalAdmins }}</span>
                            </div>
                        </div>

                        <!-- Tab 1: Products - Manajemen Stok Barang -->
                <div v-if="activeTab === 'products'" class="table-card">
                    <div class="table-header" style="flex-direction: column; gap: 16px;">
                        <div class="d-flex justify-between align-center w-100">
                            <h3 style="font-size: 20px; font-weight: 800; color: #0f172a; margin: 0;">Manajemen Stok Barang</h3>
                        </div>

                        <!-- Search + Filter + Add Button Row -->
                        <div class="d-flex justify-between align-center w-100" style="gap: 12px; flex-wrap: wrap;">
                            <div class="d-flex" style="gap: 10px; flex-direction: column;">
                                <div class="d-flex align-center" style="gap: 10px;">
                                    <!-- Search Bar -->
                                    <div style="position: relative;">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 50%; transform: translateY(-50%);">
                                            <circle cx="11" cy="11" r="8"></circle>
                                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                        </svg>
                                        <input 
                                            v-model="searchQuery"
                                            type="text" 
                                            placeholder="Cari Nama Produk" 
                                            style="padding: 8px 12px 8px 36px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; width: 220px; outline: none; background: white;"
                                        >
                                    </div>
                                    <!-- Filter Button -->
                                    <button style="padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; background: white; cursor: pointer; display: flex; align-items: center; justify-content: center;">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <line x1="4" y1="6" x2="20" y2="6"></line>
                                            <line x1="6" y1="12" x2="18" y2="12"></line>
                                            <line x1="8" y1="18" x2="16" y2="18"></line>
                                        </svg>
                                    </button>
                                </div>
                                
                                <div class="d-flex align-center" style="gap: 12px; flex-wrap: wrap;">
                                    <!-- Category Dropdown Filter -->
                                    <select v-model="categoryFilter" style="padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; outline: none; background: white; width: fit-content; min-width: 160px;">
                                        <option value="">Semua Kategori</option>
                                        <option v-for="cat in uniqueCategories" :key="cat" :value="cat">{{ cat }}</option>
                                    </select>

                                    <!-- Aktif / Stok Habis Pills -->
                                    <div class="d-flex align-center" style="background: #f1f5f9; padding: 4px; border-radius: 8px; border: 1px solid #e2e8f0;">
                                        <div 
                                            @click="productFilter = 'aktif'"
                                            style="padding: 6px 16px; font-size: 13px; font-weight: 600; cursor: pointer; border-radius: 6px; transition: all 0.2s;"
                                            :style="productFilter === 'aktif' ? 'background: white; color: #0f172a; box-shadow: 0 1px 3px rgba(0,0,0,0.1);' : 'color: #64748b;'"
                                        >
                                            Stok Tersedia
                                        </div>
                                        <div 
                                            @click="productFilter = 'habis'"
                                            style="padding: 6px 16px; font-size: 13px; font-weight: 600; cursor: pointer; border-radius: 6px; transition: all 0.2s;"
                                            :style="productFilter === 'habis' ? 'background: white; color: #dc2626; box-shadow: 0 1px 3px rgba(0,0,0,0.1);' : 'color: #64748b;'"
                                        >
                                            Stok Habis
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- Add Product Button -->
                            <Link 
                                href="/owner/products/create"
                                style="padding: 8px 18px; font-size: 13px; font-weight: 700; color: #0f172a; border: 1px solid #cbd5e1; border-radius: 8px; background: white; cursor: pointer; text-decoration: none; white-space: nowrap; transition: all 0.2s; align-self: flex-start;"
                            >
                                + Tambah Produk Baru
                            </Link>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="width: 80px;">ID</th>
                                    <th>Nama Produk</th>
                                    <th>Kategori</th>
                                    <th class="text-center" style="width: 80px;">Stok</th>
                                    <th class="text-center" style="width: 90px;">Terjual</th>
                                    <th class="text-center" style="width: 80px;">Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="product in filteredProducts" :key="product.id">
                                    <td style="font-weight: 700; font-family: monospace; font-size: 13px; color: #475569;">{{ product.id }}</td>
                                    <td style="font-weight: 600; color: #0f172a;">{{ product.name }}</td>
                                    <td style="color: #475569;">{{ product.category }}</td>
                                    <td class="text-center" style="font-weight: 800;" :style="product.stock <= 5 ? { color: '#06b6d4' } : { color: '#06b6d4' }">
                                        {{ product.stock }}
                                    </td>
                                    <td class="text-center" style="font-weight: 700; color: #06b6d4;">
                                        {{ product.sold || 0 }}
                                    </td>
                                    <td class="text-center">
                                        <div class="d-flex align-center justify-center gap-2">
                                            <button
                                                @click="openVariantModal(product)"
                                                style="padding: 5px 14px; font-size: 12px; font-weight: 600; color: #475569; border: 1px solid #cbd5e1; border-radius: 6px; background: #f8fafc; cursor: pointer; transition: all 0.2s;"
                                            >
                                                Varian
                                            </button>
                                            <Link
                                                :href="`/owner/products/${product.id}/edit`"
                                                style="padding: 5px 14px; font-size: 12px; font-weight: 600; color: #475569; border: 1px solid #cbd5e1; border-radius: 6px; background: #f8fafc; cursor: pointer; text-decoration: none; display: inline-block; transition: all 0.2s;"
                                            >
                                                Atur
                                            </Link>
                                        </div>
                                    </td>
                                </tr>
                                <tr v-if="filteredProducts.length === 0">
                                    <td colspan="6" class="text-center text-muted" style="padding: 40px 0;">
                                        {{ productFilter === 'habis' ? 'Tidak ada produk dengan stok habis.' : 'Tidak ada produk ditemukan.' }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Tab 2: Validasi Pembayaran -->
                <div v-else-if="activeTab === 'validasi'" class="table-card">
                    <div class="table-header" style="flex-direction: column; gap: 16px;">
                        <h3 style="font-size:20px; font-weight: 800; color: #0f172a; margin: 0; align-self: flex-start;">Validasi Pembayaran</h3>
                        
                        <!-- Order Filters -->
                        <div class="d-flex align-center gap-4 flex-wrap w-100" style="background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0;">
                            <!-- Search -->
                            <div style="position: relative; flex: 1; min-width: 250px;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 11px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                <input v-model="orderSearchQuery" type="text" placeholder="Cari ID Pesanan / Produk" style="width: 100%; padding: 8px 12px 8px 36px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;">
                            </div>
                            
                            <!-- Date Filter -->
                            <div style="position: relative; min-width: 150px;">
                                <input v-model="orderDateFilter" type="date" style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; color: #475569;">
                            </div>
                        </div>

                        <!-- Status Pills -->
                        <div class="d-flex align-center gap-2 flex-wrap w-100">
                            <span style="font-size: 13px; font-weight: 700; color: #64748b; margin-right: 8px;">Status:</span>
                            <template v-for="status in ['Semua', 'Menunggu Konfirmasi', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan']" :key="status">
                                <button
                                    @click="orderStatusFilter = status"
                                    style="padding: 4px 12px; font-size: 12px; border-radius: 16px; cursor: pointer; transition: all 0.2s; border: 1px solid;"
                                    :style="orderStatusFilter === status ? 'background: #eafff2; color: #16a34a; border-color: #16a34a; font-weight: 600;' : 'background: white; color: #64748b; border-color: #cbd5e1;'"
                                >
                                    {{ status }}
                                </button>
                            </template>
                            <span @click="resetOrderFilters" style="font-size: 12px; font-weight: 700; color: #16a34a; cursor: pointer; margin-left: auto;">Reset Filter</span>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">ID Order</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Tanggal</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Metode Pengiriman</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Item Pesanan</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Nominal Tagihan</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Status</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;" class="text-center">Bukti Pembayaran</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;" class="text-center">Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="order in filteredOrders" :key="order.id">
                                    <!-- ID Order -->
                                    <td style="font-weight: 800; font-family: monospace; color: #0f172a;">
                                        {{ order.id }}
                                    </td>

                                    <!-- Tanggal -->
                                    <td style="color: #475569;">{{ formatDate(order.createdAt) }}</td>

                                    <!-- Metode Pengiriman -->
                                    <td style="font-weight: 600; color: #0f172a;">
                                        {{ order.shippingMethod || 'JNE' }}
                                    </td>

                                    <!-- Item Pesanan -->
                                    <td>
                                        <div v-for="item in order.items" :key="item.productId" style="margin-bottom: 8px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px;">
                                            <div style="font-size: 12px; font-weight: 700; color: #0f172a;">{{ item.name }} ({{ item.qty }}x)</div>
                                            <div v-if="item.color" style="font-size: 11px; color: #64748b; margin-top: 2px;">Warna: <span style="font-weight: 600;">{{ item.color }}</span></div>
                                        </div>
                                    </td>

                                    <!-- Nominal Tagihan -->
                                    <td style="font-weight: 800; color: #dc2626;">
                                        {{ formatPrice(order.total || order.totalAmount || 0) }}
                                    </td>

                                    <!-- Status -->
                                    <td>
                                        <span class="status-pill" :class="getStatusClass(order.status)">
                                            {{ getStatusLabel(order.status) }}
                                        </span>
                                    </td>

                                    <!-- Bukti Pembayaran -->
                                    <td class="text-center">
                                        <a v-if="order.proofUploaded && order.proofUrl" :href="order.proofUrl" target="_blank" class="d-flex align-center justify-center gap-2" style="color: #0284c7; font-weight: 600; font-size: 12px; text-decoration: none; cursor: pointer;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                                <circle cx="12" cy="12" r="3"></circle>
                                            </svg>
                                            Lihat
                                        </a>
                                        <div v-else-if="order.proofUploaded" style="color: #94a3b8; font-style: italic; font-size: 12px;">
                                            Uploaded
                                        </div>
                                        <div v-else style="color: #94a3b8; font-style: italic; font-size: 12px;">
                                            -
                                        </div>
                                    </td>

                                    <!-- Aksi: Conditional per status & shipping type -->
                                    <td class="text-center">
                                        <!-- Validasi Pembayaran untuk Pending -->
                                        <div v-if="order.status?.toLowerCase() === 'pending'" class="d-flex align-center justify-center gap-2">
                                            <template v-if="order.payment && (order.payment.paymentMethod?.toLowerCase().includes('midtrans') || order.payment.paymentMethod?.toLowerCase().includes('online'))">
                                                <span style="color: #64748b; font-size: 11px; font-style: italic;">Menunggu<br>Sistem Midtrans</span>
                                            </template>
                                            <template v-else>
                                                <button 
                                                    @click="updateOrderStatus(order.id, 'success')"
                                                    class="btn btn-primary"
                                                    style="padding: 4px 10px; font-size:11px; background:#0284c7; border-color:#0284c7; border-radius: 4px;"
                                                >
                                                    Validasi
                                                </button>
                                                <button 
                                                    @click="updateOrderStatus(order.id, 'cancelled')"
                                                    class="btn btn-outline"
                                                    style="padding: 4px 10px; font-size:11px; color: #dc2626; border-color: #dc2626; border-radius: 4px;"
                                                >
                                                    Tolak
                                                </button>
                                            </template>
                                        </div>

                                        <!-- Logistik dipindah ke admin -->
                                        <template v-else>
                                            <div class="d-flex align-center justify-center gap-2">
                                                <button v-if="order.status?.toLowerCase() !== 'cancelled' && order.status?.toLowerCase() !== 'completed'"
                                                    @click="updateOrderStatus(order.id, 'cancelled')"
                                                    class="btn btn-outline"
                                                    style="padding: 4px 10px; font-size:11px; color: #dc2626; border-color: #dc2626; border-radius: 4px;"
                                                    title="Batalkan secara manual jika sudah dibatalkan di Biteship"
                                                >
                                                    Batalkan
                                                </button>
                                                <span v-else style="color: #94a3b8; font-size: 12px;">-</span>
                                            </div>
                                        </template>
                                    </td>
                                </tr>
                                <tr v-if="filteredOrders.length === 0">
                                    <td colspan="8" class="text-center text-muted" style="padding: 40px 0;">
                                        Belum ada rekap order yang sesuai.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Tab 2.5: Histori Transaksi -->
                <div v-else-if="activeTab === 'histori'" class="table-card">
                    <div class="table-header" style="flex-direction: column; gap: 16px;">
                        <h3 style="font-size:20px; font-weight: 800; color: #0f172a; margin: 0; align-self: flex-start;">Histori Transaksi</h3>
                        
                        <!-- Order Filters -->
                        <div class="d-flex align-center gap-4 flex-wrap w-100" style="background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0;">
                            <!-- Search -->
                            <div style="position: relative; flex: 1; min-width: 250px;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 11px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                <input v-model="orderSearchQuery" type="text" placeholder="Cari ID Pesanan / Produk" style="width: 100%; padding: 8px 12px 8px 36px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;">
                            </div>
                            
                            <!-- Date Filter -->
                            <div style="position: relative; min-width: 150px;">
                                <input v-model="orderDateFilter" type="date" style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; color: #475569;">
                            </div>
                        </div>

                        <!-- Status Pills -->
                        <div class="d-flex align-center gap-2 flex-wrap w-100">
                            <span style="font-size: 13px; font-weight: 700; color: #64748b; margin-right: 8px;">Status:</span>
                            <template v-for="status in ['Semua', 'Menunggu Konfirmasi', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan']" :key="status">
                                <button
                                    @click="orderStatusFilter = status"
                                    style="padding: 4px 12px; font-size: 12px; border-radius: 16px; cursor: pointer; transition: all 0.2s; border: 1px solid;"
                                    :style="orderStatusFilter === status ? 'background: #eafff2; color: #16a34a; border-color: #16a34a; font-weight: 600;' : 'background: white; color: #64748b; border-color: #cbd5e1;'"
                                >
                                    {{ status }}
                                </button>
                            </template>
                            <span @click="resetOrderFilters" style="font-size: 12px; font-weight: 700; color: #16a34a; cursor: pointer; margin-left: auto;">Reset Filter</span>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">ID Order</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Nama Pelanggan</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Tanggal</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Metode Pengiriman</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Item Pesanan</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Nominal Tagihan</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="order in filteredOrders" :key="order.id">
                                    <td style="font-weight: 800; font-family: monospace; color: #0f172a;">
                                        {{ order.id }}
                                    </td>
                                    <td style="font-weight: 600; color: #0f172a;">
                                        {{ order.customer || '-' }}
                                    </td>
                                    <td style="color: #475569;">{{ formatDate(order.createdAt) }}</td>
                                    <td style="font-weight: 600; color: #0f172a;">
                                        {{ order.shippingMethod || 'JNE' }}
                                    </td>
                                    <td>
                                        <div v-for="item in order.items" :key="item.productId" style="margin-bottom: 8px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px;">
                                            <div style="font-size: 12px; font-weight: 700; color: #0f172a;">{{ item.name }} ({{ item.qty }}x)</div>
                                            <div v-if="item.color" style="font-size: 11px; color: #64748b; margin-top: 2px;">Warna: <span style="font-weight: 600;">{{ item.color }}</span></div>
                                        </div>
                                    </td>
                                    <td style="font-weight: 800; color: #dc2626;">
                                        {{ formatPrice(order.total || order.totalAmount || 0) }}
                                    </td>
                                    <td>
                                        <span class="status-pill" :class="getStatusClass(order.status)">
                                            {{ getStatusLabel(order.status) }}
                                        </span>
                                    </td>
                                </tr>
                                <tr v-if="filteredOrders.length === 0">
                                    <td colspan="7" class="text-center text-muted" style="padding: 40px 0;">
                                        Belum ada histori transaksi.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Tab 3: Admins Management -->
                <div v-else class="dashboard-layout" style="grid-template-columns: 1fr;">
                    <!-- Admins List -->
                    <div class="table-card">
                        <div class="table-header d-flex justify-between align-center">
                            <h3 style="font-size:18px;">Staf Operator Aktif</h3>
                            <button @click="isCreateAdminModalOpen = true" class="btn btn-primary" style="font-size: 13px; padding: 8px 16px;">
                                + Tambah Admin
                            </button>
                        </div>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">NAMA</th>
                                        <th style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">NO TELEPON</th>
                                        <th style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">EMAIL</th>
                                        <th style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">ROLE</th>
                                        <th style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">TANGGAL DIBUAT</th>
                                        <th class="text-center" style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">AKSI</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="admin in admins.filter(a => a.role !== 'Owner')" :key="admin.username">
                                        <td style="font-weight: 700; color: #334155;">{{ admin.name }}</td>
                                        <td style="color: #475569;">{{ admin.phone || '-' }}</td>
                                        <td style="color: #475569;">{{ admin.email || '-' }}</td>
                                        <td>
                                            <span style="padding: 4px 12px; font-size: 11px; border-radius: 12px; font-weight: 600; background: #dbeafe; color: #1e40af;">
                                                {{ admin.role }}
                                            </span>
                                        </td>
                                        <td style="color: #475569;">{{ formatDate(admin.createdAt) }}</td>
                                        <td class="text-center">
                                            <div class="d-flex align-center justify-center gap-3">
                                                <button @click="openEditAdminModal(admin)" style="background: none; border: none; cursor: pointer; color: #eab308; padding: 4px;" title="Edit">
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"></path><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>
                                                </button>
                                                <button v-if="admin.role === 'Admin'" @click="handleDeleteAdmin(admin.username)" style="background: none; border: none; cursor: pointer; color: #ef4444; padding: 4px;" title="Hapus">
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr v-if="admins.length === 0">
                                        <td colspan="6" class="text-center text-muted" style="padding: 40px 0;">
                                            Belum ada staf administrator.
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    </div>
                    </template>
                    </div> <!-- End Main Content -->
                </div> <!-- End Grid Layout -->
            </div>
        </section>

        <!-- Stock Update Modal -->
        <div v-if="isStockModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:400px; padding:32px; animation: slideUp 0.3s forwards;">
                <h3 class="mb-4">Update Jumlah Stok</h3>
                <form @submit.prevent="handleUpdateStock">
                    <div class="form-group mb-6">
                        <label class="form-label">Jumlah Stok Baru</label>
                        <input 
                            type="number" 
                            class="form-input" 
                            v-model.number="stockAmount" 
                            min="0"
                            required
                        >
                    </div>
                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isStockModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100">Simpan Stok</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Variant Modal -->
        <div v-if="isVariantModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:500px; padding:32px; animation: slideUp 0.3s forwards;">
                <div class="d-flex justify-between align-center mb-6">
                    <h3 style="margin: 0;">Kelola Varian</h3>
                    <button @click="isVariantModalOpen = false" style="background: none; border: none; font-size: 24px; cursor: pointer; color: #64748b;">&times;</button>
                </div>
                
                <div v-if="selectedProductVariants.length > 0" class="mb-6">
                    <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                        <thead>
                            <tr style="border-bottom: 2px solid #e2e8f0;">
                                <th style="text-align: left; padding: 8px; color: #64748b;">Nama Varian</th>
                                <th style="text-align: right; padding: 8px; color: #64748b;">Harga (Rp)</th>
                                <th style="text-align: center; padding: 8px; color: #64748b; width: 60px;">Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="variant in selectedProductVariants" :key="variant.id" style="border-bottom: 1px solid #f1f5f9;">
                                <td style="padding: 12px 8px; font-weight: 600; color: #334155;">{{ variant.name }}</td>
                                <td style="padding: 12px 8px; text-align: right; color: #0f172a;">{{ variant.price > 0 ? formatPrice(variant.price) : 'Default' }}</td>
                                <td style="padding: 12px 8px; text-align: center;">
                                    <button @click="handleRemoveVariant(variant.id)" style="color: #ef4444; background: none; border: none; cursor: pointer; font-size: 13px; font-weight: 600;">Hapus</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div v-else class="mb-6 text-center" style="padding: 20px; background: #f8fafc; border-radius: 8px; color: #64748b; font-size: 14px;">
                    Belum ada varian untuk produk ini.
                </div>

                <form @submit.prevent="handleAddVariant" style="background: #f1f5f9; padding: 16px; border-radius: 8px;">
                    <h4 class="mb-3" style="font-size: 14px; color: #334155;">Tambah Varian Baru</h4>
                    <div class="d-flex gap-2 mb-3">
                        <div style="flex: 1;">
                            <input v-model="newVariantForm.name" type="text" placeholder="Nama Varian (Cth: Merah)" required class="form-input" style="font-size: 13px;">
                        </div>
                        <div style="flex: 1;">
                            <input v-model.number="newVariantForm.price" type="number" min="0" placeholder="Harga Khusus (0 = default)" class="form-input" style="font-size: 13px;">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary w-100" :disabled="newVariantForm.processing" style="padding: 8px 16px;">
                        {{ newVariantForm.processing ? 'Menambahkan...' : 'Tambah Varian' }}
                    </button>
                </form>
            </div>
        </div>

        <!-- Edit Admin Modal -->
        <div v-if="isEditAdminModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:400px; padding:32px; animation: slideUp 0.3s forwards;">
                <h3 class="mb-4">Update Profil Admin</h3>
                <form @submit.prevent="handleUpdateAdmin">
                    <div class="form-group mb-4">
                        <label class="form-label">Nama Lengkap</label>
                        <input type="text" class="form-input" v-model="editAdminForm.name" required>
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label">Nomor HP</label>
                        <input type="text" class="form-input" v-model="editAdminForm.phone">
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-input" v-model="editAdminForm.email">
                    </div>
                    <div class="form-group mb-6">
                        <label class="form-label">Password Baru <span style="font-weight: 400; color: #94a3b8; font-size: 12px;">(Kosongkan jika tak diubah)</span></label>
                        <input type="password" class="form-input" v-model="editAdminForm.password" placeholder="Min. 3 karakter">
                    </div>
                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isEditAdminModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100" :disabled="editAdminForm.processing">Simpan</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Create Admin Modal -->
        <div v-if="isCreateAdminModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:400px; padding:32px; animation: slideUp 0.3s forwards;">
                <h3 class="mb-4">Tambah Staf Admin Baru</h3>
                <form @submit.prevent="handleCreateAdmin">
                    <div class="form-group mb-4">
                        <label class="form-label">Nama Lengkap</label>
                        <input type="text" class="form-input" v-model="newAdminForm.name" required>
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label">Username</label>
                        <input type="text" class="form-input" v-model="newAdminForm.username" required>
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label">Nomor HP</label>
                        <input type="text" class="form-input" v-model="newAdminForm.phone">
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-input" v-model="newAdminForm.email">
                    </div>
                    <div class="form-group mb-6">
                        <label class="form-label">Password</label>
                        <input type="password" class="form-input" v-model="newAdminForm.password" placeholder="Min. 3 karakter" required>
                    </div>
                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isCreateAdminModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100" :disabled="newAdminForm.processing">Simpan</button>
                    </div>
                </form>
            </div>
        </div>

    </AppLayout>
</template>
