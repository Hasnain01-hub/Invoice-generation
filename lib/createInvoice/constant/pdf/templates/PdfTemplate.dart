import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as widgets;
import 'package:flutter/services.dart' show rootBundle;
import 'package:invoice_gen/createInvoice/database/dao/FormDAO.dart';
import 'package:invoice_gen/createInvoice/widget/pdf/InvoicePageWidget.dart';
import 'package:intl/intl.dart';


class PdfTemplate {
  static _validateNullText(String text) {
    return text != null ? text : "";
  }

  static _buildServicesList(
      List<List<String>> list, OverallInvoice overallInvoice) {
    int length = overallInvoice.serviceDetails!.length;
    int counter = 0;
    double total = 0;
    if (length > 0) {
      overallInvoice.serviceDetails!.forEach((element) {
        double nettPrice;
        counter++;
        try {
          total += double.parse(element.nettPrice);
          nettPrice = double.parse(element.nettPrice);
        } on Exception {
          nettPrice = 0.00;
          print("unable to parse service no: $counter");
        }

        list.add([
          counter.toString(),
          element.serviceName.toString(),
          "${nettPrice.toString()}"
          //   NumberFormat.currency(symbol:'₹').format(nettPrice),
        ]);
      });

      return total;
    } else {
      return 0.00;
    }
  }

  static void pdfWriter(
      OverallInvoice? overallInvoice, widgets.Document pdf) async {
    final ByteData bytes = await rootBundle.load("assets/images/Invoice_header.jpg");
    final headerImage = PdfImage.file(
      pdf.document,

      bytes: bytes.buffer.asUint8List(),
    );

    //Image stamp


    final List<List<String>> servicesList = [];
    servicesList.add(["No", "Service", "Total Price"]);
    double totalAmountToPay = _buildServicesList(servicesList, overallInvoice!);
    // String postId = Uuid().v4();
    // var custom_length_id = nanoid('INV',4);
    var id= customAlphabet('456798123',2);
    var rng = new Random();

    const twoCm = 2.0 * PdfPageFormat.cm;

    pdf.addPage(
      InvoicePage(
        //manage the position of the header from this page
        margin: widgets.EdgeInsets.only(
            left: twoCm, top: 10 * PdfPageFormat.cm, right: twoCm),
        headerImage: headerImage,
        build: (widgets.Context context) => widgets.Column(
          children: <widgets.Widget>[
            widgets.Text(
              "Invoice",
              style: widgets.TextStyle(
                  fontSize: 36, fontWeight: widgets.FontWeight.bold),
            ),
            widgets.Row(
              mainAxisAlignment: widgets.MainAxisAlignment.center,
              children: <widgets.Widget>[
                widgets.Text(
                  "Bill-No: ",
                  style: widgets.TextStyle(
                    fontSize: 24.0,
                  ),
                ),
                widgets.Padding(
                  padding: const widgets.EdgeInsets.only(top: 2),
                  child: widgets.Text(
                      _validateNullText(
                          id+rng.nextInt(1000).toString()),
                      style: widgets.TextStyle(
                          fontSize: 20.0,
                          fontWeight: widgets.FontWeight.normal)),
                ),
              ],
            ),
            widgets.Row(
              mainAxisAlignment: widgets.MainAxisAlignment.center,
              children: <widgets.Widget>[
                widgets.Text(
                  "Date of issue: ",
                  style: widgets.TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                widgets.Padding(
                  padding: const widgets.EdgeInsets.only(top: 2),
                  child: widgets.Text(
                      _validateNullText(
                          overallInvoice!.invoiceDetails!.dateOfIssue!.doi ?? ""),
                      style: widgets.TextStyle(
                          fontSize: 14.0,
                          fontWeight: widgets.FontWeight.normal)),
                ),
              ],
            ),
            widgets.Row(
              mainAxisAlignment: widgets.MainAxisAlignment.center,
              children: <widgets.Widget>[
                widgets.Text(
                  "Date Of Service: ",
                  style: widgets.TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                widgets.Padding(
                  padding: const widgets.EdgeInsets.only(top: 2),
                  child: widgets.Text(
                      "${_validateNullText(overallInvoice.invoiceDetails!.dateOfService!.firstDate ?? "")}" +
                          " - ${_validateNullText(overallInvoice.invoiceDetails!.dateOfService!.lastDate ??"")}",
                      style: widgets.TextStyle(
                          fontSize: 14.0,
                          fontWeight: widgets.FontWeight.normal)),
                ),
              ],
            ),
            widgets.SizedBox(height: 2.0 * PdfPageFormat.cm),
            widgets.Row(
              mainAxisAlignment: widgets.MainAxisAlignment.spaceBetween,
              children: <widgets.Widget>[
                widgets.Column(
                    crossAxisAlignment: widgets.CrossAxisAlignment.start,
                    children: <widgets.Widget>[
                      widgets.Text(
                        "Customer Info",
                        style: widgets.TextStyle(
                            fontWeight: widgets.FontWeight.bold,
                            decoration: widgets.TextDecoration.underline),
                      ),
                      widgets.Text(
                        "Name: " +
                            _validateNullText(
                                overallInvoice.contractorDetails!.companyName ??""),
                      ),
                      widgets.Text(
                        "Phone no: " +
                            _validateNullText(
                                overallInvoice.contractorDetails!.addressLine1 ??""),
                      ),
                      widgets.Text(
                        "Address: " +
                            _validateNullText(
                                overallInvoice.contractorDetails!.addressLine2 ??""),
                      ),
                      widgets.Text(
                        _validateNullText(
                            overallInvoice.contractorDetails!.addressLine3 ??""),
                      ),
                    ]),
                widgets.Column(
                    crossAxisAlignment: widgets.CrossAxisAlignment.start,
                    children: <widgets.Widget>[
                      widgets.Text(
                        "Service Info",
                        style: widgets.TextStyle(
                            fontWeight: widgets.FontWeight.bold,
                            decoration: widgets.TextDecoration.underline),
                      ),
                      widgets.Text(
                        "Service Type: " +
                            _validateNullText(
                                overallInvoice.clientDetails!.vehicleNo ??""),
                      ),
                      widgets.Text(
                        "Service desc: " +
                            _validateNullText(
                                overallInvoice.clientDetails!.modelLine1 ??""),
                      ),
                      // widgets.Text(
                      //   _validateNullText(overallInvoice.clientDetails.addressLine2),
                      // ),
                      // widgets.Text(
                      //   _validateNullText(overallInvoice.clientDetails.addressLine3),
                      // ),
                    ]),
              ],
            ),
            widgets.SizedBox(height: 1.5 * PdfPageFormat.cm),
            widgets.Table.fromTextArray(context: context, data: servicesList),
            widgets.SizedBox(height: 0.5 * PdfPageFormat.cm),
            widgets.Row(children: <widgets.Widget>[
              widgets.Expanded(child: widgets.Container()),
              widgets.Row(
                mainAxisAlignment: widgets.MainAxisAlignment.center,
                children: <widgets.Widget>[
                  widgets.Text(
                    "Total: Rs ",
                    style: widgets.TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  widgets.Padding(
                    padding: const widgets.EdgeInsets.only(top: 2),
                    child: widgets.Text("${totalAmountToPay.toString()}",
                        style: widgets.TextStyle(
                            fontSize: 18.0,
                            fontWeight: widgets.FontWeight.bold)),
                  ),
                ],
              ),
            ]),
            //   widgets.SizedBox(height: 1.0 * PdfPageFormat.cm),
            //
            // widgets.Row(
            //     mainAxisAlignment: widgets.MainAxisAlignment.spaceBetween,
            //     children: <widgets.Widget>[
            //       widgets.Column(
            //         children: <widgets.Widget>[
            //           widgets.Container(
            //             width: 4.0 * PdfPageFormat.cm,
            //             ),
            //
            //           ),
            //           widgets.Image(stimage)
            //         ],
            //       ),
            //       widgets.Column(
            //         children: <widgets.Widget>[
            //           widgets.Container(
            //             width: 4.0 * PdfPageFormat.cm,
            //             decoration: widgets.BoxDecoration(
            //                 border: widgets.BoxBorder(top: true)),
            //           ),
            //           widgets.Text(
            //             "Seller",
            //           ),
            //         ],
            //       )
            //     ]
            // ),
          ],
        ),

      ),
    );
  }
}
