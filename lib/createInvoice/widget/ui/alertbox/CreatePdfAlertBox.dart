import 'package:invoice_gen/createInvoice/screen/InvoiceBuilderListScreen.dart';
import 'package:flutter/material.dart';
import 'package:invoice_gen/createInvoice/constant/alertbox/AlertBoxContent.dart';
import 'package:invoice_gen/createInvoice/constant/pdf/crud/PdfBuilder.dart';
import 'package:invoice_gen/createInvoice/database/dao/FormDAO.dart';
import 'package:invoice_gen/createInvoice/widget/transitions/PageTransistions.dart';

class CreatePdfAlertBox {
  static List<Widget> listOfButtons = initListOfButtons();

  late CreatePdfAlertBox a1;
  void data() {}

  static List<Widget> initListOfButtons() {
    //confirm buttons
    // ignore: deprecated_member_use
    List<Widget> listOfButtons = [];
    return listOfButtons;
  }

  static Widget _cancelButton({required BuildContext context}) {
    // ignore: deprecated_member_use
    return FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  static Widget _pleaseWaitButton() {
    // ignore: deprecated_member_use
    return FlatButton(
      child: Text("Please Wait..."),
      onPressed: null,
    );
  }

  static Widget _generalButton(
      {required BuildContext context, required String title, required Function onClick}) {
    // ignore: deprecated_member_use
    return FlatButton(
      child: Text(title),
      onPressed: () {
        onClick();
      },
    );
  }

  static void showAlertDialog(
      BuildContext context, OverallInvoice? overallInvoice) {
    int buttonListSelect = 0;
    String title = AlertBoxStatus.confirm.title;
    String description = AlertBoxStatus.confirm.description;
    PdfBuilder? pdf;

    void changeToLoadingScreen(StateSetter setState) {
      setState(() {
        title = AlertBoxStatus.loading.title;
        description = AlertBoxStatus.loading.description;
        buttonListSelect = 1;
      });

      new Future.delayed(new Duration(seconds: 3), () {
        setState(() {
          pdf = PdfBuilder.createPdfTemplate(
              overallInvoice!.invoiceDetails!.invoiceNumber ?? '', overallInvoice!);
          title = AlertBoxStatus.completed.title;
          description = AlertBoxStatus.completed.description;
          buttonListSelect = 2;
        });
      });
    }

    goToHomePage(BuildContext context) {
      print("go to home page");
      Navigator.of(context)
          .pushReplacement(SlideRightRoute(page: InvoiceBuilderListScreen()));
    }

    void goToResultScreen(BuildContext context) {
      print("go to result screen");
      pdf!.navigateToPdfPage(context);
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //setup all button list

            //confirm screen
            final confirmationScreen = <Widget>[
              _cancelButton(context: context),
              _generalButton(
                context: context,
                title: "Continue",
                onClick: () => changeToLoadingScreen(setState),
              ),
            ];

            //loading screen
            final loadingScreen = <Widget>[
              _pleaseWaitButton(),
              new CircularProgressIndicator(),
              SizedBox(
                width: 5,
              )
            ];

            //completed screen
            final completedScreen = <Widget>[
              _generalButton(
                context: context,
                title: "Go Back To Main Menu",
                onClick: () => goToHomePage(context),
              ),
              _generalButton(
                context: context,
                title: "View PDF",
                onClick: () => goToResultScreen(context),
              ),
            ];

            //store in a list
            // ignore: deprecated_member_use
            final buttonList = [];
            buttonList.add(confirmationScreen);
            buttonList.add(loadingScreen);
            buttonList.add(completedScreen);

            return AlertDialog(
              title: Text(title),
              content: Text(description),
              actions: buttonList[buttonListSelect],
            );
          },
        );
      },
    );
  }
}
