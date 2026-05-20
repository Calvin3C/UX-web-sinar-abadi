<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { useForm, Link } from '@inertiajs/vue3';
import { ref, computed, watch } from 'vue';

const props = defineProps({
    cartItems: {
        type: Array,
        required: true,
    },
    logistic: {
        type: Object,
        required: true,
    },
    bankAccounts: {
        type: Array,
        required: true,
    },
});

const isAddressModalOpen = ref(false);
const isEditAddressModalOpen = ref(false);
const activeTab = ref('semua');

const storeAddress = {
    id: 99,
    label: 'Ambil Di Toko',
    isMain: false,
    name: 'Sinar Abadi (Pusat)',
    phone: '+62 8123388670',
    address: 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181',
    pinpoint: false
};

const mockAddresses = ref([
    {
        id: 1,
        label: 'Ijen Nirwana Green River C3 11',
        isMain: true,
        name: 'Calvin Alexander Sucipto',
        phone: '6282331339737',
        address: 'Perumahan Ijen Nirwana Cluster Green River Blok C3-11, Klojen, Kota Malang, Jawa Timur 65116 (Ijen Nirwana Green River C3-11)',
        pinpoint: true
    },
    {
        id: 2,
        label: 'Kantor Sinar Abadi',
        isMain: false,
        name: 'Budi Santoso',
        phone: '08123456789',
        address: 'Jl. Letjen Sutoyo No. 12, Lowokwaru, Malang, Jawa Timur 65141',
        pinpoint: false
    }
]);

const selectedAddress = ref(mockAddresses.value[0]);

const selectedBank = ref(props.bankAccounts[0]?.name || 'Mandiri');

const checkoutForm = useForm({
    bank: selectedBank.value,
    address: selectedAddress.value.address,
    phone: selectedAddress.value.phone,
    courier: selectedAddress.value.id === 99 ? 'Ambil Di Toko' : 'JNE',
    proof: null,
});

const handleProofUpload = (e) => {
    checkoutForm.proof = e.target.files[0];
};

// Watch for changes in selectedAddress to update checkout form
const selectAddress = (addr) => {
    selectedAddress.value = addr;
    checkoutForm.address = addr.address;
    checkoutForm.phone = addr.phone;
    if (addr.id === 99) {
        checkoutForm.courier = 'Ambil Di Toko';
    } else if (activeTab.value === 'kurir') {
        checkoutForm.courier = 'Kurir Toko Sinar Abadi';
    } else {
        checkoutForm.courier = 'JNE';
    }
};

// Automatically select default address based on tab change
watch(activeTab, (newTab) => {
    if (newTab === 'ambil') {
        selectAddress(storeAddress);
    } else {
        selectAddress(selectedAddress.value.id === 99 ? mockAddresses.value[0] : selectedAddress.value);
    }
});

// Edit form
const addressForm = useForm({
    label: '',
    address: '',
    notes: '',
    name: '',
    phone: ''
});

const formatPrice = (price) => {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(price).replace('Rp', 'Rp ');
};

const subtotal = computed(() => {
    return props.cartItems.reduce((acc, item) => acc + (item.price * item.qty), 0);
});

// PPN calculation if needed, for now just matching UI
const ppn = computed(() => {
    return subtotal.value * 0.11;
});

const grandTotal = computed(() => {
    return subtotal.value + ppn.value + (props.logistic.cost || 0);
});

const handleCheckout = () => {
    checkoutForm.bank = selectedBank.value;
    checkoutForm.post('/checkout', {
        forceFormData: true,
    });
};
</script>

<template>
    <AppLayout>
        <section class="section active" style="padding-top: 40px; background: #f8fafc; min-height: 100vh;">
            <div class="container" style="max-width: 1000px;">
                <div class="d-flex align-center justify-between mb-6" style="padding-bottom: 16px; border-bottom: 2px solid #e2e8f0;">
                    <div class="d-flex align-center gap-4">
                        <h2 style="font-size: 24px; font-weight: 800; color: #dc2626; margin: 0;">SINAR ABADI</h2>
                        <div style="width: 1px; height: 24px; background: #cbd5e1;"></div>
                        <div style="color: #059669; font-weight: 700; font-size: 14px; display: flex; align-items: center; gap: 6px;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            PEMBAYARAN AMAN
                        </div>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1.8fr 1fr; gap: 24px; align-items: start;">
                    <!-- Left Column -->
                    <div class="d-flex flex-column gap-6">
                        
                        <!-- ALAMAT PENGIRIMAN -->
                        <div style="background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 24px;">
                            <h3 style="font-size: 14px; font-weight: 700; color: #64748b; margin-bottom: 16px; text-transform: uppercase;">ALAMAT PENGIRIMAN</h3>
                            
                            <div class="d-flex justify-between align-start">
                                <div>
                                    <div class="d-flex align-center gap-2 mb-2">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#059669" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                                            <circle cx="12" cy="10" r="3"></circle>
                                        </svg>
                                        <template v-if="checkoutForm.courier === 'Ambil Di Toko'">
                                            <span style="font-weight: 700; color: #0f172a; font-size: 14px;">Ambil Di Toko</span>
                                        </template>
                                        <template v-else-if="checkoutForm.courier === 'Kurir Toko Sinar Abadi'">
                                            <span style="font-weight: 700; color: #0f172a; font-size: 14px;">Kurir Sinar Abadi - {{ selectedAddress.name }}</span>
                                        </template>
                                        <template v-else>
                                            <span style="font-weight: 700; color: #0f172a; font-size: 14px;">{{ selectedAddress.label }}</span>
                                            <span style="color: #64748b; font-size: 14px;">•</span>
                                            <span style="font-weight: 700; color: #0f172a; font-size: 14px;">{{ selectedAddress.name }}</span>
                                        </template>
                                    </div>
                                    <div style="color: #334155; font-size: 14px; line-height: 1.5; max-width: 90%;">
                                        {{ selectedAddress.address }}
                                    </div>
                                </div>
                                <button @click="isAddressModalOpen = true" class="btn btn-outline" style="padding: 6px 16px; font-size: 13px; border-radius: 8px;">
                                    Ganti
                                </button>
                            </div>
                        </div>

                        <!-- METODE PEMBAYARAN -->
                        <div style="background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 24px;">
                            <h3 style="font-size: 14px; font-weight: 700; color: #0f172a; margin-bottom: 16px; text-transform: uppercase; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px;">METODE PEMBAYARAN</h3>
                            
                            <p class="text-muted mb-4" style="font-size:13px;">
                                Silahkan pilih metode pembayaran yang Anda inginkan:
                            </p>

                            <div 
                                v-for="bank in bankAccounts" 
                                :key="bank.name" 
                                class="order-card mb-3"
                                :style="selectedBank === bank.name ? { borderColor: '#3b82f6', background: '#eff6ff' } : { cursor: 'pointer' }"
                                @click="selectedBank = bank.name"
                            >
                                <div class="d-flex align-center gap-3">
                                    <!-- Radio input mimic -->
                                    <div 
                                        style="width: 18px; height: 18px; border-radius: 50%; border: 2px solid #cbd5e1; display: flex; align-items: center; justify-content: center; background: white;"
                                        :style="selectedBank === bank.name ? { borderColor: '#3b82f6' } : {}"
                                    >
                                        <div 
                                            v-if="selectedBank === bank.name"
                                            style="width: 10px; height: 10px; border-radius: 50%; background: #3b82f6;"
                                        ></div>
                                    </div>
                                    <span style="font-size: 14px; font-weight: 600; color: #1e293b;">
                                        Transfer Bank ({{ bank.name }})
                                    </span>
                                </div>

                                <div v-if="selectedBank === bank.name" style="margin-top: 16px; margin-left: 31px; background: white; padding: 16px; border-radius: 6px; border: 1px solid #e2e8f0;">
                                    <div style="font-size: 13px; font-weight: 700; color: #0f172a; margin-bottom: 4px;">Instruksi Pembayaran (Rekening Tujuan)</div>
                                    <div style="font-size: 13px; color: #64748b; margin-bottom: 12px;">Silakan transfer tagihan Anda ke rekening kami berikut:</div>
                                    
                                    <div style="font-size: 16px; font-weight: 800; color: #1e3a8a; margin-bottom: 16px;">
                                        {{ bank.name }} - {{ bank.number }} a.n. {{ bank.owner }}
                                    </div>

                                    <div style="border-top: 1px solid #e2e8f0; margin-bottom: 12px;"></div>

                                    <div style="font-size: 13px; font-weight: 700; color: #0f172a; margin-bottom: 4px;">Alamat Sinar Abadi (Pusat)</div>
                                    <div style="font-size: 13px; color: #64748b; line-height: 1.5;">
                                        Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181 • +62 8123388670
                                    </div>
                                </div>
                            </div>
                            
                            <div style="margin-top: 16px; margin-bottom: 16px;">
                                <label style="font-size: 13px; font-weight: 700; color: #0f172a; display: block; margin-bottom: 8px;">Upload Bukti Transfer</label>
                                <input 
                                    type="file" 
                                    accept="image/*"
                                    @change="handleProofUpload"
                                    style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; background: white;"
                                    required
                                >
                                <div style="font-size: 11px; color: #dc2626; margin-top: 4px;" v-if="checkoutForm.errors.proof">
                                    {{ checkoutForm.errors.proof }}
                                </div>
                            </div>
                            
                            <form @submit.prevent="handleCheckout" class="mt-4">
                                <div style="font-size: 13px; color: #dc2626; margin-bottom: 8px;" v-if="checkoutForm.errors.bank">
                                    {{ checkoutForm.errors.bank }}
                                </div>
                                <button 
                                    type="submit" 
                                    class="btn w-100" 
                                    style="background: #0f172a; color: white; font-size:14px; padding:16px; font-weight: 700; border-radius: 6px;"
                                    :disabled="checkoutForm.processing || !checkoutForm.proof"
                                    :style="(!checkoutForm.proof) ? { opacity: 0.5, cursor: 'not-allowed' } : {}"
                                >
                                    <span v-if="checkoutForm.processing">MEMBUAT PESANAN...</span>
                                    <span v-else>BAYAR SEKARANG</span>
                                </button>
                            </form>
                        </div>
                    </div>

                    <!-- Right Column: Summaries -->
                    <div class="d-flex flex-column gap-4">
                        <!-- Ringkasan Pembelian -->
                        <div style="background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 20px;">
                            <h3 style="font-size: 15px; font-weight: 700; color: #0f172a; margin-bottom: 16px;">Ringkasan Pembelian</h3>
                            
                            <div class="d-flex justify-between align-center mb-3" style="font-size: 14px; color: #64748b;">
                                <span>Subtotal Produk</span>
                                <span style="color: #0f172a; font-weight: 500;">{{ formatPrice(subtotal) }}</span>
                            </div>
                            <div class="d-flex justify-between align-center mb-3" style="font-size: 14px; color: #64748b;">
                                <span>PPN (11%)</span>
                                <span style="color: #0f172a; font-weight: 500;">{{ formatPrice(ppn) }}</span>
                            </div>
                            <div class="d-flex justify-between align-center mb-4" style="font-size: 14px; color: #64748b;">
                                <span>Ongkos Kirim</span>
                                <span style="color: #0f172a; font-weight: 500;">{{ logistic.cost > 0 ? formatPrice(logistic.cost) : 'Gratis' }}</span>
                            </div>

                            <div style="border-top: 1px solid #e2e8f0; padding-top: 16px;" class="d-flex justify-between align-center">
                                <span style="font-size: 15px; font-weight: 700; color: #0f172a;">Grand Total</span>
                                <span style="font-size: 18px; font-weight: 800; color: #dc2626;">{{ formatPrice(grandTotal) }}</span>
                            </div>
                        </div>

                        <!-- Ringkasan Produk -->
                        <div style="background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 20px;">
                            <h3 style="font-size: 15px; font-weight: 700; color: #0f172a; margin-bottom: 16px;">Ringkasan Produk</h3>
                            <div style="max-height: 250px; overflow-y: auto; padding-right: 8px;">
                                <div v-for="item in cartItems" :key="item.id" class="d-flex gap-3 mb-4">
                                    <div style="width: 48px; height: 48px; border-radius: 6px; background: #f1f5f9; flex-shrink: 0;">
                                        <img v-if="item.img" :src="item.img" style="width:100%; height:100%; object-fit:cover; border-radius: 6px;">
                                    </div>
                                    <div>
                                        <div style="font-size: 13px; color: #1e293b; font-weight: 600; line-height: 1.4;">{{ item.name }}</div>
                                        <div style="font-size: 12px; color: #64748b; margin-top: 4px;">{{ item.qty }} x {{ formatPrice(item.price) }}</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Modal 1: Daftar Alamat -->
        <div v-if="isAddressModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div style="width:100%; max-width:650px; background: white; border-radius: 12px; overflow: hidden; animation: slideUp 0.3s forwards; display: flex; flex-direction: column; max-height: 90vh;">
                <!-- Header -->
                <div class="d-flex justify-between align-center" style="padding: 20px 24px; border-bottom: 1px solid #e2e8f0;">
                    <h3 style="font-size: 18px; font-weight: 800; color: #0f172a; margin: 0; flex: 1; text-align: center;">Daftar Alamat</h3>
                    <button @click="isAddressModalOpen = false" style="background: none; border: none; cursor: pointer;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>
                
                <!-- Tabs -->
                <div class="d-flex" style="border-bottom: 1px solid #e2e8f0;">
                    <div 
                        @click="activeTab = 'semua'"
                        style="flex: 1; text-align: center; padding: 12px 0; font-size: 14px; cursor: pointer;"
                        :style="activeTab === 'semua' ? 'font-weight: 700; color: #059669; border-bottom: 2px solid #059669;' : 'font-weight: 600; color: #64748b;'"
                    >
                        Semua Alamat
                    </div>
                    <div 
                        @click="activeTab = 'ambil'"
                        style="flex: 1; text-align: center; padding: 12px 0; font-size: 14px; cursor: pointer;"
                        :style="activeTab === 'ambil' ? 'font-weight: 700; color: #059669; border-bottom: 2px solid #059669;' : 'font-weight: 600; color: #64748b;'"
                    >
                        Ambil Di Toko
                    </div>
                    <div 
                        @click="activeTab = 'kurir'"
                        style="flex: 1; text-align: center; padding: 12px 0; font-size: 14px; cursor: pointer;"
                        :style="activeTab === 'kurir' ? 'font-weight: 700; color: #059669; border-bottom: 2px solid #059669;' : 'font-weight: 600; color: #64748b;'"
                    >
                        Kurir Sinar Abadi
                    </div>
                </div>

                <div v-if="activeTab === 'semua' || activeTab === 'kurir'" style="display: flex; flex-direction: column; overflow: hidden;">
                    <!-- Search & Add -->
                    <div style="padding: 20px 24px;">
                        <div style="position: relative; margin-bottom: 16px;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 11px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                            <input type="text" placeholder="Tulis Nama Alamat / Kota / Kecamatan tujuan pengiriman" style="width: 100%; padding: 10px 12px 10px 40px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;">
                        </div>
                        
                        <button @click="isEditAddressModalOpen = true" style="width: 100%; padding: 12px; border: 1px solid #059669; background: white; color: #059669; font-weight: 700; border-radius: 8px; font-size: 14px; cursor: pointer;">
                            Tambah Alamat Baru
                        </button>
                    </div>

                    <!-- Address List -->
                    <div style="padding: 0 24px 24px 24px; overflow-y: auto; flex: 1;">
                        <div 
                            v-for="addr in mockAddresses" 
                            :key="addr.id" 
                            @click="selectAddress(addr)"
                            style="border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; margin-bottom: 16px; cursor: pointer; position: relative;"
                            :style="selectedAddress.id === addr.id ? { borderColor: '#059669', background: '#ecfdf5' } : {}"
                        >
                            <div class="d-flex align-center gap-2 mb-2">
                                <span style="font-weight: 700; color: #0f172a; font-size: 14px;">{{ addr.label }}</span>
                                <span v-if="addr.isMain" style="background: #e2e8f0; color: #475569; font-size: 11px; font-weight: 700; padding: 2px 6px; border-radius: 4px;">Utama</span>
                            </div>
                            <div style="font-weight: 700; color: #0f172a; font-size: 15px; margin-bottom: 4px;">{{ addr.name }}</div>
                            <div style="font-size: 13px; color: #64748b; margin-bottom: 4px;">{{ addr.phone }}</div>
                            <div style="font-size: 13px; color: #334155; line-height: 1.5; margin-bottom: 12px; padding-right: 24px;">
                                {{ addr.address }}
                            </div>
                            
                            <div v-if="addr.pinpoint" class="d-flex align-center gap-2 mb-3" style="color: #059669; font-size: 13px; font-weight: 600;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                                    <circle cx="12" cy="10" r="3"></circle>
                                </svg>
                                Sudah Pinpoint
                            </div>

                            <div class="d-flex align-center gap-4">
                                <span style="font-size: 13px; font-weight: 700; color: #059669;">Share</span>
                                <div style="width: 1px; height: 12px; background: #cbd5e1;"></div>
                                <span @click.stop="isEditAddressModalOpen = true" style="font-size: 13px; font-weight: 700; color: #059669;">Ubah Alamat</span>
                            </div>

                            <!-- Checkmark -->
                            <div v-if="selectedAddress.id === addr.id" style="position: absolute; right: 16px; top: 50%; transform: translateY(-50%); color: #059669;">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            </div>
                        </div>
                    </div>
                </div>

                <div v-else style="padding: 24px; flex: 1;">
                    <div 
                        @click="selectAddress(storeAddress)"
                        style="border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; cursor: pointer; position: relative;"
                        :style="selectedAddress.id === storeAddress.id ? { borderColor: '#059669', background: '#ecfdf5' } : {}"
                    >
                        <div style="font-weight: 700; color: #0f172a; font-size: 15px; margin-bottom: 12px;">Ambil Di Toko</div>
                        <div style="font-size: 13px; color: #334155; line-height: 1.6; max-width: 90%;">
                            Alamat: {{ storeAddress.address }}
                        </div>
                        
                        <!-- Checkmark -->
                        <div v-if="selectedAddress.id === storeAddress.id" style="position: absolute; right: 16px; top: 20px; color: #059669;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                        </div>
                    </div>
                </div>

                <!-- Footer with Save Button -->
                <div style="padding: 16px 24px; border-top: 1px solid #e2e8f0; background: white;">
                    <button @click="isAddressModalOpen = false" class="btn btn-primary w-100" style="background: #059669; border-color: #059669; padding: 14px; font-weight: 700; border-radius: 8px;">
                        Simpan & Selesai
                    </button>
                </div>
            </div>
        </div>

        <!-- Modal 2: Edit Alamat -->
        <div v-if="isEditAddressModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:10000; align-items:center; justify-content:center; padding:16px;">
            <div style="width:100%; max-width:550px; background: white; border-radius: 12px; overflow: hidden; animation: slideUp 0.3s forwards;">
                <div class="d-flex justify-between align-center" style="padding: 20px 24px; border-bottom: 1px solid #e2e8f0;">
                    <h3 style="font-size: 18px; font-weight: 800; color: #0f172a; margin: 0; flex: 1; text-align: center;">Ubah Alamat</h3>
                    <button @click="isEditAddressModalOpen = false" style="background: none; border: none; cursor: pointer;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>
                
                <div style="padding: 24px; max-height: 70vh; overflow-y: auto;">
                    <div style="position: relative; margin-bottom: 24px;">
                        <label style="position: absolute; top: -8px; left: 12px; background: white; padding: 0 4px; font-size: 12px; color: #64748b; font-weight: 500;">Label Alamat</label>
                        <input type="text" value="Ijen Nirwana Green River C3 11" class="form-input" style="padding: 14px; border: 1px solid #cbd5e1; border-radius: 8px;">
                    </div>

                    <div style="position: relative; margin-bottom: 24px;">
                        <label style="position: absolute; top: -8px; left: 12px; background: white; padding: 0 4px; font-size: 12px; color: #64748b; font-weight: 500;">Alamat Lengkap</label>
                        <textarea class="form-input" rows="3" style="padding: 14px; border: 1px solid #cbd5e1; border-radius: 8px;">Perumahan Ijen Nirwana Cluster Green River Blok C3-11, Klojen, Kota Malang, Jawa Timur 65116</textarea>
                    </div>

                    <div style="position: relative; margin-bottom: 32px;">
                        <label style="position: absolute; top: -8px; left: 12px; background: white; padding: 0 4px; font-size: 12px; color: #64748b; font-weight: 500;">Catatan Untuk Kurir (Opsional)</label>
                        <input type="text" value="Ijen Nirwana Green River C3-11" class="form-input" style="padding: 14px; border: 1px solid #cbd5e1; border-radius: 8px;">
                        <div style="font-size: 11px; color: #94a3b8; margin-top: 4px;">Warna rumah, patokan, pesan khusus, dll.</div>
                    </div>

                    <div style="position: relative; margin-bottom: 24px;">
                        <label style="position: absolute; top: -8px; left: 12px; background: white; padding: 0 4px; font-size: 12px; color: #64748b; font-weight: 500;">Nama Penerima</label>
                        <input type="text" value="Calvin Alexander Sucipto" class="form-input" style="padding: 14px; border: 1px solid #cbd5e1; border-radius: 8px;">
                    </div>

                    <div style="position: relative; margin-bottom: 24px;">
                        <label style="position: absolute; top: -8px; left: 12px; background: white; padding: 0 4px; font-size: 12px; color: #64748b; font-weight: 500;">Nomor HP</label>
                        <input type="text" value="6282331339737" class="form-input" style="padding: 14px; border: 1px solid #cbd5e1; border-radius: 8px;">
                    </div>
                    
                    <button @click="isEditAddressModalOpen = false" class="btn btn-primary w-100" style="background: #059669; border-color: #059669; padding: 14px; font-weight: 700; border-radius: 8px;">
                        Simpan Alamat
                    </button>
                </div>
            </div>
        </div>
    </AppLayout>
</template>
