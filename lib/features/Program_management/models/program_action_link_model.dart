// class SysProgramActionLink {
//   final int? sysProgramActionLinkId;
//   final int programId;
//   final int programActionId;
//   final int? createdBy;
//   final DateTime? createdAt;
//   final bool isActive;
//   final int? updatedBy;
//   final DateTime? updatedAt;

//   const SysProgramActionLink({
//     this.sysProgramActionLinkId,
//     required this.programId,
//     required this.programActionId,
//     this.createdBy,
//     this.createdAt,
//     this.isActive = true,
//     this.updatedBy,
//     this.updatedAt,
//   });

//   factory SysProgramActionLink.fromJson(Map<String, dynamic> json) {
//     return SysProgramActionLink(
//       sysProgramActionLinkId: json['sysProgramActionLinkId'] as int?,
//       programId: json['programId'] as int,
//       programActionId: json['programActionId'] as int,
//       createdBy: json['createdBy'] as int?,
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'] as String)
//           : null,
//       isActive: json['isActive'] as bool? ?? true,
//       updatedBy: json['updatedBy'] as int?,
//       updatedAt: json['updatedAt'] != null
//           ? DateTime.parse(json['updatedAt'] as String)
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'sysProgramActionLinkId': sysProgramActionLinkId,
//       'programId': programId,
//       'programActionId': programActionId,
//       'createdBy': createdBy,
//       'createdAt': createdAt?.toIso8601String(),
//       'isActive': isActive,
//       'updatedBy': updatedBy,
//       'updatedAt': updatedAt?.toIso8601String(),
//     };
//   }

//   SysProgramActionLink copyWith({
//     int? sysProgramActionLinkId,
//     int? programId,
//     int? programActionId,
//     int? createdBy,
//     DateTime? createdAt,
//     bool? isActive,
//     int? updatedBy,
//     DateTime? updatedAt,
//   }) {
//     return SysProgramActionLink(
//       sysProgramActionLinkId:
//           sysProgramActionLinkId ?? this.sysProgramActionLinkId,
//       programId: programId ?? this.programId,
//       programActionId: programActionId ?? this.programActionId,
//       createdBy: createdBy ?? this.createdBy,
//       createdAt: createdAt ?? this.createdAt,
//       isActive: isActive ?? this.isActive,
//       updatedBy: updatedBy ?? this.updatedBy,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is SysProgramActionLink &&
//           runtimeType == other.runtimeType &&
//           sysProgramActionLinkId == other.sysProgramActionLinkId;

//   @override
//   int get hashCode => sysProgramActionLinkId.hashCode;
// }
