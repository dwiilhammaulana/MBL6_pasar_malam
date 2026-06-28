# e_commerce

| Info | Detail |
| --- | --- |
| Nama | Dwi Ilham Maulana |
| NIM | 1123150008 |
| Kelas | TISE23M |
| Mata Kuliah | KB1154 - Aplikasi Mobile Lanjutan |
| Tugas | UAS - Integrasi E-Commerce dengan E-Money menggunakan Deep Link |

## Link Repo Terkait

- BE e commerce: [dwiilhammaulana/MBL5_BackendGolang](https://github.com/dwiilhammaulana/MBL5_BackendGolang)
- E commerce: [dwiilhammaulana/MBL6_pasar_malam](https://github.com/dwiilhammaulana/MBL6_pasar_malam)
- BE e money: [dwiilhammaulana/be_e_money](https://github.com/dwiilhammaulana/be_e_money)
- e money: [dwiilhammaulana/e_money](https://github.com/dwiilhammaulana/e_money)

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

- Video presentasi: [https://youtu.be/D5u48pCRPgg](https://youtu.be/D5u48pCRPgg)
- APK: lampirkan file dari folder `build/app/outputs/flutter-apk/`.
- Screenshot aplikasi: lihat bagian di bawah.

## Screenshot

### Aplikasi E-Money

| | | |
| --- | --- | --- |
| <img src="image.png" alt="Splash atau halaman awal" width="220"> | <img src="WhatsApp%20Image%202026-06-28%20at%2014.12.58.jpeg" alt="Dokumentasi WhatsApp" width="220"> | <img src="image-1.png" alt="E-Money 1" width="220"> |
| <img src="image-2.png" alt="E-Money 2" width="220"> | <img src="image-3.png" alt="E-Money 3" width="220"> | <img src="image-4.png" alt="E-Money 4" width="220"> |
| <img src="image-5.png" alt="E-Money 5" width="220"> | <img src="image-6.png" alt="E-Money 6" width="220"> | <img src="image-7.png" alt="E-Money 7" width="220"> |
| <img src="image-8.png" alt="E-Money 8" width="220"> | | |

### Integrasi E-Commerce

| | | |
| --- | --- | --- |
| <img src="image-9.png" alt="E-Commerce 1" width="220"> | <img src="image-10.png" alt="E-Commerce 2" width="220"> | <img src="image-11.png" alt="E-Commerce 3" width="220"> |
| <img src="image-13.png" alt="E-Commerce 4" width="220"> | <img src="image-12.png" alt="E-Commerce 5" width="220"> | <img src="image-14.png" alt="E-Commerce 6" width="220"> |
| <img src="image-15.png" alt="E-Commerce 7" width="220"> | | |

## Checklist UAS

| Kriteria | Status |
| --- | --- |
| Aplikasi E-Money tersedia | Selesai |
| Backend E-Money tersedia | Selesai |
| Integrasi deep link dari E-Commerce ke E-Money | Selesai |
| Callback pembayaran dari E-Money ke E-Commerce | Selesai |
| Autentikasi Firebase | Selesai |
| 2FA | Selesai |
| FCM | Selesai |
| APK dapat dibuild | Selesai |
| README berisi cara menjalankan dan test manual | Selesai |
| Screenshot dan video presentasi | Selesai |
