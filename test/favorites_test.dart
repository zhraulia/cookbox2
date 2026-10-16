import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nama_project/providers/favorites_provider.dart';
import 'package:nama_project/routes/app_routes.dart';
import 'package:nama_project/screens/home_screen.dart';

void main() {
  testWidgets('menu dapat disimpan dan dihapus dari daftar favorit', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavoritesProvider(),
        child: MaterialApp(
          home: const HomeScreen(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
          onUnknownRoute: AppRoutes.onUnknownRoute,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('favorite-1')));
    await tester.pump();
    expect(find.byTooltip('Hapus dari favorit'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('favorites-toggle')));
    await tester.pump();
    expect(find.text('Menu Favorit'), findsOneWidget);
    expect(find.text('Ayam Geprek Sambal Korek'), findsOneWidget);

    await tester.tap(find.text('Ayam Geprek Sambal Korek'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('detail-favorite')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('detail-back')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Belum ada menu favorit. Tekan ikon hati untuk menyimpan menu.',
      ),
      findsOneWidget,
    );
  });
}
