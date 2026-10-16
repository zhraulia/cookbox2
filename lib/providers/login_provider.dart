import 'package:flutter/foundation.dart';

class LoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<bool> login({required String phone, required String password}) async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _isLoading = false;
    notifyListeners();
    return phone.isNotEmpty && password.isNotEmpty;
  }
}
