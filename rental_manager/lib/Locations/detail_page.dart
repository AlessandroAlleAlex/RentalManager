import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_manager/Locations/upload_reservation.dart';
import '../globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:flutter/services.dart';

class DetailPage extends StatefulWidget {
  var itemSelected;
  DetailPage({this.itemSelected});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DetailPage();
  }
}

class _DetailPage extends State<DetailPage> {
  Container getImage() {
    return Container(
      alignment: Alignment.center,
      child: Image.network(
        widget.itemSelected.data['imageURL'],
        fit: BoxFit.cover,
        height: 300.0,
      ),
      // constraints: BoxConstraints.expand(height: 300.0),
    );
  }

  Container getDescription() {
    return Container(
      alignment: Alignment.center,
      // alignment: Alignment.topCenter,
      child: Text('some item description information...'),
    );
  }

  Container reserveButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        onPressed: () {
          // print('button pressed! (reserve)');
          uploadReservation(widget.itemSelected.documentID, context);
        },
        child: Text('Reserve Now', style: TextStyle(color: Colors.white)),
        color: Colors.teal,
      ),
    );
  }

  Container top() {
    return Container(
      // padding: EdgeInsets.only(left: 10.0),
      height: MediaQuery.of(context).size.height * 0.5,
      // width: MediaQuery.of(context).size.width * 0.5,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: NetworkImage(widget.itemSelected.data['imageURL']),
          // image: new AssetImage("drive-steering-wheel.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Text descriptionText() {
    return Text('Some Item Description???', style: TextStyle(fontSize: 18.0));
  }

  Widget amount() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 30, 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('ARC_items')
              .document(widget.itemSelected.documentID)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('loading...');
            return Text('Remaining Amount: ${snapshot.data['# of items']}',
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold));
          },
        ),
      ),
    );
  }

  Container bottom() {
    return Container(
      // height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      // color: Theme.of(context).primaryColor,
      padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 30.0),
      // padding: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: <Widget>[descriptionText(), reserveButton()],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Details of: ${widget.itemSelected.data['name']}'),
          backgroundColor: Colors.teal,
        ),
        backgroundColor: Colors.blueGrey,
        // body: Image.network(
        //   widget.itemSelected.data['imageURL'],
        // ),
        body: Scaffold(
          body: Column(
            children: <Widget>[top(), amount(), bottom()],
          ),
        ));
  }
// }
}
