// @dart=2.9
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'createInvoice/screen/FormScreen.dart';
import 'createInvoice/screen/InvoiceBuilderListScreen.dart';

Future<void> main() async {
  {

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      if (kReleaseMode)
        exit(1);
    };
  }
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice Generation',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: "/",
      routes: {
        FormScreen.routeName: (ctx) => FormScreen(),
      },

      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
      // initialRoute: initialScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  Widget build(BuildContext context) {
    return InvoiceBuilderListScreen();
  }
}
