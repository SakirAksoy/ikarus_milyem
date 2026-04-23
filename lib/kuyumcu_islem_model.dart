import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// KUYUMCU İŞLEM MODELİ - TEK BİRLEŞİK MODEL
// ============================================================================
//
// Müşteri/Toptancı carileri "Has Altın Gramı" üzerinden yönetir.
// Tüm işlemler (satış, alış, ödeme) Has Altın karşılığına dönüştürülür.

enum IslemTipi {
  satis,      // Müşteriye ürün satışı → Müşteri borca girer
  alis,       // Müşteriden ürün/hurda alımı → Müşteri alacaklandırılır
  odemeAlma,  // Müşteriden nakit/hurda tahsilat
  odemeYapma; // Müşteriye nakit ödeme

  String toJson() => name;
  static IslemTipi fromJson(String json) => 
    IslemTipi.values.firstWhere((e) => e.name == json, orElse: () => satis);
}

enum UrunTipi {
  gramajli,  // Gramajlı ürün (bilezik, kolye vs.)
  adetli,    // Adetli ürün (yüzük, küpe vs.)
  hurda,     // Hurda alım/satım
  nakit;     // Nakit ödeme (TL/Dolar)

  String toJson() => name;
  static UrunTipi fromJson(String json) =>
    UrunTipi.values.firstWhere((e) => e.name == json, orElse: () => gramajli);
}

enum HurdaTipi {
  ayar22,    // 22 Ayar (916 milyem, makasta 906)
  ayar14;    // 14 Ayar (585 milyem, makasta 575)

  int get gercekMilyem {
    switch (this) {
      case ayar22: return 916;
      case ayar14: return 585;
    }
  }

  int get makasliMilyem {
    switch (this) {
      case ayar22: return 906;  // 10 puan makası
      case ayar14: return 575;  // 10 puan makası
    }
  }

  String toJson() => name;
  static HurdaTipi fromJson(String json) =>
    HurdaTipi.values.firstWhere((e) => e.name == json, orElse: () => ayar22);
}

// ============================================================================
// KUYUMCU İŞLEM MODELİ
// ============================================================================

class KuyumcuIslemModel {
  final String? id; // Firestore doc ID
  final String musteriId; // Müşteri ID (kuyumcu cari sistemi ile link)
  final String musteriAdi; // Müşteri adı
  final IslemTipi islemTipi; // Satış/Alış/OdemeAlma/OdemeYapma
  final UrunTipi urunTipi; // Gramajlı/Adetli/Hurda/Nakit
  
  // Ürün Özellikleri
  final int? urunMilyemi; // Ürünün milyemi (585, 750, 916 vb.)
  final double? iscilikMilyemi; // Gramajlı: işçilik milyemi (0.001-1.0)
  final double? parcaIscilikGrami; // Adetli: parça başı işçilik (gram)
  final double? gram; // Ürün/Hurda gramajı
  final int? adet; // Adet (sadece adetli ürünler için)
  final HurdaTipi? hurdaTipi; // Hurda tipi (22 Ayar/14 Ayar)
  
  // Ödeme Özellikleri
  final double? odemeMiktari; // Nakit ödeme miktarı (TL/Dolar)
  final String? odemeTuru; // "TL" veya "Dolar"
  final double? hasAltinKuru; // O günün Has Altın Kuru
  
  // Hesaplanan Has Altın Karşılığı
  final double hasAltinKarsiligi; // EN ÖNEMLİ: Tüm işlemin Has Altın gramaja dönüştürülmüş değeri
  
  // Tarihçe
  final DateTime islemTarihi;
  final DateTime createdAt;
  final DateTime updatedAt;

  KuyumcuIslemModel({
    this.id,
    required this.musteriId,
    required this.musteriAdi,
    required this.islemTipi,
    required this.urunTipi,
    this.urunMilyemi,
    this.iscilikMilyemi,
    this.parcaIscilikGrami,
    this.gram,
    this.adet,
    this.hurdaTipi,
    this.odemeMiktari,
    this.odemeTuru,
    this.hasAltinKuru,
    required this.hasAltinKarsiligi,
    required this.islemTarihi,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // =========================================================================
  // JSON SERIALIZATION
  // =========================================================================

  Map<String, dynamic> toJson() => {
        'id': id,
        'musteriId': musteriId,
        'musteriAdi': musteriAdi,
        'islemTipi': islemTipi.toJson(),
        'urunTipi': urunTipi.toJson(),
        'urunMilyemi': urunMilyemi,
        'iscilikMilyemi': iscilikMilyemi,
        'parcaIscilikGrami': parcaIscilikGrami,
        'gram': gram,
        'adet': adet,
        'hurdaTipi': hurdaTipi?.toJson(),
        'odemeMiktari': odemeMiktari,
        'odemeTuru': odemeTuru,
        'hasAltinKuru': hasAltinKuru,
        'hasAltinKarsiligi': hasAltinKarsiligi,
        'islemTarihi': islemTarihi.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory KuyumcuIslemModel.fromJson(Map<String, dynamic> json) =>
      KuyumcuIslemModel(
        id: json['id'] as String?,
        musteriId: json['musteriId'] as String? ?? 'sistem',
        musteriAdi: json['musteriAdi'] as String? ?? 'Sistem',
        islemTipi: IslemTipi.fromJson(json['islemTipi'] as String? ?? 'satis'),
        urunTipi: UrunTipi.fromJson(json['urunTipi'] as String? ?? 'gramajli'),
        urunMilyemi: json['urunMilyemi'] as int?,
        iscilikMilyemi: (json['iscilikMilyemi'] as num?)?.toDouble(),
        parcaIscilikGrami: (json['parcaIscilikGrami'] as num?)?.toDouble(),
        gram: (json['gram'] as num?)?.toDouble(),
        adet: json['adet'] as int?,
        hurdaTipi: json['hurdaTipi'] != null
            ? HurdaTipi.fromJson(json['hurdaTipi'] as String)
            : null,
        odemeMiktari: (json['odemeMiktari'] as num?)?.toDouble(),
        odemeTuru: json['odemeTuru'] as String?,
        hasAltinKuru: (json['hasAltinKuru'] as num?)?.toDouble(),
        hasAltinKarsiligi:
            (json['hasAltinKarsiligi'] as num?)?.toDouble() ?? 0.0,
        islemTarihi: json['islemTarihi'] is String
            ? DateTime.parse(json['islemTarihi'] as String)
            : DateTime.now(),
        createdAt: json['createdAt'] is String
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] is String
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );

  // =========================================================================
  // COPYSWITH
  // =========================================================================

  KuyumcuIslemModel copyWith({
    String? id,
    String? musteriId,
    String? musteriAdi,
    IslemTipi? islemTipi,
    UrunTipi? urunTipi,
    int? urunMilyemi,
    double? iscilikMilyemi,
    double? parcaIscilikGrami,
    double? gram,
    int? adet,
    HurdaTipi? hurdaTipi,
    double? odemeMiktari,
    String? odemeTuru,
    double? hasAltinKuru,
    double? hasAltinKarsiligi,
    DateTime? islemTarihi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      KuyumcuIslemModel(
        id: id ?? this.id,
        musteriId: musteriId ?? this.musteriId,
        musteriAdi: musteriAdi ?? this.musteriAdi,
        islemTipi: islemTipi ?? this.islemTipi,
        urunTipi: urunTipi ?? this.urunTipi,
        urunMilyemi: urunMilyemi ?? this.urunMilyemi,
        iscilikMilyemi: iscilikMilyemi ?? this.iscilikMilyemi,
        parcaIscilikGrami: parcaIscilikGrami ?? this.parcaIscilikGrami,
        gram: gram ?? this.gram,
        adet: adet ?? this.adet,
        hurdaTipi: hurdaTipi ?? this.hurdaTipi,
        odemeMiktari: odemeMiktari ?? this.odemeMiktari,
        odemeTuru: odemeTuru ?? this.odemeTuru,
        hasAltinKuru: hasAltinKuru ?? this.hasAltinKuru,
        hasAltinKarsiligi: hasAltinKarsiligi ?? this.hasAltinKarsiligi,
        islemTarihi: islemTarihi ?? this.islemTarihi,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() =>
      'KuyumcuIslem(müşteri: $musteriAdi, tipi: ${islemTipi.name}, ürün: ${urunTipi.name}, hasKarşılık: ${hasAltinKarsiligi.toStringAsFixed(2)} gr)';
}
