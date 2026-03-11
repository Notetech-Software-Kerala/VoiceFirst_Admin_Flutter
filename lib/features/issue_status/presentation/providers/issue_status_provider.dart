import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_status/data/models/issue_status_model.dart';
import 'package:voice_first_admin/features/issue_status/data/service/issue_status_service.dart';
import 'issue_status_notifier.dart';
import 'issue_status_state.dart';

final issueStatusProvider =
    NotifierProvider<IssueStatusNotifier, IssueStatusState>(
      IssueStatusNotifier.new,
    );

final issueStatusDetailProvider =
    FutureProvider.family<IssueStatusModel, int>((ref, id) async {
      final service = IssueStatusService();
      return service.getById(id);
    });
