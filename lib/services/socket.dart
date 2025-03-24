import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketService with ChangeNotifier {

  ServerStatus _serverStatus = ServerStatus.connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {

    String serverUrl = Platform.isIOS ? '127.0.0.1' : '10.0.2.2';

    // Dart client
    _socket = IO.io('http://${serverUrl}:3000/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    _socket.onConnectError((data) {
      if(kDebugMode) {
        print('Connect Error: $data');
      }
    });

    _socket.onError((data) {
      if(kDebugMode) {
        print('Error: $data');
      }
    });
  }  
}