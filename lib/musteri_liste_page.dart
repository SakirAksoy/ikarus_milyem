import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'musteri_provider.dart';
import 'musteri_ekle_dialog.dart';
import 'theme.dart';

class MusteriListePage extends ConsumerStatefulWidget {
  const MusteriListePage({super.key});

  @override
  ConsumerState<MusteriListePage> createState() => _MusteriListePageState();
}

class _MusteriListePageState extends ConsumerState<MusteriListePage> {
  void _showYeniMusteriDialog() {
    showDialog(
      context: context,
      builder: (context) => const MusteriEkleDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musteriListAsync = ref.watch(musteriListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteri Yönetimi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: musteriListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (musteriler) {
          if (musteriler.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AntiGravityColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz müşteri yok',
                    style: GoogleFonts.syne(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AntiGravityColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showYeniMusteriDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Müşteriyi Ekle'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: musteriler.length,
            itemBuilder: (context, index) {
              final musteri = musteriler[index];
              final Color bakiyeRengi = musteri.isBorcu
                  ? Color(0xFFFF6B6B)
                  : musteri.isAlacakli
                      ? AntiGravityColors.liveGreen
                      : AntiGravityColors.textMuted;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: bakiyeRengi,
                    child: Text(
                      musteri.adSoyad.isNotEmpty ? musteri.adSoyad[0].toUpperCase() : '?',
                      style: GoogleFonts.syne(
                        color: AntiGravityColors.darkBg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    musteri.firmaAdi.isNotEmpty
                        ? '${musteri.adSoyad} (${musteri.firmaAdi})'
                        : musteri.adSoyad,
                    style: GoogleFonts.syne(
                      fontWeight: FontWeight.bold,
                      color: AntiGravityColors.textLight,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (musteri.firmaAdi.isNotEmpty)
                        Text(
                          '🏢 ${musteri.firmaAdi}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AntiGravityColors.textMuted,
                          ),
                        ),
                      if (musteri.firmaAdi.isNotEmpty)
                        const SizedBox(height: 2),
                      if (musteri.telefon != null && musteri.telefon!.isNotEmpty)
                        Text(
                          '☎️ ${musteri.telefon}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: AntiGravityColors.textMuted,
                          ),
                        ),
                      if (musteri.telefon != null && musteri.telefon!.isNotEmpty)
                        const SizedBox(height: 2),
                      if (musteri.adres != null && musteri.adres!.isNotEmpty)
                        Text(
                          '📍 ${musteri.adres}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: AntiGravityColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${musteri.toplamHasBakiye.toStringAsFixed(4)} gr',
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.bold,
                          color: bakiyeRengi,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        musteri.isBorcu
                            ? 'Borçlu'
                            : musteri.isAlacakli
                                ? 'Alacaklı'
                                : 'Alacaksız',
                        style: GoogleFonts.syne(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: bakiyeRengi,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showYeniMusteriDialog,
        tooltip: 'Yeni Müşteri Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}
