import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/auth_repository.dart' as auth_repo;

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  AuthSignUpRequested({required this.email, required this.password, required this.name});

  @override
  List<Object?> get props => [email, password, name];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

class AuthStateChanged extends AuthEvent {
  final UserProfile? user;
  final bool isAuthenticated;

  AuthStateChanged({this.user, required this.isAuthenticated});

  @override
  List<Object?> get props => [user, isAuthenticated];
}

class DeepLinkReceived extends AuthEvent {
  final Uri uri;

  DeepLinkReceived(this.uri);

  @override
  List<Object?> get props => [uri];
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserProfile user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final String code;

  AuthError(this.message, {this.code = 'unknown'});

  @override
  List<Object?> get props => [message, code];
}

class AuthNeedsEmailConfirmation extends AuthState {
  final String email;

  AuthNeedsEmailConfirmation(this.email);

  @override
  List<Object?> get props => [email];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthStateChanged>(_onStateChanged);
    on<DeepLinkReceived>(_onDeepLinkReceived);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUp(event.email, event.password, event.name);
      emit(AuthAuthenticated(user));
    } on auth_repo.UserAlreadyExistsException catch (_) {
      emit(AuthError(
        'An account with this email already exists. Please sign in instead.',
        code: 'user_exists',
      ));
    } on auth_repo.WeakPasswordException catch (_) {
      emit(AuthError(
        'Password is too weak. Please use at least 6 characters with a mix of letters and numbers.',
        code: 'weak_password',
      ));
    } on auth_repo.NetworkException catch (_) {
      emit(AuthError(
        'Network error. Please check your internet connection and try again.',
        code: 'network_error',
      ));
    } on auth_repo.AuthException catch (e) {
      // Map specific error codes to user-friendly messages
      final message = _getUserFriendlyError(e);
      emit(AuthError(message, code: e.code));
    } catch (e) {
      emit(AuthError(
        'Failed to create account. Please try again.',
        code: 'signup_failed',
      ));
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(event.email, event.password);
      emit(AuthAuthenticated(user));
    } on auth_repo.InvalidCredentialsException catch (_) {
      emit(AuthError(
        'Invalid email or password. Please check your credentials and try again.',
        code: 'invalid_credentials',
      ));
    } on auth_repo.EmailNotConfirmedException catch (_) {
      emit(AuthNeedsEmailConfirmation(event.email));
    } on auth_repo.NetworkException catch (_) {
      emit(AuthError(
        'Network error. Please check your internet connection and try again.',
        code: 'network_error',
      ));
    } on auth_repo.AuthException catch (e) {
      final message = _getUserFriendlyError(e);
      emit(AuthError(message, code: e.code));
    } catch (e) {
      emit(AuthError(
        'Failed to sign in. Please try again.',
        code: 'signin_failed',
      ));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(AuthAuthenticated(user));
    } on auth_repo.AuthException catch (e) {
      final message = _getUserFriendlyError(e);
      emit(AuthError(message, code: e.code));
    } catch (e) {
      emit(AuthError(
        'Failed to sign in with Google. Please try again.',
        code: 'google_signin_failed',
      ));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(
        'Failed to sign out. Please try again.',
        code: 'signout_failed',
      ));
    }
  }

  Future<void> _onStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.isAuthenticated && event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onDeepLinkReceived(
    DeepLinkReceived event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.handleDeepLink(event.uri);
      // After handling deep link, check auth state
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(
        'Failed to complete authentication. Please try again.',
        code: 'deeplink_failed',
      ));
    }
  }

  String _getUserFriendlyError(auth_repo.AuthException e) {
    switch (e.code) {
      case 'user_exists':
        return 'An account with this email already exists. Please sign in instead.';
      case 'invalid_credentials':
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'weak_password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'email_not_confirmed':
        return 'Email not confirmed. Please check your inbox and confirm your email.';
      case 'network_error':
        return 'Network error. Please check your internet connection and try again.';
      case 'rate_limit':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return e.message;
    }
  }
}