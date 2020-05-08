import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/Locations/custom_location_card.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/manager/manage_category.dart';

class ManageLocations extends StatefulWidget {
  @override
  _ManageLocationsState createState() => _ManageLocationsState();
}

class _ManageLocationsState extends State<ManageLocations> {
  final firestore = Firestore.instance.collection(returnLocationsCollection());

  Widget popupMenuButton() {
    return PopupMenuButton<String>(
        icon: Icon(Icons.add, size: 30.0),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(child: Text('add location'), value: 'add location'),
              PopupMenuItem(
                  child: Text('upload locations'), value: 'upload locations'),
            ],
        onSelected: (val) async {
          switch (val) {
            case 'add location':
              break;
            case 'upload locations':
              break;
          }
        });
  }

  void navToMangerCategory(data, BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ManageCategory(data: data)));
  }

  Widget managerLocationCard(data, context) {
    return InkWell(
      onTap: () => navToMangerCategory(data, context),
      child: Container(
        // padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
        height: 100,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.blue,
              blurRadius: 50.0, // has the effect of softening the shadow
              // spreadRadius: 0, // has the effect of extending the shadow
              // offset: Offset(
              //   10.0, // horizontal, move right 10
              //   0.0, // vertical, move down 10
              // ),
            )
          ],
        ),
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(data['imageURL']),
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
                            data['name'],
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
                            data['name'],
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
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Locations'),
        actions: <Widget>[
          popupMenuButton(),
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: firestore.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text(
                  langaugeSetFunc('Loading...'),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return
                        // ListTile(
                        //     title: Text('${snapshot.data.documents.length}'));
                        // print(snapshot.data.documents.length);
                        managerLocationCard(
                            snapshot.data.documents[index].data, context);
                  });
            }
          },
        ),
      ),
    );
  }
}
