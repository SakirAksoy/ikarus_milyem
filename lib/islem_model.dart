import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

// ============================================================================
// ÖDEME TÜRÜ (Payment Type)
// ============================================================================

class OdemeTuru {
  final ParaTuru turuPara;
  final double miktar;
  final String? aciklamasi;

  OdemeTuru({
    required this.turuPara,
    required this.miktar,
    this.aciklamasi,
  });

  factory OdemeTuru.fromJson(Map<String, dynamic> json) {
    return OdemeTuru(
      turuPara: ParaTuru.fromJson(json['turuPara'] as String? ?? 'tl'),
      miktar: (json['miktar'] as num?)?.toDouble() ?? 0.0,
      aciklamasi: json['aciklamasi'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'turuPara': turuPara.toJson(),
      'miktar': miktar,
      'aciklamasi': aciklamasi,
    };
  }

  OdemeTuru copyWith({
    ParaTuru? turuPara,
    double? miktar,
    String? aciklamasi,
  }) {
    return OdemeTuru(
      turuPara: turuPara ?? this.turuPara,
      miktar: miktar ?? this.miktar,
      aciklamasi: aciklamasi ?? this.aciklamasi,
    );
  }
}

// ============================================================================
// ÜRÜN (Product)
// ============================================================================

class Urun {
  final String ad;
  final int milyem;
  final double gram;
  final double iscilik;

  Urun({
    required this.ad,
    required this.milyem,
    required this.gram,
    required this.iscilik,
  });

  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      ad: json['ad'] as String? ?? '',
      milyem: json['milyem'] as int? ?? 995,
      gram: (json['gram'] as num?)?.toDouble() ?? 0.0,
      iscilik: (json['iscilik'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ad': ad,
      'milyem': milyem,
      'gram': gram,
      'iscilik': iscilik,
    };
  }

  Urun copyWith({
    String? ad,
    int? milyem,
    double? gram,
    double? iscilik,
  }) {
    return Urun(
      ad: ad ?? this.ad,
      milyem: milyem ?? this.milyem,
      gram: gram ?? this.gram,
      iscilik: iscilik ?? this.iscilik,
    );
  }
}

// ============================================================================
// GÜNCELLEME (Update/Revision History)
// ============================================================================

class Guncelleme {
  final DateTime tarih;
  final String kullaniciId;
  final String degisiklik;

  Guncelleme({
    required this.tarih,
    required this.kullaniciId,
    required this.degisiklik,
  });

  factory Guncelleme.fromJson(Map<String, dynamic> json) {
    return Guncelleme(
      tarih: _parseTimestamp(json['tarih']),
      kullaniciId: json['kullaniciId'] as String? ?? '',
      degisiklik: json['degisiklik'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tarih': tarih,
      'kullaniciId': kullaniciId,
      'degisiklik': degisiklik,
    };
  }
}

// ============================================================================
// İŞLEM MODELİ (Transaction/Fiş) - FAZ 3 COMPLEX MODEL
// ============================================================================
//
// Müşteri alış/satış işlemlerini kayıt eden kompleks model
// Ürünler, ödeme türleri ve altın hesaplamaları içerir

class IslemModel {
  final String? id;
  final FisTipi fisTipi;
  final DateTime tarihSaat;
  final String musteriId;
  final List<OdemeTuru> odemeTurleri;
  final List<Urun> urunler;
  final double toplamHasAltinGram;
  final double toplamIscilik;
  final String? aciklamasi;
  final String kullanimiId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Guncelleme> guncellemeler;

  IslemModel({
    this.id,
    required this.fisTipi,
    required this.tarihSaat,
    required this.musteriId,
    required this.odemeTurleri,
    required this.urunler,
    required this.toplamHasAltinGram,
    required this.toplamIscilik,
    this.aciklamasi,
    required this.kullanimiId,
    required this.createdAt,
    required this.updatedAt,
    List<Guncelleme>? guncellemeler,
  }) : guncellemeler = guncellemeler ?? [];

  factory IslemModel.fromJson(Map<String, dynamic> json) {
    return IslemModel(
      id: json['id'] as String?,
      fisTipi: FisTipi.fromJson(json['fisTipi'] as String? ?? 'satis'),
      tarihSaat: _parseTimestamp(json['tarihSaat']),
      musteriId: json['musteriId'] as String? ?? 'SISTEM',
      odemeTurleri: (json['odemeTurleri'] as List?)
              ?.map((e) => OdemeTuru.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      urunler: (json['urunler'] as List?)
              ?.map((e) => Urun.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      toplamHasAltinGram: (json['toplamHasAltinGram'] as num?)?.toDouble() ?? 0.0,
      toplamIscilik: (json['toplamIscilik'] as num?)?.toDouble() ?? 0.0,
      aciklamasi: json['aciklamasi'] as String?,
      kullanimiId: json['kullanimiId'] as String? ?? '',
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      guncellemeler: (json['guncellemeler'] as List?)
              ?.map((e) => Guncelleme.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fisTipi': fisTipi.toJson(),
      'tarihSaat': tarihSaat.toIso8601String(),
      'musteriId': musteriId,
      'odemeTurleri': odemeTurleri.map((e) => e.toJson()).toList(),
      'urunler': urunler.map((e) => e.toJson()).toList(),
      'toplamHasAltinGram': toplamHasAltinGram,
      'toplamIscilik': toplamIscilik,
      'aciklamasi': aciklamasi,
      'kullanimiId': kullanimiId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'guncellemeler': guncellemeler.map((e) => e.toJson()).toList(),
    };
  }

  IslemModel copyWith({
    String? id,
    FisTipi? fisTipi,
    DateTime? tarihSaat,
    String? musteriId,
    List<OdemeTuru>? odemeTurleri,
    List<Urun>? urunler,
    double? toplamHasAltinGram,
    double? toplamIscilik,
    String? aciklamasi,
    String? kullanimiId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Guncelleme>? guncellemeler,
  }) {
    return IslemModel(
      id: id ?? this.id,
      fisTipi: fisTipi ?? this.fisTipi,
      tarihSaat: tarihSaat ?? this.tarihSaat,
      musteriId: musteriId ?? this.musteriId,
      odemeTurleri: odemeTurleri ?? this.odemeTurleri,
      urunler: urunler ?? this.urunler,
      toplamHasAltinGram: toplamHasAltinGram ?? this.toplamHasAltinGram,
      toplamIscilik: toplamIscilik ?? this.toplamIscilik,
      aciklamasi: aciklamasi ?? this.aciklamasi,
      kullanimiId: kullanimiId ?? this.kullanimiId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      guncellemeler: guncellemeler ?? this.guncellemeler,
    );
  }

  @override
  String toString() =>
      'IslemModel(id: $id, fisTipi: ${fisTipi.toJson()}, musteriId: $musteriId, toplamHasAltin: $toplamHasAltinGram, toplamIscilik: $toplamIscilik)';
}

// ============================================================================
// TIMESTAMP PARSER
// =========================================================================

DateTime _parseTimestamp(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is DateTime) {
    return value;
  } else if (value is String) {
    return DateTime.parse(value);
  }
  return DateTime.now();
}


