import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

// ============================================================================
// İŞLEM MODELİ (Simplified for Giriş/Çıkış)
// ============================================================================

class IslemModel {
  final String? id; // Firestore doc ID (auto-generated)
  final String musteriId; // Müşteri ID
  final String musteriAdi; // Müşteri adı
  final IslemTipi islemTipi; // Giriş (Dükkana giren) / Çıkış (Dükkandan çıkan)
  final String stokId; // Seçilen stok ID
  final String stokAdi; // Stok adı
  final double miktar; // Girilen miktar (gram/tutar/tane)
  final double kur; // O anki kur (referans)
  final double toplamTutar; // Hesaplanan toplam (TL)
  final ParaTuru odemeSekli; // Ödeme şekli
  final DateTime islemTarihi; // İşlem tarihi ve saati

  IslemModel({
    this.id,
    required this.musteriId,
    required this.musteriAdi,
    required this.islemTipi,
    required this.stokId,
    required this.stokAdi,
    required this.miktar,
    required this.kur,
    required this.toplamTutar,
    required this.odemeSekli,
    required this.islemTarihi,
  });

  // =========================================================================
  // JSON SERIALIZATION
  // =========================================================================

  Map<String, dynamic> toJson() => {
        'id': id,
        'musteriId': musteriId,
        'musteriAdi': musteriAdi,
        'islemTipi': islemTipi.toJson(),
        'stokId': stokId,
        'stokAdi': stokAdi,
        'miktar': miktar,
        'kur': kur,
        'toplamTutar': toplamTutar,
        'odemeSekli': odemeSekli.toJson(),
        'islemTarihi': islemTarihi.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory IslemModel.fromJson(Map<String, dynamic> json) => IslemModel(
        id: json['id'] as String?,
        musteriId: json['musteriId'] as String? ?? 'sistem',
        musteriAdi: json['musteriAdi'] as String? ?? 'Sistem',
        islemTipi: _parseIslemTipi(json['islemTipi'] as String?),
        stokId: json['stokId'] as String? ?? '',
        stokAdi: json['stokAdi'] as String? ?? '',
        miktar: (json['miktar'] as num?)?.toDouble() ?? 0.0,
        kur: (json['kur'] as num?)?.toDouble() ?? 0.0,
        toplamTutar: (json['toplamTutar'] as num?)?.toDouble() ?? 0.0,
        odemeSekli: ParaTuru.fromJson(json['odemeSekli'] as String? ?? 'tl'),
        islemTarihi: json['islemTarihi'] is String
            ? DateTime.parse(json['islemTarihi'] as String)
            : DateTime.now(),
      );

  // =========================================================================
  // HELPER - IslemTipi Parse
  // =========================================================================

  static IslemTipi _parseIslemTipi(String? value) {
    if (value == null) return IslemTipi.giris;
    try {
      return IslemTipi.values.firstWhere((e) => e.toJson() == value);
    } catch (_) {
      return IslemTipi.giris;
    }
  }

  // =========================================================================
  // COPYSWITH
  // =========================================================================

  IslemModel copyWith({
    String? id,
    String? musteriId,
    String? musteriAdi,
    IslemTipi? islemTipi,
    String? stokId,
    String? stokAdi,
    double? miktar,
    double? kur,
    double? toplamTutar,
    ParaTuru? odemeSekli,
    DateTime? islemTarihi,
  }) =>
      IslemModel(
        id: id ?? this.id,
        musteriId: musteriId ?? this.musteriId,
        musteriAdi: musteriAdi ?? this.musteriAdi,
        islemTipi: islemTipi ?? this.islemTipi,
        stokId: stokId ?? this.stokId,
        stokAdi: stokAdi ?? this.stokAdi,
        miktar: miktar ?? this.miktar,
        kur: kur ?? this.kur,
        toplamTutar: toplamTutar ?? this.toplamTutar,
        odemeSekli: odemeSekli ?? this.odemeSekli,
        islemTarihi: islemTarihi ?? this.islemTarihi,
      );

  @override
  String toString() =>
      'IslemModel(müşteri: $musteriAdi, tipi: ${islemTipi.toJson()}, stok: $stokId, miktar: $miktar)';
}
