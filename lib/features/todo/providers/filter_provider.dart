import 'package:flutter_riverpod/flutter_riverpod.dart';

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected category filter
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);

// Note: completionFilterProvider is in settings_provider.dart
// and synced with persistent settings
