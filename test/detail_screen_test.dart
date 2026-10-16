import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nama_project/models/item.dart';
import 'package:nama_project/providers/favorites_provider.dart';
import 'package:nama_project/routes/app_routes.dart';
import 'package:nama_project/screens/detail_menu_screen.dart';
import 'package:nama_project/screens/home_screen.dart';

void main() {
  const item = Item(
    id: 'test',
    title: 'Ayam Geprek Sambal Korek',
    subtitle: 'Ayam, sambal korek, nasi',
    description: 'Paket ayam geprek dengan sambal korek.',
    merchantName: 'Dapur Bu Tini',
    category: 'Paket Masak',
    price: 18000,
    ingredients: ['Ayam', 'Cabai rawit', 'Bawang putih', 'Nasi'],
    cookingDuration: '25 menit',
    recipeSteps: ['Goreng ayam hingga matang.', 'Sajikan bersama sambal.'],
  );

  testWidgets('detail menu menampilkan bahan, resep, dan tombol favorit', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavoritesProvider(),
        child: const MaterialApp(home: DetailMenuScreen(item: item)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Detail Menu'), findsOneWidget);
    expect(find.text(item.title), findsOneWidget);
    expect(find.text(item.merchantName), findsOneWidget);
    expect(find.text('Komposisi bahan'), findsOneWidget);
    expect(find.text('Ayam'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Resep'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Resep'), findsOneWidget);
    expect(find.text('Goreng ayam hingga matang.'), findsOneWidget);
    expect(find.text('25 menit'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('detail-favorite')));
    await tester.pump();
    expect(find.byTooltip('Hapus dari favorit'), findsOneWidget);
  });

  testWidgets('menu dari katalog membuka detail menu yang dipilih', (
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

    final selectedMenu = find.text('Ayam Geprek Sambal Korek').first;
    await tester.ensureVisible(selectedMenu);
    await tester.tap(selectedMenu);
    await tester.pumpAndSettle();

    expect(find.text('Detail Menu'), findsOneWidget);
    expect(find.text('Ayam Geprek Sambal Korek'), findsOneWidget);
    expect(find.text('Dapur Bu Tini'), findsOneWidget);
    expect(find.text('Komposisi bahan'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Resep'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Resep'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('detail-back')));
    await tester.pumpAndSettle();
    expect(find.text('Ayam Geprek Sambal Korek'), findsOneWidget);
  });
}
