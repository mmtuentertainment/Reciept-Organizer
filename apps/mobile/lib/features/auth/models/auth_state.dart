import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required String userId,
    required String email,
    required Session session,
    @Default(false) bool isOffline,
  }) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse.success({
    required Session session,
    @Default(false) bool isOffline,
  }) = _Success;
  const factory AuthResponse.error(String message) = _ErrorResponse;
}