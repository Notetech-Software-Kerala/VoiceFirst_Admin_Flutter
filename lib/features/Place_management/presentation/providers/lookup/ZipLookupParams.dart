// // ===============================
// // 1️⃣ ZipLookupParams
// // ===============================

// import 'package:flutter/foundation.dart';

// @immutable
// class ZipLookupParams {
//   final int postOfficeId;
//   final int placeId;

//   const ZipLookupParams({
//     required this.postOfficeId,
//     required this.placeId,
//   });

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is ZipLookupParams &&
//         other.postOfficeId == postOfficeId &&
//         other.placeId == placeId;
//   }

//   @override
//   int get hashCode => Object.hash(postOfficeId, placeId);

//   @override
//   String toString() =>
//       'ZipLookupParams(postOfficeId: $postOfficeId, placeId: $placeId)';
// }
