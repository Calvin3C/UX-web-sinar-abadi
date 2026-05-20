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
                    <div class="tracking-timeline">
                        <div class="timeline-steps">
                            <!-- Progress Line -->
                            <div class="timeline-progress" :style="{ width: timelineProgressWidth() }"></div>
                            
                            <!-- Steps -->
                            <div 
                                v-for="(step, index) in steps" 
                                :key="step.title" 
                                class="timeline-step"
                                :class="{ completed: index < currentStep, active: index === currentStep }"
                            >
                                <div class="step-circle">
                                    <svg viewBox="0 0 24 24">
                                        <!-- Step 1: Created -->
                                        <path v-if="index === 0" d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/>
                                        <!-- Step 2: Payment Verified -->
                                        <path v-else-if="index === 1" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                                        <!-- Step 3: Shipping -->
                                        <path v-else-if="index === 2" d="M20 8h-3V4H3c-1.1 0-2 .9-2 2v11h2c0 1.66 1.34 3 3 3s3-1.34 3-3h6c0 1.66 1.34 3 3 3s3-1.34 3-3h2v-5l-3-4zM6 18.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm12 0c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm2-5.5h-3V9h3v4z"/>
                                        <!-- Step 4: Completed -->
                                        <path v-else d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 17h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 12.9 13 13.5 13 15h-2v-.5c0-1.1.45-2.1 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.1-.9-2-2-2s-2 .9-2 2H7c0-2.76 2.24-5 5-5s5 2.24 5 5c0 1.04-.42 1.99-1.07 2.75z"/>
                                    </svg>
                                </div>
                                <div class="step-label">{{ step.title }}</div>
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
                            </div>
                            <span class="tracking-item-price">{{ formatPrice(item.price * item.qty) }}</span>
                        </div>
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
