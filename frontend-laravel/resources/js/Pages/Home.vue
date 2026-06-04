<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import ProductCard from '@/Components/ProductCard.vue';
import { usePage, Link } from '@inertiajs/vue3';
import { computed, ref, onMounted, onUnmounted } from 'vue';

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

// Hero Slider
const slides = [
    { image: '/images/banners/banner_semen.png', link: '/katalog?category=Semen' },
    { image: '/images/banners/banner_cat.png', link: '/katalog?category=Cat Tembok' },
];

const currentSlide = ref(0);
let autoplayInterval = null;

const nextSlide = () => {
    currentSlide.value = (currentSlide.value + 1) % slides.length;
};

const prevSlide = () => {
    currentSlide.value = (currentSlide.value - 1 + slides.length) % slides.length;
};

const goToSlide = (index) => {
    currentSlide.value = index;
};

const startAutoplay = () => {
    autoplayInterval = setInterval(nextSlide, 5000);
};

const stopAutoplay = () => {
    if (autoplayInterval) clearInterval(autoplayInterval);
};

onMounted(() => startAutoplay());
onUnmounted(() => stopAutoplay());
</script>

<template>
    <AppLayout>
        <section class="section active" id="home">
            <div class="container">
                <!-- Hero Banner Slider -->
                <div
                    class="hero-slider"
                    @mouseenter="stopAutoplay"
                    @mouseleave="startAutoplay"
                >
                    <div class="hero-slider-track" :style="{ transform: `translateX(-${currentSlide * 100}%)` }">
                        <Link
                            v-for="(slide, index) in slides"
                            :key="index"
                            :href="slide.link"
                            class="hero-slide"
                        >
                            <img :src="slide.image" :alt="'Banner ' + (index + 1)" />
                        </Link>
                    </div>

                    <!-- Navigation Arrows -->
                    <button class="slider-arrow slider-arrow-left" @click.prevent="prevSlide" aria-label="Previous">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
                    </button>
                    <button class="slider-arrow slider-arrow-right" @click.prevent="nextSlide" aria-label="Next">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                    </button>

                    <!-- Dots -->
                    <div class="slider-dots">
                        <button
                            v-for="(slide, index) in slides"
                            :key="index"
                            class="slider-dot"
                            :class="{ active: currentSlide === index }"
                            @click="goToSlide(index)"
                        ></button>
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

<style scoped>
.hero-slider {
    position: relative;
    width: 100%;
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
    margin-bottom: 8px;
}

.hero-slider-track {
    display: flex;
    transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.hero-slide {
    min-width: 100%;
    display: block;
    text-decoration: none;
    cursor: pointer;
}

.hero-slide img {
    width: 100%;
    height: 380px;
    object-fit: cover;
    display: block;
}

.slider-arrow {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: rgba(0, 0, 0, 0.45);
    backdrop-filter: blur(4px);
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.25s;
    z-index: 10;
}

.slider-arrow:hover {
    background: rgba(0, 0, 0, 0.7);
    transform: translateY(-50%) scale(1.1);
}

.slider-arrow-left {
    left: 16px;
}

.slider-arrow-right {
    right: 16px;
}

.slider-dots {
    position: absolute;
    bottom: 16px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    gap: 10px;
    z-index: 10;
}

.slider-dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.4);
    border: 2px solid rgba(255, 255, 255, 0.6);
    cursor: pointer;
    transition: all 0.3s;
    padding: 0;
}

.slider-dot.active {
    background: white;
    border-color: white;
    transform: scale(1.2);
}

@media (max-width: 768px) {
    .hero-slide img {
        height: 200px;
    }
    .slider-arrow {
        width: 36px;
        height: 36px;
    }
    .slider-arrow-left {
        left: 8px;
    }
    .slider-arrow-right {
        right: 8px;
    }
}
</style>
