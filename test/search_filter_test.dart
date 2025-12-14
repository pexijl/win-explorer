import 'package:flutter_test/flutter_test.dart';
import 'package:win_explorer/core/utils/search_filter.dart';

void main() {
  test('filterByQuery: empty query returns all', () {
    final result = filterByQuery<String>(['a', 'b'], (s) => s, '');
    expect(result, ['a', 'b']);
  });

  test('filterByQuery: trims query', () {
    final result = filterByQuery<String>(
      ['hello', 'world'],
      (s) => s,
      '  wor ',
    );
    expect(result, ['world']);
  });

  test('filterByQuery: case-insensitive contains', () {
    final result = filterByQuery<String>(
      ['Readme.md', 'LICENSE', 'src'],
      (s) => s,
      'me.MD',
    );
    expect(result, ['Readme.md']);
  });
}
