import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'musteri_provider.dart';
import 'musteri_ekle_dialog.dart';

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
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz müşteri yok',
                    style: Theme.of(context).textTheme.titleLarge,
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
                  ? Colors.red.shade700
                  : musteri.isAlacakli
                      ? Colors.green.shade700
                      : Colors.grey.shade700;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: bakiyeRengi,
                    child: Text(
                      musteri.adSoyad.isNotEmpty ? musteri.adSoyad[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    musteri.firmaAdi.isNotEmpty
                      ? '${musteri.adSoyad} (${musteri.firmaAdi})'
                      : musteri.adSoyad,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (musteri.firmaAdi.isNotEmpty)
                        Text('🏢 ${musteri.firmaAdi}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      if (musteri.firmaAdi.isNotEmpty)
                        const SizedBox(height: 2),
                      if (musteri.telefon != null && musteri.telefon!.isNotEmpty)
                        Text('☎️ ${musteri.telefon}', style: const TextStyle(fontSize: 12)),
                      if (musteri.telefon != null && musteri.telefon!.isNotEmpty)
                        const SizedBox(height: 2),
                      if (musteri.adres != null && musteri.adres!.isNotEmpty)
                        Text('📍 ${musteri.adres}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${musteri.toplamHasBakiye.toStringAsFixed(4)} gr',
                        style: TextStyle(
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
                        style: TextStyle(fontSize: 11, color: bakiyeRengi),
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
