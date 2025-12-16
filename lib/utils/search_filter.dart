List<T> filterByQuery<T>(
  Iterable<T> items,
  String Function(T item) nameOf,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return List<T>.of(items);
  }

  return items
      .where((item) => nameOf(item).toLowerCase().contains(normalizedQuery))
      .toList(growable: false);
}
