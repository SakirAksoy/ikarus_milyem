import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'theme.dart';
import 'fis_model.dart';
import 'fis_provider.dart';
import 'fis_pdf_servis.dart';

class FisGecmisiPage extends ConsumerWidget {
  const FisGecmisiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fislerAsync = ref.watch(fisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fiş Geçmişi',
          style: GoogleFonts.syne(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: fislerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Hata: $err')),
        data: (fisler) {
          if (fisler.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: AntiGravityColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz fiş yok',
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

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: fisler.length,
            itemBuilder: (context, index) {
              final fis = fisler[index];
              final formatter = DateFormat('dd.MM.yyyy HH:mm');
              final tarihStr = formatter.format(fis.tarih);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AntiGravityColors.goldAccent,
                    child: Icon(
                      Icons.receipt_long,
                      color: AntiGravityColors.darkBg,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${fis.musteriAd} - ${fis.fisNo}',
                    style: GoogleFonts.syne(
                      fontWeight: FontWeight.bold,
                      color: AntiGravityColors.textLight,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        tarihStr,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AntiGravityColors.textMuted,
                        ),
                      ),
                      Text(
                        '${fis.ayar} | ${fis.hasGram.toStringAsFixed(4)} gr | ${fis.tlTutar.toStringAsFixed(2)} TL',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: AntiGravityColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AntiGravityColors.textMuted,
                  ),
                  onTap: () => _showFisDetayDialog(context, fis),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFisDetayDialog(BuildContext context, FisModel fis) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: AntiGravityColors.surface,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            // Header
            Text(
              'Fiş Detayları - ${fis.fisNo}',
              style: GoogleFonts.syne(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AntiGravityColors.textLight,
              ),
            ),

            // Detaylar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                _buildDetailRow('Müşteri', fis.musteriAd),
                _buildDetailRow('Telefon', fis.musteriTelefon),
                _buildDetailRow('Tarih', DateFormat('dd.MM.yyyy HH:mm').format(fis.tarih)),
                _buildDetailRow('İşlem Tipi', _getIslemTipiStr(fis.islemTipi)),
                _buildDetailRow('Ayar', fis.ayar),
                _buildDetailRow('Has Gram', '${fis.hasGram.toStringAsFixed(4)} gr'),
                _buildDetailRow('TL Tutar', '${fis.tlTutar.toStringAsFixed(2)} TL'),
                _buildDetailRow('Ödeme Tipi', fis.odemeTipi),
                if (fis.notlar != null && fis.notlar!.isNotEmpty)
                  _buildDetailRow('Notlar', fis.notlar!),
              ],
            ),

            const SizedBox(height: 24),

            // Butonlar
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _printFis(context, fis),
                    icon: const Icon(Icons.print),
                    label: const Text('🖨️ Yazdır'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AntiGravityColors.goldAccent,
                      foregroundColor: AntiGravityColors.darkBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareWhatsApp(context, fis),
                    icon: const Icon(Icons.message),
                    label: const Text('💬 WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.syne(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AntiGravityColors.textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AntiGravityColors.goldAccent,
          ),
        ),
      ],
    );
  }

  void _printFis(BuildContext context, FisModel fis) async {
    try {
      await FisPdfServis.printFis(fis);
      if (!context.mounted) return;
      Navigator.pop(context);
      _showSnackBar(context, '✓ Fiş yazdırma başlatıldı', AntiGravityColors.liveGreen);
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, '✗ Hata: $e', const Color(0xFFFF6B6B));
    }
  }

  void _shareWhatsApp(BuildContext context, FisModel fis) async {
    try {
      await FisPdfServis.shareFisWhatsApp(fis);
      if (!context.mounted) return;
      Navigator.pop(context);
      _showSnackBar(context, '✓ WhatsApp açıldı', AntiGravityColors.liveGreen);
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, '✗ Hata: $e', const Color(0xFFFF6B6B));
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  String _getIslemTipiStr(IslemTipiFis tipi) {
    switch (tipi) {
      case IslemTipiFis.satis:
        return 'Satış';
      case IslemTipiFis.alis:
        return 'Alış';
      case IslemTipiFis.manuel:
        return 'Manuel';
    }
  }
}
