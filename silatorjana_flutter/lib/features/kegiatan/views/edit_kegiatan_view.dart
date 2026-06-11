import 'package:flutter/material.dart';
import 'create_kegiatan_view.dart';

/// Edit Kegiatan — just wraps CreateKegiatanView in edit mode.
/// Mirrors web's EditRevisiPage.tsx.
class EditKegiatanView extends StatelessWidget {
  final int kegiatanId;
  const EditKegiatanView({super.key, required this.kegiatanId});

  @override
  Widget build(BuildContext context) {
    return CreateKegiatanView(editId: kegiatanId);
  }
}
