import 'package:equatable/equatable.dart';

class PostOfficeLookupFilter extends Equatable {
  final int? countryId;
  final int? divOneId;
  final int? divTwoId;
  final int? divThreeId;
  final int? placeId;

  const PostOfficeLookupFilter({
    this.countryId,
    this.divOneId,
    this.divTwoId,
    this.divThreeId,
    this.placeId,
  });

  /// Only call lookup when all required IDs exist
  bool get isReady =>
      [countryId, divOneId, divTwoId, divThreeId].every((e) => e != null);

  /// Optional helper (VERY useful in UI resets)
  const PostOfficeLookupFilter.empty()
    : countryId = null,
      divOneId = null,
      divTwoId = null,
      divThreeId = null,
      placeId = null;

  @override
  List<Object?> get props => [
    countryId,
    divOneId,
    divTwoId,
    divThreeId,
    placeId,
  ];
}
