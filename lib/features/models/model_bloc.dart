import 'package:flutter_bloc/flutter_bloc.dart';

import 'model_event.dart';
import 'model_repo.dart';
import 'model_state.dart';

class ModelBloc extends Bloc<ModelEvent, ModelState> {
  final ModelRepository repository;

  ModelBloc(this.repository) : super(ModelInitial()) {
    on<FetchModelsEvent>((event, emit) async {
      emit(ModelLoading());
      try {
        final models = await repository.fetchModels();
        emit(ModelLoaded(models));
      } catch (e) {
        emit(ModelError(e.toString()));
      }
    });
  }
}
