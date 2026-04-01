import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_character_type/data/models/issue_charactertype_model.dart';
import 'package:voice_first_admin/features/issue_character_type/data/repositories/character_type_repository.dart';
import 'package:voice_first_admin/features/issue_character_type/presentation/providers/issue_character_type_notifier.dart';
import 'package:voice_first_admin/features/issue_character_type/presentation/providers/issue_character_type_state.dart';

final issueCharacterTypeProvider =
    NotifierProvider<IssueCharacterTypeNotifier, IssueCharacterTypeState>(
      IssueCharacterTypeNotifier.new,
    );

/// Detail provider to load a single IssueCharacterType by ID
final issueCharacterTypeDetailProvider =
    FutureProvider.family<IssueCharacterTypeModel, int>((ref, id) async {
      final repository = ref.read(characterTypeRepositoryProvider);
      return repository.getById(id);
    });
