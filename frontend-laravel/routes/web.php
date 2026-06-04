<?php

use App\Http\Controllers\HomeController;
use App\Http\Controllers\CatalogController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\OwnerController;
use Illuminate\Support\Facades\Route;

// =====================================================================
// PUBLIC ROUTES (redirect admin/owner to their dashboards)
// =====================================================================

Route::get('/', function () {
    $role = session('auth_role');
    if ($role === 'admin') return redirect()->route('admin.dashboard');
    if ($role === 'owner') return redirect()->route('owner.dashboard');
    return app(HomeController::class)->index();
})->name('home');

Route::get('/katalog', function (\Illuminate\Http\Request $request) {
    $role = session('auth_role');
    if ($role === 'admin') return redirect()->route('admin.dashboard');
    if ($role === 'owner') return redirect()->route('owner.dashboard');
    return app(CatalogController::class)->index($request);
})->name('katalog');

Route::get('/katalog/{id}', [CatalogController::class, 'show'])->name('katalog.show');

// Auth
Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
Route::post('/login', [AuthController::class, 'login'])->name('login.process');
Route::post('/register', [AuthController::class, 'register'])->name('register.process');
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// =====================================================================
// CART (Customer, session-based + API checkout)
// =====================================================================
Route::middleware('auth.api:customer')->group(function () {
    Route::get('/cart', [CartController::class, 'index'])->name('cart.index');
    Route::post('/cart/add', [CartController::class, 'add'])->name('cart.add');
    Route::post('/cart/update', [CartController::class, 'update'])->name('cart.update');
    Route::delete('/cart/{productId}', [CartController::class, 'remove'])->name('cart.remove');
    
    // New Logistic & Payment Flow
    Route::post('/cart/set-logistics', [CartController::class, 'setLogistics'])->name('cart.setLogistics');
    Route::get('/cart/payment', [CartController::class, 'paymentPage'])->name('cart.payment');
    Route::post('/checkout', [CartController::class, 'checkout'])->name('cart.checkout');
});

// =====================================================================
// CUSTOMER DASHBOARD
// =====================================================================
Route::middleware('auth.api:customer')->prefix('customer')->name('customer.')->group(function () {
    Route::get('/dashboard', [CustomerController::class, 'dashboard'])->name('dashboard');
    Route::post('/orders/{id}/proof', [CustomerController::class, 'uploadProof'])->name('upload-proof');
    Route::put('/orders/{id}/complete', [CustomerController::class, 'completeOrder'])->name('complete-order');
    Route::get('/tracking', [CustomerController::class, 'trackOrder'])->name('tracking');
});

// =====================================================================
// ADMIN DASHBOARD
// =====================================================================
Route::middleware('auth.api:admin')->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('dashboard');
    Route::put('/users/{username}/block', [AdminController::class, 'toggleBlock'])->name('toggle-block');
    Route::put('/orders/{id}/shipping', [AdminController::class, 'updateShipping'])->name('update-shipping');
});

// =====================================================================
// OWNER DASHBOARD
// =====================================================================
Route::middleware('auth.api:owner')->prefix('owner')->name('owner.')->group(function () {
    Route::get('/dashboard', [OwnerController::class, 'dashboard'])->name('dashboard');
    Route::put('/orders/{id}/status', [OwnerController::class, 'updateStatus'])->name('update-status');
    Route::put('/products/{id}/stock', [OwnerController::class, 'updateStock'])->name('update-stock');
    Route::post('/admins', [OwnerController::class, 'createAdmin'])->name('create-admin');
    Route::delete('/admins/{username}', [OwnerController::class, 'deleteAdmin'])->name('delete-admin');

    // Product CRUD
    Route::get('/products/create', [OwnerController::class, 'createProduct'])->name('products.create');
    Route::post('/products', [OwnerController::class, 'storeProduct'])->name('products.store');
    Route::get('/products/{id}/edit', [OwnerController::class, 'editProduct'])->name('products.edit');
    Route::put('/products/{id}', [OwnerController::class, 'updateProduct'])->name('products.update');
});
