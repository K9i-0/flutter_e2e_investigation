import 'package:flutter_riverpod/flutter_riverpod.dart';

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected category filter
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);

// Show completed todos toggle
final showCompletedProvider = StateProvider<bool>((ref) => true);
