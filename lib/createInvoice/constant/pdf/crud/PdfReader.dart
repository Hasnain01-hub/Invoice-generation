import 'package:flutter/material.dart';
import 'package:invoice_gen/createInvoice/screen/PdfPreviewScreen.dart';

class PdfReader {
  static void navigateToPDFPage(BuildContext context, String filePath) {
    print("### navigating to the view pdf screen ###");
    print("filePath: " + filePath.toString());

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PdfPreviewScreen(
                  path: filePath,
                )));
  }
}
