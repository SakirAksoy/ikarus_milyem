import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AltinApiServis {
  static const String _apiUrl = 'https://api.collectapi.com/economy/goldPrice';
  static const String _apiKey =
      'apikey 3FW0DxAiFlJ5eCqU8LONsQ:1IbjVV4FtzRNOqpyND6UMK';

  /// CollectAPI'den canlı gram altın fiyatını çeker
  /// Başarısız olursa varsayılan 2500.0 değerini döndürür
  static Future<double> fetchCanliFiyat() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'authorization': _apiKey,
          'content-type': 'application/json',
        },
      );

      debugPrint('🔗 API İstek URL: ${response.request?.url}');
      debugPrint('📊 API Yanıt Kodu: ${response.statusCode}');
      debugPrint('📦 API Gelen Cevap: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        // success kontrolü yap
        final bool success = jsonResponse['success'] as bool? ?? false;
        if (!success) {
          debugPrint('⚠️ API Success Hatası: ${jsonResponse['message']}');
          return 2500.0;
        }

        // result listesini kontrol et
        if (jsonResponse.containsKey('result') && jsonResponse['result'] is List) {
          final List<dynamic> resultList = jsonResponse['result'] as List<dynamic>;

          // "Gram Altın" adında objeyi bul
          final goldItem = resultList.firstWhere(
            (item) =>
                item is Map<String, dynamic> &&
                item['name'] == 'Gram Altın',
            orElse: () => null,
          ) as Map<String, dynamic>?;

          if (goldItem != null) {
            // sell (satış) veya buy (alış) değerini al
            final sellValue = goldItem['sell'] as String?;
            final buyValue = goldItem['buy'] as String?;
            final fiyatStr = sellValue ?? buyValue ?? '0';

            // String'i double'a çevir
            final fiyat = double.tryParse(fiyatStr) ?? 2500.0;
            debugPrint('✅ Gram Altın Fiyatı: $fiyat TL');
            return fiyat;
          } else {
            debugPrint('⚠️ Gram Altın listede bulunamadı');
            return 2500.0;
          }
        } else {
          debugPrint('⚠️ Result listesi yapısı hatalı');
          return 2500.0;
        }
      } else {
        debugPrint('✗ API Hatası - HTTP ${response.statusCode}: ${response.body}');
        return 2500.0;
      }
    } catch (e) {
      debugPrint('✗ Fiyat Çekme Hatası: $e');
      return 2500.0;
    }
  }
}
