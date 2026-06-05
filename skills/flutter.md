---
name: "silatorjana-flutter-skill"
description: "Sistem Layanan Terpadu Administrasi Pengajuan (Si-LATORJANA) - Mobile App Reference (Flutter)"
---

# Si-LATORJANA Mobile (Flutter) — Ultimate Skill Document

> **Tujuan**: Dokumen referensi utama dan terlengkap untuk memandu pengembangan aplikasi mobile Si-LATORJANA menggunakan framework Flutter. Dokumen ini setara dengan `skill.md` namun difokuskan 100% pada ekosistem mobile (`silatorjana_flutter`).

---

## 1. Overview Proyek Mobile

**Si-LATORJANA Mobile** adalah *companion app* untuk platform web Si-LATORJANA. Aplikasi ini berkomunikasi dengan backend yang sama (Laravel API) yang berada di port `8000` (atau IP/Domain server). 

| Aspek | Implementasi Mobile |
|---|---|
| **Lokasi Proyek** | `./silatorjana_flutter/` (Di dalam root proyek) |
| **Framework** | Flutter (Stable) + Dart |
| **Arsitektur** | Feature-First + MVVM |
| **Backend Target** | Laravel API (`/api`) - Sama dengan Web |
| **Autentikasi** | Laravel Sanctum via HTTP Bearer |
| **State Management** | `provider` (MultiProvider) + ChangeNotifier |
| **Penyimpanan Lokal** | `flutter_secure_storage` (untuk menyimpan `auth_token` dengan aman) |
| **Iconografi** | `lucide_icons_flutter` (agar seragam dengan web shadcn/ui) |

---

## 2. Cara Menjalankan Aplikasi

Pastikan backend Laravel sedang berjalan (biasanya di `localhost:8000`).

```bash
# Pastikan Anda berada di direktori Flutter
cd silatorjana_flutter

# Mengunduh dependencies
flutter pub get
```

Jika menggunakan Emulator Android (lokal), IP localhost backend Laravel adalah `10.0.2.2`, BUKAN `127.0.0.1` atau `localhost`.
```bash
# Menjalankan di perangkat/emulator yang terhubung
flutter run
```

---

## 3. Struktur Direktori (Standar Feature-First MVVM)

Aplikasi ini menggunakan arsitektur **Feature-First + MVVM**. Jangan membuat folder berdasarkan tipe file (seperti `views/`, `controllers/`, `models/` di *root* `lib/`), melainkan kelompokkan berdasarkan fiturnya.

```text
lib/
├── core/                      # Modul dasar yang dipakai lintas fitur
│   ├── constants/
│   │   ├── api_config.dart    # Endpoint URL Backend
│   │   └── app_colors.dart
│   ├── network/
│   │   └── api_service.dart   # Base HTTP Client (Inject Bearer token)
│   └── utils/
├── features/                  # Fitur-fitur aplikasi (Feature-First)
│   ├── auth/                  # Fitur Autentikasi
│   │   ├── models/            # Model data (misal: user.dart)
│   │   ├── services/          # Koneksi ke API/Storage (auth_service.dart)
│   │   ├── viewmodels/        # Logika bisnis reaktif via Provider (auth_viewmodel.dart)
│   │   └── views/             # UI murni (login_view.dart)
│   ├── kegiatan/              # Fitur Pengajuan & Monitoring Kegiatan
│   │   ├── models/
│   │   ├── services/
│   │   ├── viewmodels/
│   │   └── views/
│   └── chat/                  # Fitur Jana AI Chatbot
│       ├── viewmodels/
│       └── views/
└── main.dart                  # Entry point, Theme config, MultiProvider
```

**Aturan Emas Feature-First:** 
1. **Views**: Hanya boleh berisi Widget UI murni. Tidak boleh ada pemanggilan API langsung atau *business logic* rumit. Dapatkan data melalui `context.read<MyViewModel>()` atau gunakan `ListenableBuilder`.
2. **ViewModels**: Tempat seluruh *business logic*. Harus inherit dari `ChangeNotifier`. Memanggil service, mengolah data, dan memberitahu UI dengan `notifyListeners()`.
3. **Services**: Murni hanya untuk melakukan request jaringan, membaca disk lokal (seperti biometric_service), dsb.

---

## 4. Mekanisme Komunikasi API & Autentikasi

### A. HTTP Request Flow
1. User login `POST /api/login`.
2. Laravel Sanctum mengembalikan `token`.
3. Flutter menyimpan token ke dalam `flutter_secure_storage`.
4. Setiap request berikutnya, `api_service.dart` akan menyisipkan header:
   `Authorization: Bearer <token_dari_storage>`
   `Accept: application/json`.

### B. Konfigurasi Endpoint API Lokal
Ketika *testing* di Android Emulator lokal, Flutter **tidak bisa** mengakses `http://localhost:8000`. Anda harus menggunakan IP bridge bawaan emulator yaitu: `http://10.0.2.2:8000/api`. Jika menggunakan *physical device* (HP asli), gunakan IP WiFi komputer server.

---

## 5. Sinkronisasi UI/UX dengan Web

Untuk menjaga konsistensi desain dengan aplikasi web React:
- **Warna Utama (Primary)**: Gunakan nuansa *Emerald Green* (Hex `#047857` atau `Colors.teal`).
- **Icon**: Gunakan package `lucide_icons_flutter` agar ikon setara persis dengan *lucide-react* di web.
- **Card & Border**: Desain web mengandalkan *Card* putih bersih dengan *border* tipis (shadcn/ui style). Replikasi ini menggunakan `Card` dengan elevation 1 dan `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))`.

---

## 6. Cakupan Fitur Mobile (Prioritas Awal)

Aplikasi mobile ditargetkan untuk **aksi cepat** (Monitoring & Approval), bukan input form massal.

**Target Modul Mobile Fase 1:**
1. **Login & Biometric**: Mendukung login manual dan Biometric Token (Fingerprint/FaceID).
2. **Dashboard Overview**: Ringkasan jumlah proposal.
3. **Approval System (Pimpinan)**: Verifikator/PPK/Wadir dapat membuka detail proposal lalu klik **Setujui** / **Minta Revisi** langsung dari HP.
4. **Monitoring (Pengusul)**: Melihat status pergerakan proposal.
5. **Jana AI (Chatbot)**: Integrasi asisten AI langsung dari mobile.

---

## 7. Aturan Penulisan Kode (Linting)

- **Null Safety**: Wajib.
- **Deprekasi**: Dilarang memakai API usang. Contoh: gunakan `Color.withValues(alpha: ...)` alih-alih `Color.withOpacity()`.
- Jangan menggunakan `BuildContext` melintasi *asynchronous gaps* (`await`). Selalu periksa `if (!mounted) return;` sesudah `await`.
- Selalu pisahkan *logic* ke **ViewModel**, jangan taruh di dalam fungsi tombol UI.
- Semua package harus versi terbaru (hindari package lawas yang bentrok dengan *strict enforcement* di Flutter 3.24+, seperti konflik kelas `IconData` final).
