// musteri_ekle_dialog.dart - TAMAMLANMIŞ VE TEMİZ

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'musteri_provider.dart';

class MusteriEkleDialog extends ConsumerStatefulWidget {
  const MusteriEkleDialog({super.key});

  @override
  ConsumerState<MusteriEkleDialog> createState() => _MusteriEkleDialogState();
}

class _MusteriEkleDialogState extends ConsumerState<MusteriEkleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _adSoyadController = TextEditingController();
  final _firmaAdiController = TextEditingController();
  final _telefonController = TextEditingController();
  final _adresController = TextEditingController();
  final _bakiyeController = TextEditingController(text: '0');

  bool _isLoading = false;

  @override
  void dispose() {
    _adSoyadController.dispose();
    _firmaAdiController.dispose();
    _telefonController.dispose();
    _adresController.dispose();
    _bakiyeController.dispose();
    super.dispose();
  }

  Future<void> _saveMusteriWithValidation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(musteriProvider);

      final adSoyad = _adSoyadController.text.trim();
      final firmaAdi = _firmaAdiController.text.trim();
      final telefon = _telefonController.text.trim().isEmpty ? null : _telefonController.text.trim();
      final adres = _adresController.text.trim().isEmpty ? null : _adresController.text.trim();
      final bakiye = double.tryParse(_bakiyeController.text) ?? 0.0;

      await service.musteriEkleWithFirma(
        adSoyad: adSoyad,
        firmaAdi: firmaAdi,
        telefon: telefon,
        adres: adres,
        toplamHasBakiye: bakiye,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ "$adSoyad" başarıyla eklendi'),
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
      title: const Text('Yeni Müşteri Ekle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              TextFormField(
                controller: _adSoyadController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Ad Soyad (Zorunlu)',
                  hintText: 'Örn: Ahmet Yılmaz',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad soyad zorunludur';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _firmaAdiController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Firma Adı (İsteğe Bağlı)',
                  hintText: 'Örn: Yılmaz Kuyumculuk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
              ),
              TextFormField(
                controller: _telefonController,
                enabled: !_isLoading,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telefon (İsteğe Bağlı)',
                  hintText: '+90 555 123 4567',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              TextFormField(
                controller: _adresController,
                enabled: !_isLoading,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Adres / Not (İsteğe Bağlı)',
                  hintText: 'Müşteri adı altında not ekle (konum, özel talepler vb.)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              TextFormField(
                controller: _bakiyeController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(
                  labelText: 'Açılış Bakiyesi (Has Altın Gramı)',
                  hintText: '0 (Borç için negatif, Alacak için pozitif)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.balance),
                  suffixText: 'gr',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                  }
                  return null;
                },
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Negatif bakiye = Müşteri borçlu, Pozitif bakiye = Müşteri alacaklı',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
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
          onPressed: _isLoading ? null : _saveMusteriWithValidation,
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
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}