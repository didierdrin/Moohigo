import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/law_model.dart';
import '../repositories/law_repository.dart';

abstract class DiscoverState {}

class DiscoverInitial extends DiscoverState {}

class DiscoverLoading extends DiscoverState {}

class DiscoverLoaded extends DiscoverState {
  final List<LegalDocument> dailyReadings;
  final List<LegalDocument> recentReads;

  DiscoverLoaded({required this.dailyReadings, required this.recentReads});
}

class DiscoverError extends DiscoverState {
  final String message;
  DiscoverError(this.message);
}

class DiscoverCubit extends Cubit<DiscoverState> {
  final LawRepository _repository;

  DiscoverCubit(this._repository) : super(DiscoverInitial()) {
    loadDiscoverData();
  }

  void loadDiscoverData() async {
    emit(DiscoverLoading());
    try {
      final daily = await _repository.fetchDailyReading();
      final recent = await _repository.fetchRecentReads();
      emit(DiscoverLoaded(dailyReadings: daily, recentReads: recent));
    } catch (e) {
      emit(DiscoverError("Failed to load discover data: $e"));
    }
  }
}
