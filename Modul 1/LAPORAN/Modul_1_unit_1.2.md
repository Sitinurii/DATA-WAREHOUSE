# LAPORAN MODUL 1 UNIT 1.2

# DATA PROFILING DAN DATA QUALITY ASSESSMENT

> **Petunjuk penggunaan:** Template ini digunakan untuk mendokumentasikan pengerjaan 38 soal SQL pada database akademik UADW v1.0. Isi bagian bertanda `[Isi ...]`, tempelkan query yang benar-benar dijalankan, lampirkan hasil eksekusi, lalu tuliskan interpretasi berdasarkan hasil tersebut. Nomor modul/unit dapat disesuaikan dengan susunan praktikum.

---

## Identitas Laporan

Nama       : [Siti Nuri Andriani]  
NIM        : [240306055]  
Program Studi : [Teknologi Informasi]  
Modul      : 1  
Unit       : 1.2  
Tanggal Praktikum : [12 November 2026]  
DBMS       : PostgreSQL 18.6  
Database   : `uadw_lab`  
Schema     : `src`

---

## Tujuan Praktikum

Setelah menyelesaikan praktikum ini, mahasiswa diharapkan mampu:

1. Melakukan profiling terhadap struktur dan ukuran dataset akademik.
2. Memeriksa kualitas data berdasarkan aspek *uniqueness*, *completeness*, *validity*, dan *consistency*.
3. Mengidentifikasi indikasi duplikasi pada tabel master maupun transaksi.
4. Memeriksa keterhubungan data antar-tabel (*referential integrity*).
5. Menyusun interpretasi berdasarkan hasil eksekusi query SQL tanpa langsung mengubah data sumber.

## Ketentuan Pengerjaan

1. Gunakan PostgreSQL dan schema `src`.
2. Gunakan dataset UADW v1.0 yang disediakan pada praktikum.
3. Pertahankan data pada source layer dalam kondisi aslinya (*raw data*).
4. Praktikum ini berfokus pada pemeriksaan. Jangan melakukan `UPDATE`, `DELETE`, deduplikasi, atau standardisasi langsung pada tabel `src`.
5. Tempelkan query yang benar-benar dijalankan. Query boleh disesuaikan selama menghasilkan pemeriksaan yang diminta.
6. Sertakan hasil eksekusi. Untuk hasil berbentuk tabel, salin tabel hasil atau lampirkan tangkapan layar yang terbaca.
7. Interpretasi harus sesuai dengan hasil aktual. Jangan mengarang hasil atau menyimpulkan bahwa data harus dihapus hanya karena terindikasi duplikat.
8. Apabila query menghasilkan nol baris atau nilai 0, tuliskan maknanya dalam interpretasi.

---

# 1. Menyiapkan dan Memverifikasi Environment Praktikum

Pastikan perangkat kerja dan koneksi database tersedia sebelum melakukan profiling.

### 1.1 Memeriksa versi PostgreSQL

**Tujuan pemeriksaan**  
Memastikan DBMS yang digunakan adalah PostgreSQL dan mengetahui versinya sebelum profiling dilakukan.

**Query SQL**

```sql
SELECT version();
```

**Hasil eksekusi**

![Memeriksa versi PostgreSQL](Memeriksa versi PostgreSQL.png)

*Bukti eksekusi (file gambar): `Memeriksa versi PostgreSQL.png`*

**Keterangan**

Versi yang digunakan adalah **PostgreSQL 18.6** (x86_64-windows, dikompilasi dengan msvc-19.44.35228, 64-bit). Hasil ini menegaskan bahwa DBMS praktikum adalah PostgreSQL sesuai ketentuan.

### 1.2 Memeriksa database dan user aktif

**Tujuan pemeriksaan**  
Mengetahui database dan user yang sedang aktif agar pemeriksaan dijalankan pada database yang benar.

**Query SQL**

```sql
SELECT
    current_database() AS database_aktif,
    current_user       AS user_aktif;
```

**Hasil eksekusi**

![Memeriksa database dan user aktif](Memeriksa%20database%20dan%20user%20aktif.png)

*Bukti eksekusi (file gambar): `Memeriksa database dan user aktif.png`*

**Keterangan**

- Database aktif: `uadw_lab`
- User aktif: `postgres`

### 1.3 Memastikan schema `src` tersedia

**Tujuan pemeriksaan**  
Memastikan schema `src` yang berisi data sumber (raw) tersedia sebelum pemeriksaan dimulai.

**Query SQL**

```sql
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'src';
```

**Hasil eksekusi**

![Memastikan schema src tersedia](Memastikan%20schema%20src%20tersedia.png)

*Bukti eksekusi (file gambar): `Memastikan schema src tersedia.png`*

**Keterangan**

Schema `src` ditemukan (hasil satu baris bernilai `src`), sehingga seluruh tabel sumber dapat diakses pada pemeriksaan berikutnya.

---

# 2. Profiling Struktur dan Ukuran Dataset

## 2.1 Soal 1 — Menghitung jumlah record setiap tabel

**Tujuan pemeriksaan**  
Mengetahui jumlah record pada sepuluh tabel sumber database akademik.

**Query SQL**

```sql
-- Soal 1 — Menghitung jumlah record setiap tabel
SELECT 'aktivitas_lms' AS nama_tabel, COUNT(*) AS jumlah_record FROM src.aktivitas_lms
UNION ALL
SELECT 'dosen', COUNT(*) FROM src.dosen
UNION ALL
SELECT 'kelulusan', COUNT(*) FROM src.kelulusan
UNION ALL
SELECT 'krs', COUNT(*) FROM src.krs
UNION ALL
SELECT 'mahasiswa', COUNT(*) FROM src.mahasiswa
UNION ALL
SELECT 'mata_kuliah', COUNT(*) FROM src.mata_kuliah
UNION ALL
SELECT 'nilai', COUNT(*) FROM src.nilai
UNION ALL
SELECT 'pembayaran', COUNT(*) FROM src.pembayaran
UNION ALL
SELECT 'program_studi', COUNT(*) FROM src.program_studi
UNION ALL
SELECT 'semester', COUNT(*) FROM src.semester;
```

**Hasil eksekusi**

| Dataset | Jumlah Record |
|---|---:|
| `program_studi` | 12 |
| `semester` | 8 |
| `mahasiswa` | 1.965 |
| `dosen` | 96 |
| `mata_kuliah` | 208 |
| `krs` | 57.025 |
| `nilai` | 57.000 |
| `aktivitas_lms` | 200.356 |
| `pembayaran` | 9.500 |
| `kelulusan` | 347 |

![Menghitung jumlah record setiap tabel](Menghitung%20jumlah%20record%20setiap%20tabel.png)

*Bukti eksekusi (file gambar): `Menghitung jumlah record setiap tabel.png`*

**Interpretasi**

Total record pada sepuluh tabel adalah 326.517. Tabel dengan record terbanyak adalah `aktivitas_lms` (200.356 record, sekitar 61,36% dari total), disusul `krs` (57.025) dan `nilai` (57.000). Tabel dengan record paling sedikit adalah `semester` (8), kemudian `program_studi` (12) dan `dosen` (96). Tabel `mahasiswa` memuat 1.965 record. Gambaran ini menunjukkan dataset didominasi tabel transaksi (aktivitas LMS, KRS, nilai, pembayaran), sedangkan tabel master berukuran jauh lebih kecil.

## 2.2 Soal 2 — Menghitung jumlah kolom setiap tabel

**Tujuan pemeriksaan**  
Mengetahui jumlah kolom pada setiap tabel dalam schema `src`.

**Query SQL**

```sql
-- Soal 2 — Menghitung jumlah kolom setiap tabel
SELECT
    table_name AS nama_tabel,
    COUNT(*) AS jumlah_kolom
FROM information_schema.columns
WHERE table_schema = 'src'
GROUP BY table_name
ORDER BY table_name;
```

**Hasil eksekusi**

| Nama Tabel | Jumlah Kolom |
|---|---:|
| `program_studi` | 5 |
| `semester` | 6 |
| `mahasiswa` | 11 |
| `dosen` | 7 |
| `mata_kuliah` | 7 |
| `krs` | 8 |
| `nilai` | 8 |
| `aktivitas_lms` | 9 |
| `pembayaran` | 8 |
| `kelulusan` | 7 |

![Menghitung jumlah kolom setiap tabel](Menghitung%20jumlah%20kolom%20setiap%20tabel.png)

*Bukti eksekusi (file gambar): `Menghitung jumlah kolom setiap tabel.png`*

**Interpretasi**

Total kolom pada sepuluh tabel adalah 76. Tabel `mahasiswa` memiliki kolom terbanyak (11), diikuti `aktivitas_lms` (9). Tabel `krs`, `nilai`, dan `pembayaran` masing-masing 8 kolom; `dosen`, `kelulusan`, dan `mata_kuliah` masing-masing 7 kolom; `semester` 6 kolom; dan `program_studi` paling sedikit dengan 5 kolom. Banyaknya kolom pada `mahasiswa` sejalan dengan banyaknya atribut mentah (`*_raw`) yang diperiksa pada soal-soal berikutnya.

---

# 3. Profiling Tabel Mahasiswa

## 3.1 Soal 3 — Mengukur keunikan NIM

**Tujuan pemeriksaan**  
Mengetahui jumlah record mahasiswa, jumlah NIM unik, dan indikasi kelebihan record berdasarkan NIM.

**Query SQL**

```sql
-- Soal 3 — Mengukur keunikan NIM mahasiswa
SELECT
    COUNT(*) AS total_record,
    COUNT(DISTINCT nim) AS nim_unik,
    COUNT(*) - COUNT(DISTINCT nim) AS kelebihan_record
FROM src.mahasiswa;
```

**Hasil eksekusi**

| Raw Rows | Distinct NIM | Excess Duplicate Rows |
|---:|---:|---:|
| 1.965 | 1.950 | 15 |

![Mengukur keunikan NIM mahasiswa](Mengukur%20keunikan%20NIM%20mahasiswa.png)

*Bukti eksekusi (file gambar): `Mengukur keunikan NIM mahasiswa.png`*

**Interpretasi**

Terdapat 1.965 record mahasiswa, tetapi hanya 1.950 NIM yang unik, sehingga ada 15 record berlebih (sekitar 0,76% dari seluruh record). Hal ini mengindikasikan adanya NIM yang tercatat lebih dari satu kali. Pemeriksaan ini belum membuktikan bahwa record tersebut harus dihapus; atribut lain atau kemungkinan data historis perlu ditelusuri terlebih dahulu.

## 3.2 Soal 4 — Mengidentifikasi kelompok NIM duplikat

**Tujuan pemeriksaan**  
Menampilkan NIM yang muncul lebih dari satu kali beserta jumlah kemunculannya.

**Query SQL**

```sql
-- Soal 4 — Mengidentifikasi NIM duplikat
SELECT
    nim,
    COUNT(*) AS jumlah_kemunculan
FROM src.mahasiswa
GROUP BY nim
HAVING COUNT(*) > 1
ORDER BY nim;
```

**Hasil eksekusi**

![Mengidentifikasi NIM duplikat](Mengidentifikasi%20NIM%20duplikat.png)

*Bukti eksekusi (file gambar): `Mengidentifikasi NIM duplikat.png`*

**Interpretasi**

- Jumlah kelompok NIM duplikat: 15
- Jumlah kemunculan tertinggi: 2
- Catatan atau pola yang ditemukan: seluruh kelompok muncul tepat 2 kali, sehingga total kelebihan 15 record dan konsisten dengan hasil Soal 3.

NIM yang terindikasi duplikat adalah 21IF0052, 21TI0042, 21TR0015, 22BD0068, 22IF0004, 23DS0040, 23SI0066, 23SI0082, 23TI0055, 24BD0013, 24BD0019, 24BD0028, 24DS0078, 24TI0005, dan 24TI0062. NIM tersebut tersebar pada angkatan 21–24 dan berbagai kode program studi, tanpa pola tunggal yang terlihat dari hasil ini. Atribut lain (misalnya nama, tanggal masuk, dan status) perlu dibandingkan untuk menentukan apakah ini duplikasi atau data historis sebelum menentukan tindakan.

## 3.3 Soal 5 — Memeriksa kelengkapan kota asal mahasiswa

**Tujuan pemeriksaan**  
Menghitung jumlah record dengan `kota_asal_raw` kosong, `NULL`, atau hanya berisi spasi.

**Query SQL**

```sql
-- Soal 5 — Memeriksa data kota asal yang kosong
SELECT
    COUNT(*) AS jumlah_kota_asal_kosong
FROM src.mahasiswa
WHERE kota_asal_raw IS NULL
   OR TRIM(kota_asal_raw) = '';
```

**Hasil eksekusi**

| Missing Kota Asal |
|---:|
| 30 |

![Memeriksa data kota asal yang kosong](Memeriksa%20data%20kota%20asal%20yang%20kosong.png)

*Bukti eksekusi (file gambar): `Memeriksa data kota asal yang kosong.png`*

**Interpretasi**

Terdapat 30 record mahasiswa (sekitar 1,53% dari 1.965) dengan `kota_asal_raw` kosong, `NULL`, atau hanya berisi spasi. Proporsinya kecil, tetapi analisis yang memakai informasi kota asal (misalnya sebaran asal daerah mahasiswa) akan kehilangan 30 mahasiswa atau perlu menyediakan kategori khusus untuk data yang belum diketahui.

## 3.4 Soal 6 — Distribusi mahasiswa berdasarkan program studi mentah

**Tujuan pemeriksaan**  
Menampilkan frekuensi setiap label pada kolom `prodi_raw`.

**Query SQL**

```sql
-- Soal 6 — Distribusi mahasiswa berdasarkan program studi
SELECT
    prodi_raw,
    COUNT(*) AS jumlah_mahasiswa
FROM src.mahasiswa
GROUP BY prodi_raw
ORDER BY prodi_raw;
```

**Hasil eksekusi**

![Distribusi mahasiswa berdasarkan program studi](Distribusi%20mahasiswa%20berdasarkan%20program%20studi.png)

*Bukti eksekusi (file gambar): `Distribusi mahasiswa berdasarkan program studi.png`*

**Interpretasi**

Kolom `prodi_raw` memuat 30 label berbeda. Label dengan frekuensi tertinggi adalah `Teknologi Informasi` (286), diikuti `Sistem Informasi` (281) dan `Informatika` (276); label dengan frekuensi terendah adalah `Data Science` (8). Banyak label tampak merujuk program studi yang sama dengan penulisan berbeda, yaitu variasi huruf besar/kecil (`BISNIS DIGITAL`, `informatika`, `Sains data`), singkatan (`BD`, `DS`, `IF`, `SI`, `TI`, `TR`, `TRK`), dan bentuk penulisan lain (`Bisnis Dig.`, `Sist. Informasi`, `Tek. Informasi`, `Teknik Informatika`, `Data Science`). Pengamatan ini masih berupa dugaan dari tampilan label; kepastian pemetaan memerlukan tabel referensi.

## 3.5 Soal 7 — Menghitung variasi nama program studi

**Tujuan pemeriksaan**  
Menghitung jumlah nilai berbeda pada kolom `prodi_raw`.

**Query SQL**

```sql
-- Soal 7 — Menghitung jumlah variasi program studi
SELECT
    COUNT(DISTINCT prodi_raw) AS jumlah_variasi_prodi
FROM src.mahasiswa;
```

**Hasil eksekusi**

| Jumlah Variasi `prodi_raw` |
|---:|
| 30 |

![Menghitung jumlah variasi program studi](Menghitung%20jumlah%20variasi%20program%20studi.png)

*Bukti eksekusi (file gambar): `Menghitung jumlah variasi program studi.png`*

**Interpretasi**

Kolom `prodi_raw` memiliki 30 variasi label, sedangkan nama program studi resmi pada tabel referensi hanya 6 (Bisnis Digital, Informatika, Sains Data, Sistem Informasi, Teknologi Informasi, dan Teknologi Rekayasa Komputer). Selisih 24 label menunjukkan adanya ketidakkonsistenan penulisan yang cukup besar pada data mentah.

## 3.6 Soal 8 — Distribusi jenis kelamin mahasiswa

**Tujuan pemeriksaan**  
Menampilkan setiap nilai `jk_raw` dan frekuensi kemunculannya.

**Query SQL**

```sql
-- Soal 8 — Distribusi jenis kelamin mahasiswa
SELECT
    jk_raw,
    COUNT(*) AS jumlah_mahasiswa
FROM src.mahasiswa
GROUP BY jk_raw
ORDER BY jk_raw;
```

**Hasil eksekusi**

| `jk_raw` | Jumlah Mahasiswa |
|---|---:|
| `F` | 39 |
| `L` | 764 |
| `Laki-laki` | 162 |
| `M` | 53 |
| `P` | 764 |
| `Perempuan` | 183 |

![Distribusi jenis kelamin mahasiswa](Distribusi%20jenis%20kelamin%20mahasiswa.png)

*Bukti eksekusi (file gambar): `Distribusi jenis kelamin mahasiswa.png`*

**Interpretasi**

Kolom `jk_raw` memiliki 6 label untuk yang tampaknya hanya dua kategori. Berdasarkan pola penulisannya, `L`, `Laki-laki`, dan `M` kemungkinan merujuk pada kategori laki-laki (total 979 record, 49,82%), sedangkan `P`, `Perempuan`, dan `F` kemungkinan merujuk pada kategori perempuan (total 986 record, 50,18%). Ini mengindikasikan adanya perbedaan kode dan penulisan untuk kategori yang kemungkinan sama. Tidak dilakukan standardisasi pada tabel raw; pemetaan dilakukan pada tahap berikutnya.

## 3.7 Soal 9 — Distribusi status mahasiswa

**Tujuan pemeriksaan**  
Menampilkan variasi nilai `status_raw` dan jumlah record pada setiap status.

**Query SQL**

```sql
-- Soal 9 — Distribusi status mahasiswa
SELECT
    status_raw,
    COUNT(*) AS jumlah_mahasiswa
FROM src.mahasiswa
GROUP BY status_raw
ORDER BY status_raw;
```

**Hasil eksekusi**

| `status_raw` | Jumlah Mahasiswa |
|---|---:|
| `Aktif` | 1.567 |
| `AKTIF` | 18 |
| `Aktif` (label kedua) | 16 |
| `cuti` | 9 |
| `Cuti` | 7 |
| `Lulus` | 348 |

![Distribusi status mahasiswa](Distribusi%20status%20mahasiswa.png)

*Bukti eksekusi (file gambar): `Distribusi status mahasiswa.png`*

**Interpretasi**

Kolom `status_raw` memuat enam nilai: `Aktif` (1.567), `AKTIF` (18), satu label lain yang tampak tertulis `Aktif` (16), `cuti` (9), `Cuti` (7), dan `Lulus` (348). Label yang tampak sama (`Aktif`) muncul sebagai dua nilai terpisah, sehingga kemungkinan terdapat spasi atau karakter tersembunyi yang perlu diverifikasi. Jika dikelompokkan secara konseptual, terdapat sekitar 1.601 mahasiswa aktif (81,48%), 16 cuti (0,81%), dan 348 lulus (17,71%). Tidak ditemukan nilai status yang kosong pada hasil ini. Jumlah status `Lulus` (348) perlu dibandingkan dengan tabel `kelulusan` (347 record) pada pemeriksaan lanjutan.

## 3.8 Soal 10 — Distribusi kode program studi

**Tujuan pemeriksaan**  
Menampilkan nilai `kode_prodi_raw` dan frekuensi kemunculannya.

**Query SQL**

```sql
-- Soal 10 — Distribusi kode program studi
SELECT
    kode_prodi_raw,
    COUNT(*) AS jumlah_mahasiswa
FROM src.mahasiswa
GROUP BY kode_prodi_raw
ORDER BY kode_prodi_raw;
```

**Hasil eksekusi**

![Distribusi kode program studi](Distribusi%20kode%20program%20studi.png)

*Bukti eksekusi (file gambar): `Distribusi kode program studi.png`*

**Interpretasi**

Kolom `kode_prodi_raw` memuat 24 nilai berbeda untuk 6 kode program studi (BD, DS, IF, SI, TI, TR). Penulisan huruf kapital baku paling banyak digunakan: `IF` (336), `TI` (326), `SI` (319), `DS` (265), `BD` (256), dan `TR` (255), dengan total 1.757 record (89,41%). Sisanya berupa huruf kecil (`bd`, `ds`, `if`, `si`, `ti`, `tr`) dan variasi yang tampak mengandung spasi di awal atau akhir kode. Tidak ditemukan kode yang kosong. Nilai yang tampak sama tetapi terhitung terpisah perlu diverifikasi (misalnya dengan fungsi `LENGTH()`) dan seluruh kode perlu dibandingkan dengan tabel referensi.

## 3.9 Soal 11 — Mengidentifikasi nama program studi yang tidak sesuai standar

**Tujuan pemeriksaan**  
Menghitung record mahasiswa dengan `prodi_raw` yang tidak memiliki kecocokan persis pada `program_studi.nama_prodi`.

**Query SQL**

```sql
-- Soal 11 — Record mahasiswa dengan prodi_raw tidak cocok persis dengan program_studi
SELECT COUNT(*) AS non_standard_prodi_rows
FROM src.mahasiswa m
WHERE NOT EXISTS (
    SELECT 1
    FROM src.program_studi p
    WHERE p.nama_prodi = m.prodi_raw
);
```

**Hasil eksekusi**

| Non-standard Prodi Rows |
|---:|
| 435 |

![Record mahasiswa dengan prodi_raw tidak cocok persis dengan program_studi](Record%20mahasiswa%20dengan%20prodi_raw%20tidak%20cocok%20persis%20dengan%20program_studi.png)

*Bukti eksekusi (file gambar): `Record mahasiswa dengan prodi_raw tidak cocok persis dengan program_studi.png`*

**Interpretasi**

Terdapat 435 dari 1.965 record mahasiswa (22,14%) yang `prodi_raw`-nya tidak cocok persis dengan `program_studi.nama_prodi`; sisanya 1.530 record (77,86%) cocok persis. Dari 435 record tersebut, 175 record (8,91%) hanya berbeda penulisan (huruf besar/kecil, misalnya `BISNIS DIGITAL`, `informatika`, `Sains data`), sedangkan 260 record (13,23%) tidak memiliki padanan sama sekali, misalnya singkatan (`BD`, `DS`, `IF`, `TI`, `TR`, `TRK`) dan penulisan lain (`Sist. Informasi`, `Tek. Informasi`, `Teknik Informatika`). Ketidakcocokan persis dapat disebabkan variasi penulisan, singkatan, spasi, atau nilai yang memang tidak dikenal, sehingga diperlukan pemeriksaan lebih lanjut untuk memastikan penyebabnya. Selain itu, tabel `program_studi` memuat setiap nama program studi dua kali (12 baris untuk 6 nama), sehingga `JOIN` biasa akan menggandakan record mahasiswa; pemeriksaan ini memakai `NOT EXISTS` agar hasil tidak terdistorsi.

## 3.10 Soal 12 — Mengidentifikasi variasi format tanggal masuk

**Tujuan pemeriksaan**  
Mengelompokkan `tanggal_masuk_raw` berdasarkan format `YYYY-MM-DD`, `DD/MM/YYYY`, `DD-Mon-YYYY`, dan `OTHER`.

**Query SQL**

```sql
-- Soal 12 — Mengidentifikasi variasi format tanggal masuk
SELECT
    CASE
        WHEN tanggal_masuk_raw ~ '^\d{4}-\d{2}-\d{2}$'
            THEN 'YYYY-MM-DD'
        WHEN tanggal_masuk_raw ~ '^\d{2}/\d{2}/\d{4}$'
            THEN 'DD/MM/YYYY'
        WHEN tanggal_masuk_raw ~ '^\d{2}-[A-Za-z]{3}-\d{4}$'
            THEN 'DD-Mon-YYYY'
        ELSE 'OTHER'
    END AS format_tanggal,
    COUNT(*) AS jumlah_data
FROM src.mahasiswa
GROUP BY format_tanggal
ORDER BY format_tanggal;
```

**Hasil eksekusi**

| Format Tanggal | Jumlah Record |
|---|---:|
| `YYYY-MM-DD` | 1.429 |
| `DD/MM/YYYY` | 346 |
| `DD-Mon-YYYY` | 190 |
| `OTHER` | 0 |

![Mengidentifikasi variasi format tanggal masuk](Mengidentifikasi%20variasi%20format%20tanggal%20masuk.png)

*Bukti eksekusi (file gambar): `Mengidentifikasi variasi format tanggal masuk.png`*

**Interpretasi**

Format `YYYY-MM-DD` paling banyak digunakan (1.429 record, 72,72%), diikuti `DD/MM/YYYY` (346 record, 17,61%) dan `DD-Mon-YYYY` (190 record, 9,67%). Kategori `OTHER` bernilai 0 sehingga seluruh 1.965 record sesuai salah satu dari tiga pola. Dengan demikian terdapat tiga format berbeda pada satu kolom. Pemeriksaan pola ini belum membuktikan bahwa tanggalnya valid secara kalender, dan format `DD/MM/YYYY` dapat ambigu jika ada data yang sebenarnya berformat bulan-hari.

---

# 4. Profiling Tabel KRS

## 4.1 Soal 13 — Membandingkan jumlah record KRS dengan KRS unik

**Tujuan pemeriksaan**  
Membandingkan jumlah seluruh record KRS dengan jumlah `krs_id` yang unik.

**Query SQL**

```sql
-- Soal 13 — Pemeriksaan keunikan ID KRS
SELECT
    COUNT(*) AS total_record,
    COUNT(DISTINCT krs_id) AS krs_id_unik
FROM src.krs;
```

**Hasil eksekusi**

| Raw Rows | Distinct KRS ID |
|---:|---:|
| 57.025 | 57.000 |

![Pemeriksaan keunikan ID KRS](Pemeriksaan%20keunikan%20ID%20KRS.png)

*Bukti eksekusi (file gambar): `Pemeriksaan keunikan ID KRS.png`*

**Interpretasi**

Jumlah record KRS (57.025) tidak sama dengan jumlah `krs_id` unik (57.000); selisihnya 25. Hal ini mengindikasikan ada `krs_id` yang tercatat lebih dari satu kali. Perlu ditelusuri apakah record yang memakai `krs_id` sama identik seluruh atributnya atau berbeda.

## 4.2 Soal 14 — Mengidentifikasi duplikasi pengambilan mata kuliah

**Tujuan pemeriksaan**  
Menemukan kombinasi `nim`, `kode_mk`, dan `semester_id` yang muncul lebih dari satu kali pada tabel KRS.

**Query SQL**

```sql
-- Soal 14 — Mengidentifikasi duplikasi data KRS
SELECT
    nim,
    kode_mk,
    semester_id,
    COUNT(*) AS jumlah_kemunculan
FROM src.krs
GROUP BY nim, kode_mk, semester_id
HAVING COUNT(*) > 1
ORDER BY nim, kode_mk, semester_id;
```

**Hasil eksekusi**

![Mengidentifikasi duplikasi data KRS](Mengidentifikasi%20duplikasi%20data%20KRS.png)

*Bukti eksekusi (file gambar): `Mengidentifikasi duplikasi data KRS.png`*

**Interpretasi**

- Jumlah kombinasi yang terindikasi duplikat: 25
- Jumlah kemunculan tertinggi untuk satu kombinasi: 2
- Pola atau catatan penting: seluruh kombinasi muncul tepat 2 kali dan tersebar pada beberapa angkatan, program studi, dan semester (2021E hingga 2024G) tanpa pola tunggal.

Angka 25 kombinasi selaras dengan selisih 25 pada Soal 13, tetapi belum dipastikan bahwa record berlebih tersebut memakai `krs_id` yang sama. Sebelum disebut duplikasi yang harus dihapus, perlu dipertimbangkan kemungkinan kelas berbeda, perubahan status, atau riwayat transaksi.

## 4.3 Soal 15 — Menghitung kelebihan record KRS akibat duplikasi

**Tujuan pemeriksaan**  
Menghitung total record yang melebihi satu record pada setiap kelompok kombinasi NIM, mata kuliah, dan semester yang duplikat.

**Query SQL**

```sql
-- Soal 15 — Menghitung kelebihan record pada kombinasi KRS
SELECT
    SUM(jumlah_kemunculan - 1) AS kelebihan_record
FROM (
    SELECT
        COUNT(*) AS jumlah_kemunculan
    FROM src.krs
    GROUP BY nim, kode_mk, semester_id
    HAVING COUNT(*) > 1
) AS duplikat;
```

**Hasil eksekusi**

| Excess Duplicate KRS |
|---:|
| 25 |

![Menghitung kelebihan record pada kombinasi KRS](Menghitung%20kelebihan%20record%20pada%20kombinasi%20KRS.png)

*Bukti eksekusi (file gambar): `Menghitung kelebihan record pada kombinasi KRS.png`*

**Interpretasi**

Terdapat 25 record berlebih pada kombinasi `nim`, `kode_mk`, dan `semester_id` di tabel KRS. Karena setiap kelompok duplikat hanya berisi 2 record (Soal 14), jumlah record berlebih (25) kebetulan sama dengan jumlah kelompok duplikat (25). Angka ini tidak selalu sama pada kasus lain: kelompok dengan tiga record memiliki dua record berlebih, sehingga jumlah record berlebih tidak boleh disamakan dengan jumlah kelompok duplikat.

---

# 5. Profiling Tabel Nilai

## 5.1 Soal 16 — Menghitung nilai angka yang kosong

**Tujuan pemeriksaan**  
Menghitung record dengan `nilai_angka` kosong, `NULL`, atau hanya berisi spasi.

**Query SQL**

```sql
-- Soal 16 — Memeriksa nilai angka yang kosong
SELECT
    COUNT(*) AS jumlah_nilai_kosong
FROM src.nilai
WHERE nilai_angka IS NULL;
```

**Hasil eksekusi**

| Missing Nilai Angka |
|---:|
| 20 |

![Memeriksa nilai angka yang kosong](Memeriksa%20nilai%20angka%20yang%20kosong.png)

*Bukti eksekusi (file gambar): `Memeriksa nilai angka yang kosong.png`*

**Interpretasi**

Terdapat 20 record nilai (sekitar 0,04% dari 57.000) yang `nilai_angka`-nya kosong. Record ini tidak dapat ikut dalam perhitungan statistik nilai, sehingga analisis yang membutuhkan nilai angka harus memperlakukannya sebagai data yang belum tersedia.

## 5.2 Soal 17 — Mengidentifikasi nilai angka di luar rentang valid

**Tujuan pemeriksaan**  
Menghitung nilai angka di luar rentang 0–100. Nilai kosong tidak dihitung sebagai nilai di luar rentang pada pemeriksaan ini.

**Query SQL**

```sql
-- Soal 17 — Memeriksa nilai angka di luar rentang 0–100
SELECT
    COUNT(*) AS jumlah_nilai_tidak_valid
FROM src.nilai
WHERE nilai_angka < 0
   OR nilai_angka > 100;
```

**Hasil eksekusi**

| Invalid Nilai Angka |
|---:|
| 12 |

![Memeriksa nilai angka di luar rentang 0–100](Memeriksa%20nilai%20angka%20di%20luar%20rentang%200%E2%80%93100.png)

*Bukti eksekusi (file gambar): `Memeriksa nilai angka di luar rentang 0–100.png`*

**Interpretasi**

Terdapat 12 record (sekitar 0,02%) dengan `nilai_angka` di luar rentang 0–100; nilai kosong tidak dihitung pada pemeriksaan ini. Hasil ini belum menunjukkan apakah nilainya di bawah 0 atau di atas 100, sehingga record tersebut perlu ditelusuri lebih lanjut.

## 5.3 Soal 18 — Menghitung statistik deskriptif nilai mahasiswa

**Tujuan pemeriksaan**  
Menghitung jumlah nilai valid, nilai minimum, maksimum, dan rata-rata untuk nilai angka dalam rentang 0–100.

**Query SQL**

```sql
-- Soal 18 — Statistik nilai angka yang valid
SELECT
    COUNT(nilai_angka) AS jumlah_data_valid,
    MIN(nilai_angka) AS nilai_minimum,
    MAX(nilai_angka) AS nilai_maksimum,
    ROUND(AVG(nilai_angka)::numeric, 2) AS nilai_rata_rata
FROM src.nilai
WHERE nilai_angka BETWEEN 0 AND 100;
```

**Hasil eksekusi**

| Valid Rows | Minimum | Maksimum | Rata-rata |
|---:|---:|---:|---:|
| 56.968 | 34,8 | 100 | 77,4 |

![Statistik nilai angka yang valid](Statistik%20nilai%20angka%20yang%20valid.png)

*Bukti eksekusi (file gambar): `Statistik nilai angka yang valid.png`*

**Interpretasi**

Terdapat 56.968 nilai valid (57.000 dikurangi 20 nilai kosong dan 12 nilai di luar rentang). Nilai minimum 34,8, maksimum 100, dan rata-rata 77,4. Secara deskriptif, nilai terkonsentrasi pada rentang yang relatif tinggi. Interpretasi ini hanya deskriptif dan tidak dimaksudkan untuk menilai kualitas pembelajaran.

## 5.4 Soal 19 — Memeriksa konsistensi nilai angka dengan nilai huruf

**Tujuan pemeriksaan**  
Menghitung record dengan ketidaksesuaian antara `nilai_angka` dan `nilai_huruf` berdasarkan aturan konversi berikut.

**Query SQL**

```sql
-- Soal 19 — Memeriksa ketidaksesuaian nilai angka dan nilai huruf
SELECT
    COUNT(*) AS jumlah_tidak_sesuai
FROM src.nilai
WHERE nilai_angka BETWEEN 0 AND 100
AND nilai_huruf IS NOT NULL
AND nilai_huruf <> CASE
    WHEN nilai_angka >= 85 THEN 'A'
    WHEN nilai_angka >= 80 THEN 'AB'
    WHEN nilai_angka >= 75 THEN 'B'
    WHEN nilai_angka >= 70 THEN 'BC'
    WHEN nilai_angka >= 60 THEN 'C'
    WHEN nilai_angka >= 50 THEN 'D'
    ELSE 'E'
END;
```

**Hasil eksekusi**

| Letter Mismatch |
|---:|
| 20 |

![Memeriksa ketidaksesuaian nilai angka dan nilai huruf](Memeriksa%20ketidaksesuaian%20nilai%20angka%20dan%20nilai%20huruf.png)

*Bukti eksekusi (file gambar): `Memeriksa ketidaksesuaian nilai angka dan nilai huruf.png`*

**Interpretasi**

Terdapat 20 record yang `nilai_huruf`-nya tidak sesuai dengan hasil konversi `nilai_angka` berdasarkan aturan modul. Jumlahnya kecil (sekitar 0,04%), tetapi record tersebut perlu ditelusuri lebih lanjut untuk mengetahui apakah kesalahan ada pada nilai angka atau nilai huruf. Record dengan `nilai_huruf` kosong tidak dihitung pada query ini.

## 5.5 Soal 20 — Memeriksa konsistensi nilai angka dengan status kelulusan

**Tujuan pemeriksaan**  
Menghitung record dengan ketidaksesuaian antara `nilai_angka` dan `status_lulus`, dengan ketentuan nilai minimal 60 dinyatakan `Lulus`, sedangkan nilai di bawah 60 dinyatakan `Tidak Lulus`.

**Query SQL**

```sql
-- Soal 20 — Memeriksa kesesuaian status kelulusan
SELECT
    COUNT(*) AS jumlah_status_tidak_sesuai
FROM src.nilai
WHERE nilai_angka BETWEEN 0 AND 100
AND status_lulus IS NOT NULL
AND status_lulus <> CASE
    WHEN nilai_angka >= 60 THEN 'Lulus'
    ELSE 'Tidak Lulus'
END;
```

**Hasil eksekusi**

| Status Mismatch |
|---:|
| 0 |

![Memeriksa kesesuaian status kelulusan](Memeriksa%20kesesuaian%20status%20kelulusan.png)

*Bukti eksekusi (file gambar): `Memeriksa kesesuaian status kelulusan.png`*

**Interpretasi**

Hasil 0 berarti tidak ditemukan ketidaksesuaian antara `nilai_angka` dan `status_lulus` berdasarkan aturan pada soal (nilai minimal 60 berstatus `Lulus`, di bawah 60 berstatus `Tidak Lulus`), untuk record dengan nilai valid dan status terisi.

## 5.6 Soal 21 — Mengidentifikasi duplikasi record nilai

**Tujuan pemeriksaan**  
Menampilkan kombinasi `nim`, `kode_mk`, dan `semester_id` yang tercatat lebih dari satu kali pada tabel nilai.

**Query SQL**

```sql
-- Soal 21 — Mengidentifikasi duplikasi data nilai
SELECT
    nim,
    kode_mk,
    semester_id,
    COUNT(*) AS jumlah_kemunculan
FROM src.nilai
GROUP BY nim, kode_mk, semester_id
HAVING COUNT(*) > 1
ORDER BY nim, kode_mk, semester_id;
```

**Hasil eksekusi**

![Mengidentifikasi duplikasi data nilai](Mengidentifikasi%20duplikasi%20data%20nilai.png)

*Bukti eksekusi (file gambar): `Mengidentifikasi duplikasi data nilai.png`*

**Interpretasi**

Query tidak menghasilkan baris (0 baris), yang berarti tidak ditemukan kombinasi `nim`, `kode_mk`, dan `semester_id` yang tercatat lebih dari satu kali pada tabel `nilai`. Pemeriksaan tambahan menunjukkan 57.000 record dengan kelebihan record 0, sehingga setiap kombinasi unik dan tidak ada indikasi duplikasi pada grain tersebut. Hasil ini hanya berlaku untuk kombinasi tiga kolom itu dan tidak membuktikan bahwa data nilai bebas dari masalah kualitas lain.

---

# 6. Pemeriksaan Referential Integrity pada KRS dan Nilai

## 6.1 Soal 22 — Memeriksa NIM KRS yang tidak terdaftar sebagai mahasiswa

**Tujuan pemeriksaan**  
Menghitung record KRS dengan NIM yang tidak ditemukan pada tabel mahasiswa.

**Query SQL**

```sql
-- Soal 22 — Memeriksa NIM KRS yang tidak terdaftar sebagai mahasiswa
SELECT
    COUNT(*) AS krs_nim_tidak_terdaftar
FROM src.krs k
WHERE NOT EXISTS (
    SELECT 1
    FROM src.mahasiswa m
    WHERE m.nim = k.nim
);
```

**Hasil eksekusi**

| KRS NIM Tidak Terdaftar |
|---:|
| 0 |

![Memeriksa NIM KRS yang tidak terdaftar sebagai mahasiswa](Memeriksa%20NIM%20KRS%20yang%20tidak%20terdaftar%20sebagai%20mahasiswa.png)

*Bukti eksekusi (file gambar): `Memeriksa NIM KRS yang tidak terdaftar sebagai mahasiswa.png`*

**Interpretasi**

Hasil 0 berarti seluruh NIM pada tabel KRS ditemukan pada tabel `mahasiswa`; tidak ditemukan masalah referensial pada relasi ini.

## 6.2 Soal 23 — Memeriksa NIM pada tabel nilai yang tidak terdaftar sebagai mahasiswa

**Tujuan pemeriksaan**  
Menghitung record nilai dengan NIM yang tidak ditemukan pada tabel mahasiswa.

**Query SQL**

```sql
-- Soal 23 — Memeriksa NIM pada tabel nilai yang tidak terdaftar sebagai mahasiswa
SELECT
    COUNT(*) AS nim_tidak_terdaftar
FROM src.nilai n
WHERE NOT EXISTS (
    SELECT 1
    FROM src.mahasiswa m
    WHERE m.nim = n.nim
);
```

**Hasil eksekusi**

| NIM Tidak Terdaftar |
|---:|
| 0 |

![Memeriksa NIM pada tabel nilai yang tidak terdaftar sebagai mahasiswa](Memeriksa%20NIM%20pada%20tabel%20nilai%20yang%20tidak%20terdaftar%20sebagai%20mahasiswa.png)

*Bukti eksekusi (file gambar): `Memeriksa NIM pada tabel nilai yang tidak terdaftar sebagai mahasiswa.png`*

**Interpretasi**

Hasil 0 berarti seluruh NIM pada tabel `nilai` ditemukan pada tabel `mahasiswa`, sehingga hubungan kedua tabel terpenuhi.

## 6.3 Soal 24 — Memeriksa kode mata kuliah yang tidak memiliki referensi

**Tujuan pemeriksaan**  
Menghitung record nilai dengan `kode_mk` yang tidak ditemukan pada tabel `mata_kuliah`.

**Query SQL**

```sql
-- Soal 24 — Memeriksa kode mata kuliah yang tidak memiliki referensi
SELECT
    COUNT(*) AS orphan_nilai_mk
FROM src.nilai n
WHERE NOT EXISTS (
    SELECT 1
    FROM src.mata_kuliah mk
    WHERE mk.kode_mk = n.kode_mk
);
```

**Hasil eksekusi**

| Orphan Nilai Mata Kuliah |
|---:|
| 0 |

![Memeriksa kode mata kuliah yang tidak memiliki referensi](Memeriksa%20kode%20mata%20kuliah%20yang%20tidak%20memiliki%20referensi.png)

*Bukti eksekusi (file gambar): `Memeriksa kode mata kuliah yang tidak memiliki referensi.png`*

**Interpretasi**

Hasil 0 berarti seluruh `kode_mk` pada tabel `nilai` memiliki referensi pada tabel `mata_kuliah`.

## 6.4 Soal 25 — Memeriksa semester nilai yang tidak memiliki referensi

**Tujuan pemeriksaan**  
Menghitung record nilai dengan `semester_id` yang tidak ditemukan pada tabel `semester`.

**Query SQL**

```sql
-- Soal 25 — Memeriksa semester nilai yang tidak memiliki referensi
SELECT
    COUNT(*) AS orphan_nilai_semester
FROM src.nilai n
WHERE NOT EXISTS (
    SELECT 1
    FROM src.semester s
    WHERE s.semester_id = n.semester_id
);
```

**Hasil eksekusi**

| Orphan Nilai Semester |
|---:|
| 0 |

![Memeriksa semester nilai yang tidak memiliki referensi](Memeriksa%20semester%20nilai%20yang%20tidak%20memiliki%20referensi.png)

*Bukti eksekusi (file gambar): `Memeriksa semester nilai yang tidak memiliki referensi.png`*

**Interpretasi**

Hasil 0 berarti seluruh `semester_id` pada tabel `nilai` memiliki referensi pada tabel `semester`.

---

# 7. Profiling Aktivitas LMS

## 7.1 Soal 26 — Mengukur duplikasi aktivitas LMS

**Tujuan pemeriksaan**  
Membandingkan jumlah seluruh record aktivitas LMS dengan jumlah `lms_event_id` unik.

**Query SQL**

```sql
-- Soal 26 — Mengukur duplikasi aktivitas LMS
SELECT
    COUNT(*) AS raw_rows,
    COUNT(DISTINCT lms_event_id) AS distinct_event_id,
    COUNT(*) - COUNT(DISTINCT lms_event_id) AS duplicate_excess
FROM src.aktivitas_lms;
```

**Hasil eksekusi**

| Raw Rows | Distinct Event ID | Duplicate Excess |
|---:|---:|---:|
| 200.356 | 200.326 | 30 |

![Mengukur duplikasi aktivitas LMS](Mengukur%20duplikasi%20aktivitas%20LMS.png)

*Bukti eksekusi (file gambar): `Mengukur duplikasi aktivitas LMS.png`*

**Interpretasi**

Terdapat 200.356 record aktivitas LMS dengan 200.326 `lms_event_id` unik, sehingga ada 30 record berlebih (sekitar 0,01%). Hal ini mengindikasikan adanya identitas event yang tercatat lebih dari satu kali. Perlu ditelusuri apakah record tersebut identik atau hanya memiliki `lms_event_id` yang sama.

## 7.2 Soal 27 — Menganalisis distribusi tipe aktivitas LMS

**Tujuan pemeriksaan**  
Menampilkan setiap `tipe_event` dan jumlah aktivitas pada masing-masing tipe.

**Query SQL**

```sql
-- Soal 27 — Menganalisis distribusi tipe aktivitas LMS
SELECT
    tipe_event,
    COUNT(*) AS jumlah
FROM src.aktivitas_lms
GROUP BY tipe_event
ORDER BY tipe_event;
```

**Hasil eksekusi**

| `tipe_event` | Jumlah |
|---|---:|
| `assignment_submit` | 43.859 |
| `forum_post` | 10.000 |
| `login` | 50.136 |
| `quiz_attempt` | 40.321 |
| `view_material` | 56.040 |

![Menganalisis distribusi tipe aktivitas LMS](Menganalisis%20distribusi%20tipe%20aktivitas%20LMS.png)

*Bukti eksekusi (file gambar): `Menganalisis distribusi tipe aktivitas LMS.png`*

**Interpretasi**

Terdapat lima tipe aktivitas. Tipe terbanyak adalah `view_material` (56.040; 27,97%), diikuti `login` (50.136; 25,02%), `assignment_submit` (43.859; 21,89%), dan `quiz_attempt` (40.321; 20,12%). Tipe paling sedikit adalah `forum_post` (10.000; 4,99%). Komposisi ini menunjukkan aktivitas LMS didominasi melihat materi dan login, sedangkan partisipasi forum paling rendah.

## 7.3 Soal 28 — Memeriksa kelengkapan skor kuis

**Tujuan pemeriksaan**  
Menghitung aktivitas bertipe `quiz_attempt` yang tidak memiliki skor pada `skor_kuis`.

**Query SQL**

```sql
-- Soal 28 — Memeriksa nilai quiz attempt yang kosong
SELECT
    COUNT(*) AS quiz_score_kosong
FROM src.aktivitas_lms
WHERE tipe_event = 'quiz_attempt'
  AND skor_kuis IS NULL;
```

**Hasil eksekusi**

| Quiz Missing Score |
|---:|
| 0 |

![Memeriksa nilai quiz attempt yang kosong](Memeriksa%20nilai%20quiz%20attempt%20yang%20kosong.png)

*Bukti eksekusi (file gambar): `Memeriksa nilai quiz attempt yang kosong.png`*

**Interpretasi**

Hasil 0 berarti seluruh aktivitas `quiz_attempt` (40.321 record) memiliki nilai pada `skor_kuis`; tidak ditemukan skor kuis yang kosong.

## 7.4 Soal 29 — Mengidentifikasi skor pada aktivitas selain kuis

**Tujuan pemeriksaan**  
Menghitung aktivitas selain `quiz_attempt` yang tetap memiliki nilai pada kolom `skor_kuis`.

**Query SQL**

```sql
-- Soal 29 – Aktivitas Non-Quiz yang Memiliki Skor
SELECT
    COUNT(*) AS nonquiz_with_score
FROM src.aktivitas_lms
WHERE tipe_event <> 'quiz_attempt'
  AND skor_kuis IS NOT NULL;
```

**Hasil eksekusi**

| Nonquiz With Score |
|---:|
| 0 |

![Aktivitas Non-Quiz yang Memiliki Skor](Aktivitas%20Non-Quiz%20yang%20Memiliki%20Skor.png)

*Bukti eksekusi (file gambar): `Aktivitas Non-Quiz yang Memiliki Skor.png`*

**Interpretasi**

Hasil 0 berarti tidak ditemukan aktivitas selain `quiz_attempt` yang memiliki nilai pada `skor_kuis`, sehingga skor hanya muncul pada aktivitas kuis.

---

# 8. Profiling Tabel Pembayaran

## 8.1 Soal 30 — Mengidentifikasi nominal pembayaran negatif

**Tujuan pemeriksaan**  
Menghitung record pembayaran dengan `nominal_bayar` kurang dari nol.

**Query SQL**

```sql
-- Soal 30 – Pembayaran dengan Nominal Negatif
SELECT
    COUNT(*) AS negative_payment
FROM src.pembayaran
WHERE nominal_bayar < 0;
```

**Hasil eksekusi**

| Negative Payment |
|---:|
| 5 |

![Pembayaran dengan Nominal Negatif](Pembayaran%20dengan%20Nominal%20Negatif.png)

*Bukti eksekusi (file gambar): `Pembayaran dengan Nominal Negatif.png`*

**Interpretasi**

Terdapat 5 record pembayaran (sekitar 0,05% dari 9.500) dengan `nominal_bayar` negatif. Transaksi ini perlu ditelusuri sesuai konteks pencatatan keuangan (misalnya koreksi atau pengembalian dana) sebelum dinilai sebagai kesalahan data.

## 8.2 Soal 31 — Memeriksa tanggal pembayaran yang kosong

**Tujuan pemeriksaan**  
Menghitung pembayaran dengan nominal positif tetapi `tanggal_bayar_raw` kosong, `NULL`, atau hanya berisi spasi.

**Query SQL**

```sql
-- Soal 31 – Tanggal Pembayaran Positif yang Kosong
SELECT
    COUNT(*) AS positive_payment_missing_date
FROM src.pembayaran
WHERE nominal_bayar > 0
  AND (
      tanggal_bayar_raw IS NULL
      OR TRIM(tanggal_bayar_raw) = ''
  );
```

**Hasil eksekusi**

| Positive Payment Missing Date |
|---:|
| 12 |

![Tanggal Pembayaran Positif yang Kosong](Tanggal%20Pembayaran%20Positif%20yang%20Kosong.png)

*Bukti eksekusi (file gambar): `Tanggal Pembayaran Positif yang Kosong.png`*

**Interpretasi**

Terdapat 12 transaksi pembayaran bernominal positif (sekitar 0,13% dari 9.500) yang `tanggal_bayar_raw`-nya kosong, `NULL`, atau hanya berisi spasi. Transaksi ini belum dapat dianalisis berdasarkan waktu pembayaran.

## 8.3 Soal 32 — Menganalisis distribusi status pembayaran

**Tujuan pemeriksaan**  
Menampilkan jumlah record berdasarkan setiap nilai `status_pembayaran`.

**Query SQL**

```sql
-- Soal 32 – Distribusi Status Pembayaran
SELECT
    status_pembayaran,
    COUNT(*) AS jumlah
FROM src.pembayaran
GROUP BY status_pembayaran
ORDER BY jumlah DESC, status_pembayaran;
```

**Hasil eksekusi**

| `status_pembayaran` | Jumlah |
|---|---:|
| `Lunas` | 7.962 |
| `Cicilan` | 1.077 |
| `Belum Lunas` | 461 |

![Distribusi Status Pembayaran](Distribusi%20Status%20Pembayaran.png)

*Bukti eksekusi (file gambar): `Distribusi Status Pembayaran.png`*

**Interpretasi**

Terdapat tiga status pembayaran dengan total 9.500 record. Status terbanyak adalah `Lunas` (7.962; 83,81%), diikuti `Cicilan` (1.077; 11,34%), dan paling sedikit `Belum Lunas` (461; 4,85%). Tidak terlihat variasi penulisan pada label status.

---

# 9. Profiling Tabel Kelulusan

## 9.1 Soal 33 — Memeriksa duplikasi data kelulusan

**Tujuan pemeriksaan**  
Membandingkan jumlah seluruh record kelulusan dengan jumlah NIM unik.

**Query SQL**

```sql
-- Soal 33 – Memeriksa Duplikasi Data Kelulusan
SELECT
    COUNT(*) AS total_record,
    COUNT(DISTINCT nim) AS nim_unik,
    COUNT(*) - COUNT(DISTINCT nim) AS kelebihan_record
FROM src.kelulusan;
```

**Hasil eksekusi**

| Raw Rows | Distinct Graduate NIM | Duplicate Excess |
|---:|---:|---:|
| 347 | 345 | 2 |

![Memeriksa Duplikasi Data Kelulusan](Memeriksa%20Duplikasi%20Data%20Kelulusan.png)

*Bukti eksekusi (file gambar): `Memeriksa Duplikasi Data Kelulusan.png`*

**Interpretasi**

Terdapat 347 record kelulusan dengan 345 NIM unik, sehingga ada 2 record berlebih (sekitar 0,58%). Artinya ada NIM yang memiliki lebih dari satu record kelulusan. Konteks bisnis perlu diperiksa terlebih dahulu sebelum menganggapnya sebagai duplikasi yang tidak sah.

## 9.2 Soal 34 — Menganalisis status kelulusan tepat waktu

**Tujuan pemeriksaan**  
Menampilkan jumlah record berdasarkan setiap nilai `status_tepat_waktu`.

**Query SQL**

```sql
-- Soal 34 – Distribusi Status Kelulusan Tepat Waktu
SELECT
    status_tepat_waktu,
    COUNT(*) AS jumlah
FROM src.kelulusan
GROUP BY status_tepat_waktu
ORDER BY jumlah DESC;
```

**Hasil eksekusi**

| `status_tepat_waktu` | Jumlah |
|---|---:|
| `Ya` | 347 |

![Distribusi Status Kelulusan Tepat Waktu](Distribusi%20Status%20Kelulusan%20Tepat%20Waktu.png)

*Bukti eksekusi (file gambar): `Distribusi Status Kelulusan Tepat Waktu.png`*

**Interpretasi**

Seluruh 347 record kelulusan (100%) memiliki `status_tepat_waktu` bernilai `Ya`; tidak ada kategori lain pada hasil ini. Jika persentase dihitung, pembaginya adalah 347 record kelulusan. Tidak adanya variasi status perlu dikonfirmasi, apakah memang seluruh lulusan tepat waktu atau kategori lain tidak tercatat pada data sumber.

---

# 10. Pemeriksaan Relasi Antar-Tabel

## 10.1 Soal 35 — Memeriksa aktivitas LMS dengan NIM yang tidak terdaftar

**Tujuan pemeriksaan**  
Menghitung record aktivitas LMS dengan NIM yang tidak ditemukan pada tabel mahasiswa.

**Query SQL**

```sql
-- Soal 35 – Aktivitas LMS dengan NIM Tidak Terdaftar
SELECT
    COUNT(*) AS orphan_lms_student
FROM src.aktivitas_lms a
LEFT JOIN src.mahasiswa m
    ON a.nim = m.nim
WHERE m.nim IS NULL;
```

**Hasil eksekusi**

| Orphan LMS Student |
|---:|
| 0 |

![Aktivitas LMS dengan NIM Tidak Terdaftar](Aktivitas%20LMS%20dengan%20NIM%20Tidak%20Terdaftar.png)

*Bukti eksekusi (file gambar): `Aktivitas LMS dengan NIM Tidak Terdaftar.png`*

**Interpretasi**

Hasil 0 berarti seluruh aktivitas LMS dapat dihubungkan dengan mahasiswa yang terdaftar pada tabel `mahasiswa`.

## 10.2 Soal 36 — Memeriksa aktivitas LMS dengan mata kuliah yang tidak terdaftar

**Tujuan pemeriksaan**  
Menghitung record aktivitas LMS dengan `kode_mk` yang tidak ditemukan pada tabel mata kuliah.

**Query SQL**

```sql
-- Soal 36 – Aktivitas LMS dengan Mata Kuliah Tidak Terdaftar
SELECT
    COUNT(*) AS orphan_lms_course
FROM src.aktivitas_lms a
LEFT JOIN src.mata_kuliah mk
    ON a.kode_mk = mk.kode_mk
WHERE mk.kode_mk IS NULL;
```

**Hasil eksekusi**

| Orphan LMS Course |
|---:|
| 0 |

![Aktivitas LMS dengan Mata Kuliah Tidak Terdaftar](Aktivitas%20LMS%20dengan%20Mata%20Kuliah%20Tidak%20Terdaftar.png)

*Bukti eksekusi (file gambar): `Aktivitas LMS dengan Mata Kuliah Tidak Terdaftar.png`*

**Interpretasi**

Hasil 0 berarti seluruh aktivitas LMS memiliki `kode_mk` yang ditemukan pada tabel master `mata_kuliah`.

## 10.3 Soal 37 — Memeriksa pembayaran dengan NIM yang tidak terdaftar

**Tujuan pemeriksaan**  
Menghitung record pembayaran dengan NIM yang tidak ditemukan pada tabel mahasiswa.

**Query SQL**

```sql
-- Soal 37 – Pembayaran dengan NIM Tidak Terdaftar
SELECT
    COUNT(*) AS orphan_payment_student
FROM src.pembayaran p
LEFT JOIN src.mahasiswa m
    ON p.nim = m.nim
WHERE m.nim IS NULL;
```

**Hasil eksekusi**

| Orphan Payment Student |
|---:|
| 0 |

![Pembayaran dengan NIM Tidak Terdaftar](Pembayaran%20dengan%20NIM%20Tidak%20Terdaftar.png)

*Bukti eksekusi (file gambar): `Pembayaran dengan NIM Tidak Terdaftar.png`*

**Interpretasi**

Hasil 0 berarti seluruh transaksi pembayaran terhubung dengan data mahasiswa pada tabel `mahasiswa`.

## 10.4 Soal 38 — Memeriksa data kelulusan dengan NIM yang tidak terdaftar

**Tujuan pemeriksaan**  
Menghitung record kelulusan dengan NIM yang tidak ditemukan pada tabel mahasiswa.

**Query SQL**

```sql
-- Soal 38 – Data Kelulusan dengan NIM Tidak Terdaftar
SELECT
    COUNT(*) AS orphan_graduation_student
FROM src.kelulusan k
LEFT JOIN src.mahasiswa m
    ON k.nim = m.nim
WHERE m.nim IS NULL;
```

**Hasil eksekusi**

| Orphan Graduation Student |
|---:|
| 0 |

![Data Kelulusan dengan NIM Tidak Terdaftar](Data%20Kelulusan%20dengan%20NIM%20Tidak%20Terdaftar.png)

*Bukti eksekusi (file gambar): `Data Kelulusan dengan NIM Tidak Terdaftar.png`*

**Interpretasi**

Hasil 0 berarti seluruh record kelulusan memiliki data induk pada tabel `mahasiswa`.

---

# 11. Rekapitulasi Hasil Data Profiling dan Data Quality

Isikan ringkasan hasil dari seluruh pemeriksaan. Kolom status dapat menggunakan kategori **Tidak ditemukan masalah**, **Perlu pemeriksaan**, atau **Data belum cukup**. Berikan status berdasarkan hasil dan konteks data, bukan berdasarkan dugaan.

| No. | Area Pemeriksaan | Indikator | Hasil | Status | Catatan Temuan |
|---:|---|---|---:|---|---|
| 1 | Dataset | Jumlah record setiap tabel | 326.517 record (10 tabel) | Tidak ditemukan masalah | Terbanyak `aktivitas_lms` (200.356), tersedikit `semester` (8) |
| 2 | Dataset | Jumlah kolom setiap tabel | 76 kolom (10 tabel) | Tidak ditemukan masalah | Terbanyak `mahasiswa` (11), tersedikit `program_studi` (5) |
| 3 | Mahasiswa | Kelebihan record berdasarkan NIM | 15 | Perlu pemeriksaan | 1.965 record vs 1.950 NIM unik |
| 4 | Mahasiswa | Kelompok NIM duplikat | 15 kelompok | Perlu pemeriksaan | Seluruh kelompok muncul tepat 2 kali |
| 5 | Mahasiswa | Kota asal kosong | 30 | Perlu pemeriksaan | Sekitar 1,53% dari 1.965 record |
| 6 | Mahasiswa | Variasi label program studi | 30 label | Perlu pemeriksaan | Hanya 6 prodi resmi; variasi huruf, singkatan, dan penulisan lain |
| 7 | Mahasiswa | Variasi label jenis kelamin | 6 label | Perlu pemeriksaan | `L`/`Laki-laki`/`M` dan `P`/`Perempuan`/`F` kemungkinan kategori sama |
| 8 | Mahasiswa | Program studi tidak cocok dengan referensi | 435 | Perlu pemeriksaan | 175 beda penulisan, 260 tidak dikenal; `program_studi` memuat nama ganda |
| 9 | Mahasiswa | Variasi format tanggal masuk | 3 format | Perlu pemeriksaan | `YYYY-MM-DD` 1.429, `DD/MM/YYYY` 346, `DD-Mon-YYYY` 190, `OTHER` 0 |
| 10 | KRS | Kelebihan record berdasarkan KRS ID | 25 | Perlu pemeriksaan | 57.025 record vs 57.000 `krs_id` unik |
| 11 | KRS | Duplikasi kombinasi NIM–MK–semester | 25 kombinasi (25 record berlebih) | Perlu pemeriksaan | Seluruh kombinasi muncul tepat 2 kali |
| 12 | Nilai | Nilai angka kosong | 20 | Perlu pemeriksaan | Sekitar 0,04% dari 57.000 record |
| 13 | Nilai | Nilai angka di luar rentang | 12 | Perlu pemeriksaan | Sekitar 0,02% dari 57.000 record |
| 14 | Nilai | Statistik nilai valid | 56.968 valid; min 34,8; maks 100; rata-rata 77,4 | Tidak ditemukan masalah | Informasi deskriptif |
| 15 | Nilai | Ketidaksesuaian nilai angka dan huruf | 20 | Perlu pemeriksaan | Nilai huruf tidak sesuai konversi nilai angka |
| 16 | Nilai | Ketidaksesuaian nilai dan status lulus | 0 | Tidak ditemukan masalah | Konsisten dengan aturan lulus minimal 60 |
| 17 | Nilai | Duplikasi kombinasi NIM–MK–semester | 0 | Tidak ditemukan masalah | 57.000 record, 0 kombinasi duplikat |
| 18 | Referential integrity | NIM KRS tidak terdaftar | 0 | Tidak ditemukan masalah | Seluruh NIM KRS terdaftar |
| 19 | Referential integrity | NIM nilai tidak terdaftar | 0 | Tidak ditemukan masalah | Seluruh NIM nilai terdaftar |
| 20 | Referential integrity | Kode MK nilai tidak terdaftar | 0 | Tidak ditemukan masalah | Seluruh kode MK nilai memiliki referensi |
| 21 | Referential integrity | Semester nilai tidak terdaftar | 0 | Tidak ditemukan masalah | Seluruh semester nilai memiliki referensi |
| 22 | LMS | Kelebihan record berdasarkan event ID | 30 | Perlu pemeriksaan | 200.356 record vs 200.326 event ID unik |
| 23 | LMS | Distribusi tipe aktivitas | 5 tipe | Tidak ditemukan masalah | Terbanyak `view_material` (56.040), tersedikit `forum_post` (10.000) |
| 24 | LMS | Skor kuis kosong | 0 | Tidak ditemukan masalah | Seluruh `quiz_attempt` memiliki skor |
| 25 | LMS | Skor pada aktivitas non-kuis | 0 | Tidak ditemukan masalah | Skor hanya muncul pada aktivitas kuis |
| 26 | Pembayaran | Nominal pembayaran negatif | 5 | Perlu pemeriksaan | Perlu ditelusuri sesuai konteks pencatatan keuangan |
| 27 | Pembayaran | Pembayaran positif tanpa tanggal | 12 | Perlu pemeriksaan | Sekitar 0,13% dari 9.500 record |
| 28 | Pembayaran | Distribusi status pembayaran | 3 status | Tidak ditemukan masalah | `Lunas` 7.962, `Cicilan` 1.077, `Belum Lunas` 461 |
| 29 | Kelulusan | Kelebihan record berdasarkan NIM | 2 | Perlu pemeriksaan | 347 record vs 345 NIM unik |
| 30 | Kelulusan | Distribusi status tepat waktu | 1 nilai (`Ya` = 347) | Perlu pemeriksaan | Tidak ada variasi; perlu konfirmasi sumber data |
| 31 | Relasi LMS | NIM aktivitas LMS tidak terdaftar | 0 | Tidak ditemukan masalah | Seluruh NIM aktivitas LMS terdaftar |
| 32 | Relasi LMS | Kode MK aktivitas LMS tidak terdaftar | 0 | Tidak ditemukan masalah | Seluruh kode MK aktivitas LMS terdaftar |
| 33 | Relasi pembayaran | NIM pembayaran tidak terdaftar | 0 | Tidak ditemukan masalah | Seluruh NIM pembayaran terdaftar |
| 34 | Relasi kelulusan | NIM kelulusan tidak terdaftar | 0 | Tidak ditemukan masalah | Seluruh NIM kelulusan terdaftar |

> **Catatan:** Rekap di atas merangkum indikator utama. Hasil distribusi dan statistik yang berbentuk beberapa baris tetap perlu disertakan pada bagian aktivitas masing-masing.

---

# 12. Kesimpulan Praktikum

Berdasarkan seluruh query dan hasil pemeriksaan yang telah dilakukan, tuliskan kesimpulan dengan menjawab pertanyaan berikut.

1. Bagaimana gambaran umum struktur dan ukuran dataset akademik yang diperiksa?

   Dataset terdiri atas 10 tabel dengan total 326.517 record dan 76 kolom. Ukurannya didominasi tabel transaksi: `aktivitas_lms` (200.356 record), `krs` (57.025), `nilai` (57.000), dan `pembayaran` (9.500). Tabel master jauh lebih kecil, misalnya `mahasiswa` (1.965), `kelulusan` (347), `mata_kuliah` (208), `dosen` (96), `semester` (8), dan `program_studi` (12). Tabel `mahasiswa` memiliki kolom terbanyak (11).

2. Aspek kualitas data apa saja yang menunjukkan indikasi masalah?

   - *Uniqueness*: kelebihan record pada `mahasiswa` (15 NIM), `krs` (25 `krs_id` dan 25 kombinasi NIM–MK–semester), `aktivitas_lms` (30 event ID), dan `kelulusan` (2 NIM). Tabel `nilai` tidak menunjukkan duplikasi pada kombinasi NIM–MK–semester.
   - *Completeness*: kota asal kosong (30), nilai angka kosong (20), dan pembayaran positif tanpa tanggal (12).
   - *Validity*: nilai angka di luar 0–100 (12) dan pembayaran bernominal negatif (5).
   - *Consistency*: variasi penulisan pada `prodi_raw` (30 label; 435 record tidak cocok persis dengan referensi), `jk_raw` (6 label), `status_raw`, `kode_prodi_raw` (24 nilai), format tanggal masuk (3 format), serta 20 nilai huruf yang tidak sesuai nilai angka.

3. Tabel mana yang memiliki temuan paling banyak atau paling perlu diperiksa lebih lanjut? Jelaskan berdasarkan hasil.

   Tabel `mahasiswa` memiliki jenis temuan terbanyak: NIM ganda, kota asal kosong, serta variasi penulisan pada program studi, jenis kelamin, status, kode program studi, dan format tanggal masuk. Tabel `nilai` juga perlu diperiksa karena memiliki nilai kosong, nilai di luar rentang, dan ketidaksesuaian nilai huruf. Dari sisi jumlah record berlebih, `aktivitas_lms` (30) dan `krs` (25) paling banyak, meskipun proporsinya sangat kecil terhadap ukuran tabelnya.

4. Apakah terdapat relasi antar-tabel yang tidak terpenuhi?

   Tidak. Seluruh delapan pemeriksaan referential integrity (Soal 22–25 dan 35–38) menghasilkan 0 record tanpa pasangan: NIM pada KRS, nilai, aktivitas LMS, pembayaran, dan kelulusan seluruhnya ditemukan pada `mahasiswa`; kode mata kuliah pada `nilai` dan `aktivitas_lms` ditemukan pada `mata_kuliah`; dan semester pada `nilai` ditemukan pada `semester`. Relasi `program_studi` belum diperiksa secara referensial; hanya dibandingkan berdasarkan nama pada Soal 11.

5. Pemeriksaan lanjutan apa yang diperlukan sebelum melakukan cleaning, standardisasi, atau deduplikasi?

   Perlu menelusuri atribut lain pada kelompok duplikat (NIM, KRS, event LMS, dan kelulusan) untuk membedakan duplikasi dengan data historis; menyusun tabel pemetaan nilai untuk program studi, jenis kelamin, status, kode program studi, dan format tanggal berdasarkan tabel referensi; memverifikasi label yang tampak sama tetapi terhitung terpisah (kemungkinan spasi tersembunyi); serta menelusuri nilai kosong, nilai di luar rentang, ketidaksesuaian nilai huruf, pembayaran negatif, dan pembayaran tanpa tanggal sesuai aturan bisnis. Seluruh langkah dilakukan tanpa mengubah tabel pada schema `src`.

## 12.1 Temuan Utama

Tuliskan maksimal lima temuan utama berdasarkan hasil praktikum.

1. Terdapat kelebihan record pada empat tabel: `mahasiswa` (15), `krs` (25), `aktivitas_lms` (30), dan `kelulusan` (2), sedangkan `nilai` tidak memiliki duplikasi pada kombinasi NIM–MK–semester.
2. Data mentah `mahasiswa` tidak konsisten: 30 label `prodi_raw` untuk 6 program studi (435 record tidak cocok persis), 6 label `jk_raw`, 24 nilai `kode_prodi_raw`, variasi `status_raw`, dan 3 format tanggal masuk.
3. Terdapat data yang belum lengkap: kota asal kosong (30), nilai angka kosong (20), dan pembayaran positif tanpa tanggal (12).
4. Terdapat data yang perlu divalidasi: nilai di luar rentang 0–100 (12), nilai huruf tidak sesuai nilai angka (20), dan pembayaran negatif (5).
5. Seluruh relasi antar-tabel yang diperiksa terpenuhi (0 record tanpa pasangan pada 8 pemeriksaan).

## 12.2 Rekomendasi Pemeriksaan Lanjutan

Tuliskan rekomendasi langkah pemeriksaan lanjutan. Pada tahap ini, rekomendasi tidak berarti langsung mengubah atau menghapus data pada source layer.

1. Telusuri kelompok duplikat pada `mahasiswa`, `krs`, `aktivitas_lms`, dan `kelulusan` dengan membandingkan atribut lain (misalnya nama, tanggal, status, atau timestamp) untuk membedakan duplikasi dengan data historis atau transaksi yang sah.
2. Susun tabel pemetaan (*mapping*) untuk program studi, jenis kelamin, status, kode program studi, dan format tanggal di layer berikutnya (bukan pada `src`), serta periksa penyebab nama program studi yang muncul dua kali pada `program_studi`.
3. Konfirmasi dengan pemilik data atau aturan bisnis terkait nilai kosong, nilai di luar rentang, ketidaksesuaian nilai huruf, pembayaran negatif, pembayaran tanpa tanggal, serta status kelulusan tepat waktu yang seluruhnya `Ya`.

---

# 13. Lampiran

## 13.1 Bukti Eksekusi Query

Bukti eksekusi disimpan sebagai berkas gambar terpisah pada folder yang sama dengan berkas ini. Setiap gambar sudah ditautkan pada bagian **Hasil eksekusi** masing-masing soal.

| No. | Bagian | Berkas Gambar |
|---:|---|---|
| 1 | 1.1 | [`Memeriksa versi PostgreSQL.png`](Memeriksa%20versi%20PostgreSQL.png) |
| 2 | 1.2 | [`Memeriksa database dan user aktif.png`](Memeriksa%20database%20dan%20user%20aktif.png) |
| 3 | 1.3 | [`Memastikan schema src tersedia.png`](Memastikan%20schema%20src%20tersedia.png) |
| 4 | Soal 1 | [`Menghitung jumlah record setiap tabel.png`](Menghitung%20jumlah%20record%20setiap%20tabel.png) |
| 5 | Soal 2 | [`Menghitung jumlah kolom setiap tabel.png`](Menghitung%20jumlah%20kolom%20setiap%20tabel.png) |
| 6 | Soal 3 | [`Mengukur keunikan NIM mahasiswa.png`](Mengukur%20keunikan%20NIM%20mahasiswa.png) |
| 7 | Soal 4 | [`Mengidentifikasi NIM duplikat.png`](Mengidentifikasi%20NIM%20duplikat.png) |
| 8 | Soal 5 | [`Memeriksa data kota asal yang kosong.png`](Memeriksa%20data%20kota%20asal%20yang%20kosong.png) |
| 9 | Soal 6 | [`Distribusi mahasiswa berdasarkan program studi.png`](Distribusi%20mahasiswa%20berdasarkan%20program%20studi.png) |
| 10 | Soal 7 | [`Menghitung jumlah variasi program studi.png`](Menghitung%20jumlah%20variasi%20program%20studi.png) |
| 11 | Soal 8 | [`Distribusi jenis kelamin mahasiswa.png`](Distribusi%20jenis%20kelamin%20mahasiswa.png) |
| 12 | Soal 9 | [`Distribusi status mahasiswa.png`](Distribusi%20status%20mahasiswa.png) |
| 13 | Soal 10 | [`Distribusi kode program studi.png`](Distribusi%20kode%20program%20studi.png) |
| 14 | Soal 11 | [`Record mahasiswa dengan prodi_raw tidak cocok persis dengan program_studi.png`](Record%20mahasiswa%20dengan%20prodi_raw%20tidak%20cocok%20persis%20dengan%20program_studi.png) |
| 15 | Soal 12 | [`Mengidentifikasi variasi format tanggal masuk.png`](Mengidentifikasi%20variasi%20format%20tanggal%20masuk.png) |
| 16 | Soal 13 | [`Pemeriksaan keunikan ID KRS.png`](Pemeriksaan%20keunikan%20ID%20KRS.png) |
| 17 | Soal 14 | [`Mengidentifikasi duplikasi data KRS.png`](Mengidentifikasi%20duplikasi%20data%20KRS.png) |
| 18 | Soal 15 | [`Menghitung kelebihan record pada kombinasi KRS.png`](Menghitung%20kelebihan%20record%20pada%20kombinasi%20KRS.png) |
| 19 | Soal 16 | [`Memeriksa nilai angka yang kosong.png`](Memeriksa%20nilai%20angka%20yang%20kosong.png) |
| 20 | Soal 17 | [`Memeriksa nilai angka di luar rentang 0–100.png`](Memeriksa%20nilai%20angka%20di%20luar%20rentang%200%E2%80%93100.png) |
| 21 | Soal 18 | [`Statistik nilai angka yang valid.png`](Statistik%20nilai%20angka%20yang%20valid.png) |
| 22 | Soal 19 | [`Memeriksa ketidaksesuaian nilai angka dan nilai huruf.png`](Memeriksa%20ketidaksesuaian%20nilai%20angka%20dan%20nilai%20huruf.png) |
| 23 | Soal 20 | [`Memeriksa kesesuaian status kelulusan.png`](Memeriksa%20kesesuaian%20status%20kelulusan.png) |
| 24 | Soal 21 | [`Mengidentifikasi duplikasi data nilai.png`](Mengidentifikasi%20duplikasi%20data%20nilai.png) |
| 25 | Soal 22 | [`Memeriksa NIM KRS yang tidak terdaftar sebagai mahasiswa.png`](Memeriksa%20NIM%20KRS%20yang%20tidak%20terdaftar%20sebagai%20mahasiswa.png) |
| 26 | Soal 23 | [`Memeriksa NIM pada tabel nilai yang tidak terdaftar sebagai mahasiswa.png`](Memeriksa%20NIM%20pada%20tabel%20nilai%20yang%20tidak%20terdaftar%20sebagai%20mahasiswa.png) |
| 27 | Soal 24 | [`Memeriksa kode mata kuliah yang tidak memiliki referensi.png`](Memeriksa%20kode%20mata%20kuliah%20yang%20tidak%20memiliki%20referensi.png) |
| 28 | Soal 25 | [`Memeriksa semester nilai yang tidak memiliki referensi.png`](Memeriksa%20semester%20nilai%20yang%20tidak%20memiliki%20referensi.png) |
| 29 | Soal 26 | [`Mengukur duplikasi aktivitas LMS.png`](Mengukur%20duplikasi%20aktivitas%20LMS.png) |
| 30 | Soal 27 | [`Menganalisis distribusi tipe aktivitas LMS.png`](Menganalisis%20distribusi%20tipe%20aktivitas%20LMS.png) |
| 31 | Soal 28 | [`Memeriksa nilai quiz attempt yang kosong.png`](Memeriksa%20nilai%20quiz%20attempt%20yang%20kosong.png) |
| 32 | Soal 29 | [`Aktivitas Non-Quiz yang Memiliki Skor.png`](Aktivitas%20Non-Quiz%20yang%20Memiliki%20Skor.png) |
| 33 | Soal 30 | [`Pembayaran dengan Nominal Negatif.png`](Pembayaran%20dengan%20Nominal%20Negatif.png) |
| 34 | Soal 31 | [`Tanggal Pembayaran Positif yang Kosong.png`](Tanggal%20Pembayaran%20Positif%20yang%20Kosong.png) |
| 35 | Soal 32 | [`Distribusi Status Pembayaran.png`](Distribusi%20Status%20Pembayaran.png) |
| 36 | Soal 33 | [`Memeriksa Duplikasi Data Kelulusan.png`](Memeriksa%20Duplikasi%20Data%20Kelulusan.png) |
| 37 | Soal 34 | [`Distribusi Status Kelulusan Tepat Waktu.png`](Distribusi%20Status%20Kelulusan%20Tepat%20Waktu.png) |
| 38 | Soal 35 | [`Aktivitas LMS dengan NIM Tidak Terdaftar.png`](Aktivitas%20LMS%20dengan%20NIM%20Tidak%20Terdaftar.png) |
| 39 | Soal 36 | [`Aktivitas LMS dengan Mata Kuliah Tidak Terdaftar.png`](Aktivitas%20LMS%20dengan%20Mata%20Kuliah%20Tidak%20Terdaftar.png) |
| 40 | Soal 37 | [`Pembayaran dengan NIM Tidak Terdaftar.png`](Pembayaran%20dengan%20NIM%20Tidak%20Terdaftar.png) |
| 41 | Soal 38 | [`Data Kelulusan dengan NIM Tidak Terdaftar.png`](Data%20Kelulusan%20dengan%20NIM%20Tidak%20Terdaftar.png) |

## 13.2 Catatan Kendala Praktikum

| No. | Kendala | Penyebab (jika diketahui) | Solusi yang Dilakukan |
|---:|---|---|---|
| 1 | [Isi] | [Isi] | [Isi] |
| 2 | [Isi] | [Isi] | [Isi] |
| 3 | [Isi] | [Isi] | [Isi] |

## 13.3 Referensi

- Materi praktikum Modul 1 Unit 1.1 — persiapan environment dan source layer UADW v1.0.
- Dataset UADW v1.0 yang disediakan untuk praktikum.
- Dokumentasi PostgreSQL: [Tambahkan referensi yang digunakan, jika ada].

---

**Akhir Laporan**
