import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'milyem_converter.dart';
import 'waste_gold_calculator.dart';
import 'combined_payment_calculator.dart';
import 'piece_gold_calculator.dart';

// ============================================================================
// CALCULATOR PROVIDERS - Dependency Injection
// ============================================================================

// Milyem Converter Provider (Stateless - always available)
final milyemConverterProvider = Provider((ref) {
  return MilyemConverter();
});

// Waste Gold Calculator Provider
final wasteGoldCalculatorProvider = Provider((ref) {
  return WasteGoldCalculator();
});

// Combined Payment Calculator Provider (requires exchange rates)
// Exchange rates would typically come from database/API
final combinedPaymentCalculatorProvider = Provider<CombinedPaymentCalculator?>((ref) {
  // This will be updated with actual rates from Firestore
  // For now, returning null until rates are available
  return null;
});

// Piece Gold Calculator Provider
final pieceGoldCalculatorProvider = Provider((ref) {
  return PieceGoldCalculator();
});

// ============================================================================
// EXCHANGE RATES STATE - For CombinedPaymentCalculator
// ============================================================================

class ExchangeRates {
  final double dolarToTL;
  final double gramHasGoldToTL;
  final double gramWasteToTL;
  final DateTime timestamp;

  ExchangeRates({
    required this.dolarToTL,
    required this.gramHasGoldToTL,
    required this.gramWasteToTL,
    required this.timestamp,
  });
}

// Exchange rates state (can be updated from Firestore)
final exchangeRatesProvider = StateNotifierProvider<
    ExchangeRatesNotifier,
    ExchangeRates?>((ref) {
  return ExchangeRatesNotifier();
});

class ExchangeRatesNotifier extends StateNotifier<ExchangeRates?> {
  ExchangeRatesNotifier()
      : super(ExchangeRates(
          dolarToTL: 35.50,
          gramHasGoldToTL: 2500.0,
          gramWasteToTL: 1200.0,
          timestamp: DateTime.now(),
        ));

  void updateRates({
    required double dolarToTL,
    required double gramHasGoldToTL,
    required double gramWasteToTL,
  }) {
    state = ExchangeRates(
      dolarToTL: dolarToTL,
      gramHasGoldToTL: gramHasGoldToTL,
      gramWasteToTL: gramWasteToTL,
      timestamp: DateTime.now(),
    );
  }
}

// Combined Payment Calculator with rates
final calculatorWithRatesProvider =
    Provider<CombinedPaymentCalculator?>((ref) {
  final rates = ref.watch(exchangeRatesProvider);
  
  if (rates == null) {
    return null;
  }

  return CombinedPaymentCalculator(
    dolarToTL: rates.dolarToTL,
    gramHasGoldToTL: rates.gramHasGoldToTL,
    gramWasteToTL: rates.gramWasteToTL,
  );
});
