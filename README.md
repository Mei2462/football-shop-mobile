Tugas 7: Elemen Dasar Flutter

1. Jelaskan apa itu widget tree pada Flutter dan bagaimana hubungan parent-child (induk-anak) bekerja antar widget.
-> Setiap tampilan di layar sebenarnya hanyalah kumpulan widget yang terhubung dalam struktur parent-child, sehingga widget tree Flutter menunjukkan hierarki dari UI yang kita buat. Dalam hubungan antara parent-child, parent membungkus child atau berisi widget lain dan menetapkan aturan tata letak (constraint), sementara child adalah widget yang berada di dalam widget lain dan akan melaporkan ukuran terbaiknya berdasarkan constraint yang diterima. Akibatnya, perilaku dan penampilan child sering kali dipengaruhi langsung oleh parent. Misalnya, Kolom mengatur bagaimana beberapa teks dan ikon disejajarkan vertikal, dan Padding menambah ruang di sekitar child tanpa mengubah child itu sendiri.

2. Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya.
-> Berikut adalah widget yang digunakan dalam proyek ini:
- MaterialApp: root dari aplikasi berbasis Material yang memasang navigator tema global dan membangun seluruh widget di bawahnya.
- MyApp: widget stateless yang berfungsi sebagai entry point dan membungkus MaterialApp untuk konfigurasi terpusat.
- MyHomePage: widget stateless yang mewakili halaman utama dan membangun kerangka layar melalui Scaffold.
- Scaffold: menyediakan area dan body AppBar serta mengintegrasikan snackbar agar memiliki struktur yang konsisten melalui ScaffoldMessenger.
- AppBar: menampilkan judul Football Shop dengan warna yang diambil dari tema.
- Padding: pembungkus yang memberi ruang tepi agar konten dapat "bernapas" dan tampilan terasa lebih lega.
- Column: tata letak yang menumpuk secara vertical contohnya seperti grid menu.
- Row: tata letak yang menumpuk secara horizontal yang meratakan tiga InfoCard dalam satu baris.
- SizedBox: pemisah secara vertikal agar tampilan lebih nyaman dibaca.
- Center: menempatkan kolom konten berikutnya tepat di tengah layer.
- GridView.count: grid tiga kolom yang merender ItemCard secara konsisten dan responsif tanpa memerlukan adapter tambahan.
- Card: kartu material pada InfoCard sebagai wadah informasi ringkas sehingga konten lebih rapi.
- Container: wrapper serbaguna untuk padding ukuran dan dekorasi yang membantu mengatur ruang di dalam kartu dan item menu.
- Text: menampilkan tulisan seperti NPM Name Class judul aplikasi dan label menu.
- Icon: menampilkan ikon untuk setiap item menu.
- Material: memungkinkan efek tinta sesuai dengan Material Design.
- InkWell: memberi efek ripple saat card dipilih
- SnackBar: komponen feedback singkat yang muncul di bagian bawah layar ketika item menu dipilih sehingga pengguna mendapat konfirmasi dari aksi yang dilakukan.
- InfoCard: widget stateless custom yang menampilkan pasangan judul dan isi dalam kartu dengan lebar menyesuaikan ukuran layer.
- ItemCard: widget stateless custom untuk satu tile menu yang memadukan latar berwarna ikon teks dan interaksi ketuk agar navigasi terasa intuitif.
- ScaffoldMessenger: widget konteks yang diakses melalui "of" untuk menampilkan SnackBar pada Scaffold yang sedang aktif sehingga pesan tampil di tempat yang tepat.
- MediaQuery: inherited widget yang diakses melalui "of" untuk membaca ukuran layar ketika menghitung lebar InfoCard agar tata letak tetap adaptif.

3. Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini sering digunakan sebagai widget root.
-> Fungsi MaterialApp adalah untuk membangun fondasi aplikasi berbasis Material Design. Ini memungkinkan untuk mendaftarkan rute dan navigator, memasang tema global (ThemeData) yang mencakup skema warna dan tipografi, mengaktifkan lokalisasi dan pengaturan arah teks, dan menyiapkan sejumlah InheritedWidget penting yang dapat diakses di seluruh subtree (seperti Theme, Navigator, dan MediaQuery melalui WidgetsApp).  

MaterialApp biasanya dijadikan widget root karena dari MaterialApp, child yang berada di dalamnya akan menerima semua konfigurasi global, seperti navigasi, tema, lokasi, dan perilaku scroll. Jika diletakkan di root, banyak widget Material seperti Scaffold, AppBar, dan SnackBar tidak akan memiliki konteks yang diperlukan untuk bekerja dengan baik.

4. Jelaskan perbedaan antara StatelessWidget dan StatefulWidget. Kapan kamu memilih salah satunya?
-> StatelessWidget berbeda dari StatefulWidget. StatefulWidget memiliki objek State yang dapat berubah dan memicu setState() untuk build() ulang UI, sehingga cocok untuk komponen interaktif seperti form, layar yang bergantung pada data asinkron, atau tab yang mempertahankan posisi scroll. Tidak seperti StatefulWidget, StatelessWidget tidak menyimpan state yang berubah sepanjang umur widget dimana StatelessWidget merender UI murni dari parameter dan tidak menyimpan state internal. 

Ketika UI pengguna hanya bergantung pada input/user interaction (UI statis), StatelessWidget dapat digunakan. Sebaliknya, StatefulWidget digunakan ketika UI perlu update saat user berinteraksi (UI dinamis (interaktif)) misalnya tombol counter, checkbox.

5. Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di metode build?
->BuildContext memastikan posisi widget dalam widget tree sehingga memungkinkan widget "melihat ke atas" untuk mendapatkan data dari InheritedWidget. Contohnya adalah Theme.of(context).colorScheme.primary yang digunakan di build() pada AppBar mengubah warna tema global dalam tugas ini. Selain itu ada juga MediaQuery.of(context) di InfoCard untuk  menghitung lebar kartu dengan menggunakan dimensi layar, dan ScaffoldMessenger.of(context) di ItemCard menampilkan SnackBar pada Scaffold yang tepat. Pemilihan konteks yang tepat memastikan bahwa komponen menemukan dependensi yang sesuai karena BuildContext menunjukkan lokasi. Misalnya, snackbar harus muncul pada halaman yang sedang aktif, bukan di tempat lain.

6. Jelaskan konsep "hot reload" di Flutter dan bagaimana bedanya dengan "hot restart".
-> Dua metode untuk mempercepat iterasi adalah "hot reload" dan "hot restart". Hot reload menyuntikkan perubahan kode Dart ke VM yang sedang berjalan dan memanggil ulang build() sehingga perubahan UI pengguna langsung terlihat tanpa menghapus state saat ini. Contohnya pada tugas ini adalah mengubah warna tema pada ThemeData atau teks label dimana hot reload akan segera memperbarui tampilan tanpa menutup halaman. Sebaliknya, hot restart menjalankan ulang aplikasi dari main(), menghilangkan semua state di memori, dan membangun ulang widget tree dari nol. Penggunaan hot reload diperlukan untuk mengubah inisialisasi global, struktur objek yang memengaruhi state awal, atau jika state sudah tidak sinkron dan ingin mulai dengan "bersih". Singkatnya, kita dapat menggunakan hot reload untuk iterasi UI yang cepat, dan gunakan hot restart ketika perubahan memerlukan re-start aplikasi secara keseluruhan.
