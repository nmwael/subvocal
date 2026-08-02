import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/opensubtitles_api.dart';
import '../../data/datasources/token_storage.dart';
import 'search_provider.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? username;
  final UserAccountInfo? accountInfo;

  const AuthState({required this.status, this.username, this.accountInfo});

  const AuthState.unknown()
    : status = AuthStatus.unknown,
      username = null,
      accountInfo = null;
  const AuthState.authenticated(this.username, {this.accountInfo})
    : status = AuthStatus.authenticated;
  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      username = null,
      accountInfo = null;
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(tokenStorageProvider);
    final repo = ref.read(subtitleRepositoryProvider);

    final token = await storage.getToken();
    if (token == null) return const AuthState.unauthenticated();

    final valid = await repo.validateToken();
    if (!valid) {
      await storage.clearToken();
      return const AuthState.unauthenticated();
    }

    // Restore the token on the shared API instance
    ref.read(subtitleRepositoryProvider).setToken(token);

    final username = await storage.getUsername();
    return AuthState.authenticated(username, accountInfo: repo.api.accountInfo);
  }

  Future<bool> login(String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(subtitleRepositoryProvider);
      final (token, failure) = await repo.login(username, password);
      if (failure != null || token == null) {
        return const AuthState.unauthenticated();
      }

      final storage = ref.read(tokenStorageProvider);
      await storage.saveToken(token, username: username);

      // Set the token on the shared API instance
      ref.read(subtitleRepositoryProvider).setToken(token);

      return AuthState.authenticated(
        username,
        accountInfo: repo.api.accountInfo,
      );
    });
    return state.valueOrNull?.status == AuthStatus.authenticated;
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final storage = ref.read(tokenStorageProvider);
    final repo = ref.read(subtitleRepositoryProvider);
    repo.logout();
    await storage.clearToken();
    state = const AsyncData(AuthState.unauthenticated());
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
