# Jual Alat Pemadam Kebakaran

| Info | Detail |
|------|--------|
| **Nama** | Dwi Ilham Maulana |
| **Kelas** | TISE23M |
| **Mata Kuliah** | Mobile Aplikasi Lanjutan |
| **Ujian** | Ujian Tengah Semester (UTS) |

---

## Struktur Folder `lib`

Aplikasi ini mengadopsi arsitektur modular yang memisahkan antara lapisan **core** (inti) dan **features** (fitur bisnis), sehingga kode lebih terorganisir dan mudah dikembangkan.

```
lib/
├── main.dart               # Entry point aplikasi Flutter
├── firebase_options.dart   # Konfigurasi Firebase (auto-generated oleh FlutterFire)
├── core/
│   ├── constants/          # Konstanta global (teks, nilai tetap, dll.)
│   ├── routes/             # Konfigurasi navigasi dan routing halaman
│   ├── services/           # Layanan umum (API service, konfigurasi, dll.)
│   └── theme/              # Tema aplikasi (warna, typography, gaya global)
└── features/
    ├── auth/               # Fitur autentikasi (Login & Register)
    └── dashboard/          # Fitur halaman utama (Dashboard)
```

### Penjelasan Singkat

| File / Folder | Fungsi |
|---|---|
| `main.dart` | Titik masuk utama yang menginisialisasi dan menjalankan aplikasi |
| `firebase_options.dart` | Menyimpan konfigurasi koneksi ke layanan Firebase |
| `core/constants/` | Variabel konstanta yang digunakan secara global |
| `core/routes/` | Definisi alur navigasi antar halaman |
| `core/services/` | Kumpulan service umum yang dapat digunakan lintas fitur |
| `core/theme/` | Konfigurasi tampilan global (warna, font, style) |
| `features/auth/` | UI, state management, dan logika autentikasi pengguna |
| `features/dashboard/` | UI, state management, dan logika halaman utama |

---

## Cara Menjalankan Aplikasi

Aplikasi ini terdiri dari dua bagian terpisah: **Frontend** (Flutter) dan **Backend** (Golang). Keduanya harus dijalankan bersamaan agar aplikasi berfungsi penuh.

### 1. Backend — Golang

> Repository backend: [github.com/dwiilhammaulana/MBL5_BackendGolang](https://github.com/dwiilhammaulana/MBL5_BackendGolang)

Buka terminal pada direktori proyek backend, lalu jalankan:

```bash
go run main.go
```

### 2. Frontend — Flutter

Buka terminal pada root direktori proyek Flutter (lokasi file `pubspec.yaml`), kemudian jalankan perintah berikut secara berurutan:

```bash
# 1. Install semua dependensi
flutter pub get

# 2. Pastikan emulator/device sudah terhubung, lalu jalankan aplikasi
flutter run
```

---

## Demo Aplikasi

Tonton video demo dan review aplikasi melalui tautan berikut:

mohon maaf pak untuk demo aplikasi ini vidio saya terblokir 3 kali dengan keterangan membagikan data pribadi
![alt text](<WhatsApp Image 2026-04-26 at 20.45.42.jpeg>) 


maka dari itu saya alihkan ke Link Drive saja ya pak, berikut untuk linknya:
https://drive.google.com/file/d/1BeAyvIMkLeCZ9g9I3Het8jkIId3XbzEW/view?usp=sharing

---

## Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Frontend | Flutter |
| Backend | Golang |
| Database / Auth | Firebase |