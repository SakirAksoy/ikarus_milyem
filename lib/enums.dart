/// Stok Türü Enumı
enum StokTuru {
  adetli,     // Ziynet (Adet cinsinden: Bilezik, Yüzük vb.)
  adetsiz,    // Ağırlıklı (gram cinsinden: Çubuk, Levha vb.)
  hurda,      // Hurda Altın
  para,       // Para (TL, Dolar, Has Altın, Hurda)
  demirbas;   // Demirbaş (Makine, Tezgah vb.)

  String toJson() => name;
  static StokTuru fromJson(String json) => StokTuru.values.byName(json);
}

/// Para Türü Enumı
enum ParaTuru {
  tl,         // Türk Lirası
  dolar,      // ABD Doları
  hasAltin,   // Has Altın (gram)
  hurda;      // Hurda Altın (gram)

  String toJson() => name;
  static ParaTuru fromJson(String json) => ParaTuru.values.byName(json);
}

/// İşlem Tipi (Giriş/Çıkış)
enum IslemTipi {
  giris,   // Dükkana giren (Alış)
  cikis;   // Dükkandan çıkan (Satış)

  String toJson() => name;
  static IslemTipi fromJson(String json) => IslemTipi.values.byName(json);
}

/// Fiş Tipi Enumı
enum FisTipi {
  alim,       // Müşteriden altın/ürün alımı
  satis,      // Müşteriye altın/ürün satışı
  iade,       // İade işlemi
  hurdaGiris, // Hurda giriş
  paraGiris,  // Para girişi (Dolar, TL vb.)
  paraCikis;  // Para çıkışı

  String toJson() => name;
  static FisTipi fromJson(String json) => FisTipi.values.byName(json);
}

/// Milyem Seviyeleri
enum MilyemSeviye {
  rawGold(1000),              // Saf altın (işlenmemiş)
  karat24(995),               // 24 Ayar
  karat22(916),               // 22 Ayar
  karat21(875),               // 21 Ayar
  karat18(750),               // 18 Ayar
  karat14(585),               // 14 Ayar
  karat8(333);                // 8 Ayar

  final int deger;
  const MilyemSeviye(this.deger);

  static MilyemSeviye fromDeger(int deger) {
    return values.firstWhere(
      (e) => e.deger == deger,
      orElse: () => throw ArgumentError('Geçersiz milyem değeri: $deger'),
    );
  }
}
