import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'enums.dart';

// ============================================================================
// ISLEM FORM STATE
// ============================================================================

class IslemFormState {
  final FisTipi fisTipi;
  final String musteriId;
  final List<UrunInput> urunler;
  final List<OdemeInput> odemeler;
  final String? aciklama;
  final String? errorMessage;
  final bool isSubmitting;

  IslemFormState({
    required this.fisTipi,
    required this.musteriId,
    required this.urunler,
    required this.odemeler,
    this.aciklama,
    this.errorMessage,
    this.isSubmitting = false,
  });

  IslemFormState copyWith({
    FisTipi? fisTipi,
    String? musteriId,
    List<UrunInput>? urunler,
    List<OdemeInput>? odemeler,
    String? aciklama,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return IslemFormState(
      fisTipi: fisTipi ?? this.fisTipi,
      musteriId: musteriId ?? this.musteriId,
      urunler: urunler ?? this.urunler,
      odemeler: odemeler ?? this.odemeler,
      aciklama: aciklama ?? this.aciklama,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  bool get isValid =>
      musteriId.isNotEmpty &&
      urunler.isNotEmpty &&
      odemeler.isNotEmpty &&
      errorMessage == null;
}

class UrunInput {
  final String ad;
  final int milyem;
  final double gram;
  final double iscilik;

  UrunInput({
    required this.ad,
    required this.milyem,
    required this.gram,
    required this.iscilik,
  });
}

class OdemeInput {
  final String turuPara;
  final double miktar;

  OdemeInput({
    required this.turuPara,
    required this.miktar,
  });
}

// ============================================================================
// ISLEM FORM NOTIFIER
// ============================================================================

class IslemFormNotifier extends StateNotifier<IslemFormState> {
  IslemFormNotifier()
      : super(IslemFormState(
          fisTipi: FisTipi.satis,
          musteriId: '',
          urunler: [],
          odemeler: [],
        ));

  void setFisTipi(FisTipi fisTipi) {
    state = state.copyWith(fisTipi: fisTipi);
  }

  void setMusteri(String musteriId) {
    if (musteriId.isEmpty) {
      state = state.copyWith(
        musteriId: musteriId,
        errorMessage: 'Müşteri seçilmesi zorunludur',
      );
    } else {
      state = state.copyWith(
        musteriId: musteriId,
        errorMessage: null,
      );
    }
  }

  void addUrun({
    required String ad,
    required int milyem,
    required double gram,
    required double iscilik,
  }) {
    if (ad.isEmpty || gram <= 0) {
      state = state.copyWith(
        errorMessage: 'Ürün bilgileri geçersiz',
      );
      return;
    }

    final newUrunler = [...state.urunler];
    newUrunler.add(
      UrunInput(
        ad: ad,
        milyem: milyem,
        gram: gram,
        iscilik: iscilik,
      ),
    );

    state = state.copyWith(
      urunler: newUrunler,
      errorMessage: null,
    );
  }

  void removeUrun(int index) {
    if (index < 0 || index >= state.urunler.length) return;

    final newUrunler = [...state.urunler];
    newUrunler.removeAt(index);

    state = state.copyWith(urunler: newUrunler);
  }

  void addOdeme({
    required String turuPara,
    required double miktar,
  }) {
    if (miktar <= 0) {
      state = state.copyWith(
        errorMessage: 'Ödeme miktarı pozitif olmalıdır',
      );
      return;
    }

    final newOdemeler = [...state.odemeler];
    newOdemeler.add(
      OdemeInput(
        turuPara: turuPara,
        miktar: miktar,
      ),
    );

    state = state.copyWith(
      odemeler: newOdemeler,
      errorMessage: null,
    );
  }

  void removeOdeme(int index) {
    if (index < 0 || index >= state.odemeler.length) return;

    final newOdemeler = [...state.odemeler];
    newOdemeler.removeAt(index);

    state = state.copyWith(odemeler: newOdemeler);
  }

  void setAciklama(String aciklama) {
    state = state.copyWith(aciklama: aciklama.isEmpty ? null : aciklama);
  }

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void reset() {
    state = IslemFormState(
      fisTipi: FisTipi.satis,
      musteriId: '',
      urunler: [],
      odemeler: [],
    );
  }
}

// ============================================================================
// KUR (EXCHANGE RATES) FORM STATE
// ============================================================================

class KurFormState {
  final double dolarToTL;
  final double gramHasGoldToTL;
  final double gramWasteToTL;
  final String? errorMessage;
  final bool isSubmitting;

  KurFormState({
    required this.dolarToTL,
    required this.gramHasGoldToTL,
    required this.gramWasteToTL,
    this.errorMessage,
    this.isSubmitting = false,
  });

  KurFormState copyWith({
    double? dolarToTL,
    double? gramHasGoldToTL,
    double? gramWasteToTL,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return KurFormState(
      dolarToTL: dolarToTL ?? this.dolarToTL,
      gramHasGoldToTL: gramHasGoldToTL ?? this.gramHasGoldToTL,
      gramWasteToTL: gramWasteToTL ?? this.gramWasteToTL,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  bool get isValid =>
      dolarToTL > 0 &&
      gramHasGoldToTL > 0 &&
      gramWasteToTL > 0 &&
      errorMessage == null;
}

// ============================================================================
// KUR FORM NOTIFIER
// ============================================================================

class KurFormNotifier extends StateNotifier<KurFormState> {
  KurFormNotifier()
      : super(KurFormState(
          dolarToTL: 35.50,
          gramHasGoldToTL: 2500.0,
          gramWasteToTL: 1200.0,
        ));

  void setDolarToTL(double value) {
    if (value <= 0) {
      state = state.copyWith(
        errorMessage: 'Dolar kuru pozitif olmalıdır',
      );
    } else {
      state = state.copyWith(
        dolarToTL: value,
        errorMessage: null,
      );
    }
  }

  void setGramHasGoldToTL(double value) {
    if (value <= 0) {
      state = state.copyWith(
        errorMessage: 'Has altın kuru pozitif olmalıdır',
      );
    } else {
      state = state.copyWith(
        gramHasGoldToTL: value,
        errorMessage: null,
      );
    }
  }

  void setGramWasteToTL(double value) {
    if (value <= 0) {
      state = state.copyWith(
        errorMessage: 'Hurda kuru pozitif olmalıdır',
      );
    } else {
      state = state.copyWith(
        gramWasteToTL: value,
        errorMessage: null,
      );
    }
  }

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void reset() {
    state = KurFormState(
      dolarToTL: 35.50,
      gramHasGoldToTL: 2500.0,
      gramWasteToTL: 1200.0,
    );
  }
}

// ============================================================================
// RIVERPOD PROVIDERS - Form State Management
// ============================================================================

// Islem Form Provider
final islemFormProvider =
    StateNotifierProvider<IslemFormNotifier, IslemFormState>((ref) {
  return IslemFormNotifier();
});

// Kur Form Provider
final kurFormProvider =
    StateNotifierProvider<KurFormNotifier, KurFormState>((ref) {
  return KurFormNotifier();
});
