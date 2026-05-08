import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'dashboard_page.dart';
import 'islem_page.dart';
import 'fis_gecmisi_page.dart';
import 'ayarlar_page.dart';
import 'musteri_liste_page.dart';
import 'envanter_hub_page.dart';

// ============================================================================
// MAIN LAYOUT - Application Shell with Navigation
// ============================================================================
//
// Provides the main scaffold with bottom navigation bar
// Pages: Dashboard, İşlem, Stok, Fişler, Ayarlar

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    IslemPage(),
    EnvanterHubPage(),
    FisGecmisiPage(),
    MusteriListePage(),
    AyarlarPage(),
  ];

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'IKARUS MİLYEM';
      case 1:
        return 'İŞLEMLER';
      case 2:
        return 'KASA & STOK';
      case 3:
        return 'FİŞ GEÇMİŞİ';
      case 4:
        return 'MÜŞTERİLER';
      case 5:
        return 'AYARLAR';
      default:
        return 'IKARUS MİLYEM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getPageTitle(_currentIndex),
          style: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AntiGravityColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AntiGravityColors.surface,
        selectedItemColor: AntiGravityColors.goldAccent,
        unselectedItemColor: AntiGravityColors.textMuted,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'İşlemler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Kasa & Stok',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Fişler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Müşteriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
