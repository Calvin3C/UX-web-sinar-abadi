<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { router } from '@inertiajs/vue3';
import { ref } from 'vue';

const props = defineProps({
    order: {
        type: Object,
        default: null,
    },
    queryId: {
        type: String,
        default: '',
    },
    steps: {
        type: Array,
        default: () => [],
    },
    currentStep: {
        type: Number,
        default: -1,
    },
});

const searchId = ref(props.queryId || '');

const handleSearch = (e) => {
    e.preventDefault();
    if (!searchId.value.trim()) return;
    router.get('/customer/tracking', { orderId: searchId.value }, {
        preserveState: true,
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
            year: 'numeric',
            month: 'long',
            day: 'numeric',
        });
    } catch (e) {
        return dateStr;
    }
};

const timelineProgressWidth = () => {
    if (props.currentStep <= 0) return '0%';
    const percentage = (props.currentStep / (props.steps.length - 1)) * 100;
    return `${percentage}%`;
};

const handleCompleteOrder = (orderId) => {
    if (confirm('Apakah Anda yakin pesanan sudah diterima dengan baik? Status pesanan akan diubah menjadi Selesai.')) {
        router.put(`/customer/orders/${orderId}/complete`, {}, {
            preserveScroll: true,
            onSuccess: () => {
                // Return to dashboard after completing
                router.get('/customer/dashboard');
            }
        });
    }
};
</script>

<template>
    <AppLayout>
        <section class="section active">
            <div class="container">
                <h2 class="section-title text-center">Pelacakan Pesanan</h2>

                <!-- Search Tracking ID -->
                <div class="tracking-search-wrap">
                    <form @submit="handleSearch" class="tracking-search-box">
                        <input 
                            type="text" 
                            placeholder="Masukkan kode unik ID Pesanan (contoh: ORD-...)" 
                            v-model="searchId"
                            required
                        >
                        <button type="submit" class="btn btn-primary">Cari Resi</button>
                    </form>
                </div>

                <!-- If Order Found -->
                <div v-if="order" class="tracking-card" id="tracking-result">
                    <div class="tracking-card-header">
                        <h3>Status Pelacakan Real-time</h3>
                        <div class="tracking-order-id">{{ order.id }}</div>
                        <div class="tracking-meta">
                            <div style="font-size: 13px; color: #94a3b8; display:flex; gap:16px;">
                                <div>Kurir: <strong style="color:white;">{{ order.shippingMethod || '-' }}</strong></div>
                                <div>&bull;</div>
                                <div>Tanggal Transaksi: <strong style="color:white;">{{ formatDate(order.createdAt) }}</strong></div>
                                <div>&bull;</div>
                                <div>Tujuan: <strong style="color:white;">{{ order.address || '-' }}</strong></div>
                            </div>
                        </div>
                    </div>

                    <!-- Timeline -->
                    <div class="tracking-timeline" style="overflow-x: auto; padding-bottom: 10px;">
                        <div class="timeline-steps" :style="{ minWidth: steps.length > 4 ? '600px' : 'auto' }">
                            <!-- Progress Line -->
                            <div class="timeline-progress" :style="{ width: timelineProgressWidth() }"></div>
                            
                            <!-- Steps -->
                            <div 
                                v-for="(step, index) in steps" 
                                :key="index + '-' + step.title" 
                                class="timeline-step"
                                :class="{ 
                                    completed: index < currentStep || (index === currentStep && step.status === 'delivered'), 
                                    active: index === currentStep && step.status !== 'delivered' 
                                }"
                            >
                                <div class="step-circle">
                                    <svg viewBox="0 0 24 24">
                                        <!-- Step 1: Created -->
                                        <path v-if="index === 0" d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/>
                                        <!-- Step Last: Completed (Home Check) -->
                                        <path v-else-if="index === steps.length - 1 && index > 1" d="M12 3L2 12h3v8h14v-8h3L12 3zm-2 14l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/>
                                        <!-- Step Default (Checkmark) -->
                                        <path v-else d="M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z"/>
                                    </svg>
                                </div>
                                <div class="step-label" style="font-size:12px; line-height:1.2;">{{ step.title }}</div>
                                <div style="font-size:10px; color: var(--color-text-muted); margin-top:4px;">
                                    {{ step.time }}
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Items & Details -->
                    <div class="tracking-details">
                        <h4 style="font-size: 14px; text-transform: uppercase; color: var(--color-text-muted); margin-bottom: 16px;">Ringkasan Item Pesanan</h4>
                        <div 
                            v-for="item in order.items" 
                            :key="item.productId" 
                            class="tracking-item-row"
                        >
                            <div>
                                <span class="tracking-item-name">{{ item.name }}</span>
                                <span class="tracking-item-qty" style="margin-left: 8px;">({{ item.qty }} pcs)</span>
                                <div v-if="item.color" style="font-size: 12px; color: #64748b; margin-top: 2px;">Warna: <span style="font-weight: 500;">{{ item.color }}</span></div>
                            </div>
                            <span class="tracking-item-price">{{ formatPrice(item.price * item.qty) }}</span>
                        </div>
                    </div>

                    <!-- Pesanan Diterima Action -->
                    <div 
                        v-if="order.status?.toUpperCase() !== 'COMPLETED' && steps[currentStep]?.status === 'delivered'"
                        class="d-flex flex-column align-end mt-6 pt-4"
                        style="border-top: 1px dashed #cbd5e1;"
                    >
                        <div style="font-size: 13px; color: #64748b; margin-bottom: 12px; text-align: right;">
                            Tracking menunjukkan barang sudah terkirim.<br>Silakan konfirmasi jika Anda sudah menerima barang dengan baik.
                        </div>
                        <button 
                            @click="handleCompleteOrder(order.id)"
                            style="padding: 12px 32px; font-size: 15px; font-weight: 700; color: white; background: #16a34a; border: none; border-radius: 8px; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 6px -1px rgba(22, 163, 74, 0.4);"
                        >
                            Pesanan Diterima
                        </button>
                    </div>
                </div>

                <!-- If Query Exists But Order Null -->
                <div v-else-if="queryId" class="text-center" style="padding: 40px 20px; color: #64748b;">
                    <svg viewBox="0 0 24 24" width="80" height="80" fill="#fee2e2" style="margin: 0 auto 16px;">
                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
                    </svg>
                    <h3>Pesanan Tidak Ditemukan</h3>
                    <p>ID Pesanan <strong>"{{ queryId }}"</strong> tidak terdaftar di sistem. Coba periksa kembali ejaan ID Anda.</p>
                </div>
            </div>
        </section>
    </AppLayout>
</template>
