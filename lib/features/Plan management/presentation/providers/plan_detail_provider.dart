import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/core/config/api_endpints.dart';
import '../../models/plan_detail_model.dart';
import '../../plan_service/plan_service.dart';

class PlanDetailState {
  final PlanDetailModel? detail;
  final bool isLoading;
  final String? error;

  const PlanDetailState({this.detail, this.isLoading = false, this.error});

  PlanDetailState copyWith({
    PlanDetailModel? detail,
    bool? isLoading,
    String? error,
  }) {
    return PlanDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PlanDetailNotifier extends StateNotifier<PlanDetailState> {
  final PlanService _service;
  final int id;

  PlanDetailNotifier({required PlanService service, required this.id})
    : _service = service,
      super(const PlanDetailState(isLoading: false));

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final detail = await _service.getPlanById(id);
      state = state.copyWith(detail: detail, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final planDetailProvider =
    StateNotifierProvider.family<PlanDetailNotifier, PlanDetailState, int>((
      ref,
      id,
    ) {
      final service = PlanService(baseUrl: ApiEndpoints.baseUrl);
      return PlanDetailNotifier(service: service, id: id);
    });
