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
});

const activeTab = ref('products'); // 'products', 'orders', or 'admins'
const productFilter = ref('aktif'); // 'aktif' or 'habis'
const searchQuery = ref('');

// Modals State
const isStockModalOpen = ref(false);
const selectedProductId = ref('');
const stockAmount = ref(0);


const newAdminForm = useForm({
    name: '',
    username: '',
    password: '',
});

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
        case 'success': return 'success';
        case 'verified': return 'success';
        case 'shipping': return 'info';
        case 'completed': return 'success';
        case 'cancelled': return 'cancelled';
        default: return 'pending';
    }
};

const getStatusLabel = (status) => {
    switch (status?.toLowerCase()) {
        case 'pending': return 'Belum Bayar';
        case 'success': return 'SUCCESS';
        case 'verified': return 'SUCCESS';
        case 'shipping': return 'Dalam Pengiriman';
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
    
    // Stock tab filter
    if (productFilter.value === 'habis') {
        list = list.filter(p => (p.stock ?? 0) <= 0);
    } else {
        list = list.filter(p => (p.stock ?? 0) > 0);
    }
    
    return list;
});



const updateOrderStatus = (orderId, nextStatus) => {
    router.put(`/owner/orders/${orderId}/status`, { status: nextStatus }, {
        preserveScroll: true,
    });
};


const handleCreateAdmin = () => {
    newAdminForm.post('/owner/admins', {
        onSuccess: () => {
            newAdminForm.reset();
        },
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
        <section class="section active">
            <div class="container">
                <!-- Welcome Section -->
                <div class="hero" style="min-height:auto; padding: 40px 32px; margin-bottom: 40px; background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);">
                    <div class="hero-content">
                        <h2 style="color:white; font-size:28px; margin-bottom:8px;">Halo Owner, {{ username }}!</h2>
                        <p style="color:#94a3b8; margin-bottom:0; font-size:15px;">Dashboard pemilik toko. Pantau laporan omzet, stok gudang, dan konfigurasi admin staf.</p>
                    </div>
                </div>

                <!-- Stats Cards -->
                <div class="stats-grid">
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

                <!-- Tabs Selection -->
                <div class="role-tabs" style="max-width: 600px; margin-bottom: 24px;">
                    <div 
                        class="role-tab" 
                        :class="{ active: activeTab === 'products' }" 
                        @click="activeTab = 'products'"
                    >
                        Stok Produk
                    </div>
                    <div 
                        class="role-tab" 
                        :class="{ active: activeTab === 'orders' }" 
                        @click="activeTab = 'orders'"
                    >
                        Histori Transaksi
                    </div>
                    <div 
                        class="role-tab" 
                        :class="{ active: activeTab === 'admins' }" 
                        @click="activeTab = 'admins'"
                    >
                        Kelola Staf Admin
                    </div>
                </div>

                <!-- Tab 1: Products - Manajemen Stok Barang -->
                <div v-if="activeTab === 'products'" class="table-card">
                    <div class="table-header" style="flex-direction: column; gap: 16px;">
                        <div class="d-flex justify-between align-center w-100">
                            <h3 style="font-size: 20px; font-weight: 800; color: #0f172a; margin: 0;">Manajemen Stok Barang</h3>
                        </div>

                        <!-- Search + Filter + Add Button Row -->
                        <div class="d-flex justify-between align-center w-100" style="gap: 12px;">
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
                            <!-- Add Product Button -->
                            <Link 
                                href="/owner/products/create"
                                style="padding: 8px 18px; font-size: 13px; font-weight: 700; color: #0f172a; border: 1px solid #cbd5e1; border-radius: 8px; background: white; cursor: pointer; text-decoration: none; white-space: nowrap; transition: all 0.2s;"
                            >
                                + Tambah Produk Baru
                            </Link>
                        </div>

                        <!-- Aktif / Stok Habis Tabs -->
                        <div class="d-flex" style="gap: 0; border-bottom: 1px solid #e2e8f0; margin: 0 -24px; padding: 0 24px;">
                            <div 
                                @click="productFilter = 'aktif'"
                                style="padding: 10px 16px; font-size: 14px; cursor: pointer; position: relative;"
                                :style="productFilter === 'aktif' ? 'font-weight: 700; color: #0f172a; border-bottom: 2px solid #0f172a;' : 'font-weight: 500; color: #64748b;'"
                            >
                                Aktif
                            </div>
                            <div 
                                @click="productFilter = 'habis'"
                                style="padding: 10px 16px; font-size: 14px; cursor: pointer; position: relative;"
                                :style="productFilter === 'habis' ? 'font-weight: 700; color: #0f172a; border-bottom: 2px solid #0f172a;' : 'font-weight: 500; color: #64748b;'"
                            >
                                Stok Habis
                            </div>
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
                                        <Link
                                            :href="`/owner/products/${product.id}/edit`"
                                            style="padding: 5px 14px; font-size: 12px; font-weight: 600; color: #475569; border: 1px solid #cbd5e1; border-radius: 6px; background: #f8fafc; cursor: pointer; text-decoration: none; display: inline-block; transition: all 0.2s;"
                                        >
                                            Atur
                                        </Link>
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

                <!-- Tab 2: Orders -->
                <div v-else-if="activeTab === 'orders'" class="table-card">
                    <div class="table-header">
                        <h3 style="font-size:20px; font-weight: 800; color: #0f172a;">Histori Transaksi</h3>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">ID Order</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Tanggal</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Metode Pengiriman</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Nominal Tagihan</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Status</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;" class="text-center">Bukti Pembayaran</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;" class="text-center">Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="order in orders" :key="order.id">
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
                                        </div>

                                        <!-- Logistik dipindah ke admin -->
                                        <template v-else>
                                            <span style="color: #94a3b8; font-size: 12px;">-</span>
                                        </template>
                                    </td>
                                </tr>
                                <tr v-if="orders.length === 0">
                                    <td colspan="7" class="text-center text-muted" style="padding: 40px 0;">
                                        Belum ada rekap order masuk.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Tab 3: Admins Management -->
                <div v-else class="dashboard-layout" style="grid-template-columns: 1.5fr 1fr;">
                    <!-- Admins List -->
                    <div class="table-card">
                        <div class="table-header">
                            <h3 style="font-size:18px;">Staf Operator Aktif</h3>
                        </div>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Nama Staf</th>
                                        <th>Username</th>
                                        <th class="text-center">Tindakan</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="admin in admins" :key="admin.username">
                                        <td style="font-weight: 700;">{{ admin.name }}</td>
                                        <td>{{ admin.username }}</td>
                                        <td class="text-center">
                                            <button 
                                                @click="handleDeleteAdmin(admin.username)"
                                                class="btn-ghost"
                                                style="color: var(--color-danger); cursor:pointer; font-weight: 700; font-size:12px;"
                                            >
                                                Hapus Akses
                                            </button>
                                        </td>
                                    </tr>
                                    <tr v-if="admins.length === 0">
                                        <td colspan="3" class="text-center text-muted" style="padding: 40px 0;">
                                            Belum ada staf administrator.
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Create Admin Form -->
                    <div class="sidebar-card">
                        <h3 class="mb-4" style="font-size: 18px;">Tambah Staf Admin</h3>
                        <form @submit.prevent="handleCreateAdmin">
                            <div class="form-group">
                                <label class="form-label">Nama Staf</label>
                                <input 
                                    type="text" 
                                    class="form-input" 
                                    placeholder="Nama Lengkap" 
                                    v-model="newAdminForm.name"
                                    required
                                >
                            </div>
                            <div class="form-group">
                                <label class="form-label">Username</label>
                                <input 
                                    type="text" 
                                    class="form-input" 
                                    placeholder="Username login" 
                                    v-model="newAdminForm.username"
                                    required
                                >
                            </div>
                            <div class="form-group mb-6">
                                <label class="form-label">Kata Sandi</label>
                                <input 
                                    type="password" 
                                    class="form-input" 
                                    placeholder="Min. 3 karakter" 
                                    v-model="newAdminForm.password"
                                    required
                                >
                            </div>
                            <button 
                                type="submit" 
                                class="btn btn-primary w-100" 
                                :disabled="newAdminForm.processing"
                            >
                                <span v-if="newAdminForm.processing">Mendaftarkan...</span>
                                <span v-else>Daftarkan Staf</span>
                            </button>
                        </form>
                    </div>
                </div>
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

    </AppLayout>
</template>
