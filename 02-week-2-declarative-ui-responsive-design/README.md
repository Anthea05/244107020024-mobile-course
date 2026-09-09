AI Prompt Challenge

1. Prompt desain = Saya sedang membuat dashboard akademik menggunakan Flutter. Bandingkan dua pendekatan layout, yaitu GridView dan LayoutBuilder + Column. Jelaskan kelebihan dan kekurangan masing-masing dari sisi responsivitas, fleksibilitas terhadap ukuran layar, aksesibilitas, keterbacaan, dan kemudahan pemeliharaan kode.  Berikan rekomendasi layout yang paling sesuai beserta alasan teknisnya.  
- GridView dan LayoutBuilder + Row/Column, keduanya bisa digunakan untuk membuat dashboard responsif dengan pendekatan yang berbeda.
- GridView lebih sederhana karena dapat mengatur item secara otomatis ke baris berikutnya berdasarkan crossAxisCount. Pendekatan ini cocok untuk dashboard yang punya banyak card dengan struktur seragam. yang perlu diperhatikan adalah penggunaan childAspectRatio karena bisa menyebabkan card terlihat seperti terpotong.
- LayoutBuilder yang dikombinasikan dengan Row dan Column punya control yang lebih besar pada perubahan layout. biasanya membutuhkan kode yang lebih panjang karena layout ditentukan secara eksplisit namun masih mudah dikontrol.
- Dari sisi aksesibilitas, kedua pendekatan sebenarnya tidak otomatis lebih unggul. Aksesibilitas tetap bergantung pada bagaimana widget di dalam layout dibuat, seperti penggunaan Semantics
- apabila ingin pemeliharaan kode yang praktis, gridview membuat struktur menjadi lebih seragam.

2. Prompt Penguatan Konsep = Jelaskan kondisi ketika penggunaan Expanded justru dapat menyebabkan overflow atau layout error di dalam Row pada Flutter. Tunjukkan contoh kode yang salah, jelaskan penyebabnya, kemudian berikan perbaikannya. Bandingkan juga penggunaan Expanded dan Flexible dalam kondisi tersebut. 
- Expanded butuh parent yang punya ukuran jelas. Kalau row dengan Expanded ada di tempat yang lebarnya unbounded, misalnya SingleChildScrollView horizontal, Flutter jadi bingung menentukan ukuran Expanded dan akhirnya bisa error/crash.
contoh kode yang salah:

SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      Expanded(child: Container(color: Colors.red, height: 50)), // ERROR
      Container(width: 100, color: Colors.blue),
    ],
  ),
)
error disini terjadi karena scroll horizontalnya belum tau total lebar kontennya, sedangkan sebenarnya ini sangat dibutuhkan untuk membagi ruang.

kode yang benar:
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      Container(width: 200, color: Colors.red, height: 50), // pakai lebar fix
      Container(width: 100, color: Colors.blue),
    ],
  ),
)
Expanded memaksa child untuk mengisi ruang yang tersedia, sedangkan Flexible hanya memberi batas maksimal sehingga ukurannya bisa lebih kecil.

3. Verification Prompt = Periksa kembali rekomendasi layout yang telah diberikan. Pastikan solusi tersebut tetap responsif pada ukuran layar di bawah 600px dan tidak menimbulkan overflow. Periksa juga apakah widget dan properti yang digunakan tersedia pada Flutter stable saat ini. Jika terdapat kekeliruan, jelaskan dan berikan alternatif perbaikannya.
- Di bawah 600px: layout kartu tugas memakai breakpoint kWideBreakpoint = 700, jadi di bawah 600px otomatis kena jalur 1-kolom
- Overflow check:Container card pakai height: 100 isinya Row dengan satu Expanded(Text) + satu Text angka
- Ketersediaan widget di Flutter stable: LayoutBuilder, Row, Column, Expanded, Container, CupertinoSwitch, Semantics