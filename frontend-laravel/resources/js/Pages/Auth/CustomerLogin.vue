<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { useForm, Link } from '@inertiajs/vue3';

const loginForm = useForm({
    role: 'customer',
    username: '',
    password: '',
});

const handleLogin = () => {
    loginForm.post('/login', {
        onFinish: () => loginForm.reset('password'),
    });
};
</script>

<template>
    <AppLayout>
        <section class="section active">
            <div class="container">
                <div class="auth-container">
                    <div class="auth-header">
                        <h2>Login Autentikasi</h2>
                        <p style="color:#cbd5e1; font-size:14px;">
                            Login untuk mulai berbelanja
                        </p>
                    </div>

                    <div class="auth-body">
                        <form @submit.prevent="handleLogin" id="login-form">
                            <div class="form-group">
                                <label class="form-label">Email atau Username</label>
                                <input 
                                    type="text" 
                                    class="form-input" 
                                    placeholder="Masukkan email atau username"
                                    v-model="loginForm.username" 
                                    required
                                >
                                <div v-if="loginForm.errors.username" class="text-danger mt-2" style="font-size: 13px;">
                                    {{ loginForm.errors.username }}
                                </div>
                            </div>

                            <div class="form-group mb-8">
                                <label class="form-label">Kata Sandi</label>
                                <input 
                                    type="password" 
                                    class="form-input" 
                                    placeholder="••••••••" 
                                    v-model="loginForm.password" 
                                    required
                                >
                                <div v-if="loginForm.errors.password" class="text-danger mt-2" style="font-size: 13px;">
                                    {{ loginForm.errors.password }}
                                </div>
                            </div>

                            <button 
                                type="submit" 
                                class="btn btn-primary w-100" 
                                style="font-size:16px;"
                                :disabled="loginForm.processing"
                            >
                                <span v-if="loginForm.processing">Memproses...</span>
                                <span v-else>
                                    Masuk Sebagai Customer
                                </span>
                            </button>
                        </form>

                        <div class="text-center mt-8 text-muted" style="font-size:14px;">
                            Pelanggan baru? <Link href="/register">Buat Akun Customer</Link>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </AppLayout>
</template>
