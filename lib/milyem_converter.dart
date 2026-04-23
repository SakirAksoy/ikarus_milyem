// Milyem to Has Gold Conversion Engine
//
// Example calculations:
// - Raw gold (1000 milyem) + 0 gram labor = 1.0 * gram = has gold gram
// - 24 Karat (995 milyem) + 2g labor = 0.995 * (gram - 2) + (gram - 2) + 2 = ?
//
// Formula:
// hasGoldGram = (milyem / 1000) * goldGram + laborGram

class MilyemConverter {
  /// Converts milyem + labor to has gold equivalent
  /// 
  /// Parameters:
  /// - milyem: Purity level (1000, 995, 916, 875, 750, 585, 333)
  /// - goldGram: Total weight of the gold item (gram)
  /// - laborGram: Labor added during crafting (gram)
  /// 
  /// Returns: Equivalent has gold in grams (double, with high precision)
  /// 
  /// Example:
  /// 24 Karat (995) + 10 gram weight + 2 gram labor
  /// = (995/1000) * 10 + 2 = 0.995 * 10 + 2 = 9.95 + 2 = 11.95 grams has gold
  static double milyemToHasGold({
    required int milyem,
    required double goldGram,
    required double laborGram,
  }) {
    _validateMilyem(milyem);
    _validateGrams(goldGram, laborGram);

    final purity = milyem / 1000.0;
    final purifiedGold = goldGram * purity;
    final totalHasGold = purifiedGold + laborGram;

    return _roundPrecise(totalHasGold);
  }

  /// Reverse calculation: Has gold to milyem (for scrap gold estimation)
  /// 
  /// Parameters:
  /// - hasGoldGram: Total has gold equivalent
  /// - totalGram: Total weight (gold + labor)
  /// 
  /// Returns: Estimated milyem value (int)
  static int hasGoldToEstimatedMilyem({
    required double hasGoldGram,
    required double totalGram,
  }) {
    _validateGrams(hasGoldGram, totalGram);

    if (totalGram == 0) {
      return 1000; // Default to raw gold if no weight
    }

    final estimatedMilyem = (hasGoldGram / totalGram * 1000).round();
    return estimatedMilyem.clamp(0, 1000);
  }

  /// Extract pure gold weight from total weight given milyem
  /// 
  /// Useful for: "Given 10g of 995 milyem gold, how much pure gold is it?"
  static double extractPureGoldOnly({
    required int milyem,
    required double totalGram,
    required double laborGram,
  }) {
    _validateMilyem(milyem);
    _validateGrams(totalGram, laborGram);

    // Pure gold = total weight excluding labor, then apply milyem
    final goldWeightOnly = totalGram - laborGram;
    if (goldWeightOnly < 0) {
      throw ArgumentError(
        'Gold weight cannot be negative. Total: $totalGram, Labor: $laborGram',
      );
    }

    final purity = milyem / 1000.0;
    final pureGold = goldWeightOnly * purity;

    return _roundPrecise(pureGold);
  }

  /// Calculate labor weight from has gold equivalency
  /// 
  /// Reverse: If we know final has gold and original gold weight, what was labor?
  static double calculateImpliedLabor({
    required int milyem,
    required double goldGram,
    required double hasGoldResult,
  }) {
    _validateMilyem(milyem);
    _validateGrams(goldGram, 0);

    final purity = milyem / 1000.0;
    final purifiedGold = goldGram * purity;
    final impliedLabor = hasGoldResult - purifiedGold;

    return _roundPrecise(impliedLabor);
  }

  // Validation helpers
  static void _validateMilyem(int milyem) {
    const validMilyems = {1000, 995, 916, 875, 750, 585, 333};
    if (!validMilyems.contains(milyem)) {
      throw ArgumentError(
        'Invalid milyem: $milyem. Must be one of: $validMilyems',
      );
    }
  }

  static void _validateGrams(double goldGram, double laborGram) {
    if (goldGram < 0) {
      throw ArgumentError('Gold weight cannot be negative: $goldGram');
    }
    if (laborGram < 0) {
      throw ArgumentError('Labor weight cannot be negative: $laborGram');
    }
  }

  /// Precise rounding to 2 decimal places (0.01 gram precision)
  static double _roundPrecise(double value) {
    return (value * 100).round() / 100.0;
  }
}
