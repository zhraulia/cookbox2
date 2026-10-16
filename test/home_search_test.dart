import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nama_project/providers/favorites_provider.dart';
import 'package:nama_project/screens/home_screen.dart';

void main() {
  testWidgets('search and category filters combine and can be cleared', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavoritesProvider(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'AYAM');
    await tester.pump();
    expect(find.text('Ayam Geprek Sambal Korek'), findsOneWidget);
    expect(find.text('Menu tidak ditemukan'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('category-filter')));
    await tester.pumpAndSettle();
    expect(find.text('Filter kategori'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    await tester.tap(find.text('Paket Masak').last);
    await tester.tap(find.text('Segar').last);
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Ayam Geprek Sambal Korek'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('category-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paket Masak').last);
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Menu tidak ditemukan'), findsOneWidget);
    expect(find.text('Ayam Geprek Sambal Korek'), findsNothing);

    await tester.tap(find.byTooltip('Hapus pencarian'));
    await tester.pump();
    expect(tester.widget<TextField>(searchField).controller!.text, isEmpty);
    expect(find.text('Menu tidak ditemukan'), findsNothing);
    expect(find.text('Cah Kangkung Terasi'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('category-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Cah Kangkung Terasi'), findsOneWidget);
  });
}
