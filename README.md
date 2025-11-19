Tugas 9: Integrasi Layanan Web Django dengan Aplikasi Flutter

1. Jelaskan mengapa kita perlu membuat model Dart saat mengambil/mengirim data JSON? Apa konsekuensinya jika langsung memetakan Map<String, dynamic> tanpa model (terkait validasi tipe, null-safety, maintainability)?
-> Saat Flutter ngambil data dari Django, data yang dikirim adalah berbentuk JSON. Jika langsung menggunakan Map<String, dynamic>, maka kode penuh dengan string key seperti "title", "price", dll yang akan rawan typo dan sulit dilacak jika terjadi error. 

Dengan menggunakan model Dart seperti (newsEntry, productList, dsb), kita dapat memanfaatkan type-safety dan null safety Dart sebagai jaminan untuk memastikan tipe data yang jelas (misal int, String, bool, DateTime, dll). Jika terjadi penambahan atau pengubahan field logika, kita cukup update model saja tanpa perlu menyentuh semua widget karena struktur data yang terkumpul di satu tempat. 

2. Apa fungsi package http dan CookieRequest dalam tugas ini? Jelaskan perbedaan peran http vs CookieRequest.
-> Perbedaan http dan CookieRequest adalah sbb:
a. http adalah alat dasar untuk mengirim request HTTP (GET, POST, dll). Jenis http yang dapat digunakan misalnya http.get, http.post, lalu jsonDecode manual.
b. CookieRequest (dari package pbp_django_auth) adalah lapisan di atas http yang khusus dibuat untuk Django dengan method siap pakai seperti login, logout, get, postJson. CookieRequest ini akan otomatis menyimpan dan mengirim session cookie setiap ada aktivitas dari method tersebut.

Jika hanya perlu untuk "mengambil JSON biasa" tanpa login, maka kita cukup pakai http saja. Namun pada tugas PBP ini, terutama yang butuh autentikasi (login/register/logout dan endpoint yang pakai request.user), kita menggunakan CookieRequest karena dapat mengelola cookie secara otomatis agar status login ke Django tetap "nempel". 

3. Jelaskan mengapa instance CookieRequest perlu untuk dibagikan ke semua komponen di aplikasi Flutter.
-> Pada main.dart, aplikasi dibungkus dengan Provider yang memiliki satu objek CookieRequest yang dipakai di seluruh aplikasi agar saat login CookieRequest dapat menyimpan session cookie dari Django. Sehingga halaman lain seperti product list, form create product, logout, dll yang membutuhkan status login dapat terbaca oleh Django bahwa ini user yang sudah login. Jika tiap halaman membuat CookieRequest sendiri-sendiri, maka cookie-nya akan terpecah-pecah yang menyebabkan login user di halaman A tidak akan berpengaruh ke request yang dipanggil di halaman B.

4. Jelaskan konfigurasi konektivitas yang diperlukan agar Flutter dapat berkomunikasi dengan Django. Mengapa kita perlu menambahkan 10.0.2.2 pada ALLOWED_HOSTS, mengaktifkan CORS dan pengaturan SameSite/cookie, dan menambahkan izin akses internet di Android? Apa yang akan terjadi jika konfigurasi tersebut tidak dilakukan dengan benar?
-> Konfigurasi konektivitas yang diperlukan agar Flutter dapat berkomunikasi dengan Django sbb:
a. ALLOWED_HOSTS
Pada emulator Android, localhost laptop kita dianggap beda mesin. Sehingga diperlukan alamat khusus untuk mengakses host dari emulator, yaitu 10.0.2.2 dan pada saat login atau fetch data kita menggunakan URL http://10.0.2.2:8000/..... Jika 10.0.2.2 tidak dimasukkan ke ALLOWED_HOSTS, Django akan menolak request dengan error “Bad Request (400) Invalid HTTP_HOST header”. Dan pada Flutter akan terjadi request gagal atau dapat respons error, login & fetch data tidak jalan.

b. CORS
Jika aplikasi diakses lewat browser (misalnya Flutter Web), origin Flutter (http://localhost:port) akan berbeda dengan origin Django (http://localhost:8000). Konfigurasi CORS_ALLOW_ALL_ORIGINS = True dan CORS_ALLOW_CREDENTIALS = True lah yang mengizinkan browser mengakses API Django dan mengirim cookie. Jika konfigurasi ini tidak dilakukan, maka Browser (bukan Flutter Android) akan memblokir request dengan pesan “blocked by CORS policy”. Dan aplikasi Flutter Web / front-end di browser tidak bisa mengakses API Django meski server menyala.

c. cookie dan SameSite
Autentikasi Django menggunakan session + cookie, dan untuk mengenali user yang login Django menggunakan cookie sessionid. Agar cookie ini dapat dipakai dalam konteks tertentu (terutama bila melibatkan origin berbeda), perlu konfigurasi SAMESITE='None' agar cookie boleh dikirim pada request cross-site. dengan tambahan SECURE=True agar cookie hanya dikirim via HTTPS (pengaturan ideal untuk production). Dengan dikombinasikan dengan CORS_ALLOW_CREDENTIALS = True, ini mengizinkan klien seperti CookieRequest untuk menerima cookie session, dan mengirimnya lagi di request selanjutnya.

Jika konfigurasi cookie/SameSite tidak dilakukan dengan benar, cookie bisa saja tidak pernah terkirim / tidak pernah menempel, request.user di Django akan terus menjadi AnonymousUser, dan Endpoint yang bergantung pada request.user bisa tidak berperilaku seperti yang diharapkan.

d. izin internet
Android secara default melarang aplikasi mengakses jaringan kalau permission ini tidak ada. Tanpa ini semua error SocketException: Failed host lookup karena request ke Django seperti request.login, request.get, request.postJson pasti gagal.

5. Jelaskan mekanisme pengiriman data mulai dari input hingga dapat ditampilkan pada Flutter.
-> Alur form produk yang terhubung ke view create_product_flutter di Django adalah input form Flutter -> POST ke Django -> disimpan ke DB -> Flutter GET lagi -> ditampilkan di list/detail. Berikut penjelasannya:
a. User mengisi form di Flutter, sebelum submit form akan divalidasi dulu (data null, format data, dll).
b. Flutter mengirim data ke Django (POST) saat tombol “Save” ditekan.
c. Django menerima dan menyimpan ke database dengan membuat objek News(...) berdasarkan HTML dari title & content yang dibersihkan oleh strip_tags dari  JSON yang terbaca oleh json.loads(request.body). 
d. Django mengirim respons balik ke Flutter berupa JSON, dan Flutter akan mengecek response['status'] yang dikirimkan.
e. Jika sukses, data baru akan muncul saat Flutter fetch list produk. Dan jika user memilih card produk, maka card itu akan membuka ProductDetailPage yang menampilkan detail lengkap produk.

6. Jelaskan mekanisme autentikasi dari login, register, hingga logout. Mulai dari input data akun pada Flutter ke Django hingga selesainya proses autentikasi oleh Django dan tampilnya menu pada Flutter.
-> Di tugas ini, autentikasi menggunakan kombinasi Django auth di backend + CookieRequest di Flutter dengan detail sbb:
a. Register:
- User mengisi username & password di halaman RegisterPage.
- Flutter kirim data registrasi ke Django.
- Django akan mengecek apakah password1 dan password2 sama atau tidak, dan username sudah dipakai atau belum.
- Jika passed, Django akan membuat user baru (User.objects.create_user(...)) dan mengirim respons sukses ke Flutter.
- Di Flutter, akan tampil pesan sukses di SnackBar, dan meredirect user ke halaman LoginPage.

b. Login
- User mengisi username & password di halaman LoginPage.
- Flutter mengirimkan data login ke Django.
- Kemudian Django akan cek kredensial dengan authenticate. Jika data login valid, auth_login akan membuat session dan mengirim cookie sessionid, dan membalas JSON berisi status, message, username ke Flutter.
- CookieRequest akan menyimpan cookie dan set loggedIn = true.
- Flutter kemudian cek request.loggedIn. Jika true, user akan diarahkan ke MyHomePage() dan tampil pesan login sukses. Namun jika false, akan tampil dialog pesan login gagal.

Setelah login, semua request request.get / request.postJson akan membawa cookie ini, sehingga Django bisa tahu user mana yang mengakses (via request.user).

c. Logout
- User menekan menu “Logout”.
- Flutter mengirimkan request logout ke Django.
- Di Django, fungsi logout akan memanggil auth_logout(request) untuk menghapus session, serta mengembalikan JSON dengan status dan pesan.
- CookieRequest kemudian menghapus cookie di sisi Flutter.
- Flutter kemudian cek status JSON yang dikirimkan oleh Django. Jika logout sukses, tampil pesan pada SnackBar, dan user akan ter-redirect ke LoginPage.

7. Jelaskan bagaimana cara kamu mengimplementasikan checklist di atas secara step-by-step! (bukan hanya sekadar mengikuti tutorial)!
->
1. Membuat app baru pada proyek Django yang bernama ‘authentication’ dengan perintah ‘python manage.py startapp authentication’
2. Menambahkan 'authentication', ke INSTALLED_APPS di file settings.py proyek utama Django
3. Install library django-cors-headers, tambahkan django-cors-headers ke requirements.txt, tambahkan 'corsheaders'  ke INSTALLED_APPS dan 'corsheaders.middleware.CorsMiddleware'  ke MIDDLEWARE pada settings.py proyek utama Django
4. Tambahkan konfigurasi tambahan mengenai cors dan cookie pada settings.py proyek utama Django
5. Menambahkan 10.0.2.2 di ALLOWED_HOSTS pada settings.py proyek utama Django untuk integrasi ke Django dari emulator Android
6. Membuat sebuah method login ke views.py pada direktori authentication Django yang berfungsi untuk menangani fitur login dari flutter menggunakan HTTP request.
7. Buat file baru yang bernama urls.py pada direktori authentication yang berguna untuk url routing dalam authentication
8. Menambahkan URL routing terhadap fungsi login yang telah dibuat sebelumnya di views.py pada urls.py dalam direktori authentication
9. Menambahkan path('auth/', include('authentication.urls')) untuk menghubungkan urls pada app authentication dengan urls.py utama
10. Menambahkan method register dan logout ke views.py pada direktori authentication Django yang berfungsi untuk registrasi akun user baru dengan menyimpan username & password ke database Django dengan output Json response yang akan digunakan pada flutter pada form registernya dan logout user dari sesi output Json response yang akan digunakan pada flutter melalui request.logout()
11. Menambahkan URL routing terhadap fungsi register dan logout yang telah dibuat sebelumnya di views.py pada urls.py dalam direktori authentication
12. Kemudian buka proyek flutter dan install dependency flutter dengan perintah pada terminal shell ‘flutter pub add provider’ dan ‘flutter pub add pbp_django_auth’
13. Lakukan modifikasi pada main.dart untuk menggunakan package yang sudah diinstall di atas dan menyediakan CookieRequest yang terkait dengan login, logout, fetch data ke seluruh app flutter.
14. Membuat file login.dart dan register.dart dalam direktori screens pada direktori lib, pada file login.dart yang berfungsi untuk menampilkan halaman login pada flutter serta menghubungkan flutter dengan Django melalui pbp_django_auth dan pada file register.dart berfungsi untuk menampilkan halaman register pada flutter serta mengambil input username dan password akun baru user ke Django
15. Kemudian runserver Django dan akses endpoint JSON pada Django dengan url localhost:8000/api/products/, membuka website Quicktype
16. Mengubah name menjadi ProductEntry, source type menjadi JSON dan languange menjadi dart pada web Quicktype. Data JSON yang ada di Django salin ke textbox Quicktype dan copy code yang dihasilkan
17. Membuat sebuah direktori baru pada direktori ‘lib’ yang bernama models yang di dalamnya berisi file yang bernama ‘product_entry.dart’ dan paste code yang sudah disalin sebelumnya ke dalam file ‘product_entry.dart’
18. Menambahkan form field untuk stock pada file ‘products_form.dart’ untuk menyesuaikan dengan models yang sudah dibuat pada product_entry.dart’
19. Membuka terminal proyek flutter dan menambahkan package http dengan menjalankan perintah ‘flutter pub add http’
20. Menambahkan kode untuk izin untuk akses internet pada app flutter dalam file dengan path android/app/src/main/AndroidManifest.xml
21. Membuka kembali proyek Django dan buka views.py pada direktori main dan tambahkan method dengan nama ‘proxy_image’ dan ‘create_product_flutter’ yang berfungsi untuk menerima permintaan gambar dari url eksternal kemudian mengirimkan melalui server Django sehingga flutter tidak langsung mengakses ke luar dan menerima data product dari flutter melalui POST request JSON lalu simpan data product ke database Django
22. Menambahkan URL routing terhadap fungsi proxy_image dan create_product_flutter yang telah dibuat sebelumnya di views.py pada urls.py dalam direktori main
23. Membuka proyek flutter, buat file ‘product_entry_card.dart’ pada direktori widgets dalam direktori lib dengan fungsi untuk menampilkan UI dari card setiap product yang ada
24. buat file ‘product_entry_list.dart’ pada direktori screens dalam direktori lib dengan fungsi untuk menampilkan daftar product dari backend Django dan mengarahkan ke page detail product saat ditekan
25. Menambahkan kode dalam ‘left_drawer.dart’ untuk menampilkan left drawer yang akan membuka page ‘product_entry_list.dart’
26. Kemudian sesuaikan tombol ‘All product’ agar dapat mengarahkan halaman ke daftar produk dengan menambahkan kode pada file shop_card.dart dalam direktori widgets
27. Membuat file ‘product_detail.dart’ pada direktori screens dalam direktori lib dengan fungsi untuk menampilkan detail product yang sesuai dengan yang ada di Django
28. Melakukan modifikasi kode pada bagian onTap di file ‘product_entry_list.dart’ untuk navigasi ke halaman detail
29. Kemudian tambahkan dan modifikasi kode pada file ‘products_form.dart’ untuk menghubungkan form di flutter dengan backend Django menggunakan  CookieRequest supaya data yang diinput user dikirim secara asinkronus ke endpoint Django melalui metode postJson, dan kemudian memberikan umpan balik serta navigasi berdasarkan hasil respon dari server
30. Melakukan modifikasi kode pada file ‘main.dart’ untuk integrasi fungsi logout ke dalam flutter menggunakan CookieRequest, modifikasi dilakukan pada bagian AppBar agar tombol logout muncul di bagian kanan atas AppBar dan ketika ditekan, aplikasi akan mengirim permintaan logout ke backend Django secara asinkronus lalu mengarahkan pengguna kembali ke halaman login
31. Menambahkan parameter showOnlyMine di halaman daftar produk untuk membedakan antara halaman "All Products" dan "My Products".
32. Untuk menyimpan nilai toggle di State, saya akan membuat variabel boolean _showOnlyMine untuk menangani perubahan toggle saat runtime.
33. Melakukan inisialisasi nilai toggle dari parameter dan memastikan nilai awal _showOnlyMine mengikuti showOnlyMine dari konstruktor halaman.
34. Menambahkan switch toggle di atas daftar produk sebagai opsi kepada pengguna untuk menyaring produk milik sendiri.
35. Mengambil ID user yang sedang login menggunakan CookieRequest untuk mendapatkan userId dari session login.
36. Menambahkan kode filter data berdasarkan toggle dan userId. Jika toggle aktif, hanya tampilkan produk dengan userId yang sama dengan user login.
37. Menambahkan kode untuk mengubah tampilan AppBar atau judul sesuai konteks halaman.
38. Update navigasi di shop_card.dart untuk memastikan tombol "All Products" dan "My Products" memanggil halaman dengan nilai showOnlyMine yang sesuai.
39. Kemudian ubah tema warna yang sebelumnya belum seragam pada flutter dengan mengubah  dengan website menjadi satu tema warna yang sama
40. Melakukan add-commit-push ke GitHub setelah memastikan semuanya sudah sesuai dengan yang diharapkan