import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'Locations/show_all.dart';
import 'language.dart';

class LocationManager extends StatefulWidget {
  String uid;
  String name;
  LocationManager({this.uid, this.name});
  @override
  _LocationManagerState createState() => _LocationManagerState();
}

class _LocationManagerState extends State<LocationManager> {
  Future setLocationManager(String locationSelected) {
    return Firestore.instance
        .collection('global_users')
        .document(widget.uid)
        .updateData({'LocationManager': locationSelected});
  }

  Future _dialog(BuildContext context, String locationName) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Added Successfully',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            content: Text('${widget.name} is now $locationName\'s manager.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Done',
                      style: TextStyle(fontWeight: FontWeight.bold)))
            ],
          );
        });
  }

  Widget locationManagerCustomCard(
      int index, AsyncSnapshot snapshot, BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          // navigateToCategory(snapshot.data[index], context);
          // print(snapshot.data[index]['name']);
          setLocationManager(snapshot.data[index]['name']).whenComplete(() {
            globals.locationManager = snapshot.data[index]['name'];
            _dialog(context, snapshot.data[index]['name']).whenComplete(() {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          });
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
          height: 140,
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

  Future getFirestoreData() async {
    final firestore = Firestore.instance;
    QuerySnapshot arrayOfLocationDocuments =
        await firestore.collection(returnLocationsCollection()).getDocuments();
    return arrayOfLocationDocuments.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Manager Selection:'),
      ),
      body: FutureBuilder(
        future: getFirestoreData(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text(langaugeSetFunc('Loading...')),
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) =>
                    locationManagerCustomCard(index, snapshot, context));
          }
        },
      ),
    );
  }
}
