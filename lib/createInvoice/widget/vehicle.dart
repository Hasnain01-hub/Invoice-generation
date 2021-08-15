import 'package:flutter/material.dart';
import 'package:invoice_gen/createInvoice/database/dao/FormDAO.dart';

//for the contractor & client details
class vehicleWidget extends StatelessWidget {
  final int pageIndex;
  final Function validateController;

  final formKey = new GlobalKey<FormState>();
  vehicleWidget(this.vehicleDetails,this.pageIndex,this.validateController);

  final VehicleDetails vehicleDetails;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      onChanged: () {
        if (formKey.currentState!.validate()) {
          validateController(pageIndex,false);
          formKey.currentState!.save();
        }
        else {
          //prevent procced to next page if validation is not successful
          validateController(pageIndex,true);
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20,bottom: 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Service Info",
                textAlign: TextAlign.left,
                style: TextStyle(
                  decoration:TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          TextFormField(
            controller: vehicleDetails.vehiclenoTxtCtrl,
            maxLength: 20,
            textDirection: TextDirection.ltr,

            decoration: InputDecoration(labelText: "Service type"),
            validator: (String? value) {
              return value!.isEmpty ? 'Service Type is Required' : null;
            },

            onSaved: (String? value) {
              vehicleDetails.vehicleNo = value!;
              vehicleDetails.vehiclenoTxtCtrl.text = vehicleDetails.vehicleNo;
            },
              onChanged: (text) {
                // TextSelection previousSelection = vehicleDetails.vehiclenoTxtCtrl.selection;
                // vehicleDetails.vehiclenoTxtCtrl.text = text;
                // vehicleDetails.vehiclenoTxtCtrl.selection = previousSelection;
                final val = TextSelection.collapsed(offset:vehicleDetails.vehiclenoTxtCtrl.text.length);
                vehicleDetails.vehiclenoTxtCtrl.selection = val;
              }
          ),
          TextFormField(
            controller: vehicleDetails.modelTxtCtrl,
            maxLength: 20,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(labelText: "Service Description"),
            validator: (String? value) {
              return value!.isEmpty ? 'Service Description cannot be empty' : null;
            },
            onSaved: (String? value) {
              vehicleDetails.modelLine1 = value!;
              vehicleDetails.modelTxtCtrl.text = vehicleDetails.modelLine1;
            },
              onChanged: (text) {
                // TextSelection previousSelection = vehicleDetails.modelTxtCtrl.selection;
                // vehicleDetails.modelTxtCtrl.text = text;
                // vehicleDetails.modelTxtCtrl.selection = previousSelection;
                final val = TextSelection.collapsed(offset:vehicleDetails.modelTxtCtrl.text.length);
                vehicleDetails.modelTxtCtrl.selection = val;
              }
          ),
          // TextFormField(
          //   controller: billingDetails.addressLine2TxtCtrl,
          //   maxLength: 30,
          //   decoration: InputDecoration(labelText: "Address Line 1"),
          //   onSaved: (String value) {
          //     billingDetails.addressLine2 = value;
          //     billingDetails.addressLine2TxtCtrl.text = billingDetails.addressLine2;
          //   },
          // ),
          // TextFormField(
          //   controller: billingDetails.addressLine3TxtCtrl,
          //   maxLength: 30,
          //   decoration: InputDecoration(labelText: "Address Line 2"),
          //   onSaved: (String value) {
          //     billingDetails.addressLine3 = value;
          //     billingDetails.addressLine3TxtCtrl.text = billingDetails.addressLine3;
          //   },
          // ),
        ],
      ),
    );
  }


}
