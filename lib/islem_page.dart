// islem_page.dart - TAMAMLANMIŞ VE TEMİZ

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'kuyumcu_islem_model.dart';
import 'kuyumcu_islem_provider.dart';
import 'musteri_provider.dart';
import 'musteri_model.dart';
import 'calculator_providers.dart';
import 'stok_provider.dart';
import 'stok_model.dart';

class IslemPage extends ConsumerStatefulWidget {
  const IslemPage({super.key});

  @override
  ConsumerState<IslemPage> createState() => _IslemPageState();
}

class _IslemPageState extends ConsumerState<IslemPage> {
  String? _selectedMusteriId;
  String? _selectedMusteriAdi;
  String? _selectedStokId;
  IslemTipi _selectedIslemTipi = IslemTipi.satis;
  UrunTipi _selectedUrunTipi = UrunTipi.gramajli;
  HurdaTipi _selectedHurdaTipi = HurdaTipi.ayar22;

  final _urunMilyemiController = TextEditingController();
  final _iscilikMilyemiController = TextEditingController();
  final _parcaIscilikGramiController = TextEditingController();
  final _gramController = TextEditingController();
  final _adetController = TextEditingController();
  final _nakitMiktariController = TextEditingController();
  final _odemeTuruController = TextEditingController(text: 'TL');

  double _hasAltinKarsiligi = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _urunMilyemiController.addListener(_recalculateHasAltin);
    _iscilikMilyemiController.addListener(_recalculateHasAltin);
    _parcaIscilikGramiController.addListener(_recalculateHasAltin);
    _gramController.addListener(_recalculateHasAltin);
    _adetController.addListener(_recalculateHasAltin);
    _nakitMiktariController.addListener(_recalculateHasAltin);
  }

  @override
  void dispose() {
    _urunMilyemiController.dispose();
    _iscilikMilyemiController.dispose();
    _parcaIscilikGramiController.dispose();
    _gramController.dispose();
    _adetController.dispose();
    _nakitMiktariController.dispose();
    _odemeTuruController.dispose();
    super.dispose();
  }

  void _recalculateHasAltin() {
    final service = ref.read(kuyumcuIslemProvider);
    double result = 0.0;

    try {
      switch (_selectedUrunTipi) {
        case UrunTipi.gramajli:
          final milyem = int.tryParse(_urunMilyemiController.text) ?? 0;
          final iscilik = double.tryParse(_iscilikMilyemiController.text) ?? 0.0;
          final gram = double.tryParse(_gramController.text) ?? 0.0;

          if (milyem > 0 && gram > 0) {
            result = service.hesaplaGramajliUrunHasAltin(
              urunMilyemi: milyem,
              iscilikMilyemi: iscilik,
              gram: gram,
            );
          }
          break;

        case UrunTipi.adetli:
          final milyem = int.tryParse(_urunMilyemiController.text) ?? 0;
          final gram = double.tryParse(_gramController.text) ?? 0.0;
          final adet = int.tryParse(_adetController.text) ?? 0;
          final parcaIscilik = double.tryParse(_parcaIscilikGramiController.text) ?? 0.0;

          if (milyem > 0 && gram > 0 && adet > 0) {
            result = service.hesaplaAdetliUrunHasAltin(
              urunMilyemi: milyem,
              gram: gram,
              adet: adet,
              parcaIscilikGrami: parcaIscilik,
            );
          }
          break;

        case UrunTipi.hurda:
          final gram = double.tryParse(_gramController.text) ?? 0.0;
          if (gram > 0) {
            result = service.hesaplaHurdaHasAltin(
              hurdaGram: gram,
              hurdaTipi: _selectedHurdaTipi,
            );
          }
          break;

        case UrunTipi.nakit:
          final rates = ref.read(exchangeRatesProvider);
          final miktar = double.tryParse(_nakitMiktariController.text) ?? 0.0;
          final kur = rates?.gramHasGoldToTL ?? 250.0;

          if (miktar > 0) {
            result = service.hesaplaNakitHasAltin(
              nakitMiktar: miktar,
              hasAltinKuru: kur,
            );
          }
          break;
      }

      setState(() => _hasAltinKarsiligi = result);
    } catch (_) {
      setState(() => _hasAltinKarsiligi = 0.0);
    }
  }

  Widget _buildStokSelector(List<StokModel> stoklar) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stok Ürünü (İsteğe Bağlı)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedStokId,
              hint: const Text('Ürün seç... (Stok otomatik doldurulacak)'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Ürün Seçme'),
                ),
                ...stoklar
                    .map((s) => DropdownMenuItem<String>(
                          value: s.id,
                          child: Text('${s.urunAdi} (${s.toplamGram.toStringAsFixed(2)} gr)'),
                        ))
                    .toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStokId = value;
                  if (value != null) {
                    final stok = stoklar.firstWhere((s) => s.id == value);
                    _urunMilyemiController.text = stok.milyem.toStringAsFixed(0);
                    _gramController.text = stok.toplamGram.toStringAsFixed(2);
                    _recalculateHasAltin();
                  } else {
                    _urunMilyemiController.clear();
                  }
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusteriSelector(List<MusteriModel> musteriler) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Müşteri Seçimi',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
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
                    _selectedMusteriAdi = musteriler.firstWhere((m) => m.id == value).adSoyad;
                  }
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIslemTipiSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İşlem Tipi',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  selected: _selectedIslemTipi == IslemTipi.satis,
                  label: const Text('Satış'),
                  onSelected: (v) => setState(() => _selectedIslemTipi = IslemTipi.satis),
                ),
                FilterChip(
                  selected: _selectedIslemTipi == IslemTipi.alis,
                  label: const Text('Alış'),
                  onSelected: (v) => setState(() => _selectedIslemTipi = IslemTipi.alis),
                ),
                FilterChip(
                  selected: _selectedIslemTipi == IslemTipi.odemeAlma,
                  label: const Text('Ödeme Alma'),
                  onSelected: (v) => setState(() => _selectedIslemTipi = IslemTipi.odemeAlma),
                ),
                FilterChip(
                  selected: _selectedIslemTipi == IslemTipi.odemeYapma,
                  label: const Text('Ödeme Yapma'),
                  onSelected: (v) => setState(() => _selectedIslemTipi = IslemTipi.odemeYapma),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrunTipiSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ürün Tipi',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UrunTipi>(
              initialValue: _selectedUrunTipi,
              items: [
                DropdownMenuItem(value: UrunTipi.gramajli, child: const Text('📏 Gramajlı (Bilezik, Kolye)')),
                DropdownMenuItem(value: UrunTipi.adetli, child: const Text('📌 Adetli (Yüzük, Küpe)')),
                DropdownMenuItem(value: UrunTipi.hurda, child: const Text('♻️ Hurda')),
                DropdownMenuItem(value: UrunTipi.nakit, child: const Text('💵 Nakit Ödeme')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUrunTipi = value ?? UrunTipi.gramajli;
                  _recalculateHasAltin();
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        if (_selectedUrunTipi == UrunTipi.gramajli) ...[
          _buildTextField(label: 'Ürün Milyemi', hint: '916, 750, 585 vb.', controller: _urunMilyemiController),
          const SizedBox(height: 12),
          _buildTextField(label: 'İşçilik Milyemi', hint: '50', controller: _iscilikMilyemiController),
          const SizedBox(height: 12),
          _buildTextField(label: 'Gram', hint: '10.50', controller: _gramController),
        ],
        if (_selectedUrunTipi == UrunTipi.adetli) ...[
          _buildTextField(label: 'Ürün Milyemi', hint: '916, 750, 585 vb.', controller: _urunMilyemiController),
          const SizedBox(height: 12),
          _buildTextField(label: 'Toplam Gram', hint: '100.00', controller: _gramController),
          const SizedBox(height: 12),
          _buildTextField(label: 'Adet', hint: '20', controller: _adetController, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _buildTextField(label: 'Parça Başı İşçilik (gr)', hint: '0.10', controller: _parcaIscilikGramiController),
        ],
        if (_selectedUrunTipi == UrunTipi.hurda) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hurda Tipi', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<HurdaTipi>(
                    initialValue: _selectedHurdaTipi,
                    items: [
                      DropdownMenuItem(value: HurdaTipi.ayar22, child: const Text('22 Ayar (916 → makasta 906)')),
                      DropdownMenuItem(value: HurdaTipi.ayar14, child: const Text('14 Ayar (585 → makasta 575)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedHurdaTipi = value ?? HurdaTipi.ayar22;
                        _recalculateHasAltin();
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(label: 'Hurda Gramı', hint: '3.30', controller: _gramController),
        ],
        if (_selectedUrunTipi == UrunTipi.nakit) ...[
          _buildTextField(label: 'Ödeme Miktarı', hint: '1000.00', controller: _nakitMiktariController),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ödeme Türü', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _odemeTuruController.text.isEmpty ? 'TL' : _odemeTuruController.text,
                    items: [
                      DropdownMenuItem(value: 'TL', child: const Text('TL')),
                      DropdownMenuItem(value: 'Dolar', child: const Text('Dolar')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _odemeTuruController.text = value ?? 'TL';
                        _recalculateHasAltin();
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = const TextInputType.numberWithOptions(decimal: true),
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHasAltinDisplay() {
    final kur = ref.watch(exchangeRatesProvider);
    final tlDegeri = _hasAltinKarsiligi * (kur?.gramHasGoldToTL ?? 250.0);

    return Card(
      elevation: 3,
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Has Altın Karşılığı', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gramaj', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      '${_hasAltinKarsiligi.toStringAsFixed(4)} gr',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TL Değeri', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      '${tlDegeri.toStringAsFixed(2)} TL',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_selectedMusteriId == null) {
      _showSnackBar('Lütfen müşteri seçin', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rates = ref.read(exchangeRatesProvider);
      final service = ref.read(kuyumcuIslemProvider);

      final islem = KuyumcuIslemModel(
        musteriId: _selectedMusteriId!,
        musteriAdi: _selectedMusteriAdi!,
        islemTipi: _selectedIslemTipi,
        urunTipi: _selectedUrunTipi,
        urunMilyemi: int.tryParse(_urunMilyemiController.text),
        iscilikMilyemi: double.tryParse(_iscilikMilyemiController.text),
        parcaIscilikGrami: double.tryParse(_parcaIscilikGramiController.text),
        gram: double.tryParse(_gramController.text),
        adet: int.tryParse(_adetController.text),
        hurdaTipi: _selectedUrunTipi == UrunTipi.hurda ? _selectedHurdaTipi : null,
        odemeMiktari: double.tryParse(_nakitMiktariController.text),
        odemeTuru: _odemeTuruController.text.isEmpty ? null : _odemeTuruController.text,
        hasAltinKuru: rates?.gramHasGoldToTL ?? 250.0,
        hasAltinKarsiligi: _hasAltinKarsiligi,
        islemTarihi: DateTime.now(),
      );

      await service.islemKaydet(islem: islem);

      if (mounted) {
        _showSnackBar(
          '✓ İşlem kaydedildi (${_hasAltinKarsiligi.toStringAsFixed(4)} gr Has)',
          Colors.green,
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('✗ Hata: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    _urunMilyemiController.clear();
    _iscilikMilyemiController.clear();
    _parcaIscilikGramiController.clear();
    _gramController.clear();
    _adetController.clear();
    _nakitMiktariController.clear();
    setState(() {
      _hasAltinKarsiligi = 0.0;
      _selectedStokId = null;
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
    final stoklarAsync = ref.watch(stoklarStreamProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: musterilerAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Hata: $err')),
          data: (musteriler) {
            if (musteriler.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 100),
                  child: Column(
                    children: [
                      Icon(Icons.person_add, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Lütfen önce müşteri ekleyin', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Card(
                  elevation: 2,
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.business, size: 32, color: Colors.blue.shade700),
                        const SizedBox(height: 8),
                        Text(
                          'KUYUMCU CARİ İŞLEMLERİ',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Has Altın Gramı Üzerinden Yönetim',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMusteriSelector(musteriler),
                const SizedBox(height: 16),
                stoklarAsync.when(
                  loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (stoklar) => Column(
                    children: [
                      _buildStokSelector(stoklar),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                _buildIslemTipiSelector(),
                const SizedBox(height: 16),
                _buildUrunTipiSelector(),
                const SizedBox(height: 16),
                _buildFormFields(),
                const SizedBox(height: 24),
                _buildHasAltinDisplay(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveTransaction,
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
                    label: Text(_isLoading ? 'KAYDEDILIYOR...' : 'İŞLEMİ KAYDET'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tüm işlemler Has Altın Gramı üzerinden hesaplanır.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}