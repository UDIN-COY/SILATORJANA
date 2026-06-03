<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kak', function (Blueprint $table) {
            if (!Schema::hasColumn('kak', 'indikator_kinerja')) {
                $table->text('indikator_kinerja')->nullable()->after('tahapan_pelaksanaan');
            }
        });
    }

    public function down(): void
    {
        Schema::table('kak', function (Blueprint $table) {
            if (Schema::hasColumn('kak', 'indikator_kinerja')) {
                $table->dropColumn('indikator_kinerja');
            }
        });
    }
};
