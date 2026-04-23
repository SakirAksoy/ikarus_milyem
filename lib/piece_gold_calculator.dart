// Piece-based Gold Jewelry Calculator
//
// For jewelry sold by piece count, not weight (e.g., 5 bracelets)
// Each piece has: adet (count) + iscilik (labor per piece)

class PieceGoldCalculator {
  /// Calculate total has gold value from piece jewelry
  /// 
  /// Parameters:
  /// - pieceCount: Number of pieces (int)
  /// - laborPerPiece: Labor weight per piece (gram)
  /// - milyem: Purity of the gold pieces
  /// - goldWeightPerPiece: Base weight of gold per piece excluding labor (gram)
  /// 
  /// Returns: Total has gold equivalent (gram)
  /// 
  /// Example:
  /// - 5 bracelets, each 10g of 995 milyem gold + 2g labor each
  /// - Total = 5 * (10 * 0.995 + 2) = 5 * 11.95 = 59.75g has gold
  static double calculateTotalHasGold({
    required int pieceCount,
    required double laborPerPiece,
    required int milyem,
    required double goldWeightPerPiece,
  }) {
    _validatePieceInput(pieceCount, laborPerPiece, milyem, goldWeightPerPiece);

    final purity = milyem / 1000.0;
    final purifiedGoldPerPiece = goldWeightPerPiece * purity;
    final totalHasGoldPerPiece = purifiedGoldPerPiece + laborPerPiece;
    final totalHasGold = totalHasGoldPerPiece * pieceCount;

    return _roundPrecise(totalHasGold);
  }

  /// Calculate cost/profit analysis for piece jewelry
  /// 
  /// Parameters:
  /// - pieceCount: Number of pieces
  /// - laborPerPiece: Labor weight per piece
  /// - milyem: Purity
  /// - goldWeightPerPiece: Gold weight per piece
  /// - costPricePerGramHasGold: Cost price in TL per gram has gold
  /// - sellingPricePerGramHasGold: Selling price in TL per gram has gold
  /// 
  /// Returns: {totalCost, totalSale, profit, profitPercent}
  static Map<String, double> calculateProfitAnalysis({
    required int pieceCount,
    required double laborPerPiece,
    required int milyem,
    required double goldWeightPerPiece,
    required double costPricePerGramHasGold,
    required double sellingPricePerGramHasGold,
  }) {
    _validatePieceInput(pieceCount, laborPerPiece, milyem, goldWeightPerPiece);
    if (costPricePerGramHasGold <= 0 || sellingPricePerGramHasGold <= 0) {
      throw ArgumentError('Prices must be positive');
    }

    final totalHasGold = calculateTotalHasGold(
      pieceCount: pieceCount,
      laborPerPiece: laborPerPiece,
      milyem: milyem,
      goldWeightPerPiece: goldWeightPerPiece,
    );

    final totalCost = totalHasGold * costPricePerGramHasGold;
    final totalSale = totalHasGold * sellingPricePerGramHasGold;
    final profit = totalSale - totalCost;
    final profitPercent = (profit / totalCost * 100);

    return {
      'totalHasGold': totalHasGold,
      'totalCost': _roundPrecise(totalCost),
      'totalSale': _roundPrecise(totalSale),
      'profit': _roundPrecise(profit),
      'profitPercent': _roundPrecise(profitPercent),
    };
  }

  /// Calculate labor cost contribution to final value
  /// 
  /// How much of the final price is due to labor (craftsmanship)?
  static double calculateLaborValue({
    required int pieceCount,
    required double laborPerPiece,
    required double valuePerGramHasGold,
  }) {
    if (pieceCount <= 0 || laborPerPiece < 0 || valuePerGramHasGold <= 0) {
      throw ArgumentError('Invalid input values');
    }

    final totalLaborGrams = pieceCount * laborPerPiece;
    final laborValue = totalLaborGrams * valuePerGramHasGold;

    return _roundPrecise(laborValue);
  }

  /// Calculate pure gold vs labor split in piece jewelry
  /// 
  /// Example output:
  /// {
  ///   pureGoldGrams: 49.75,
  ///   laborGrams: 10.0,
  ///   pureGoldPercent: 83.3,
  ///   laborPercent: 16.7
  /// }
  static Map<String, double> calculateComposition({
    required int pieceCount,
    required double laborPerPiece,
    required int milyem,
    required double goldWeightPerPiece,
  }) {
    _validatePieceInput(pieceCount, laborPerPiece, milyem, goldWeightPerPiece);

    final purity = milyem / 1000.0;
    final totalGoldWeight = pieceCount * goldWeightPerPiece;
    final totalLaborGrams = pieceCount * laborPerPiece;
    final totalPureGold = totalGoldWeight * purity;

    final totalHasGold = totalPureGold + totalLaborGrams;
    final pureGoldPercent = (totalPureGold / totalHasGold * 100);
    final laborPercent = (totalLaborGrams / totalHasGold * 100);

    return {
      'pureGoldGrams': _roundPrecise(totalPureGold),
      'laborGrams': _roundPrecise(totalLaborGrams),
      'totalHasGold': _roundPrecise(totalHasGold),
      'pureGoldPercent': _roundPrecise(pureGoldPercent),
      'laborPercent': _roundPrecise(laborPercent),
    };
  }

  /// Scale production: If we need 100g has gold, how many pieces?
  /// 
  /// Parameters:
  /// - targetHasGold: Target has gold amount (gram)
  /// - laborPerPiece: Labor per piece
  /// - milyem: Purity
  /// - goldWeightPerPiece: Gold per piece
  /// 
  /// Returns: Number of pieces needed (rounded up)
  static int calculatePiecesNeeded({
    required double targetHasGold,
    required double laborPerPiece,
    required int milyem,
    required double goldWeightPerPiece,
  }) {
    if (targetHasGold <= 0) {
      throw ArgumentError('Target has gold must be positive: $targetHasGold');
    }

    _validatePieceInput(1, laborPerPiece, milyem, goldWeightPerPiece);

    final purity = milyem / 1000.0;
    final hasGoldPerPiece = goldWeightPerPiece * purity + laborPerPiece;

    if (hasGoldPerPiece <= 0) {
      throw ArgumentError('Has gold per piece must be positive');
    }

    final piecesNeeded = (targetHasGold / hasGoldPerPiece).ceil();
    return piecesNeeded;
  }

  /// Batch update: Multiple products with same labor rate but different counts
  /// 
  /// Used when updating entire collection value
  static Map<String, double> batchCalculate({
    required List<({String name, int count, int milyem, double goldPerPiece, double laborPerPiece})> items,
    required double pricePerGramHasGold,
  }) {
    double totalHasGold = 0;
    double totalValue = 0;

    for (final item in items) {
      final itemHasGold = calculateTotalHasGold(
        pieceCount: item.count,
        laborPerPiece: item.laborPerPiece,
        milyem: item.milyem,
        goldWeightPerPiece: item.goldPerPiece,
      );

      totalHasGold += itemHasGold;
      totalValue += itemHasGold * pricePerGramHasGold;
    }

    return {
      'totalHasGold': _roundPrecise(totalHasGold),
      'totalValue': _roundPrecise(totalValue),
      'avgValuePerGram': _roundPrecise(totalValue / totalHasGold),
    };
  }

  // Validation helpers
  static void _validatePieceInput(
    int pieceCount,
    double laborPerPiece,
    int milyem,
    double goldWeightPerPiece,
  ) {
    if (pieceCount <= 0) {
      throw ArgumentError('Piece count must be positive: $pieceCount');
    }
    if (laborPerPiece < 0) {
      throw ArgumentError('Labor per piece cannot be negative: $laborPerPiece');
    }
    const validMilyems = {1000, 995, 916, 875, 750, 585, 333};
    if (!validMilyems.contains(milyem)) {
      throw ArgumentError('Invalid milyem: $milyem');
    }
    if (goldWeightPerPiece < 0) {
      throw ArgumentError('Gold weight per piece cannot be negative: $goldWeightPerPiece');
    }
  }

  /// Precise rounding to 2 decimal places
  static double _roundPrecise(double value) {
    return (value * 100).round() / 100.0;
  }
}
