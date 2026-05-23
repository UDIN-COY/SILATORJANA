<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\IkuMaster;
use Illuminate\Http\Request;

class IkuMasterController extends Controller
{
    public function index()
    {
        return response()->json(IkuMaster::orderBy('created_at', 'desc')->get());
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_indikator' => 'required|string|max:255',
            'is_visible' => 'boolean',
        ]);

        $iku = IkuMaster::create($validated);

        return response()->json($iku, 201);
    }

    public function update(Request $request, string $id)
    {
        $iku = IkuMaster::findOrFail($id);

        $validated = $request->validate([
            'nama_indikator' => 'sometimes|string|max:255',
            'is_visible' => 'boolean',
        ]);

        $iku->update($validated);

        return response()->json($iku);
    }

    public function destroy(string $id)
    {
        IkuMaster::findOrFail($id)->delete();
        return response()->json(['message' => 'IKU Master berhasil dihapus.']);
    }
}
