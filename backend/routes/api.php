<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\KegiatanController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\IkuMasterController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Si-LATORJANA API Routes
|--------------------------------------------------------------------------
*/

// Public routes
Route::post('/login', [AuthController::class, 'login']);

Route::get('/health', function () {
    return response()->json(['status' => 'ok', 'app' => 'Si-LATORJANA Backend']);
});

// Protected routes (require Sanctum token)
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // Kegiatan (Proposals) — full CRUD
    Route::apiResource('kegiatan', KegiatanController::class);

    // Users — admin management
    Route::apiResource('users', UserController::class);

    // IKU Master — admin config
    Route::apiResource('iku-master', IkuMasterController::class);

    // Quick stats for dashboards
    Route::get('/stats', function (Request $request) {
        $user = $request->user();
        $query = \App\Models\Kegiatan::query();

        // If pengusul, only show their own
        if ($user->role === 'pengusul') {
            $query->where('pengusul_id', $user->id);
        }

        return response()->json([
            'total' => (clone $query)->count(),
            'draft' => (clone $query)->where('status', 'draft')->count(),
            'submitted' => (clone $query)->where('status', 'submitted')->count(),
            'verified' => (clone $query)->where('status', 'verified')->count(),
            'approved' => (clone $query)->whereIn('status', ['approved_ppk', 'approved_wadir'])->count(),
            'revision' => (clone $query)->whereIn('status', ['revision_requested', 'revisi'])->count(),
            'rejected' => (clone $query)->whereIn('status', ['rejected', 'ditolak'])->count(),
            'completed' => (clone $query)->whereIn('status', ['completed', 'lpj_done'])->count(),
        ]);
    });

    // Status History — timeline tracking
    Route::get('/status-history/{ref_type}/{ref_id}', function ($refType, $refId) {
        return response()->json(
            \App\Models\StatusHistory::where('ref_type', $refType)
                ->where('ref_id', $refId)
                ->orderBy('created_at', 'asc')
                ->get()
        );
    });

    Route::post('/status-history', function (Request $request) {
        $validated = $request->validate([
            'ref_type' => 'required|string',
            'ref_id' => 'required|integer',
            'status_lama' => 'nullable|string',
            'status_baru' => 'required|string',
            'catatan' => 'nullable|string',
        ]);

        $user = $request->user();
        $validated['user_id'] = $user->id;
        $validated['user_nama'] = $user->nama;
        $validated['user_role'] = $user->role;

        return response()->json(\App\Models\StatusHistory::create($validated), 201);
    });

    // Jurusan (departments)
    Route::get('/jurusan', function () {
        return response()->json(\App\Models\Jurusan::orderBy('nama_jurusan')->get());
    });

    // LPJ
    Route::post('/lpj', function (Request $request) {
        $validated = $request->validate([
            'kegiatan_id' => 'required|integer',
            'catatan_pengusul' => 'nullable|string',
        ]);
        return response()->json(\App\Models\Lpj::create($validated), 201);
    });

    Route::get('/lpj/{kegiatan_id}', function ($kegiatanId) {
        return response()->json(
            \App\Models\Lpj::where('kegiatan_id', $kegiatanId)->first()
        );
    });
});
