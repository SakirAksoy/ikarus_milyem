import 'package:cloud_firestore/cloud_firestore.dart';

class MusteriModel {
  final String id;
  final String adSoyad;
  final String firmaAdi;
  final String? telefon;
  final String? adres;
  final double toplamHasBakiye;
  final DateTime? sonIslemTarihi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MusteriModel({
    required this.id,
    required this.adSoyad,
    this.firmaAdi = '',
    this.telefon,
    this.adres,
    this.toplamHasBakiye = 0.0,
    this.sonIslemTarihi,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adSoyad': adSoyad,
      'firmaAdi': firmaAdi,
      'telefon': telefon,
      'adres': adres,
      'toplamHasBakiye': toplamHasBakiye,
      'sonIslemTarihi': sonIslemTarihi,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory MusteriModel.fromJson(Map<String, dynamic> json, String docId) {
    return MusteriModel(
      id: docId,
      adSoyad: json['adSoyad'] ?? '',
      firmaAdi: json['firmaAdi'] ?? '',
      telefon: json['telefon'],
      adres: json['adres'],
      toplamHasBakiye: (json['toplamHasBakiye'] ?? 0.0).toDouble(),
      sonIslemTarihi: json['sonIslemTarihi'] != null 
        ? (json['sonIslemTarihi'] as Timestamp).toDate() 
        : null,
      createdAt: json['createdAt'] != null 
        ? (json['createdAt'] as Timestamp).toDate() 
        : null,
      updatedAt: json['updatedAt'] != null 
        ? (json['updatedAt'] as Timestamp).toDate() 
        : null,
    );
  }

  MusteriModel copyWith({
    String? id,
    String? adSoyad,
    String? firmaAdi,
    String? telefon,
    String? adres,
    double? toplamHasBakiye,
    DateTime? sonIslemTarihi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MusteriModel(
      id: id ?? this.id,
      adSoyad: adSoyad ?? this.adSoyad,
      firmaAdi: firmaAdi ?? this.firmaAdi,
      telefon: telefon ?? this.telefon,
      adres: adres ?? this.adres,
      toplamHasBakiye: toplamHasBakiye ?? this.toplamHasBakiye,
      sonIslemTarihi: sonIslemTarihi ?? this.sonIslemTarihi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MusteriModel(id: $id, adSoyad: $adSoyad, firmaAdi: $firmaAdi, toplamHasBakiye: $toplamHasBakiye)';
  }

  // Status getters for UI
  bool get isBorcu => toplamHasBakiye < 0;
  bool get isAlacakli => toplamHasBakiye > 0;
  bool get isSifir => toplamHasBakiye == 0;
}


