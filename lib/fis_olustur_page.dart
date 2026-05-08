import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'fis_model.dart';
import 'fis_provider.dart';
import 'musteri_provider.dart';

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
  int _selectedMilyem = 916;
  String _selectedOdemeTipi = 'Nakit';

  final _hasGramController = TextEditingController();
  final _tlTutarController = TextEditingController();
  final _notlarController = TextEditingController();

  bool _isLoading = false;

  static const List<Map<String, dynamic>> milyemAyarlari = [
    {'ad': '8 Ayar', 'milyem': 333},
    {'ad': '9 Ayar', 'milyem': 375},
    {'ad': '10 Ayar', 'milyem': 417},
    {'ad': '14 Ayar', 'milyem': 585},
    {'ad': '18 Ayar', 'milyem': 750},
    {'ad': '19 Ayar', 'milyem': 800},
    {'ad': '21 Ayar', 'milyem': 875},
    {'ad': '22 Ayar', 'milyem': 916},
    {'ad': '24 Ayar', 'milyem': 1000},
  ];

  @override
  void dispose() {
    _hasGramController.dispose();
    _tlTutarController.dispose();
    _notlarController.dispose();
    super.dispose();
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
            ayar: (_selectedMilyem / 1000).toStringAsFixed(3),
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
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
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
      _selectedMilyem = 916;
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

                // Altın Ayarı (Milyem)
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
                        DropdownButtonFormField<int>(
                          initialValue: _selectedMilyem,
                          items: milyemAyarlari
                              .map((ayar) => DropdownMenuItem<int>(
                                    value: ayar['milyem'] as int,
                                    child: Text(
                                      '${ayar['ad']} (${ayar['milyem']} Milyem)',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 13),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedMilyem = value);
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AntiGravityColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AntiGravityColors.border,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AntiGravityColors.goldAccent,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
