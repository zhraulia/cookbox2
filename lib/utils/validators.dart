/// Kumpulan fungsi validasi yang bisa dipakai ulang (reusable).
/// Aturan validator di Flutter:
/// - return null -> input VALID
/// - return 'pesan' -> input TIDAK VALID, pesan tampil di bawah field
class Validators {
  Validators._();

  static String? requiredField(
    String? value, {
    String fieldName = 'Field ini',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'Field ini',
  }) {
    final requiredError = requiredField(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;
    if (value!.trim().length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  /// Angka bulat yang harus berada di antara [min] dan [max] (aturan "Range").
  static String? numberInRange(
    String? value,
    int min,
    int max, {
    String fieldName = 'Nilai',
  }) {
    final requiredError = requiredField(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;

    final number = int.tryParse(value!.trim());
    if (number == null) return '$fieldName harus berupa angka bulat';
    if (number < min || number > max) {
      return '$fieldName harus di antara $min sampai $max';
    }
    return null;
  }

  /// Memastikan minimal satu pilihan dipilih (aturan "Required" untuk pilihan).
  /// Memakai aturan yang sama: null = valid, teks = pesan error.
  static String? atLeastOne(
    Iterable<String> selected, {
    String message = 'Pilih minimal 1 pilihan',
  }) {
    if (selected.isEmpty) return message;
    return null;
  }

  /// Memvalidasi bahwa rating bintang sudah dipilih (nilai lebih dari 0).
  static String? rating(int? value) {
    if (value == null || value <= 0) {
      return 'Pilih rating bintang terlebih dahulu';
    }
    return null;
  }

  /// Memvalidasi panjang ulasan (minimal 10 karakter, maksimal 200 karakter).
  static String? reviewComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ulasan wajib diisi';
    }
    if (value.trim().length < 10) {
      return 'Ulasan minimal 10 karakter';
    }
    if (value.trim().length > 200) {
      return 'Ulasan maksimal 200 karakter';
    }
    return null;
  }
}
