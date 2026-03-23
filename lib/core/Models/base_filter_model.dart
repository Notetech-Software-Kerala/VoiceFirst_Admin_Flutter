class BaseFilterModel {
  final String? searchBy;
  final String? searchText;
  final String? sortBy;
  final String sortOrder;
  final bool? active;
  final bool? deleted;
  final DateTime? createdFromDate;
  final DateTime? createdToDate;
  final DateTime? updatedFromDate;
  final DateTime? updatedToDate;
  final DateTime? deletedFromDate;
  final DateTime? deletedToDate;

  const BaseFilterModel({
    this.searchBy,
    this.searchText,
    this.sortBy,
    this.sortOrder = 'Asc',
    this.active,
    this.deleted,
    this.createdFromDate,
    this.createdToDate,
    this.updatedFromDate,
    this.updatedToDate,
    this.deletedFromDate,
    this.deletedToDate,
  });

  BaseFilterModel copyWith({
    String? searchBy,
    String? searchText,
    String? sortBy,
    String? sortOrder,
    bool? active,
    bool? deleted,
    DateTime? createdFromDate,
    DateTime? createdToDate,
    DateTime? updatedFromDate,
    DateTime? updatedToDate,
    DateTime? deletedFromDate,
    DateTime? deletedToDate,
  }) {
    return BaseFilterModel(
      searchBy: searchBy ?? this.searchBy,
      searchText: searchText ?? this.searchText,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      createdFromDate: createdFromDate ?? this.createdFromDate,
      createdToDate: createdToDate ?? this.createdToDate,
      updatedFromDate: updatedFromDate ?? this.updatedFromDate,
      updatedToDate: updatedToDate ?? this.updatedToDate,
      deletedFromDate: deletedFromDate ?? this.deletedFromDate,
      deletedToDate: deletedToDate ?? this.deletedToDate,
    );
  }
}
