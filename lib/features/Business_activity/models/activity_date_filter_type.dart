enum ActivityDateType {
  created,
  updated,
  deleted,
}

extension ActivityDateTypeX on ActivityDateType {
  String get label {
    switch (this) {
      case ActivityDateType.created:
        return 'Created Date';
      case ActivityDateType.updated:
        return 'Updated Date';
      case ActivityDateType.deleted:
        return 'Deleted Date';
    }
  }
}
