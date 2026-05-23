<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kegiatan extends Model
{
    use HasFactory;

    protected $table = 'kegiatan';

    protected $fillable = [
        'nama_kegiatan',
        'deskripsi',
        'jenis_kegiatan',
        'status',
        'pengusul_id',
        'pengusul_nama',
        'nama_jurusan',
        'tanggal_kegiatan',
        'tempat',
        'total_anggaran',
        'catatan_revisi',
        'surat_pengantar',
    ];

    protected function casts(): array
    {
        return [
            'tanggal_kegiatan' => 'date',
            'total_anggaran' => 'decimal:2',
        ];
    }

    public function pengusul()
    {
        return $this->belongsTo(User::class, 'pengusul_id');
    }

    public function kak()
    {
        return $this->hasOne(Kak::class);
    }

    public function iku()
    {
        return $this->hasMany(Iku::class);
    }

    public function rab()
    {
        return $this->hasMany(Rab::class);
    }
}
