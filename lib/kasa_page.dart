import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kasa_provider.dart';
import 'theme.dart';

class KasaPage extends ConsumerStatefulWidget {
  const KasaPage({super.key});

  @override
  ConsumerState<KasaPage> createState() => _KasaPageState();
}

class _KasaPageState extends ConsumerState<KasaPage> {
  final _tutarController = TextEditingController();
  final _aciklamaController = TextEditingController();
  String _selectedDoviz = 'TL';
  String _selectedGiderDoviz = 'TL';

  @override
  void dispose() {
    _tutarController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  void _showParaGirisiDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Para Girişi'),
        backgroundColor: AntiGravityColors.surface,
        contentTextStyle: TextStyle(color: AntiGravityColors.textLight),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedDoviz,
              items: [
                DropdownMenuItem(value: 'TL', child: const Text('₺ TL')),
                DropdownMenuItem(value: 'USD', child: const Text('\$ USD')),
                DropdownMenuItem(value: 'EUR', child: const Text('€ EUR')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDoviz = value ?? 'TL';
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tutarController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Tutar girin',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final tutar = double.tryParse(_tutarController.text) ?? 0.0;
              if (tutar > 0) {
                ref.read(kasaProvider.notifier).paraGirisi(
                      dovizTipi: _selectedDoviz,
                      tutar: tutar,
                    );
                _tutarController.clear();
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ $_selectedDoviz $tutar girişi yapıldı'),
                    backgroundColor: AntiGravityColors.liveGreen,
                  ),
                );
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showParaCikisiDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Para Çıkışı'),
        backgroundColor: AntiGravityColors.surface,
        contentTextStyle: TextStyle(color: AntiGravityColors.textLight),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedDoviz,
              items: [
                DropdownMenuItem(value: 'TL', child: const Text('₺ TL')),
                DropdownMenuItem(value: 'USD', child: const Text('\$ USD')),
                DropdownMenuItem(value: 'EUR', child: const Text('€ EUR')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDoviz = value ?? 'TL';
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tutarController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Tutar girin',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final tutar = double.tryParse(_tutarController.text) ?? 0.0;
              if (tutar > 0) {
                ref.read(kasaProvider.notifier).paraCikisi(
                      dovizTipi: _selectedDoviz,
                      tutar: tutar,
                    );
                _tutarController.clear();
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ $_selectedDoviz $tutar çıkışı yapıldı'),
                    backgroundColor: Color(0xFFFF6B6B),
                  ),
                );
              }
            },
            child: const Text('Çıkar'),
          ),
        ],
      ),
    );
  }

  void _showGiderEkleDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Masraf / Gider Ekle'),
        backgroundColor: AntiGravityColors.surface,
        contentTextStyle: TextStyle(color: AntiGravityColors.textLight),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _aciklamaController,
              decoration: InputDecoration(
                labelText: 'Gider Açıklaması',
                hintText: 'Örn: Yemek, Fatura, Maaş',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tutarController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Tutar',
                hintText: '0.00',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedGiderDoviz,
              items: [
                DropdownMenuItem(value: 'TL', child: const Text('₺ TL')),
                DropdownMenuItem(value: 'USD', child: const Text('\$ USD')),
                DropdownMenuItem(value: 'EUR', child: const Text('€ EUR')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGiderDoviz = value ?? 'TL';
                });
              },
              decoration: InputDecoration(
                labelText: 'Döviz Cinsi',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final tutar = double.tryParse(_tutarController.text) ?? 0.0;
              final aciklama = _aciklamaController.text.trim();

              if (aciklama.isNotEmpty && tutar > 0) {
                ref.read(kasaProvider.notifier).giderEkle(
                      aciklama: aciklama,
                      tutar: tutar,
                      dovizCinsi: _selectedGiderDoviz,
                    );

                _aciklamaController.clear();
                _tutarController.clear();

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ $_selectedGiderDoviz $tutar masrafı eklendi'),
                    backgroundColor: Color(0xFFFF6B6B),
                  ),
                );
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kasa = ref.watch(kasaProvider);
    const double kurUSD = 32.5;
    const double kurEUR = 35.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nakit Kasası',
          style: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AntiGravityColors.textLight,
          ),
        ),
        backgroundColor: AntiGravityColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AntiGravityColors.goldAccent,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 3 PARA BİRİMİ KARTI
            Column(
              children: [
                // TL KARTI
                Card(
                  color: AntiGravityColors.surface,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AntiGravityColors.liveGreen.withValues(alpha: 0.2),
                          AntiGravityColors.liveGreen.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AntiGravityColors.liveGreen.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₺ TL Kasası',
                              style: GoogleFonts.syne(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AntiGravityColors.textMuted,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${kasa.tlBakiye.toStringAsFixed(2)} ₺',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AntiGravityColors.liveGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // USD KARTI
                Card(
                  color: AntiGravityColors.surface,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4A90E2).withValues(alpha: 0.2),
                          Color(0xFF4A90E2).withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF4A90E2).withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$ USD Kasası',
                          style: GoogleFonts.syne(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AntiGravityColors.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${kasa.usdBakiye.toStringAsFixed(2)} \$',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A90E2),
                              ),
                            ),
                            Text(
                              '(~ ${(kasa.usdBakiye * kurUSD).toStringAsFixed(2)} TL)',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: AntiGravityColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // EUR KARTI
                Card(
                  color: AntiGravityColors.surface,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFA500).withValues(alpha: 0.2),
                          Color(0xFFFFA500).withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFFFFA500).withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '€ EUR Kasası',
                          style: GoogleFonts.syne(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AntiGravityColors.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${kasa.eurBakiye.toStringAsFixed(2)} €',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFA500),
                              ),
                            ),
                            Text(
                              '(~ ${(kasa.eurBakiye * kurEUR).toStringAsFixed(2)} TL)',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: AntiGravityColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // İŞLEM BUTONLARI
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showParaGirisiDialog,
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Para Girişi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AntiGravityColors.liveGreen,
                        foregroundColor: AntiGravityColors.darkBg,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showParaCikisiDialog,
                      icon: const Icon(Icons.remove_circle),
                      label: const Text('Para Çıkışı'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _showGiderEkleDialog,
                  icon: const Icon(Icons.money_off),
                  label: const Text('Masraf / Gider Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCC5555),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // SON MASRAFLAR LİSTESİ
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Son Masraflar',
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AntiGravityColors.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: kasa.giderler.isEmpty
                        ? Center(
                            child: Text(
                              'Henüz bir masraf girilmedi',
                              style: TextStyle(
                                color: AntiGravityColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: kasa.giderler.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final gider = kasa.giderler[index];
                              final tarih = DateTime.parse(gider['tarih']);
                              final formattedTarih =
                                  '${tarih.day}/${tarih.month}/${tarih.year} ${tarih.hour}:${tarih.minute.toString().padLeft(2, '0')}';
                              final dovizSembol = gider['dovizCinsi'] == 'USD'
                                  ? '\$'
                                  : gider['dovizCinsi'] == 'EUR'
                                      ? '€'
                                      : '₺';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Card(
                                  color: Color(0xFF1A1A1A),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.money_off,
                                      color: Color(0xFFFF6B6B),
                                      size: 20,
                                    ),
                                    title: Text(
                                      gider['aciklama'],
                                      style: TextStyle(
                                        color: AntiGravityColors.textLight,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      formattedTarih,
                                      style: TextStyle(
                                        color: AntiGravityColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                    trailing: Text(
                                      '-$dovizSembol${gider['tutar'].toStringAsFixed(2)}',
                                      style: GoogleFonts.jetBrainsMono(
                                        color: Color(0xFFFF6B6B),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
