import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: camel_case_types
class viewPDF extends StatefulWidget {
  viewPDF({required this.customerName, required this.url});

  final String customerName;
  final String url;

  @override
  _viewPDFState createState() => _viewPDFState();
}

// ignore: camel_case_types
class _viewPDFState extends State<viewPDF> {
  int progress = 0;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.customerName,
            style: TextStyle(fontSize: 18),
          ),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              print("go to home page");
              Navigator.pop(context);
            },
          ),
          ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: widget.url != null
            ? Center(
          child: SfPdfViewer.network(
            widget.url,
              key:_pdfViewerKey,
          ),

        )
            : Center(
          child: Container(
            child: Text(
              'No Pdf Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}