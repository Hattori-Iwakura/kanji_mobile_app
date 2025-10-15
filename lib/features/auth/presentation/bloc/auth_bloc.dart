import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/auth_service.dart';
import '../../data/models/auth_response_model.dart';
import '../../../../core/network/api_client.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final AuthService authService;
  final ApiClient apiClient;

  AuthBloc({
    required this.repository,
    required this.authService,
    required this.apiClient,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final isAuth = await authService.isAuthenticated();
    if (!isAuth) {
      emit(const AuthUnauthenticated());
      return;
    }

    final authResponse = await authService.getAuthResponse();
    if (authResponse != null) {
      // Set token to API client
      apiClient.setAuthToken(authResponse.accessToken);

      // Check if token is expired
      if (authResponse.expiresAt.isBefore(DateTime.now())) {
        // Try to refresh token
        add(const RefreshTokenRequested());
      } else {
        emit(
          AuthAuthenticated(
            user: authResponse.user,
            accessToken: authResponse.accessToken,
          ),
        );
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await repository.login(event.account, event.password);

    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (authResponse) async {
        // Save auth data
        await authService.saveAuthData(authResponse as AuthResponseModel);

        // Set token to API client
        apiClient.setAuthToken(authResponse.accessToken);

        emit(
          AuthAuthenticated(
            user: authResponse.user,
            accessToken: authResponse.accessToken,
          ),
        );
      },
    );
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    final sessionId = await authService.getSessionId();
    final refreshToken = await authService.getRefreshToken();

    if (sessionId == null || refreshToken == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    final result = await repository.refreshToken(sessionId, refreshToken);

    await result.fold(
      (failure) async {
        // Refresh failed, logout user
        await authService.clearAuthData();
        apiClient.clearAuthToken();
        emit(const AuthUnauthenticated());
      },
      (authResponse) async {
        // Save new auth data
        await authService.saveAuthData(authResponse as AuthResponseModel);

        // Set new token to API client
        apiClient.setAuthToken(authResponse.accessToken);

        emit(
          AuthAuthenticated(
            user: authResponse.user,
            accessToken: authResponse.accessToken,
          ),
        );
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final sessionId = await authService.getSessionId();

    if (sessionId != null) {
      await repository.logout(sessionId);
    }

    // Clear local auth data
    await authService.clearAuthData();
    apiClient.clearAuthToken();

    emit(const AuthUnauthenticated());
  }
}
