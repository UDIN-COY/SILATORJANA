<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lpj extends Model
{
    protected $table = 'lpj';

    protected $fillable = [
        'kegiatan_id',
        'catatan_pengusul',
        'catatan_verifikasi',
        'status_verifikasi',
    ];

    public function kegiatan()
    {
        return $this->belongsTo(Kegiatan::class);
    }
}
