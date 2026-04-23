# Firebase Konfigürasyon Rehberi - IKARUS MİLYEM

## Adım 1: Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com) adresine gidin
2. "Yeni Proje Oluştur" tıklayın
3. Proje adı: `ikarus-milyem` (ya da tercih ettiğiniz ad)
4. Google Analytics'i etkinleştirin (opsiyonel)

---

## Adım 2: Flutter Projesine Firebase Entegre Etme

### Web Platformu İçin (Şu an test için)

1. Firebase CLI'ı yükleme:
```bash
npm install -g firebase-tools
firebase login
```

2. Flutter projesi kökünde Firebase'i initialize etme:
```bash
firebase init
```

3. İlgili seçenekler:
   - ✓ Firestore
   - ✓ Authentication (Kim kullanıyor)
   - ✓ Hosting (Web depolama)

4. Flutter projesine FlutterFire CLI plugin yükleme:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Bu komut otomatik olarak:
- iOS/Android/Web konfigürasyon dosyalarını oluşturur
- `lib/firebase_options.dart` dosyasını oluşturur

---

## Adım 3: Firestore Koleksiyonları ve İndexes Oluşturma

### Firestore'da Koleksiyon Başlatma

1. Firebase Console → Firestore Database
2. "Koleksiyon Başlat" (Start Collection) tıklayın
3. Aşağıdaki koleksiyonları oluşturun:

#### Collection: `/firmas`
```
Document ID: (auto-generated)
{
  name: "Dükkan Adı",
  kurulusTarihi: 2024-01-01T00:00:00Z,
  musteriSayisi: 0,
  toplamKasa: 0.0,
  ortaklar: ["example@gmail.com"],
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### Subcollection: `/firmas/{firmaId}/musteriler`
```
Document ID: (auto-generated)
{
  ad: "Müşteri Adı",
  telefon: "05xx xxx xxxx",
  adres: "Adres",
  ozetTuruId: null,
  cariHesap: {
    hasAltinBorcu: 0.0,
    turkLiraBorcu: 0.0,
    dolarBorcu: 0.0,
    hurdaBorcu: 0.0
  },
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### Subcollection: `/firmas/{firmaId}/stoks`
Farklı stok türlerine göre belgeler oluşturun. Örnek (ADETLI):
```
{
  ad: "24 Ayar Bilezik",
  stokTuru: "adetli",
  adet: 5,
  iscilikPerAdet: 2.5,
  milyemPerAdet: 995,
  hasAltinGramPerAdet: 7.5,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### Subcollection: `/firmas/{firmaId}/kurlar`
```
{
  tarih: 2024-01-18T00:00:00Z,
  dolarTL: 35.50,
  gramHasAltinTL: 2500.00,
  gramHurdaTL: 1200.00,
  kaynak: "MANUEL",
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### Subcollection: `/firmas/{firmaId}/islemler`
```
{
  fisTipi: "satis",
  tarihSaat: 2024-01-18T10:30:00Z,
  musteriId: "SISTEM",
  odemeTurleri: [
    {
      turuPara: "hasAltin",
      miktar: 5.25,
      aciklamasi: "Ana ödeme"
    }
  ],
  urunler: [
    {
      ad: "24 Ayar Çubuk",
      milyem: 995,
      gram: 10.0,
      iscilik: 2.0
    }
  ],
  toplamHasAltinGram: 10.0,
  toplamIscilik: 2.0,
  aciklamasi: null,
  kullanimiId: "admin",
  createdAt: timestamp,
  updatedAt: timestamp,
  guncellemeler: []
}
```

---

## Adım 4: Firestore Security Rules Ayarı

Firestore Console → Rules sekmesine gidin ve aşağıdaki kuralları yapıştırın:

```
rules_version = '3';
match /databases/{database}/documents {
  // Firma ve tüm subcollections için erişim kontrolü
  match /firmas/{firmaId} {
    allow read, write: if request.auth != null;
  }
  
  match /firmas/{firmaId}/{document=**} {
    allow read, write: if request.auth != null;
  }
}
```

**NOT:** Üretim ortamında daha katı kurallar uygulanmalıdır.

---

## Adım 5: Authentication (Kimlik Doğrulama) Ayarı

1. Firebase Console → Authentication → Başlangıç Rehberi
2. "Email/Şifre" sign-in method'unu etkinleştirin
3. Varsayılan olarak ilk kullanıcıyı Firebase Console'dan oluşturun:
   - Email: `admin@ikarus.local`
   - Şifre: (güvenli bir şifre seçin)

---

## Adım 6: Indexes (İndexler) Oluşturma

Performans için composite indexler oluşturun. Firebase, taşkın sorgu çalıştırdığında otomatik olarak index önerir.

Önerilen indexler:
```
Collection: /firmas/{firmaId}/islemler
- Field: tarihSaat (Ascending)
- Field: fisTipi (Ascending)

Collection: /firmas/{firmaId}/musteriler
- Field: createdAt (Descending)

Collection: /firmas/{firmaId}/stoks
- Field: stokTuru (Ascending)
```

---

## Adım 7: main.dart Başlatma

Firebase'i Flutter uygulamasına başlat:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

---

## Adım 8: Web Dağıtımı (Deployment)

Faz 1 sonunda Web testleri yapmak için:

```bash
flutter build web
firebase deploy --only hosting
```

---

## API Konfigürasyonu: Harem Altın (Opsiyonel)

Faz 4'te kur entegrasyonu için Harem Altın API'si kullanılacaktır.

- **API Base URL:** https://haremAltinAPI.com (örnek)
- **Endpoint:** `/latest-rates`
- **Örnek Response:**
```json
{
  "dolarTL": 35.50,
  "gramHasAltinTL": 2500.00,
  "timestamp": "2024-01-18T10:00:00Z"
}
```

Bu Faz 4'te uygulanacaktır.

---

## Firestore Emulator (Geliştirme)

Yerel test için emulator kullanabilirsiniz:

```bash
firebase emulators:start --only firestore,auth
```

Dart kodunuzda emulator bağlantısı:
```dart
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
```
