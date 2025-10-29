import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/setup_2fa.dart';
import '../../domain/usecases/enable_2fa.dart';
import '../../domain/usecases/disable_2fa.dart';
import '../../domain/usecases/send_email_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Register register;
  final Logout logout;
  final GetProfile getProfile;
  final CheckAuthStatus checkAuthStatus;
  final Setup2FA setup2FA;
  final Enable2FA enable2FA;
  final Disable2FA disable2FA;
  final SendEmailOTP sendEmailOTP;

  AuthBloc({
    required this.login,
    required this.register,
    required this.logout,
    required this.getProfile,
    required this.checkAuthStatus,
    required this.setup2FA,
    required this.enable2FA,
    required this.disable2FA,
    required this.sendEmailOTP,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<GetProfileEvent>(_onGetProfile);
    on<Setup2FAEvent>(_onSetup2FA);
    on<Enable2FAEvent>(_onEnable2FA);
    on<Disable2FAEvent>(_onDisable2FA);
    on<SendEmailOTPEvent>(_onSendEmailOTP);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkAuthStatus();

    await result.fold((failure) async => emit(Unauthenticated()), (
      isAuthenticated,
    ) async {
      if (isAuthenticated) {
        // Try to get profile
        final profileResult = await getProfile();
        profileResult.fold(
          (failure) => emit(Unauthenticated()),
          (user) => emit(Authenticated(user)),
        );
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await login(
      event.email,
      event.password,
      twoFactorCode: event.twoFactorCode,
    );

    result.fold(
      (failure) {
        print('=== AUTH BLOC - LOGIN FAILURE ===');
        print('Failure message: ${failure.message}');
        print('Contains 2FA: ${failure.message.contains('2FA')}');
        print('Contains two-factor: ${failure.message.contains('two-factor')}');

        // Check if 2FA is required
        if (failure.message.contains('2FA') ||
            failure.message.contains('two-factor')) {
          print('=== EMITTING TwoFactorRequired STATE ===');
          emit(TwoFactorRequired(event.email, event.password));
        } else {
          print('=== EMITTING AuthError STATE ===');
          emit(AuthError(failure.message));
        }
      },
      (user) {
        print('=== AUTH BLOC - LOGIN SUCCESS ===');
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await register(event.email, event.password, event.name);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await logout();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await getProfile();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSetup2FA(Setup2FAEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await setup2FA();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (setup) => emit(TwoFactorSetupSuccess(setup)),
    );
  }

  Future<void> _onEnable2FA(
    Enable2FAEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await enable2FA(event.code);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(TwoFactorEnabled(user)),
    );
  }

  Future<void> _onDisable2FA(
    Disable2FAEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await disable2FA(password: event.password, code: event.code);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(TwoFactorDisabled(user)),
    );
  }

  Future<void> _onSendEmailOTP(
    SendEmailOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await sendEmailOTP();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(EmailOTPSent()),
    );
  }
}
