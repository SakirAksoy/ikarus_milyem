import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'musteri_model.dart';
import 'fis_provider.dart';
import 'theme.dart';

class MusteriDetayPage extends ConsumerWidget {
  final MusteriModel musteri;

  const MusteriDetayPage({
    super.key,
    required this.musteri,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fislerAsync = ref.watch(fisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(musteri.adSoyad),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ÖZET KARTI
          _buildOzetKarty(context),
          const SizedBox(height: 16),
          // İŞLEM GEÇMİŞİ
          Expanded(
            child: fislerAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Hata: $err')),
              data: (fisler) {
                // Sadece bu müşteriye ait işlemleri filtrele
                final musteriIslemi = fisler
                    .where((fis) =>
                        fis.musteriAd.toLowerCase() ==
                        musteri.adSoyad.toLowerCase())
                    .toList();

                if (musteriIslemi.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: AntiGravityColors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bu müşteriye ait işlem yok',
                          style: GoogleFonts.syne(
                            fontSize: 16,
                            color: AntiGravityColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: musteriIslemi.length,
                  itemBuilder: (context, index) {
                  final fis = musteriIslemi[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fis.islemTipi.name == 'satis' ? '📤 Satış' : '📥 Alış',
                                    style: GoogleFonts.syne(
                                      fontWeight: FontWeight.bold,
                                      color: fis.islemTipi.name == 'satis'
                                          ? Color(0xFFFF6B6B)
                                          : AntiGravityColors.liveGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tarih: ${_formatTarih(fis.tarih)}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      color: AntiGravityColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ayar: ${fis.ayar} | Gram: ${fis.hasGram.toStringAsFixed(4)}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      color: AntiGravityColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${fis.hasGram.toStringAsFixed(4)} gr',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AntiGravityColors.goldAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (fis.tlTutar > 0)
                                  Text(
                                    '${fis.tlTutar.toStringAsFixed(2)} TL',
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOzetKarty(BuildContext context) {
    final bakiyeRengi = musteri.toplamHasBakiye < 0
        ? Color(0xFFFF6B6B)
        : musteri.toplamHasBakiye > 0
            ? AntiGravityColors.liveGreen
            : AntiGravityColors.textMuted;

    final bakiyeMetni = musteri.toplamHasBakiye < 0
        ? 'BORÇLU'
        : musteri.toplamHasBakiye > 0
            ? 'ALACAKLI'
            : 'TAM ÖDEME';

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bakiyeRengi.withValues(alpha: 0.2),
            bakiyeRengi.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bakiyeRengi.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            musteri.adSoyad,
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AntiGravityColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          if (musteri.telefon != null && musteri.telefon!.isNotEmpty)
            Text(
              '☎️ ${musteri.telefon}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: AntiGravityColors.textMuted,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Güncel Bakiye',
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      color: AntiGravityColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${musteri.toplamHasBakiye.toStringAsFixed(4)} gr',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: bakiyeRengi,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: bakiyeRengi.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bakiyeMetni,
                  style: GoogleFonts.syne(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: bakiyeRengi,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTarih(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
