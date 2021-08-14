import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';


import 'package:invoice_gen/createInvoice/widget/transitions/PageTransistions.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:share/share.dart';
import 'InvoiceBuilderListScreen.dart';

class PdfPreviewScreen extends StatefulWidget {
  final String path;
  // File file;

  PdfPreviewScreen({ required this.path});

  @override
  _PdfPreviewScreenState createState() => _PdfPreviewScreenState();
}


class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  StreamSubscription? connectivitySubscription;
  
  bool dialogshown = false;

  // ignore: missing_return



  @override
  void dispose() {
    super.dispose();
    connectivitySubscription!.cancel();
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InvoiceBuilderListScreen()),
            );
          },
        ),
        title: Text("PDF Preview"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share file',
            onPressed: () {
              print("share file");
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






