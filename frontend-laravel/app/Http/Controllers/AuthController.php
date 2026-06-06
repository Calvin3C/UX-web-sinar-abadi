<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;
use Inertia\Inertia;

class AuthController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    public function showCustomerLogin()
    {
        if (session('auth_token')) return $this->redirectByRole(session('auth_role'));
        return Inertia::render('Auth/CustomerLogin');
    }

    public function showCustomerRegister()
    {
        if (session('auth_token')) return $this->redirectByRole(session('auth_role'));
        return Inertia::render('Auth/CustomerRegister');
    }

    public function showAdminLogin()
    {
        if (session('auth_token')) return $this->redirectByRole(session('auth_role'));
        return Inertia::render('Auth/AdminLogin');
    }

    public function showOwnerLogin()
    {
        if (session('auth_token')) return $this->redirectByRole(session('auth_role'));
        return Inertia::render('Auth/OwnerLogin');
    }

    /**
     * Proses login via Go API.
     */
    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
            'role'     => 'required|in:customer,admin,owner',
        ]);

        $result = $this->api->login(
            $request->input('username'),
            $request->input('password'),
            $request->input('role')
        );

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Login gagal. Periksa kembali kredensial Anda.';
            return back()->withErrors(['username' => $error]);
        }

        $data = $result['data'];

        // Store JWT token and user info in session
        session([
            'auth_token'    => $data['token'],
            'auth_user'     => $data['user'],
            'auth_role'     => $data['user']['role'],
            'auth_username' => $data['user']['username'],
            'auth_name'     => $data['user']['name'],
            'auth_user_id'  => $data['user']['id'],
        ]);

        return $this->redirectByRole($data['user']['role'])->with('success', 'Selamat datang kembali!');
    }

    /**
     * Proses registrasi akun baru (Customer/Admin/Owner).
     */
    public function register(Request $request)
    {
        $role = $request->input('role', 'customer');
        
        $rules = [
            'username' => 'required|string|min:3',
            'password' => 'required|string|min:5|confirmed',
            'role'     => 'required|in:customer,admin,owner',
        ];

        if ($role === 'customer') {
            $rules['name']   = 'required|string|min:2';
            $rules['phone']  = 'required|string|max:50';
            $rules['email']  = 'required|email|max:200';
            $rules['gender'] = 'required|string|in:Laki-laki,Perempuan';
        }

        $request->validate($rules);

        $result = $this->api->register(
            $request->input('username'),
            $request->input('password'),
            $role,
            $request->input('name', ''),
            $request->input('phone', ''),
            $request->input('email', ''),
            $request->input('gender', '')
        );

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Registrasi gagal.';
            return back()->withErrors(['username' => $error]);
        }

        return redirect()->route('login')->with('success', 'Akun berhasil terdaftar! Silakan login.');
    }

    public function logout()
    {
        $role = session('auth_role');

        session()->forget([
            'auth_token', 'auth_user', 'auth_role',
            'auth_username', 'auth_name', 'auth_user_id',
            'cart',
        ]);

        if ($role === 'admin') {
            return redirect()->route('admin.login')->with('success', 'Anda telah keluar.');
        } elseif ($role === 'owner') {
            return redirect()->route('owner.login')->with('success', 'Anda telah keluar.');
        }

        return redirect()->route('login')->with('success', 'Anda telah keluar.');
    }

    /**
     * Redirect user ke dashboard sesuai role.
     */
    private function redirectByRole(?string $role)
    {
        return match ($role) {
            'customer' => redirect()->route('customer.dashboard'),
            'admin'    => redirect()->route('admin.dashboard'),
            'owner'    => redirect()->route('owner.dashboard'),
            default    => redirect()->route('home'),
        };
    }
}
