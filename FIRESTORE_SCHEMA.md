# IKARUS MİLYEM - Firebase Firestore Schema (NoSQL)

## Koleksiyonlar (Collections) Mimarisi

### 1. **Firma** Collection
Sistem içindeki tüm firmaları/dükkanları tutar.

```
/firmas
  /{firmaId}
    - name: String (Dükkan adı)
    - kurulusTarihi: Timestamp
    - musteriSayisi: int
    - toplamKasa: double (Toplamda ne kadar para yatıracak)
    - ortaklar: List<String> (Partner email'leri)
    - createdAt: Timestamp
    - updatedAt: Timestamp
```

---

### 2. **Müşteri** Collection
Firmaya ait müşterileri (Alıcı/Satıcı) tutar.

```
/firmas/{firmaId}/musteriler
  /{musteriId}
    - ad: String (Müşteri adı)
    - telefon: String
    - adres: String
    - ozetTuruId: String? (Hesap türü: Normal, Hurda Toplayıcı, vs.)
    - cariHesap: {
        hasAltinBorcu: double (gram cinsinden)
        turkLiraBorcu: double
        dolarBorcu: double
        hurdaBorcu: double (gram cinsinden)
      }
    - createdAt: Timestamp
    - updatedAt: Timestamp
```

---

### 3. **Stok** Collection
Firma/Tezgah içindeki tüm stok türlerini tutar. Adetli, Adetsiz (ağırlıklı), Hurda, Para, Demirbaş.

```
/firmas/{firmaId}/stoks
  /{stokId}
    - ad: String (Ürün adı: "24 Ayar Bilezik", "Hurda Kahve", "Kasa Para" vb.)
    - stokTuru: Enum ["ADETLI", "ADETSIZ", "HURDA", "PARA", "DEMIRBAŞ"]
    
    # ADETLI (Ziynet - Ürün Başına Öğün)
    - adet: int (Kaç tane var?)
    - iscilikPerAdet: double (Her birine kaçar gram işçilik?)
    - milyemPerAdet: int (Her birinin milyemi)
    - hasAltinGramPerAdet: double (Taşıdığı has altın gram miktarı)
    
    # ADETSIZ (Ağırlıklı)
    - gramAglirlik: double (Toplam ağırlığı)
    - milyem: int (Ürünün milyemi: 995, 916, 875, vb.)
    - hasAltinGram: double (Has altın karşılığı)
    
    # HURDA
    - gramAglirlik: double
    - milyem: int (Hurdanın tahmini milyemi)
    
    # PARA
    - turuPara: Enum ["TL", "DOLAR", "HAS_ALTIN", "HURDA"]
    - miktar: double
    
    # DEMIRBAŞ (Makine, Tezgah vb.)
    - ad: String
    - oasDegeri: double (Opsiyonel - İtfaiye Akaryakıt Satış değeri)
    
    - createdAt: Timestamp
    - updatedAt: Timestamp
```

---

### 4. **Kur** Collection
Döviz ve Altın kurlarını tutar.

```
/firmas/{firmaId}/kurlar
  /{kurId}
    - tarih: Timestamp (Hangi güne ait)
    - dolarTL: double (1 Dolar = ? TL)
    - gramHasAltinTL: double (1 Gram Has Altın = ? TL)
    - gramHurdaTL: double (1 Gram Hurda = ? TL)
    - kaynak: String ("MANUEL" veya "HAREM_ALTIN_API")
    - createdAt: Timestamp
    - updatedAt: Timestamp
```

---

### 5. **İşlem (Fiş)** Collection
Tüm alışveriş, iade, hurda işlemleri ve para giriş/çıkışlarını tutar. Her işlem atomik ve izlenebilir olmalıdır.

```
/firmas/{firmaId}/islemler
  /{islemId}
    # İşlem Başlığı
    - fisTipi: Enum ["ALIM", "SATIS", "IADE", "HURDA_GIRIS", "PARA_GIRIS", "PARA_CIKIS"]
    - tarihSaat: Timestamp
    - musteriId: String (İlgili müşteri, eğer yoksa "SISTEM")
    
    # Para Kaynağı / Hedefi
    - odemeTurleri: List<{
        turuPara: String ("TL", "DOLAR", "HAS_ALTIN", "HURDA"),
        miktar: double,
        aciklamasi: String?
      }>
    
    # Ürün Bilgisi
    - urunler: List<{
        ad: String,
        milyem: int,
        gram: double (veya adet, işlem türüne göre),
        iscilik: double (gram cinsinden, işçilik)
      }>
    
    # Hesaplama Sonuçları (İşlem sırasında Dart tarafından hesaplanmış)
    - toplamHasAltinGram: double (Tüm ürünlerin has altın karşılığı)
    - toplamIscilik: double (Toplam işçilik)
    - aciklamasi: String?
    
    # Audit
    - kullanimiId: String (Kimin tarafından yapıldı)
    - createdAt: Timestamp
    - updatedAt: Timestamp
    - guncellemeler: List<{
        tarih: Timestamp,
        kullaniciId: String,
        degisiklik: String
      }>
```

---

## İşlem Güvenliği (Transactions)

### Firestore Transactions / Batched Writes Kullanılacak Yerler:
1. **SATIS işlemi**: Stok azaltma + Müşteri cari hesap güncelleme
2. **ALIM işlemi**: Stok artırma + Müşteri cari hesap güncelleme
3. **HURDA işlemi**: Hurda stok azaltma + Para stok artırma + İşlem kaydı
4. **Para Kaydı**: Cari hesap + Para stok güncelleme

Hiçbir işlem yarıda kesintiye uğrayacak şekilde tasarlanmamıştır. Transaction fail olursa tamamı geri alınır.

---

## İndeks Gereksinimleri (Firestore Composite Indexes)

```
1. /firmas/{firmaId}/islemler:
   - tarihSaat (Ascending)
   - fisTipi (Ascending)
   
2. /firmas/{firmaId}/musteriler:
   - createdAt (Descending)
   
3. /firmas/{firmaId}/stoks:
   - stokTuru (Ascending)
   - createdAt (Descending)
```

---

## Koleksiyon Erişim Kuralları (Firestore Security Rules)

```
rules_version = '3';
match /databases/{database}/documents {
  // Firma sahibi ve ortakları tüm koleksiyonlara erişebilir
  match /firmas/{firmaId} {
    allow read, write: if request.auth != null && 
      (resource.data.ortaklar.contains(request.auth.token.email));
  }
  
  match /firmas/{firmaId}/{document=**} {
    allow read, write: if request.auth != null && 
      get(/databases/$(database)/documents/firmas/$(firmaId)).data.ortaklar.contains(request.auth.token.email);
  }
}
```
