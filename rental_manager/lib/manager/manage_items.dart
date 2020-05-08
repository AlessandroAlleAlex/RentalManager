import 'package:flutter/material.dart';

class ManageItems extends StatefulWidget {
  final data;
  ManageItems({this.data});
  @override
  _ManageItemsState createState() => _ManageItemsState();
}

class _ManageItemsState extends State<ManageItems> {
  Widget popupMenuButton() {
    return PopupMenuButton<String>(
        icon: Icon(Icons.add, size: 30.0),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(child: Text('add item'), value: 'add item'),
              PopupMenuItem(child: Text('upload items'), value: 'upload items'),
            ],
        onSelected: (val) async {
          switch (val) {
            case 'add item':
              break;
            case 'upload items':
              break;
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('manage items'),
        actions: <Widget>[
          popupMenuButton(),
        ],
      ),
      body: Center(child: Text(widget.data.toString())),
    );
  }
}
