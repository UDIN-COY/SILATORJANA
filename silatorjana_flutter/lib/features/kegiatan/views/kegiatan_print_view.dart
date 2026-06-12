import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../../../core/network/api_service.dart';
import '../services/pdf_generator_service.dart';

/// Print/Preview proposal — mirrors web's PrintProposalPage.tsx.
/// Shows a formatted PDF preview of the full proposal for printing or sharing.
class KegiatanPrintView extends StatefulWidget {
  final int kegiatanId;
  const KegiatanPrintView({super.key, required this.kegiatanId});

  @override
  State<KegiatanPrintView> createState() => _KegiatanPrintViewState();
}

class _KegiatanPrintViewState extends State<KegiatanPrintView> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  Uint8List? _pdfDataCache;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/kegiatan/${widget.kegiatanId}');
      if (response.statusCode == 200) {
        _data = jsonDecode(response.body);
        final pdfDoc = await PdfGeneratorService.generatePdf(_data!);
        _pdfDataCache = await pdfDoc.save();
      }
    } catch (e) {
      debugPrint('Error fetch/generate PDF: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePdf() async {
    if (_pdfDataCache == null) return;
    try {
      final fileName = 'KGT_${widget.kegiatanId}.pdf';
      await Printing.sharePdf(bytes: _pdfDataCache!, filename: fileName);
    } catch (e) {
      debugPrint('Save file error: $e');
    }
  }

  Future<void> _printPdf() async {
    if (_pdfDataCache == null) return;
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => _pdfDataCache!,
      name: 'KGT_${widget.kegiatanId}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Pratinjau Dokumen'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF047857)))
          : _data == null || _pdfDataCache == null
              ? const Center(child: Text('Gagal memuat dokumen PDF'))
              : PdfPreview(
                  build: (format) => _pdfDataCache!,
                  useActions: false, // Kita buat action custom di bottom bar
                  allowPrinting: false,
                  allowSharing: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  maxPageWidth: 700,
                  pdfFileName: 'KGT_${widget.kegiatanId}.pdf',
                ),
      bottomNavigationBar: _isLoading || _pdfDataCache == null ? null : _buildBottomActions(),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _savePdf,
                icon: const Icon(LucideIcons.save, size: 18),
                label: const Text('Simpan PDF'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: const Color(0xFF047857),
                  side: const BorderSide(color: Color(0xFF047857), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _printPdf,
                icon: const Icon(LucideIcons.printer, size: 18),
                label: const Text('Cetak'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF047857),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
