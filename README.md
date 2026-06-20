# Si-LATORJANA

<div align="center">
  <img src="https://img.shields.io/badge/TypeScript-40.3%25-blue?style=flat-square&logo=typescript" alt="TypeScript">
  <img src="https://img.shields.io/badge/Dart-33.4%25-0175C2?style=flat-square&logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/PHP-10.5%25-777BB4?style=flat-square&logo=php" alt="PHP">
  <img src="https://img.shields.io/badge/License-AGPL--3.0-blue?style=flat-square&logo=gnu" alt="License">
  <img src="https://img.shields.io/github/stars/UDIN-COY/SILATORJANA?style=flat-square&logo=github" alt="Stars">
</div>

---

## 📋 About Si-LATORJANA

**Si-LATORJANA** (*Sistem Layanan Terpadu Administrasi Pengajuan*) is a campus activity-proposal administration system built for **Politeknik Negeri Jakarta (PNJ)**. It digitizes the full lifecycle of a kampus activity proposal — from submission, multi-level approval, fund disbursement, all the way to accountability reporting (LPJ) — across a **web dashboard**, a **mobile app**, and a shared **Laravel API**.

Unlike a generic CRUD app, the core of the system is a strict **role-based approval workflow**: a proposal moves sequentially through *Pengusul → Verifikator → PPK → Wadir → Bendahara → Rektorat*, with every status change automatically logged and snapshotted for audit purposes.

### Key Highlights
- 🔁 **Multi-level approval workflow** with 8 distinct roles and a locked status state-machine
- 📝 **Integrated proposal form** — KAK, RAB (auto-calculated budget), and dynamic IKU indicators
- 💰 **Staged fund disbursement** (bendahara can release funds in percentages, not just all-or-nothing)
- 📊 **LPJ comparative verification** — planned budget (RAB) vs. realized expenses, with variance
- 🧮 **Automated LPJ quality grading** using the **SPK MOORA** decision-support method (Grade A–D)
- 🖨️ **PDF proposal export** with Indonesian number-to-words ("Terbilang") conversion
- 🤖 **"Jana" AI Assistant** — in-app chatbot for help with the submission flow (via OpenRouter)
- 🔐 **Sanctum token auth** with optional biometric login on mobile
- 📱 **Native mobile companion app** built with Flutter (Feature-First MVVM)

---

## 🛠 Technology Stack

### Frontend Web (`/`)
| Technology | Purpose | Version |
|-----------|---------|---------|
| **React** | UI library | 19.0.1 |
| **TypeScript** | Type-safe development | ~5.8.2 |
| **Vite** | Build tool & dev server | 6.2.3 |
| **Tailwind CSS** | Utility-first styling | 4.1.14 |
| **shadcn/ui** + **Base UI** | Component primitives | — |
| **React Router** | Client-side routing | 7.15.0 |
| **Motion** | Animations | 12.23.24 |
| **React Markdown** + **remark-gfm** | Markdown rendering (Jana chat) | 10.1.0 |
| **React Joyride** | Onboarding / guided tours | 3.1.0 |
| **@google/genai** | AI SDK dependency | 1.29.0 |

### Mobile (`/silatorjana_flutter`)
| Technology | Purpose |
|-----------|---------|
| **Flutter / Dart** | Cross-platform app (Android, iOS, also builds for Linux/macOS/Windows/Web) |
| **Provider** | State management (Feature-First MVVM architecture) |
| **flutter_secure_storage** | Secure Bearer-token storage on device |
| **lucide_icons_flutter** | Icon set matching the web UI |

### Backend (`/backend`)
| Technology | Purpose | Version |
|-----------|---------|---------|
| **Laravel** | API framework | ^13.8 |
| **PHP** | Language | ^8.3 |
| **Laravel Sanctum** | Token-based API authentication | ^4.3 |
| **MySQL / MariaDB** | Database | 8.0+ |
| **Laravel Pail** | Real-time log viewer (dev) | — |

> The project previously used Appwrite + OpenRouter as a BaaS layer; this has since been **fully migrated off Appwrite**, and the backend is now 100% Laravel + MySQL.

---

## 👥 Roles & Approval Workflow

The system enforces strict **Role-Based Access Control**. Each role has a deliberately limited set of actions — only the Verifikator can outright reject a proposal; everyone downstream can only request a revision or approve.

| Role | Responsibility |
|---|---|
| `admin` | User management, IKU master data, system-wide monitoring |
| `pengusul` | Creates proposals (student/lecturer/department), revises, uploads LPJ |
| `verifikator` | First gate — checks completeness; the **only** role that can outright **reject** |
| `ppk` | Reviews proposals that passed verification; can request revision or approve |
| `wadir1`–`wadir4` | Vice-director final approval, routed by the proposer's department/unit |
| `bendahara` | Disburses funds (can be staged/partial) and approves/rejects LPJ |
| `rektorat` | Institution-level monitoring, recap reports, and timelines |

### Proposal Lifecycle
```
draft → submitted → (verifikator: revision_requested | rejected | pending_ppk)
      → pending_ppk → (ppk: revision_requested | approved_ppk)
      → approved_ppk → (wadir: revision_requested | approved_wadir)
      → approved_wadir → accepted_funds → funds_disbursed
      → lpj_submitted → (bendahara: lpj_revision | lpj_approved / lpj_done)
```
Every transition is recorded in `status_histories`, including a JSON `payload_snapshot` of the proposal at the moment of approval — preventing data from being altered retroactively after sign-off.

---

## ✨ Core Features

<table>
  <tr>
    <td width="50%">
      <h3>📝 Proposal Submission (Pengusul)</h3>
      <ul>
        <li>Integrated form: KAK, RAB (auto-calculates qty × harga), dynamic IKU</li>
        <li>Strict frontend validation — can't skip tabs, no past dates</li>
        <li>One-click PDF export with "Terbilang" amount-to-words</li>
        <li>Full status history with tamper-evident snapshots</li>
      </ul>
    </td>
    <td width="50%">
      <h3>✅ Approval Chain</h3>
      <ul>
        <li>Conditional action buttons per role/status</li>
        <li>Multi-Wadir routing based on department/unit</li>
        <li>"Smart Archive" views for PPK and Wadir</li>
        <li>Actions auto-hidden when viewing archived items</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>💰 Finance (Bendahara)</h3>
      <ul>
        <li>Staged/partial fund disbursement</li>
        <li>RAB (plan) vs. realization comparison with variance</li>
        <li>SPK/MOORA-based LPJ quality grading (A–D)</li>
        <li>Attached LPJ documents & receipts</li>
      </ul>
    </td>
    <td width="50%">
      <h3>📊 Monitoring & AI</h3>
      <ul>
        <li>Universal monitoring dashboard across roles</li>
        <li>"Jana" AI assistant chatbot (OpenRouter-backed)</li>
        <li>Biometric login support (mobile)</li>
        <li>Guided product tour (React Joyride)</li>
      </ul>
    </td>
  </tr>
</table>

---

## 🚀 Getting Started

### Requirements
- **Node.js** 18+
- **PHP** 8.3+ and **Composer**
- **MySQL/MariaDB** 8.0+ (or Docker, see below)
- **Flutter SDK** 3.0+ (only needed for the mobile app)

### 1. Clone
```bash
git clone https://github.com/UDIN-COY/SILATORJANA.git
cd SILATORJANA
```

### 2. Backend (Laravel API)
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
# set DB_DATABASE, DB_USERNAME, DB_PASSWORD in .env (default DB name: silatorjana)
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000
```

### 3. Frontend (React web)
```bash
# from project root
npm install
npm run dev:frontend     # Vite dev server only (default http://localhost:5173)
```

### 4. Run both together
```bash
# from project root — starts Vite + runs migrations + starts Laravel concurrently
npm run dev
```
The Vite dev server proxies `/api` and `/data/upload` to `http://localhost:8000` (see `vite.config.ts`), so no separate API base URL config is needed in dev.

### 5. Mobile app (Flutter)
```bash
cd silatorjana_flutter
flutter pub get
flutter run
```

### Alternative: Docker (backend only)
A `docker-compose.yml` is provided to run Laravel + MySQL without touching a local PHP install:
```bash
docker compose up -d
docker compose exec app composer install --no-interaction --prefer-dist
docker compose exec app cp .env.example .env
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate --force --seed
```
See `README_DEV.md` for the full Docker walkthrough.

---

## 📁 Project Structure

```
SILATORJANA/
├── src/                          # React web frontend
│   ├── pages/                    # Pages grouped by role
│   │   ├── admin/  pengusul/  verifikator/  ppk/
│   │   ├── wadir/  bendahara/  rektorat/  approval/  dashboard/  shared/
│   ├── layouts/                  # RoleLayout (sidebar/topbar, role-aware nav)
│   ├── lib/                      # api.ts (axios + auth interceptor), helpers
│   └── components/                # Reusable UI (shadcn-based)
│
├── backend/                      # Laravel API
│   ├── app/Http/Controllers/Api/ # AuthController, KegiatanController, LpjController, SpkController, UserController...
│   ├── app/Http/Middleware/      # CheckRole (RBAC guard)
│   ├── app/Models/                # Kegiatan, Kak, Iku, Rab, RabRealisasi, Lpj, LpjFile,
│   │                               # PencairanDana, SpkKriteria, SpkPenilaian, StatusHistory, User, Jurusan
│   ├── database/migrations/
│   └── routes/api.php
│
├── silatorjana_flutter/          # Flutter mobile app (Feature-First MVVM)
│   └── lib/features/
│       ├── auth/  kegiatan/  lpj/  bendahara/  chat/
│       └── documents/  master_data/  monitoring/  profile/  user_management/
│
├── docker-compose.yml             # Laravel + MySQL containers
├── README_DEV.md                  # Docker dev environment guide
└── skills/skill.md                # Full internal architecture reference
```

---

## 🗄️ Database Overview

Central table is `kegiatan` (the activity proposal), related to:
- `kaks` (1:1) — KAK: general description, strategy, KPIs, timing
- `ikus` (1:N) — IKU: percentage-based key performance indicators
- `rabs` (1:N) — planned budget line items (category, price, qty)
- `rab_realisasi` — actual/realized spending, compared against `rabs`
- `status_histories` (1:N) — every status change, auto-logged via an Eloquent Observer, including a JSON snapshot
- `lpjs` / `lpj_files` — accountability reports and their attachments
- `pencairan_dana` — fund disbursement records (supports partial/staged release)
- `spk_kriteria` / `spk_penilaian` — MOORA criteria & computed LPJ quality scores
- `users` — bcrypt-hashed passwords, bound to a `role` column, with optional biometric login fields

---

## 📚 API Overview

Base URL (dev): `http://localhost:8000/api`

| Endpoint | Description |
|---|---|
| `POST /login` | Email/password login (rate-limited 5/min), returns a Sanctum bearer token |
| `POST /biometric-login` | Mobile biometric login using a pre-issued device token |
| `GET /health` | Liveness check |
| `GET\|POST\|PUT\|PATCH /kegiatan` | Proposal CRUD (write access scoped to `pengusul`/`admin`; status updates scoped per-role) |
| `GET\|POST /lpj` | Accountability report submission & review |
| `POST /chat` | "Jana" AI assistant — proxies to OpenRouter with a Si-LATORJANA system prompt |
| `GET /users` | Admin-only user management |

All protected routes require `Authorization: Bearer <token>` and are guarded by the `auth:sanctum` and custom `role:` middleware.

---

## 🔐 Security Notes

- Token-based auth via Laravel Sanctum (not session cookies) — same API serves web and mobile
- Role middleware (`CheckRole`) enforced on every write endpoint, not just hidden in the UI
- Login endpoint throttled to 5 attempts/minute
- Approved proposal data is snapshotted (`payload_snapshot`) to prevent retroactive tampering
- See `DOKUMEN_KEAMANAN.md` for the full security documentation (Bahasa Indonesia)

---

## 📄 License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)** — see [LICENSE](LICENSE) for the full text.

In short: anyone is free to use, modify, and even run this commercially or institutionally. The key condition is the **network copyleft clause** — if you run a modified version of this software as a service (e.g. deploy it for an organization's internal use over a network), you must make the modified source code available to that software's users. This prevents anyone from taking the code, modifying it, and operating it privately without giving back to the community.

---

## 👨‍💻 Developer

**Owner:** [@UDIN-K](https://github.com/UDIN-K)
**Repository:** [github.com/UDIN-COY/SILATORJANA](https://github.com/UDIN-COY/SILATORJANA)

<div align="center">
  <p><a href="https://github.com/UDIN-COY/SILATORJANA/stargazers">⭐ Star this repo if it's useful!</a></p>
</div>
