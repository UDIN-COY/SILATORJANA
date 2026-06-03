<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kak extends Model
{
    use HasFactory;

    protected $table = 'kak';

    protected $fillable = [
        'kegiatan_id',
        'gambaran_umum',
        'penerima_manfaat',
        'strategi_pencapaian',
        'metode_pelaksanaan',
        'tahapan_pelaksanaan',
        'indikator_kinerja',
        'kurun_waktu_mulai',
        'kurun_waktu_selesai',
        'file_kak',
    ];

    protected function casts(): array
    {
        return [
            'kurun_waktu_mulai' => 'date',
            'kurun_waktu_selesai' => 'date',
        ];
    }

    public function kegiatan()
    {
        return $this->belongsTo(Kegiatan::class);
    }
}
