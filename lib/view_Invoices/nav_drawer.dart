import 'package:flutter/material.dart';
import 'package:invoice_gen/createInvoice/screen/InvoiceBuilderListScreen.dart';
import 'package:invoice_gen/view_Invoices/view_invoice.dart';
class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  _NavDrawerState createState() => _NavDrawerState();
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
    ],),
    );
  }
}
