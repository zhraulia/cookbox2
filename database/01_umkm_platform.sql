-- =====================================================================
-- DATABASE 1: umkm_platform  (sumber data API PUBLIK, baca saja)
-- Disusun dari model Flutter asli: Item, Umkm, PromoPreference.
-- Engine: MySQL 8.x
-- CATATAN: skema ini belum diuji di server MySQL sungguhan. Jalankan
-- import, dan kalau ada error sintaks, kirim pesan errornya.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS umkm_platform
    DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE umkm_platform;

SET FOREIGN_KEY_CHECKS = 0;

-- Kategori dipakai bersama oleh menu DAN UMKM (di aplikasi keduanya
-- memakai 4 nilai yang sama: Paket Masak, Segar, Lauk Instan, Hemat Kos).
CREATE TABLE categories (
    id    BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Model Umkm: id, name, description, category, rating, address,
-- phoneNumber, imageUrl. (promo & isFollowing milik pengguna -> tabel
-- follows di database cookbox_app, bukan di sini.)
-- latitude/longitude disiapkan untuk FR-M4-04 (jarak UMKM via GPS).
CREATE TABLE umkms (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(150) NOT NULL UNIQUE,
    description   TEXT         NOT NULL,
    category_id   BIGINT UNSIGNED NOT NULL,
    rating        DECIMAL(2,1) NOT NULL DEFAULT 4.9,
    address       VARCHAR(255) NULL,
    phone_number  VARCHAR(20)  NULL,
    image_url     VARCHAR(500) NULL,
    latitude      DECIMAL(10,7) NULL,
    longitude     DECIMAL(10,7) NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_umkm_category FOREIGN KEY (category_id) REFERENCES categories(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Model Item: id, title, subtitle, description, merchantName (-> lewat
-- umkm_id, tidak lagi dicocokkan lewat nama), category, imageUrl, price,
-- rating, ingredients, cookingDuration, recipeSteps.
CREATE TABLE menus (
    id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    umkm_id           BIGINT UNSIGNED NOT NULL,
    category_id       BIGINT UNSIGNED NOT NULL,
    title             VARCHAR(150) NOT NULL,
    subtitle          VARCHAR(255) NOT NULL,
    description       TEXT         NOT NULL,
    price             INT UNSIGNED NULL,            -- Item.price bertipe int?
    rating            DECIMAL(2,1) NOT NULL DEFAULT 4.9,
    image_url         VARCHAR(500) NULL,
    cooking_duration  VARCHAR(30)  NULL,            -- contoh: '25 menit'
    is_active         TINYINT(1)   NOT NULL DEFAULT 1,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_menu_umkm FOREIGN KEY (umkm_id) REFERENCES umkms(id) ON DELETE CASCADE,
    CONSTRAINT fk_menu_category FOREIGN KEY (category_id) REFERENCES categories(id),
    INDEX idx_menu_title (title),
    INDEX idx_menu_category (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Item.ingredients di Flutter adalah List<String> (nama saja, tanpa
-- takaran), jadi tabel ini juga hanya menyimpan nama.
CREATE TABLE menu_ingredients (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    menu_id     BIGINT UNSIGNED NOT NULL,
    name        VARCHAR(100) NOT NULL,
    sort_order  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_ing_menu FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Item.recipeSteps: List<String>, urutan langkah penting.
CREATE TABLE menu_recipe_steps (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    menu_id      BIGINT UNSIGNED NOT NULL,
    step_no      SMALLINT UNSIGNED NOT NULL,
    instruction  VARCHAR(500) NOT NULL,
    UNIQUE KEY uq_menu_step (menu_id, step_no),
    CONSTRAINT fk_step_menu FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Kabar promo dari UMKM. Sumber notifikasi:
--   M4-05: dicocokkan dengan follows (promo_types & min_discount milik user)
--   M1-05: dicocokkan dengan kategori menu favorit user (category_id)
-- promo_type memakai 3 nilai yang sama dengan PromoPreference.availableTypes.
CREATE TABLE umkm_updates (
    id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    umkm_id          BIGINT UNSIGNED NOT NULL,
    promo_type       ENUM('Diskon','Produk Baru','Paket Hemat') NOT NULL,
    discount_percent TINYINT UNSIGNED NULL,         -- hanya untuk 'Diskon'
    title            VARCHAR(150) NOT NULL,
    body             VARCHAR(255) NOT NULL,
    menu_id          BIGINT UNSIGNED NULL,
    category_id      BIGINT UNSIGNED NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_upd_umkm FOREIGN KEY (umkm_id) REFERENCES umkms(id) ON DELETE CASCADE,
    CONSTRAINT fk_upd_menu FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE SET NULL,
    CONSTRAINT fk_upd_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    CONSTRAINT chk_discount CHECK (discount_percent IS NULL OR discount_percent BETWEEN 1 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- Satu-satunya data yang sudah pasti dari kode: 4 kategori.
-- Data UMKM, menu, bahan, resep, dan update dibuat dari repository
-- (lihat prompt pembuat seed), supaya isinya identik dengan data dummy.
INSERT INTO categories (name) VALUES
('Paket Masak'), ('Segar'), ('Lauk Instan'), ('Hemat Kos');
