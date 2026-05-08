// Ayarlar modeli
class AyarlarModel {
  final String firmaAdi;
  final String fisNotu;
  final double milyem22;
  final double milyem18;
  final double milyem14;

  const AyarlarModel({
    required this.firmaAdi,
    required this.fisNotu,
    required this.milyem22,
    required this.milyem18,
    required this.milyem14,
  });

  AyarlarModel copyWith({
    String? firmaAdi,
    String? fisNotu,
    double? milyem22,
    double? milyem18,
    double? milyem14,
  }) {
    return AyarlarModel(
      firmaAdi: firmaAdi ?? this.firmaAdi,
      fisNotu: fisNotu ?? this.fisNotu,
      milyem22: milyem22 ?? this.milyem22,
      milyem18: milyem18 ?? this.milyem18,
      milyem14: milyem14 ?? this.milyem14,
    );
  }
}
