import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

// ============================================================================
// FIREBASE SEEDER - Database Initialization
// ============================================================================
//
// Initializes Firestore with default collections and documents
// Runs only once when app first starts

class FirebaseSeeder {
  final FirebaseFirestore _firestore;

  FirebaseSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // =========================================================================
  // MAIN INITIALIZATION METHOD
  // =========================================================================
  // 
  // Checks if database is empty and seeds default data
  // Safe to call multiple times (idempotent via checksums)

  Future<void> initializeDatabase({required String firmaId}) async {
    try {
      // Check if firma exists
      final firmaDoc = await _firestore.collection('firmas').doc(firmaId).get();

      if (firmaDoc.exists) {
        // Firma already exists, check if seeded
        final isSeedeed = firmaDoc.data()?['seeded'] as bool? ?? false;
        if (isSeedeed) {
          debugPrint('✓ Database already seeded for firma: $firmaId');
          return;
        }
      }

      debugPrint('⚙️ Initializing database for firma: $firmaId...');

      // Create default stok entries (kasalar)
      await _createDefaultStoks(firmaId);

      // Create system settings
      await _createSystemSettings(firmaId);

      // Mark firma as seeded
      await _firestore.collection('firmas').doc(firmaId).set({
        'seeded': true,
        'seedDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✓ Database initialization completed for firma: $firmaId');
    } catch (e) {
      debugPrint('✗ Database initialization failed: $e');
      // Re-throw to be caught in FutureBuilder
      rethrow;
    }
  }

  // =========================================================================
  // CREATE DEFAULT STOKS (Kasalar)
  // =========================================================================

  Future<void> _createDefaultStoks(String firmaId) async {
    final stokCollection =
        _firestore.collection('firmas').doc(firmaId).collection('stoks');

    // 1. TL KASA (Para - TL)
    await stokCollection.add({
      'ad': 'TL Kasası',
      'stokTuru': StokTuru.para.toJson(),
      'paraTuru': ParaTuru.tl.toJson(),
      'miktar': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. DOLAR KASA (Para - USD)
    await stokCollection.add({
      'ad': 'Dolar Kasası',
      'stokTuru': StokTuru.para.toJson(),
      'paraTuru': ParaTuru.dolar.toJson(),
      'miktar': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 3. HAS ALTIN KASA (Adetsiz - 995 milyem)
    await stokCollection.add({
      'ad': 'Has Altın Kasası (24 Ayar)',
      'stokTuru': StokTuru.adetsiz.toJson(),
      'milyem': 995, // 24 Karat
      'gramAglirlik': 0.0,
      'hasAltinGram': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 4. 22 AYAR HURDA KASA
    await stokCollection.add({
      'ad': '22 Ayar Hurda Kasası',
      'stokTuru': StokTuru.hurda.toJson(),
      'milyem': 916, // 22 Ayar
      'gramAglirlik': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 5. 14 AYAR HURDA KASA
    await stokCollection.add({
      'ad': '14 Ayar Hurda Kasası',
      'stokTuru': StokTuru.hurda.toJson(),
      'milyem': 585, // 14 Ayar
      'gramAglirlik': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    debugPrint('✓ Created 5 default kasalar (stoks)');
  }

  // =========================================================================
  // CREATE SYSTEM SETTINGS
  // =========================================================================

  Future<void> _createSystemSettings(String firmaId) async {
    final settingsRef = _firestore
        .collection('firmas')
        .doc(firmaId)
        .collection('ayarlar')
        .doc('sistem');

    final settingsData = {
      'dukkanAdi': 'İkarus Milyem',
      'varsayilanRenk': 'mavi', // mavi, kirmizi, yesil, etc.
      'paraBirimi': 'TL',
      'defaultMilyem': 995, // 24 Karat
      'hurdaIslemKaybi': 0.02, // 2% (0.02)
      'varsayilanDolarKur': 35.50,
      'varsayilanHasAltinFiyati': 2500.0, // TL/gram
      'varsayilanHurdaFiyati': 1200.0, // TL/gram
      'vergiOrani': 0.0, // %0 initially
      'aciklamasi': 'IKARUS MİLYEM - Kuyumculuk Muhasebe Sistemi',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await settingsRef.set(settingsData, SetOptions(merge: true));

    debugPrint('✓ Created system settings document');
  }

  // =========================================================================
  // UTILITY: Reset Database (for testing)
  // =========================================================================

  Future<void> resetDatabase({required String firmaId}) async {
    try {
      debugPrint('⚠️  Resetting database for firma: $firmaId...');

      // Delete all stoks
      final stoks = await _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('stoks')
          .get();

      for (final doc in stoks.docs) {
        await doc.reference.delete();
      }

      // Delete settings
      await _firestore
          .collection('firmas')
          .doc(firmaId)
          .collection('ayarlar')
          .doc('sistem')
          .delete();

      // Mark as not seeded
      await _firestore.collection('firmas').doc(firmaId).update({
        'seeded': false,
      });

      debugPrint('✓ Database reset completed');
    } catch (e) {
      debugPrint('✗ Database reset failed: $e');
      rethrow;
    }
  }
}
