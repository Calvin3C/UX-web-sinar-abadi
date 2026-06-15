<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { router, useForm } from '@inertiajs/vue3';
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
    profile: {
        type: Object,
        default: () => ({}),
    },
});

const activeTab = ref('dashboard'); // 'dashboard', 'orders', 'customers', or 'profile'

const isShippingModalOpen = ref(false);
const selectedOrderId = ref('');
const shippingCode = ref('');

const profileForm = useForm({
    name: props.profile?.name || '',
    username: props.profile?.username || '',
    email: props.profile?.email || '',
    phone: props.profile?.phone || '',
    password: '',
});

const saveProfile = () => {
    profileForm.put('/admin/profile', {
        preserveScroll: true,
        onSuccess: () => {
            profileForm.password = '';
        }
    });
};

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

const handleMarkShipping = (orderId) => {
    router.put(`/admin/orders/${orderId}/shipping`, {
        status: 'SHIPPING',
    }, { preserveScroll: true });
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
</script>

<template>
    <AppLayout>
        <section class="section active" style="padding-top: 40px; background: #f8fafc; min-height: 100vh;">
            <div class="container">
                <div style="display: grid; grid-template-columns: 280px 1fr; gap: 32px; align-items: start;">
                    
                    <!-- Sidebar -->
                    <div style="background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 24px;">
                        <!-- Profile -->
                        <!-- Profile -->
                        <div 
                            class="d-flex align-center gap-4 mb-4" 
                            @click="activeTab = 'profile'" 
                            style="cursor: pointer; padding: 12px; border-radius: 8px; transition: background 0.2s; margin: -12px -12px 16px -12px;"
                            :style="activeTab === 'profile' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent; hover: background: #f8fafc;'"
                        >
                            <div style="width: 48px; height: 48px; background: #e11d48; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 800; box-shadow: 0 4px 10px rgba(225, 29, 72, 0.4);">
                                {{ username ? username.charAt(0).toUpperCase() : 'A' }}
                            </div>
                            <div>
                                <h3 style="font-size: 16px; font-weight: 800; margin: 0; color: #0f172a;">{{ username }}</h3>
                                <div style="font-size: 13px; color: #64748b;">Administrator</div>
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
                                <span :style="activeTab === 'dashboard' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Dashboard Admin</span>
                                <div v-if="activeTab === 'dashboard'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>

                            <div 
                                @click="activeTab = 'orders'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'orders' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'orders' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Update Status Order</span>
                                <div v-if="activeTab === 'orders'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                            
                            <div 
                                @click="activeTab = 'customers'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'customers' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'customers' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Daftar Customer</span>
                                <div v-if="activeTab === 'customers'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
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
                        <!-- Tab 0: Dashboard (Stats Only) -->
                        <div v-if="activeTab === 'dashboard'" class="stats-grid mb-6">
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
                                    <th>Alamat Pengiriman</th>
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
                                    <td style="max-width: 250px; white-space: normal; font-size: 13px;">
                                        {{ order.shipping?.destinationAddress || '-' }}
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
                                            <!-- Jasa Kurir (JNE, JNT, dll): Admin can mark as shipped -->
                                            <template v-if="getShippingType(order.shippingMethod) === 'kurir'">
                                                <button 
                                                    v-if="order.status?.toUpperCase() === 'SUCCESS' || order.status?.toUpperCase() === 'VERIFIED'"
                                                    @click="handleMarkShipping(order.id)"
                                                    style="padding: 6px 18px; font-size: 12px; font-weight: 700; color: white; background: #e11d48; border: none; border-radius: 6px; cursor: pointer;"
                                                >
                                                    Cetak Resi
                                                </button>
                                                <span v-else style="color: #94a3b8; font-size: 12px;">-</span>
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
                                    <th>Email</th>
                                    <th>No Telepon</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="cust in customers" :key="cust.username">
                                    <td style="font-weight: 700;">{{ cust.name }}</td>
                                    <td>{{ cust.username }}</td>
                                    <td>{{ cust.email || '-' }}</td>
                                    <td>{{ cust.phone || '-' }}</td>
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
                </template>
                </div> <!-- End Main Content -->
            </div> <!-- End Grid Layout -->
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
