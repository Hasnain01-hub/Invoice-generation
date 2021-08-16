import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_gen/createInvoice/screen/InvoiceBuilderListScreen.dart';
import 'package:invoice_gen/view_Invoices/view_invoice.dart';



class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  _NavDrawerState createState() => _NavDrawerState();
}
final ButtonStyle style = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20) );

Future<bool> exit(BuildContext context) async{
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

Widget exitWidget(BuildContext context) {
  return Column(

    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 15,
          ),

          ElevatedButton(

            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.pinkAccent)
                ),
              ),
              textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 20.0)),

            ),
            onPressed: () {
              exit(context);
            },
            child: const Text('Exit'),
          ),

        ],
      ),
    ],
  );
}
class _NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    return  Drawer(

      child: ListView(


        children: [ListTile(
          title: const Text('Generate Invoices'),
          onTap: () {
            // Update the state of the app
            // ...
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InvoiceBuilderListScreen()),
            );
          },
        ),
          ListTile(
            title: const Text('View Invoices'),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => viewInvoices()),//
              );
            },
          ),
          // SizedBox(height: 300.0),

          SizedBox(height: 1.0, child: Container(color: Colors.black)),
          exitWidget(context),



        ],),
    );
  }
}
