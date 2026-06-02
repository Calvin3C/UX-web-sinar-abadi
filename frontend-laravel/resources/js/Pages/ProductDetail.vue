<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    product: {
        type: Object,
        required: true,
    }
});

const page = usePage();
const auth = computed(() => page.props.auth);

const isSemen = props.product.category === 'Semen';
const minPurchase = isSemen ? 10 : 1;
const unit = isSemen ? 'Sak' : 'Pcs';

const quantity = ref(minPurchase);

const subtotal = computed(() => {
    return props.product.price * quantity.value;
});

const decreaseQty = () => {
    if (quantity.value > minPurchase) quantity.value--;
};

const increaseQty = () => {
    if (quantity.value < props.product.stock) quantity.value++;
};

const formatPrice = (price) => {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(price).replace('Rp', 'Rp ');
};

const handleAddToCart = () => {
    if (auth.value.role !== 'customer') {
        router.visit('/login');
        return;
    }
    
    router.post('/cart/add', {
        id: props.product.id,
        name: props.product.name,
        price: props.product.price,
        img: props.product.img || '',
        isLarge: props.product.isLarge || false,
        stock: props.product.stock,
        qty: quantity.value,
    }, {
        preserveScroll: true
    });
};

const sharePage = () => {
    if (navigator.share) {
        navigator.share({
            title: props.product.name,
            url: window.location.href
        }).catch(console.error);
    } else {
        navigator.clipboard.writeText(window.location.href);
        alert('Tautan disalin ke clipboard!');
    }
};

const activeTab = ref('spesifikasi');

const getMerek = () => {
    return props.product.name.split(' ')[0];
};

const getWeight = () => {
    return props.product.isLarge ? '15.000 Gram / 15 Kg' : '2.000 Gram / 2 Kg';
};

const getWaLink = () => {
    const text = `Halo CS Sinar Abadi, saya mau bertanya tentang produk ${props.product.name}`;
    return `https://wa.me/6281234567890?text=${encodeURIComponent(text)}`;
};
</script>

<template>
    <Head :title="product.name" />
    <AppLayout>
        <div class="container" style="padding-top: 40px; padding-bottom: 80px;">
            <div class="breadcrumb">
                <Link href="/">Beranda</Link> &gt; 
                <Link href="/katalog">Katalog</Link> &gt; 
                <Link :href="`/katalog?category=${product.category}`">{{ product.category }}</Link> &gt; 
                <span>{{ product.name }}</span>
            </div>

            <div class="detail-grid">
                <!-- Kiri: Gambar -->
                <div class="detail-left card">
                    <img :src="product.img || 'https://placehold.co/400x300/e2e8f0/64748b?text=No+Image'" :alt="product.name" class="main-image">
                    
                    <button class="btn btn-outline w-100 mt-4" style="border-color: #cbd5e1; color: #0f172a;" @click="sharePage">
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor" style="vertical-align: middle; margin-right: 8px;">
                            <path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92s2.92-1.31 2.92-2.92-1.31-2.92-2.92-2.92z"/>
                        </svg>
                        Bagikan Halaman
                    </button>
                </div>

                <!-- Tengah: Info -->
                <div class="detail-mid card">
                    <h1 class="product-title">{{ product.name }}</h1>
                    <div class="product-price">{{ formatPrice(product.price) }}</div>
                    
                    <div class="badges">
                        <span class="badge" v-if="product.stock <= 10">Stok Terbatas</span>
                        <span class="badge-outline">
                            <svg viewBox="0 0 24 24" width="14" height="14" fill="#10b981" style="vertical-align: middle;"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                            Termasuk PPN
                        </span>
                    </div>

                    <div class="tabs">
                        <div class="tab" :class="{ active: activeTab === 'spesifikasi' }" @click="activeTab = 'spesifikasi'">Spesifikasi Produk</div>
                        <div class="tab" :class="{ active: activeTab === 'deskripsi' }" @click="activeTab = 'deskripsi'">Deskripsi Produk</div>
                    </div>

                    <div class="tab-content" v-if="activeTab === 'spesifikasi'">
                        <div class="spec-row">
                            <div class="spec-label">Satuan</div>
                            <div class="spec-value">{{ unit }}</div>
                        </div>
                        <div class="spec-row">
                            <div class="spec-label">Pembelian minimal</div>
                            <div class="spec-value">{{ minPurchase }} {{ unit }}</div>
                        </div>
                        <div class="spec-row">
                            <div class="spec-label">Berat</div>
                            <div class="spec-value">{{ getWeight() }}</div>
                        </div>
                        <div class="spec-row">
                            <div class="spec-label">Merek</div>
                            <div class="spec-value" style="color: var(--color-primary); font-weight: 600;">{{ getMerek() }}</div>
                        </div>
                        <div class="spec-row">
                            <div class="spec-label">Sub kategori</div>
                            <div class="spec-value" style="color: var(--color-primary); font-weight: 600;">{{ product.category }}</div>
                        </div>
                    </div>

                    <div class="tab-content" v-if="activeTab === 'deskripsi'">
                        <p>Produk material bangunan Sinar Abadi. Jaminan kualitas terbaik dan orisinal untuk kebutuhan konstruksi Anda.</p>
                        <p v-if="isSemen">Perhatian: Pembelian minimal untuk produk Semen adalah {{ minPurchase }} sak.</p>
                    </div>
                </div>

                <!-- Kanan: Keranjang -->
                <div class="detail-right">
                    <div class="promo-box mb-4">
                        <div style="font-weight: 600; color: #0f172a;">Potensi Harga Terbaik</div>
                        <div style="font-size: 13px; color: #475569;">Beli lebih banyak, hemat ongkir!</div>
                    </div>

                    <div class="card">
                        <h3 style="font-size: 18px; margin-bottom: 8px;">Subtotal</h3>
                        <div class="subtotal-price">{{ formatPrice(subtotal) }}</div>

                        <div style="margin-top: 20px; margin-bottom: 8px; font-weight: 500; font-size: 14px; color: #334155;">Atur Jumlah Pembelian</div>
                        
                        <div class="qty-control">
                            <button class="qty-btn" @click="decreaseQty" :disabled="quantity <= minPurchase">-</button>
                            <input type="number" class="qty-input" v-model.number="quantity" :min="minPurchase" :max="product.stock" readonly>
                            <span style="padding-right: 8px; color: #475569; font-weight: 500;">x {{ unit }}</span>
                            <button class="qty-btn" @click="increaseQty" :disabled="quantity >= product.stock">+</button>
                        </div>
                        
                        <div v-if="product.stock <= 0" class="text-danger mt-2" style="font-size: 14px; font-weight: 600;">
                            Stok Habis
                        </div>
                        <div v-else-if="product.stock < quantity" class="text-danger mt-2" style="font-size: 14px;">
                            Sisa stok: {{ product.stock }}
                        </div>

                        <button 
                            class="btn btn-outline w-100 mt-4 mb-4" 
                            style="border-color: #cbd5e1; color: #0f172a; padding: 12px;" 
                            @click="handleAddToCart"
                            :disabled="product.stock < minPurchase"
                        >
                            <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor" style="vertical-align: middle; margin-right: 8px;">
                                <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/>
                            </svg>
                            Masukkan Keranjang
                        </button>

                        <div class="delivery-estimate">
                            <strong>Estimasi Pengiriman</strong><br>
                            Malang: <span style="font-weight: 600;">2-7 hari kerja</span>
                        </div>

                        <a :href="getWaLink()" target="_blank" class="btn w-100 mt-4" style="background: #f1f5f9; color: #334155; border: 1px solid #e2e8f0; font-size: 14px; display: block; text-align: center; text-decoration: none;">
                            <svg viewBox="0 0 24 24" width="16" height="16" fill="#25D366" style="vertical-align: middle; margin-right: 6px;">
                                <path d="M12.01 2.01A10 10 0 0 0 2 12c0 1.93.55 3.73 1.52 5.25L2 22l4.88-1.52A9.95 9.95 0 0 0 12.01 22c5.52 0 10-4.48 10-10s-4.48-10-10-10zm0 18.33c-1.63 0-3.18-.42-4.52-1.22l-.32-.19-3.36 1.05.89-3.27-.21-.34A8.29 8.29 0 0 1 3.68 12c0-4.6 3.74-8.34 8.33-8.34s8.33 3.74 8.33 8.34-3.74 8.34-8.33 8.34zm4.57-6.23c-.25-.13-1.49-.74-1.72-.82-.23-.09-.4-.13-.57.13-.17.25-.65.82-.79.99-.15.17-.29.19-.54.06-1.07-.54-2.02-1.39-2.73-2.39-.2-.29.04-.37.26-.78.07-.13.11-.22.17-.35.13-.25.06-.48-.06-.74-.13-.25-.57-1.38-.78-1.89-.21-.5-.41-.43-.57-.44h-.49c-.21 0-.54.08-.82.39s-1.09 1.07-1.09 2.6c0 1.54 1.12 3.02 1.27 3.23.15.21 2.2 3.36 5.33 4.71 1.9.82 2.65.88 3.55.74.96-.15 2.12-.87 2.42-1.71.3-.84.3-1.56.21-1.71-.09-.15-.32-.23-.57-.36z"/>
                            </svg>
                            Hubungi Sinar Abadi
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </AppLayout>
</template>

<style scoped>
.breadcrumb {
    font-size: 14px;
    color: #64748b;
    margin-bottom: 24px;
}
.breadcrumb a {
    color: var(--color-primary);
    text-decoration: none;
}
.breadcrumb a:hover {
    text-decoration: underline;
}

.detail-grid {
    display: grid;
    grid-template-columns: 300px 1fr 320px;
    gap: 24px;
    align-items: start;
}

@media (max-width: 992px) {
    .detail-grid {
        grid-template-columns: 1fr;
    }
}

.card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    border: 1px solid #e2e8f0;
}

.main-image {
    width: 100%;
    height: auto;
    object-fit: contain;
    border-radius: 8px;
}

.product-title {
    font-size: 24px;
    font-weight: 700;
    color: #0f172a;
    margin-bottom: 8px;
    line-height: 1.3;
}

.product-price {
    font-size: 32px;
    font-weight: 800;
    color: var(--color-primary);
    margin-bottom: 16px;
}

.badges {
    display: flex;
    gap: 8px;
    margin-bottom: 32px;
}

.badge {
    background: #fef3c7;
    color: #d97706;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 600;
}

.badge-outline {
    border: 1px solid #10b981;
    color: #10b981;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 600;
}

.tabs {
    display: flex;
    border-bottom: 2px solid #e2e8f0;
    margin-bottom: 20px;
}

.tab {
    padding: 12px 24px;
    font-weight: 600;
    color: #64748b;
    cursor: pointer;
    border-bottom: 2px solid transparent;
    margin-bottom: -2px;
    transition: all 0.2s;
}

.tab:hover {
    color: #0f172a;
}

.tab.active {
    color: var(--color-primary);
    border-bottom-color: var(--color-primary);
}

.tab-content {
    font-size: 14px;
    line-height: 1.6;
    color: #334155;
}

.spec-row {
    display: flex;
    padding: 12px 0;
    border-bottom: 1px dashed #e2e8f0;
}

.spec-label {
    width: 200px;
    color: #64748b;
    font-weight: 500;
}

.spec-value {
    flex: 1;
    color: #0f172a;
}

.promo-box {
    background: #e0f2fe;
    border: 1px solid #bae6fd;
    border-radius: 8px;
    padding: 16px;
}

.subtotal-price {
    font-size: 24px;
    font-weight: 800;
    color: var(--color-primary);
}

.qty-control {
    display: flex;
    align-items: center;
    border: 1px solid #cbd5e1;
    border-radius: 6px;
    padding: 4px;
    background: #fff;
}

.qty-btn {
    width: 36px;
    height: 36px;
    background: transparent;
    border: none;
    font-size: 20px;
    color: #475569;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
}

.qty-btn:disabled {
    opacity: 0.3;
    cursor: not-allowed;
}

.qty-input {
    flex: 1;
    text-align: center;
    border: none;
    font-weight: 600;
    color: #0f172a;
    width: 60px;
}

.qty-input:focus {
    outline: none;
}

.delivery-estimate {
    font-size: 13px;
    color: #475569;
    padding-top: 16px;
    border-top: 1px dashed #e2e8f0;
    line-height: 1.5;
}
</style>
