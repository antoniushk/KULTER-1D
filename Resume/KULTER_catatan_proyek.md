# KULTER: catatan proyek (untuk Project Knowledge)

Terakhir diperbarui: Sabtu, 24 Oktober 2026

## 1. Tugas
- Mengolah data magnetotellurik (MT) 1D dengan coding (tanpa software jadi). Hasil kodingan sendiri adalah pembeda kelompok.
- Deadline: Minggu 25 Okt 2026 pukul 23.59. Target selesai pukul 18.00.
- Laporan ditunda. Sekarang fokus pengolahan. Temuan selama pengolahan dicatat di file ini.
- Pengolahan utama angkatan memakai PyGMI (Occam1D). Tiap kelompok disarankan membuat pengolahan yang berbeda. Kata dosen penanggung jawab, pengolahan yang beda sendiri nilainya lebih tinggi.
- Asumsi: kelompok ikut menjalankan PyGMI sendiri. Belum dipastikan apakah cukup memakai hasil ketua pengolahan.

## 2. Profil dan aturan kerja
- Mahasiswa Teknik Geofisika ITS angkatan 2023, semester 6. Belum menguasai dasar teori MT. Mengerjakan dengan bantuan AI dan literatur.
- Target: nilai A, argumentasi kuat, berbasis masalah nyata (tidak terlalu generik, tidak terlalu sempit).
- Bahasa: Indonesia mahasiswa yang mudah dimengerti. Hindari tanda pisah panjang dan titik koma.
- Sitasi gaya APA (Nama, Tahun). Sumber valid dan bisa dilacak. Dorongan 5 tahun terakhir dan Scopus Q1-Q2. Paper klasik boleh sebagai fondasi. Jangan mengarang sitasi. Jangan plagiat.
- Jelaskan tiap langkah dengan bahasa sederhana supaya user bisa membela hasilnya.
- Status Q1/Q2 dicek user sendiri (Scimago).

## 3. Data
- File data.zip: 10 stasiun (MT1 sampai MT10), dekat Ponorogo, proyek KULTER2026, akuisisi 20 Agu 2026, alat Phoenix MTU-5C, diproses EMpower v2.48.0.3. Koordinat contoh MT1: -7.782639, 111.610583, elevasi 609 m. Elevasi stasiun 609 sampai 845 m.
- Format EDI berisi SPEKTRA mentah, bukan impedansi. Matriks cross-spectra 7x7 per frekuensi, kanal urut: HX, HY, HZ, EX, EY, RX, RY. 96 frekuensi (MT9: 92), dari 10 kHz sampai sekitar 0,0007 Hz.
- Tata letak matriks: diagonal real, segitiga bawah = bagian real, segitiga atas = bagian imajiner. Rumus yang terbukti benar: S_ij = M_ij + i*M_ji untuk i>j, S_ji = konjugat. Z = S_EH * inv(S_HH). Satuan Z: mV/km/nT. Rho = 0,2 * T * |Z|^2.
- Kanal referensi (RX, RY) sama dengan kanal magnetik lokal, jadi single-station, bukan remote reference. Header MT1: fine robust NONE, sekitar 60% crosspower ditolak, comb filter 50 Hz.
- Setiap stasiun punya 1 sampai 8 blok frekuensi bernilai nol di frekuensi terendah. Harus dibuang saat QC.
- File trial_datashifa.zip (dari teman, ketua pengolahan 1D) adalah dataset yang SAMA. Z hasil hitung sendiri cocok persis dengan EDI temannya (contoh MT1 10 kHz, Zxy = 502,61 + 1699,68i). Datanya sudah dikonversi lewat MTpy dan dipotong ke 54 frekuensi (>= 1 Hz).

## 4. Pipeline teman (hanya referensi)
- Zxy dan Zyx diganti Zssq (invarian sum of squares). Zssq = akar dari (Zxx^2 + Zxy^2 + Zyx^2 + Zyy^2)/2. Ini BUKAN koreksi static shift.
- Potong frekuensi > 1 Hz (AMT), hitung kedalaman penetrasi.
- Inversi lewat PyGMI Occam1D (mode "TE", maks 20 iterasi, target misfit 1, 51 parameter). Notebook hanya membaca logfile, memilih iterasi "elbow" dengan jarak ke titik asal (heuristik, bukan kurvatur L-curve), lalu plot.
- RMS iterasi terpilih: MT1 2,47. MT2 2,45. MT3 1,37. MT4 1,92. MT5 1,59. MT6 0,92. MT7 1,23. MT8 2,20. MT9 3,61. MT10 2,18.
- Resistivitas model sampai 1e5 sampai 6,9e5 Ohm.m di beberapa stasiun (MT4, MT6, dan lainnya). Mencurigakan, kemungkinan artefak.

## 5. Temuan analisis data (band dan dimensi)
Band (median semua stasiun):
- 100 Hz sampai 10 kHz: koherensi Ex/Ey 0,95/0,97. Stacking 456. 32% titik ellipticity phase tensor < 0,15.
- 1 sampai 100 Hz: koherensi 0,83/0,83. Stacking 225. 3% titik ellipticity < 0,15.
- 0,01 sampai 1 Hz: koherensi 0,63/0,69. Stacking 22. 4%.
- Di bawah 0,01 Hz: stacking sekitar 2. Koherensi 0,98 tidak dipercaya (bias karena stacking kecil).
- Kesimpulan: band utama 1 Hz sampai 10 kHz (54 frekuensi).

Seberapa 1D (band >= 1 Hz). Rasio (|Zxx|+|Zyy|)/(|Zxy|+|Zyx|), makin kecil makin 1D:
- MT1 0,19. MT2 0,61. MT3 0,20. MT4 0,17. MT5 0,28. MT6 0,23. MT7 0,24. MT8 0,43. MT9 0,50. MT10 0,48.
- Rho XY vs YX median (Ohm.m): MT1 100/149. MT2 928/2589. MT3 570/200. MT4 201/189. MT5 42/14. MT6 372/686. MT7 110/107. MT8 99/85. MT9 12/325. MT10 80/188.
- MT9 paling tidak 1D (beda XY/YX sekitar 1,45 dekade, rasio DET/XY sekitar 6). MT1, MT6, MT7 paling baik. Data secara umum tidak benar-benar 1D, jadi 1D adalah pendekatan. Ini bahan argumen "masalah nyata".
- Ellipticity dihitung dari nilai singular phase tensor (Phi = inv(Re Z) * Im Z). Ambang 0,15 adalah patokan kasar buatan sendiri, bukan angka baku.

## 6. Keputusan yang sudah di-ACC user
1. Empat mode dijalankan terpisah: XY, YX, DET, Zssq. DET: rho = 0,2*T*|det Z|, fase = sudut(det Z)/2.
2. Band utama 1 Hz sampai 10 kHz dengan saklar untuk mengganti.
3. PyGMI = pengolahan utama angkatan. Kode sendiri = pembeda kelompok. Hasil teman hanya referensi.
4. Pembeda "indie": (1) mulai dari spektra mentah, (2) Occam ditulis sendiri, (3) empat mode terpisah, (4) bobot data berdasarkan phase tensor. Poin 5 (ketidakpastian lewat MCMC) hanya jika waktu cukup. Opsi tambahan: invarian TE/TM tanpa strike (Gomez-Trevino dkk., 2018).
5. Keluaran: kode Python, tabel hasil, gambar (kurva rho-fase, model 1D, L-curve). Laporan nanti.

## 7. Rencana kerja
1. Kode dasar: spektra ke Z, QC (buang blok nol, stacking kecil, koherensi rendah), rho dan fase.
2. Forward 1D (rekursi impedansi berlapis) dan Occam sendiri (NumPy). Validasi dulu dengan model sintetik dan data Constable 1987.
3. Jalankan 10 stasiun untuk 4 mode (tiap mode terpisah).
4. Tambahkan bobot phase tensor. MCMC jika waktu cukup.
5. Siapkan file input PyGMI/Occam1D (format sama dengan teman). User yang menjalankan di laptop.

## 8. Referensi yang sudah ditemukan (cek akses dan kuartil sendiri)
Inversi 1D:
- Constable, S. C., Parker, R. L., & Constable, C. G. (1987). Occam's inversion. Geophysics, 52(3), 289-300. PDF: mtnet.info/papers/ClassicPapers/Constable_etal_1987_Geophysics.pdf
- Key, K. (2009). 1D inversion of multicomponent, multifrequency marine CSEM data. Geophysics, 74, F9-F20. Kode: marineemlab.ucsd.edu/Projects/Occam/1DCSEM/
- Tutorial SEG Wiki: wiki.seg.org/wiki/Exploring_nonlinear_inversions:_A_1D_magnetotelluric_example
- Repo Occam 1D MT (Matlab): github.com/dong-hao/occam1dmt

Pengolahan Z dan QC:
- Ajithabh, K. S., & Patro, P. K. (2023). SigMT. Computers & Geosciences, 171, 105270. doi:10.1016/j.cageo.2022.105270
- Kappler, K., et al. (2024). Aurora. Journal of Open Source Software, 9. doi:10.21105/joss.06832
- Chen, H., Zhang, L., Ren, Z., Cao, H., & Wang, G. (2023). Frontiers in Earth Science, 11. doi:10.3389/feart.2023.1230071
- Zhan, Q., Liu, C., Liu, Y., & Zhao, P. (2023). Frontiers in Earth Science, 11. doi:10.3389/feart.2023.1183188

Dimensi dan mode:
- Caldwell, T. G., Bibby, H. M., & Brown, C. (2004). The magnetotelluric phase tensor. GJI, 158(2), 457-469. doi:10.1111/j.1365-246X.2004.02281.x
- Bibby, H. M., Caldwell, T. G., & Brown, C. (2005). GJI, 163(3), 915-930.
- Moorkamp, M. (2007). Comment on the phase tensor. GJI, 171, 565-566.
- Pedersen, L. B., & Engels, M. (2005). Routine 2D inversion of MT data using the determinant of the impedance tensor. Geophysics, 70, G33-G41.
- Gomez-Trevino, E., Muniz, Y., Cuellar, M., et al. (2018). Invariant TE and TM magnetotelluric impedances. Earth, Planets and Space, 70, 133. doi:10.1186/s40623-018-0900-y
- Weaver, J. T., Agarwal, A. K., & Lilley, F. E. M. (2000). GJI, 141, 321-336.
- Rung-Arunwan, Siripunvaraporn, & Utada: abstrak SGEPSS tentang Zssq (tahun belum diverifikasi).

Plus:
- Mandolesi, E., Ogaya, X., Campanya, J., & Piana Agostinetti, N. (2018). rjMCMC 1D MT. Computers & Geosciences. doi:10.1016/j.cageo.2018.01.011
- Goyes-Penafiel, P., Waheed, U. bin, & Arguello, H. IEEE GRSL, art. 7503005 (arXiv:2410.15274).
- Remote Sensing 2024, 16(1), 62 (physics-informed DL inversion, noisy MT).

## 9. Belum diputuskan atau perlu dicek
- Apakah soal tugas atau modul menyebut mode tertentu (TE, TM, DET, Zssq). Jika ada, ikuti soal.
- Apakah kelompok wajib menjalankan PyGMI sendiri atau memakai hasil ketua.
- Paper-paper di atas belum dibaca penuh. Hanya abstrak. User akan mengirim zip paper.
- Szarka & Menvielle (1997) adalah rujukan asli invarian, detail jurnal belum diverifikasi.
