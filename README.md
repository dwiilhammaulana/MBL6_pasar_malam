# e_commerce

| Info | Detail |
| --- | --- |
| Nama | Dwi Ilham Maulana |
| Kelas | TISE23M |
| Mata Kuliah | KB1154 - Aplikasi Mobile Lanjutan |
| Tugas | UAS - Integrasi E-Commerce dengan E-Money menggunakan Deep Link |

## Deskripsi

e_commerce adalah aplikasi Flutter merchant yang digunakan untuk melihat produk, mengelola keranjang, checkout, dan melakukan pembayaran menggunakan aplikasi e-money Dompet Jajan.

Integrasi pembayaran dilakukan dengan app-to-app deep link. Aplikasi e_commerce membuka aplikasi Dompet Jajan menggunakan skema `dompetkampus://pay`, lalu menerima hasil pembayaran kembali melalui skema callback `pasarmalam://payment-callback`.

## Fitur Utama

- Login dan register menggunakan Firebase Authentication.
- Integrasi backend Golang untuk data produk, order, dan status pembayaran.
- Daftar produk, detail produk, keranjang, checkout, dan riwayat pesanan.
- Metode pembayaran Dompet Jajan.
- Halaman pending payment untuk menunggu callback dari aplikasi e-money.
- Deep link callback untuk mengubah status order menjadi paid.
- Biometric lock untuk keamanan aplikasi.

## Arsitektur Singkat

Struktur kode menggunakan pemisahan `core` dan `features`.

```text
lib/
|-- main.dart
|-- firebase_options.dart
|-- core/
|   |-- constants/
|   |-- providers/
|   |-- routes/
|   |-- services/
|   |-- theme/
|   `-- widgets/
`-- features/
    |-- auth/
    |-- cart/
    |-- dashboard/
    |-- order/
    `-- product/
```

| Bagian | Fungsi |
| --- | --- |
| `core/constants` | Konfigurasi URL API dan konstanta global. |
| `core/services` | Service umum, termasuk deep link payment. |
| `core/routes` | Konfigurasi navigasi halaman. |
| `features/auth` | Login, register, dan autentikasi pengguna. |
| `features/cart` | Keranjang dan checkout. |
| `features/order` | Order, status pembayaran, dan riwayat transaksi. |
| `features/product` | Daftar dan detail produk. |

State management utama menggunakan `Provider`, komunikasi API menggunakan `Dio`, dan data sensitif disimpan dengan `flutter_secure_storage`.

## Konfigurasi Backend

Backend E-Commerce berjalan pada port `8081`.

```text
Base URL Flutter: http://127.0.0.1:8081/v1
Folder backend: ../be-E_commerce
```

Jika menjalankan aplikasi di HP Android fisik lewat USB, aktifkan reverse port:

```powershell
adb reverse tcp:8081 tcp:8081
```

## Cara Menjalankan

1. Jalankan backend E-Commerce.

```powershell
cd "D:\kulyah\smt 6\mobile app lanjutan\12\inside dosen\be-E_commerce"
go run .
```

2. Jalankan aplikasi Flutter.

```powershell
cd "D:\kulyah\smt 6\mobile app lanjutan\12\inside dosen\e_commerce"
flutter pub get
adb reverse tcp:8081 tcp:8081
flutter run
```

3. Pastikan endpoint health dapat diakses dari device.

```text
http://127.0.0.1:8081/v1/health
```

## Deep Link Payment

### Deep link keluar ke Dompet Jajan

```text
dompetkampus://pay?merchant_id=MCH_E_COMMERCE&merchant_name=e_commerce&amount=75000&description=Order%20%231&reference=INV-1&callback=pasarmalam%3A%2F%2Fpayment-callback
```

### Callback masuk dari Dompet Jajan

```text
pasarmalam://payment-callback?status=success&reference=INV-1&transaction_id=TXN789
```

Jika callback berhasil dan `reference` sesuai order, aplikasi akan memanggil endpoint backend:

```text
POST /v1/orders/:id/mark-paid
```

## Test Manual

1. Login ke aplikasi e_commerce.
2. Pilih produk dan masukkan ke keranjang.
3. Checkout menggunakan metode pembayaran Dompet Jajan.
4. Pastikan aplikasi Dompet Jajan terbuka.
5. Selesaikan pembayaran di aplikasi Dompet Jajan.
6. Pastikan kembali ke e_commerce dan status order menjadi paid.

Callback juga dapat dites manual dengan ADB:

```powershell
adb shell am start -a android.intent.action.VIEW -d "pasarmalam://payment-callback?status=success&reference=INV-1&transaction_id=TXN789"
```

## Dependensi Utama

| Dependency | Fungsi |
| --- | --- |
| `provider` | State management. |
| `firebase_core`, `firebase_auth` | Autentikasi Firebase. |
| `google_sign_in` | Login Google. |
| `dio` | HTTP client ke backend. |
| `flutter_secure_storage` | Penyimpanan token dan data sensitif. |
| `local_auth` | Biometric lock. |
| `app_links` | Deep link callback. |
| `url_launcher` | Membuka aplikasi e-money melalui deep link. |

## Build APK

```powershell
flutter build apk --debug
```

atau untuk release:

```powershell
flutter build apk --release
```

## Dokumentasi Pengumpulan

- Screenshot aplikasi: tambahkan pada bagian ini sebelum dikumpulkan.
- Link video presentasi: https://youtu.be/D5u48pCRPgg
- APK: lampirkan file hasil build dari folder `build/app/outputs/flutter-apk/`.
