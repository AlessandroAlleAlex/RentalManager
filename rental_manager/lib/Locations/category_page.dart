import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_gridcell.dart';
import 'item_page.dart';
import 'show_all.dart';

class CategoryPage extends StatefulWidget {
  final DocumentSnapshot passedFirestoreData;
  CategoryPage({this.passedFirestoreData});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return _CategoryPageState();
  }
}

class _CategoryPageState extends State<CategoryPage> {
  navigateToItem(String categorySelected) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemPage(category: categorySelected),
      ),
    );
  }

  displayGrids(data) {
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

  navToShowAll() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => showAll()));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // print(widget.passedFirestoreData.data['categories']);
    return Scaffold(
      appBar: AppBar(
        title: Text('Category'),
        backgroundColor: Colors.teal,
        // automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: FlatButton(
              onPressed: () {
                navToShowAll();
                // displayGrids(fetchAll());
              },
              child: Text(
                'show all',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: displayGrids(widget.passedFirestoreData.data['categories']),
    );
  }
}
