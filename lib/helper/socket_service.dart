import 'package:socket_io_client/socket_io_client.dart' as io;

import '../components/config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  late io.Socket socket;

  SocketService._internal() {
    _initializeSocket();
  }

  void _initializeSocket() {
    socket = io.io('https://43.204.94.146', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });

    socket.onConnect((_) {
      print("Connected to WebSocket");
      socket.emit("connected", Config.id);
    });

    socket.onDisconnect((_) {
      print("Disconnected from WebSocket");
    });

    socket.onError((error) {
      print("WebSocket Error: $error");
    });

    socket.onReconnect((_) {
      print("Reconnected to WebSocket");
      socket.emit("connected", Config.id);
    });
  }

  void sendMessage(String event, dynamic data) {
    socket.emit(event, data);
  }

  void listen(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void disconnect() {
    socket.disconnect();
  }

  void reconnect() {
    if (!socket.connected) {
      socket.connect();
    }
  }
}
