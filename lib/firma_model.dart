import 'package:cloud_firestore/cloud_firestore.dart';

class FirmaModel {
  final String id;
  final String name;
  final DateTime kurulusTarihi;
  final int musteriSayisi;
  final double toplamKasa;
  final List<String> ortaklar;
  final DateTime createdAt;
  final DateTime updatedAt;

  FirmaModel({
    required this.id,
    required this.name,
    required this.kurulusTarihi,
    required this.musteriSayisi,
    required this.toplamKasa,
    required this.ortaklar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FirmaModel.fromJson(Map<String, dynamic> json) {
    return FirmaModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      kurulusTarihi: _parseTimestamp(json['kurulusTarihi']),
      musteriSayisi: json['musteriSayisi'] as int? ?? 0,
      toplamKasa: (json['toplamKasa'] as num?)?.toDouble() ?? 0.0,
      ortaklar: List<String>.from(json['ortaklar'] as List? ?? []),
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kurulusTarihi': kurulusTarihi,
      'musteriSayisi': musteriSayisi,
      'toplamKasa': toplamKasa,
      'ortaklar': ortaklar,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  FirmaModel copyWith({
    String? id,
    String? name,
    DateTime? kurulusTarihi,
    int? musteriSayisi,
    double? toplamKasa,
    List<String>? ortaklar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FirmaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      kurulusTarihi: kurulusTarihi ?? this.kurulusTarihi,
      musteriSayisi: musteriSayisi ?? this.musteriSayisi,
      toplamKasa: toplamKasa ?? this.toplamKasa,
      ortaklar: ortaklar ?? this.ortaklar,
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
