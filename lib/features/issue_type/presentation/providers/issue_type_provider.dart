import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/issue_type_model.dart';
import '../../data/repositories/issue_type_repository.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'issue_type_notifier.dart';
import 'issue_type_state.dart';

final issueTypeProvider = NotifierProvider<IssueTypeNotifier, IssueTypeState>(
  IssueTypeNotifier.new,
);

final issueTypeRepositoryProvider = Provider((ref) {
  return IssueTypeRepository(ref.read(dioClientProvider));
});

final issueTypeDetailProvider = FutureProvider.family<IssueTypeModel, int>((
  ref,
  id,
) async {
  final repository = ref.read(issueTypeRepositoryProvider);
  return repository.getById(id);
});
