import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import 'app.dart';
import 'core/dev_tools/talker.dart';

void main() {
  runApp(
    ProviderScope(
      observers: [
        if (kDebugMode) TalkerRiverpodObserver(talker: talker),
      ],
      child: const TodoApp(),
    ),
  );
}
