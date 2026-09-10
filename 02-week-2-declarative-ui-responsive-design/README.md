## Hasil Screenshot & Tampilan Aplikasi

### 1. Layout Sederhana (Praktikum 4)
Berikut adalah hasil tampilan implementasi kode pada Praktikum 4:

<p align="center">
  <img src="screenshots/1.png" alt="Layout Sederhana" width="400" />
</p>

---

### 2. Dashboard Responsif (Praktikum 5)
Berikut adalah hasil tampilan implementasi layout dashboard responsif:

| Tampilan Desktop / Luas | Tampilan Mobile / Sempit |
| :---: | :---: |
| ![Dashboard Desktop](screenshots/2.png) | ![Dashboard Mobile](screenshots/3.png) |

---

### 3. Tugas Utama (Praktikum 5)
Berikut adalah hasil pengujian dan tampilan dari tugas utama:

| Preview 1 | Preview 2 | Preview 3 |
| :---: | :---: | :---: |
| ![Tugas 1](screenshots/4.png) | ![Tugas 2](screenshots/5.png) | ![Tugas 3](screenshots/6.png) |


#  AI Prompt Challenge AI

### 1.  Prompt Desain: GridView vs LayoutBuilder + Column
* **Perbandingan Pendekatan:**
  * **GridView:** Lebih sederhana dan otomatis mengatur item ke baris berikutnya berdasarkan `crossAxisCount`. Sangat cocok untuk dashboard dengan banyak card seragam. *Catatan:* Perlu memperhatikan `childAspectRatio` agar card tidak terpotong.
  * **LayoutBuilder + Row/Column:** Memberikan kontrol ukuran yang lebih fleksibel secara eksplisit, meski membutuhkan baris kode yang sedikit lebih panjang.
* **Aspek Lainnya:**
  * **Aksesibilitas:** Kedua pendekatan tidak otomatis unggul; aksesibilitas bergantung pada implementasi widget di dalamnya (seperti penggunaan `Semantics`).
  * **Pemeliharaan Kode:** `GridView` lebih praktis untuk menjaga keseragaman struktur kode.
* **Rekomendasi:** Penggunaan disesuaikan dengan kebutuhan kompleksitas tampilan dan konsistensi card data.

---

### 2.  Prompt Penguatan Konsep: Expanded & Flexible
* **Kondisi Error pada `Expanded`:**
  `Expanded` membutuhkan parent dengan ukuran yang jelas (*bounded*). Jika dimasukkan ke dalam `Row` yang berada di dalam `SingleChildScrollView` horizontal (yang lebarnya *unbounded*), Flutter akan mengalami error/crash karena tidak dapat menentukan sisa ruang secara pasti.
  
  * **Contoh Kode yang Salah:**
    ```dart
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Expanded(child: Container(color: Colors.red, height: 50)), // ❌ ERROR
          Container(width: 100, color: Colors.blue),
        ],
      ),
    )
    ```
  * **Solusi Perbaikan:**
    Gunakan lebar tetap (`width`) alih-alih `Expanded` pada *infinite scroll container*:
    ```dart
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(width: 200, color: Colors.red, height: 50), 
          Container(width: 100, color: Colors.blue),
        ],
      ),
    )
    ```
* **Perbedaan `Expanded` vs `Flexible`:**
  * `Expanded`: Memaksa *child* untuk mengisi seluruh ruang sisa yang tersedia.
  * `Flexible`: Hanya memberi batas maksimal (*loose*), sehingga *child* tetap bisa berukuran lebih kecil dari sisa ruang yang ada.

---

### 3.  Verification Prompt:
* **Pengujian Layar < 600px:** 
   Layout kartu tugas menggunakan breakpoint (`kWideBreakpoint = 700`), sehingga pada layar di bawah 600px akan otomatis menyesuaikan ke jalur 1-kolom.
* **Pencegahan Overflow:**
  * `Container` card menggunakan `height: 100` berisi `Row` dengan kombinasi satu `Expanded(Text)` dan satu `Text` angka untuk mencegah teks terpotong.
* **Kompatibilitas Flutter Stable:**
  Seluruh widget dan properti yang digunakan dipastikan tersedia pada versi stable, meliputi: `LayoutBuilder`, `Row`, `Column`, `Expanded`, `Container`, `CupertinoSwitch`, dan `Semantics`.

---
## Catatan Refleksi & Pengalaman Praktikum

### 1. Perbedaan Imperative vs Declarative UI
* **Pengalaman Belajar:** 
  Pendekatan *Imperative* menuntut kita memberikan instruksi *step-by-step* untuk mengubah elemen UI secara manual (mirip Android View lama). Sebaliknya, *Declarative* di Flutter membuat kita cukup mendeskripsikan tampilan akhir berdasarkan *state* saat ini.
* **Contoh Riil di Tugas:** 
  Saat membuat tombol *toggle dark mode*, saya tidak perlu menulis kode perintah eksplisit seperti *"ubah warna card jadi gelap"*. Cukup memanggil `theme.colorScheme.surfaceContainerHighest` dan mentrigger `setState(() => isDark = value)`, lalu biarkan Flutter sendiri yang me-*rebuild* metode `build()` dan menyesuaikan perubahannya di layar.

### 2. Kapan `Expanded` Membantu vs Kapan Bikin Error
* **Kapan Membantu:** 
  Sangat berguna di dalam `Row` atau `Column` dengan ukuran yang pasti (*bounded*), seperti pada komponen `_InfoCardGrid` kita di mana beberapa kartu perlu membagi sisa ruang horizontal secara proporsional dan otomatis menyesuaikan ukuran layar perangkat.
* **Kapan Menyebabkan Error:** 
  Terjadi jika `Expanded` dipasang di dalam parent yang *unbounded* (ukurannya tidak terbatas), contoh klasiknya adalah `Row` di dalam `SingleChildScrollView` dengan arah horizontal. Scroll butuh tahu total lebar konten secara keseluruhan, sementara `Expanded` justru menuntut batasan ukuran dulu untuk menghitung sisa ruang—dua hal yang saling bertentangan dan memunculkan error *RenderFlex children have non-zero flex...*.

### 3. Pengaruh Breakpoint & Theme Terhadap Pengalaman Pengguna (UX)
* **Breakpoint:** 
  Memastikan tingkat kepadatan informasi pas di setiap layar. Di layar HP yang sempit, struktur 1 kolom mencegah kartu atau teks menjadi terlalu padat dan sulit dibaca. Sementara di layar tablet/desktop, 2 kolom dimanfaatkan agar pengguna tidak perlu *scroll* berlebihan.
* **Theme (Light/Dark Mode):** 
  Penggunaan sistem *color scheme* (`theme.colorScheme.*`) alih-alih warna *hardcode* membuat kontras teks dan background otomatis terjaga dengan baik oleh Material 3 di kedua mode, sehingga aspek aksesibilitas dan kenyamanan visual langsung terpenuhi tanpa konfigurasi manual yang rumit.

### 4. Verifikasi Rekomendasi AI pada Tugas Inti
Setelah mendapatkan saran dari AI, beberapa hal krusial yang saya cek dan verifikasi langsung meliputi:
1. **Responsivitas Layar (< 600px):** Memastikan bahwa breakpoint (`kWideBreakpoint = 700`) benar-benar turun ke jalur 1-kolom, bukan sekadar asumsi teks belaka.
2. **Potensi Overflow:** Memastikan penggunaan `Expanded` pada kartu berada di dalam *parent* `Row` yang aman (bukan di dalam scroll horizontal).
3. **Stabilitas Widget Flutter:** Memastikan seluruh widget seperti `LayoutBuilder`, `Card`, `CupertinoSwitch`, dan `Semantics` merupakan komponen stabil di versi Flutter saat ini, bukan API eksperimental yang rawan *deprecated*.
* **Kesimpulan:** Verifikasi lewat `flutter analyze` dan pengujian langsung sangat penting karena AI terkadang memberikan solusi yang hanya berjalan mulus pada skenario tertentu saja.

---

##  Cara Menjalankan

```bash
# 1. Masuk ke folder project
cd nama-folder-project

# 2. Install dependencies
flutter pub get

# 3. Jalankan aplikasi
flutter run lib/main.dart
