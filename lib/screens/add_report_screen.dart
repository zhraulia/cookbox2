import 'package:flutter/material.dart';
import 'dart:math';

class AddReportScreen extends StatefulWidget {
  final String initialCategory;

  const AddReportScreen({super.key, required this.initialCategory});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  late String _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan pengaduan berhasil dikirim!'),
          backgroundColor: Color(0xFF28B957),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final randomId = Random().nextInt(9000) + 1000;
      final newData = {
        'id': '#LP-$randomId',
        'title': _titleController.text,
        'desc': _descController.text,
        'status': '⏳ Sedang Diproses',
      };

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context, newData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFC44307);
    final bgColor = const Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Buat Pengaduan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER BANNER KHUSUS UNTUK HALAMAN PENGADUAN
            _buildBannerHeader(primaryColor),

            // KOTAK FORM PENGADUAN (LEBIH CLEAN TANPA HIGHLIGHT BOX REDUNDAN)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kategori Masalah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: _inputDecoration(),
                      items: ['Pesanan & Pengiriman Bahan', 'Pembayaran', 'Akun', 'Lainnya']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text('Judul Keluhan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      maxLength: 50,
                      decoration: _inputDecoration(hint: 'Contoh: Paket sayur asem bahan kurang'),
                      style: const TextStyle(fontSize: 12),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Judul keluhan wajib diisi';
                        if (v.trim().length < 10) return 'Judul minimal 10 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text('Rincian Masalah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: _inputDecoration(hint: 'Sertakan nomor pesanan dan jelaskan masalahnya...'),
                      style: const TextStyle(fontSize: 12),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Rincian masalah wajib diisi';
                        if (v.trim().length < 20) return 'Rincian minimal 20 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: _isLoading ? const SizedBox() : const Icon(Icons.send, size: 16, color: Colors.white),
                        label: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Kirim Laporan Pengaduan', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER BANNER YANG SUDAH DISESUAIKAN
  Widget _buildBannerHeader(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.assignment_late_outlined, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text('Form Laporan', style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Layanan Pengaduan Pelanggan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Silakan lengkapi form di bawah ini agar kami dapat membantu memecahkan masalah Anda.', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      counterStyle: const TextStyle(fontSize: 10, color: Colors.black54),
    );
  }
}