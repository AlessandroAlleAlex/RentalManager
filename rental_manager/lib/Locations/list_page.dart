import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/language.dart';
import '../globals.dart' as globals;
import 'package:firebase_storage/firebase_storage.dart';
import '../Locations/category_page.dart';
import 'custom_location_card.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ListPageState();
  }
}

class _ListPageState extends State<ListPage> {
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   setManager();
  // }

  // Future setManager() {}

  Future getFirestoreData() async {
    final firestore = Firestore.instance;
    print('${globals.organization} ---------------------------');
    QuerySnapshot arrayOfLocationDocuments =
        await firestore.collection(returnLocationsCollection()).getDocuments();
    return arrayOfLocationDocuments.documents;
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
              child: Text(langaugeSetFunc('Loading...')),
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) =>
                    customCard(index, snapshot, context));
          }
        },
      ),
    );
  }
}
