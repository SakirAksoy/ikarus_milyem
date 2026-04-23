import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'calculator_providers.dart';

// ============================================================================
// KUR SAYFASI (Exchange Rates Page)
// ============================================================================
//
// Displays and manages exchange rates (Döviz Kurları)
// Features:
// - Display current rates (Dolar, Has Altın, Hurda)
// - Manual rate input with validation
// - Real-time Riverpod state updates
// - Harem Altın API integration ready

class KurPage extends ConsumerStatefulWidget {
  const KurPage({super.key});

  @override
  ConsumerState<KurPage> createState() => _KurPageState();
}

class _KurPageState extends ConsumerState<KurPage> {
  late TextEditingController _dolarKurController;
  late TextEditingController _hasAltinController;
  late TextEditingController _hurdaController;

  @override
  void initState() {
    super.initState();
    _dolarKurController = TextEditingController();
    _hasAltinController = TextEditingController();
    _hurdaController = TextEditingController();
  }

  @override
  void dispose() {
    _dolarKurController.dispose();
    _hasAltinController.dispose();
    _hurdaController.dispose();
    super.dispose();
  }

  // =========================================================================
  // BUILD INPUT CARD
  // =========================================================================

  Widget _buildRateCard({
    required String label,
    required String unit,
    required TextEditingController controller,
    required String hint,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: hint,
                suffixText: unit,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // SAVE RATES HANDLER
  // =========================================================================

  void _saveRates(WidgetRef ref) {
    final dolarStr = _dolarKurController.text.trim();
    final hasAltinStr = _hasAltinController.text.trim();
    final hurdaStr = _hurdaController.text.trim();

    if (dolarStr.isEmpty || hasAltinStr.isEmpty || hurdaStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm kurları girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final dolarToTL = double.parse(dolarStr);
      final hasGramToTL = double.parse(hasAltinStr);
      final hurdaGramToTL = double.parse(hurdaStr);

      // Validate ranges
      if (dolarToTL <= 0 || hasGramToTL <= 0 || hurdaGramToTL <= 0) {
        throw 'Kurlar pozitif değer olmalıdır';
      }

      // Update Riverpod state
      ref.read(exchangeRatesProvider.notifier).updateRates(
        dolarToTL: dolarToTL,
        gramHasGoldToTL: hasGramToTL,
        gramWasteToTL: hurdaGramToTL,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Kurlar başarıyla kaydedildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✗ Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    // Watch current exchange rates
    final rates = ref.watch(exchangeRatesProvider);

    // Populate controllers with current values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dolarKurController.text.isEmpty && rates != null) {
        _dolarKurController.text = rates.dolarToTL.toStringAsFixed(2);
        _hasAltinController.text = rates.gramHasGoldToTL.toStringAsFixed(2);
        _hurdaController.text = rates.gramWasteToTL.toStringAsFixed(2);
      }
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ===== HEADER SECTION =====
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 32,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Döviz Kurları',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Güncel kurları görüntüleyin ve manuel olarak güncelleyin',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== CURRENT RATES DISPLAY =====
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mevcut Kurlar',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildRateDisplayRow(
                      '💵 Dolar → TL:',
                      '${(rates?.dolarToTL ?? 0.0).toStringAsFixed(2)} TL/USD',
                    ),
                    const SizedBox(height: 8),
                    _buildRateDisplayRow(
                      '🏆 Has Altın → TL:',
                      '${(rates?.gramHasGoldToTL ?? 0.0).toStringAsFixed(2)} TL/gr',
                    ),
                    const SizedBox(height: 8),
                    _buildRateDisplayRow(
                      '♻️ Hurda → TL:',
                      '${(rates?.gramWasteToTL ?? 0.0).toStringAsFixed(2)} TL/gr',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== RATE INPUT SECTION =====
            Text(
              'Kurları Güncelle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 12),

            _buildRateCard(
              label: '1 USD → TL',
              unit: 'TL',
              controller: _dolarKurController,
              hint: 'örn: 35.50',
            ),

            const SizedBox(height: 12),

            _buildRateCard(
              label: '1 gr Has Altın → TL',
              unit: 'TL/gr',
              controller: _hasAltinController,
              hint: 'örn: 2500.00',
            ),

            const SizedBox(height: 12),

            _buildRateCard(
              label: '1 gr Hurda → TL',
              unit: 'TL/gr',
              controller: _hurdaController,
              hint: 'örn: 1200.00',
            ),

            const SizedBox(height: 24),

            // ===== ACTION BUTTONS =====
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveRates(ref),
                    icon: const Icon(Icons.save),
                    label: const Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _dolarKurController.text =
                          (rates?.dolarToTL ?? 0.0).toStringAsFixed(2);
                      _hasAltinController.text =
                          (rates?.gramHasGoldToTL ?? 0.0).toStringAsFixed(2);
                      _hurdaController.text = (rates?.gramWasteToTL ?? 0.0).toStringAsFixed(2);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Sıfırla'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ===== INFO SECTION =====
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'İpucu: Harem Altın API\'sinden otomatik kur çekme özelliği yakında eklenecek.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.amber.shade900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER: Display Rate Row
  // =========================================================================

  Widget _buildRateDisplayRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
        ),
      ],
    );
  }
}
