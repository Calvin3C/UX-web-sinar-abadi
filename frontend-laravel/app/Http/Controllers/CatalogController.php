<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;
use Inertia\Inertia;

class CatalogController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Halaman Katalog Lengkap — dengan search, filter, dan sorting.
     */
    public function index(Request $request)
    {
        $filters = [
            'search'   => $request->input('search', ''),
            'category' => $request->input('category', 'all'),
            'sort'     => $request->input('sort', 'rekomendasi'),
        ];

        $result = $this->api->getProducts(array_filter($filters));
        $products = $result['success'] ? $result['data'] : [];

        // Extract unique categories for the filter dropdown
        $allResult = $this->api->getProducts();
        $allProducts = $allResult['success'] ? $allResult['data'] : [];
        $categories = collect($allProducts)->pluck('category')->unique()->sort()->values()->all();

        // Simple server-side pagination
        $page = max(1, (int) $request->input('page', 1));
        $perPage = 12;
        $total = count($products);
        $totalPages = max(1, (int) ceil($total / $perPage));
        $page = min($page, $totalPages);
        $paginatedProducts = array_slice($products, ($page - 1) * $perPage, $perPage);

        return Inertia::render('Katalog', [
            'paginatedProducts' => $paginatedProducts,
            'categories' => $categories,
            'page' => $page,
            'totalPages' => $totalPages,
            'total' => $total,
            'filters' => $filters,
        ]);
    }

    /**
     * Halaman Detail Produk
     */
    public function show(string $id)
    {
        $role = session('auth_role');
        if ($role === 'admin') return redirect()->route('admin.dashboard');
        if ($role === 'owner') return redirect()->route('owner.dashboard');

        $result = $this->api->getProductById($id);
        
        if (!$result['success'] || empty($result['data'])) {
            abort(404, 'Produk tidak ditemukan');
        }

        return Inertia::render('ProductDetail', [
            'product' => $result['data']
        ]);
    }
}
