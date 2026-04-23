import 'package:flutter/material.dart';
import 'kur_page.dart';
import 'islem_page.dart';
import 'musteri_liste_page.dart';
import 'stok_liste_page.dart';

enum AppPage { kur, islem, musteriler, stok, raporlar }

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
  AppPage _currentPage = AppPage.kur;

  // =========================================================================
  // PAGE TITLE MAPPING
  // =========================================================================

  String _getPageTitle(AppPage page) {
    switch (page) {
      case AppPage.kur:
        return 'Döviz Kurları';
      case AppPage.islem:
        return 'İşlem Kaydı';
      case AppPage.musteriler:
        return 'Müşteri Yönetimi';
      case AppPage.stok:
        return 'Stok Yönetimi';
      case AppPage.raporlar:
        return 'Raporlar';
    }
  }

  // =========================================================================
  // PAGE BUILDER
  // =========================================================================

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case AppPage.kur:
        return const KurPage();
      case AppPage.islem:
        return const IslemPage();
      case AppPage.musteriler:
        return const MusteriListePage();
      case AppPage.stok:
        return const StokListePage();
      case AppPage.raporlar:
        return const _PlaceholderPage(
          title: 'Raporlar',
          icon: Icons.bar_chart,
          description: 'Raporlar sayfası (Faz 4 Aşama 3 de gelecek)',
        );
    }
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(_currentPage)),
        elevation: 2,
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
            icon: const Icon(Icons.trending_up),
            label: 'Kurlar',
            tooltip: 'Döviz Kurları',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: 'İşlem',
            tooltip: 'İşlem Kaydı',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: 'Müşteriler',
            tooltip: 'Müşteri Yönetimi',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2),
            label: 'Stok',
            tooltip: 'Stok Yönetimi',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: 'Raporlar',
            tooltip: 'Raporlar',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PLACEHOLDER PAGE - For upcoming sections
// ============================================================================

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const _PlaceholderPage({
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.blue.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
