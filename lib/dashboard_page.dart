import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'musteri_model.dart';
import 'musteri_provider.dart';
import 'stok_model.dart';
import 'stok_provider.dart';
import 'fis_olustur_page.dart';
import 'fis_gecmisi_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musterilerAsync = ref.watch(musteriListProvider);
    final stoklarAsync = ref.watch(stoklarStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        children: [
          // Gold Price Card with Radial Gradient
          _buildGoldPriceCard(),

          // KPI Tiles Grid
          _buildKPIGrid(musterilerAsync, stoklarAsync),

          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  // =========================================================================
  // GOLD PRICE CARD WITH RADIAL GRADIENT & LIVE PULSE
  // =========================================================================

  Widget _buildGoldPriceCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 1.5,
          colors: [
            AntiGravityColors.gold2,
            AntiGravityColors.gold1,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AntiGravityColors.goldAccent.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AntiGravityColors.goldAccent.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                'HAS ALTIN FIYATI',
                style: GoogleFonts.syne(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AntiGravityColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '₺ 2,650.50',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AntiGravityColors.goldAccent,
                ),
              ),
              Text(
                '+2.45% 24h',
                style: GoogleFonts.syne(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AntiGravityColors.liveGreen,
                ),
              ),
            ],
          ),
          // Live Pulse Indicator
          Column(
            spacing: 8,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.2)
                    .animate(_pulseController),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AntiGravityColors.liveGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AntiGravityColors.liveGreen.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'CANLI',
                style: GoogleFonts.syne(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AntiGravityColors.liveGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // KPI TILES GRID (2x2)
  // =========================================================================

  Widget _buildKPIGrid(
    AsyncValue<List<MusteriModel>> musterilerAsync,
    AsyncValue<List<StokModel>> stoklarAsync,
  ) {
    return musterilerAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (musteriler) {
        return stoklarAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (stoklar) {
            // Calculate KPIs
            final totalStokGram = stoklar.fold<double>(
              0,
              (sum, s) => sum + s.toplamGram,
            );
            final borclularTotal = musteriler
                .where((m) => m.toplamHasBakiye < 0)
                .fold<double>(0, (sum, m) => sum + m.toplamHasBakiye.abs());
            final alacaklilarTotal = musteriler
                .where((m) => m.toplamHasBakiye > 0)
                .fold<double>(0, (sum, m) => sum + m.toplamHasBakiye);

            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildKPITile(
                  'STOK',
                  '${totalStokGram.toStringAsFixed(2)} gr',
                  Icons.inventory_2,
                  AntiGravityColors.goldAccent,
                ),
                _buildKPITile(
                  'MÜŞTERİLER',
                  musteriler.length.toString(),
                  Icons.people,
                  AntiGravityColors.goldPrimary,
                ),
                _buildKPITile(
                  'BORÇLU',
                  '${borclularTotal.toStringAsFixed(2)} gr',
                  Icons.trending_down,
                  const Color(0xFFFF6B6B),
                ),
                _buildKPITile(
                  'ALACAKLI',
                  '${alacaklilarTotal.toStringAsFixed(2)} gr',
                  Icons.trending_up,
                  AntiGravityColors.liveGreen,
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // KPI TILE BUILDER
  // =========================================================================

  Widget _buildKPITile(
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AntiGravityColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AntiGravityColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.syne(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AntiGravityColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: accentColor, size: 20),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // QUICK ACTIONS
  // =========================================================================

  Widget _buildQuickActions() {
    return Column(
      spacing: 12,
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FisOlusturPage()),
              );
            },
            icon: const Icon(Icons.receipt_long, size: 20),
            label: Text(
              'SATIŞ FİŞİ OLUŞTUR',
              style: GoogleFonts.syne(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AntiGravityColors.goldAccent,
              foregroundColor: AntiGravityColors.darkBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FisGecmisiPage()),
              );
            },
            icon: const Icon(Icons.history, size: 20),
            label: Text(
              'FİŞ GEÇMİŞİ',
              style: GoogleFonts.syne(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AntiGravityColors.goldAccent,
              side: const BorderSide(
                color: AntiGravityColors.goldAccent,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
