Checklist verifikasi
1. Anda dapat menjelaskan perbedaan hot reload dan hot restart.
Hot reload itu bisa berjalan tanpa mengulang state dari awal. Jadi kalau sedang ada data yang sedanv terisi cuma UI nya saja yang terupdate.
Hot restart itu bisa mengulang seluruh state aplikasi dari nol. misalnya perubahan di main(), bisa penambahan dan pengurangan variable baru.

Pertanyaan refleksi 
1. Kapan native lebih tepat dipilih daripada cross-platform? 
native lebih cocok dipakai apabila aplikasi butuh performa maksimal ke fitur spesifik ke OS, misalnya apk AR/VR, atau game berat yang butuh optimasi grafis langsung ke GPU
2. Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?
Di Flutter, UI bersifat deklaratif, artinya kita menulis kode yang menggambarkan bagaimana seharusnya UI terlihat berdasarkan state saat itu, bukan menulis langkah-langkah manual untuk mengubah tampilan. Ketika ada state yang berubah, misalnya lewat pemanggilan setState(), Flutter secara otomatis membangun ulang (rebuild) widget tree yang terpengaruh, membandingkannya dengan tree sebelumnya melalui proses reconciliation, lalu hanya memperbarui bagian UI yang benar-benar berubah.
3. Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portfolio?
apabila terjadi bug, maka proses debugging seperti git bisect bisa menemukan commit penyebab masalah tanpa harus membaca banyak perubahan sekaligus
