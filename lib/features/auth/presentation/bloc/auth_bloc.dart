import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.register(event.email, event.password);
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.login(event.email, event.password);
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<CheckAuthEvent>((event, emit) async {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });

    on<LogoutEvent>((event, emit) async {
      await authRepository.logout();
      emit(Unauthenticated());
    });
  }
}
