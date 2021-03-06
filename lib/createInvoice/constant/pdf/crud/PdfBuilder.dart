import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:invoice_gen/createInvoice/constant/pdf/crud/PdfReader.dart';
import 'package:invoice_gen/createInvoice/constant/pdf/templates/PdfTemplate.dart';
import 'package:invoice_gen/createInvoice/database/dao/FormDAO.dart';
import 'package:invoice_gen/createInvoice/database/io/IoOperations.dart';
import 'package:invoice_gen/createInvoice/database/sql/db_helper.dart';
import 'package:invoice_gen/createInvoice/database/dao/pdfDAO.dart';

class PdfBuilder {
  bool filePathAssigned = false;
  final String _fileName;
  String? _directory;
  final pw.Document _pdf = new pw.Document();
  var content;
  //SQL-STATEMENTS
  DBHelper? dbHelper;
  PdfDB? pdfDB;

  String? get fileName => _fileName;

  //only use this method to create new PDF templates and persist into database
  PdfBuilder.createPdfTemplate(this._fileName, OverallInvoice overallInvoice) {
    _writeOnPdfTemplateWriter(overallInvoice);
  }

  Future<void> _writeOnPdfTemplateWriter(OverallInvoice overallInvoice) async {
    PdfTemplate.pdfWriter(overallInvoice, _pdf);
    content = await savePdf();
    //SQL-STATEMENTS
    dbHelper = DBHelper();
    print("filename: " + _fileName.toString());
    print("directory: " + _directory.toString());
    pdfDB = PdfDB(null, _fileName, _directory);
    dbHelper!.save(pdfDB!);
    dbHelper!.close();
  }

  void navigateToPdfPage(BuildContext context) {
    String? fullPath = filePath();
    PdfReader.navigateToPDFPage(context, fullPath!);
  }

  Future savePdf() async {
    String? directory = await _tempDirectory;
    File file = new File(directory!);
    final content = _pdf.save();
    print("file saved successfully");
   file.writeAsBytesSync(await content);

    filePathAssigned = true;
    return content;
  }

  String? filePath() {
    if (_directory == null) {
      throw new Exception("file path not assigned");
    }
    return _directory;
  }

  Future<String?> get _tempDirectory async {
    _directory = await IoOperations.writeDocsIntoDirectory(_fileName);
    return _directory;
  }
}
