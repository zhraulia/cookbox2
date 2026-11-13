-- =====================================================================
-- COOKBOX SEED DATA
-- Sumber Data: lib/data/ (umkm_repository, item_repository, faq_repository, order_repository)
-- Dibuat untuk inisialisasi database MySQL: umkm_platform & cookbox_app
-- =====================================================================

-- ---------------------------------------------------------------------
-- DATABASE 1: umkm_platform
-- ---------------------------------------------------------------------
USE umkm_platform;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. umkms (Sumber: lib/data/umkm_repository.dart -> UmkmRepository._umkmList)
-- Catatan: Kategori menggunakan id dari tabel categories (1=Paket Masak, 2=Segar, 3=Lauk Instan, 4=Hemat Kos)
INSERT INTO umkms (id, name, description, category_id, rating, address, phone_number, image_url, latitude, longitude) VALUES
(1, 'Dapur Bu Tini', 'Paket masak rumahan dengan bumbu yang sudah ditakar.', 1, 4.9, 'Jl. Limau Manis No. 12, Padang', '081200000001', NULL, -0.9150, 100.4590),
(2, 'Pasar Segar Bu Sari', 'Sayur dan bahan segar dipilih setiap hari.', 2, 4.8, 'Jl. Pasar Raya No. 5, Padang', '081200000002', NULL, -0.9500, 100.3600),
(3, 'Kantin Mbak Sari', 'Lauk instan praktis untuk makan sehari-hari.', 3, 4.9, 'Jl. Kampus Unand, Padang', '081200000003', NULL, -0.9145, 100.4610),
(4, 'Dapur Hemat Kampus', 'Menu hemat untuk anak kos dengan bahan sudah ditakar.', 4, 4.7, 'Jl. Limau Manis Selatan, Padang', '081200000004', NULL, -0.9250, 100.4560),
(5, 'Dapur Barokah Kampus', 'Spesialis paket bumbu siap olah dan olahan Nusantara.', 1, 4.9, 'Jl. Dr. Hamka, Padang', '081200000005', NULL, -0.9005, 100.3490);

-- 2. menus (Sumber: lib/data/item_repository.dart -> ItemRepository._items)
-- Dihubungkan ke umkms lewat merchantName, category_id dicocokkan ke categories
INSERT INTO menus (id, umkm_id, category_id, title, subtitle, description, price, rating, image_url, cooking_duration, is_active) VALUES
(1, 1, 1, 'Ayam Geprek Sambal Korek', 'Ayam, sambal korek, nasi', 'Paket ayam geprek dengan sambal korek.', 18000, 4.9, 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=85', '25 menit', 1),
(2, 2, 2, 'Cah Kangkung Terasi', 'Kangkung segar, bumbu terasi', 'Sayur segar siap dimasak.', 8500, 4.7, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=85', '18 menit', 1),
(3, 3, 3, 'Sup Telur Bakso Gurih', 'Telur, bakso, sayuran', 'Lauk praktis untuk makan sehari-hari.', 12000, 4.8, 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=900&q=85', '30 menit', 1),
(4, 4, 4, 'Tumis Tempe Orek', 'Tempe, kecap, bumbu pilihan', 'Menu hemat dengan bahan yang sudah ditakar.', 9500, 4.6, 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=85', '20 menit', 1);

-- 3. menu_ingredients (Sumber: lib/data/item_repository.dart -> Item.ingredients)
INSERT INTO menu_ingredients (id, menu_id, name, sort_order) VALUES
(1, 1, 'Ayam', 1),
(2, 1, 'Cabai rawit', 2),
(3, 1, 'Bawang putih', 3),
(4, 1, 'Nasi', 4),
(5, 2, 'Kangkung', 1),
(6, 2, 'Bumbu terasi', 2),
(7, 2, 'Bawang merah', 3),
(8, 2, 'Cabai', 4),
(9, 3, 'Telur', 1),
(10, 3, 'Bakso sapi', 2),
(11, 3, 'Wortel', 3),
(12, 3, 'Daun bawang', 4),
(13, 4, 'Tempe', 1),
(14, 4, 'Kecap manis', 2),
(15, 4, 'Bawang merah', 3),
(16, 4, 'Cabai', 4);

-- 4. menu_recipe_steps (Sumber: lib/data/item_repository.dart -> Item.recipeSteps)
INSERT INTO menu_recipe_steps (id, menu_id, step_no, instruction) VALUES
(1, 1, 1, 'Goreng ayam hingga matang dan berwarna keemasan.'),
(2, 1, 2, 'Ulek cabai rawit dan bawang putih, lalu siram sedikit minyak panas.'),
(3, 1, 3, 'Geprek ayam di atas sambal dan sajikan bersama nasi.'),
(4, 2, 1, 'Tumis bawang merah, cabai, dan bumbu terasi hingga harum.'),
(5, 2, 2, 'Masukkan kangkung dan aduk hingga layu.'),
(6, 2, 3, 'Tambahkan sedikit air, masak hingga matang, lalu sajikan.'),
(7, 3, 1, 'Didihkan air dan masukkan wortel hingga mulai lunak.'),
(8, 3, 2, 'Tambahkan bakso dan bumbu, lalu masak hingga mendidih.'),
(9, 3, 3, 'Masukkan telur dan daun bawang, aduk perlahan hingga matang.'),
(10, 4, 1, 'Potong tempe kecil-kecil, lalu goreng hingga setengah kering.'),
(11, 4, 2, 'Tumis bawang merah dan cabai hingga harum.'),
(12, 4, 3, 'Masukkan tempe dan kecap, aduk hingga bumbu meresap.');

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- DATABASE 2: cookbox_app
-- ---------------------------------------------------------------------
USE cookbox_app;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. users (Pengguna uji awal)
INSERT INTO users (id, name, phone_number, password_hash) VALUES
(1, 'Pengguna Uji', '081200000099', 'GANTI_DENGAN_HASH');

-- 2. faqs (Sumber: lib/data/faq_repository.dart -> FaqRepository._faqs)
INSERT INTO faqs (id, category, question, answer, icon_name, color_hex, sort_order) VALUES
(1, '📦 Pesanan & Bayar', 'Bagaimana cara pesan paket bahan masak?', 'Pilih menu dari UMKM mitra favorit di katalog harian, pilih porsi, lalu tentukan jam antar instan atau jadwal pengiriman esok pagi.', 'shopping_bag_outlined', '#FF9800', 1),
(2, '📦 Pesanan & Bayar', 'Metode pembayaran apa saja yang didukung?', 'Kami menerima pembayaran melalui Transfer Bank, QRIS, E-Wallet (OVO, GoPay, Dana), dan bayar di tempat (COD).', 'payment', '#2196F3', 2),
(3, '🥬 Kualitas Bahan', 'Apakah bahan makanan dijamin segar dan higienis?', 'Ya, semua bahan disortir ketat, dicuci bersih, dan dikemas secara higienis sebelum dikirim ke lokasi Anda.', 'verified_user_outlined', '#4CAF50', 3),
(4, '🥬 Kualitas Bahan', 'Berapa lama bahan masak tahan disimpan?', 'Sebaiknya dimasak pada hari yang sama. Jika disimpan di kulkas (chiller), tahan hingga 2-3 hari untuk sayuran, dan di freezer untuk ayam/daging.', 'ac_unit', '#03A9F4', 4);

-- 3. orders (Sumber: lib/data/order_repository.dart -> OrderRepository._orders)
INSERT INTO orders (id, order_code, user_id, status, delivery_method, delivery_address, delivery_latitude, delivery_longitude, payment_method, payment_status, subtotal, delivery_fee, total, created_at) VALUES
(1, 'CKB-90214', 1, 'dikemas', 'diantar', 'Kost Bougenville No. 12, Padang', NULL, NULL, 'qris', 'paid', 18000, 0, 18000, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
(2, 'CKB-90188', 1, 'dikirim', 'diantar', 'Kost Bougenville No. 12, Padang', NULL, NULL, 'transfer_va', 'paid', 17000, 0, 17000, DATE_SUB(NOW(), INTERVAL 3 HOUR)),
(3, 'CKB-89945', 1, 'selesai', 'ambil_sendiri', NULL, NULL, NULL, 'cod', 'paid', 18000, 0, 18000, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(4, 'CKB-89753', 1, 'selesai', 'diantar', 'Kost Bougenville No. 12, Padang', NULL, NULL, 'qris', 'paid', 8500, 0, 8500, DATE_SUB(NOW(), INTERVAL 5 DAY));

-- 4. order_items (Sumber: lib/data/order_repository.dart -> Order.items)
INSERT INTO order_items (id, order_id, menu_id, menu_title, merchant_name, unit_price, quantity, subtotal) VALUES
(1, 1, 1, 'Ayam Geprek Sambal Korek', 'Dapur Bu Tini', 18000, 1, 18000),
(2, 2, 2, 'Cah Kangkung Terasi', 'Pasar Segar Bu Sari', 8500, 2, 17000),
(3, 3, 1, 'Ayam Geprek Sambal Korek', 'Dapur Bu Tini', 18000, 1, 18000),
(4, 4, 2, 'Cah Kangkung Terasi', 'Pasar Segar Bu Sari', 8500, 1, 8500);

-- 5. reviews (Sumber: lib/data/order_repository.dart -> Order.review)
INSERT INTO reviews (id, order_id, user_id, rating, comment, created_at) VALUES
(1, 4, 1, 5, 'Sayurannya masih sangat segar dan bumbunya pas banget. Cocok buat anak kos!', DATE_SUB(NOW(), INTERVAL 4 DAY));

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- CATATAN PEMETAAN DAN DATA YANG TIDAK BISA DIPETAKAN
-- =====================================================================
-- 1. umkm_platform.umkms:
--    - Kolom 'image_url', 'latitude', dan 'longitude' tidak ada di dummy
--      UmkmRepository (model Umkm belum menyediakan URL foto dan koordinat),
--      sehingga bernilai NULL.
--
-- 2. umkm_platform.menus:
--    - Kolom 'is_active' diisi 1 (aktif) karena model Item di Flutter
--      belum memiliki properti penanda keaktifan menu.
--
-- 3. cookbox_app.orders:
--    - Kolom 'payment_status' tidak ada di model Order Flutter, diisi 'paid'
--      karena pesanan dummy sudah berstatus proses/selesai.
--    - Kolom 'delivery_latitude' dan 'delivery_longitude' bernilai NULL karena
--      data dummy OrderRepository adalah pesanan riwayat yang belum memiliki
--      koordinat titik peta.
--    - Nilai deliveryAddress 'Ambil Sendiri' pada order CKB-89945 dipetakan
--      menjadi NULL sesuai konvensi skema (-- NULL jika ambil sendiri).
--    - Nilai deliveryMethod distandarkan: 'Antar ke Alamat' -> 'diantar',
--      'Ambil di UMKM' -> 'ambil_sendiri'.
--    - Nilai paymentMethod distandarkan: 'QRIS' -> 'qris',
--      'Transfer Bank' -> 'transfer_va', 'Tunai' -> 'cod'.
--
-- 4. cookbox_app.faqs:
--    - Kolom 'icon_name' dan 'color_hex' diturunkan dari properti Flutter
--      IconData (Icons.*) dan Color (Colors.*).
--    - ID FaqItem di Flutter ('faq_1' s/d 'faq_4') dipetakan ke integer 1 s/d 4.
--
-- 5. cookbox_app.reviews:
--    - ID Review di Flutter ('REV-89753') tidak disimpan ke kolom id karena
--      tabel reviews memakai BIGINT AUTO_INCREMENT (id diisi 1).
--
-- 6. Tabel yang sengaja tidak di-seed:
--    - umkm_platform.categories: Sudah di-insert 4 baris oleh 01_umkm_platform.sql.
--    - umkm_platform.umkm_updates: Tidak ada data dummy di repository Flutter.
--    - cookbox_app.favorites: Diinisialisasi kosong (belum ada data awal).
--    - cookbox_app.follows: Diinisialisasi kosong (belum ada data awal ikuti UMKM).
--    - cookbox_app.reports: Dummy pengaduan belum ada di layer repository.
--    - cookbox_app.notifications & processed_umkm_updates: Belum ada di Flutter.
