import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/main.dart';
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

Color textcolor() {
  if (globals.dark == false) {
    return Colors.black;
  } else {
    return Colors.white;
  }
}

List<PopupMenuItem<String>> copy_list = [];
List<String> organizationList = [];

class _LocationPageState extends State<LocationPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void abc() async {
    organizationList.clear();
    QuerySnapshot list =
        await Firestore.instance.collection('organizations').getDocuments();
    list.documents.forEach((element) {
      String str = element.data['name'];
      if (str != null && str.isNotEmpty) {
        organizationList.add(str);
      }
    });

    List<PopupMenuItem<String>> alist = [];
    organizationList.forEach((element) {
      alist.add(new PopupMenuItem(value: element, child: new Text(element)));
    });

    copy_list.clear();
    copy_list = alist;
  }

  Widget popMenuButton() {
    return new PopupMenuButton(
        icon: Icon(Icons.camera_alt),
        onSelected: (String value) async {
          setState(() {
            globals.organization = value;
          });
        },
        itemBuilder: (BuildContext context) => copy_list);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    abc();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          langaugeSetFunc('Select a Location'),
          style: TextStyle(color: textcolor()),
        ),
        backgroundColor: backgroundcolor(),
        actions: <Widget>[
          popMenuButton(),
//          IconButton(
//            icon: Icon(Icons.add),
//            onPressed: (){
//              setState(() {
//                globals.organization = "UCDavis";
//              });
//              print(globals.organization);
//            },
//          ),
        ],
      ),
      body: ListPage(),
    );
  }
}
