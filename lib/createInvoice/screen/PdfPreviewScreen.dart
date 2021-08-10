import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:invoice_gen/screens/noNetwork.dart';
import 'package:connectivity/connectivity.dart';
import 'package:invoice_gen/createInvoice/widget/transitions/PageTransistions.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:share/share.dart';
import 'InvoiceBuilderListScreen.dart';

class PdfPreviewScreen extends StatefulWidget {
  final Key key;
  final String path;
  // File file;

  PdfPreviewScreen({this.key, this.path});

  @override
  _PdfPreviewScreenState createState() => _PdfPreviewScreenState();
}


class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  StreamSubscription connectivitySubscription;
  ConnectivityResult _previousResult;
  bool dialogshown = false;

  // ignore: missing_return
  Future<bool> checkinternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return Future.value(true);
      }
    } on SocketException catch (_) {
      return Future.value(false);
    }
  }

  @override
  void initState() {
    super.initState();

    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult connresult) {
      if (connresult == ConnectivityResult.none) {
        dialogshown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:(context)=> noNetwork(),
        );
      } else if (_previousResult == ConnectivityResult.none) {
        checkinternet().then((result) {
          if (result == true) {
            if (dialogshown == true) {
              dialogshown = false;
              Navigator.pop(context);
            }
          }
        });
      }

      _previousResult = connresult;
    });
  }

  @override
  void dispose() {
    super.dispose();
    connectivitySubscription.cancel();
  }

  Future sharePdf(String filePath) async {
    Share.shareFiles(['$filePath']);
  }

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      key: widget.key,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            print("go to home page");
            Navigator.of(context).pushReplacement(SlideRightRoute(page: InvoiceBuilderListScreen()));
          },
        ),
        title: Text("PDF Preview"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share file',
            onPressed: () {
              print("download");
              sharePdf(widget.path);
            },
          ),
        ],
      ),
      path: widget.path,
    );
  }
}
  //
  // Future<String> uploadPdfToStorage() async {
  //   try {
  //     Uri file = Uri.file(widget.path);
  //
  //     // final Reference storageReference =
  //     // FirebaseStorage.instance.ref().child('pdfs');
  //
  //     Reference ref = FirebaseStorage.instance
  //         .ref()
  //         .child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');
  //     UploadTask uploadTask =
  //     ref.putFile(io.File(file.path), SettableMetadata(contentType: 'pdf'));
  //
  //     TaskSnapshot snapshot = await uploadTask;
  //
  //     String url = await snapshot.ref.getDownloadURL();
  //
  //     print("url:$url");
  //     saveItemInfo(url);
  //     return url;
  //   } catch (e) {
  //     return null;
  //   }
  // }
  //
  // saveItemInfo(String downloadUrl) async {
  //   await FirebaseFirestore.instance.collection("Invoices").doc(postId).set({
  //     "Url": downloadUrl,
  //     "User Email":Email.text,
  //   });






