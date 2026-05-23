<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kak', function (Blueprint $table) {
            $table->id();
            $table->foreignId('kegiatan_id')->constrained('kegiatan')->onDelete('cascade');
            $table->text('gambaran_umum')->nullable();
            $table->text('penerima_manfaat')->nullable();
            $table->text('strategi_pencapaian')->nullable();
            $table->text('metode_pelaksanaan')->nullable();
            $table->text('tahapan_pelaksanaan')->nullable();
            $table->date('kurun_waktu_mulai')->nullable();
            $table->date('kurun_waktu_selesai')->nullable();
            $table->string('file_kak')->nullable(); // file path
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('kak');
    }
};
