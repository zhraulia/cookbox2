import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nama_project/providers/favorites_provider.dart';
import 'package:nama_project/routes/app_routes.dart';
import 'package:nama_project/screens/home_screen.dart';

void main() {
  testWidgets('navigasi Menu membuka daftar semua menu', (tester) async {
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
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Menu'), findsOneWidget);
    expect(find.text('Ayam Geprek Sambal Korek'), findsOneWidget);
    expect(find.text('Cah Kangkung Terasi'), findsOneWidget);
    expect(find.text('Sup Telur Bakso Gurih'), findsOneWidget);
    expect(find.text('Tumis Tempe Orek'), findsOneWidget);
    expect(find.text('Filter berdasarkan rating'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(4));

    await tester.tap(find.byKey(const ValueKey('rating-filter-4.8')));
    await tester.pump();
    expect(find.text('Ayam Geprek Sambal Korek'), findsOneWidget);
    expect(find.text('Sup Telur Bakso Gurih'), findsOneWidget);
    expect(find.text('Cah Kangkung Terasi'), findsNothing);
    expect(find.text('Tumis Tempe Orek'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('rating-filter-all')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('catalog-item-1')));
    await tester.pumpAndSettle();
    expect(find.text('Detail Menu'), findsOneWidget);
    expect(find.text('Ayam Geprek Sambal Korek'), findsOneWidget);
  });
}
