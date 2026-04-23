import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stok_provider.dart';
import 'stok_ekle_dialog.dart';

class StokListePage extends ConsumerStatefulWidget {
  const StokListePage({super.key});

  @override
  ConsumerState<StokListePage> createState() => _StokListePageState();
}

class _StokListePageState extends ConsumerState<StokListePage> {
  void _showYeniStokDialog() {
    showDialog(
      context: context,
      builder: (context) => const StokEkleDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stoklarAsync = ref.watch(stoklarStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Yönetimi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: stoklarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (stoklar) {
          if (stoklar.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz ürün yok',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showYeniStokDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Ürünü Ekle'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: stoklar.length,
            itemBuilder: (context, index) {
              final stok = stoklar[index];
              final gramRengi = stok.toplamGram > 0
                  ? Colors.blue.shade700
                  : Colors.grey.shade700;
              final adetRengi = stok.toplamAdet > 0
                  ? Colors.green.shade700
                  : Colors.grey.shade700;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.shade700,
                    child: const Icon(Icons.diamond, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    '${stok.urunAdi} (${stok.urunKodu})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '🏷️ ${stok.urunGrubu} • 💎 ${stok.milyem.toStringAsFixed(0)} Milyem',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '⚖️ ${stok.toplamGram.toStringAsFixed(2)} gr | 📦 ${stok.toplamAdet} Adet',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${stok.toplamGram.toStringAsFixed(2)} gr',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: gramRengi,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${stok.toplamAdet} Adet',
                              style: TextStyle(
                                fontSize: 10,
                                color: adetRengi,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(stok.id),
                          tooltip: 'Ürünü Sil',
                          constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showYeniStokDialog,
        tooltip: 'Yeni Ürün Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(String stokId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content: const Text('Bu ürünü silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              String? errorMsg;
              try {
                await ref.read(stokProvider).stokSil(stokId: stokId);
              } catch (e) {
                errorMsg = e.toString();
              }
              if (!context.mounted) return;
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    errorMsg == null ? '✓ Ürün silindi' : '✗ Hata: $errorMsg',
                  ),
                  backgroundColor: errorMsg == null ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
