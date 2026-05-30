<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;
use Inertia\Inertia;

class CartController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Tampilkan halaman keranjang.
     */
    public function index()
    {
        $cart = session('cart', []);
        $cartItems = array_values($cart);
        
        $logistic = session('checkout_logistics', [
            'courier' => '',
            'address' => '',
            'cost' => 0,
            'totalWeight' => 0
        ]);

        return Inertia::render('Cart/Index', [
            'cartItems' => $cartItems,
            'logistic' => $logistic,
        ]);
    }

    /**
     * Tambah produk ke keranjang.
     */
    public function add(Request $request)
    {
        $request->validate([
            'id'      => 'required|string',
            'name'    => 'required|string',
            'price'   => 'required|numeric',
            'img'     => 'nullable|string',
            'stock'   => 'nullable|numeric',
            'isLarge' => 'nullable',
            'qty'     => 'nullable|numeric|min:1',
        ]);

        $cart = session('cart', []);
        $productId = $request->input('id');
        $isLarge = in_array($request->input('isLarge'), ['1', 'true', true, 1], true)
                || $request->input('isLarge') === true;
        
        $requestedQty = (int) $request->input('qty', 1);

        if (isset($cart[$productId])) {
            // Check stock limit
            $newQty = $cart[$productId]['qty'] + $requestedQty;
            $stockLimit = (int) $request->input('stock', 999);
            if ($newQty > $stockLimit) {
                return back()->with('error', 'Stok produk tidak mencukupi.');
            }
            $cart[$productId]['qty'] = $newQty;
        } else {
            $cart[$productId] = [
                'id'      => $productId,
                'name'    => $request->input('name'),
                'price'   => (int) $request->input('price'),
                'img'     => $request->input('img', ''),
                'isLarge' => $isLarge,
                'stock'   => (int) $request->input('stock', 0),
                'qty'     => $requestedQty,
            ];
        }

        session(['cart' => $cart]);

        // Recalculate shipping if logistics already set
        $this->recalculateLogistics();

        return back()->with('success', 'Produk ditambahkan ke keranjang.');
    }

    /**
     * Update quantity produk di keranjang.
     */
    public function update(Request $request)
    {
        $request->validate([
            'id'  => 'required|string',
            'qty' => 'required|integer|min:0',
        ]);

        $cart = session('cart', []);
        $productId = $request->input('id');
        $qty = (int) $request->input('qty');

        if ($qty <= 0) {
            unset($cart[$productId]);
        } elseif (isset($cart[$productId])) {
            // Check stock
            $stockLimit = $cart[$productId]['stock'];
            if ($qty > $stockLimit) {
                return back()->with('error', "Stok maksimal yang dapat dibeli adalah {$stockLimit}.");
            }
            $cart[$productId]['qty'] = $qty;
        }

        session(['cart' => $cart]);

        // Recalculate shipping if logistics already set
        $this->recalculateLogistics();

        return back()->with('success', 'Jumlah belanja berhasil diperbarui.');
    }

    /**
     * Hapus produk dari keranjang.
     */
    public function remove(string $productId)
    {
        $cart = session('cart', []);
        unset($cart[$productId]);
        session(['cart' => $cart]);

        // Recalculate shipping if logistics already set
        $this->recalculateLogistics();

        return back()->with('success', 'Produk dihapus dari keranjang.');
    }

    /**
     * Simpan data logistik ke session.
     */
    public function setLogistics(Request $request)
    {
        $request->validate([
            'courier' => 'required|string',
            'address' => 'required|string',
        ]);

        $cart = session('cart', []);
        $totalQty = collect($cart)->sum('qty');
        $hasLargeItem = collect($cart)->some(fn($item) => $item['isLarge'] === true);

        // Simple shipping rates calculation
        $baseRate = 15000;
        if ($request->input('courier') === 'JNE') {
            $baseRate = 20000;
        } else if ($request->input('courier') === 'Pos Indonesia') {
            $baseRate = 12000;
        }

        $cost = $baseRate + ($totalQty * 4000);
        if ($hasLargeItem) {
            $cost += 50000; // Extra heavy charge
        }

        // Mock total weight (each item approx 2kg, large items 15kg)
        $weight = 0;
        foreach ($cart as $item) {
            $weight += $item['qty'] * ($item['isLarge'] ? 15 : 2);
        }

        session([
            'checkout_logistics' => [
                'courier' => $request->input('courier'),
                'address' => $request->input('address'),
                'phone' => '0812-3456-7890', // Default phone fallback
                'cost' => $cost,
                'totalWeight' => $weight,
            ]
        ]);

        return back()->with('success', 'Kurir & alamat pengiriman berhasil disimpan.');
    }

    /**
     * Tampilkan halaman pembayaran setelah logistik diisi.
     */
    public function paymentPage()
    {
        $cart = session('cart', []);
        if (empty($cart)) return redirect()->route('cart.index')->with('error', 'Keranjang kosong.');

        $logistic = session('checkout_logistics');
        if (!$logistic || empty($logistic['address'])) {
            $logistic = [
                'courier' => 'J&T',
                'address' => '',
                'phone' => '',
                'cost' => 0,
                'totalWeight' => collect($cart)->sum(fn($i) => $i['qty'] * ($i['isLarge'] ? 15 : 2)),
            ];
        }

        $bankAccounts = [
            [
                'name' => 'BCA',
                'number' => '012-345-6789',
                'owner' => 'Sinar Abadi Utama'
            ],
        ];

        return Inertia::render('Cart/Payment', [
            'cartItems' => array_values($cart),
            'logistic' => $logistic,
            'bankAccounts' => $bankAccounts,
            'user' => session('auth_user', []),
        ]);
    }

    /**
     * Proses checkout — kirim order ke Go backend.
     */
    public function checkout(Request $request)
    {
        $request->validate([
            'bank' => 'required|string',
            'address' => 'required|string',
            'phone' => 'required|string',
            'courier' => 'required|string',
            'proof' => 'required|file|image|max:4096',
        ]);

        $proofPath = null;
        if ($request->hasFile('proof')) {
            $proofPath = $request->file('proof')->store('proofs', 'public');
        }

        $logistic = [
            'address' => $request->input('address'),
            'phone' => $request->input('phone'),
            'courier' => $request->input('courier'),
        ];

        $cart = session('cart', []);
        if (empty($cart)) {
            return redirect()->route('cart.index')->with('error', 'Keranjang kosong.');
        }

        $items = [];
        foreach ($cart as $item) {
            $items[] = [
                'productId' => $item['id'],
                'name'      => $item['name'],
                'qty'       => $item['qty'],
                'price'     => $item['price'],
            ];
        }

        $subtotal = collect($cart)->sum(fn($item) => $item['price'] * $item['qty']);
        $tax = floor($subtotal * 0.11);
        $totalProduct = $subtotal + $tax;

        $result = $this->api->createOrder(session('auth_token'), [
            'phone'          => $logistic['phone'],
            'address'        => $logistic['address'],
            'shippingMethod' => $logistic['courier'],
            'paymentMethod'  => 'Transfer Bank ' . $request->input('bank'),
            'items'          => $items,
            'total'          => $totalProduct,
        ]);

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Gagal membuat pesanan.';
            return back()->withErrors(['bank' => $error]);
        }

        $orderId = $result['data']['id'] ?? null;
        if ($orderId && $proofPath) {
            $proofUrl = asset('storage/' . $proofPath);
            $this->api->uploadProof(session('auth_token'), $orderId, $proofUrl);
        }

        // Clear session after successful checkout
        session()->forget(['cart', 'checkout_logistics']);

        return redirect()->route('customer.dashboard')->with('success', 'Pesanan berhasil dibuat! Bukti pembayaran Anda sedang diverifikasi.');
    }

    /**
     * Helper to update logistics calculations dynamically if cart contents change.
     */
    private function recalculateLogistics()
    {
        $logistic = session('checkout_logistics');
        if ($logistic && $logistic['address']) {
            $cart = session('cart', []);
            $totalQty = collect($cart)->sum('qty');
            $hasLargeItem = collect($cart)->some(fn($item) => $item['isLarge'] === true);

            $baseRate = 15000;
            if ($logistic['courier'] === 'JNE') {
                $baseRate = 20000;
            } else if ($logistic['courier'] === 'Pos Indonesia') {
                $baseRate = 12000;
            }

            $cost = $baseRate + ($totalQty * 4000);
            if ($hasLargeItem) {
                $cost += 50000;
            }

            $weight = 0;
            foreach ($cart as $item) {
                $weight += $item['qty'] * ($item['isLarge'] ? 15 : 2);
            }

            $logistic['cost'] = $cost;
            $logistic['totalWeight'] = $weight;

            session(['checkout_logistics' => $logistic]);
        }
    }
}
