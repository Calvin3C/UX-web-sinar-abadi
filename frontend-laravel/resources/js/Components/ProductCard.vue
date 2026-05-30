<script setup>
import { Link, router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';

const props = defineProps({
    product: {
        type: Object,
        required: true,
    },
    authRole: {
        type: String,
        default: null,
    },
});

const quantity = ref(1);

const decreaseQty = () => {
    if (quantity.value > 1) quantity.value--;
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
    router.post('/cart/add', {
        id: props.product.id,
        name: props.product.name,
        price: props.product.price,
        img: props.product.img || '',
        isLarge: props.product.isLarge || false,
        stock: props.product.stock,
        qty: quantity.value,
    }, {
        preserveScroll: true,
        onSuccess: () => {
            quantity.value = 1;
        }
    });
};
</script>

<template>
    <div class="product-card">
        <div class="product-image-wrap">
            <span v-if="product.stock <= 0" class="product-badge">Habis</span>
            <span v-if="product.isLarge" class="size-badge">Barang Besar</span>
            <img 
                :src="product.img || 'https://placehold.co/400x300/e2e8f0/64748b?text=No+Image'" 
                :alt="product.name" 
                class="product-image" 
                loading="lazy"
            >
        </div>
        <div class="product-content">
            <span class="product-cat-label">{{ product.category }}</span>
            <h4 class="product-title">{{ product.name }}</h4>
            <div class="product-stats">
                <span>{{ product.sold || 0 }} terjual</span>
                <span>•</span>
                <span>Stok: {{ product.stock || 0 }}</span>
            </div>
            <div class="product-price">{{ formatPrice(product.price) }}</div>

            <template v-if="product.stock > 0">
                <div v-if="authRole === 'customer'" class="quantity-selector">
                    <button class="qty-btn" @click="decreaseQty" :disabled="quantity <= 1">-</button>
                    <input type="number" class="qty-input" v-model.number="quantity" min="1" :max="product.stock" readonly>
                    <button class="qty-btn" @click="increaseQty" :disabled="quantity >= product.stock">+</button>
                </div>

                <button 
                    v-if="authRole === 'customer'" 
                    class="btn btn-primary w-100 btn-add-cart" 
                    @click="handleAddToCart"
                >
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="white">
                        <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/>
                    </svg>
                    Tambah ke Keranjang
                </button>
                <Link 
                    v-else 
                    href="/login" 
                    class="btn btn-outline w-100" 
                    style="border-color: var(--color-primary); color: var(--color-primary);"
                >
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
                        <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/>
                    </svg>
                    Login untuk Beli
                </Link>
            </template>
            <button 
                v-else 
                class="btn w-100" 
                disabled 
                style="background: #e2e8f0; color: #94a3b8; cursor: not-allowed;"
            >
                Stok Habis
            </button>
        </div>
    </div>
</template>

<style scoped>
.quantity-selector {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: #f1f5f9;
    border-radius: 8px;
    padding: 4px;
    margin-bottom: 12px;
}
.qty-btn {
    background: transparent;
    border: none;
    color: #475569;
    font-size: 1.2rem;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    border-radius: 4px;
    transition: all 0.2s;
}
.qty-btn:hover:not(:disabled) {
    background: #e2e8f0;
    color: #0f172a;
}
.qty-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
.qty-input {
    width: 40px;
    text-align: center;
    border: none;
    background: transparent;
    font-weight: 600;
    color: #0f172a;
    -moz-appearance: textfield;
}
.qty-input:focus {
    outline: none;
}
.qty-input::-webkit-outer-spin-button,
.qty-input::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
}
</style>
