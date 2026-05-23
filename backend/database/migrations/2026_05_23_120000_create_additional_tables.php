<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add deskripsi to kegiatan if not exists
        if (!Schema::hasColumn('kegiatan', 'deskripsi')) {
            Schema::table('kegiatan', function (Blueprint $table) {
                $table->text('deskripsi')->nullable()->after('nama_kegiatan');
            });
        }

        // Status history for timeline tracking
        Schema::create('status_history', function (Blueprint $table) {
            $table->id();
            $table->string('ref_type')->default('kegiatan');
            $table->unsignedBigInteger('ref_id');
            $table->string('status_lama')->nullable();
            $table->string('status_baru');
            $table->text('catatan')->nullable();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('user_nama')->nullable();
            $table->string('user_role')->nullable();
            $table->timestamps();

            $table->index(['ref_type', 'ref_id']);
        });

        // Jurusan master table
        Schema::create('jurusan', function (Blueprint $table) {
            $table->id();
            $table->string('nama_jurusan');
            $table->string('kode')->nullable();
            $table->timestamps();
        });

        // LPJ table
        Schema::create('lpj', function (Blueprint $table) {
            $table->id();
            $table->foreignId('kegiatan_id')->constrained('kegiatan')->onDelete('cascade');
            $table->text('catatan_pengusul')->nullable();
            $table->text('catatan_verifikasi')->nullable();
            $table->string('status_verifikasi')->default('pending');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lpj');
        Schema::dropIfExists('jurusan');
        Schema::dropIfExists('status_history');

        if (Schema::hasColumn('kegiatan', 'deskripsi')) {
            Schema::table('kegiatan', function (Blueprint $table) {
                $table->dropColumn('deskripsi');
            });
        }
    }
};
