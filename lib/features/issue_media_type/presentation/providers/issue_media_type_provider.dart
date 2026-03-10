import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_model.dart';
import 'package:voice_first_admin/features/issue_media_type/data/service/media_type_service.dart';
import 'issue_media_type_notifier.dart';
import 'issue_media_type_state.dart';

final issueMediaTypeProvider =
    NotifierProvider<IssueMediaTypeNotifier, IssueMediaTypeState>(
      IssueMediaTypeNotifier.new,
    );

final issueMediaTypeDetailProvider =
    FutureProvider.family<IssueMediaTypeModel, int>((ref, id) async {
      final service = MediaTypeService();
      return service.getById(id);
    });
