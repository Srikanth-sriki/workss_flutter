// // lib/core/net.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:works_app/firebase/locator.dart';
// import 'package:works_app/core/auth_http_client.dart';
//
// http.Client get _c => locator<AuthHttpClient>();
//
// // Match common http APIs so callsites don't change:
// Future<http.Response> get(Uri url, {Map<String, String>? headers}) =>
//     _c.get(url, headers: headers);
//
// Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
//     _c.post(url, headers: headers, body: body, encoding: encoding);
//
// Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
//     _c.put(url, headers: headers, body: body, encoding: encoding);
//
// Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
//     _c.delete(url, headers: headers, body: body, encoding: encoding);
//
// Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
//     _c.patch(url, headers: headers, body: body, encoding: encoding);
//
// // If you need a Client instance:
// http.Client client() => _c;
