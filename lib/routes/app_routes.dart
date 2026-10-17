import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/order.dart';
import '../screens/cart_checkout_screen.dart';
import '../screens/detail_menu_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/order_confirmation_screen.dart';
import '../models/umkm.dart';
import '../screens/umkm_detail_screen.dart';
import '../screens/umkm_list_screen.dart';
import '../models/promo_preference.dart';
import '../models/review.dart';
import '../screens/order_status_screen.dart';
import '../screens/promo_preference_screen.dart';
import '../screens/review_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String umkmList = '/umkm-list';
  static const String umkmDetail = '/umkm-detail';
  static const String promoForm = '/promo-form';
  static const String home = '/home';
  static const String detailMenu = '/detail-menu';
  // Route baru untuk checkout dan konfirmasi pesanan.
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  // Route Modul 3: Status Pesanan dan Beri Ulasan
  static const String orders = '/orders';
  static const String review = '/review';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case detailMenu:
        final args = settings.arguments;
        if (args is Item) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailMenuScreen(item: args),
            settings: settings,
          );
        }
        return null;
      case checkout:
        return MaterialPageRoute<void>(
          builder: (_) => const CartCheckoutScreen(),
          settings: settings,
        );
      case orderConfirmation:
        final args = settings.arguments;
        if (args is Order) {
          return MaterialPageRoute<void>(
            builder: (_) => OrderConfirmationScreen(order: args),
            settings: settings,
          );
        }
        return null;
      case umkmList:
        return MaterialPageRoute<void>(
          builder: (_) => const UmkmListScreen(),
          settings: settings,
        );
      case umkmDetail:
        // Argument WAJIB berupa Umkm, cek tipenya dulu
        final args = settings.arguments;
        if (args is Umkm) {
          return MaterialPageRoute<void>(
            builder: (_) => UmkmDetailScreen(umkm: args),
            settings: settings,
          );
        }
        return null;
      case promoForm:
        final args = settings.arguments;
        if (args is Umkm) {
          // <PromoPreference> = tipe data yang DIKEMBALIKAN layar ini saat pop.
          // Harus sama dengan tipe di pushNamed<PromoPreference>.
          return MaterialPageRoute<PromoPreference>(
            builder: (_) => PromoPreferenceScreen(umkm: args),
            settings: settings,
          );
        }
        return null;
      case orders:
        return MaterialPageRoute<void>(
          builder: (_) => const OrderStatusScreen(),
          settings: settings,
        );
      case review:
        final args = settings.arguments;
        if (args is Order) {
          // Mengembalikan hasil objek Review saat Navigator.pop(context, review)
          return MaterialPageRoute<Review>(
            builder: (_) => ReviewScreen(order: args),
            settings: settings,
          );
        }
        return null;

      default:
        return null; // route tidak terdaftar -> halaman 404
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
