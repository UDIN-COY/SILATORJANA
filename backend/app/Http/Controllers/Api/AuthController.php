<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Login — returns user data
     * When Sanctum is installed, this will also return an API token.
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        // If Sanctum is available, create token
        $token = null;
        if (method_exists($user, 'createToken')) {
            $user->tokens()->delete();
            $token = $user->createToken('auth-token')->plainTextToken;
        }

        return response()->json([
            'user' => $user,
            'token' => $token,
        ]);
    }

    /**
     * Logout
     */
    public function logout(Request $request)
    {
        if ($request->user() && method_exists($request->user(), 'currentAccessToken')) {
            $request->user()->currentAccessToken()->delete();
        }

        return response()->json(['message' => 'Berhasil logout.']);
    }

    /**
     * Get authenticated user
     */
    public function me(Request $request)
    {
        return response()->json(['user' => $request->user()]);
    }
}
