import 'package:cloud_firestore/cloud_firestore.dart';

class StokModel {
  final String id;
  final String urunAdi;
  final String urunKodu;
  final double milyem;
  final double toplamGram;
  final int toplamAdet;
  final String urunGrubu;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StokModel({
    required this.id,
    required this.urunAdi,
    required this.urunKodu,
    required this.milyem,
    this.toplamGram = 0.0,
    this.toplamAdet = 0,
    required this.urunGrubu,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'urunAdi': urunAdi,
      'urunKodu': urunKodu,
      'milyem': milyem,
      'toplamGram': toplamGram,
      'toplamAdet': toplamAdet,
      'urunGrubu': urunGrubu,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory StokModel.fromMap(Map<String, dynamic> map, String docId) {
    return StokModel(
      id: docId,
      urunAdi: map['urunAdi'] ?? '',
      urunKodu: map['urunKodu'] ?? '',
      milyem: (map['milyem'] ?? 0.0).toDouble(),
      toplamGram: (map['toplamGram'] ?? 0.0).toDouble(),
      toplamAdet: map['toplamAdet'] ?? 0,
      urunGrubu: map['urunGrubu'] ?? 'Diğer',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  StokModel copyWith({
    String? id,
    String? urunAdi,
    String? urunKodu,
    double? milyem,
    double? toplamGram,
    int? toplamAdet,
    String? urunGrubu,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StokModel(
      id: id ?? this.id,
      urunAdi: urunAdi ?? this.urunAdi,
      urunKodu: urunKodu ?? this.urunKodu,
      milyem: milyem ?? this.milyem,
      toplamGram: toplamGram ?? this.toplamGram,
      toplamAdet: toplamAdet ?? this.toplamAdet,
      urunGrubu: urunGrubu ?? this.urunGrubu,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'StokModel(id: $id, urunAdi: $urunAdi, milyem: $milyem, toplamGram: $toplamGram, toplamAdet: $toplamAdet)';
  }
}
