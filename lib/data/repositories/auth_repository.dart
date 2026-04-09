import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_profile.dart';

/// Custom exceptions for auth operations
class AuthException implements Exception {
  final String message;
  final String code;
  
  AuthException(this.message, {this.code = 'unknown'});
  
  @override
  String toString() => message;
}

class UserAlreadyExistsException extends AuthException {
  UserAlreadyExistsException() : super('User already exists', code: 'user_exists');
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Invalid email or password', code: 'invalid_credentials');
}

class WeakPasswordException extends AuthException {
  WeakPasswordException() : super('Password is too weak', code: 'weak_password');
}

class EmailNotConfirmedException extends AuthException {
  EmailNotConfirmedException() : super('Email not confirmed. Please check your inbox.', code: 'email_not_confirmed');
}

class NetworkException extends AuthException {
  NetworkException() : super('Network error. Please check your connection.', code: 'network_error');
}

abstract class AuthRepository {
  Future<UserProfile?> getCurrentUser();
  Future<UserProfile> signUp(String email, String password, String name);
  Future<UserProfile> signIn(String email, String password);
  Future<UserProfile> signInWithGoogle();
  Future<UserProfile> signInWithApple();
  Future<void> signOut();
  Stream<AuthStateEvent> get authStateChanges;
  Future<void> handleDeepLink(Uri uri);
}

/// Auth state events for session persistence
class AuthStateEvent {
  final AuthChangeEvent event;
  final UserProfile? user;
  
  AuthStateEvent(this.event, this.user);
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  
  AuthRepositoryImpl(this._supabase);

  @override
  Future<UserProfile?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return null;
      
      final user = session.user;
      final data = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();
      
      return UserProfile.fromMap(data);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Failed to get current user: $e', code: 'get_user_failed');
    }
  }

  @override
  Future<UserProfile> signUp(String email, String password, String name) async {
    try {
      // First check if user might already exist by trying to sign in
      // (Supabase doesn't give us a clean "user exists" error on signup)
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      
      if (response.user == null) {
        throw AuthException('Sign up failed - no user returned', code: 'signup_failed');
      }
      
      // Check if this was a new user or existing user
      // Supabase returns user even if they exist but email confirmation is pending
      final identities = response.user!.identities;
      if (identities != null && identities.isEmpty) {
        // User exists but email not confirmed - treat as "user already exists"
        throw UserAlreadyExistsException();
      }
      
      final now = DateTime.now();
      final profile = UserProfile(
        id: response.user!.id,
        email: email,
        name: name,
        createdAt: now,
        updatedAt: now,
      );
      
      try {
        await _supabase.from('user_profiles').insert(profile.toMap());
      } catch (e) {
        // Profile might already exist - try to update instead
        await _supabase.from('user_profiles').upsert(profile.toMap());
      }
      
      return profile;
      
    } on AuthException {
      rethrow;
    } on AuthWeakPasswordException catch (e) {
      throw WeakPasswordException();
    } on AuthException catch (e) {
      // Check for specific error messages
      final message = e.message.toLowerCase();
      if (message.contains('user already registered') || 
          message.contains('already exists') ||
          message.contains('email address is already')) {
        throw UserAlreadyExistsException();
      }
      if (message.contains('network') || message.contains('connection')) {
        throw NetworkException();
      }
      rethrow;
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('user already registered') || 
          message.contains('already exists') ||
          message.contains('email address is already')) {
        throw UserAlreadyExistsException();
      }
      throw AuthException('Sign up failed: $e', code: 'signup_error');
    }
  }

  @override
  Future<UserProfile> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw InvalidCredentialsException();
      }
      
      return (await getCurrentUser())!;
      
    } on AuthException {
      rethrow;
    } on AuthInvalidCredentialsException catch (e) {
      throw InvalidCredentialsException();
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();
      if (message.contains('invalid login credentials') ||
          message.contains('invalid email or password')) {
        throw InvalidCredentialsException();
      }
      if (message.contains('network') || message.contains('connection')) {
        throw NetworkException();
      }
      if (message.contains('email not confirmed')) {
        throw EmailNotConfirmedException();
      }
      rethrow;
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('invalid login credentials') ||
          message.contains('invalid email or password')) {
        throw InvalidCredentialsException();
      }
      throw AuthException('Sign in failed: $e', code: 'signin_error');
    }
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'bloodpulse://auth/callback',
      );
      
      return (await getCurrentUser())!;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Google sign in failed: $e', code: 'google_signin_error');
    }
  }

  @override
  Future<UserProfile> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'bloodpulse://auth/callback',
      );
      
      return (await getCurrentUser())!;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Apple sign in failed: $e', code: 'apple_signin_error');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e', code: 'signout_error');
    }
  }

  @override
  Stream<AuthStateEvent> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((data) async {
      final event = data.event;
      final session = data.session;
      
      UserProfile? user;
      if (session != null) {
        try {
          user = await getCurrentUser();
        } catch (e) {
          // If we can't get the user profile, still emit the event but with null user
          user = null;
        }
      }
      
      return AuthStateEvent(event, user);
    });
  }

  @override
  Future<void> handleDeepLink(Uri uri) async {
    // Handle OAuth callbacks and email confirmation links
    if (uri.scheme == 'bloodpulse' && uri.host == 'auth') {
      // This is our auth callback
      final params = uri.queryParameters;
      
      // Check for access_token in fragment (OAuth implicit flow)
      // or in query params (PKCE flow)
      final accessToken = params['access_token'];
      final refreshToken = params['refresh_token'];
      final type = params['type'];
      
      if (accessToken != null) {
        // Exchange the token or set the session
        try {
          await _supabase.auth.setSession(accessToken);
        } catch (e) {
          throw AuthException('Failed to set session from deep link: $e', code: 'deeplink_error');
        }
      }
      
      // Handle different auth types
      if (type == 'recovery') {
        // Password recovery flow
      } else if (type == 'invite') {
        // User invited flow
      } else if (type == 'email_change') {
        // Email change confirmation
      }
      
      // Recovery token handling
      final token = params['token'];
      if (token != null && type == 'recovery') {
        // Handle password reset
      }
    }
  }
}