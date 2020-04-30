import 'package:flutter/material.dart';
import 'package:rental_manager/language.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../Locations/list_page.dart';
import 'package:rental_manager/globals.dart' as globals;

class FirstTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationPage(title: 'Select a Location'),
    );
  }
}

class LocationPage extends StatefulWidget {
  final String title;
  LocationPage({Key key, this.title}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LocationPageState();
  }
}

Color backgroundcolor() {

  if (globals.dark == false) {
    return Colors.grey[200];
  } else {
    return Colors.black;
  }
}

Color textcolor( ) {
  if (globals.dark == false) {
    return Colors.black;
  } else {
    return Colors.white;
  }
}

class _LocationPageState extends State<LocationPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(langaugeSetFunc('Select a Location'), style: TextStyle(color: textcolor()),),
        backgroundColor: backgroundcolor(),

      ),
      body: ListPage(),
    );
  }
}
