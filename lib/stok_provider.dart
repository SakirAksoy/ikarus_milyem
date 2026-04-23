import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stok_model.dart';

final stoklarStreamProvider = StreamProvider<List<StokModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  const firmaId = 'default_firma';

  return firestore
      .collection('firmas')
      .doc(firmaId)
      .collection('stoklar')
      .orderBy('urunAdi')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => StokModel.fromMap(doc.data(), doc.id)).toList();
  });
});

final stokProvider = Provider<StokService>((ref) {
  return StokService();
});

class StokService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String firmaId = 'default_firma';

  Future<void> stokEkle({
    required String urunAdi,
    required String urunKodu,
    required double milyem,
    double toplamGram = 0.0,
    int toplamAdet = 0,
    required String urunGrubu,
  }) async {
    try {
      final stokRef = _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('stoklar')
          .doc();

      final stok = StokModel(
        id: stokRef.id,
        urunAdi: urunAdi,
        urunKodu: urunKodu,
        milyem: milyem,
        toplamGram: toplamGram,
        toplamAdet: toplamAdet,
        urunGrubu: urunGrubu,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await stokRef.set(stok.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stokGuncelle({
    required String stokId,
    required String urunAdi,
    required String urunKodu,
    required double milyem,
    required double toplamGram,
    required int toplamAdet,
    required String urunGrubu,
  }) async {
    try {
      await _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('stoklar')
          .doc(stokId)
          .update({
        'urunAdi': urunAdi,
        'urunKodu': urunKodu,
        'milyem': milyem,
        'toplamGram': toplamGram,
        'toplamAdet': toplamAdet,
        'urunGrubu': urunGrubu,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stokSil({
    required String stokId,
  }) async {
    try {
      await _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('stoklar')
          .doc(stokId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<StokModel?> stokGetir({
    required String stokId,
  }) async {
    try {
      final doc = await _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('stoklar')
          .doc(stokId)
          .get();

      if (doc.exists) {
        return StokModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
