import 'package:equatable/equatable.dart';

class PostOfficeLookupFilter extends Equatable {
  final int? countryId;
  final int? divOneId;
  final int? divTwoId;
  final int? divThreeId;

  const PostOfficeLookupFilter({
    this.countryId,
    this.divOneId,
    this.divTwoId,
    this.divThreeId,
  });

  /// Only call lookup when all required IDs exist
  bool get isReady =>
      countryId != null &&
      divOneId != null &&
      divTwoId != null &&
      divThreeId != null;

  /// Optional helper (VERY useful in UI resets)
  const PostOfficeLookupFilter.empty()
    : countryId = null,
      divOneId = null,
      divTwoId = null,
      divThreeId = null;

  @override
  List<Object?> get props => [countryId, divOneId, divTwoId, divThreeId];
}
