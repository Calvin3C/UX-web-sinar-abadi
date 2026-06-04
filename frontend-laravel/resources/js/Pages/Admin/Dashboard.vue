<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { router } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    orders: {
        type: Array,
        default: () => [],
    },
    customers: {
        type: Array,
        default: () => [],
    },
    username: {
        type: String,
        required: true,
    },
    stats: {
        type: Object,
        default: () => ({ totalOrders: 0, pendingOrders: 0, verifiedOrders: 0, totalCustomers: 0 }),
    },
});

const activeTab = ref('orders'); // 'orders' or 'customers'

const isShippingModalOpen = ref(false);
const selectedOrderId = ref('');
const shippingCode = ref('');

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

// Helper to classify shipping method type
const getShippingType = (method) => {
    if (!method) return 'kurir';
    const m = method.toLowerCase();
    if (m.includes('ambil di toko') || m.includes('ambil')) return 'ambil';
    if (m.includes('kurir toko') || m.includes('kurir sinar') || m.includes('sinar abadi')) return 'kurir_toko';
    return 'kurir'; // JNE, JNT, etc.
};

const handleMarkCompleted = (orderId) => {
    router.put(`/admin/orders/${orderId}/shipping`, {
        shippingCode: 'Diambil di toko',
        status: 'COMPLETED',
    }, {
        preserveScroll: true,
    });
};

const handleKurirStatusChange = (orderId, newStatus) => {
    if (newStatus === 'completed') {
        router.put(`/admin/orders/${orderId}/shipping`, {
            shippingCode: 'Kurir Toko',
            status: 'COMPLETED',
        }, { preserveScroll: true });
    } else if (newStatus === 'shipping') {
        router.put(`/admin/orders/${orderId}/shipping`, {
            shippingCode: 'Kurir Toko - Dalam Pengiriman',
            status: 'SHIPPING',
        }, { preserveScroll: true });
    }
};

const openShippingModal = (orderId) => {
    selectedOrderId.value = orderId;
    shippingCode.value = '';
    isShippingModalOpen.value = true;
};

const handleUpdateShipping = () => {
    router.put(`/admin/orders/${selectedOrderId.value}/shipping`, {
        shippingCode: shippingCode.value,
    }, {
        onSuccess: () => {
            isShippingModalOpen.value = false;
        },
        preserveScroll: true,
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
        case 'success': return 'success';
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

const toggleBlockCustomer = (customerUsername) => {
    router.put(`/admin/users/${customerUsername}/block`, {}, {
        preserveScroll: true,
    });
};
</script>

<template>
    <AppLayout>
        <section class="section active">
            <div class="container">
                <!-- Welcome Section -->
                <div class="hero" style="min-height:auto; padding: 40px 32px; margin-bottom: 40px; background: linear-gradient(135deg, var(--color-accent) 0%, #0f172a 100%);">
                    <div class="hero-content">
                        <h2 style="color:white; font-size:28px; margin-bottom:8px;">Halo Admin, {{ username }}!</h2>
                        <p style="color:#94a3b8; margin-bottom:0; font-size:15px;">Kelola pesanan customer dan verifikasi pembayaran masuk secara efisien.</p>
                    </div>
                </div>

                <!-- Stats Cards -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <span class="stat-title">Total Pesanan</span>
                        <span class="stat-value">{{ stats.totalOrders }}</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-title" style="color: var(--color-warning);">Menunggu Status Order</span>
                        <span class="stat-value" style="color: var(--color-warning);">{{ stats.pendingOrders }}</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-title">Total Pelanggan</span>
                        <span class="stat-value">{{ stats.totalCustomers }}</span>
                    </div>
                </div>

                <!-- Tabs Selection -->
                <div class="role-tabs" style="max-width: 400px; margin-bottom: 24px;">
                    <div 
                        class="role-tab" 
                        :class="{ active: activeTab === 'orders' }" 
                        @click="activeTab = 'orders'"
                    >
                        Update Status Order
                    </div>
                    <div 
                        class="role-tab" 
                        :class="{ active: activeTab === 'customers' }" 
                        @click="activeTab = 'customers'"
                    >
                        Daftar Customer
                    </div>
                </div>

                <!-- Tab 1: Orders -->
                <div v-if="activeTab === 'orders'" class="table-card">
                    <div class="table-header" style="flex-direction: column; gap: 16px;">
                        <h3 style="font-size:18px; align-self: flex-start; margin: 0;">Daftar Transaksi</h3>
                        
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
                                    <th>ID Order</th>
                                    <th>Tanggal</th>
                                    <th>Metode Pengiriman</th>
                                    <th>Status</th>
                                    <th>Kode Resi (Shipping)</th>
                                    <th class="text-center">Aksi Logistik</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="order in filteredOrders" :key="order.id">
                                    <td style="font-weight: 800; font-family: monospace;">{{ order.id }}</td>
                                    <td>{{ formatDate(order.createdAt) }}</td>
                                    <td style="font-weight: 600; color: #0f172a;">
                                        {{ order.shippingMethod || 'JNE' }}
                                    </td>
                                    <td>
                                        <span class="status-pill" :class="getStatusClass(order.status)">
                                            {{ getStatusLabel(order.status) }}
                                        </span>
                                    </td>
                                    
                                    <!-- Kode Resi: Show only for Jasa Kurir (JNE/JNT/etc) -->
                                    <td style="font-weight: 700; font-family: monospace; color: #0f172a;">
                                        <template v-if="getShippingType(order.shippingMethod) === 'kurir'">
                                            {{ order.shipping?.waybillId || '-' }}
                                        </template>
                                        <template v-else>
                                            <span style="color: #94a3b8;">-</span>
                                        </template>
                                    </td>

                                    <!-- Aksi Logistik -->
                                    <td class="text-center">
                                        <template v-if="order.status?.toUpperCase() !== 'PENDING' && order.status?.toUpperCase() !== 'CANCELLED'">
                                            <!-- Jasa Kurir (JNE, JNT, dll): No action, just show - -->
                                            <template v-if="getShippingType(order.shippingMethod) === 'kurir'">
                                                <span style="color: #94a3b8; font-size: 12px;">-</span>
                                            </template>

                                            <!-- Ambil Di Toko: Show Selesai button -->
                                            <template v-else-if="getShippingType(order.shippingMethod) === 'ambil'">
                                                <button 
                                                    v-if="order.status?.toUpperCase() === 'SUCCESS' || order.status?.toUpperCase() === 'VERIFIED'"
                                                    @click="handleMarkCompleted(order.id)"
                                                    style="padding: 6px 18px; font-size: 12px; font-weight: 700; color: white; background: #2563eb; border: none; border-radius: 6px; cursor: pointer;"
                                                >
                                                    Selesai
                                                </button>
                                                <span v-else style="color: #94a3b8; font-size: 12px;">-</span>
                                            </template>

                                            <!-- Kurir Sinar Abadi: Dropdown with Dalam Pengiriman / Selesai -->
                                            <template v-else-if="getShippingType(order.shippingMethod) === 'kurir_toko'">
                                                <div v-if="order.status?.toUpperCase() === 'SUCCESS' || order.status?.toUpperCase() === 'VERIFIED' || order.status?.toUpperCase() === 'SHIPPING'" style="position: relative; display: inline-block;">
                                                    <select 
                                                        @change="handleKurirStatusChange(order.id, $event.target.value); $event.target.value = '';"
                                                        style="padding: 6px 32px 6px 12px; font-size: 12px; font-weight: 600; border: 1px solid #cbd5e1; border-radius: 6px; background: white; color: #0f172a; cursor: pointer; appearance: none; outline: none;"
                                                    >
                                                        <option value="" disabled selected>
                                                            {{ order.status?.toUpperCase() === 'SHIPPING' ? 'Dalam Pengiriman ▾' : 'Proses Pesanan ▾' }}
                                                        </option>
                                                        <option v-if="order.status?.toUpperCase() !== 'SHIPPING'" value="shipping">Dalam Pengiriman</option>
                                                        <option value="completed">Selesai</option>
                                                    </select>
                                                </div>
                                                <span v-else style="color: #94a3b8; font-size: 12px;">-</span>
                                            </template>
                                        </template>
                                        <span v-else style="color: #94a3b8; font-size: 12px;">-</span>
                                    </td>
                                </tr>
                                <tr v-if="filteredOrders.length === 0">
                                    <td colspan="6" class="text-center text-muted" style="padding: 40px 0;">
                                        Belum ada order yang sesuai.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Tab 2: Customers -->
                <div v-else class="table-card">
                    <div class="table-header">
                        <h3 style="font-size:18px;">Manajemen Pelanggan</h3>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Nama Lengkap</th>
                                    <th>Username</th>
                                    <th>Status Akun</th>
                                    <th class="text-center">Aksi Moderasi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="cust in customers" :key="cust.username">
                                    <td style="font-weight: 700;">{{ cust.name }}</td>
                                    <td>{{ cust.username }}</td>
                                    <td>
                                        <span 
                                            class="status-pill" 
                                            :class="cust.blocked ? 'cancelled' : 'success'"
                                        >
                                            {{ cust.blocked ? 'Diblokir' : 'Aktif' }}
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        <button 
                                            @click="toggleBlockCustomer(cust.username)"
                                            class="btn"
                                            :class="cust.blocked ? 'btn-primary' : 'btn-outline'"
                                            style="padding: 6px 12px; font-size:12px;"
                                            :style="cust.blocked ? { background: 'var(--color-success)' } : { color: 'var(--color-danger)', borderColor: 'var(--color-danger)' }"
                                        >
                                            {{ cust.blocked ? 'Aktifkan Akun' : 'Blokir Customer' }}
                                        </button>
                                    </td>
                                </tr>
                                <tr v-if="customers.length === 0">
                                    <td colspan="4" class="text-center text-muted" style="padding: 40px 0;">
                                        Belum ada data customer terdaftar.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </section>

        <!-- Shipping Code Modal -->
        <div v-if="isShippingModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:400px; padding:32px; animation: slideUp 0.3s forwards;">
                <h3 class="mb-4">Input Kode Resi Pengiriman</h3>
                <form @submit.prevent="handleUpdateShipping">
                    <div class="form-group mb-6">
                        <label class="form-label">Nomor Resi / Bukti Jalan</label>
                        <input 
                            type="text" 
                            class="form-input" 
                            placeholder="Contoh: JT-12345678"
                            v-model="shippingCode" 
                            required
                        >
                    </div>
                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isShippingModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100">Kirim Barang</button>
                    </div>
                </form>
            </div>
        </div>
    </AppLayout>
</template>
