<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { useForm } from '@inertiajs/vue3';
import { ref } from 'vue';

const mode = ref('login'); // 'login' or 'register'
const activeRole = ref('customer');

const loginForm = useForm({
    role: 'customer',
    username: '',
    password: '',
});

const registerForm = useForm({
    role: 'customer',
    name: '',
    username: '',
    password: '',
    password_confirmation: '',
    phone: '',
    email: '',
    gender: 'Laki-laki',
});

const activeRegisterRole = ref('customer');

const switchRegisterRole = (role) => {
    activeRegisterRole.value = role;
    registerForm.role = role;
};

const switchRole = (role) => {
    activeRole.value = role;
    loginForm.role = role;
};

const toggleAuthMode = () => {
    mode.value = mode.value === 'login' ? 'register' : 'login';
};

const handleLogin = () => {
    loginForm.post('/login', {
        onFinish: () => loginForm.reset('password'),
    });
};

const handleRegister = () => {
    registerForm.transform((data) => {
        let phone = data.phone;
        if (data.role === 'customer' && phone) {
            // Remove leading zero if user accidentally typed it
            if (phone.startsWith('0')) {
                phone = phone.substring(1);
            }
            // Only prepend +62 if not already starting with +62
            if (!phone.startsWith('+62')) {
                phone = '+62' + phone;
            }
        }
        return {
            ...data,
            phone: phone
        };
    }).post('/register', {
        onSuccess: () => {
            mode.value = 'login';
            registerForm.reset();
        },
    });
};
</script>

<template>
    <AppLayout>
        <section class="section active">
            <div class="container">
                <div class="auth-container">
                    <div class="auth-header">
                        <h2>{{ mode === 'register' ? 'Registrasi Customer' : 'Login Autentikasi' }}</h2>
                        <p style="color:#cbd5e1; font-size:14px;">
                            {{ mode === 'register' ? 'Buat akun pelanggan Sinar Abadi' : 'Login untuk mulai berbelanja' }}
                        </p>
                    </div>

                    <div class="auth-body">
                        <!-- Login Section -->
                        <div v-if="mode === 'login'" id="login-section">
                            <div class="role-tabs" id="auth-role-selector">
                                <div 
                                    class="role-tab" 
                                    :class="{ active: activeRole === 'customer' }" 
                                    @click="switchRole('customer')"
                                >
                                    Customer
                                </div>
                                <div 
                                    class="role-tab" 
                                    :class="{ active: activeRole === 'admin' }" 
                                    @click="switchRole('admin')"
                                >
                                    Admin
                                </div>
                                <div 
                                    class="role-tab" 
                                    :class="{ active: activeRole === 'owner' }" 
                                    @click="switchRole('owner')"
                                >
                                    Owner
                                </div>
                            </div>

                            <form @submit.prevent="handleLogin" id="login-form">
                                <div class="form-group">
                                    <label class="form-label">{{ activeRole === 'customer' ? 'Email atau Username' : 'Username' }}</label>
                                    <input 
                                        type="text" 
                                        class="form-input" 
                                        :placeholder="activeRole === 'customer' ? 'Masukkan email atau username' : 'Masukkan username'"
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
                                        Masuk Sebagai {{ activeRole === 'customer' ? 'Customer' : activeRole === 'admin' ? 'Admin' : 'Owner' }}
                                    </span>
                                </button>
                            </form>

                            <div v-if="activeRole === 'customer'" class="text-center mt-8 text-muted" style="font-size:14px;">
                                Pelanggan baru? <a href="javascript:void(0)" @click="toggleAuthMode">Buat Akun Customer</a>
                            </div>
                        </div>

                        <!-- Register Section -->
                        <div v-else id="register-section">
                            <div class="role-tabs" id="auth-role-selector">
                                <div 
                                    class="role-tab" 
                                    :class="{ active: activeRegisterRole === 'customer' }" 
                                    @click="switchRegisterRole('customer')"
                                >
                                    Customer
                                </div>
                                <div 
                                    class="role-tab" 
                                    :class="{ active: activeRegisterRole === 'admin' }" 
                                    @click="switchRegisterRole('admin')"
                                >
                                    Admin
                                </div>

                            </div>

                            <form @submit.prevent="handleRegister">
                                <template v-if="activeRegisterRole === 'customer'">
                                    <div class="form-group">
                                        <label class="form-label">Nama Lengkap</label>
                                    <input 
                                        type="text" 
                                        class="form-input" 
                                        placeholder="Masukkan nama lengkap"
                                        v-model="registerForm.name"
                                        required
                                    >
                                    <div v-if="registerForm.errors.name" class="text-danger mt-2" style="font-size: 13px;">
                                        {{ registerForm.errors.name }}
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">No. Handphone Pengguna <span class="text-danger" style="color: #e11d48;">*</span></label>
                                    <div style="display: flex; gap: 8px;">
                                        <div style="padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 8px; background: white; color: #1e293b; font-size: 14px; display: flex; align-items: center; justify-content: center; width: 80px; flex-shrink: 0; font-weight: 500;">
                                            +62
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-left: 4px;"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                        </div>
                                        <input 
                                            type="tel" 
                                            class="form-input" 
                                            placeholder="eg, 871037262"
                                            v-model="registerForm.phone"
                                            style="flex: 1;"
                                            required
                                        >
                                    </div>
                                    <div v-if="registerForm.errors.phone" class="text-danger mt-2" style="font-size: 13px;">
                                        {{ registerForm.errors.phone }}
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Email</label>
                                    <input 
                                        type="email" 
                                        class="form-input" 
                                        placeholder="Masukkan alamat email"
                                        v-model="registerForm.email"
                                        required
                                    >
                                    <div v-if="registerForm.errors.email" class="text-danger mt-2" style="font-size: 13px;">
                                        {{ registerForm.errors.email }}
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Gender</label>
                                    <select 
                                        class="form-input" 
                                        v-model="registerForm.gender"
                                        required
                                    >
                                        <option value="Laki-laki">Laki-laki</option>
                                        <option value="Perempuan">Perempuan</option>
                                    </select>
                                        <div v-if="registerForm.errors.gender" class="text-danger mt-2" style="font-size: 13px;">
                                            {{ registerForm.errors.gender }}
                                        </div>
                                    </div>
                                </template>

                                <div class="form-group">
                                    <label class="form-label">Username</label>
                                    <input 
                                        type="text" 
                                        class="form-input" 
                                        placeholder="Buat username unik"
                                        v-model="registerForm.username"
                                        required
                                    >
                                    <div v-if="registerForm.errors.username" class="text-danger mt-2" style="font-size: 13px;">
                                        {{ registerForm.errors.username }}
                                    </div>
                                </div>

                                <div class="form-group mb-4">
                                    <label class="form-label">Kata Sandi</label>
                                    <input 
                                        type="password" 
                                        class="form-input" 
                                        placeholder="Min. 5 karakter"
                                        v-model="registerForm.password"
                                        minlength="5"
                                        required
                                    >
                                    <div v-if="registerForm.errors.password" class="text-danger mt-2" style="font-size: 13px;">
                                        {{ registerForm.errors.password }}
                                    </div>
                                </div>

                                <div class="form-group mb-8">
                                    <label class="form-label">Konfirmasi Kata Sandi</label>
                                    <input 
                                        type="password" 
                                        class="form-input" 
                                        placeholder="Ketik ulang kata sandi"
                                        v-model="registerForm.password_confirmation"
                                        minlength="5"
                                        required
                                    >
                                </div>

                                <button 
                                    type="submit" 
                                    class="btn btn-primary w-100" 
                                    style="font-size:16px;"
                                    :disabled="registerForm.processing"
                                >
                                    <span v-if="registerForm.processing">Mendaftar...</span>
                                    <span v-else>Daftar Sekarang</span>
                                </button>
                            </form>

                            <div class="text-center mt-8 text-muted" style="font-size:14px;">
                                Sudah punya akun? <a href="javascript:void(0)" @click="toggleAuthMode">Masuk di sini</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </AppLayout>
</template>
