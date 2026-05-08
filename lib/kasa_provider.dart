import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// KASA PROVIDER - Cash Management
// ============================================================================
//
// Manages TL, USD, and EUR cash balances with deposit/withdrawal operations

class KasaModel {
  final double tlBakiye;
  final double usdBakiye;
  final double eurBakiye;
  final List<Map<String, dynamic>> giderler;

  const KasaModel({
    this.tlBakiye = 0.0,
    this.usdBakiye = 0.0,
    this.eurBakiye = 0.0,
    this.giderler = const [],
  });

  KasaModel copyWith({
    double? tlBakiye,
    double? usdBakiye,
    double? eurBakiye,
    List<Map<String, dynamic>>? giderler,
  }) {
    return KasaModel(
      tlBakiye: tlBakiye ?? this.tlBakiye,
      usdBakiye: usdBakiye ?? this.usdBakiye,
      eurBakiye: eurBakiye ?? this.eurBakiye,
      giderler: giderler ?? this.giderler,
    );
  }
}

class KasaNotifier extends StateNotifier<KasaModel> {
  KasaNotifier() : super(const KasaModel());

  void paraGirisi({
    required String dovizTipi,
    required double tutar,
  }) {
    switch (dovizTipi) {
      case 'TL':
        state = state.copyWith(tlBakiye: state.tlBakiye + tutar);
        break;
      case 'USD':
        state = state.copyWith(usdBakiye: state.usdBakiye + tutar);
        break;
      case 'EUR':
        state = state.copyWith(eurBakiye: state.eurBakiye + tutar);
        break;
    }
  }

  void paraCikisi({
    required String dovizTipi,
    required double tutar,
  }) {
    switch (dovizTipi) {
      case 'TL':
        state = state.copyWith(tlBakiye: state.tlBakiye - tutar);
        break;
      case 'USD':
        state = state.copyWith(usdBakiye: state.usdBakiye - tutar);
        break;
      case 'EUR':
        state = state.copyWith(eurBakiye: state.eurBakiye - tutar);
        break;
    }
  }

  void giderEkle({
    required String aciklama,
    required double tutar,
    required String dovizCinsi,
  }) {
    // Bakiyeden gideri düş
    paraCikisi(dovizTipi: dovizCinsi, tutar: tutar);

    // Giderleri listeye ekle
    final yeniGiderler = [
      ...state.giderler,
      {
        'aciklama': aciklama,
        'tutar': tutar,
        'dovizCinsi': dovizCinsi,
        'tarih': DateTime.now().toIso8601String(),
      },
    ];

    state = state.copyWith(giderler: yeniGiderler);
  }
}

final kasaProvider = StateNotifierProvider<KasaNotifier, KasaModel>((ref) {
  return KasaNotifier();
});
