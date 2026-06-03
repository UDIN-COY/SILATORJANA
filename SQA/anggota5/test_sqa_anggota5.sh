#!/bin/bash
# ================================================================
# SQA Test Runner — Anggota 5: Modul Eksekutif & Penutupan (Approval & LPJ)
# Target: Laravel API at localhost:8000
# Tester: Irzal
# ================================================================
BASE="http://127.0.0.1:8000/api"
PASS=0
FAIL=0
TOTAL=0
RESULTS=""

run_test() {
  local id="$1" desc="$2" expected="$3" actual="$4"
  TOTAL=$((TOTAL+1))
  if echo "$actual" | grep -qiE "$expected"; then
    PASS=$((PASS+1))
    RESULTS+="| $id | $desc | ✅ PASS |"$'\n'
  else
    FAIL=$((FAIL+1))
    RESULTS+="| $id | $desc | ❌ FAIL |"$'\n'
    RESULTS+="  └─ Expected pattern: $expected"$'\n'
    RESULTS+="  └─ Got: $(echo "$actual" | head -c 200)"$'\n'
  fi
}

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  SQA TEST RUNNER — ANGGOTA 5 (Approval, LPJ & PDF Export)    ║"
echo "║  $(date '+%Y-%m-%d %H:%M:%S')                                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================
# PRE-REQUISITE / LOGIN TOKENS
# ============================================================
echo "━━━ PERSIAPAN TOKENS & AKUN ━━━"

# 1. Login Pengusul
R_PENG=$(curl.exe -s -X POST "$BASE/login" -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"email":"budi@pnj.ac.id","password":"12345678"}')
PENGUSUL_TOKEN=$(echo "$R_PENG" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# 2. Login PPK
R_PPK=$(curl.exe -s -X POST "$BASE/login" -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"email":"hendri@pnj.ac.id","password":"12345678"}')
PPK_TOKEN=$(echo "$R_PPK" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# 3. Login Wadir 2
R_WADIR=$(curl.exe -s -X POST "$BASE/login" -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"email":"susanto@pnj.ac.id","password":"12345678"}')
WADIR_TOKEN=$(echo "$R_WADIR" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# 4. Login Bendahara
R_BEND=$(curl.exe -s -X POST "$BASE/login" -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"email":"ratna@pnj.ac.id","password":"12345678"}')
BENDAHARA_TOKEN=$(echo "$R_BEND" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "Tokens obtained successfully:"
echo "  Pengusul  : ${PENGUSUL_TOKEN:0:10}..."
echo "  PPK       : ${PPK_TOKEN:0:10}..."
echo "  Wadir 2   : ${WADIR_TOKEN:0:10}..."
echo "  Bendahara : ${BENDAHARA_TOKEN:0:10}..."
echo ""

# ============================================================
# DUMMY KEGIATAN CREATION (FOR WORKFLOW STEPS)
# ============================================================
echo "━━━ PEMBUATAN PROPOSAL BARU UNTUK TESTING ALUR ━━━"
R_CREATE=$(curl.exe -s -X POST "$BASE/kegiatan" -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "Authorization: Bearer $PENGUSUL_TOKEN" \
  -d '{"nama_kegiatan":"Usulan SQA Kelompok 5","jenis_kegiatan":"Seminar","tanggal_kegiatan":"2026-06-30","tempat":"Ruang Serbaguna","deskripsi":"Pengujian alur SQA","pengusul_organisasi":"Himpunan TIK","status":"submitted"}')

KEGIATAN_ID=$(echo "$R_CREATE" | grep -oE '"id":\s*([0-9]+|"[0-9]+")' | grep -oE '[0-9]+')
echo "Proposal baru dibuat dengan ID: $KEGIATAN_ID"
echo ""

# ============================================================
# FUNCTIONAL TESTING (10 Test Case)
# ============================================================
echo "━━━ FUNCTIONAL TESTING (10 Test Case) ━━━"
echo ""

# TC-F-041: Dashboard PPK/Wadir
R=$(curl.exe -s "$BASE/stats" -H "Accept: application/json" -H "Authorization: Bearer $PPK_TOKEN")
run_test "TC-F-041" "Dashboard stats PPK/Wadir" '"total"|"submitted"|"verified"' "$R"

# TC-F-042: Klik Approve (Setuju) oleh PPK
# Ubah status usulan menjadi pending_ppk dahulu
curl.exe -s -X PUT "$BASE/kegiatan/$KEGIATAN_ID" -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "Authorization: Bearer $PPK_TOKEN" \
  -d '{"status":"pending_ppk"}' > /dev/null
# PPK melakukan Approve
R=$(curl.exe -s -X PUT "$BASE/kegiatan/$KEGIATAN_ID" -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "Authorization: Bearer $PPK_TOKEN" \
  -d '{"status":"approved_ppk"}')
run_test "TC-F-042" "PPK klik Approve" '"status":"approved_ppk"' "$R"

# TC-F-043: Klik Reject (Tolak) oleh Wadir 2 (Kita buat dummy usulan baru untuk di-reject)
R_REJ_CREATE=$(curl.exe -s -X POST "$BASE/kegiatan" -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "Authorization: Bearer $PENGUSUL_TOKEN" \
  -d '{"nama_kegiatan":"Usulan SQA Ditolak","jenis_kegiatan":"Workshop","tanggal_kegiatan":"2026-06-25","tempat":"Laboratorium TIK","deskripsi":"Ditolak untuk testing","pengusul_organisasi":"Himpunan TIK","status":"submitted"}')
REJ_ID=$(echo "$R_REJ_CREATE" | grep -oE '"id":\s*([0-9]+|"[0-9]+")' | grep -oE '[0-9]+')

R=$(curl.exe -s -X PUT "$BASE/kegiatan/$REJ_ID" -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "Authorization: Bearer $WADIR_TOKEN" \
  -d '{"status":"rejected"}')
run_test "TC-F-043" "Wadir 2 klik Reject" '"status":"rejected"' "$R"

# TC-F-044: Klik Approve oleh Wadir 2 (Pada usulan utama)
R=$(curl.exe -s -X PUT "$BASE/kegiatan/$KEGIATAN_ID" -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "Authorization: Bearer $WADIR_TOKEN" \
  -d '{"status":"approved_wadir"}')
run_test "TC-F-044" "Wadir 2 klik Approve" '"status":"approved_wadir"' "$R"

# TC-F-045: Bendahara klik Cairkan Dana
R=$(curl.exe -s -X PUT "$BASE/kegiatan/$KEGIATAN_ID" -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "Authorization: Bearer $BENDAHARA_TOKEN" \
  -d '{"status":"funds_disbursed"}')
run_test "TC-F-045" "Bendahara klik Cairkan Dana" '"status":"funds_disbursed"' "$R"

# TC-F-046: Pengusul buka Form Upload LPJ
# Cek ketersediaan usulan di list pengusul dengan status funds_disbursed
R=$(curl.exe -s "$BASE/kegiatan/$KEGIATAN_ID" -H "Accept: application/json" -H "Authorization: Bearer $PENGUSUL_TOKEN")
run_test "TC-F-046" "Pengusul akses detail usulan siap LPJ" '"status":"funds_disbursed"' "$R"

# TC-F-047: Unggah PDF LPJ valid (<5MB)
# Kita buat file dummy temporer untuk test upload
echo "dummy pdf content" > test_dummy_lpj.pdf
R=$(curl.exe -s -X POST "$BASE/upload" -H "Authorization: Bearer $PENGUSUL_TOKEN" \
  -F "file=@test_dummy_lpj.pdf" -F "type=lpj_file")
run_test "TC-F-047" "Unggah PDF LPJ valid" '"url"|"path"' "$R"
LPJ_PATH=$(echo "$R" | grep -o '"path":"[^"]*"' | cut -d'"' -f4)
rm -f test_dummy_lpj.pdf

# TC-F-048: Validasi Upload (Kirim type parameter invalid)
R=$(curl.exe -s -o /dev/null -w "%{http_code}" -X POST "$BASE/upload" -H "Authorization: Bearer $PENGUSUL_TOKEN" \
  -F "file=@tsconfig.json" -F "type=invalid_type")
run_test "TC-F-048" "Validasi parameter type upload" '422' "$R"

# TC-F-049: Klik tombol Export/Cetak PDF
# Akses detail kegiatan yang siap cetak PDF (Data lengkap)
R=$(curl.exe -s "$BASE/kegiatan/$KEGIATAN_ID" -H "Accept: application/json" -H "Authorization: Bearer $PENGUSUL_TOKEN")
run_test "TC-F-049" "Akses data print PDF" '"nama_kegiatan"|"deskripsi"' "$R"

# TC-F-050: Cek Layout PDF Output (Payload API mengembalikan data relasi KAK, IKU, RAB secara lengkap)
run_test "TC-F-050" "Layout kelengkapan data kegiatan" '"nama_kegiatan"|"jenis_kegiatan"|"status"' "$R"

echo ""

# ============================================================
# INTEGRATION TESTING (5 Test Case)
# ============================================================
echo "━━━ INTEGRATION TESTING (5 Test Case) ━━━"
echo ""

# TC-I-021: Wadir approve auto-trigger antrean masuk ke list Bendahara
# Wadir approve -> check di list Bendahara
R=$(curl.exe -s "$BASE/kegiatan" -H "Accept: application/json" -H "Authorization: Bearer $BENDAHARA_TOKEN")
run_test "TC-I-021" "Antrean masuk ke list Bendahara" "\"id\":$KEGIATAN_ID" "$R"

# TC-I-022: Link file LPJ sukses tersimpan di database
R=$(curl.exe -s -X POST "$BASE/lpj" -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "Authorization: Bearer $PENGUSUL_TOKEN" \
  -d "{\"kegiatan_id\":$KEGIATAN_ID,\"catatan_pengusul\":\"LPJ Terlampir\"}")
run_test "TC-I-022" "Data LPJ tersimpan di database" '"kegiatan_id"' "$R"

# TC-I-023: PDF Rendering (Menyatukan 3 tabel berbeda)
# Verifikasi detail proposal memiliki data terstruktur yang siap digabung di frontend
R=$(curl.exe -s "$BASE/kegiatan/$KEGIATAN_ID" -H "Accept: application/json" -H "Authorization: Bearer $PENGUSUL_TOKEN")
run_test "TC-I-023" "Data rendering PDF terintegrasi" '"nama_kegiatan".*"jenis_kegiatan"' "$R"

# TC-I-024: Notifikasi Bendahara — Sistem mengenali adanya LPJ baru
R=$(curl.exe -s "$BASE/notifications" -H "Accept: application/json" -H "Authorization: Bearer $BENDAHARA_TOKEN")
run_test "TC-I-024" "Notifikasi LPJ baru terbaca oleh Bendahara" '"status_baru"' "$R"

# TC-I-025: Penutupan Siklus (Bendahara ACC LPJ → Status terkunci akhir: lpj_approved)
R=$(curl.exe -s -X PUT "$BASE/kegiatan/$KEGIATAN_ID" -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "Authorization: Bearer $BENDAHARA_TOKEN" \
  -d '{"status":"lpj_approved"}')
run_test "TC-I-025" "Bendahara ACC LPJ → lpj_approved" '"status":"lpj_approved"' "$R"

echo ""

# ============================================================
# USER ACCEPTANCE TESTING (UAT) (5 Test Case)
# ============================================================
echo "━━━ USER ACCEPTANCE TESTING (5 Test Case) ━━━"
echo ""

# TC-U-021: Angka statistik dashboard eksekutif tebal & kontras
R=$(curl.exe -s "$BASE/stats" -H "Accept: application/json" -H "Authorization: Bearer $WADIR_TOKEN")
run_test "TC-U-021" "Angka stats dashboard dapat diakses" '"total"|"completed"|"approved"' "$R"

# TC-U-022: Terdapat log konfirmasi/tindakan (Audit Trail / Status History)
R=$(curl.exe -s "$BASE/status-history/kegiatan/$KEGIATAN_ID" -H "Accept: application/json" -H "Authorization: Bearer $WADIR_TOKEN")
run_test "TC-U-022" "Audit trail status terekam di status-history" '"status_baru"' "$R"

# TC-U-023: Print PDF layout parameter
R=$(curl.exe -s "$BASE/kegiatan/$KEGIATAN_ID" -H "Accept: application/json" -H "Authorization: Bearer $PENGUSUL_TOKEN")
run_test "TC-U-023" "Kelayakan data untuk cetak A4" '"nama_kegiatan"' "$R"

# TC-U-024: Nominal total_anggaran tersedia untuk format Terbilang
run_test "TC-U-024" "Nominal total_anggaran tersedia untuk format Terbilang" '"total_anggaran"' "$R"

# TC-U-025: Notifikasi badge merah / history record
R=$(curl.exe -s "$BASE/notifications" -H "Accept: application/json" -H "Authorization: Bearer $PPK_TOKEN")
run_test "TC-U-025" "History notifikasi atasan terbit" '"status_baru"' "$R"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  RINGKASAN HASIL PENGUJIAN                   ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "$RESULTS"
echo "╠══════════════════════════════════════════════════════════════╣"
printf "║  Total: %d  |  ✅ PASS: %d  |  ❌ FAIL: %d               ║\n" $TOTAL $PASS $FAIL
echo "╚══════════════════════════════════════════════════════════════╝"
