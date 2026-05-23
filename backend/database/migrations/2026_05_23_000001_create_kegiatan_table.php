<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kegiatan', function (Blueprint $table) {
            $table->id();
            $table->string('nama_kegiatan');
            $table->string('jenis_kegiatan')->nullable(); // rutin, non-rutin, etc.
            $table->string('status')->default('draft');
            // Status: draft, submitted, verified, pending_ppk, approved_ppk, approved_wadir,
            //         accepted_funds, funds_disbursed, lpj_submitted, lpj_approved, lpj_done,
            //         completed, revision_requested, revisi, rejected, ditolak, lpj_revision, lpj_rejected

            $table->foreignId('pengusul_id')->constrained('users')->onDelete('cascade');
            $table->string('pengusul_nama')->nullable();
            $table->string('nama_jurusan')->nullable();

            $table->date('tanggal_kegiatan')->nullable();
            $table->string('tempat')->nullable();
            $table->decimal('total_anggaran', 15, 2)->default(0);
            $table->text('catatan_revisi')->nullable();

            $table->string('surat_pengantar')->nullable(); // file path
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('kegiatan');
    }
};
