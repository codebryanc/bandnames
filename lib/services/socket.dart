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

  get serverStatus => _serverStatus;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {

    String serverUrl = Platform.isIOS ? '127.0.0.1' : '10.0.2.2';

    // Dart client
    IO.Socket socket = IO.io('http://${serverUrl}:3000/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    socket.onConnectError((data) {
      if(kDebugMode) {
        print('Connect Error: $data');
      }
    });

    socket.onError((data) {
      if(kDebugMode) {
        print('Error: $data');
      }
    });

    // socket.on('nuevo-mensaje', (payload) {
    //     print('nuevo-mensaje: $payload');        
    //     print('nuevo-mensaje: $payload[mensaje]');
    //     print('nuevo-mensaje: $payload[nombre]');
    // });


  }
  
}