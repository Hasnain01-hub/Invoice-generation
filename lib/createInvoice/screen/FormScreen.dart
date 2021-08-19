import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:invoice_gen/createInvoice/database/dao/FormDAO.dart';
import 'package:invoice_gen/createInvoice/widget/ui/alertbox/CreatePdfAlertBox.dart';
import 'package:invoice_gen/createInvoice/widget/ui/alertbox/FieldValidationAlertBox.dart';
import 'package:invoice_gen/createInvoice/widget/ui/form/BillingDetailWidget.dart';
import 'package:invoice_gen/createInvoice/widget/ui/form/InvoiceDetailWidget.dart';
import 'package:invoice_gen/createInvoice/widget/ui/form/ServiceDetailWidget.dart';
import 'package:invoice_gen/createInvoice/widget/vehicle.dart';

// ignore: must_be_immutable
class FormScreen extends StatefulWidget {
  static const routeName = '/createNewInvoice';
  String? Filename;

  String? FILEPATH;
  String? ID;
  FormScreen({this.ID, this.Filename, this.FILEPATH});
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // ignore: deprecated_member_use
  final List<Widget> list = [];

  int currentPagination = 1;
   OverallInvoice? overallInvoice;
  //errorMessage
  String? errorMessage;
  //validation controllers
  bool validateInvoiceDetail = false;
  bool validateContractorDetail = false;
  bool validateClientDetail = false;
  bool validateServiceDetail = false;
  StreamSubscription? connectivitySubscription;

  bool dialogshown = false;
  @override
  void initState() {
    super.initState();
    overallInvoice = new OverallInvoice();
    initPageDetail();
  }
  // ignore: missing_return
@override

  void toggleValidationStatus(int currentPagination, bool status) {
    switch (currentPagination) {
      case (1):
        validateInvoiceDetail = status;
        break;
      case (2):
        validateContractorDetail = status;
        break;
      case (3):
        validateClientDetail = status;
        break;
      case (4):
        validateServiceDetail = status;
        break;
    }
  }

  bool checkValidationStatus() {
    List<bool> validationItem = [
      validateInvoiceDetail,
      validateContractorDetail,
      validateClientDetail,
      validateServiceDetail
    ];

    bool result = false;
    validationItem.forEach((element) {
      if (element) {
        result = true;
      }
    });
    return result;
  }

  bool validateAllFields() {
    bool checkIfNullOrEmpty(String value) {
      if (value != null) {
        value.trim();
        return value.isEmpty;
      } else {
        return true;
      }
    }

    bool validateInvoiceDetails(InvoiceDetails? invoiceDetails) {
      bool state = false;

      if (checkIfNullOrEmpty(invoiceDetails!.invoiceNumber ?? '')) {
        state = true;
      }
      if (checkIfNullOrEmpty(invoiceDetails.dateOfIssue!.doi ??"")) {
        state = true;
      }

      //String ?? '' == String?
      // if (checkIfNullOrEmpty(invoiceDetails.dateOfService!.firstDate ??"")) {
      //   state = true;
      // }
      // if (checkIfNullOrEmpty(invoiceDetails.dateOfService!.lastDate ??"")) {
      //   state = true;
      // }
      return state;
    }

    bool validateContractorDetails(BillingDetails billingDetails) {
      bool state = false;

      if (checkIfNullOrEmpty(billingDetails.companyName)) {
        state = true;
      }
      if (checkIfNullOrEmpty(billingDetails.addressLine1)) {
        state = true;
      }

      return state;
    }

    bool validateclientDetails(VehicleDetails vehicleDetails) {
      bool state = false;

      if (checkIfNullOrEmpty(vehicleDetails.vehicleNo)) {
        state = true;
      }
      if (checkIfNullOrEmpty(vehicleDetails.modelLine1)) {
        state = true;
      }

      return state;
    }

    bool validateServiceDetails(List<ServiceDetails> serviceDetails) {
      if (serviceDetails != null) {
        if (serviceDetails.isEmpty) {
          return true;
        } else {
          bool result = false;
          serviceDetails.forEach((element) {
            print(element.serviceName);
            bool serviceState = checkIfNullOrEmpty(element.serviceName ??"");
            bool netPrice = checkIfNullOrEmpty(element.nettPrice);
            if (serviceState || netPrice) {
              print("check");
              result = true;
            }
          });
          return result;
        }
      }
      return false;
    }

    //main logic
    var buffer = new StringBuffer();
    bool state = false;

    if (overallInvoice != null) {
      InvoiceDetails? invoiceDetails = overallInvoice!.invoiceDetails;
      BillingDetails? contractorDetails = overallInvoice!.contractorDetails;
      VehicleDetails? clientDetails = overallInvoice!.clientDetails;
      List<ServiceDetails>? serviceDetails = overallInvoice!.serviceDetails;

      int counter = 0;
      if (validateInvoiceDetails(invoiceDetails)) {
        state = true;
        counter++;
        buffer.write("$counter.Invoice Details incomplete Fields.\n");
      }

      if (validateContractorDetails(contractorDetails!)) {
        state = true;
        counter++;
        buffer.write("$counter.Customer Details incomplete Fields.\n");
      }

      if (validateclientDetails(clientDetails!)) {
        state = true;
        counter++;
        buffer.write("$counter.Vehicle Details incomplete Fields.\n");
      }

      if (validateServiceDetails(serviceDetails!)) {
        state = true;
        counter++;
        buffer.write("$counter.Service Details incomplete Fields.\n");
      }

      errorMessage = buffer.toString();
      if (errorMessage!.isNotEmpty) {
        print(errorMessage);
      }
    }
    return state;
  }

  List<Widget> initPageDetail() {

    //first page open this
    list.add(InvoiceDetailWidget(
        overallInvoice?.invoiceDetails ?? InvoiceDetails(), 1, toggleValidationStatus ));
    //second page
    list.add(BillingWidget(
        overallInvoice!.contractorDetails ?? BillingDetails() , 2, toggleValidationStatus));
    //third page
    list.add(
        vehicleWidget(overallInvoice!.clientDetails ?? VehicleDetails() , 3, toggleValidationStatus));
    //fourth page
    list.add(ServiceDetailWidget(
        overallInvoice!.serviceDetails ?? [] , 4, toggleValidationStatus));

    return list;

  }

  Widget accessPageDetail(int i) {
    print("length of list is ........+${list.length}");

    return list[i] ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create a New Invoice")),
      body: ListView(

        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              pagination(1, "Invoice"),
              paginationBlocks(),
              pagination(2, "Customer"),
              paginationBlocks(),
              pagination(3, "Service"),
              paginationBlocks(),
              pagination(4, "Cost of Service"),
            ],
          ),
          Container(
            height: 420,
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
            ),
            child: Center(
              child: accessPageDetail(currentPagination - 1),
            ),
          ),
          backAndNextButton(context),
        ],
      ),
    );
  }

  void validationErrorMsg() {
    print("validation not success on page ${currentPagination.toString()}");
    print("clear validation process before proceeding");
  }

  Widget backAndNextButton(BuildContext context) {
    Expanded backButton() {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade500,
              ),
              color:
                  currentPagination != 1 ? Colors.red[700] : Colors.grey[500],
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            height: 40,
            width: double.infinity,
            // ignore: deprecated_member_use
            child: FlatButton(
              textColor: Colors.white,
              onPressed: currentPagination != 1
                  ? () {
                      //prevent page to navigate, if there is error messages not handled
                      var checkValidationMsgs = checkValidationStatus();
                      if (checkValidationMsgs) {
                        validationErrorMsg();
                      } else {
                        setState(() {
                          currentPagination--;
                        });
                      }
                    }
                  : null,
              child: Text(
                "Back",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ),
      );
    }

    Expanded nextButton() {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade500,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            height: 40,
            width: double.infinity,
            // ignore: deprecated_member_use
            child: FlatButton(
              textColor: Theme.of(context).primaryColor,
              onPressed: () {
                //prevent page to navigate, if there is error messages not handled
                var checkValidationMsgs = checkValidationStatus();
                if (checkValidationMsgs) {
                  validationErrorMsg();
                } else {
                  if (currentPagination < list.length) {
                    setState(() {
                      currentPagination++;
                    });
                  } else if (currentPagination == list.length) {
                    if (validateAllFields()) {
                      FieldValidationAlertBox.showAlertDialog(
                          context, errorMessage!);
                      errorMessage = "";
                    } else {
                      CreatePdfAlertBox.showAlertDialog(
                          context, overallInvoice!);
                      // setState(() {
                      //   Map<String, dynamic> invoice = {
                      //     "ID": widget.ID,
                      //     "FILENAME": widget.Filename,
                      //     "FILEPATH": widget.FILEPATH,
                      //
                      //   };
                      //   var firebaseUser = FirebaseAuth.instance.currentUser;
                      //   FirebaseFirestore.instance
                      //       .collection("Invoices")
                      //       .doc(firebaseUser.email)
                      //       .update({
                      //     "invoices": FieldValue.arrayUnion([ invoice ]),
                      //   });
                      // });

                      //print data to verify its content
                      overallInvoice!.printContent();
                    }
                  }
                }
              },
              child: Text(
                currentPagination == list.length ? "Proceed" : "Next",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
      child: Container(
        child: Row(
          children: [
            backButton(),
            nextButton(),
          ],
        ),
      ),
    );
  }

  Widget pagination(int number, String title) {
    var colorBox =
        number <= currentPagination ? Colors.blue : Colors.grey.shade300;
    var textBold =
        number <= currentPagination ? FontWeight.bold : FontWeight.normal;

    return GestureDetector(
      onTap: () {
        //prevent page to navigate, if there is error messages not handled
        var checkValidationMsgs = checkValidationStatus();
        if (checkValidationMsgs) {
          validationErrorMsg();
        } else {
          setState(() {
            currentPagination = number;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 7.5, right: 7.5),
        child: Column(children: [
          Container(
            width: 40,
            height: 40,
            color: colorBox,
            child: Center(
                child: Text(
              number.toString(),
              style: TextStyle(fontWeight: textBold),
            )),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10.5, fontWeight: textBold),
          ),
          Text(
            "details",
            style: TextStyle(fontSize: 12.5, fontWeight: textBold),
          ),
        ]),
      ),
    );
  }

  Widget paginationBlocks() {
    return Padding(
      padding: const EdgeInsets.only(left: 7.5, right: 7.5, bottom: 28),
      child: Container(
        width: 10,
        height: 10,
        color: Colors.grey.shade500,
      ),
    );
  }
}
