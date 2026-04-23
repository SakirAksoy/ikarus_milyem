// Waste Gold (Hurda) Calculation Engine
//
// Handles scraps, old jewelry, and refined waste gold.
// Key challenge: We don't always know the exact milyem of scrap.

class WasteGoldCalculator {
  /// Calculate has gold equivalent from scrap gold
  /// 
  /// Parameters:
  /// - gramWeight: Total weight of scrap gold (gram)
  /// - estimatedMilyem: Estimated purity (e.g., 750 for old mixed jewelry)
  /// - refinementLoss: Expected loss during refining (0-10%, default 0%)
  /// 
  /// Returns: Equivalent has gold after refinement (gram)
  /// 
  /// Example:
  /// - 100g scrap at estimated 750 milyem
  /// - Refinement loss: 2%
  /// - = (750/1000) * 100 * (1 - 0.02) = 73.5 grams has gold
  static double wasteToHasGold({
    required double gramWeight,
    required int estimatedMilyem,
    double refinementLoss = 0.0,
  }) {
    _validateWasteInput(gramWeight, estimatedMilyem, refinementLoss);

    final purity = estimatedMilyem / 1000.0;
    final hasGoldBefore = gramWeight * purity;
    final hasGoldAfter = hasGoldBefore * (1.0 - refinementLoss);

    return _roundPrecise(hasGoldAfter);
  }

  /// Reverse: Calculate how much scrap gold needed to get target has gold
  /// 
  /// Example: We need 50g has gold. We have scrap at ~750 milyem. How much scrap?
  /// = 50 / (750/1000) / (1 - 0.02) = 68.49g scrap needed
  static double hasGoldToWasteNeeded({
    required double targetHasGold,
    required int estimatedMilyem,
    double refinementLoss = 0.0,
  }) {
    _validateWasteInput(targetHasGold, estimatedMilyem, refinementLoss);

    final purity = estimatedMilyem / 1000.0;
    final refinementFactor = 1.0 - refinementLoss;

    if (purity <= 0 || refinementFactor <= 0) {
      throw ArgumentError('Invalid purity or refinement factor');
    }

    final wasteNeeded = targetHasGold / purity / refinementFactor;
    return _roundPrecise(wasteNeeded);
  }

  /// When mixing waste of different purities
  /// 
  /// Parameters:
  /// - lots: List of {gramWeight, milyem} for each waste batch
  /// 
  /// Returns: Average milyem of mixed waste
  /// 
  /// Example:
  /// - 30g at 750 milyem
  /// - 20g at 916 milyem
  /// - Average = (30*750 + 20*916) / (30+20) = 822.8 milyem
  static int calculateMixedWasteMilyem(
    List<({double gramWeight, int milyem})> lots,
  ) {
    if (lots.isEmpty) {
      throw ArgumentError('At least one waste lot required');
    }

    double totalHasGold = 0;
    double totalWeight = 0;

    for (final lot in lots) {
      _validateWasteInput(lot.gramWeight, lot.milyem, 0);
      totalWeight += lot.gramWeight;
      final purity = lot.milyem / 1000.0;
      totalHasGold += lot.gramWeight * purity;
    }

    if (totalWeight == 0) {
      throw ArgumentError('Total weight cannot be zero');
    }

    final averageMilyem = (totalHasGold / totalWeight * 1000).round();
    return averageMilyem.clamp(0, 1000);
  }

  /// Calculate total has gold from multiple waste lots after mixing and refining
  static double calculateMixedWasteTotalHasGold({
    required List<({double gramWeight, int milyem})> lots,
    double refinementLoss = 0.0,
  }) {
    if (lots.isEmpty) {
      throw ArgumentError('At least one waste lot required');
    }

    _validateRefinementLoss(refinementLoss);

    double totalHasGold = 0;

    for (final lot in lots) {
      _validateWasteInput(lot.gramWeight, lot.milyem, refinementLoss);
      final purity = lot.milyem / 1000.0;
      totalHasGold += lot.gramWeight * purity;
    }

    // Apply refinement loss once to total
    final finalHasGold = totalHasGold * (1.0 - refinementLoss);
    return _roundPrecise(finalHasGold);
  }

  /// Scrap waste reduction calculation
  /// 
  /// When you take scrap gold for recycling, calculate what you get back
  /// Parameters:
  /// - originalWaste: Original weight (gram)
  /// - milyem: Estimated purity
  /// - processingLoss: Loss due to refining (%)
  /// 
  /// Returns: Weight of pure gold after processing
  static double scrapProcessingResult({
    required double originalWaste,
    required int milyem,
    required double processingLoss,
  }) {
    return wasteToHasGold(
      gramWeight: originalWaste,
      estimatedMilyem: milyem,
      refinementLoss: processingLoss,
    );
  }

  // Validation helpers
  static void _validateWasteInput(
    double gramWeight,
    int milyem,
    double refinementLoss,
  ) {
    if (gramWeight < 0) {
      throw ArgumentError('Waste weight cannot be negative: $gramWeight');
    }
    const validMilyems = {1000, 995, 916, 875, 750, 585, 333};
    if (!validMilyems.contains(milyem)) {
      throw ArgumentError('Invalid milyem for waste: $milyem');
    }
    _validateRefinementLoss(refinementLoss);
  }

  static void _validateRefinementLoss(double loss) {
    if (loss < 0 || loss > 0.15) {
      throw ArgumentError(
        'Refinement loss must be 0-15%: ${(loss * 100).toStringAsFixed(1)}%',
      );
    }
  }

  /// Precise rounding to 2 decimal places
  static double _roundPrecise(double value) {
    return (value * 100).round() / 100.0;
  }
}
