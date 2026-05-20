<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { router } from '@inertiajs/vue3';
import { ref } from 'vue';

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
        case 'cancelled': return 'cancelled';
        default: return 'pending';
    }
};

const getStatusLabel = (status) => {
    switch (status?.toLowerCase()) {
        case 'pending': return 'Verifikasi Pembayaran';
        case 'success': return 'success';
        case 'cancelled': return 'Dibatalkan';
        default: return status;
    }
};

const updateOrderStatus = (orderId, nextStatus) => {
    router.put(`/admin/orders/${orderId}/status`, { status: nextStatus }, {
        preserveScroll: true,
    });
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
                        <span class="stat-title" style="color: var(--color-warning);">Butuh Verifikasi</span>
                        <span class="stat-value" style="color: var(--color-warning);">{{ stats.pendingOrders }}</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-title" style="color: var(--color-success);">Pembayaran Valid</span>
                        <span class="stat-value" style="color: var(--color-success);">{{ stats.verifiedOrders }}</span>
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
                        Manajemen Order
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
                    <div class="table-header">
                        <h3 style="font-size:18px;">Daftar Transaksi</h3>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID Order</th>
                                    <th>Tanggal</th>
                                    <th>Pelanggan</th>
                                    <th>Total Tagihan</th>
                                    <th>Status</th>
                                    <th class="text-center">Bukti Pembayaran</th>
                                    <th class="text-center">Aksi Operasional</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="order in orders" :key="order.id">
                                    <td style="font-weight: 800; font-family: monospace;">{{ order.id }}</td>
                                    <td>{{ formatDate(order.createdAt) }}</td>
                                    <td>
                                        <div style="font-weight: 700;">{{ order.customer || '-' }}</div>
                                    </td>
                                    <td style="font-weight: 800; color: var(--color-primary);">
                                        {{ formatPrice(order.total) }}
                                    </td>
                                    <td>
                                        <span class="status-pill" :class="getStatusClass(order.status)">
                                            {{ getStatusLabel(order.status) }}
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        <a v-if="order.proofUploaded && order.proofUrl" :href="order.proofUrl" target="_blank" class="d-flex align-center justify-center gap-2" style="color: #0284c7; font-weight: 600; font-size: 13px; text-decoration: none; cursor: pointer;">
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                                <circle cx="12" cy="12" r="3"></circle>
                                            </svg>
                                            Lihat Bukti
                                        </a>
                                        <div v-else-if="order.proofUploaded" style="color: #94a3b8; font-style: italic; font-size: 13px;">
                                            (Legacy) Uploaded but no URL
                                        </div>
                                        <div v-else style="color: #94a3b8; font-style: italic; font-size: 13px;">
                                            No proof provided
                                        </div>
                                    </td>
                                    <td class="text-center">
                                        <!-- Actions based on state -->
                                        <div v-if="order.status?.toLowerCase() === 'pending'" class="d-flex align-center justify-center gap-2">
                                            <button 
                                                @click="updateOrderStatus(order.id, 'success')"
                                                class="btn btn-primary"
                                                style="padding: 4px 12px; font-size:12px; background:#0284c7; border-color:#0284c7; border-radius: 4px;"
                                            >
                                                Validasi
                                            </button>
                                            <button 
                                                @click="updateOrderStatus(order.id, 'cancelled')"
                                                class="btn btn-outline"
                                                style="padding: 4px 12px; font-size:12px; color: #dc2626; border-color: #dc2626; border-radius: 4px;"
                                            >
                                                Tolak
                                            </button>
                                        </div>
                                        <span v-else class="text-muted" style="font-size:13px; font-style: italic;">Selesai</span>
                                    </td>
                                </tr>
                                <tr v-if="orders.length === 0">
                                    <td colspan="6" class="text-center text-muted" style="padding: 40px 0;">
                                        Belum ada order masuk di sistem.
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
    </AppLayout>
</template>
