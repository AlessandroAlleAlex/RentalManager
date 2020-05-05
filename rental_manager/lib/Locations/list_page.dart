import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../globals.dart' as globals;
import 'package:firebase_storage/firebase_storage.dart';
import '../Locations/category_page.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ListPageState();
  }
}

class _ListPageState extends State<ListPage> {
  Future getFirestoreData() async {
    final firestore = Firestore.instance;
    print('${globals.organization} ---------------------------');
    QuerySnapshot arrayOfLocationDocuments = await firestore
        .collection(globals.organization == 'UCDavis'
            ? 'locations'
            : '${globals.organization}_locations')
        .getDocuments();
    return arrayOfLocationDocuments.documents;
  }

  navigateToCategory(DocumentSnapshot indexedData) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CategoryPage(passedFirestoreData: indexedData)));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: FutureBuilder(
        future: getFirestoreData(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text('Loading...'),
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) =>
                    customCard(index, snapshot));
          }
        },
      ),
    );
  }

  Widget customCard(int index, AsyncSnapshot snapshot) {
    return Material(
      child: InkWell(
        onTap: () => navigateToCategory(snapshot.data[index]),
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
}
