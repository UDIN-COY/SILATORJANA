import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/network/api_service.dart';

/// Create Kegiatan form — mirrors web's CreateUsulanPage.tsx
/// Multi-step form: Info Umum → KAK → RAB → IKU → Submit
class CreateKegiatanView extends StatefulWidget {
  final int? editId; // If provided, edit mode
  const CreateKegiatanView({super.key, this.editId});

  @override
  State<CreateKegiatanView> createState() => _CreateKegiatanViewState();
}

class _CreateKegiatanViewState extends State<CreateKegiatanView> {
  final ApiService _apiService = ApiService();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Info Umum
  final _namaKegiatanCtrl = TextEditingController();
  final _jenisKegiatanCtrl = TextEditingController();
  final _tanggalMulaiCtrl = TextEditingController();
  final _tanggalSelesaiCtrl = TextEditingController();

  // KAK (Kerangka Acuan Kerja)
  final _latarBelakangCtrl = TextEditingController();
  final _tujuanCtrl = TextEditingController();
  final _sasaranCtrl = TextEditingController();
  final _targetCapaianCtrl = TextEditingController();

  // RAB items
  final List<Map<String, TextEditingController>> _rabItems = [];

  // IKU items
  final List<Map<String, TextEditingController>> _ikuItems = [];

  bool get _isEditMode => widget.editId != null;

  @override
  void initState() {
    super.initState();
    _addRabItem();
    _addIkuItem();
    if (_isEditMode) {
      _loadExistingData();
    }
  }

  @override
  void dispose() {
    _namaKegiatanCtrl.dispose();
    _jenisKegiatanCtrl.dispose();
    _tanggalMulaiCtrl.dispose();
    _tanggalSelesaiCtrl.dispose();
    _latarBelakangCtrl.dispose();
    _tujuanCtrl.dispose();
    _sasaranCtrl.dispose();
    _targetCapaianCtrl.dispose();
    for (var item in _rabItems) {
      for (var ctrl in item.values) {
        ctrl.dispose();
      }
    }
    for (var item in _ikuItems) {
      for (var ctrl in item.values) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    try {
      final response = await _apiService.get('/kegiatan/${widget.editId}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _namaKegiatanCtrl.text = data['nama_kegiatan'] ?? '';
            _jenisKegiatanCtrl.text = data['jenis_kegiatan'] ?? '';
            _tanggalMulaiCtrl.text = data['tanggal_mulai'] ?? '';
            _tanggalSelesaiCtrl.text = data['tanggal_selesai'] ?? '';

            final kak = data['kak'];
            if (kak != null) {
              _latarBelakangCtrl.text = kak['latar_belakang'] ?? '';
              _tujuanCtrl.text = kak['tujuan'] ?? '';
              _sasaranCtrl.text = kak['sasaran'] ?? '';
              _targetCapaianCtrl.text = kak['target_capaian'] ?? '';
            }
          });
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  void _addRabItem() {
    _rabItems.add({
      'uraian': TextEditingController(),
      'kategori': TextEditingController(),
      'harga': TextEditingController(),
      'qty1': TextEditingController(text: '1'),
      'qty2': TextEditingController(text: '1'),
      'qty3': TextEditingController(text: '1'),
    });
    setState(() {});
  }

  void _addIkuItem() {
    _ikuItems.add({
      'indikator': TextEditingController(),
      'target': TextEditingController(),
      'satuan': TextEditingController(text: '%'),
    });
    setState(() {});
  }

  void _removeRabItem(int index) {
    if (_rabItems.length > 1) {
      for (var ctrl in _rabItems[index].values) {
        ctrl.dispose();
      }
      _rabItems.removeAt(index);
      setState(() {});
    }
  }

  void _removeIkuItem(int index) {
    if (_ikuItems.length > 1) {
      for (var ctrl in _ikuItems[index].values) {
        ctrl.dispose();
      }
      _ikuItems.removeAt(index);
      setState(() {});
    }
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF047857))),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  Future<void> _submitForm() async {
    if (_namaKegiatanCtrl.text.isEmpty) {
      _showError('Nama kegiatan wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final body = {
        'nama_kegiatan': _namaKegiatanCtrl.text,
        'jenis_kegiatan': _jenisKegiatanCtrl.text,
        'tanggal_mulai': _tanggalMulaiCtrl.text,
        'tanggal_selesai': _tanggalSelesaiCtrl.text,
        'kak': {
          'latar_belakang': _latarBelakangCtrl.text,
          'tujuan': _tujuanCtrl.text,
          'sasaran': _sasaranCtrl.text,
          'target_capaian': _targetCapaianCtrl.text,
        },
        'rabs': _rabItems.map((item) => {
          'uraian': item['uraian']!.text,
          'kategori': item['kategori']!.text,
          'harga': double.tryParse(item['harga']!.text) ?? 0,
          'qty1': int.tryParse(item['qty1']!.text) ?? 1,
          'qty2': int.tryParse(item['qty2']!.text) ?? 1,
          'qty3': int.tryParse(item['qty3']!.text) ?? 1,
        }).toList(),
        'ikus': _ikuItems.map((item) => {
          'indikator': item['indikator']!.text,
          'target': item['target']!.text,
          'satuan': item['satuan']!.text,
        }).toList(),
      };

      final response = _isEditMode
          ? await _apiService.put('/kegiatan/${widget.editId}', body: body)
          : await _apiService.post('/kegiatan', body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode ? 'Usulan berhasil diperbarui!' : 'Usulan berhasil dibuat!'),
              backgroundColor: const Color(0xFF047857),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        final errData = jsonDecode(response.body);
        _showError(errData['message'] ?? 'Gagal menyimpan data (${response.statusCode})');
      }
    } catch (e) {
      _showError('Kesalahan jaringan: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Usulan' : 'Buat Usulan Baru'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 1,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep++);
          } else {
            _submitForm();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _isSubmitting ? null : details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF047857),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isSubmitting && _currentStep == 3
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_currentStep == 3 ? 'Simpan' : 'Lanjut', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Kembali'),
                  ),
              ],
            ),
          );
        },
        type: StepperType.vertical,
        steps: [
          Step(
            title: const Text('Info Umum', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Nama, jenis, dan waktu kegiatan'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildInfoUmumStep(),
          ),
          Step(
            title: const Text('Kerangka Acuan (KAK)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Latar belakang, tujuan, sasaran'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildKakStep(),
          ),
          Step(
            title: const Text('Rencana Anggaran (RAB)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Detail rincian biaya'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: _buildRabStep(),
          ),
          Step(
            title: const Text('Indikator Kinerja (IKU)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Target capaian kegiatan'),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
            content: _buildIkuStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoUmumStep() {
    return Column(
      children: [
        _buildTextField(_namaKegiatanCtrl, 'Nama Kegiatan *', LucideIcons.fileText),
        const SizedBox(height: 12),
        _buildTextField(_jenisKegiatanCtrl, 'Jenis Kegiatan', LucideIcons.tag),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _selectDate(_tanggalMulaiCtrl),
          child: AbsorbPointer(child: _buildTextField(_tanggalMulaiCtrl, 'Tanggal Mulai', LucideIcons.calendar)),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _selectDate(_tanggalSelesaiCtrl),
          child: AbsorbPointer(child: _buildTextField(_tanggalSelesaiCtrl, 'Tanggal Selesai', LucideIcons.calendarCheck)),
        ),
      ],
    );
  }

  Widget _buildKakStep() {
    return Column(
      children: [
        _buildTextArea(_latarBelakangCtrl, 'Latar Belakang'),
        const SizedBox(height: 12),
        _buildTextArea(_tujuanCtrl, 'Tujuan'),
        const SizedBox(height: 12),
        _buildTextArea(_sasaranCtrl, 'Sasaran'),
        const SizedBox(height: 12),
        _buildTextArea(_targetCapaianCtrl, 'Target Capaian'),
      ],
    );
  }

  Widget _buildRabStep() {
    return Column(
      children: [
        ..._rabItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final harga = double.tryParse(item['harga']!.text) ?? 0;
          final qty1 = int.tryParse(item['qty1']!.text) ?? 1;
          final qty2 = int.tryParse(item['qty2']!.text) ?? 1;
          final qty3 = int.tryParse(item['qty3']!.text) ?? 1;
          final subtotal = harga * qty1 * qty2 * qty3;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Item #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF047857))),
                    if (_rabItems.length > 1)
                      IconButton(icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red), onPressed: () => _removeRabItem(index)),
                  ],
                ),
                _buildTextField(item['uraian']!, 'Uraian', LucideIcons.fileText),
                const SizedBox(height: 8),
                _buildTextField(item['kategori']!, 'Kategori', LucideIcons.tag),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildTextField(item['harga']!, 'Harga', LucideIcons.banknote, isNumber: true, onChanged: (_) => setState(() {}))),
                    const SizedBox(width: 6),
                    SizedBox(width: 50, child: _buildTextField(item['qty1']!, 'Qty1', null, isNumber: true, onChanged: (_) => setState(() {}))),
                    const SizedBox(width: 6),
                    SizedBox(width: 50, child: _buildTextField(item['qty2']!, 'Qty2', null, isNumber: true, onChanged: (_) => setState(() {}))),
                    const SizedBox(width: 6),
                    SizedBox(width: 50, child: _buildTextField(item['qty3']!, 'Qty3', null, isNumber: true, onChanged: (_) => setState(() {}))),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Subtotal: Rp ${subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF047857), fontSize: 13)),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addRabItem,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Tambah Item RAB'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF047857),
            side: const BorderSide(color: Color(0xFFA7F3D0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildIkuStep() {
    return Column(
      children: [
        ..._ikuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('IKU #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF047857))),
                    if (_ikuItems.length > 1)
                      IconButton(icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red), onPressed: () => _removeIkuItem(index)),
                  ],
                ),
                _buildTextField(item['indikator']!, 'Indikator', LucideIcons.target),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildTextField(item['target']!, 'Target', LucideIcons.barChart, isNumber: true)),
                    const SizedBox(width: 8),
                    SizedBox(width: 80, child: _buildTextField(item['satuan']!, 'Satuan', null)),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addIkuItem,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Tambah IKU'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF047857),
            side: const BorderSide(color: Color(0xFFA7F3D0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData? icon, {bool isNumber = false, ValueChanged<String>? onChanged}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        alignLabelWithHint: true,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}
