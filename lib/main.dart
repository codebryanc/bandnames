import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bandnames/pages/home.dart';
import 'package:bandnames/pages/status.dart';
import 'package:bandnames/services/socket.dart';

void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketService() )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: 'home',
        routes: {
          'home': ( _ ) => HomePage(),
          'status': ( _ ) => StatusPage(),
        },
      ),
    );
  }
}