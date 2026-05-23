<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rab', function (Blueprint $table) {
            $table->id();
            $table->foreignId('kegiatan_id')->constrained('kegiatan')->onDelete('cascade');
            $table->string('uraian');
            $table->string('kategori')->default('barang'); // barang, jasa, perjalanan, or custom
            $table->decimal('harga_satuan', 15, 2)->default(0);
            $table->integer('volume')->default(1);
            $table->integer('qty1')->default(1);
            $table->string('satuan1')->nullable();
            $table->integer('qty2')->nullable();
            $table->string('satuan2')->nullable();
            $table->integer('qty3')->nullable();
            $table->string('satuan3')->nullable();
            $table->decimal('total', 15, 2)->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rab');
    }
};
