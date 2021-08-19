import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_gen/createInvoice/constant/pdf/crud/PdfReader.dart';
import 'package:invoice_gen/createInvoice/database/io/IoOperations.dart';
import 'package:invoice_gen/createInvoice/database/sql/db_helper.dart';
import 'package:invoice_gen/createInvoice/database/dao/pdfDAO.dart';
import 'package:invoice_gen/createInvoice/screen/FormScreen.dart';
import 'package:invoice_gen/createInvoice/widget/ui/alertbox/ConfirmDeleteAlertBox.dart';
import 'package:invoice_gen/createInvoice/widget/ui/pdfbuilder/InvoiceOverviewWidget.dart';
import 'package:intl/intl.dart';
import 'package:invoice_gen/view_Invoices/nav_drawer.dart';
import 'dart:io' as io;

import 'package:uuid/uuid.dart';

class InvoiceBuilderListScreen extends StatefulWidget {
  @override
  _InvoiceBuilderListScreenState createState() =>
      _InvoiceBuilderListScreenState();
}

class _InvoiceBuilderListScreenState extends State<InvoiceBuilderListScreen> {
  Future<List<PdfDB>>? pdfDbList;
  TextEditingController controller = TextEditingController();
  String? newFileName;
  int? currentPDFId;
  PdfDB? currentPDFdb;
  String postId = Uuid().v4();
  final formKey = new GlobalKey<FormState>();
  DBHelper? dbHelper;
  bool isUpdating = false;
  //alertbox
  bool? currentState;
  StreamSubscription? connectivitySubscription;

  bool dialogshown = false;

  // ignore: missing_return
  @override
  void initState() {
    isUpdating = false;
    refreshList();
    super.initState();
  }
  @override
  void dispose() {
    dbHelper!.close();
    super.dispose();
    connectivitySubscription!.cancel();
  }

  assignFileName(String val) {
    newFileName = val;
  }

  clearName() {
    controller.text = "";
  }

  refreshList() {
    dbHelper = DBHelper();
    setState(() {
      pdfDbList = dbHelper!.getPdfDB();
      print("refresh homepage list");
    });
    dbHelper!.close();
  }

  Future<String?> uploadPdfToStorage(PdfDB? pdf) async {
    try {
      Uri file = Uri.file(pdf!.filePath ??'');
      // final Reference storageReference =
      // FirebaseStorage.instance.ref().child('pdfs');
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');
      UploadTask uploadTask = ref.putFile(
          io.File(file.path), SettableMetadata(contentType: 'application/pdf'));

      TaskSnapshot snapshot = await uploadTask;

      String url = await snapshot.ref.getDownloadURL();

      print("url:$url");
      saveItemInfo(url);
      return url;
    } catch (e) {
      return null;
    }
  }


  TextEditingController customer_name = new TextEditingController();

  TextEditingController phone_no = new TextEditingController();
  saveItemInfo(String downloadUrl) async {
    await FirebaseFirestore.instance.collection("Invoices").doc(postId).set({
      "id": postId,
      "Url": downloadUrl,
      "Customer Name": customer_name.text,
      "Phone No": phone_no.text,
      "Date": DateFormat('yyyy-MM-dd \n kk:mm:ss')
          .format(DateTime.now())
          .toString(),
    });
    setState(() {
      customer_name.clear();

      phone_no.clear();

    });
  }

  var Email_id;
  var customerName;
  var vehicle;
  var phone;
  validateUpdate() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      //IO Operations
      final newFilePath = await IoOperations.renameDocsFromDirectory(
          currentPDFdb!.filePath ?? '', currentPDFdb!.fileName ??'', newFileName!);
      //SQL Operations
      PdfDB d = PdfDB(currentPDFId, newFileName, newFilePath);
      dbHelper = DBHelper();
      await dbHelper!.initDb();
      dbHelper!.update(d);
      setState(() {
        isUpdating = false;
      });
      dbHelper!.close();
    }
    clearName();
    refreshList();
  }

  deleteItemFromList(PdfDB pdf) async {
    dbHelper = DBHelper();
    await dbHelper!.initDb();
    await dbHelper!.delete(pdf.id!);
    IoOperations.deleteDocsFromDirectory(pdf.filePath!);
    refreshList();
  }

  _validateDelete(bool newState, PdfDB pdf) {
    currentState = newState ;
    if (currentState!) {
      deleteItemFromList(pdf);
    } else {
      print("### item is not deleted ###");
    }
  }

  final _formKey = GlobalKey<FormState>();
  SingleChildScrollView dataTable(List<PdfDB> pdfDBList) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: 20,
        columns: [
          DataColumn(
              label: Text(
                "PDF NAME",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800]),
              )),
          DataColumn(
              label: Padding(
                padding: const EdgeInsets.only(left: 11.0),
                child: Text("VIEW"),
              )),
          DataColumn(
              label: Padding(
                padding: const EdgeInsets.only(left: 11.0),
                child: Text("Upload"),
              )),
          DataColumn(label: Text("DELETE")),
        ],
        rows: pdfDBList
            .map((pdf) => DataRow(
          cells: [
            DataCell(Text(pdf.fileName ??"")),
            DataCell(
              IconButton(
                icon: const Icon(
                  Icons.image,
                  color: Colors.blueAccent,
                ), onPressed: () {String? filePath = pdf.filePath;
              PdfReader.navigateToPDFPage(context, filePath!);  },
              ), ),
            DataCell(
              IconButton(
                icon: const Icon(
                  Icons.upload_sharp,
                  color: Colors.blueGrey,
                ), onPressed: () {                        showDialog(
                context: context,
                builder: (BuildContext context,
                    {BuildContext? popupContext}) {
                  return AlertDialog(
                    title: Text(
                      "Upload ",
                      textAlign: TextAlign.center,
                    ),
                    content: SingleChildScrollView(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Positioned(
                            right: -39.0,
                            top: -66.0,
                            child: InkResponse(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: CircleAvatar(
                                child: Icon(Icons.close),
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Customer Name',
                                      enabledBorder:
                                      UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0)),
                                      hintText: 'Enter Customer Name',
                                      hintStyle:
                                      TextStyle(color: Colors.grey),
                                    ),
                                    // keyboardType: TextInputType.visiblePassword,
                                    controller: customer_name,
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Enter Customer Name';
                                      }

                                      return null;
                                    },
                                    onSaved: (String? value) {
                                      customerName = value;
                                    },
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    maxLength: 10,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Customer Phone No',
                                      enabledBorder:
                                      UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0)),
                                      hintText:
                                      'Enter Customer Phone No',
                                      hintStyle:
                                      TextStyle(color: Colors.grey),
                                    ),
                                    // keyboardType: TextInputType.visiblePassword,
                                    controller: phone_no,
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Enter Customer Phone No';
                                      }

                                      return null;
                                    },
                                    onSaved: (String? value) {
                                      phone = value;
                                    },
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    child: Text("Submit"),
                                    onPressed: () {
                                      if (_formKey.currentState!
                                          .validate()) {
                                        _formKey.currentState!.save();
                                        print(Email_id);
                                        uploadPdfToStorage(pdf);

                                        Dialog dialog = Dialog(
                                            shape:
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    4.0)),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              alignment:
                                              Alignment.topCenter,
                                              children: [
                                                Container(
                                                  height: 200,
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .fromLTRB(
                                                        10,
                                                        70,
                                                        10,
                                                        10),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'Success !',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              fontSize:
                                                              20),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          'Successfully Uploaded ' ,
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            20,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                          children: [
                                                            // ignore: deprecated_member_use
                                                            RaisedButton(
                                                              color: Colors
                                                                  .indigo,
                                                              child:
                                                              Text(
                                                                "Ok",
                                                                style: TextStyle(
                                                                    color:
                                                                    Colors.white),
                                                              ),
                                                              onPressed:
                                                                  () {
                                                                Navigator.of(context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                    top: -60,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                      Colors.indigo,
                                                      radius: 60,
                                                      child: Icon(
                                                        Icons
                                                            .sentiment_satisfied_alt,
                                                        color: Colors
                                                            .white,
                                                        size: 70,
                                                      ),
                                                    )),
                                              ],
                                            ));

                                        showDialog(
                                            context: context,
                                            builder:
                                                (BuildContext context) {
                                              return dialog;
                                            });
                                      }
                                      _formKey.currentState!.save();
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              controller.text = pdf.fileName!;
              },
              ), ),
            DataCell(ConfirmDeleteAlertBoxButton(_validateDelete, pdf)),
          ],
        ))
            .toList(),
      ),
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: pdfDbList,
        builder: (BuildContext context,AsyncSnapshot snapshot) {
          //if data exist, return data table
          if (snapshot.hasData && snapshot.data.length > 0) {
            return dataTable(snapshot.data);
          }
          //if data is null or empty list, display no information found
          if (null == snapshot.data || snapshot.data!.length == 0) {
            return Center(child: InvoiceOverviewWidget.emptyList());
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget form() {
    return isUpdating
        ? Container(
      color: Theme.of(context).primaryColor,
      child: Form(
        key: formKey,
        child: Padding(
          padding:
          EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              TextFormField(
                style: TextStyle(
                  color: Colors.white,
                ),
                //cursorColor: Colors.white,
                controller: controller,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Change PDF Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                ),
                validator: (val) => val!.length == 0 ? "Enter Name" : null,
                onSaved: (val) => assignFileName(val!),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    onPressed: validateUpdate,
                    child: Text(
                      "UPDATE",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  FlatButton(
                    child: Text(
                      "CLOSE",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        isUpdating = false;
                      });
                      clearName();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    )
        : Container();
  }
  Future<bool> exit() async{
    return await showDialog(
      context: context,
      builder: (context) => Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                  child: Column(
                    children: [
                      Text(
                        'Do you really want to exit ?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ignore: deprecated_member_use
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            color: Colors.indigo,
                            child: Text(
                              'No',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          // ignore: deprecated_member_use
                          RaisedButton(
                            onPressed: () {
                              SystemNavigator.pop();
                            },
                            color: Colors.indigo,
                            child: Text(
                              'Yes',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: -60,
                  child: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    radius: 60,
                    child: Icon(
                      Icons.sentiment_dissatisfied_outlined,
                      color: Colors.white,
                      size: 70,
                    ),
                  )),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: exit,
      child: Scaffold(
        drawer:NavDrawer(),
        appBar: AppBar(
          title: Text("Create Invoice"),
          centerTitle: true,

        ),

        body: new Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              list(),
              form(),
            ],
          ),
        ),
        floatingActionButton: isUpdating
            ? null
            : FloatingActionButton(
          onPressed: () {
            var value = 0;
            setState(() {
              value++;
              print(value);
            });
          },
          child: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add New Invoice',
              onPressed: () {
                Navigator.pushNamed(context, FormScreen.routeName);
              }),
        ),
      ),
    );
  }
}
