import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/Locations/custom_gridcell.dart';
import 'package:rental_manager/manager/manage_items.dart';

class ManageCategory extends StatefulWidget {
  final data;
  ManageCategory({this.data});

  @override
  _ManageCategoryState createState() => _ManageCategoryState();
}

class _ManageCategoryState extends State<ManageCategory> {
  Widget popupMenuButton() {
    return PopupMenuButton<String>(
        icon: Icon(Icons.add, size: 30.0),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(child: Text('add category'), value: 'add category'),
              PopupMenuItem(
                  child: Text('upload categories'), value: 'upload categories'),
            ],
        onSelected: (val) async {
          switch (val) {
            case 'add category':
              break;
            case 'upload categories':
              break;
          }
        });
  }

  navigateToItem(String categorySelected) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ManageItems(data: categorySelected)));
  }

  Widget displayGrids(data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              children: data.map<Widget>(
                (categoryInfo) {
                  return GestureDetector(
                    child: GridTile(
                      child: CustomCell(categoryInfo),
                    ),
                    onTap: () {
                      // print("tapped ${categoryInfo.toString()}");
                      navigateToItem(categoryInfo['name']);
                    },
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('manage category'),
          actions: <Widget>[
            popupMenuButton(),
          ],
        ),
        body: displayGrids(widget.data['categories']));
  }
}
