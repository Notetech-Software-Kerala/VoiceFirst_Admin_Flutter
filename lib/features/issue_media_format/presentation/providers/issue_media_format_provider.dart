import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_model.dart';
import 'package:voice_first_admin/features/issue_media_format/data/service/media_format_service.dart';
import 'issue_media_format_notifier.dart';
import 'issue_media_format_state.dart';

final issueMediaFormatProvider =
    NotifierProvider<IssueMediaFormatNotifier, IssueMediaFormatState>(
      IssueMediaFormatNotifier.new,
    );

final issueMediaFormatDetailProvider =
    FutureProvider.family<IssueMediaFormatModel, int>((ref, id) async {
      final service = ref.read(issueMediaFormatServiceProvider);
      return service.getById(id);
    });
