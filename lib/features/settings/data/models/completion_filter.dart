import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum CompletionFilter {
  all,
  completed,
  incomplete,
}
