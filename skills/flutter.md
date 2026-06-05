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
| **Backend Target** | Laravel API (`/api`) - Sama dengan Web |
| **Autentikasi** | Laravel Sanctum via HTTP Bearer |
| **State Management** | *(Belum ditentukan, disarankan: Provider atau sekadar StatefulWidget + FutureBuilder untuk fase awal)* |
| **Penyimpanan Lokal** | `flutter_secure_storage` (untuk menyimpan `auth_token` dengan aman) |
| **Iconografi** | `lucide_flutter` (agar seragam dengan web shadcn/ui) |

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

## 3. Struktur Direktori (Standar yang Harus Diikuti)

Agar rapi dan sejalan dengan *best practices* Flutter, berikut adalah struktur folder yang harus diterapkan di dalam folder `lib/`:

```text
lib/
├── main.dart                  # Entry point, Theme config, Route awal
├── core/
│   ├── theme.dart             # Warna utama (Emerald Green), Typography
│   └── constants.dart         # URL API Endpoint (misal: "http://10.0.2.2:8000/api")
├── models/                    # Model data (Kegiatan, User, Iku, dll) dengan fromJson()
├── services/                  # Logika pemanggilan API (HTTP)
│   ├── auth_service.dart      # Login, Logout, get Token dari secure_storage
│   └── api_service.dart       # HTTP Client wrapper (Inject bearer token otomatis)
├── screens/                   # Halaman / UI Utama
│   ├── auth/                  # LoginScreen
│   ├── dashboard/             # DashboardScreen (Home)
│   └── proposal/              # Pengajuan, Detail Proposal, Form KAK
└── widgets/                   # Komponen UI Reusable
    ├── custom_button.dart     # Tombol standar aplikasi
    └── status_badge.dart      # Label status (Draft, Verified, dll)
```

---

## 4. Mekanisme Komunikasi API & Autentikasi

Berbeda dengan web yang menggunakan *cookie/localStorage* + *Vite proxy*, Flutter harus mengatur *header* secara manual.

### A. HTTP Request Flow
1. User login `POST /api/login`.
2. Laravel Sanctum mengembalikan `token`.
3. Flutter menyimpan token ke dalam `flutter_secure_storage`.
4. Setiap request berikutnya (misal: `GET /api/kegiatan`), `api_service.dart` akan menyisipkan header:
   `Authorization: Bearer <token_dari_storage>`.
   `Accept: application/json`.

### B. Konfigurasi Endpoint API Lokal
Ketika *testing* di Android Emulator lokal, Flutter **tidak bisa** mengakses `http://localhost:8000`. Anda harus menggunakan IP bridge bawaan emulator yaitu: `http://10.0.2.2:8000/api`. Jika menggunakan *physical device* (HP asli), gunakan IP WiFi laptop/komputer Anda (misal: `http://192.168.1.5:8000/api`).

---

## 5. Sinkronisasi UI/UX dengan Web

Untuk menjaga konsistensi desain dengan aplikasi web React:
- **Warna Utama (Primary)**: Gunakan nuansa *Emerald Green* (seperti `Colors.teal` atau *custom hex* `#10b981`).
- **Icon**: Hindari icon Material bawaan. Gunakan `LucideIcons` (dari package `lucide_flutter`) persis seperti yang digunakan di web.
- **Card & Border**: Desain web sangat mengandalkan Card putih bersih dengan *border* abu-abu tipis (khas shadcn/ui). Di Flutter, replikasi ini dengan widget `Container` atau `Card` yang memiliki *elevation* sangat rendah (0 atau 1) dan *border* radius tipis (sekitar 8.0).

---

## 6. Cakupan Fitur Mobile (Prioritas Awal)

Mengingat kompleksitas sistem web, aplikasi mobile biasanya ditargetkan untuk **aksi cepat** (Monitoring & Approval), bukan input data massal.

**Target Modul Mobile Fase 1:**
1. **Login & RBAC**: Login dan navigasi sesuai peran (Pengusul, Verifikator, PPK, Wadir, Bendahara).
2. **Dashboard Overview**: Ringkasan jumlah proposal (Menunggu, Disetujui, Ditolak).
3. **Approval System (Pimpinan)**: Fitur bagi Verifikator/PPK/Wadir untuk membuka detail proposal dan langsung mengeklik **Setujui** atau **Minta Revisi** langsung dari HP.
4. **Monitoring (Pengusul)**: Melihat status pergerakan proposal *real-time* tanpa harus membuka laptop.

*(Pembuatan Form KAK, RAB, dan IKU yang panjang disarankan tetap dikerjakan melalui aplikasi Web untuk kenyamanan pengusul, kecuali jika diminta sebaliknya).*

---

## 7. Aturan Penulisan Kode (Linting)

- Gunakan *Null Safety* secara ketat.
- Biasakan memisahkan *logic* pemanggilan HTTP dari *file* UI (`Screen`). Panggil API melalui class di dalam folder `services/`.
- Jangan menyimpan token *auth* di dalam *Shared Preferences* biasa, selalu gunakan `flutter_secure_storage` demi keamanan.
