import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/issue_status_model.dart';
import '../../data/models/issue_status_filter.dart';
import '../../data/repositories/issue_status_repository.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'issue_status_notifier.dart';
import 'issue_status_state.dart';

final issueStatusProvider =
    NotifierProvider<IssueStatusNotifier, IssueStatusState>(
      IssueStatusNotifier.new,
    );

final issueStatusRepositoryProvider = Provider((ref) {
  return IssueStatusRepository(ref.read(dioClientProvider));
});

final issueStatusDetailProvider =
    FutureProvider.family<IssueStatusModel, int>((ref, id) async {
      final repository = ref.read(issueStatusRepositoryProvider);
      return repository.getById(id);
    });
