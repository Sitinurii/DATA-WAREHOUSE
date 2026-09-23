-- UADW v1.0 - Modul Praktikum 01
CREATE SCHEMA IF NOT EXISTS src;
DROP TABLE IF EXISTS src.program_studi;
CREATE TABLE src.program_studi (kode_prodi TEXT,nama_prodi TEXT,fakultas TEXT,departemen TEXT,status TEXT);
DROP TABLE IF EXISTS src.semester;
CREATE TABLE src.semester (semester_id TEXT,tahun_akademik TEXT,term TEXT,urutan_tahun TEXT,tanggal_mulai TEXT,tanggal_selesai TEXT);
DROP TABLE IF EXISTS src.mahasiswa;
CREATE TABLE src.mahasiswa (nim TEXT,nama TEXT,jk_raw TEXT,tanggal_lahir_raw TEXT,kota_asal_raw TEXT,kode_prodi_raw TEXT,prodi_raw TEXT,angkatan TEXT,tanggal_masuk_raw TEXT,status_raw TEXT,email_kampus TEXT);
DROP TABLE IF EXISTS src.dosen;
CREATE TABLE src.dosen (nidn TEXT,nama_dosen TEXT,jk_raw TEXT,unit_prodi_raw TEXT,jabatan_akademik TEXT,tanggal_masuk_raw TEXT,status TEXT);
DROP TABLE IF EXISTS src.mata_kuliah;
CREATE TABLE src.mata_kuliah (kode_mk TEXT,nama_mk TEXT,kode_prodi TEXT,sks TEXT,semester_rekomendasi TEXT,kategori TEXT,aktif TEXT);



--Menjalankan excertise C - Membuat Data Invertory
SELECT 'program_studi' AS tabel, COUNT(*) AS jumlah_baris
FROM src.program_studi
UNION ALL
SELECT 'semester', COUNT(*) FROM src.semester
UNION ALL
SELECT 'mahasiswa', COUNT(*) FROM src.mahasiswa
UNION ALL
SELECT 'dosen', COUNT(*) FROM src.dosen
UNION ALL
SELECT 'mata_kuliah', COUNT(*) FROM src.mata_kuliah;



-- Guided Exercise C - Membuat Data Inventory
SELECT 'program_studi' AS tabel, COUNT(*) AS jumlah_baris,(SELECT COUNT(*)
	FROM information_schema.columns WHERE table_schema = 'src'
       AND table_name = 'program_studi') AS jumlah_kolom, 'kode_prodi' AS natural_key_candidat, 'Master/Reference Data' AS peran_bisnis
	FROM src.program_studi

UNION ALL

SELECT 'semester',COUNT(*),(SELECT COUNT(*)
	FROM information_schema.columns WHERE table_schema = 'src'
       AND table_name = 'semester'),'semester_id', 'Master/Reference Data'
	FROM src.semester

UNION ALL

SELECT 'mahasiswa', COUNT(*),(SELECT COUNT(*)
     FROM information_schema.columns WHERE table_schema = 'src' AND table_name = 'mahasiswa'),'nim','Master Data'
	FROM src.mahasiswa

UNION ALL

select 'dosen', COUNT(*), (SELECT COUNT(*)
     FROM information_schema.columns WHERE table_schema = 'src' AND table_name = 'dosen'), 'nidn', 'Master Data'
	FROM src.dosen

UNION ALL

select 'mata_kuliah', COUNT(*), (SELECT COUNT(*)
     FROM information_schema.columns WHERE table_schema = 'src' AND table_name = 'mata_kuliah'), 'kode_mk', 'Master Data'
	FROM src.mata_kuliah;



--Excercise D- Eksplorasi Awal
--Mencari jumlah mahasiswa dan duplikat
select COUNT(*) as ROW_ROWS,
COUNT(distinct nim) as distinct_nim,
COUNT(*) - COUNT (distinct nim) as selisih
from src.mahasiswa;

-- Cari Missing data kolom kota_raw
select count(*) as missing_kota
from src.mahasiswa 
where trim(coalesce(kota_asal_raw, '')) = '';

-- Variasi label prodi
select prodi_raw, count(*) as jumlah
from src.mahasiswa
group by prodi_raw 
order by prodi_raw;
 


---No 1. jumlah baris pada masing-masing dari lima tabel sumber---
--- Prodi
SELECT 'program_studi' AS tabel, COUNT(*) AS jumlah_baris
FROM src.program_studi

--- Semester
UNION ALL
SELECT 'semester', COUNT(*)
FROM src.semester

--- Mahasiswa
UNION ALL
SELECT 'mahasiswa', COUNT(*)
FROM src.mahasiswa

--- Dosen
UNION ALL
SELECT 'dosen', COUNT(*)
FROM src.dosen

--- Mata kuliah
UNION ALL
SELECT 'mata_kuliah', COUNT(*)
FROM src.mata_kuliah;




---NO 2. Jumlah NIM unik pada mahasiswa---
SELECT 
    COUNT(*) AS jumlah_baris,
    COUNT(DISTINCT nim) AS jumlah_nim_unik
FROM src.mahasiswa;


--- No 3. Jumlah baris mahasiswa yang merupakan excess duuplicate jika NIM dianggap naturally key
SELECT 
    COUNT(*) - COUNT(DISTINCT nim) AS excess_duplicate_rows
FROM src.mahasiswa;


---No 4. Rentang angkatan pada base load---
SELECT 
    MIN(angkatan::INTEGER) AS angkatan_terlama,
    MAX(angkatan::INTEGER) AS angkatan_terbaru
FROM src.mahasiswa;



---No 5. Mahasiswa yang kota_asal_raw-nya kosong---
SELECT COUNT(*) AS missing_kota
FROM src.mahasiswa
WHERE TRIM(COALESCE(kota_asal_raw, '')) = '';


--- No 6. Membandingkan jumlah label prodi_raw dengan program studi canonical
SELECT
    (SELECT COUNT(DISTINCT prodi_raw)
     FROM src.mahasiswa) AS jumlah_label_raw,
     
    (SELECT COUNT(*)
     FROM src.program_studi) AS jumlah_prodi_canonical;
    


--- No 7.Pola lain yang menunjukkan source data belum siap langsung dimasukkan ke Dimension Table---
---Variasi status mahasiswa
SELECT status_raw, COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY status_raw
ORDER BY status_raw;

---Variasi jenis kelamin
SELECT jk_raw, COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY jk_raw
ORDER BY jk_raw;

--Variasi label program studi
SELECT prodi_raw, COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY prodi_raw
ORDER BY prodi_raw;



-- No 8. Lima kelompok file yang menjadi master/reference data atau transactional data--
SELECT 'program_studi.csv' AS file,
       'Master/Reference Data' AS jenis_data,
       'Karena berisi daftar program studi yang menjadi acuan.' AS alasan
UNION ALL
SELECT 'semester.csv',
       'Master/Reference Data',
       'Karena berisi data semester dan periode akademik yang digunakan sebagai acuan.'
UNION ALL
SELECT 'mahasiswa.csv',
       'Master Data',
       'Karena berisi data utama tentang mahasiswa.'
UNION ALL
SELECT 'dosen.csv',
       'Master Data',
       'Karena berisi data utama tentang dosen.'
UNION ALL
SELECT 'mata_kuliah.csv',
       'Master Data',
       'Karena berisi daftar mata kuliah yang digunakan dalam kegiatan akademik.';



-- No 9. lima pertanyaan analitik yang belum dapat dijawab hanya dengan lima master dataset ini dan sebutkan dataset tambahan yang dibutuhkan--
SELECT 1 AS no,
       'Berapa jumlah mahasiswa yang mengambil setiap mata kuliah?' AS pertanyaan_analitik,
       'Dataset KRS' AS dataset_tambahan
UNION ALL
SELECT 2,
       'Berapa nilai yang diperoleh mahasiswa pada setiap mata kuliah?',
       'Dataset Nilai'
UNION ALL
SELECT 3,
       'Berapa jumlah mahasiswa yang lulus dan tidak lulus pada setiap mata kuliah?',
       'Dataset Nilai'
UNION ALL
SELECT 4,
       'Berapa jumlah mahasiswa yang melakukan pembayaran kuliah?',
       'Dataset Pembayaran'
UNION ALL
SELECT 5,
       'Berapa rata-rata nilai mahasiswa pada setiap program studi?',
       'Dataset Nilai'


