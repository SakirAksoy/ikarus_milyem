import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'stok_liste_page.dart';
import 'kasa_page.dart';
import 'theme.dart';

class EnvanterHubPage extends StatelessWidget {
  const EnvanterHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ALTIN STOK KARTI
            _buildHubCard(
              context,
              title: 'Altın Stokları',
              icon: Icons.inventory_2,
              description: 'Stok envanterini görüntüle ve yönet',
              accentColor: AntiGravityColors.goldAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StokListePage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // NAKİT KASASI KARTI
            _buildHubCard(
              context,
              title: 'Nakit Kasası',
              icon: Icons.payments,
              description: 'TL, USD ve EUR kasalarını yönet',
              accentColor: AntiGravityColors.liveGreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KasaPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withValues(alpha: 0.15),
                accentColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Icon(
                icon,
                size: 56,
                color: accentColor,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.syne(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AntiGravityColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: AntiGravityColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.arrow_forward,
                color: accentColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
