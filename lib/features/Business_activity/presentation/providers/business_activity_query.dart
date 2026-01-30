import 'package:voice_first_admin/features/Business_activity/models/activity_searchby.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_filter.dart';

class BusinessActivityQuery {
  final ActivitySearchBy? searchBy;
  final String? searchText;

  final String? sortBy;
  final String? sortOrder;

  final bool? active;
  final bool? deleted;

  final int pageNumber;
  final int limit;

  final DateTime? createdFromDate;
  final DateTime? createdToDate;
  final DateTime? updatedFromDate;
  final DateTime? updatedToDate;
  final DateTime? deletedFromDate;
  final DateTime? deletedToDate;

  const BusinessActivityQuery({
    this.searchBy,
    this.searchText,
    this.sortBy,
    this.sortOrder,
    this.active,
    this.deleted,
    this.pageNumber = 1,
    this.limit = 10,
    this.createdFromDate,
    this.createdToDate,
    this.updatedFromDate,
    this.updatedToDate,
    this.deletedFromDate,
    this.deletedToDate,
  });

  factory BusinessActivityQuery.initial() => const BusinessActivityQuery();

  BusinessActivityFilter toApiFilter() {
    return BusinessActivityFilter(
      searchBy: searchBy?.apiValue,
      searchText: searchText,
      sortBy: sortBy,
      sortOrder: sortOrder,
      active: active,
      deleted: deleted,
      pageNumber: pageNumber,
      limit: limit,
      createdFromDate: createdFromDate,
      createdToDate: createdToDate,
      updatedFromDate: updatedFromDate,
      updatedToDate: updatedToDate,
      deletedFromDate: deletedFromDate,
      deletedToDate: deletedToDate,
    );
  }

  BusinessActivityQuery copyWith({
    ActivitySearchBy? searchBy,
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
    int? pageNumber,
    int? limit,
  }) {
    return BusinessActivityQuery(
      searchBy: searchBy ?? this.searchBy,
      searchText: searchText ?? this.searchText,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      pageNumber: pageNumber ?? this.pageNumber,
      limit: limit ?? this.limit,
      createdFromDate: createdFromDate ?? this.createdFromDate,
      createdToDate: createdToDate ?? this.createdToDate,
      updatedFromDate: updatedFromDate ?? this.updatedFromDate,
      updatedToDate: updatedToDate ?? this.updatedToDate,
      deletedFromDate: deletedFromDate ?? this.deletedFromDate,
      deletedToDate: deletedToDate ?? this.deletedToDate,
    );
  }
}
