import 'dart:async';
import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:invoice_gen/view_Invoices/pdf_view.dart';

import 'nav_drawer.dart';


final CollectionReference invoiceRef =
FirebaseFirestore.instance.collection('Invoices');
String customerName = 'Customer Name : ';

String customerPhone = 'Customer Phone : ';
String date = 'Date : ';

// ignore: camel_case_types
class viewInvoices extends StatefulWidget {
  @override
  _viewInvoicesState createState() => _viewInvoicesState();
}

// ignore: camel_case_types
class _viewInvoicesState extends State<viewInvoices> {
  List userInvoiceList = [];

  bool dialogshown = false;

  // ignore: missing_return

  @override
  void initState() {
    super.initState();
    fetchDatabaseList();
      }





  fetchDatabaseList() async {
    dynamic resultant = await getsellCarList();
    if (resultant == null) {
      print('Data not Found');
    } else {
      setState(() {
        userInvoiceList = resultant;
      });
    }
  }

  // ignore: non_constant_identifier_names
  DeleteInvoice(BuildContext context, String id, String url) {
    Dialog alert = Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 240,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                child: Column(
                  children: [
                    Text(
                      'Delete Invoice',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: Text(
                        'Invoice will be deleted from database too',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Do you really want to delete Invoice ?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ignore: deprecated_member_use
                        RaisedButton(
                          color: Colors.indigo,
                          child: Text(
                            "Yes",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              invoiceRef.doc(id).delete();
                              try {
                                final Reference storage =
                                FirebaseStorage.instance.refFromURL(url);
                                storage.delete();
                              } catch (e) {
                                print(e.toString());
                                return null;
                              }
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/viewInvoice', (route) => false);
                            });
                          },
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        // ignore: deprecated_member_use
                        RaisedButton(
                          color: Colors.indigo,
                          child: Text(
                            "No",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
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
                  backgroundColor: Colors.indigo,
                  radius: 60,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 70,
                  ),
                )),
          ],
        ));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Invoices"),
        centerTitle: true,
      ),
      body: Container(
        child: ListView.builder(
            itemCount: userInvoiceList.length,
            itemBuilder: (context, index) {
              return InkWell(
                splashColor: Colors.cyan[500],
                child: Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Card(
                    elevation: 4.0,
                    child: Container(
                      height: 200.0,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 4.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 15.0,
                                ),
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(left: 10.0),
                                            child: Text(
                                              customerName +
                                                  ' ' +
                                                  userInvoiceList[index]
                                                  ['Customer Name'],

                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 20.0,
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        customerPhone +
                                            ' ' +
                                            userInvoiceList[index]['Phone No'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      // ignore: deprecated_member_use
                                    ),
                                  ],
                                ),

                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        date +
                                            ' ' +
                                            userInvoiceList[index]['Date'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      // ignore: deprecated_member_use
                                      child: RaisedButton(
                                        color: Colors.indigo,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                              Duration(seconds: 1),
                                              transitionsBuilder:
                                                  (context,
                                                  animation,
                                                  animationTime,
                                                  child) {
                                                animation = CurvedAnimation(parent: animation, curve: Curves.elasticOut);
                                                return ScaleTransition(
                                                  scale: animation,
                                                  child: child,
                                                );
                                              },
                                              pageBuilder: (context,
                                                  animation,
                                                  animationTime) {
                                                return viewPDF(
                                                  url: userInvoiceList[index]
                                                  ['Url'],
                                                  customerName:
                                                  userInvoiceList[index]
                                                  ['Customer Name'],
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "View Invoice",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      // ignore: deprecated_member_use
                                      child: RaisedButton(
                                        color: Colors.red,
                                        onPressed: () {
                                          setState(() {
                                            DeleteInvoice(
                                              context,
                                              userInvoiceList[index]['id'],
                                              userInvoiceList[index]['Url'],
                                            );
                                          });
                                        },
                                        child: Text(
                                          "Delete Invoice",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Future getsellCarList() async {
    List itemList = [];
    try {
      await invoiceRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          itemList.add(element.data());
        });
      });
      return itemList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
