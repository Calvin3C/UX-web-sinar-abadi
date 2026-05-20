<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import ProductCard from '@/Components/ProductCard.vue';
import { usePage, Link, router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';

const props = defineProps({
    paginatedProducts: {
        type: Array,
        required: true,
    },
    categories: {
        type: Array,
        required: true,
    },
    page: {
        type: Number,
        required: true,
    },
    totalPages: {
        type: Number,
        required: true,
    },
    total: {
        type: Number,
        required: true,
    },
    filters: {
        type: Object,
        default: () => ({ search: '', category: 'all', sort: 'rekomendasi' }),
    },
});

const pageData = usePage();
const auth = computed(() => pageData.props.auth);

const searchQuery = ref(props.filters.search || '');
const selectedCategory = ref(props.filters.category || 'all');
const selectedSort = ref(props.filters.sort || 'rekomendasi');

const applyFilters = (newPage = 1) => {
    router.get('/katalog', {
        search: searchQuery.value,
        category: selectedCategory.value,
        sort: selectedSort.value,
        page: newPage,
    }, {
        preserveState: true,
        replace: true,
    });
};

const handleSearch = (e) => {
    e.preventDefault();
    applyFilters(1);
};

const handleCategoryChange = () => {
    applyFilters(1);
};

const handleSortChange = () => {
    applyFilters(1);
};
</script>

<template>
    <AppLayout>
        <section class="section active">
            <div class="container">
                <h2 class="section-title">Katalog Lengkap</h2>

                <!-- Toolbar: Search + Filter + Sort -->
                <div class="toolbar">
                    <div class="search-box">
                        <svg viewBox="0 0 24 24" width="20" height="20" fill="#64748b">
                            <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                        </svg>
                        <form @submit="handleSearch">
                            <input 
                                type="text" 
                                placeholder="Cari nama produk, merek, atau tipe..."
                                v-model="searchQuery"
                            >
                        </form>
                    </div>
                    
                    <div class="d-flex gap-4 align-center">
                        <select 
                            class="form-input" 
                            style="width:auto; padding:10px 16px;"
                            v-model="selectedCategory"
                            @change="handleCategoryChange"
                        >
                            <option value="all">Semua Kategori</option>
                            <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
                        </select>
                        
                        <select 
                            class="form-input" 
                            style="width:auto; padding:10px 16px;"
                            v-model="selectedSort"
                            @change="handleSortChange"
                        >
                            <option value="rekomendasi">Terlaris</option>
                            <option value="termurah">Harga Termurah</option>
                            <option value="termahal">Harga Termahal</option>
                            <option value="az">A - Z</option>
                        </select>
                    </div>
                </div>

                <!-- Product Grid -->
                <div v-if="paginatedProducts.length > 0">
                    <div class="product-grid">
                        <ProductCard 
                            v-for="product in paginatedProducts" 
                            :key="product.id" 
                            :product="product" 
                            :authRole="auth.role" 
                        />
                    </div>
                </div>
                
                <!-- Not Found -->
                <div v-else class="text-center" style="padding: 60px 20px; color: #64748b;">
                    <svg viewBox="0 0 24 24" width="80" height="80" fill="#cbd5e1" style="margin: 0 auto;">
                        <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                    </svg>
                    <h3 style="margin-top: 16px;">Produk Tidak Ditemukan</h3>
                    <p>Coba ubah kata kunci pencarian atau filter kategori.</p>
                </div>

                <!-- Pagination -->
                <div v-if="totalPages > 1" class="pagination">
                    <Link 
                        v-for="i in totalPages" 
                        :key="i"
                        :href="`/katalog?search=${searchQuery}&category=${selectedCategory}&sort=${selectedSort}&page=${i}`"
                        class="page-btn"
                        :class="{ active: i === page }"
                    >
                        {{ i }}
                    </Link>
                </div>

                <p class="text-muted text-center mt-4" style="font-size:13px;">
                    Menampilkan {{ paginatedProducts.length }} dari {{ total }} produk
                </p>
            </div>
        </section>
    </AppLayout>
</template>
