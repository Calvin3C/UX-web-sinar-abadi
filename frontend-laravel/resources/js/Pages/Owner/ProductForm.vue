<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { useForm, Link } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    mode: {
        type: String, // 'create' or 'edit'
        default: 'create',
    },
    product: {
        type: Object,
        default: null,
    },
    categories: {
        type: Array,
        default: () => [],
    },
    username: {
        type: String,
        default: 'Owner',
    },
});

const isEdit = computed(() => props.mode === 'edit');
const pageTitle = computed(() => isEdit.value ? 'Edit Produk' : 'Tambahkan Produk');

const form = useForm({
    _method: isEdit.value ? 'PUT' : 'POST',
    id: props.product?.id || '',
    name: props.product?.name || '',
    category: props.product?.category || '',
    price: props.product?.price || 0,
    ...(isEdit.value ? {} : { stock: 0 }),
    isLarge: props.product?.isLarge || false,
    img: props.product?.img || '',
    photo_main: null,
    photo_1: null,
    photo_2: null,
    photo_3: null,
    photo_4: null,
    photo_5: null,
});

const photoSlots = ref([
    { label: '• Foto Utama', file: null, preview: props.product?.img || null, field: 'photo_main' },
    { label: 'Foto 1', file: null, preview: null, field: 'photo_1' },
    { label: 'Foto 2', file: null, preview: null, field: 'photo_2' },
    { label: 'Foto 3', file: null, preview: null, field: 'photo_3' },
    { label: 'Foto 4', file: null, preview: null, field: 'photo_4' },
    { label: 'Foto 5', file: null, preview: null, field: 'photo_5' },
]);

const fileInputRefs = ref([]);

const triggerUpload = (index) => {
    const input = document.getElementById(`photo-input-${index}`);
    if (input) input.click();
};

const handlePhotoChange = (e, index) => {
    const file = e.target.files[0];
    if (!file) return;
    photoSlots.value[index].file = file;
    photoSlots.value[index].preview = URL.createObjectURL(file);
    // Sync file into form data
    form[photoSlots.value[index].field] = file;
};

const removePhoto = (index) => {
    photoSlots.value[index].file = null;
    photoSlots.value[index].preview = null;
    form[photoSlots.value[index].field] = null;
};

const handleSubmit = () => {
    if (isEdit.value) {
        form.post(`/owner/products/${props.product.id}`, {
            preserveScroll: true,
            forceFormData: true,
        });
    } else {
        form.post('/owner/products', {
            preserveScroll: true,
            forceFormData: true,
        });
    }
};

const uniqueCategories = computed(() => {
    const cats = [...new Set(props.categories)];
    return cats;
});
</script>

<template>
    <AppLayout>
        <section class="section active" style="padding-top: 40px; background: #f8fafc; min-height: 100vh;">
            <div class="container" style="max-width: 900px;">
                <!-- Card Wrapper -->
                <div style="background: white; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); overflow: hidden;">
                    
                    <!-- Header -->
                    <div style="padding: 28px 32px 20px 32px; border-bottom: 2px solid #e2e8f0;">
                        <h2 style="font-size: 22px; font-weight: 800; color: #0f172a; margin: 0;">{{ pageTitle }}</h2>
                    </div>

                    <!-- Form Body -->
                    <form @submit.prevent="handleSubmit" style="padding: 28px 32px 32px 32px;">
                        
                        <!-- Kode Produk -->
                        <div style="display: grid; grid-template-columns: 140px 1fr; align-items: center; margin-bottom: 20px; gap: 16px;">
                            <label style="font-size: 14px; font-weight: 600; color: #334155; line-height: 1.3;">
                                Kode Produk/<br>Id Produk
                            </label>
                            <input
                                v-model="form.id"
                                type="text"
                                placeholder="Masukkan kode Produk"
                                :disabled="isEdit"
                                style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; background: white; color: #0f172a; outline: none; transition: border 0.2s;"
                                :style="isEdit ? { background: '#f1f5f9', color: '#64748b', cursor: 'not-allowed' } : {}"
                            >
                        </div>

                        <!-- Nama Produk -->
                        <div style="display: grid; grid-template-columns: 140px 1fr; align-items: center; margin-bottom: 20px; gap: 16px;">
                            <label style="font-size: 14px; font-weight: 600; color: #334155;">Nama Produk</label>
                            <input
                                v-model="form.name"
                                type="text"
                                placeholder="Masukkan Nama Produk"
                                style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; background: white; color: #0f172a; outline: none; transition: border 0.2s;"
                            >
                        </div>

                        <!-- Kategori -->
                        <div style="display: grid; grid-template-columns: 140px 1fr; align-items: center; margin-bottom: 20px; gap: 16px;">
                            <label style="font-size: 14px; font-weight: 600; color: #334155;">Kategori</label>
                            <div style="position: relative;">
                                <select
                                    v-model="form.category"
                                    style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; background: white; color: #0f172a; outline: none; appearance: none; cursor: pointer; padding-right: 40px;"
                                >
                                    <option value="" disabled>Masukkan Kategori yang Sesuai</option>
                                    <option v-for="cat in uniqueCategories" :key="cat" :value="cat">{{ cat }}</option>
                                </select>
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); pointer-events: none;">
                                    <polyline points="6 9 12 15 18 9"></polyline>
                                </svg>
                            </div>
                        </div>

                        <!-- Harga -->
                        <div style="display: grid; grid-template-columns: 140px 1fr; align-items: center; margin-bottom: 20px; gap: 16px;">
                            <label style="font-size: 14px; font-weight: 600; color: #334155;">Harga (Rp)</label>
                            <input
                                v-model.number="form.price"
                                type="number"
                                placeholder="Masukkan Harga Produk"
                                min="0"
                                style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; background: white; color: #0f172a; outline: none; transition: border 0.2s;"
                            >
                        </div>

                        <!-- Stok (hanya untuk mode create, stok dikelola terpisah saat edit) -->
                        <div v-if="!isEdit" style="display: grid; grid-template-columns: 140px 1fr; align-items: center; margin-bottom: 28px; gap: 16px;">
                            <label style="font-size: 14px; font-weight: 600; color: #334155;">Stok Awal</label>
                            <input
                                v-model.number="form.stock"
                                type="number"
                                placeholder="Masukkan Jumlah Stok Awal"
                                min="0"
                                style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; background: white; color: #0f172a; outline: none; transition: border 0.2s;"
                            >
                        </div>
                        <div v-else style="display: grid; grid-template-columns: 140px 1fr; align-items: center; margin-bottom: 28px; gap: 16px;">
                            <label style="font-size: 14px; font-weight: 600; color: #334155;">Stok</label>
                            <div style="padding: 10px 14px; background: #f1f5f9; border-radius: 6px; font-size: 14px; color: #64748b;">
                                Stok dikelola melalui menu "Update Stok" di Dashboard
                            </div>
                        </div>

                        <!-- Divider -->
                        <div style="border-top: 1px solid #e2e8f0; margin-bottom: 24px;"></div>

                        <!-- Media Section -->
                        <div style="margin-bottom: 32px;">
                            <h3 style="font-size: 18px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">Media</h3>
                            <p style="font-size: 13px; color: #64748b; margin-bottom: 20px;">Foto Produk</p>

                            <div style="display: flex; flex-wrap: wrap; gap: 16px;">
                                <div 
                                    v-for="(slot, index) in photoSlots" 
                                    :key="index"
                                    style="display: flex; flex-direction: column; align-items: center; gap: 8px;"
                                >
                                    <!-- Photo Slot Box -->
                                    <div
                                        @click="triggerUpload(index)"
                                        style="width: 100px; height: 100px; border: 2px solid #e2e8f0; border-radius: 8px; display: flex; align-items: center; justify-content: center; cursor: pointer; position: relative; overflow: hidden; transition: all 0.2s; background: #fafafa;"
                                        @mouseover="$event.currentTarget.style.borderColor = '#94a3b8'"
                                        @mouseleave="$event.currentTarget.style.borderColor = '#e2e8f0'"
                                    >
                                        <!-- Preview Image -->
                                        <img 
                                            v-if="slot.preview" 
                                            :src="slot.preview" 
                                            style="width: 100%; height: 100%; object-fit: cover;"
                                        >
                                        <!-- Plus Icon -->
                                        <div v-else style="display: flex; align-items: center; justify-content: center;">
                                            <div style="width: 40px; height: 40px; border-radius: 50%; background: #1e293b; display: flex; align-items: center; justify-content: center;">
                                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                                    <line x1="12" y1="5" x2="12" y2="19"></line>
                                                    <line x1="5" y1="12" x2="19" y2="12"></line>
                                                </svg>
                                            </div>
                                        </div>

                                        <!-- Remove Button -->
                                        <button 
                                            v-if="slot.preview"
                                            @click.stop="removePhoto(index)"
                                            style="position: absolute; top: 4px; right: 4px; width: 22px; height: 22px; border-radius: 50%; background: rgba(220,38,38,0.9); border: none; cursor: pointer; display: flex; align-items: center; justify-content: center;"
                                        >
                                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                                                <line x1="18" y1="6" x2="6" y2="18"></line>
                                                <line x1="6" y1="6" x2="18" y2="18"></line>
                                            </svg>
                                        </button>
                                    </div>

                                    <!-- Hidden File Input -->
                                    <input 
                                        :id="`photo-input-${index}`"
                                        type="file" 
                                        accept="image/*"
                                        @change="(e) => handlePhotoChange(e, index)"
                                        style="display: none;"
                                    >

                                    <!-- Label -->
                                    <span style="font-size: 12px; color: #64748b; font-weight: 500;">{{ slot.label }}</span>
                                </div>
                            </div>
                        </div>

                        <!-- Error Messages -->
                        <div v-if="form.errors && Object.keys(form.errors).length > 0" style="margin-bottom: 16px; padding: 12px 16px; background: #fef2f2; border: 1px solid #fecaca; border-radius: 8px;">
                            <p v-for="(error, key) in form.errors" :key="key" style="color: #dc2626; font-size: 13px; margin: 0;">{{ error }}</p>
                        </div>

                        <!-- Footer Actions -->
                        <div style="display: flex; justify-content: space-between; align-items: center; padding-top: 16px; border-top: 1px solid #e2e8f0;">
                            <Link 
                                href="/owner/dashboard" 
                                style="padding: 10px 20px; font-size: 14px; font-weight: 600; color: #64748b; text-decoration: none; border: 1px solid #cbd5e1; border-radius: 8px; background: white; cursor: pointer; transition: all 0.2s;"
                            >
                                ← Kembali
                            </Link>

                            <button
                                type="submit"
                                :disabled="form.processing"
                                style="padding: 12px 28px; font-size: 14px; font-weight: 700; color: white; background: #1e293b; border: none; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                @mouseover="$event.currentTarget.style.background = '#334155'"
                                @mouseleave="$event.currentTarget.style.background = '#1e293b'"
                            >
                                <span v-if="form.processing">Menyimpan...</span>
                                <span v-else>Simpan & Update</span>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </section>
    </AppLayout>
</template>
