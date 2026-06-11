
class User {
  final int id;
  final String nama;
  final String email;
  final String role;
  final String? verifikatorUnit; // from users.verifikator_unit (e.g. 'wadir1')
  final String? jurusan;
  final String? nip;

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.verifikatorUnit,
    this.jurusan,
    this.nip,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      verifikatorUnit: json['verifikator_unit']?.toString(),
      jurusan: json['jurusan']?.toString(),
      nip: json['nip']?.toString(),
    );
  }

  /// Returns the wadir unit this user belongs to.
  /// - For verifikator: uses `verifikator_unit` from DB (e.g. 'wadir1')
  /// - For wadir roles: the role itself IS the unit (e.g. 'wadir2')
  String get wadirTarget {
    if (role == 'verifikator' && verifikatorUnit != null && verifikatorUnit!.isNotEmpty) {
      return verifikatorUnit!;
    }
    if (role.startsWith('wadir')) {
      return role; // wadir1, wadir2, etc.
    }
    return '';
  }
}
