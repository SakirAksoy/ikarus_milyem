import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

import 'fis_model.dart';

class FisPdfServis {
  static Future<Uint8List> generateFisPdf(FisModel fis, {String? firmaAdi, String? fisNotu}) async {
    final pdf = pw.Document();

    final prefs = await SharedPreferences.getInstance();
    final finalFirmaAdi = firmaAdi ?? prefs.getString('firma_adi') ?? 'ANTIGRAVITY KUYUMCULUK';
    final finalFisNotu = fisNotu ?? prefs.getString('fis_notu') ?? 'Bizi tercih ettiğiniz için teşekkür ederiz.';

    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    final tarihStr = formatter.format(fis.tarih);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Firma Adı
              pw.Text(
                finalFirmaAdi,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(height: 1),
              pw.SizedBox(height: 8),

              // Fiş No ve Tarih
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Fiş No: ${fis.fisNo}',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.Text(tarihStr,
                      style: pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 2),

              // İşlem Tipi
              pw.Text(
                'İşlem: ${_getIslemTipiStr(fis.islemTipi)} (${fis.ayar})',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(height: 1),
              pw.SizedBox(height: 8),

              // Müşteri Bilgisi
              pw.Text('Müşteri: ${fis.musteriAd}',
                  style: pw.TextStyle(fontSize: 10)),
              pw.Text('Tel: ${fis.musteriTelefon}',
                  style: pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 8),

              // Detaylar
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Has Gram:', style: pw.TextStyle(fontSize: 9)),
                      pw.Text('Tutar (TL):', style: pw.TextStyle(fontSize: 9)),
                      pw.Text('Ödeme:', style: pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(fis.hasGram.toStringAsFixed(4),
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text(fis.tlTutar.toStringAsFixed(2),
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text(fis.odemeTipi,
                          style: pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(height: 1),
              pw.SizedBox(height: 8),

              // Not
              pw.Text(
                finalFisNotu,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 8),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  static Future<void> printFis(FisModel fis) async {
    try {
      final pdfData = await generateFisPdf(fis);
      await Printing.layoutPdf(
        onLayout: (_) => pdfData,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> shareFisWhatsApp(FisModel fis, {String? firmaAdi}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final finalFirmaAdi = firmaAdi ?? prefs.getString('firma_adi') ?? 'ANTIGRAVITY KUYUMCULUK';

      final formatter = DateFormat('dd.MM.yyyy HH:mm');
      final tarihStr = formatter.format(fis.tarih);

      final message = '''
Merhaba ${fis.musteriAd},

$tarihStr tarihli işleminizin detayı:

📊 İşlem Tipi: ${_getIslemTipiStr(fis.islemTipi)} (${fis.ayar})
💎 Has Altın: ${fis.hasGram.toStringAsFixed(4)} gr
💰 Tutar: ${fis.tlTutar.toStringAsFixed(2)} TL
🏪 Ödeme: ${fis.odemeTipi}

*Mali değeri yoktur.*

$finalFirmaAdi
''';

      // WhatsApp URL şeması
      final whatsappUrl =
          'https://wa.me/${fis.musteriTelefon.replaceAll(RegExp(r'[^0-9]'), '')}?text=${Uri.encodeComponent(message)}';

      // URL Launcher ile aç
      await _launchWhatsApp(whatsappUrl);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _launchWhatsApp(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      // ignore: deprecated_member_use
      if (await canLaunchUrl(uri)) {
        // ignore: deprecated_member_use
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'WhatsApp açılamadı';
      }
    } catch (e) {
      rethrow;
    }
  }

  static String _getIslemTipiStr(IslemTipiFis tipi) {
    switch (tipi) {
      case IslemTipiFis.satis:
        return 'Satış';
      case IslemTipiFis.alis:
        return 'Alış';
      case IslemTipiFis.manuel:
        return 'Manuel';
    }
  }
}
