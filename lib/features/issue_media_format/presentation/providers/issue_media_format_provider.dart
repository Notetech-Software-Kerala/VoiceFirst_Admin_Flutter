import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_model.dart';
import 'package:voice_first_admin/features/issue_media_format/data/repositories/media_format_repository.dart';
import 'package:voice_first_admin/features/issue_media_format/presentation/providers/issue_media_format_notifier.dart';
import 'package:voice_first_admin/features/issue_media_format/presentation/providers/issue_media_format_state.dart';


final issueMediaFormatProvider =
    NotifierProvider<IssueMediaFormatNotifier, IssueMediaFormatState>(
      IssueMediaFormatNotifier.new,
    );

final issueMediaFormatDetailProvider =
    FutureProvider.family<IssueMediaFormatModel, int>((ref, id) async {
      final repository = ref.read(issueMediaFormatRepositoryProvider);
      return repository.getById(id);
    });
