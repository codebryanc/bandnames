import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bandnames/services/socket.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    SocketService socketService = Provider.of<SocketService>(context);
 
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Server status: ${socketService.serverStatus}")
          ],
        ),
      ),
    );
  }
}