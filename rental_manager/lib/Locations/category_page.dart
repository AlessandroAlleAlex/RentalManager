import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_gridcell.dart';

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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Selection Page'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
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
                children: widget.passedFirestoreData.data['categories']
                    .map<Widget>((categoryInfo) {
                  return GridTile(
                    child: CustomCell(categoryInfo),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),

      // body:
      // body: Container(
      // child: FutureBuilder(
      //   future: getFirestoreData(),
      //   builder: (_, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(
      //         child: Text('Loading...'),
      //       );
      //     } else {
      //       return ListView.builder(
      //           itemCount: snapshot.data.length,
      //           itemBuilder: (BuildContext context, int index) => ListTile(
      //                 title: Text(snapshot.data[index].data['name']),
      //               ));
      //     }
      //   },
      // ),

      // widget.passedFirestoreData.data['categories']
      //     .forEach((categ) => print(categ.toString()))

      // Text(
      //     widget.passedFirestoreData.data['categories'].length.toString())

      // child: Card(
      //   child: ListTile(
      //     title:
      //         Text(widget.passedFirestoreData.data['categories'][0]['name']),
      //   ),
      // ),
      // ),
    );
  }
}
