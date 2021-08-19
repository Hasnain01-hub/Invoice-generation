import 'package:flutter/material.dart';
import 'package:invoice_gen/createInvoice/widget/vehicle.dart';

class InvoiceDetails {
  TextEditingController invoiceNoTxtCtrl = new TextEditingController();

  String? invoiceNumber;
  DateOfIssue? dateOfIssue = new DateOfIssue.empty();
  DateOfService? dateOfService= new DateOfService.empty();

  printContent() {
    print("invoice number: " + invoiceNumber.toString());
    dateOfIssue!.printContent();
    dateOfService!.printContent();
  }

}

class BillingDetails {
  TextEditingController companyNameTxtCtrl = new TextEditingController();
  TextEditingController addressLine1TxtCtrl = new TextEditingController();
  TextEditingController addressLine2TxtCtrl = new TextEditingController();
  TextEditingController addressLine3TxtCtrl = new TextEditingController();

  late String companyName;
  late String addressLine1;
  late String addressLine2;
  late String addressLine3;

  printContent() {
        print("billing company name: " + companyName.toString());

      print("billing address 1: " + addressLine1.toString());
      print("billing address 2: " + addressLine2.toString());
      print("billing address 3: " + addressLine3.toString());
    }

}
class VehicleDetails {
  TextEditingController vehiclenoTxtCtrl = new TextEditingController();
  TextEditingController modelTxtCtrl = new TextEditingController();
  TextEditingController Notice = new TextEditingController();

  late String vehicleNo;
  late String modelLine1;
  late String notice;
  printContent() {
    print("my vehicle no: " + vehicleNo.toString());

    print("Model no: " + modelLine1.toString());
    print("Model no: " + Notice.toString());
  }

}

class ServiceDetails {
  TextEditingController serviceNameTxtCtrl = new TextEditingController();
  TextEditingController nettPriceTxtCtrl = new TextEditingController();

  static int serviceIdCounter = 0;
  int? _serviceId;
  String? serviceName;
  String nettPrice = "0.00";

  ServiceDetails(this.serviceName, this.nettPrice) {
    _serviceId = incrementServiceIdCounter();
    nettPriceTxtCtrl.text = "0.00";
  }

  incrementServiceIdCounter() {
    return serviceIdCounter += 1;
  }

  int? get serviceId => _serviceId;

  printContent() {
    print("service name: " + serviceName!);
    print("nett price: " + nettPrice);
  }

}

class OverallInvoice {
  InvoiceDetails? invoiceDetails;
  BillingDetails? contractorDetails;
  VehicleDetails? clientDetails;
  List<ServiceDetails>? serviceDetails;

  OverallInvoice() {
    invoiceDetails = new InvoiceDetails();
    contractorDetails = new BillingDetails();
    clientDetails = new VehicleDetails();
    serviceDetails = [];

    serviceDetails!.add(ServiceDetails("", "0.00"));
  }

  void printContent() {
    _getAllServiceDetailsToPrint(){
      int counter = 0;
      serviceDetails!.forEach((element) {
        counter = counter + 1;
        print("service detail $counter");
        element.printContent();
      });
    }

    invoiceDetails!.printContent();
    contractorDetails!.printContent();
    clientDetails!.printContent();
    _getAllServiceDetailsToPrint();
  }

}

class DateOfIssue {
  TextEditingController dateOfIssueCtrl = new TextEditingController();

  String? doi;

  DateOfIssue.empty(){
    dateOfIssueCtrl.text = this.doi ??"";
  }

  DateOfIssue({this.doi}){
    dateOfIssueCtrl.text = this.doi!;
  }

  printContent() {
    print("--- date of issue ---");
    print("date of issue: " + doi.toString());
  }

}

class DateOfService {
  TextEditingController firstDateTxtCtrl = new TextEditingController();
  TextEditingController lastDateTxtCtrl = new TextEditingController();

  String? firstDate;
  String? lastDate;

  DateOfService.empty(){
    firstDateTxtCtrl.text = this.firstDate as String;
    lastDateTxtCtrl.text = this.lastDate as String;
  }

  DateOfService({required this.firstDate, required this.lastDate}){
    firstDateTxtCtrl.text = this.firstDate!;
    lastDateTxtCtrl.text = this.lastDate!;
  }

  printContent() {
    print("--- date of service ---");
    print("first date: " + firstDate.toString());
    print("last date: " + lastDate.toString());
  }

}

