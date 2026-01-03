enum SortOrder {
  createdAt,
  dueDate,
  name;

  String toJson() => this.name;

  static SortOrder fromJson(String json) {
    return SortOrder.values.firstWhere(
      (e) => e.name == json,
      orElse: () => SortOrder.createdAt,
    );
  }
}
