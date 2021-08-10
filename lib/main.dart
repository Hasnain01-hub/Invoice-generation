import 'dart:html';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'authentication/firebase_auth_service.dart';
import 'createInvoice/screen/InvoiceBuilderListScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
        create: (_) => FirebaseAuthService(),
        dispose: (_, AuthService authService) => authService.dispose(),
        child: MaterialApp(
  
          title: 'Car Service',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
          ),
          debugShowCheckedModeBanner: false,
  home:Scaffold(body:InvoiceBuilderListScreen(),),      
      )
      
      );
  }
}
