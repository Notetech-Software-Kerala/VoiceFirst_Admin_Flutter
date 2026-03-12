import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_type/data/models/issue_type_model.dart';
import 'package:voice_first_admin/features/issue_type/data/service/issue_type_service.dart';
import 'issue_type_notifier.dart';
import 'issue_type_state.dart';

final issueTypeProvider =
    NotifierProvider<IssueTypeNotifier, IssueTypeState>(IssueTypeNotifier.new);

final issueTypeDetailProvider =
    FutureProvider.family<IssueTypeModel, int>((ref, id) async {
      final service = IssueTypeService();
      return service.getById(id);
    });
