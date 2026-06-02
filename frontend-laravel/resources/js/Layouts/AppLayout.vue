<script setup>
import { Link, usePage, router } from '@inertiajs/vue3';
import { computed, watch, ref } from 'vue';

const page = usePage();
const auth = computed(() => page.props.auth);
const cartCount = computed(() => page.props.cartCount);
const flash = computed(() => page.props.flash);
const currentRouteName = computed(() => page.props.currentRouteName);

const logoHref = computed(() => {
    if (auth.value.role === 'admin') return '/admin/dashboard';
    if (auth.value.role === 'owner') return '/owner/dashboard';
    return '/';
});

// Toast Notifications System
const toasts = ref([]);

const showToast = (type, title, message) => {
    const id = Date.now() + Math.random();
    toasts.value.push({ id, type, title, message, fading: false });
    
    setTimeout(() => {
        const toast = toasts.value.find(t => t.id === id);
        if (toast) toast.fading = true;
        
        setTimeout(() => {
            removeToast(id);
        }, 500);
    }, 4000);
};

const removeToast = (id) => {
    toasts.value = toasts.value.filter(t => t.id !== id);
};

// Watch for flash notifications from Laravel
watch(() => flash.value.success, (msg) => {
    if (msg) showToast('success', 'Berhasil', msg);
}, { immediate: true });

watch(() => flash.value.error, (msg) => {
    if (msg) showToast('warning', 'Gagal', msg);
}, { immediate: true });

const handleLogout = () => {
    router.post('/logout');
};
</script>

<template>
    <div>
        <!-- Toast Container -->
        <div class="toast-container" id="toast-container">
            <div 
                v-for="toast in toasts" 
                :key="toast.id" 
                class="toast" 
                :class="[toast.type, { fading: toast.fading }]"
                :style="toast.fading ? { animation: 'fadeOut 0.5s forwards' } : {}"
            >
                <svg class="toast-icon" viewBox="0 0 24 24">
                    <path v-if="toast.type === 'success'" d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
                    <path v-else d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/>
                </svg>
                <div>
                    <div class="toast-title">{{ toast.title }}</div>
                    <div class="toast-msg">{{ toast.message }}</div>
                </div>
            </div>
        </div>

        <!-- Header -->
        <header class="header">
            <div class="container header-inner">
                <Link :href="logoHref" class="logo">
                    <svg viewBox="0 0 100 100" width="36" height="36">
                        <polygon points="50,2 61,38 98,38 68,60 79,96 50,74 21,96 32,60 2,38 39,38" fill="none" stroke="currentColor" stroke-width="5" stroke-linejoin="round"/>
                        <text x="50" y="60" text-anchor="middle" font-size="24" font-weight="800" fill="currentColor" font-family="'Plus Jakarta Sans', sans-serif">SA</text>
                    </svg>
                    SINAR<span>ABADI</span>
                </Link>

                <nav class="nav-menu" id="main-nav">
                    <!-- Guest & Customer Navigation -->
                    <template v-if="auth.role !== 'admin' && auth.role !== 'owner'">
                        <Link href="/" class="nav-link" :class="{ active: currentRouteName === 'home' }">Beranda</Link>
                        <Link href="/katalog" class="nav-link" :class="{ active: currentRouteName === 'katalog' }">Semua Katalog</Link>
                    </template>

                    <!-- Authenticated Menu -->
                    <template v-if="!auth.token">
                        <Link href="/login" class="nav-link" :class="{ active: currentRouteName === 'login' }">Masuk / Daftar</Link>
                    </template>
                    <template v-else>
                        <!-- Customer -->
                        <template v-if="auth.role === 'customer'">
                            <Link href="/customer/dashboard" class="nav-link" :class="{ active: currentRouteName && currentRouteName.startsWith('customer.') }">Dashboard Saya</Link>
                            <Link href="/cart" class="cart-trigger">
                                <svg viewBox="0 0 24 24" width="20" height="20">
                                    <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z" fill="currentColor"/>
                                </svg>
                                Keranjang
                                <span class="cart-badge" id="cart-counter" v-if="cartCount > 0">{{ cartCount }}</span>
                            </Link>
                        </template>

                        <!-- Admin -->
                        <template v-else-if="auth.role === 'admin'">
                            <Link href="/admin/dashboard" class="nav-link" :class="{ active: currentRouteName && currentRouteName.startsWith('admin.') }">Panel Admin</Link>
                        </template>

                        <!-- Owner -->
                        <template v-else-if="auth.role === 'owner'">
                            <Link href="/owner/dashboard" class="nav-link" :class="{ active: currentRouteName && currentRouteName.startsWith('owner.') }">Laporan Owner</Link>
                        </template>

                        <!-- Logout Button -->
                        <button @click="handleLogout" class="btn btn-outline" style="padding: 8px 16px; margin-left: 8px;">
                            Keluar ({{ auth.username }})
                        </button>
                    </template>
                </nav>
            </div>
        </header>

        <!-- Main Content -->
        <main>
            <slot />
        </main>

        <!-- Footer -->
        <footer class="footer">
            <div class="container">
                <div class="footer-grid">
                    <div class="footer-brand">
                        <div class="logo">
                            <svg viewBox="0 0 100 100" width="36" height="36">
                                <polygon points="50,2 61,38 98,38 68,60 79,96 50,74 21,96 32,60 2,38 39,38" fill="none" stroke="#dc2626" stroke-width="5" stroke-linejoin="round"/>
                                <text x="50" y="60" text-anchor="middle" font-size="24" font-weight="800" fill="#dc2626" font-family="'Plus Jakarta Sans', sans-serif">SA</text>
                            </svg>
                            SINAR<span>ABADI</span>
                        </div>
                        <p>Toko material bangunan terlengkap di Dampit, Malang. Melayani penjualan material berkualitas tinggi untuk kebutuhan konstruksi Anda.</p>
                    </div>

                    <div v-if="auth.role !== 'admin' && auth.role !== 'owner'">
                        <h4>Navigasi</h4>
                        <ul class="footer-links">
                            <li><Link href="/">Beranda</Link></li>
                            <li><Link href="/katalog">Katalog Produk</Link></li>
                            <li><Link href="/login">Masuk / Daftar</Link></li>
                        </ul>
                    </div>
                    <div v-else>
                        <h4>Panel</h4>
                        <ul class="footer-links">
                            <li v-if="auth.role === 'admin'"><Link href="/admin/dashboard">Dashboard Admin</Link></li>
                            <li v-if="auth.role === 'owner'"><Link href="/owner/dashboard">Dashboard Owner</Link></li>
                        </ul>
                    </div>

                    <div v-if="auth.role !== 'admin' && auth.role !== 'owner'">
                        <h4>Kategori</h4>
                        <ul class="footer-links">
                            <li><Link href="/katalog?category=Semen">Semen</Link></li>
                            <li><Link href="/katalog?category=Perpipaan">Perpipaan</Link></li>
                            <li><Link href="/katalog?category=Cat Tembok">Cat Tembok</Link></li>
                            <li><Link href="/katalog?category=Perkakas">Perkakas</Link></li>
                        </ul>
                    </div>
                    <div v-else>
                        <!-- Spacer for admins/owner -->
                        <div></div>
                    </div>

                    <div>
                        <h4>Hubungi Kami</h4>
                        <div class="contact-item">
                            <svg viewBox="0 0 24 24" width="20" height="20" fill="#dc2626">
                                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                            </svg>
                            <span>Jl. Raya Dampit, Kab. Malang, Jawa Timur</span>
                        </div>
                        <div class="contact-item">
                            <svg viewBox="0 0 24 24" width="20" height="20" fill="#dc2626">
                                <path d="M20.01 15.38c-1.23 0-2.42-.2-3.53-.56-.35-.12-.74-.03-1.01.24l-1.57 1.97c-2.83-1.35-5.48-3.9-6.89-6.83l1.95-1.66c.27-.28.35-.67.24-1.02-.37-1.11-.56-2.3-.56-3.53 0-.54-.45-.99-.99-.99H4.19C3.65 3 3 3.24 3 3.99 3 13.28 10.73 21 20.01 21c.71 0 .99-.63.99-1.18v-3.45c0-.54-.45-.99-.99-.99z"/>
                            </svg>
                            <span>+62 812-3456-7890</span>
                        </div>
                    </div>
                </div>
                <div class="footer-bottom">
                    &copy; 2026 Sinar Abadi. All rights reserved. | Built with Laravel, Vue & Go
                </div>
            </div>
        </footer>
    </div>
</template>
