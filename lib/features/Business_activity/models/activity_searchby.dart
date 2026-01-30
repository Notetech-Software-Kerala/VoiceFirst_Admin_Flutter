enum ActivitySearchBy {
  activityName,
  createdUser,
  updatedUser,
  deletedUser,
}

extension ActivitySearchByX on ActivitySearchBy {
  /// Value expected by API
  String get apiValue {
    switch (this) {
      case ActivitySearchBy.activityName:
        return 'ActivityName';
      case ActivitySearchBy.createdUser:
        return 'CreatedUser';
      case ActivitySearchBy.updatedUser:
        return 'UpdatedUser';
      case ActivitySearchBy.deletedUser:
        return 'DeletedUser';
        
    }
  }

  /// Value shown in UI
  String get label {
    switch (this) {
      case ActivitySearchBy.activityName:
        return 'Activity Name';
      case ActivitySearchBy.createdUser:
        return 'Created User';
      case ActivitySearchBy.updatedUser:
        return 'Updated User';
      case ActivitySearchBy.deletedUser:
        return 'Deleted User';
    }
  }
}
