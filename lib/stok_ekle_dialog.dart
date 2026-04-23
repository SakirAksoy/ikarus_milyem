import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stok_provider.dart';

class StokEkleDialog extends ConsumerStatefulWidget {
  const StokEkleDialog({super.key});

  @override
  ConsumerState<StokEkleDialog> createState() => _StokEkleDialogState();
}

class _StokEkleDialogState extends ConsumerState<StokEkleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urunAdiController = TextEditingController();
  final _urunKoduController = TextEditingController();
  final _milyemController = TextEditingController();
  final _toplamGramController = TextEditingController(text: '0');
  final _toplamAdetController = TextEditingController(text: '0');

  String _selectedUrunGrubu = 'Yüzük';
  bool _isLoading = false;

  final List<String> _urunGruplari = [
    'Yüzük',
    'Kolye',
    'Bilezik',
    'Küpe',
    'Broş',
    'Diğer',
  ];

  @override
  void dispose() {
    _urunAdiController.dispose();
    _urunKoduController.dispose();
    _milyemController.dispose();
    _toplamGramController.dispose();
    _toplamAdetController.dispose();
    super.dispose();
  }

  Future<void> _saveStokWithValidation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(stokProvider);

      final urunAdi = _urunAdiController.text.trim();
      final urunKodu = _urunKoduController.text.trim();
      final milyem = double.tryParse(_milyemController.text) ?? 0.0;
      final toplamGram = double.tryParse(_toplamGramController.text) ?? 0.0;
      final toplamAdet = int.tryParse(_toplamAdetController.text) ?? 0;

      await service.stokEkle(
        urunAdi: urunAdi,
        urunKodu: urunKodu,
        milyem: milyem,
        toplamGram: toplamGram,
        toplamAdet: toplamAdet,
        urunGrubu: _selectedUrunGrubu,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ "$urunAdi" başarıyla eklendi'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✗ Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Ürün Ekle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              TextFormField(
                controller: _urunAdiController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Ürün Adı (Zorunlu)',
                  hintText: 'Örn: Altın Bilezik',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ürün adı zorunludur';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _urunKoduController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Ürün Kodu (Zorunlu)',
                  hintText: 'Örn: SKU-001',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.qr_code),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ürün kodu zorunludur';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedUrunGrubu,
                items: _urunGruplari.map((grup) {
                  return DropdownMenuItem(
                    value: grup,
                    child: Text(grup),
                  );
                }).toList(),
                onChanged: _isLoading ? null : (value) {
                  if (value != null) {
                    setState(() => _selectedUrunGrubu = value);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Ürün Grubu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
              ),
              TextFormField(
                controller: _milyemController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(
                  labelText: 'Milyem (Zorunlu)',
                  hintText: '916, 750, 585 vb.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.verified),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Milyem zorunludur';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _toplamGramController,
                      enabled: !_isLoading,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Toplam Gram',
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixText: 'gr',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Geçerli sayı';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _toplamAdetController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Adet',
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixText: 'Adet',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (int.tryParse(value) == null) {
                            return 'Geçerli sayı';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _saveStokWithValidation,
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.check_circle),
          label: Text(_isLoading ? 'KAYDEDILIYOR...' : 'KAYDET'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
