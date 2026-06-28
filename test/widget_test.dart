import 'package:discipline/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Discipline app builds MaterialApp shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DisciplineApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
