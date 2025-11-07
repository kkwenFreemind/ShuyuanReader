import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test assets/test/books.json can be loaded', () async {
    final jsonString = await rootBundle.loadString('assets/test/books.json');
    expect(jsonString, isNotEmpty);

    final jsonData = json.decode(jsonString);
    expect(jsonData, isA<Map<String, dynamic>>());
    expect(jsonData['version'], '1.0');
    expect(jsonData['books'], isA<List>());
    expect(jsonData['books'].length, 5);
  });

  test('Test assets/test/covers/ images can be loaded', () async {
    final coverFiles = [
      'assets/test/covers/一夢漫言.png',
      'assets/test/covers/六祖壇經講記.png',
      'assets/test/covers/壽康寶鑑.png',
      'assets/test/covers/地藏經略說.png',
      'assets/test/covers/孔子傳.png',
    ];

    for (final coverFile in coverFiles) {
      final data = await rootBundle.load(coverFile);
      expect(data.lengthInBytes, greaterThan(0));
    }
  });
}
