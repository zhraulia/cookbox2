-- =====================================================================
-- DATABASE 2: cookbox_app  (data milik pengguna, dipakai API aplikasi)
-- Disusun dari model Flutter asli: Order, CartItem, Review,
-- PromoPreference, FaqItem, DeliveryLocation + temuan inventaris.
-- Engine: MySQL 8.x
-- CATATAN: skema ini belum diuji di server MySQL sungguhan. Jalankan
-- import, dan kalau ada error sintaks, kirim pesan errornya.
--
-- Data UMKM/menu TIDAK disalin ke sini. Kolom menu_id / umkm_id di bawah
-- hanya menyimpan nomor id dari database umkm_platform (tanpa FOREIGN KEY,
-- karena beda database), ditambah snapshot nama/harga supaya riwayat
-- pesanan tidak berubah walau menu diubah.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS cookbox_app
    DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cookbox_app;

SET FOREIGN_KEY_CHECKS = 0;

-- Login di aplikasi memakai nomor HP + password (LoginProvider).
CREATE TABLE users (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    phone_number   VARCHAR(20)  NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Modul 1: FavoritesProvider (Set id menu).
-- category_id disalin saat favorit dibuat, dipakai untuk notifikasi promo
-- berdasarkan kategori favorit (FR-M1-05).
CREATE TABLE favorites (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id      BIGINT UNSIGNED NOT NULL,
    menu_id      BIGINT UNSIGNED NOT NULL,   -- umkm_platform.menus.id
    category_id  BIGINT UNSIGNED NOT NULL,   -- umkm_platform.categories.id
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_favorite (user_id, menu_id),
    CONSTRAINT fk_fav_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Modul 2 & 3: model Order.
-- Keranjang TIDAK punya tabel: CartProvider cukup di perangkat dan baru
-- dikirim saat checkout (POST /orders).
-- Nilai ENUM di bawah adalah bentuk baku. Di Flutter, string-nya masih
-- tidak seragam (lihat catatan inkonsistensi), API yang menerjemahkan.
CREATE TABLE orders (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_code          VARCHAR(20) NOT NULL UNIQUE,      -- contoh: 'CKB-89753'
    user_id             BIGINT UNSIGNED NOT NULL,
    status              ENUM('dikemas','dikirim','selesai') NOT NULL DEFAULT 'dikemas',
    delivery_method     ENUM('diantar','ambil_sendiri') NOT NULL,
    delivery_address    VARCHAR(255) NULL,                -- NULL jika ambil sendiri
    delivery_latitude   DECIMAL(10,7) NULL,
    delivery_longitude  DECIMAL(10,7) NULL,
    payment_method      ENUM('qris','transfer_va','cod') NOT NULL,
    payment_status      ENUM('unpaid','paid') NOT NULL DEFAULT 'unpaid',  -- baru, untuk FR-M2-05
    subtotal            INT UNSIGNED NOT NULL,
    delivery_fee        INT UNSIGNED NOT NULL DEFAULT 0,
    total               INT UNSIGNED NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- updated_at ikut berubah saat status naik; timer backend memakainya
    -- untuk tahu sudah berapa lama pesanan berada di status sekarang.
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_user_status (user_id, status),
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- CartItem: item + quantity. Satu pesanan boleh berisi menu dari UMKM
-- berbeda (keranjang di Flutter tidak membatasi), maka nama UMKM disimpan
-- per baris, bukan per pesanan.
CREATE TABLE order_items (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id       BIGINT UNSIGNED NOT NULL,
    menu_id        BIGINT UNSIGNED NOT NULL,   -- umkm_platform.menus.id
    menu_title     VARCHAR(150) NOT NULL,      -- snapshot
    merchant_name  VARCHAR(150) NOT NULL,      -- snapshot
    unit_price     INT UNSIGNED NOT NULL,      -- snapshot
    quantity       INT UNSIGNED NOT NULL,
    subtotal       INT UNSIGNED NOT NULL,
    CONSTRAINT fk_oi_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Model Review: id, rating, comment, createdAt. Di Flutter ulasan
-- menempel pada Order (1 pesanan = maksimal 1 ulasan), maka order_id UNIQUE.
-- Panjang komentar (10-200 karakter) divalidasi di aplikasi dan API.
CREATE TABLE reviews (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id    BIGINT UNSIGNED NOT NULL UNIQUE,
    user_id     BIGINT UNSIGNED NOT NULL,
    rating      TINYINT UNSIGNED NOT NULL,
    comment     TEXT NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_rev_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_rev_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Modul 4: Umkm.promo (PromoPreference). Baris ada = mengikuti UMKM
-- (isFollowing = promo != null). Baris dihapus = berhenti mengikuti.
-- promo_types berisi array JSON, contoh: ["Diskon","Produk Baru"].
-- min_discount (15-80) hanya terisi jika "Diskon" ada di promo_types.
CREATE TABLE follows (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT UNSIGNED NOT NULL,
    umkm_id       BIGINT UNSIGNED NOT NULL,    -- umkm_platform.umkms.id
    promo_types   JSON NOT NULL,
    min_discount  TINYINT UNSIGNED NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_follow (user_id, umkm_id),
    CONSTRAINT chk_min_discount CHECK (min_discount IS NULL OR min_discount BETWEEN 15 AND 80),
    CONSTRAINT fk_follow_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Modul 5: FaqItem. icon dan color di Flutter bertipe IconData/Color,
-- tidak bisa disimpan langsung, jadi disimpan sebagai nama ikon dan kode
-- warna, lalu aplikasi yang memetakannya. category saat ini masih memuat
-- emoji persis seperti di kode ('📦 Pesanan & Bayar').
CREATE TABLE faqs (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category    VARCHAR(80)  NOT NULL,
    question    VARCHAR(255) NOT NULL,
    answer      TEXT         NOT NULL,
    icon_name   VARCHAR(50)  NULL,             -- contoh: 'shopping_bag_outlined'
    color_hex   CHAR(7)      NULL,             -- contoh: '#FF9800'
    sort_order  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    FULLTEXT KEY ft_faq (question, answer)     -- untuk FR-M5-02 (cari FAQ)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Modul 5: laporan/pengaduan. Di Flutter masih Map<String,String>
-- (belum ada class model), id berbentuk '#LP-2041'.
-- Balasan dan perubahan status diisi timer backend (simulasi pengelola).
CREATE TABLE reports (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    report_code  VARCHAR(20) NOT NULL UNIQUE,
    user_id      BIGINT UNSIGNED NOT NULL,
    category     VARCHAR(60)  NOT NULL,        -- 'Pesanan & Pengiriman Bahan', 'Pembayaran', 'Akun', 'Lainnya'
    title        VARCHAR(150) NOT NULL,
    description  TEXT NOT NULL,
    status       ENUM('diproses','dibalas','selesai') NOT NULL DEFAULT 'diproses',
    admin_reply  TEXT NULL,
    replied_at   TIMESTAMP NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_report_user (user_id),
    CONSTRAINT fk_report_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Notifikasi untuk semua modul (belum ada di Flutter sama sekali).
--   promo           -> M1 (FR-M1-05)
--   order_confirmed, payment -> M2 (FR-M2-05)
--   order_status    -> M3 (FR-M3-02/03)
--   umkm_update     -> M4 (FR-M4-05)
--   report_reply    -> M5 (FR-M5-05)
CREATE TABLE notifications (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    type        ENUM('promo','order_confirmed','payment','order_status','umkm_update','report_reply') NOT NULL,
    title       VARCHAR(150) NOT NULL,
    body        VARCHAR(255) NOT NULL,
    related_id  BIGINT UNSIGNED NULL,          -- id pesanan / laporan / update terkait
    is_read     TINYINT(1) NOT NULL DEFAULT 0,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_notif_user_read (user_id, is_read),
    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Penanda umkm_updates mana yang sudah dijadikan notifikasi oleh timer
-- backend, supaya tidak terkirim dobel.
CREATE TABLE processed_umkm_updates (
    update_id     BIGINT UNSIGNED PRIMARY KEY,  -- umkm_platform.umkm_updates.id
    processed_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
