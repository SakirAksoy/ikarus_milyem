import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fis_model.dart';

final fisProvider =
    StateNotifierProvider<FisNotifier, AsyncValue<List<FisModel>>>((ref) {
  return FisNotifier();
});

class FisNotifier extends StateNotifier<AsyncValue<List<FisModel>>> {
  FisNotifier() : super(const AsyncValue.loading()) {
    _loadFisler();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _loadFisler() {
    _firestore
        .collection('fisler')
        .orderBy('tarih', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final fisler = snapshot.docs
            .map((doc) => FisModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
        state = AsyncValue.data(fisler);
      },
      onError: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  Future<void> fisEkle({
    required String fisNo,
    required String musteriAd,
    required String musteriTelefon,
    required DateTime tarih,
    required IslemTipiFis islemTipi,
    required String ayar,
    required double hasGram,
    required double tlTutar,
    required String odemeTipi,
    String? notlar,
  }) async {
    try {
      final newFis = FisModel(
        id: '',
        fisNo: fisNo,
        musteriAd: musteriAd,
        musteriTelefon: musteriTelefon,
        tarih: tarih,
        islemTipi: islemTipi,
        ayar: ayar,
        hasGram: hasGram,
        tlTutar: tlTutar,
        odemeTipi: odemeTipi,
        notlar: notlar,
      );

      final docRef = await _firestore.collection('fisler').add(newFis.toMap());

      // Update id field
      await docRef.update({'id': docRef.id});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fisSil(String id) async {
    try {
      await _firestore.collection('fisler').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}
