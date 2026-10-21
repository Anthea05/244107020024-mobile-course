# Dokumentasi AI Challenge - Week 6

## 1. Prompt yang Digunakan
Sesuai dengan instruksi modul codelab, prompt yang diberikan kepada AI adalah:
> "Aplikasi Flutter Campus Notification App. Stack: firebase_messaging, flutter_local_notifications, flutter_secure_storage, go_router, Riverpod. Buatkan PushService dengan: 
> - requestPermission + getToken + onTokenRefresh (kirim ke POST) 
> - onMessage (tampilkan local notification manual) 
> - onMessageOpenedApp + getInitialMessage (navigasi ke data.route) 
> - subscribe/unsubscribe topic pengumuman-kampus 
> - background handler top-level dengan @pragma('vm:entry-point') 
> Tandai bagian yang BERBEDA untuk Android 13+ vs iOS, dan bagian yang tidak boleh mengakses BuildContext."

## 2. Output Awal AI
AI memberikan draf kode lengkap untuk file `fcm_service.dart`. Kode tersebut mencakup:
- Fungsi `_firebaseMessagingBackgroundHandler` sebagai fungsi *top-level* (di luar kelas) lengkap dengan anotasi `@pragma('vm:entry-point')`.
- Inisialisasi `flutter_local_notifications` untuk memunculkan *banner* secara manual saat aplikasi dalam kondisi *foreground*.
- Pendengar event `onTokenRefresh` yang disiapkan untuk melakukan POST request (via HTTP/Dio) ke *backend*.
- Pengaturan routing dari `FirebaseMessaging.onMessageOpenedApp` (untuk kondisi *background*) dan `getInitialMessage` (untuk kondisi *terminated*).

## 3. Perbaikan Manual
Meskipun draf awal AI sudah berjalan, ada beberapa perbaikan manual yang harus dilakukan agar sesuai dengan keseluruhan arsitektur aplikasi:
1. **Penambahan Simulasi Login:** Saat notifikasi di-klik, aplikasi awalnya gagal berpindah ke halaman pengumuman dan malah terjebak di `LoginPage`. Ini terjadi karena `go_router` melakukan *redirect* (menahan rute) akibat status *user* belum login. Solusinya adalah membuat simulasi login (menggunakan Riverpod `StateNotifierProvider` dan menyimpan mock token di `flutter_secure_storage`) agar *guard route* terbuka.
2. **Penyesuaian Payload Data dari Firebase Console:** Untuk menguji *deep link*, harus ditambahkan "Custom data" secara manual di Firebase Console dengan key `route` dan value `/pengumuman/1` agar navigasi tahu rute tujuannya.
3. **Refactoring Route Parser:** Mengekstrak pembacaan *route* menjadi fungsi murni `routeFromMessage(Map<String, dynamic> data)` agar mudah dilakukan *unit testing* tanpa memerlukan *library* Firebase sungguhan.

## 4. Alasan Teknis
Berikut adalah penjelasan dari arsitektur FCM yang diterapkan:
- **Background Handler Wajib Top-Level:** Fungsi *background* harus berjalan sebagai fungsi *top-level* (berdiri sendiri, bukan *method* dalam sebuah *class*) karena dieksekusi di dalam *isolate* memori yang terpisah dari *isolate* utama UI aplikasi.
- **Tidak Boleh Mengakses BuildContext:** Di dalam *background handler*, UI aplikasi tidak sedang di-render (atau bahkan sudah hancur/mati). Mencoba mengakses `BuildContext` atau state UI (seperti Riverpod) akan menyebabkan aplikasi *crash*.
- **Local Notification di State Foreground:** Secara *default*, sistem operasi tidak memunculkan *banner* (heads-up notification) ketika ada pesan FCM masuk dan aplikasi sedang aktif dipakai (*foreground*). Oleh karena itu, kita harus menangkap pesan tersebut via `onMessage` dan memanggil `flutter_local_notifications` untuk secara paksa menampilkan *banner* tersebut secara lokal.