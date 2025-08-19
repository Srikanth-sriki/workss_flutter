// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
//
// import '../components/config.dart';
// import 'token_manager.dart';
//
// class AuthHttpClient extends http.BaseClient {
//   AuthHttpClient({
//     required http.Client inner,
//     required TokenManager tokenManager,
//     void Function()? onUnauthorized,
//     void Function()? onForbidden,
//   })  : _inner = inner,
//         _tokenManager = tokenManager,
//         _onUnauthorized = onUnauthorized,
//         _onForbidden = onForbidden;
//
//   final http.Client _inner;
//   final TokenManager _tokenManager;
//   final void Function()? _onUnauthorized;
//   final void Function()? _onForbidden;
//
//   Future<void> _attachAuth(http.BaseRequest req) async {
//     final tok = await _tokenManager.getAccessToken();
//     if (tok != null && tok.isNotEmpty) {
//       req.headers[HttpHeaders.authorizationHeader] = 'Bearer $tok';
//     } else {
//       req.headers.remove(HttpHeaders.authorizationHeader);
//     }
//     req.headers.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/json');
//   }
//
//   String? _getHeader(Map<String, String> headers, String name) {
//     final ln = name.toLowerCase();
//     for (final e in headers.entries) {
//       if (e.key.toLowerCase() == ln) return e.value;
//     }
//     return null;
//   }
//
//   String? _parseBearer(String? authHeader) {
//     if (authHeader == null) return null;
//     final parts = authHeader.split(' ');
//     if (parts.length == 2 && parts.first.toLowerCase() == 'bearer') {
//       return parts.last.trim();
//     }
//     return null;
//   }
//
//   http.BaseRequest _clone(http.BaseRequest original, {List<int>? bodyBytes}) {
//     final copy = http.Request(original.method, original.url)
//       ..persistentConnection = original.persistentConnection
//       ..followRedirects = original.followRedirects
//       ..maxRedirects = original.maxRedirects;
//     copy.headers.addAll(Map<String, String>.from(original.headers)
//       ..remove(HttpHeaders.authorizationHeader));
//     if (bodyBytes != null) {
//       (copy as http.Request).bodyBytes = bodyBytes;
//     }
//     return copy;
//   }
//
//   List<int>? _maybeBody(http.BaseRequest request) =>
//       request is http.Request ? request.bodyBytes : null;
//
//   bool _looksBlockedMessage(String bodyText) {
//     try {
//       final j = jsonDecode(bodyText);
//       final msg = (j['message'] ?? '').toString().toLowerCase();
//       return msg.contains('blocked');
//     } catch (_) {
//       return bodyText.toLowerCase().contains('blocked');
//     }
//   }
//
//   http.StreamedResponse _rebuildStreamed(
//       http.StreamedResponse original,
//       List<int> bodyBytes,
//       http.BaseRequest request,
//       ) {
//     return http.StreamedResponse(
//       http.ByteStream.fromBytes(bodyBytes),
//       original.statusCode,
//       request: request,
//       headers: original.headers,
//       isRedirect: original.isRedirect,
//       reasonPhrase: original.reasonPhrase,
//       persistentConnection: original.persistentConnection,
//       contentLength: bodyBytes.length,
//     );
//   }
//
//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) async {
//     final savedBody = _maybeBody(request);
//
//     await _attachAuth(request);
//     var res = await _inner.send(request);
//
//     // Capture refreshed token in common headers (if your API sets them)
//     final refreshed =
//         _getHeader(res.headers, 'x-refreshed-token') ??
//             _getHeader(res.headers, 'x-access-token') ??
//             _parseBearer(_getHeader(res.headers, 'authorization'));
//     if (refreshed != null && refreshed.isNotEmpty) {
//       await _tokenManager.saveTokens(accessToken: refreshed);
//     }
//
//     if (res.statusCode == 401) {
//       // Read body to check blocked vs expired
//       final bodyBytes = await res.stream.toBytes();
//       final bodyText = utf8.decode(bodyBytes);
//
//       // If message says blocked, treat as "forbidden" and logout immediately
//       if (_looksBlockedMessage(bodyText)) {
//         _onForbidden?.call();
//         return _rebuildStreamed(res, bodyBytes, request);
//       }
//
//       // Otherwise try a refresh (implement TokenManager._doRefresh for real refresh)
//       final ok = await _tokenManager.refreshTokenOnce();
//       if (!ok) {
//         _onUnauthorized?.call();
//         return _rebuildStreamed(res, bodyBytes, request);
//       }
//
//       // Retry once with new token
//       final retry = _clone(request, bodyBytes: savedBody);
//       await _attachAuth(retry);
//       final res2 = await _inner.send(retry);
//
//       final refreshed2 =
//           _getHeader(res2.headers, 'x-refreshed-token') ??
//               _getHeader(res2.headers, 'x-access-token') ??
//               _parseBearer(_getHeader(res2.headers, 'authorization'));
//       if (refreshed2 != null && refreshed2.isNotEmpty) {
//         await _tokenManager.saveTokens(accessToken: refreshed2);
//       }
//
//       if (res2.statusCode == 401) {
//         _onUnauthorized?.call();
//       }
//       return res2;
//     }
//
//     // If your backend ever uses 403 for blocked in other places
//     if (res.statusCode == 403) {
//       _onForbidden?.call();
//     }
//
//     return res;
//   }
// }
