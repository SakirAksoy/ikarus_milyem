import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kur_page.dart';
import 'islem_page.dart';
import 'musteri_liste_page.dart';
import 'stok_liste_page.dart';
import 'dashboard_page.dart';

enum AppPage { dashboard, kur, islem, musteriler, stok }

// ============================================================================
// MAIN LAYOUT - Application Shell with Navigation
// ============================================================================
//
// Provides the main scaffold with bottom navigation bar
// Pages: Kur (Exchange Rates), İşlem (Transactions), Stok (Inventory), Raporlar (Reports)

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  AppPage _currentPage = AppPage.dashboard;

  // =========================================================================
  // PAGE TITLE MAPPING
  // =========================================================================

  String _getPageTitle(AppPage page) {
    switch (page) {
      case AppPage.dashboard:
        return 'IKARUS MİLYEM';
      case AppPage.kur:
        return 'Döviz Kurları';
      case AppPage.islem:
        return 'İşlem Kaydı';
      case AppPage.musteriler:
        return 'Müşteri Yönetimi';
      case AppPage.stok:
        return 'Stok Yönetimi';
    }
  }

  // =========================================================================
  // PAGE BUILDER
  // =========================================================================

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case AppPage.dashboard:
        return const DashboardPage();
      case AppPage.kur:
        return const KurPage();
      case AppPage.islem:
        return const IslemPage();
      case AppPage.musteriler:
        return const MusteriListePage();
      case AppPage.stok:
        return const StokListePage();
    }
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getPageTitle(_currentPage),
          style: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage.index,
        onTap: (index) {
          setState(() {
            _currentPage = AppPage.values[index];
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: 'Dashboard',
            tooltip: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up_rounded),
            label: 'Kurlar',
            tooltip: 'Döviz Kurları',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_rounded),
            label: 'İşlem',
            tooltip: 'İşlem Kaydı',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_rounded),
            label: 'Müşteriler',
            tooltip: 'Müşteri Yönetimi',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_rounded),
            label: 'Stok',
            tooltip: 'Stok Yönetimi',
          ),
        ],
      ),
    );
  }
}
