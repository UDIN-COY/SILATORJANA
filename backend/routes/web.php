<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Serve files from ../data/upload
Route::get('/data/upload/{folder}/{filename}', function ($folder, $filename) {
    $path = base_path('../data/upload/' . $folder . '/' . $filename);
    
    if (!file_exists($path)) {
        abort(404);
    }
    
    return response()->file($path);
})->where('filename', '.*');
