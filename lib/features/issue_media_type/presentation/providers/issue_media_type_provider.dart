import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_model.dart';
import 'package:voice_first_admin/features/issue_media_type/data/repositories/media_type_repository.dart';
import 'package:voice_first_admin/features/issue_media_type/presentation/providers/issue_media_type_notifier.dart';
import 'package:voice_first_admin/features/issue_media_type/presentation/providers/issue_media_type_state.dart';

final issueMediaTypeProvider =
    NotifierProvider<IssueMediaTypeNotifier, IssueMediaTypeState>(
      IssueMediaTypeNotifier.new,
    );

final issueMediaTypeDetailProvider =
    FutureProvider.family<IssueMediaTypeModel, int>((ref, id) async {
      final repository = ref.read(issueMediaTypeRepositoryProvider);
      return repository.getById(id);
    });
