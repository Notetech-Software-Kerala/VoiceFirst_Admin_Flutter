import '../../../../core/models/base_filter_model.dart';

class PostOfficeFilterModel {
  final String? searchBy;
  final String? searchText;
  final int? countryId;
  final int? divisionOneId; // State
  final int? divisionTwoId;
  final int? divisionThreeId;
  final DateTime? createdFromDate;
  final DateTime? createdToDate;
  final DateTime? updatedFromDate;
  final DateTime? updatedToDate;
  final DateTime? deletedFromDate;
  final DateTime? deletedToDate;
  final String? sortBy;
  final String sortOrder;
  final bool? active;
  final bool? deleted;
  final int pageNumber;
  final int limit;

  const PostOfficeFilterModel({
    this.searchBy,
    this.searchText,
    this.countryId,
    this.divisionOneId,
    this.divisionTwoId,
    this.divisionThreeId,
    this.createdFromDate,
    this.createdToDate,
    this.updatedFromDate,
    this.updatedToDate,
    this.deletedFromDate,
    this.deletedToDate,
    this.sortBy,
    this.sortOrder = 'Asc',
    this.active,
    this.deleted,
    this.pageNumber = 1,
    this.limit = 10,
  });

  PostOfficeFilterModel copyWith({
    String? searchBy,
    String? searchText,
    int? countryId,
    int? divisionOneId,
    int? divisionTwoId,
    int? divisionThreeId,
    DateTime? createdFromDate,
    DateTime? createdToDate,
    DateTime? updatedFromDate,
    DateTime? updatedToDate,
    DateTime? deletedFromDate,
    DateTime? deletedToDate,
    String? sortBy,
    String? sortOrder,
    bool? active,
    bool? deleted,
    int? pageNumber,
    int? limit,
  }) {
    return PostOfficeFilterModel(
      searchBy: searchBy ?? this.searchBy,
      searchText: searchText ?? this.searchText,
      countryId: countryId ?? this.countryId,
      divisionOneId: divisionOneId ?? this.divisionOneId,
      divisionTwoId: divisionTwoId ?? this.divisionTwoId,
      divisionThreeId: divisionThreeId ?? this.divisionThreeId,
      createdFromDate: createdFromDate ?? this.createdFromDate,
      createdToDate: createdToDate ?? this.createdToDate,
      updatedFromDate: updatedFromDate ?? this.updatedFromDate,
      updatedToDate: updatedToDate ?? this.updatedToDate,
      deletedFromDate: deletedFromDate ?? this.deletedFromDate,
      deletedToDate: deletedToDate ?? this.deletedToDate,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      pageNumber: pageNumber ?? this.pageNumber,
      limit: limit ?? this.limit,
    );
  }

  // Method to create from BaseFilterModel (merging with existing)
  PostOfficeFilterModel copyWithBase(BaseFilterModel base) {
    return copyWith(
      searchBy: base.searchBy,
      searchText: base.searchText,
      sortBy: base.sortBy,
      sortOrder: base.sortOrder,
      active: base.active,
      deleted: base.deleted,
      createdFromDate: base.createdFromDate,
      createdToDate: base.createdToDate,
      updatedFromDate: base.updatedFromDate,
      updatedToDate: base.updatedToDate,
      deletedFromDate: base.deletedFromDate,
      deletedToDate: base.deletedToDate,
    );
  }

  // Method to convert to BaseFilterModel
  BaseFilterModel toBase() {
    return BaseFilterModel(
      searchBy: searchBy,
      searchText: searchText,
      sortBy: sortBy,
      sortOrder: sortOrder,
      active: active,
      deleted: deleted,
      createdFromDate: createdFromDate,
      createdToDate: createdToDate,
      updatedFromDate: updatedFromDate,
      updatedToDate: updatedToDate,
      deletedFromDate: deletedFromDate,
      deletedToDate: deletedToDate,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'PageNumber': pageNumber.toString(),
      'Limit': limit.toString(),
      'SortOrder': sortOrder,
    };

    if (searchBy != null && searchBy!.isNotEmpty)
      params['SearchBy'] = searchBy!;
    if (searchText != null && searchText!.isNotEmpty)
      params['SearchText'] = searchText!;

    if (countryId != null) params['CountryId'] = countryId.toString();
    if (divisionOneId != null)
      params['DivisionOneId'] = divisionOneId.toString();
    if (divisionTwoId != null)
      params['DivisionTwoId'] = divisionTwoId.toString();
    if (divisionThreeId != null)
      params['DivisionThreeId'] = divisionThreeId.toString();

    if (sortBy != null && sortBy!.isNotEmpty) params['SortBy'] = sortBy!;

    if (active != null) params['Active'] = active.toString();
    if (deleted != null) params['Deleted'] = deleted.toString();

    if (createdFromDate != null)
      params['CreatedFromDate'] = createdFromDate!.toIso8601String();
    if (createdToDate != null)
      params['CreatedToDate'] = createdToDate!.toIso8601String();

    if (updatedFromDate != null)
      params['UpdatedFromDate'] = updatedFromDate!.toIso8601String();
    if (updatedToDate != null)
      params['UpdatedToDate'] = updatedToDate!.toIso8601String();

    if (deletedFromDate != null)
      params['DeletedFromDate'] = deletedFromDate!.toIso8601String();
    if (deletedToDate != null)
      params['DeletedToDate'] = deletedToDate!.toIso8601String();

    return params;
  }
}
