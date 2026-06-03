<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('kegiatan', function (Blueprint $table) {
            $table->string('kode_mak', 100)->nullable()->after('verifikator_target');
            $table->json('penanggung_jawab')->nullable()->after('kode_mak');
            $table->string('surat_pengantar_filename')->nullable()->after('surat_pengantar');
            $table->string('surat_pengantar_path')->nullable()->after('surat_pengantar_filename');
            $table->timestamp('surat_pengantar_uploaded_at')->nullable()->after('surat_pengantar_path');
            $table->boolean('uang_muka_diambil')->default(false)->after('surat_pengantar_uploaded_at');
            $table->date('deadline_lpj')->nullable()->after('uang_muka_diambil');
            $table->unsignedBigInteger('approved_by')->nullable()->after('deadline_lpj');

            $table->foreign('approved_by')->references('id')->on('users')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kegiatan', function (Blueprint $table) {
            $table->dropForeign(['approved_by']);
            $table->dropColumn([
                'kode_mak',
                'penanggung_jawab',
                'surat_pengantar_filename',
                'surat_pengantar_path',
                'surat_pengantar_uploaded_at',
                'uang_muka_diambil',
                'deadline_lpj',
                'approved_by'
            ]);
        });
    }
};
