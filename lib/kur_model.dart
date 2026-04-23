import 'package:cloud_firestore/cloud_firestore.dart';

class KurModel {
  final String id;
  final DateTime tarih;              // Hangi güne ait
  final double dolarTL;              // 1 Dolar = ? TL
  final double gramHasAltinTL;       // 1 Gram Has Altın = ? TL
  final double gramHurdaTL;          // 1 Gram Hurda = ? TL
  final String kaynak;               // "MANUEL" veya "HAREM_ALTIN_API"
  final DateTime createdAt;
  final DateTime updatedAt;

  KurModel({
    required this.id,
    required this.tarih,
    required this.dolarTL,
    required this.gramHasAltinTL,
    required this.gramHurdaTL,
    required this.kaynak,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KurModel.fromJson(Map<String, dynamic> json) {
    return KurModel(
      id: json['id'] as String? ?? '',
      tarih: _parseTimestamp(json['tarih']),
      dolarTL: (json['dolarTL'] as num?)?.toDouble() ?? 0.0,
      gramHasAltinTL: (json['gramHasAltinTL'] as num?)?.toDouble() ?? 0.0,
      gramHurdaTL: (json['gramHurdaTL'] as num?)?.toDouble() ?? 0.0,
      kaynak: json['kaynak'] as String? ?? 'MANUEL',
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tarih': tarih,
      'dolarTL': dolarTL,
      'gramHasAltinTL': gramHasAltinTL,
      'gramHurdaTL': gramHurdaTL,
      'kaynak': kaynak,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  KurModel copyWith({
    String? id,
    DateTime? tarih,
    double? dolarTL,
    double? gramHasAltinTL,
    double? gramHurdaTL,
    String? kaynak,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KurModel(
      id: id ?? this.id,
      tarih: tarih ?? this.tarih,
      dolarTL: dolarTL ?? this.dolarTL,
      gramHasAltinTL: gramHasAltinTL ?? this.gramHasAltinTL,
      gramHurdaTL: gramHurdaTL ?? this.gramHurdaTL,
      kaynak: kaynak ?? this.kaynak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

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
