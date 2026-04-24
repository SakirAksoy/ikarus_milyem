import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'kuyumcu_islem_model.dart';
import 'fis_model.dart';

// ============================================================================
// KUYUMCU İŞLEM PROVIDER - Riverpod Servisi (FAZ 4 PROFESYONELİ)
// ============================================================================
//
// Kuyumcu Matematiği: Tüm işlemler "Has Altın Gramı" üzerinden yönetilir.
// Gramajlı, Adetli, Hurda ve Nakit ödemeleri Has Altın karşılığına çevirir.

final kuyumcuIslemProvider = Provider<KuyumcuIslemService>((ref) {
  return KuyumcuIslemService();
});

// ============================================================================
// KUYUMCU İŞLEM SERVİSİ
// ============================================================================

class KuyumcuIslemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String firmaId = 'default_firma';

  // =========================================================================
  // KUYUMCU MATEMATİĞİ - HAS ALTIN HESAPLAMALARI
  // =========================================================================

  /// **GRAMAJLI ÜRÜN:** (Milyem + İşçilik Milyemi) * Gram = Has Altın Gramı
  /// Örnek: 10 gr, 916 milyem, 50 milyem işçilik
  /// Has = (0.916 + 0.050) * 10 = 9.66 gr
  double hesaplaGramajliUrunHasAltin({
    required int urunMilyemi,
    required double iscilikMilyemi,
    required double gram,
  }) {
    final toplam = (urunMilyemi / 1000 + iscilikMilyemi / 1000) * gram;
    return _yuvarla(toplam);
  }

  /// **ADETLI ÜRÜN:** (Gram * Milyem) + (Adet * Parça İşçilik) = Has Altın Gramı
  /// Örnek: 100 gr, 916 milyem, 20 adet, 0.10 gr parça işçilik
  /// Has = (100 * 0.916) + (20 * 0.10) = 93.6 gr
  double hesaplaAdetliUrunHasAltin({
    required int urunMilyemi,
    required double gram,
    required int adet,
    required double parcaIscilikGrami,
  }) {
    final urunHas = gram * (urunMilyemi / 1000);
    final iscilikHas = adet * parcaIscilikGrami;
    return _yuvarla(urunHas + iscilikHas);
  }

  /// **NAKIT ÖDEME:** Nakit Miktar ÷ Has Altın Kuru = Has Altın Gramı
  /// Örnek: 1000 TL ÷ 250 TL/gr = 4 gr Has
  double hesaplaNakitHasAltin({
    required double nakitMiktar,
    required double hasAltinKuru,
  }) {
    if (hasAltinKuru == 0) return 0;
    return _yuvarla(nakitMiktar / hasAltinKuru);
  }

  /// **HURDA ÖDEME (MAKASLı):** Gram * Makasli Milyem = Has Altın Gramı
  /// 22 Ayar: 916 milyem → makasta 906 milyem (10 puan makası)
  /// 14 Ayar: 585 milyem → makasta 575 milyem (10 puan makası)
  /// Örnek: 3.30 gr 14 ayar hurda * 0.575 = 1.90 gr Has
  double hesaplaHurdaHasAltin({
    required double hurdaGram,
    required HurdaTipi hurdaTipi,
  }) {
    final makasliMilyem = hurdaTipi.makasliMilyem / 1000;
    return _yuvarla(hurdaGram * makasliMilyem);
  }

  /// **YOKETİKİ HESAP:** Hurda gramajını bulur
  /// Has Borcu ÷ Makasli Milyem = Hurda Gramajı
  /// Örnek: 1.9 gr Has ÷ 0.575 = 3.30 gr 14 ayar hurda gerekir
  double hesaplaGereklHurdaGrami({
    required double hasAltinBorcu,
    required HurdaTipi hurdaTipi,
  }) {
    final makasliMilyem = hurdaTipi.makasliMilyem / 1000;
    if (makasliMilyem == 0) return 0;
    return _yuvarla(hasAltinBorcu / makasliMilyem);
  }

  /// **YUVARLAMA:** Tüm hesaplamalar 4 ondalık basamağa yuvarlanır
  double _yuvarla(double deger) {
    return (deger * 10000).round() / 10000;
  }

  // =========================================================================
  // IŞLEM KAYDI - FIRESTORE'A YAZ (ATOMIC)
  // =========================================================================

  Future<void> islemKaydet({
    required KuyumcuIslemModel islem,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. İŞLEMİ KAYDET
      final islemRef = _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('kuyumcu_islemler')
          .doc();

      final islemData = islem.copyWith(id: islemRef.id).toJson();
      batch.set(islemRef, islemData);

      // 2. MÜŞTERİ CARİ HESABINI GÜNCELLE
      // Not: İşlem tipine göre borç/alacak yönetimi
      // - Satış (satis) → Müşteri borca girer (+)
      // - Alış (alis) → Müşteri alacaklandırılır (-)
      // - OdemeAlma → Borç azalır (-)
      // - OdemeYapma → Alacak azalır (+)
      final musteriRef = _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('musteriler')
          .doc(islem.musteriId);

      final hasDegisim = _hesaplaHasDegisim(islem);

      batch.set(
        musteriRef,
        {
          'toplamHasBakiye': FieldValue.increment(hasDegisim),
          'sonIslemTarihi': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // 3. BATCH UYGULA
      await batch.commit();

      // 4. OTOMATİK FİŞ OLUŞTUR (Satış/Alış işlemleri için)
      if (islem.islemTipi == IslemTipi.satis || islem.islemTipi == IslemTipi.alis) {
        try {
          final fisNo = DateTime.now().millisecondsSinceEpoch.toString();
          final ayarStr = _getAyarString(islem);

          await _firestore.collection('fisler').add({
            'fisNo': fisNo,
            'musteriAd': islem.musteriAdi,
            'musteriTelefon': islem.musteriTelefon ?? '',
            'tarih': DateTime.now().toIso8601String(),
            'islemTipi': islem.islemTipi == IslemTipi.satis ? 'satis' : 'alis',
            'ayar': ayarStr,
            'hasGram': islem.hasAltinKarsiligi,
            'tlTutar': islem.odemeMiktari ?? 0.0,
            'odemeTipi': islem.odemeTuru ?? 'Nakit',
            'notlar': null,
          });

          debugPrint('✓ Otomatik Fiş Oluşturuldu: $fisNo');
        } catch (e) {
          debugPrint('⚠️ Fiş Oluşturma Hatası (İşlem kaydı başarılı): $e');
          // İşlem kaydı başarılı, fiş hatası non-critical
        }
      }

      debugPrint('✓ Kuyumcu İşlem Kaydedildi:');
      debugPrint('  - İşlem ID: ${islemRef.id}');
      debugPrint('  - Müşteri: ${islem.musteriAdi}');
      debugPrint('  - İşlem Tipi: ${islem.islemTipi.name}');
      debugPrint('  - Ürün Tipi: ${islem.urunTipi.name}');
      debugPrint('  - Has Karşılığı: ${islem.hasAltinKarsiligi.toStringAsFixed(4)} gr');
    } catch (e) {
      debugPrint('✗ İşlem Kaydı Hatası: $e');
      rethrow;
    }
  }

  String _getAyarString(KuyumcuIslemModel islem) {
    if (islem.urunMilyemi != null) {
      final milyem = islem.urunMilyemi!;
      if (milyem >= 995) return '1000';
      if (milyem >= 916) return '916';
      if (milyem >= 875) return '875';
      if (milyem >= 750) return '750';
      return '$milyem';
    }
    return 'Bilinmiyor';
  }

  /// İşlem tipine göre cari hesaba yazılacak Has değişimini hesapla
  double _hesaplaHasDegisim(KuyumcuIslemModel islem) {
    switch (islem.islemTipi) {
      case IslemTipi.satis:
        return islem.hasAltinKarsiligi; // Müşteri borca girer (+)
      case IslemTipi.alis:
        return -islem.hasAltinKarsiligi; // Müşteri alacaklandırılır (-)
      case IslemTipi.odemeAlma:
        return -islem.hasAltinKarsiligi; // Borç azalır (-)
      case IslemTipi.odemeYapma:
        return islem.hasAltinKarsiligi; // Alacak azalır (+)
    }
  }
}
