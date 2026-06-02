<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;
use Inertia\Inertia;

class OwnerController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Dashboard owner — laporan, stok, logistik, admin management.
     */
    public function dashboard(Request $request)
    {
        $token = session('auth_token');

        // Fetch all orders for reports
        $orderResult = $this->api->getOrders($token);
        $orders = $orderResult['success'] ? $orderResult['data'] : [];

        // Fetch all products for stock management
        $productResult = $this->api->getProducts();
        $products = $productResult['success'] ? $productResult['data'] : [];

        // Fetch admins
        $adminResult = $this->api->getAdmins($token);
        $admins = $adminResult['success'] ? $adminResult['data'] : [];

        // Calculate stats
        $completedOrders = array_filter($orders, fn($o) => in_array(strtolower($o['status'] ?? ''), ['success', 'completed']));
        $totalRevenue = collect($completedOrders)->sum('total');
        $stockIssues = count(array_filter($products, fn($p) => ($p['stock'] ?? 0) <= 5));

        return Inertia::render('Owner/Dashboard', [
            'products' => $products,
            'orders' => $orders,
            'admins' => $admins,
            'username' => session('auth_username', 'Owner'),
            'stats' => [
                'totalRevenue' => $totalRevenue,
                'salesCount' => count($completedOrders),
                'stockIssuesCount' => $stockIssues,
                'totalAdmins' => count($admins),
            ],
        ]);
    }

    /**
     * Update status pesanan (validasi pembayaran).
     */
    public function updateStatus(Request $request, string $orderId)
    {
        $token = session('auth_token');
        $result = $this->api->updateOrderStatus($token, $orderId, [
            'status' => $request->input('status'),
        ]);

        if (!$result['success']) {
            return back()->with('error', 'Gagal memperbarui status.');
        }

        return back()->with('success', 'Status pesanan berhasil diperbarui.');
    }


    /**
     * Update stok produk.
     */
    public function updateStock(Request $request, string $productId)
    {
        $request->validate(['amount' => 'required|integer']);
        $token = session('auth_token');

        $result = $this->api->updateStock($token, $productId, $request->input('amount'));

        if (!$result['success']) {
            return back()->with('error', 'Gagal memperbarui stok.');
        }

        return back()->with('success', $result['data']['message'] ?? 'Stok berhasil diperbarui.');
    }


    /**
     * Buat akun admin baru.
     */
    public function createAdmin(Request $request)
    {
        $request->validate([
            'username' => 'required|string|min:3',
            'password' => 'required|string|min:3',
            'name'     => 'required|string|min:2',
        ]);

        $token = session('auth_token');
        $result = $this->api->createAdmin($token, $request->only('username', 'password', 'name'));

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Gagal membuat akun admin.';
            return back()->with('error', $error);
        }

        return back()->with('success', 'Akun admin berhasil dibuat.');
    }

    /**
     * Hapus akun admin.
     */
    public function deleteAdmin(string $username)
    {
        $token = session('auth_token');
        $result = $this->api->deleteAdmin($token, $username);

        if (!$result['success']) {
            return back()->with('error', 'Gagal menghapus admin.');
        }

        return back()->with('success', 'Akun admin berhasil dihapus.');
    }

    /**
     * Tampilkan form tambah produk baru.
     */
    public function createProduct()
    {
        $token = session('auth_token');
        $productResult = $this->api->getProducts();
        $categories = collect($productResult['success'] ? $productResult['data'] : [])
            ->pluck('category')
            ->unique()
            ->values()
            ->all();

        return Inertia::render('Owner/ProductForm', [
            'mode' => 'create',
            'product' => null,
            'categories' => $categories,
            'username' => session('auth_username', 'Owner'),
        ]);
    }

    /**
     * Tampilkan form edit produk.
     */
    public function editProduct(string $productId)
    {
        $token = session('auth_token');
        $result = $this->api->getProductById($token, $productId);

        if (!$result['success']) {
            return redirect()->route('owner.dashboard')->with('error', 'Produk tidak ditemukan.');
        }

        $productResult = $this->api->getProducts();
        $categories = collect($productResult['success'] ? $productResult['data'] : [])
            ->pluck('category')
            ->unique()
            ->values()
            ->all();

        return Inertia::render('Owner/ProductForm', [
            'mode' => 'edit',
            'product' => $result['data'],
            'categories' => $categories,
            'username' => session('auth_username', 'Owner'),
        ]);
    }

    /**
     * Simpan produk baru.
     */
    public function storeProduct(Request $request)
    {
        $request->validate([
            'id'         => 'required|string',
            'name'       => 'required|string',
            'category'   => 'required|string',
            'price'      => 'required|integer|min:0',
            'stock'      => 'required|integer|min:0',
            'photo_main' => 'nullable|file|image|max:4096',
            'photo_1'    => 'nullable|file|image|max:4096',
            'photo_2'    => 'nullable|file|image|max:4096',
            'photo_3'    => 'nullable|file|image|max:4096',
            'photo_4'    => 'nullable|file|image|max:4096',
            'photo_5'    => 'nullable|file|image|max:4096',
        ]);

        // Handle photo uploads
        $imgUrl = '';
        if ($request->hasFile('photo_main')) {
            $path = $request->file('photo_main')->store('products', 'public');
            $imgUrl = asset('storage/' . $path);
        }

        // Store additional photos (for future use)
        $additionalPhotos = [];
        foreach (['photo_1', 'photo_2', 'photo_3', 'photo_4', 'photo_5'] as $photoField) {
            if ($request->hasFile($photoField)) {
                $path = $request->file($photoField)->store('products', 'public');
                $additionalPhotos[] = asset('storage/' . $path);
            }
        }

        $token = session('auth_token');
        $result = $this->api->createProduct($token, [
            'id'       => $request->input('id'),
            'name'     => $request->input('name'),
            'category' => $request->input('category'),
            'price'    => (int) $request->input('price'),
            'stock'    => (int) $request->input('stock'),
            'isLarge'  => (bool) $request->input('isLarge', false),
            'img'      => $imgUrl,
        ]);

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Gagal menambahkan produk.';
            return back()->withErrors(['id' => $error]);
        }

        return redirect()->route('owner.dashboard')->with('success', 'Produk berhasil ditambahkan.');
    }

    /**
     * Update produk yang sudah ada.
     */
    public function updateProduct(Request $request, string $productId)
    {
        $request->validate([
            'name'       => 'required|string',
            'category'   => 'required|string',
            'price'      => 'required|integer|min:0',
            'photo_main' => 'nullable|file|image|max:4096',
            'photo_1'    => 'nullable|file|image|max:4096',
            'photo_2'    => 'nullable|file|image|max:4096',
            'photo_3'    => 'nullable|file|image|max:4096',
            'photo_4'    => 'nullable|file|image|max:4096',
            'photo_5'    => 'nullable|file|image|max:4096',
        ]);

        // Handle main photo upload
        $imgUrl = $request->input('img', '');
        if ($request->hasFile('photo_main')) {
            $path = $request->file('photo_main')->store('products', 'public');
            $imgUrl = asset('storage/' . $path);
        }

        // Store additional photos (for future use)
        foreach (['photo_1', 'photo_2', 'photo_3', 'photo_4', 'photo_5'] as $photoField) {
            if ($request->hasFile($photoField)) {
                $request->file($photoField)->store('products', 'public');
            }
        }

        $token = session('auth_token');
        $result = $this->api->updateProduct($token, $productId, [
            'name'     => $request->input('name'),
            'category' => $request->input('category'),
            'price'    => (int) $request->input('price'),
            'isLarge'  => (bool) $request->input('isLarge', false),
            'img'      => $imgUrl,
        ]);

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Gagal memperbarui produk.';
            return back()->withErrors(['name' => $error]);
        }

        return redirect()->route('owner.dashboard')->with('success', 'Produk berhasil diperbarui.');
    }
}
