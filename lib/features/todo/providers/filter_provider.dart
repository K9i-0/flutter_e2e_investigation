import 'package:flutter_riverpod/flutter_riverpod.dart';

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected category filter
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);

// Note: showCompletedProvider is now in settings_provider.dart
// and synced with persistent settings
