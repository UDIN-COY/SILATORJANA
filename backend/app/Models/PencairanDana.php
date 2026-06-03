<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PencairanDana extends Model
{
    use HasFactory;

    protected $table = 'pencairan_dana';

    protected $fillable = [
        'kegiatan_id',
        'persentase',
        'nominal',
        'tanggal_pencairan',
        'tanggal_pengambilan',
        'is_taken',
        'catatan',
        'created_by',
    ];

    protected $casts = [
        'persentase' => 'decimal:2',
        'nominal' => 'decimal:2',
        'is_taken' => 'boolean',
        'tanggal_pencairan' => 'datetime',
        'tanggal_pengambilan' => 'datetime',
    ];

    public function kegiatan()
    {
        return $this->belongsTo(Kegiatan::class, 'kegiatan_id');
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
