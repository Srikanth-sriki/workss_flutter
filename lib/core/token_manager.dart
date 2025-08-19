// lib/core/token_manager.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/config.dart';
import '../components/local_constant.dart';
import '../components/global_handle.dart';
import '../bloc/authentication/authentication_bloc.dart';

/// Centralized token storage + safe global logout + (optional) refresh logic.
class TokenManager {
  TokenManager({http.Client? refreshHttp})
      : _refreshHttp = refreshHttp ?? http.Client();

  final http.Client _refreshHttp;

  String? _accessToken;   // in-memory cache
  String? _refreshToken;  // in-memory cache

  // Prevents multiple refreshes at once.
  Future<bool>? _refreshingFuture;

  // Prevents double-logout crashes.
  static bool _isLoggingOut = false;

  /// Load tokens once during app startup.
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(LocalConstant.accessToken);
    _refreshToken = prefs.getString(LocalConstant.refreshToken);

    // Keep legacy Config in sync for any old code paths.
    Config.accessToken = _accessToken ?? '';
  }

  Future<String?> getAccessToken() async {
    if (_accessToken != null) return _accessToken;
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(LocalConstant.accessToken);
    return _accessToken;
  }

  Future<String?> getRefreshToken() async {
    if (_refreshToken != null) return _refreshToken;
    final prefs = await SharedPreferences.getInstance();
    _refreshToken = prefs.getString(LocalConstant.refreshToken);
    return _refreshToken;
  }

  /// Persist new tokens (call this when server returns a new access token header).
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _accessToken = accessToken;
    await prefs.setString(LocalConstant.accessToken, accessToken);
    Config.accessToken = accessToken;

    if (refreshToken != null && refreshToken.isNotEmpty) {
      _refreshToken = refreshToken;
      await prefs.setString(LocalConstant.refreshToken, refreshToken);
    }
  }

  /// Clears all auth and safely routes the user to the login/auth screen.
  Future<void> clearTokensAndLogout({String? reason, String redirectRoute = '/authentication'}) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(LocalConstant.accessToken);
      await prefs.remove(LocalConstant.refreshToken);
      await prefs.remove(LocalConstant.userId);
      await prefs.remove(LocalConstant.profileCompleted);
      await prefs.remove(LocalConstant.phoneNumber);
      await prefs.remove(LocalConstant.name);

      _accessToken = null;
      _refreshToken = null;
      Config.accessToken = '';

      // 1) Notify the bloc if it's still alive
      final authBloc = GlobalBlocClass.authenticationBloc;
      if (authBloc != null && !authBloc.isClosed) {
        authBloc.add(const AuthenticationLogoutEvent());
      }

      // 2) Hard navigation fallback to make sure we land on /authentication
      final ctx = GlobalBlocClass.authenticationContext;
      if (ctx != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // ignore: use_build_context_synchronously
          Navigator.of(ctx).pushNamedAndRemoveUntil(redirectRoute, (_) => false);
        });
      }
    } finally {
      _isLoggingOut = false;
    }
  }

  /// Ensures only one refresh happens for concurrent 401s.
  Future<bool> refreshTokenOnce() {
    _refreshingFuture ??= _doRefresh().whenComplete(() {
      _refreshingFuture = null;
    });
    return _refreshingFuture!;
  }

  /// Implement your real refresh call here.
  ///
  /// Return `true` if you successfully obtained a fresh access token and saved it
  /// via [saveTokens]. Return `false` to indicate failure (caller will logout).
  Future<bool> _doRefresh() async {
    try {
      // If your backend DOES NOT have a refresh endpoint and only returns a new token
      // in headers (e.g., x-refreshed-token) on normal requests, just return false
      // so the caller logs out on 401.
      //
      // return false;

      // If your backend HAS a refresh endpoint, implement it here:
      final rt = await getRefreshToken();
      if (rt == null || rt.isEmpty) return false;

      final resp = await _refreshHttp.post(
        Uri.parse('${Config.url}/auth/refresh'), // <-- adjust path
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({'refreshToken': rt}),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final newAccess = (data['accessToken'] ?? '').toString();
        final newRefresh = (data['refreshToken'] ?? '').toString();

        if (newAccess.isEmpty) return false;

        await saveTokens(
          accessToken: newAccess,
          refreshToken: newRefresh.isEmpty ? null : newRefresh,
        );
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
