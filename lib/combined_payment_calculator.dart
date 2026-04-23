// Combined/Mixed Payment Calculator
//
// Handles transactions where payment is in multiple currencies/assets:
// TL (Turkish Lira), USD (Dollar), Has Gold, Waste Gold

class CombinedPaymentCalculator {
  /// Exchange rates needed for calculation
  final double dolarToTL;          // 1 USD = ? TL
  final double gramHasGoldToTL;    // 1g has gold = ? TL
  final double gramWasteToTL;      // 1g waste gold = ? TL

  CombinedPaymentCalculator({
    required this.dolarToTL,
    required this.gramHasGoldToTL,
    required this.gramWasteToTL,
  }) {
    if (dolarToTL <= 0 || gramHasGoldToTL <= 0 || gramWasteToTL <= 0) {
      throw ArgumentError('All exchange rates must be positive');
    }
  }

  /// Convert any payment type to TL equivalent
  /// 
  /// Parameters:
  /// - amount: Quantity of payment
  /// - paymentType: "TL", "USD", "HAS_GOLD", "WASTE"
  /// 
  /// Returns: Equivalent value in TL
  double convertToTL(double amount, String paymentType) {
    if (amount < 0) {
      throw ArgumentError('Payment amount cannot be negative: $amount');
    }

    switch (paymentType.toUpperCase()) {
      case 'TL':
        return amount;
      case 'USD':
      case 'DOLAR':
        return amount * dolarToTL;
      case 'HAS_GOLD':
      case 'HAS_ALTIN':
        return amount * gramHasGoldToTL;
      case 'WASTE':
      case 'HURDA':
        return amount * gramWasteToTL;
      default:
        throw ArgumentError('Unknown payment type: $paymentType');
    }
  }

  /// Convert TL to any payment type
  /// 
  /// Reverse of convertToTL
  double convertFromTL(double tlAmount, String targetType) {
    if (tlAmount < 0) {
      throw ArgumentError('TL amount cannot be negative: $tlAmount');
    }

    switch (targetType.toUpperCase()) {
      case 'TL':
        return tlAmount;
      case 'USD':
      case 'DOLAR':
        return _roundPrecise(tlAmount / dolarToTL);
      case 'HAS_GOLD':
      case 'HAS_ALTIN':
        return _roundPrecise(tlAmount / gramHasGoldToTL);
      case 'WASTE':
      case 'HURDA':
        return _roundPrecise(tlAmount / gramWasteToTL);
      default:
        throw ArgumentError('Unknown payment type: $targetType');
    }
  }

  /// Calculate total payment in TL from mixed payment list
  /// 
  /// Example payment list:
  /// - 100 TL
  /// - 2 USD
  /// - 5g has gold
  /// - 10g waste gold
  /// = 100 + (2 * 35.5) + (5 * 2500) + (10 * 1200) TL
  double calculateTotalPaymentTL(
    List<({double amount, String type})> payments,
  ) {
    if (payments.isEmpty) {
      throw ArgumentError('At least one payment required');
    }

    double totalTL = 0;

    for (final payment in payments) {
      totalTL += convertToTL(payment.amount, payment.type);
    }

    return _roundPrecise(totalTL);
  }

  /// Convert total TL payment into equivalent amounts of different currencies
  /// 
  /// Useful for: "Customer wants to pay 150,000 TL. How much in USD and gold?"
  double convertTLToType(double tlAmount, String targetType) {
    return convertFromTL(tlAmount, targetType);
  }

  /// Calculate discount/markup in has gold terms
  /// 
  /// Example: Item worth 50g has gold, but customer pays 48g has gold (4% discount)
  double calculateGoldDiscountPercent({
    required double fullValueHasGold,
    required double paidHasGold,
  }) {
    if (fullValueHasGold <= 0) {
      throw ArgumentError('Full value must be positive: $fullValueHasGold');
    }
    if (paidHasGold < 0) {
      throw ArgumentError('Paid amount cannot be negative: $paidHasGold');
    }

    final discountPercent = ((fullValueHasGold - paidHasGold) / fullValueHasGold);
    return _roundPrecise(discountPercent * 100);
  }

  /// Complex payment: Customer provides mixed items, needs calculation
  /// 
  /// Example:
  /// - Customer gives: 30g waste (750 milyem) + 100 TL + 1 USD
  /// - How much has gold equivalent?
  double calculateMixedGiftsToHasGoldEquivalent({
    required List<({double amount, String type, int? milyem})> gifts,
  }) {
    if (gifts.isEmpty) {
      return 0;
    }

    double totalHasGold = 0;

    for (final gift in gifts) {
      if (gift.type.toUpperCase() == 'WASTE' || gift.type.toUpperCase() == 'HURDA') {
        // Waste gold conversion
        final hasGoldValue = gift.amount * (gift.milyem ?? 750) / 1000.0;
        totalHasGold += hasGoldValue;
      } else {
        // Other currencies -> TL -> has gold
        final tlValue = convertToTL(gift.amount, gift.type);
        final hasGoldFromTL = tlValue / gramHasGoldToTL;
        totalHasGold += hasGoldFromTL;
      }
    }

    return _roundPrecise(totalHasGold);
  }

  /// Multi-currency balance check
  /// 
  /// Used in accounting: "Total debt was 10000 TL, paid in mixed currencies"
  bool verifyPaymentCovers({
    required double debtTL,
    required List<({double amount, String type})> payments,
  }) {
    final totalPaid = calculateTotalPaymentTL(payments);
    return totalPaid >= (debtTL - 0.01); // Allow tiny rounding error
  }

  /// Payment plan calculator - split debt across multiple payments
  /// 
  /// If total debt in TL, calculate how much of each currency needed
  Map<String, double> splitDebtAcrossCurrencies({
    required double debtTL,
    required List<String> paymentTypes,
  }) {
    if (paymentTypes.isEmpty) {
      throw ArgumentError('At least one payment type required');
    }

    // Split equally
    final perTypeAmount = debtTL / paymentTypes.length;
    final result = <String, double>{};

    for (final type in paymentTypes) {
      result[type] = convertFromTL(perTypeAmount, type);
    }

    return result;
  }

  /// Debug: Print current exchange rates
  @override
  String toString() => '''
CombinedPaymentCalculator:
  1 USD = $dolarToTL TL
  1g Has Gold = $gramHasGoldToTL TL
  1g Waste Gold = $gramWasteToTL TL
''';

  /// Precise rounding to 2 decimal places
  static double _roundPrecise(double value) {
    return (value * 100).round() / 100.0;
  }
}
