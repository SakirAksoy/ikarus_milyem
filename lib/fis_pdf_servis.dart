import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'fis_model.dart';
import 'theme.dart';

class FisPdfServis {
  static Future<Uint8List> generateFisPdf(FisModel fis) async {
    final pdf = pw.Document();

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
                'IKARUS MİLYEM',
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
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(tarihStr,
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 2),

              // İşlem Tipi
              pw.Text(
                'İşlem: ${_getIslemTipiStr(fis.islemTipi)} (${fis.ayar})',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(height: 1),
              pw.SizedBox(height: 8),

              // Müşteri Bilgisi
              pw.Text('Müşteri: ${fis.musteriAd}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Tel: ${fis.musteriTelefon}',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 8),

              // Detaylar
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Has Gram:', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Tutar (TL):', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Ödeme:', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('${fis.hasGram.toStringAsFixed(4)}',
                          style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('${fis.tlTutar.toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text(fis.odemeTipi,
                          style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(height: 1),
              pw.SizedBox(height: 8),

              // Not
              pw.Text(
                'Mali değeri yoktur.',
                style: const pw.TextStyle(fontSize: 8),
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

  static Future<void> shareFisWhatsApp(FisModel fis) async {
    try {
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

IKARUS MİLYEM
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
