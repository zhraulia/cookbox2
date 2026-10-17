/// Mengubah error menjadi teks yang aman ditampilkan ke pengguna.
/// Awalan "Exception: " dibuang karena tidak berguna bagi pengguna.
String errorMessageOf(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}
