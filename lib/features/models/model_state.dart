import 'model.dart';

abstract class ModelState {}

class ModelInitial extends ModelState {}

class ModelLoading extends ModelState {}

class ModelLoaded extends ModelState {
  final List<Model> models;
  ModelLoaded(this.models);
}

class ModelError extends ModelState {
  final String message;
  ModelError(this.message);
}
