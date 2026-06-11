class Kegiatan {
  final int id;
  final String judul;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String namaPengusul;
  final String namaKegiatan;
  final String? namaJurusan;
  final String? jenisKegiatan;
  final String? verifikatorTarget;
  final String? catatanRevisi;
  final num? totalAnggaran;
  final int? pengusulId;

  Kegiatan({
    required this.id,
    required this.judul,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.namaPengusul,
    required this.namaKegiatan,
    this.namaJurusan,
    this.jenisKegiatan,
    this.verifikatorTarget,
    this.catatanRevisi,
    this.totalAnggaran,
    this.pengusulId,
  });

  factory Kegiatan.fromJson(Map<String, dynamic> json) {
    return Kegiatan(
      id: json['id'],
      judul: json['nama_kegiatan'] ?? 'Tanpa Judul',
      status: json['status'] ?? 'draft',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? json['created_at'] ?? '',
      namaPengusul: json['user']?['nama'] ?? json['pengusul_nama'] ?? 'Pengusul',
      namaKegiatan: json['nama_kegiatan'] ?? 'Tanpa Judul',
      namaJurusan: json['nama_jurusan'] ?? json['jurusan']?['nama_jurusan'],
      jenisKegiatan: json['jenis_kegiatan'],
      verifikatorTarget: json['verifikator_target'],
      catatanRevisi: json['catatan_revisi'],
      totalAnggaran: json['total_anggaran'],
      pengusulId: json['pengusul_id'],
    );
  }
}
