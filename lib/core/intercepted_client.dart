// somewhere common, e.g. core/http_utils.dart
import 'package:works_app/firebase/locator.dart';
import 'package:works_app/core/token_manager.dart';
import 'package:works_app/components/global_handle.dart';
import '../bloc/authentication/authentication_bloc.dart';

void handleAuthFailure(int statusCode, Map<String, dynamic> body) {
  final msg = (body['message'] ?? '').toString().toLowerCase();
  final dynamic statusField = body['status'];
  final bool statusIsFalse =
      statusField == false ||
          (statusField is String && statusField.toLowerCase() == 'false') ||
          (statusField is num && statusField == 0);

  final bool looksUnauthorized =
      msg.contains('unauthorized') || msg.contains('authentication failed');

  final bool looksBlocked = msg.contains('blocked');

  // treat either real 401 or body {status:false + auth-ish message} as auth failure
  final bool shouldLogout =
      statusCode == 401 || (statusIsFalse && (looksUnauthorized || looksBlocked));

  if (shouldLogout) {
    // Either blocked or generic unauthorized — kick user out
    // Prefer TokenManager to ensure tokens cleared + navigation fallback
    locator<TokenManager>().clearTokensAndLogout(
      reason: looksBlocked ? 'Account blocked' : 'Unauthorized',
    );

    // Also emit bloc event (harmless if already navigating)
    GlobalBlocClass.authenticationBloc?.add(const AuthenticationLogoutEvent());
  } else {
    // print('---------No issue ----------');
  }
}


// void checkTokenResponse(Map<String, dynamic> response) {
//   final status = response['status'];
//   final bool isFalse = status == false || (status is String && status.toLowerCase() == 'false');
//
//   final msg = (response['message'] ?? '').toString().toLowerCase();
//   final bool match = isFalse && (
//       msg.contains('unauthorized') ||
//           msg.contains('authentication failed') ||
//           msg.contains('blocked')
//   );
//
//   if (match) {
//     GlobalBlocClass.authenticationBloc?.add(const AuthenticationLogoutEvent());
//   } else {
//     // print('---------No issue ----------');
//   }
// }

