<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rab extends Model
{
    use HasFactory;

    protected $table = 'rab';

    protected $fillable = [
        'kegiatan_id',
        'uraian',
        'kategori',
        'harga_satuan',
        'volume',
        'qty1',
        'satuan1',
        'qty2',
        'satuan2',
        'qty3',
        'satuan3',
        'total',
    ];

    protected function casts(): array
    {
        return [
            'harga_satuan' => 'decimal:2',
            'total' => 'decimal:2',
        ];
    }

    /**
     * Calculate total based on qty1 × qty2 × qty3 × harga_satuan
     */
    public function calculateTotal(): float
    {
        $multiplier = max(1, $this->qty1 ?? 1);
        if ($this->qty2 && $this->qty2 > 0) $multiplier *= $this->qty2;
        if ($this->qty3 && $this->qty3 > 0) $multiplier *= $this->qty3;

        return $multiplier * ($this->harga_satuan ?? 0);
    }

    public function kegiatan()
    {
        return $this->belongsTo(Kegiatan::class);
    }
}
