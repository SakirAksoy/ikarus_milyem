import 'package:test/test.dart';
import 'package:ikarus_milyem/milyem_converter.dart';
import 'package:ikarus_milyem/waste_gold_calculator.dart';
import 'package:ikarus_milyem/combined_payment_calculator.dart';
import 'package:ikarus_milyem/piece_gold_calculator.dart';

void main() {
  group('MilyemConverter Tests', () {
    test('Raw gold (1000 milyem) with no labor = same weight', () {
      final result = MilyemConverter.milyemToHasGold(
        milyem: 1000,
        goldGram: 10.0,
        laborGram: 0.0,
      );
      expect(result, 10.0);
    });

    test('24 Karat (995) with 2g labor', () {
      // 10g of 995 milyem + 2g labor
      // = (995/1000 * 10) + 2 = 9.95 + 2 = 11.95
      final result = MilyemConverter.milyemToHasGold(
        milyem: 995,
        goldGram: 10.0,
        laborGram: 2.0,
      );
      expect(result, 11.95);
    });

    test('22 Karat (916) conversion', () {
      // 50g of 916 + 5g labor = (50 * 0.916) + 5 = 45.8 + 5 = 50.8
      final result = MilyemConverter.milyemToHasGold(
        milyem: 916,
        goldGram: 50.0,
        laborGram: 5.0,
      );
      expect(result, 50.8);
    });

    test('18 Karat (750) with large labor component', () {
      // 100g of 750 + 50g labor = (100 * 0.75) + 50 = 75 + 50 = 125
      final result = MilyemConverter.milyemToHasGold(
        milyem: 750,
        goldGram: 100.0,
        laborGram: 50.0,
      );
      expect(result, 125.0);
    });

    test('8 Karat (333) - low purity', () {
      // 10g of 333 + 1g labor = (10 * 0.333) + 1 = 3.33 + 1 = 4.33
      final result = MilyemConverter.milyemToHasGold(
        milyem: 333,
        goldGram: 10.0,
        laborGram: 1.0,
      );
      expect(result, 4.33);
    });

    test('Precision to 2 decimal places', () {
      // (10 * 0.916) + 1.5 = 9.16 + 1.5 = 10.66
      final result = MilyemConverter.milyemToHasGold(
        milyem: 916,
        goldGram: 10.0,
        laborGram: 1.5,
      );
      expect(result, 10.66);
    });

    test('Invalid milyem throws error', () {
      expect(
        () => MilyemConverter.milyemToHasGold(
          milyem: 500, // Invalid
          goldGram: 10.0,
          laborGram: 1.0,
        ),
        throwsArgumentError,
      );
    });

    test('Negative gold weight throws error', () {
      expect(
        () => MilyemConverter.milyemToHasGold(
          milyem: 995,
          goldGram: -5.0,
          laborGram: 1.0,
        ),
        throwsArgumentError,
      );
    });

    test('Negative labor throws error', () {
      expect(
        () => MilyemConverter.milyemToHasGold(
          milyem: 995,
          goldGram: 10.0,
          laborGram: -1.0,
        ),
        throwsArgumentError,
      );
    });

    test('hasGoldToEstimatedMilyem - reverse calculation', () {
      // If we have 11.95g has gold from 12g total (10g gold + 2g labor)
      // Estimated milyem should be close to 995
      final estimated = MilyemConverter.hasGoldToEstimatedMilyem(
        hasGoldGram: 11.95,
        totalGram: 12.0,
      );
      expect(estimated, 996); // Rounded from 995.83
    });

    test('extractPureGoldOnly calculation', () {
      // 10g 995 milyem, 2g labor => pure gold = (10-2) * 0.995 = 7.96
      final pureGold = MilyemConverter.extractPureGoldOnly(
        milyem: 995,
        totalGram: 10.0,
        laborGram: 2.0,
      );
      expect(pureGold, 7.96);
    });

    test('calculateImpliedLabor - reverse labor calculation', () {
      // Knowing: 995 milyem, 10g gold, result is 11.95g has gold
      // Implied labor = 11.95 - (10 * 0.995) = 11.95 - 9.95 = 2.0
      final impliedLabor = MilyemConverter.calculateImpliedLabor(
        milyem: 995,
        goldGram: 10.0,
        hasGoldResult: 11.95,
      );
      expect(impliedLabor, 2.0);
    });
  });

  group('WasteGoldCalculator Tests', () {
    test('Basic waste to has gold conversion', () {
      // 100g waste at 750 milyem, no loss = 100 * 0.75 = 75g
      final result = WasteGoldCalculator.wasteToHasGold(
        gramWeight: 100.0,
        estimatedMilyem: 750,
        refinementLoss: 0.0,
      );
      expect(result, 75.0);
    });

    test('Waste with refinement loss', () {
      // 100g waste at 750 milyem, 2% loss
      // = 100 * 0.75 * (1 - 0.02) = 75 * 0.98 = 73.5g
      final result = WasteGoldCalculator.wasteToHasGold(
        gramWeight: 100.0,
        estimatedMilyem: 750,
        refinementLoss: 0.02,
      );
      expect(result, 73.5);
    });

    test('Mixed waste lots averaging', () {
      // Mix: 30g at 750 + 20g at 916
      // Average = (30*750 + 20*916) / 50 = (22500 + 18320) / 50 = 822.8
      final milyem = WasteGoldCalculator.calculateMixedWasteMilyem([
        (gramWeight: 30.0, milyem: 750),
        (gramWeight: 20.0, milyem: 916),
      ]);
      expect(milyem, 823); // Rounded
    });

    test('Mixed waste total has gold calculation', () {
      // 30g at 750 + 20g at 916, 0% loss
      // = (30 * 0.75) + (20 * 0.916) = 22.5 + 18.32 = 40.82g
      final total = WasteGoldCalculator.calculateMixedWasteTotalHasGold(
        lots: [
          (gramWeight: 30.0, milyem: 750),
          (gramWeight: 20.0, milyem: 916),
        ],
        refinementLoss: 0.0,
      );
      expect(total, 40.82);
    });

    test('Scrap processing result', () {
      // 100g scrap at 750 milyem, 3% processing loss
      // = 100 * 0.75 * (1 - 0.03) = 72.75g
      final result = WasteGoldCalculator.scrapProcessingResult(
        originalWaste: 100.0,
        milyem: 750,
        processingLoss: 0.03,
      );
      expect(result, 72.75);
    });

    test('Invalid refinement loss throws error', () {
      expect(
        () => WasteGoldCalculator.wasteToHasGold(
          gramWeight: 100.0,
          estimatedMilyem: 750,
          refinementLoss: 0.2, // > 15%
        ),
        throwsArgumentError,
      );
    });

    test('hasGoldToWasteNeeded calculation', () {
      // Need 50g has gold from 750 milyem waste, 2% loss
      // = 50 / (0.75 * 0.98) = 50 / 0.735 = 68.03g waste
      final waste = WasteGoldCalculator.hasGoldToWasteNeeded(
        targetHasGold: 50.0,
        estimatedMilyem: 750,
        refinementLoss: 0.02,
      );
      expect(waste, greaterThan(67.0));
      expect(waste, lessThan(69.0));
    });
  });

  group('CombinedPaymentCalculator Tests', () {
    late CombinedPaymentCalculator calc;

    setUp(() {
      calc = CombinedPaymentCalculator(
        dolarToTL: 35.50,
        gramHasGoldToTL: 2500.0,
        gramWasteToTL: 1200.0,
      );
    });

    test('Convert TL to USD', () {
      // 100,000 TL / 35.50 = 2816.90 USD
      final usd = calc.convertFromTL(100000.0, 'USD');
      expect(usd, closeTo(2816.90, 0.1));
    });

    test('Convert USD to TL', () {
      // 100 USD * 35.50 = 3550 TL
      final tl = calc.convertToTL(100.0, 'USD');
      expect(tl, 3550.0);
    });

    test('Convert has gold to TL', () {
      // 10g has gold * 2500 TL/g = 25000 TL
      final tl = calc.convertToTL(10.0, 'HAS_GOLD');
      expect(tl, 25000.0);
    });

    test('Convert waste gold to TL', () {
      // 20g waste * 1200 TL/g = 24000 TL
      final tl = calc.convertToTL(20.0, 'WASTE');
      expect(tl, 24000.0);
    });

    test('Calculate mixed payment total', () {
      // 50000 TL + 10 USD + 5g has gold + 10g waste
      // = 50000 + 355 + 12500 + 12000 = 74855 TL
      final total = calc.calculateTotalPaymentTL([
        (amount: 50000.0, type: 'TL'),
        (amount: 10.0, type: 'USD'),
        (amount: 5.0, type: 'HAS_GOLD'),
        (amount: 10.0, type: 'WASTE'),
      ]);
      expect(total, 74855.0);
    });

    test('Verify payment covers debt', () {
      final covers = calc.verifyPaymentCovers(
        debtTL: 50000.0,
        payments: [
          (amount: 1000.0, type: 'TL'),
          (amount: 1.0, type: 'USD'),
          (amount: 17.5, type: 'HAS_GOLD'),
        ],
      );
      // 1000 + 35.5 + 43750 = 44785.5 < 50000, should not cover
      expect(covers, false);
    });

    test('Split debt across currencies', () {
      final split = calc.splitDebtAcrossCurrencies(
        debtTL: 105000.0,
        paymentTypes: ['TL', 'USD', 'HAS_GOLD'],
      );

      // Each should cover 35000 TL
      expect(split['TL']!, closeTo(35000.0, 0.1));
      expect(split['USD']!, closeTo(985.9, 0.1));
      expect(split['HAS_GOLD']!, closeTo(14.0, 0.1));
    });

    test('Calculate gold discount percent', () {
      // Full: 100g has gold, Paid: 98g has gold
      // Discount = (100 - 98) / 100 * 100 = 2%
      final discount = calc.calculateGoldDiscountPercent(
        fullValueHasGold: 100.0,
        paidHasGold: 98.0,
      );
      expect(discount, 2.0);
    });

    test('Calculate mixed gifts to has gold', () {
      // 30g waste (750 milyem) + 100 TL + 1 USD
      // Waste: 30 * 0.75 = 22.5g has gold
      // Money: (100 + 35.5) / 2500 = 0.054g has gold
      // Total ≈ 22.554g has gold
      final total = calc.calculateMixedGiftsToHasGoldEquivalent(
        gifts: [
          (amount: 30.0, type: 'WASTE', milyem: 750),
          (amount: 100.0, type: 'TL', milyem: null),
          (amount: 1.0, type: 'USD', milyem: null),
        ],
      );
      expect(total, greaterThan(22.5));
      expect(total, lessThan(22.6));
    });

    test('Invalid exchange rate throws error', () {
      expect(
        () => CombinedPaymentCalculator(
          dolarToTL: -10.0, // Negative
          gramHasGoldToTL: 2500.0,
          gramWasteToTL: 1200.0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('PieceGoldCalculator Tests', () {
    test('Calculate total has gold for piece jewelry', () {
      // 5 pieces, each 10g of 995 milyem + 2g labor
      // = 5 * ((10 * 0.995) + 2) = 5 * 11.95 = 59.75g
      final total = PieceGoldCalculator.calculateTotalHasGold(
        pieceCount: 5,
        laborPerPiece: 2.0,
        milyem: 995,
        goldWeightPerPiece: 10.0,
      );
      expect(total, 59.75);
    });

    test('Calculate profit analysis', () {
      final analysis = PieceGoldCalculator.calculateProfitAnalysis(
        pieceCount: 5,
        laborPerPiece: 2.0,
        milyem: 995,
        goldWeightPerPiece: 10.0,
        costPricePerGramHasGold: 2000.0,
        sellingPricePerGramHasGold: 2500.0,
      );

      expect(analysis['totalHasGold'], 59.75);
      expect(analysis['totalCost'], 119500.0); // 59.75 * 2000
      expect(analysis['totalSale'], 149375.0); // 59.75 * 2500
      expect(analysis['profit'], 29875.0);
      expect(analysis['profitPercent'], closeTo(25.0, 0.1));
    });

    test('Calculate labor value contribution', () {
      // 10 pieces, 2.5g labor each, 2500 TL/g
      // = 10 * 2.5 * 2500 = 62500 TL
      final laborValue = PieceGoldCalculator.calculateLaborValue(
        pieceCount: 10,
        laborPerPiece: 2.5,
        valuePerGramHasGold: 2500.0,
      );
      expect(laborValue, 62500.0);
    });

    test('Calculate composition split', () {
      final comp = PieceGoldCalculator.calculateComposition(
        pieceCount: 5,
        laborPerPiece: 2.0,
        milyem: 995,
        goldWeightPerPiece: 10.0,
      );

      expect(comp['pureGoldGrams'], closeTo(49.75, 0.01));
      expect(comp['laborGrams'], 10.0);
      expect(comp['totalHasGold'], 59.75);
      expect(comp['pureGoldPercent'], closeTo(83.27, 0.1));
      expect(comp['laborPercent'], closeTo(16.73, 0.1));
    });

    test('Calculate pieces needed for target has gold', () {
      // Each piece: (10 * 0.995) + 2 = 11.95g has gold
      // For 100g target: 100 / 11.95 = 8.37, round up to 9 pieces
      final pieces = PieceGoldCalculator.calculatePiecesNeeded(
        targetHasGold: 100.0,
        laborPerPiece: 2.0,
        milyem: 995,
        goldWeightPerPiece: 10.0,
      );
      expect(pieces, 9);
    });

    test('Batch calculate multiple products', () {
      final batch = PieceGoldCalculator.batchCalculate(
        items: [
          (
            name: 'Bracelet',
            count: 5,
            milyem: 995,
            goldPerPiece: 10.0,
            laborPerPiece: 2.0,
          ),
          (
            name: 'Ring',
            count: 10,
            milyem: 916,
            goldPerPiece: 3.0,
            laborPerPiece: 1.0,
          ),
        ],
        pricePerGramHasGold: 2500.0,
      );

      // Bracelet: 5 * (10*0.995 + 2) = 59.75g
      // Ring: 10 * (3*0.916 + 1) = 39.48g
      // Total: 99.23g
      expect(batch['totalHasGold'], closeTo(99.23, 0.1));
      expect(
        batch['totalValue'],
        closeTo(99.23 * 2500, 1.0),
      );
    });

    test('Invalid piece count throws error', () {
      expect(
        () => PieceGoldCalculator.calculateTotalHasGold(
          pieceCount: 0, // Invalid
          laborPerPiece: 2.0,
          milyem: 995,
          goldWeightPerPiece: 10.0,
        ),
        throwsArgumentError,
      );
    });
  });
}
