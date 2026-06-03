<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kegiatan', function (Blueprint $table) {
            if (!Schema::hasColumn('kegiatan', 'pengusul_organisasi')) {
                $table->string('pengusul_organisasi')->nullable()->after('pengusul_nama');
            }
        });
    }

    public function down(): void
    {
        Schema::table('kegiatan', function (Blueprint $table) {
            if (Schema::hasColumn('kegiatan', 'pengusul_organisasi')) {
                $table->dropColumn('pengusul_organisasi');
            }
        });
    }
};
