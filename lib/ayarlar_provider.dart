import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ayarlar_model.dart';

// Default ayarlar
const String _defaultFirmaAdi = 'ANTIGRAVITY KUYUMCULUK';
const String _defaultFisNotu = 'Bizi tercih ettiğiniz için teşekkür ederiz.';
const double _defaultMilyem22 = 0.916;
const double _defaultMilyem18 = 0.750;
const double _defaultMilyem14 = 0.585;

// SharedPreferences anahtarları
const String _keyFirmaAdi = 'firma_adi';
const String _keyFisNotu = 'fis_notu';
const String _keyMilyem22 = 'milyem_22';
const String _keyMilyem18 = 'milyem_18';
const String _keyMilyem14 = 'milyem_14';

// Ayarlar provider
final ayarlarProvider = StateNotifierProvider<AyarlarNotifier, AyarlarModel>((ref) {
  return AyarlarNotifier();
});

class AyarlarNotifier extends StateNotifier<AyarlarModel> {
  AyarlarNotifier()
      : super(const AyarlarModel(
          firmaAdi: _defaultFirmaAdi,
          fisNotu: _defaultFisNotu,
          milyem22: _defaultMilyem22,
          milyem18: _defaultMilyem18,
          milyem14: _defaultMilyem14,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final firmaAdi = prefs.getString(_keyFirmaAdi) ?? _defaultFirmaAdi;
      final fisNotu = prefs.getString(_keyFisNotu) ?? _defaultFisNotu;
      final milyem22 = prefs.getDouble(_keyMilyem22) ?? _defaultMilyem22;
      final milyem18 = prefs.getDouble(_keyMilyem18) ?? _defaultMilyem18;
      final milyem14 = prefs.getDouble(_keyMilyem14) ?? _defaultMilyem14;

      state = AyarlarModel(
        firmaAdi: firmaAdi,
        fisNotu: fisNotu,
        milyem22: milyem22,
        milyem18: milyem18,
        milyem14: milyem14,
      );
    } catch (e) {
      debugPrint('Ayarlar yükleme hatası: $e');
    }
  }

  Future<void> updateFirmaAdi(String firmaAdi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyFirmaAdi, firmaAdi);
      state = state.copyWith(firmaAdi: firmaAdi);
    } catch (e) {
      debugPrint('Firma adı güncelleme hatası: $e');
    }
  }

  Future<void> updateFisNotu(String fisNotu) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyFisNotu, fisNotu);
      state = state.copyWith(fisNotu: fisNotu);
    } catch (e) {
      debugPrint('Fiş notu güncelleme hatası: $e');
    }
  }

  Future<void> updateMilyem22(double milyem22) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyMilyem22, milyem22);
      state = state.copyWith(milyem22: milyem22);
    } catch (e) {
      debugPrint('Milyem 22 güncelleme hatası: $e');
    }
  }

  Future<void> updateMilyem18(double milyem18) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyMilyem18, milyem18);
      state = state.copyWith(milyem18: milyem18);
    } catch (e) {
      debugPrint('Milyem 18 güncelleme hatası: $e');
    }
  }

  Future<void> updateMilyem14(double milyem14) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyMilyem14, milyem14);
      state = state.copyWith(milyem14: milyem14);
    } catch (e) {
      debugPrint('Milyem 14 güncelleme hatası: $e');
    }
  }
}
