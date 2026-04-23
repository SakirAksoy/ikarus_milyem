import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'enums.dart';

// ============================================================================
// CAR İ İŞLEM PROVIDER - Firebase Backend Entegrasyonu (FAZ 4)
// ============================================================================
//
// Müşteri bazlı stok giriş/çıkış işlemlerini yönetir
// Atomic batch write ile Firebase entegrasyonu

final islemProvider = Provider<CariIslemService>((ref) {
  return CariIslemService();
});

// ============================================================================
// CAR İ İŞLEM SERVİSİ
// ============================================================================

class CariIslemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String firmaId = 'default_firma'; // Sabit firma ID

  // =========================================================================
  // İŞLEM KAYDI VE STOK GÜNCELLEME (Atomic - Batch Write)
  // =========================================================================

  Future<void> islemKaydet({
    required String musteriId,
    required String musteriAdi,
    required IslemTipi islemTipi,
    required String stokId,
    required String stokAdi,
    required double miktar,
    required double kur,
    required double toplamTutar,
    required ParaTuru odemeSekli,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. CAR İ İŞLEM KAYDINI EKLE
      final islemRef =
          _firestore.collection('firmas').doc(firmaId).collection('cari_islemler').doc();

      final islemData = {
        'id': islemRef.id,
        'musteriId': musteriId,
        'musteriAdi': musteriAdi,
        'islemTipi': islemTipi.toJson(),
        'stokId': stokId,
        'stokAdi': stokAdi,
        'miktar': miktar,
        'kur': kur,
        'toplamTutar': toplamTutar,
        'odemeSekli': odemeSekli.toJson(),
        'islemTarihi': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      batch.set(islemRef, islemData);

      // 2. STOĞU GÜNCELLE
      // Giriş ise stoğa ekle (+), Çıkış ise stoktan düş (-)
      final stokRef = _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('stoks')
          .doc(stokId);

      final miktarDegisim = islemTipi == IslemTipi.giris ? miktar : -miktar;

      batch.update(stokRef, {
        'miktar': FieldValue.increment(miktarDegisim),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. BATCH'ı UYGULA (Atomic - Her ikisi başarılı veya hiçbiri)
      await batch.commit();

      debugPrint('✓ Cari İşlem Başarıyla Kaydedildi:');
      debugPrint('  - İşlem ID: ${islemRef.id}');
      debugPrint('  - Müşteri: $musteriAdi');
      debugPrint('  - Tipi: ${islemTipi.toJson()}');
      debugPrint('  - Stok: $stokAdi');
      debugPrint('  - Miktar: $miktar');
      debugPrint('  - Toplam: $toplamTutar TL');
    } catch (e) {
      debugPrint('✗ Cari İşlem Kaydı Hatası: $e');
      rethrow;
    }
  }

  // =========================================================================
  // STOKLARı GETIR (Dropdown için)
  // =========================================================================

  Future<List<Map<String, String>>> getStoklarMap() async {
    try {
      final snapshot = await _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('stoks')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'ad': data['ad'] as String? ?? 'Bilinmeyen',
        };
      }).toList();
    } catch (e) {
      debugPrint('✗ Stok Getirme Hatası: $e');
      return [];
    }
  }
}


