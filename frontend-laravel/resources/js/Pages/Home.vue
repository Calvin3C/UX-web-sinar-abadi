<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import ProductCard from '@/Components/ProductCard.vue';
import { usePage, Link } from '@inertiajs/vue3';
import { computed } from 'vue';

const props = defineProps({
    bestSellers: {
        type: Array,
        required: true,
    },
    categories: {
        type: Array,
        required: true,
    },
});

const page = usePage();
const auth = computed(() => page.props.auth);

const categoryImages = {
    'Semen': '/images/categories/semen.png',
    'Perpipaan': '/images/categories/perpipaan.png',
    'Cat Tembok': '/images/categories/cat_tembok.png',
    'Cat Kayu': '/images/categories/cat_kayu.png',
    'Besi Beton': '/images/categories/besi_beton.png',
    'Kloset': '/images/categories/kloset.png',
    'Perkakas': '/images/categories/perkakas.png',
    'Listrik': '/images/categories/listrik.png',
    'Kuas Cat': '/images/categories/kuas_cat.png',
    'Kunci Pintu': '/images/categories/kunci_pintu.png',
    'Engsel': '/images/categories/engsel.png',
    'Keramik & Granite': '/images/categories/keramik_granite.png',
};
</script>

<template>
    <AppLayout>
        <section class="section active" id="home">
            <div class="container">
                <!-- Hero Banner -->
                <div class="hero">
                    <div class="hero-decoration"></div>
                    <div class="hero-content">
                        <h1>Membangun Masa Depan Dengan Material Terbaik</h1>
                        <p>Sinar Abadi menyediakan kebutuhan konstruksi berskala industri maupun residensial. Jaminan keaslian merek dan pengiriman tepat waktu di seluruh Jawa Timur.</p>
                        <div class="d-flex gap-4">
                            <Link href="/katalog" class="btn btn-primary" style="font-size:16px; padding:16px 32px;">Jelajahi Katalog</Link>
                            <a href="#cat-section" class="btn btn-outline" style="border-color:rgba(255,255,255,0.3); color:white; font-size:16px; padding:16px 32px;">Kategori</a>
                        </div>
                    </div>
                </div>

                <!-- Kategori Material -->
                <div id="cat-section" style="padding-top:20px;">
                    <div class="text-center">
                        <h3 class="section-title">Kategori Material</h3>
                    </div>
                    <div class="category-grid">
                        <Link 
                            v-for="cat in categories" 
                            :key="cat" 
                            :href="`/katalog?category=${cat}`" 
                            class="category-card"
                        >
                            <div class="category-icon">
                                <img 
                                    :src="categoryImages[cat] || '/images/categories/default.png'" 
                                    :alt="cat"
                                    style="width: 64px; height: 64px; object-fit: contain;"
                                />
                            </div>
                            <span class="category-name">{{ cat }}</span>
                        </Link>
                    </div>
                </div>

                <!-- Produk Paling Laku -->
                <div class="mt-8">
                    <div class="d-flex align-center justify-between mb-8">
                        <h3 class="section-title" style="margin-bottom:0;">Produk Paling Laku</h3>
                        <Link href="/katalog" class="btn btn-ghost">Lihat Semua →</Link>
                    </div>
                    <div class="product-grid">
                        <ProductCard 
                            v-for="product in bestSellers" 
                            :key="product.id" 
                            :product="product" 
                            :authRole="auth.role" 
                        />
                    </div>
                </div>
            </div>
        </section>
    </AppLayout>
</template>
