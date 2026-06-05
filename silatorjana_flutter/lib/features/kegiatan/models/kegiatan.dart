class Kegiatan {
  final int id;
  final String judul;
  final String status;
  final String createdAt;
  final String namaPengusul;

  Kegiatan({
    required this.id,
    required this.judul,
    required this.status,
    required this.createdAt,
    required this.namaPengusul,
  });

  factory Kegiatan.fromJson(Map<String, dynamic> json) {
    return Kegiatan(
      id: json['id'],
      judul: json['nama_kegiatan'] ?? 'Tanpa Judul',
      status: json['status'] ?? 'draft',
      createdAt: json['created_at'] ?? '',
      namaPengusul: json['user']?['nama'] ?? 'Pengusul',
    );
  }
}
