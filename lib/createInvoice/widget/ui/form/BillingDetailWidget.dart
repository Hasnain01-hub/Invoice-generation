

import 'package:flutter/material.dart';
import 'package:invoice_gen/createInvoice/database/dao/FormDAO.dart';

//for the contractor & client details
class BillingWidget extends StatelessWidget {
  final int pageIndex;
  final Function validateController;

  final formKey = new GlobalKey<FormState>();
  BillingWidget(this.billingDetails,this.pageIndex,this.validateController);

  final BillingDetails billingDetails;

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
                "Customer Info",
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
            controller: billingDetails.companyNameTxtCtrl,
            maxLength: 20,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(labelText: "Name"),
            validator: (String? value) {
              return value!.isEmpty ? 'Name is Required' : null;
            },
            onSaved: (String? value) {
              billingDetails.companyName = value!;
              billingDetails.companyNameTxtCtrl.text = billingDetails.companyName;
            },

              onChanged: (text) {
                // TextSelection previousSelection = billingDetails.companyNameTxtCtrl.selection;
                // billingDetails.companyNameTxtCtrl.text = text;
                // billingDetails.companyNameTxtCtrl.selection = previousSelection;
                final val = TextSelection.collapsed(offset: billingDetails.companyNameTxtCtrl.text.length);
                billingDetails.companyNameTxtCtrl.selection = val;
              }
          ),
          TextFormField(
            controller: billingDetails.addressLine1TxtCtrl,
            maxLength: 10,

            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Phone No"),
            validator: (String? value) {
              return value!.isEmpty ? 'Phone No cannot be empty' : null;
            },
            onSaved: (String? value) {
              billingDetails.addressLine1 = value!;
              billingDetails.addressLine1TxtCtrl.text = billingDetails.addressLine1;
            },
              onChanged: (text) {
                // TextSelection previousSelection = billingDetails.addressLine1TxtCtrl.selection;
                // billingDetails.addressLine1TxtCtrl.text = text;
                // billingDetails.addressLine1TxtCtrl.selection = previousSelection;
                final val = TextSelection.collapsed(offset: billingDetails.addressLine1TxtCtrl.text.length);
                billingDetails.addressLine1TxtCtrl.selection = val;
              }

          ),
          TextFormField(
            controller: billingDetails.addressLine2TxtCtrl,
            maxLength: 40,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(labelText: "Address Line 1"),
            onSaved: (String? value) {
              billingDetails.addressLine2 = value!;
              billingDetails.addressLine2TxtCtrl.text = billingDetails.addressLine2;
            },
              onChanged: (text) {
                // TextSelection previousSelection = billingDetails.addressLine2TxtCtrl.selection;
                // billingDetails.addressLine2TxtCtrl.text = text;
                // billingDetails.addressLine2TxtCtrl.selection = previousSelection;
                final val = TextSelection.collapsed(offset: billingDetails.addressLine2TxtCtrl.text.length);
                billingDetails.addressLine2TxtCtrl.selection = val;
              }
          ),
          TextFormField(
            controller: billingDetails.addressLine3TxtCtrl,
            maxLength: 40,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(labelText: "Address Line 2"),
            onSaved: (String? value) {
              billingDetails.addressLine3 = value!;
              billingDetails.addressLine3TxtCtrl.text = billingDetails.addressLine3;
            },
              onChanged: (text) {
                // TextSelection previousSelection =  billingDetails.addressLine3TxtCtrl.selection;
                // billingDetails.addressLine3TxtCtrl.text = text;
                // billingDetails.addressLine3TxtCtrl.selection = previousSelection;
                final val = TextSelection.collapsed(offset: billingDetails.addressLine3TxtCtrl.text.length);
                billingDetails.addressLine3TxtCtrl.selection = val;
              }
          ),
        ],
      ),
    );
  }


}
