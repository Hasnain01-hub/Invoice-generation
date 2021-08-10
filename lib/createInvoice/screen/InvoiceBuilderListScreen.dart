import 'dart:async';
import 'dart:io';

import 'package:invoice_gen/admin/adminnav.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:email_validator/email_validator.dart';

import 'package:invoice_gen/screens/noNetwork.dart';
import 'package:connectivity/connectivity.dart';

import 'package:flutter/material.dart';
import 'package:invoice_gen/createInvoice/constant/pdf/crud/PdfReader.dart';
import 'package:invoice_gen/createInvoice/database/io/IoOperations.dart';
import 'package:invoice_gen/createInvoice/database/sql/db_helper.dart';
import 'package:invoice_gen/createInvoice/database/dao/pdfDAO.dart';
import 'package:invoice_gen/createInvoice/screen/FormScreen.dart';
import 'package:invoice_gen/createInvoice/widget/ui/alertbox/ConfirmDeleteAlertBox.dart';
import 'package:invoice_gen/createInvoice/widget/ui/pdfbuilder/InvoiceOverviewWidget.dart';
import 'package:intl/intl.dart';
import 'dart:io' as io;

import 'package:uuid/uuid.dart';

class InvoiceBuilderListScreen extends StatefulWidget {
  @override
  _InvoiceBuilderListScreenState createState() =>
      _InvoiceBuilderListScreenState();
}

class _InvoiceBuilderListScreenState extends State<InvoiceBuilderListScreen> {
  Future<List<PdfDB>> pdfDbList;
  TextEditingController controller = TextEditingController();
  String newFileName;
  int currentPDFId;
  PdfDB currentPDFdb;
  String postId = Uuid().v4();
  final formKey = new GlobalKey<FormState>();
  DBHelper dbHelper;
  bool isUpdating;
  //alertbox
  bool currentState;
  StreamSubscription connectivitySubscription;
  ConnectivityResult _previousResult;
  bool dialogshown = false;

  // ignore: missing_return
  Future<bool> checkinternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return Future.value(true);
      }
    } on SocketException catch (_) {
      return Future.value(false);
    }
  }

  @override
  void initState() {
    isUpdating = false;
    refreshList();
    super.initState();

    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult connresult) {
      if (connresult == ConnectivityResult.none) {
        dialogshown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => noNetwork(),
        );
      } else if (_previousResult == ConnectivityResult.none) {
        checkinternet().then((result) {
          if (result == true) {
            if (dialogshown == true) {
              dialogshown = false;
              Navigator.pop(context);
            }
          }
        });
      }

      _previousResult = connresult;
    });
  }

  @override
  void dispose() {
    dbHelper.close();
    super.dispose();
    connectivitySubscription.cancel();
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
      pdfDbList = dbHelper.getPdfDB();
      print("refresh homepage list");
    });
    dbHelper.close();
  }

  Future<String> uploadPdfToStorage(PdfDB pdf) async {
    try {
      Uri file = Uri.file(pdf.filePath);
      // final Reference storageReference =
      // FirebaseStorage.instance.ref().child('pdfs');
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');
      UploadTask uploadTask =
          ref.putFile(io.File(file.path), SettableMetadata(contentType: 'application/pdf'));

      TaskSnapshot snapshot = await uploadTask;

      String url = await snapshot.ref.getDownloadURL();

      print("url:$url");
      saveItemInfo(url);
      return url;
    } catch (e) {
      return null;
    }
  }

  TextEditingController Email = new TextEditingController();
  TextEditingController customer_name = new TextEditingController();
  TextEditingController vehicle_no = new TextEditingController();
  TextEditingController phone_no = new TextEditingController();
  saveItemInfo(String downloadUrl) async {
    await FirebaseFirestore.instance.collection("Invoices").doc(postId).set({
      "id" : postId,
      "Url": downloadUrl,
      "User Email": Email.text,
      "Customer Name": customer_name.text,
      "Vehicle No": vehicle_no.text,
      "Phone No": phone_no.text,
      "Date": DateFormat('yyyy-MM-dd \n kk:mm:ss')
          .format(DateTime.now())
          .toString(),
    });
    setState(() {
      customer_name.clear();
      vehicle_no.clear();
      phone_no.clear();
      Email.clear();
    });
  }

  var Email_id;
  var customerName;
  var vehicle;
  var phone;
  validateUpdate() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      //IO Operations
      final newFilePath = await IoOperations.renameDocsFromDirectory(
          currentPDFdb.filePath, currentPDFdb.fileName, newFileName);
      //SQL Operations
      PdfDB d = PdfDB(currentPDFId, newFileName, newFilePath);
      dbHelper = DBHelper();
      await dbHelper.initDb();
      dbHelper.update(d);
      setState(() {
        isUpdating = false;
      });
      dbHelper.close();
    }
    clearName();
    refreshList();
  }

  deleteItemFromList(PdfDB pdf) async {
    dbHelper = DBHelper();
    await dbHelper.initDb();
    await dbHelper.delete(pdf.id);
    IoOperations.deleteDocsFromDirectory(pdf.filePath);
    refreshList();
  }

  _validateDelete(bool newState, PdfDB pdf) {
    currentState = newState;
    if (currentState) {
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
                    DataCell(Text(pdf.fileName)),
                    DataCell(
                        IconButton(
                          icon: const Icon(
                            Icons.image,
                            color: Colors.blueAccent,
                          ),
                        ), onTap: () {
                      String filePath = pdf.filePath;
                      PdfReader.navigateToPDFPage(context, filePath);
                    }),
                    DataCell(
                        IconButton(
                          icon: const Icon(
                            Icons.upload_sharp,
                            color: Colors.blueGrey,
                          ),
                        ), onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context,
                            {BuildContext popupContext}) {
                          return AlertDialog(
                            title: Text(
                              "Upload " + pdf.fileName,
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
                                            validator: (String value) {
                                              if (value.isEmpty) {
                                                return 'Enter Customer Name';
                                              }

                                              return null;
                                            },
                                            onSaved: (String value) {
                                              customerName = value;
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              labelText: 'Vehicle no',
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              hintText: 'Enter Vehicle no',
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            // keyboardType: TextInputType.visiblePassword,
                                            controller: vehicle_no,
                                            validator: (String value) {
                                              if (value.isEmpty) {
                                                return 'Enter Vehicle no';
                                              }

                                              return null;
                                            },
                                            onSaved: (String value) {
                                              vehicle = value;
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
                                            validator: (String value) {
                                              if (value.isEmpty) {
                                                return 'Enter Customer Phone No';
                                              }

                                              return null;
                                            },
                                            onSaved: (String value) {
                                              phone = value;
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              labelText: 'Customer Email ID',
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
                                                  'Enter Customer Email ID',
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            // keyboardType: TextInputType.visiblePassword,
                                            controller: Email,
                                            validator: (value) => EmailValidator
                                                    .validate(value)
                                                ? null
                                                : "Please enter a valid email",
                                            // validator: (String value) {
                                            //   if (value.isEmpty) {
                                            //     return 'User Email ID required';
                                            //   }
                                            //
                                            //   return null;
                                            // },
                                            onSaved: (String value) {
                                              Email_id = value;
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            child: Text("Submit"),
                                            onPressed: () {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                _formKey.currentState.save();
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
                                                                  'Successfully Uploaded ' +
                                                                      pdf.fileName,
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
                                              _formKey.currentState.save();
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

                      controller.text = pdf.fileName;
                    }),
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
        builder: (context, snapshot) {
          //if data exist, return data table
          if (snapshot.hasData && snapshot.data.length > 0) {
            return dataTable(snapshot.data);
          }
          //if data is null or empty list, display no information found
          if (null == snapshot.data || snapshot.data.length == 0) {
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
                      validator: (val) => val.length == 0 ? "Enter Name" : null,
                      onSaved: (val) => assignFileName(val),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: adminnav(),
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
    );
  }
}