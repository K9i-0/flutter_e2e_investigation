import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum SortOrder {
  createdAt,
  dueDate,
  name,
}
