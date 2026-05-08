import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'ayarlar_provider.dart';

class AyarlarPage extends ConsumerStatefulWidget {
  const AyarlarPage({super.key});

  @override
  ConsumerState<AyarlarPage> createState() => _AyarlarPageState();
}

class _AyarlarPageState extends ConsumerState<AyarlarPage> {
  late TextEditingController _firmaAdiController;
  late TextEditingController _fisNotayController;
  late TextEditingController _milyem22Controller;
  late TextEditingController _milyem18Controller;
  late TextEditingController _milyem14Controller;

  @override
  void initState() {
    super.initState();
    final ayarlar = ref.read(ayarlarProvider);
    _firmaAdiController = TextEditingController(text: ayarlar.firmaAdi);
    _fisNotayController = TextEditingController(text: ayarlar.fisNotu);
    _milyem22Controller = TextEditingController(text: ayarlar.milyem22.toString());
    _milyem18Controller = TextEditingController(text: ayarlar.milyem18.toString());
    _milyem14Controller = TextEditingController(text: ayarlar.milyem14.toString());
  }

  @override
  void dispose() {
    _firmaAdiController.dispose();
    _fisNotayController.dispose();
    _milyem22Controller.dispose();
    _milyem18Controller.dispose();
    _milyem14Controller.dispose();
    super.dispose();
  }

  void _saveFirmaAyarlari() {
    final notifier = ref.read(ayarlarProvider.notifier);
    notifier.updateFirmaAdi(_firmaAdiController.text).then((_) {
      return notifier.updateFisNotu(_fisNotayController.text);
    }).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firma ayarları kaydedildi',
            style: GoogleFonts.syne(),
          ),
          backgroundColor: AntiGravityColors.liveGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hata: $error',
            style: GoogleFonts.syne(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _editMilyem(String milyemType, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AntiGravityColors.surface,
        title: Text(
          'Milyem Düzenle',
          style: GoogleFonts.syne(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AntiGravityColors.textLight,
          ),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.jetBrainsMono(color: AntiGravityColors.textLight),
          decoration: InputDecoration(
            hintText: '0.000',
            hintStyle: GoogleFonts.jetBrainsMono(
              color: AntiGravityColors.textMuted,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AntiGravityColors.goldAccent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AntiGravityColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AntiGravityColors.goldAccent,
                width: 2,
              ),
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'İptal',
              style: GoogleFonts.syne(color: AntiGravityColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              final value = double.tryParse(controller.text) ?? 0.0;
              final notifier = ref.read(ayarlarProvider.notifier);

              if (milyemType == '22') {
                await notifier.updateMilyem22(value);
              } else if (milyemType == '18') {
                await notifier.updateMilyem18(value);
              } else if (milyemType == '14') {
                await notifier.updateMilyem14(value);
              }

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  content: Text(
                    'Milyem $milyemType Ayar güncellendi',
                    style: GoogleFonts.syne(),
                  ),
                  backgroundColor: AntiGravityColors.liveGreen,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Kaydet',
              style: GoogleFonts.syne(
                fontWeight: FontWeight.bold,
                color: AntiGravityColors.goldAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ayarlar = ref.watch(ayarlarProvider);

    return Scaffold(
      backgroundColor: AntiGravityColors.darkBg,
      appBar: AppBar(
        title: Text(
          'AYARLAR',
          style: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AntiGravityColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 24,
          children: [
            // Firma Ayarları Bölümü
            _buildSectionHeader('FİRMA AYARLARI'),
            _buildFirmaAyarlariCard(),

            // Milyem Parametreleri Bölümü
            _buildSectionHeader('MİLYEM PARAMETRELERİ'),
            _buildMilyemCard(
              'ZİYAFET KAPLAMA',
              '22 Ayar',
              ayarlar.milyem22.toStringAsFixed(3),
              '22',
              _milyem22Controller,
            ),
            _buildMilyemCard(
              'ORTA',
              '18 Ayar',
              ayarlar.milyem18.toStringAsFixed(3),
              '18',
              _milyem18Controller,
            ),
            _buildMilyemCard(
              'İNCE TELKARI',
              '14 Ayar',
              ayarlar.milyem14.toStringAsFixed(3),
              '14',
              _milyem14Controller,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.syne(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AntiGravityColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFirmaAyarlariCard() {
    return Container(
      decoration: BoxDecoration(
        color: AntiGravityColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AntiGravityColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        children: [
          TextField(
            controller: _firmaAdiController,
            style: GoogleFonts.jetBrainsMono(
              color: AntiGravityColors.textLight,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              labelText: 'Firma Adı',
              labelStyle: GoogleFonts.syne(
                color: AntiGravityColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AntiGravityColors.border,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AntiGravityColors.goldAccent,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          TextField(
            controller: _fisNotayController,
            style: GoogleFonts.jetBrainsMono(
              color: AntiGravityColors.textLight,
              fontSize: 14,
            ),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Fiş Notu',
              labelStyle: GoogleFonts.syne(
                color: AntiGravityColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AntiGravityColors.border,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AntiGravityColors.goldAccent,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saveFirmaAyarlari,
              style: ElevatedButton.styleFrom(
                backgroundColor: AntiGravityColors.goldAccent,
                foregroundColor: AntiGravityColors.darkBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'KAYDET',
                style: GoogleFonts.syne(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilyemCard(
    String title,
    String ayar,
    String value,
    String milyemType,
    TextEditingController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AntiGravityColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AntiGravityColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  title,
                  style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AntiGravityColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AntiGravityColors.goldAccent,
                  ),
                ),
                Text(
                  ayar,
                  style: GoogleFonts.syne(
                    fontSize: 11,
                    color: AntiGravityColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editMilyem(milyemType, controller),
            icon: const Icon(
              Icons.edit,
              color: AntiGravityColors.goldAccent,
            ),
            tooltip: 'Düzenle',
          ),
        ],
      ),
    );
  }
}
