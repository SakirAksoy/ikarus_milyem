import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

// ============================================================================
// İŞLEM MODELİ (Transaction/Fiş Model) - GÜNCELLENMIŞ
// ============================================================================
//
// Firestore'da islemler koleksiyonunda depolanacak işlem dokümanı
// Müşteri bazlı giriş (alım) ve çıkış (satış) işlemlerini kayıt eder

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
// YENİ: BASİT İŞLEM MODELİ (Simple Transaction Model)
// ============================================================================
//
// Müşteri bazlı giriş/çıkış işlemleri için basitleştirilmiş model

class IslemModel {
  final String? id; // Firestore doc ID (auto-generated)
  final FisTipi islemTipi; // Alış/Satış
  final String musteriId; // Müşteri ID (zorunlu)
  final String musteriAdi; // Müşteri adı (zorunlu)
  final DateTime tarihSaat; // İşlem tarihi ve saati
  final String stokId; // Seçilen stok/kasa ID
  final String stokAdi; // Stok/kasa adı
  final double miktar; // Miktar (gram/tutar/tane)
  final double kur; // O anki kur (referans)
  final double toplamTutar; // Hesaplanan toplam tutar (TL)
  final ParaTuru odemeSekli; // Ödeme şekli
  final String? aciklamasi; // Opsiyonel açıklama
  final DateTime createdAt; // Oluşturma tarihi
  final DateTime updatedAt; // Güncelleme tarihi
  final List<Guncelleme> guncellemeler; // Değişim geçmişi

  IslemModel({
    this.id,
    required this.islemTipi,
    required this.musteriId,
    required this.musteriAdi,
    required this.tarihSaat,
    required this.stokId,
    required this.stokAdi,
    required this.miktar,
    required this.kur,
    required this.toplamTutar,
    required this.odemeSekli,
    this.aciklamasi,
    required this.createdAt,
    required this.updatedAt,
    List<Guncelleme>? guncellemeler,
  }) : guncellemeler = guncellemeler ?? [];

  // =========================================================================
  // JSON SERIALIZATION
  // =========================================================================

  factory IslemModel.fromJson(Map<String, dynamic> json) {
    return IslemModel(
      id: json['id'] as String?,
      islemTipi: FisTipi.fromJson(json['islemTipi'] as String? ?? 'alim'),
      musteriId: json['musteriId'] as String? ?? 'SISTEM',
      musteriAdi: json['musteriAdi'] as String? ?? 'Bilinmeyen',
      tarihSaat: _parseTimestamp(json['tarihSaat']),
      stokId: json['stokId'] as String? ?? '',
      stokAdi: json['stokAdi'] as String? ?? '',
      miktar: (json['miktar'] as num?)?.toDouble() ?? 0.0,
      kur: (json['kur'] as num?)?.toDouble() ?? 0.0,
      toplamTutar: (json['toplamTutar'] as num?)?.toDouble() ?? 0.0,
      odemeSekli: ParaTuru.fromJson(json['odemeSekli'] as String? ?? 'tl'),
      aciklamasi: json['aciklamasi'] as String?,
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
      'islemTipi': islemTipi.toJson(),
      'musteriId': musteriId,
      'musteriAdi': musteriAdi,
      'tarihSaat': tarihSaat.toIso8601String(),
      'stokId': stokId,
      'stokAdi': stokAdi,
      'miktar': miktar,
      'kur': kur,
      'toplamTutar': toplamTutar,
      'odemeSekli': odemeSekli.toJson(),
      'aciklamasi': aciklamasi,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'guncellemeler': guncellemeler.map((e) => e.toJson()).toList(),
    };
  }

  // =========================================================================
  // COPYWITH
  // =========================================================================

  IslemModel copyWith({
    String? id,
    FisTipi? islemTipi,
    String? musteriId,
    String? musteriAdi,
    DateTime? tarihSaat,
    String? stokId,
    String? stokAdi,
    double? miktar,
    double? kur,
    double? toplamTutar,
    ParaTuru? odemeSekli,
    String? aciklamasi,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Guncelleme>? guncellemeler,
  }) {
    return IslemModel(
      id: id ?? this.id,
      islemTipi: islemTipi ?? this.islemTipi,
      musteriId: musteriId ?? this.musteriId,
      musteriAdi: musteriAdi ?? this.musteriAdi,
      tarihSaat: tarihSaat ?? this.tarihSaat,
      stokId: stokId ?? this.stokId,
      stokAdi: stokAdi ?? this.stokAdi,
      miktar: miktar ?? this.miktar,
      kur: kur ?? this.kur,
      toplamTutar: toplamTutar ?? this.toplamTutar,
      odemeSekli: odemeSekli ?? this.odemeSekli,
      aciklamasi: aciklamasi ?? this.aciklamasi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      guncellemeler: guncellemeler ?? this.guncellemeler,
    );
  }

  @override
  String toString() =>
      'IslemModel(id: $id, musteri: $musteriAdi, tipi: ${islemTipi.toJson()}, stok: $stokId, miktar: $miktar, tutar: $toplamTutar TL)';
}

// =========================================================================
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
