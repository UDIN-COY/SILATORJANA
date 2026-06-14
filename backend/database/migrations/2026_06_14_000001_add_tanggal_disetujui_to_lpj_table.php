<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Tambahkan kolom tanggal_disetujui ke tabel lpj.
     * Digunakan oleh kriteria C4 (Waktu Approval LPJ) pada MOORA Calculator
     * agar skor dihitung dari tanggal submit → tanggal disetujui (statis),
     * bukan dari submit → now() (dinamis/berubah-ubah setiap hari).
     */
    public function up(): void
    {
        Schema::table('lpj', function (Blueprint $table) {
            $table->date('tanggal_disetujui')
                ->nullable()
                ->after('tanggal_pengajuan')
                ->comment('Tanggal LPJ disetujui oleh Bendahara, dipakai oleh SPK C4');
        });
    }

    public function down(): void
    {
        Schema::table('lpj', function (Blueprint $table) {
            $table->dropColumn('tanggal_disetujui');
        });
    }
};
