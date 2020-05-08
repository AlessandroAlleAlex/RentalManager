import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/Locations/category_page.dart';
import 'list_page.dart' as list;

navigateToCategory(DocumentSnapshot indexedData, BuildContext context) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CategoryPage(passedFirestoreData: indexedData)));
}

Widget customCard(int index, AsyncSnapshot snapshot, BuildContext context) {
  return Material(
    child: InkWell(
      onTap: () => navigateToCategory(snapshot.data[index], context),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
        height: 200,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.blue,
              blurRadius: 100.0, // has the effect of softening the shadow
              spreadRadius: 0, // has the effect of extending the shadow
              offset: Offset(
                30.0, // horizontal, move right 10
                0.0, // vertical, move down 10
              ),
            )
          ],
        ),
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(snapshot.data[index].data['imageURL']),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Text(
                            snapshot.data[index].data['name'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              // color: Colors.white,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6
                                ..color = Colors.blue[700],
                            ),
                          ),
                          Text(
                            snapshot.data[index].data['name'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Stack(
                        children: <Widget>[
                          Text(
                            '>',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              // color: Colors.white,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6
                                ..color = Colors.blue[700],
                            ),
                          ),
                          Text(
                            '>',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // Icon(
                      //   Icons.keyboard_arrow_right,
                      //   color: Colors.white,
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
