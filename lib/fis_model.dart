import 'package:cloud_firestore/cloud_firestore.dart';

enum IslemTipiFis { satis, alis, manuel }

class FisModel {
  final String id;
  final String fisNo;
  final String musteriAd;
  final String musteriTelefon;
  final DateTime tarih;
  final IslemTipiFis islemTipi;
  final String ayar;
  final double hasGram;
  final double tlTutar;
  final String odemeTipi;
  final String? notlar;

  FisModel({
    required this.id,
    required this.fisNo,
    required this.musteriAd,
    required this.musteriTelefon,
    required this.tarih,
    required this.islemTipi,
    required this.ayar,
    required this.hasGram,
    required this.tlTutar,
    required this.odemeTipi,
    this.notlar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fisNo': fisNo,
      'musteriAd': musteriAd,
      'musteriTelefon': musteriTelefon,
      'tarih': tarih.toIso8601String(),
      'islemTipi': islemTipi.toString().split('.').last,
      'ayar': ayar,
      'hasGram': hasGram,
      'tlTutar': tlTutar,
      'odemeTipi': odemeTipi,
      'notlar': notlar,
    };
  }

  static FisModel fromMap(Map<String, dynamic> map) {
    return FisModel(
      id: map['id'] ?? '',
      fisNo: map['fisNo'] ?? '',
      musteriAd: map['musteriAd'] ?? '',
      musteriTelefon: map['musteriTelefon'] ?? '',
      tarih: map['tarih'] is Timestamp
          ? (map['tarih'] as Timestamp).toDate()
          : DateTime.parse(map['tarih'] ?? DateTime.now().toIso8601String()),
      islemTipi: _parseIslemTipi(map['islemTipi']),
      ayar: map['ayar'] ?? '',
      hasGram: (map['hasGram'] ?? 0.0).toDouble(),
      tlTutar: (map['tlTutar'] ?? 0.0).toDouble(),
      odemeTipi: map['odemeTipi'] ?? '',
      notlar: map['notlar'],
    );
  }

  static IslemTipiFis _parseIslemTipi(String? str) {
    switch (str) {
      case 'satis':
        return IslemTipiFis.satis;
      case 'alis':
        return IslemTipiFis.alis;
      case 'manuel':
        return IslemTipiFis.manuel;
      default:
        return IslemTipiFis.manuel;
    }
  }

  FisModel copyWith({
    String? id,
    String? fisNo,
    String? musteriAd,
    String? musteriTelefon,
    DateTime? tarih,
    IslemTipiFis? islemTipi,
    String? ayar,
    double? hasGram,
    double? tlTutar,
    String? odemeTipi,
    String? notlar,
  }) {
    return FisModel(
      id: id ?? this.id,
      fisNo: fisNo ?? this.fisNo,
      musteriAd: musteriAd ?? this.musteriAd,
      musteriTelefon: musteriTelefon ?? this.musteriTelefon,
      tarih: tarih ?? this.tarih,
      islemTipi: islemTipi ?? this.islemTipi,
      ayar: ayar ?? this.ayar,
      hasGram: hasGram ?? this.hasGram,
      tlTutar: tlTutar ?? this.tlTutar,
      odemeTipi: odemeTipi ?? this.odemeTipi,
      notlar: notlar ?? this.notlar,
    );
  }
}
