enum ReviewType {
  all('ALL', 'All Cards', 'Review both new and due cards'),
  newOnly('NEW_ONLY', 'New Cards Only', 'Only study new cards'),
  dueOnly('DUE_ONLY', 'Due Cards Only', 'Only review due cards');

  final String value;
  final String label;
  final String description;

  const ReviewType(this.value, this.label, this.description);

  static ReviewType fromString(String value) {
    return ReviewType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ReviewType.all,
    );
  }
}
