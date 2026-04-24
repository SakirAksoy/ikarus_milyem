import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'fis_model.dart';
import 'fis_provider.dart';
import 'musteri_provider.dart';
import 'musteri_model.dart';

class FisOlusturPage extends ConsumerStatefulWidget {
  const FisOlusturPage({super.key});

  @override
  ConsumerState<FisOlusturPage> createState() => _FisOlusturPageState();
}

class _FisOlusturPageState extends ConsumerState<FisOlusturPage> {
  String? _selectedMusteriId;
  String? _selectedMusteriAd;
  String? _selectedMusteriTelefon;
  IslemTipiFis _selectedIslemTipi = IslemTipiFis.manuel;
  String _selectedAyar = '916';
  String _selectedOdemeTipi = 'Nakit';

  final _hasGramController = TextEditingController();
  final _tlTutarController = TextEditingController();
  final _notlarController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _hasGramController.dispose();
    _tlTutarController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  void _generateFisNo() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return;
  }

  Future<void> _saveFis() async {
    if (_selectedMusteriId == null) {
      _showSnackBar('Lütfen müşteri seçin', AntiGravityColors.goldAccent);
      return;
    }

    if (_hasGramController.text.isEmpty) {
      _showSnackBar('Lütfen Has Gram giriniz', AntiGravityColors.goldAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fisNo = DateTime.now().millisecondsSinceEpoch.toString();

      await ref.read(fisProvider.notifier).fisEkle(
            fisNo: fisNo,
            musteriAd: _selectedMusteriAd ?? 'Bilinmiyor',
            musteriTelefon: _selectedMusteriTelefon ?? '',
            tarih: DateTime.now(),
            islemTipi: _selectedIslemTipi,
            ayar: _selectedAyar,
            hasGram: double.tryParse(_hasGramController.text) ?? 0.0,
            tlTutar: double.tryParse(_tlTutarController.text) ?? 0.0,
            odemeTipi: _selectedOdemeTipi,
            notlar: _notlarController.text.isEmpty ? null : _notlarController.text,
          );

      if (!context.mounted) return;
      _showSnackBar('✓ Fiş başarıyla oluşturuldu!', AntiGravityColors.liveGreen);
      _resetForm();
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar('✗ Hata: $e', const Color(0xFFFF6B6B));
    } finally {
      if (!context.mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _hasGramController.clear();
    _tlTutarController.clear();
    _notlarController.clear();
    setState(() {
      _selectedMusteriId = null;
      _selectedMusteriAd = null;
      _selectedIslemTipi = IslemTipiFis.manuel;
      _selectedAyar = '916';
      _selectedOdemeTipi = 'Nakit';
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musterilerAsync = ref.watch(musteriListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fiş Oluştur',
          style: GoogleFonts.syne(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: musterilerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Hata: $err')),
        data: (musteriler) {
          if (musteriler.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add, size: 64, color: AntiGravityColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'Lütfen önce müşteri ekleyin',
                    style: GoogleFonts.syne(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AntiGravityColors.textLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              children: [
                // Müşteri Seçimi
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Müşteri Seçimi',
                          style: GoogleFonts.syne(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AntiGravityColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedMusteriId,
                          hint: const Text('Müşteri seçin...'),
                          items: musteriler
                              .map((m) => DropdownMenuItem<String>(
                                    value: m.id,
                                    child: Text('${m.adSoyad} (${m.toplamHasBakiye.toStringAsFixed(2)} gr)'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMusteriId = value;
                              if (value != null) {
                                final selected = musteriler.firstWhere((m) => m.id == value);
                                _selectedMusteriAd = selected.adSoyad;
                                _selectedMusteriTelefon = selected.telefon;
                              }
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // İşlem Tipi
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İşlem Tipi',
                          style: GoogleFonts.syne(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AntiGravityColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              selected: _selectedIslemTipi == IslemTipiFis.satis,
                              label: const Text('Satış'),
                              onSelected: (v) => setState(() => _selectedIslemTipi = IslemTipiFis.satis),
                            ),
                            FilterChip(
                              selected: _selectedIslemTipi == IslemTipiFis.alis,
                              label: const Text('Alış'),
                              onSelected: (v) => setState(() => _selectedIslemTipi = IslemTipiFis.alis),
                            ),
                            FilterChip(
                              selected: _selectedIslemTipi == IslemTipiFis.manuel,
                              label: const Text('Manuel'),
                              onSelected: (v) => setState(() => _selectedIslemTipi = IslemTipiFis.manuel),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Ayar
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Altın Ayarı',
                          style: GoogleFonts.syne(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AntiGravityColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedAyar,
                          items: [
                            DropdownMenuItem(value: '1000', child: const Text('1000 - Has Altın')),
                            DropdownMenuItem(value: '995', child: const Text('995 - 24 Ayar')),
                            DropdownMenuItem(value: '916', child: const Text('916 - 22 Ayar')),
                            DropdownMenuItem(value: '875', child: const Text('875 - 21 Ayar')),
                            DropdownMenuItem(value: '750', child: const Text('750 - 18 Ayar')),
                          ].toList(),
                          onChanged: (value) => setState(() => _selectedAyar = value ?? '916'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Has Gram
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Has Altın Gramı',
                          style: GoogleFonts.syne(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AntiGravityColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _hasGramController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '0.0000',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // TL Tutar
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TL Tutar',
                          style: GoogleFonts.syne(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AntiGravityColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _tlTutarController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Ödeme Tipi
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ödeme Tipi',
                          style: GoogleFonts.syne(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AntiGravityColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedOdemeTipi,
                          items: [
                            DropdownMenuItem(value: 'Nakit', child: const Text('Nakit')),
                            DropdownMenuItem(value: 'Hurda', child: const Text('Hurda')),
                            DropdownMenuItem(value: 'Banka', child: const Text('Banka')),
                            DropdownMenuItem(value: 'Çek', child: const Text('Çek')),
                          ].toList(),
                          onChanged: (value) => setState(() => _selectedOdemeTipi = value ?? 'Nakit'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Notlar
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notlar (İsteğe Bağlı)',
                          style: GoogleFonts.syne(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AntiGravityColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notlarController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Fiş notları...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Kaydet Butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveFis,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(_isLoading ? 'KAYDEDILIYOR...' : 'FİŞ OLUŞTUR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AntiGravityColors.goldAccent,
                      foregroundColor: AntiGravityColors.darkBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
