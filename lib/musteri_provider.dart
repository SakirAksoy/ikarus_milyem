import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'musteri_model.dart';
import 'kuyumcu_islem_model.dart';

final musteriListProvider = StreamProvider<List<MusteriModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  const firmaId = 'default_firma';

  return firestore
      .collection('firmas')
      .doc(firmaId)
      .collection('musteriler')
      .orderBy('adSoyad')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => MusteriModel.fromJson(doc.data(), doc.id)).toList();
  });
});

final musteriProvider = Provider<MusteriService>((ref) {
  return MusteriService();
});

class MusteriService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String firmaId = 'default_firma';

  Future<void> musteriEkle({
    required String adSoyad,
    String? telefon,
    String? adres,
    double toplamHasBakiye = 0.0,
  }) async {
    try {
      final musteriRef = _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('musteriler')
          .doc();

      final musteri = MusteriModel(
        id: musteriRef.id,
        adSoyad: adSoyad,
        telefon: telefon,
        adres: adres,
        toplamHasBakiye: toplamHasBakiye,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await musteriRef.set(musteri.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> musteriEkleWithFirma({
    required String adSoyad,
    String firmaAdi = '',
    String? telefon,
    String? adres,
    double toplamHasBakiye = 0.0,
  }) async {
    try {
      final musteriRef = _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('musteriler')
          .doc();

      final musteri = MusteriModel(
        id: musteriRef.id,
        adSoyad: adSoyad,
        firmaAdi: firmaAdi,
        telefon: telefon,
        adres: adres,
        toplamHasBakiye: toplamHasBakiye,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await musteriRef.set(musteri.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> musteriGuncelle({
    required String musteriId,
    required String adSoyad,
    String? telefon,
    String? adres,
  }) async {
    try {
      await _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('musteriler')
          .doc(musteriId)
          .update({
        'adSoyad': adSoyad,
        'telefon': telefon,
        'adres': adres,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> musteriSil({
    required String musteriId,
  }) async {
    try {
      await _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('musteriler')
          .doc(musteriId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<MusteriModel?> musteriGetir({
    required String musteriId,
  }) async {
    try {
      final doc = await _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('musteriler')
          .doc(musteriId)
          .get();

      if (doc.exists) {
        return MusteriModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> islemSonrasiMusteriBakiyeGuncelle({
    required String musteriId,
    required KuyumcuIslemModel islem,
  }) async {
    try {
      final batch = _firestore.batch();

      final musteriRef = _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('musteriler')
          .doc(musteriId);

      final hasDegisim = _hesaplaHasDegisimMusteri(islem);

      batch.set(
        musteriRef,
        {
          'toplamHasBakiye': FieldValue.increment(hasDegisim),
          'sonIslemTarihi': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  double _hesaplaHasDegisimMusteri(KuyumcuIslemModel islem) {
    switch (islem.islemTipi) {
      case IslemTipi.satis:
        return islem.hasAltinKarsiligi;
      case IslemTipi.alis:
        return -islem.hasAltinKarsiligi;
      case IslemTipi.odemeAlma:
        return -islem.hasAltinKarsiligi;
      case IslemTipi.odemeYapma:
        return islem.hasAltinKarsiligi;
    }
  }
}

