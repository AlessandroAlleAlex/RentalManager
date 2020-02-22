import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'globals.dart' as globals;
import 'package:awesome_dialog/animated_button.dart';

import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class CureentReservation extends StatefulWidget {
  @override
  _CureentReservationState createState() => _CureentReservationState();
}

class _CureentReservationState extends State<CureentReservation> {
  List<globals.ReservationItem> localList = new List();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();
    Timer(const Duration(seconds: 1), () {
      completer.complete();
    });
    return completer.future.then<void>((_) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: const Text('Refresh complete'),
          action: SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              })));
    });
  }
  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for the major Material Components.
    return new Scaffold(
        appBar: AppBar(
          title: Text('Current Reservation'),
          backgroundColor: Colors.teal,
        ),
        body: new SafeArea(
            child: Container( child: Column(children: <Widget>[

              Expanded(child:  LiquidPullToRefresh(
                color: Colors.teal,
                key: _refreshIndicatorKey,	// key if you want to add
                onRefresh: _handleRefresh,
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: _getListings(context), // <<<<< Note this change for the return type
                ),
              ),
              )
            ])
            )));
  }

}

List<globals.ReservationItem> globallList = new List();

Widget _getContainer(String test, IconData icon) {
  return new Column(
    children: <Widget>[
      new ListTile(
        //显示在title之前
        leading: new Icon(icon),
        //显示在title之后
        trailing: new Icon(Icons.chevron_right),
        title: new Text(test),
        subtitle:new Text("我是subtitle") ,
      ),
      Divider(height: 2.0,),
    ],


  );
}

List _listings = new List();

class ItemNameLocation{
  String itemName;
  String imageURL;
}

List<ItemNameLocation>myList = [];

List<Widget> _getListings(BuildContext context) { // <<<<< Note this change for the return type
  List listings = new List<Widget>();
  var list = globals.itemList;


  for (var i = 0; i < list.length; i++) {
    if(list[i].status == "Picked Up"){
      var name = list[i].name;
      if(name == null){
        name = 'Error no name';
      }
      if(list[i].imageURL != null){
        print("CR: " + list[i].imageURL);
      }

      var url = list[i].imageURL;
      listings.add(
        Column(
          children: <Widget>[
            new ListTile(

              leading: CircleAvatar(
                backgroundImage: NetworkImage(url),
              ),
              //显示在title之后
              trailing: new Icon(Icons.chevron_right),
              title: new Text(name),
              subtitle:new Text(list[i].startTime) ,
              onTap: (){
                String value = itemInfo(list[i]);
                //Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryReservation()));

                AwesomeDialog(
                  context: context,
                  animType: AnimType.SCALE,
                  customHeader: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(url),
                  ),

                  tittle: 'Item Information ',
                  desc: itemInfo(list[i]),
                  btnOk: _buildFancyButtonOk(context),
                  //this is ignored
                  btnOkOnPress: () {},
                ).show();
              },
            ),
            Divider(height: 2.0,),
          ],
        ),

      );
    }
  }
  return listings;
}

String itemInfo(globals.ReservationItem item){
  String ret = '';
  ret += 'Item Name:' + item.name + '\n';
  ret += 'Item Amount: ' + item.amount + '\n';
  ret += 'Item Status: ' + item.status + '\n';
  ret += 'Item Start Time: ' + item.startTime + '\n';
  ret += 'Item End Tiem: ' + item.endTime + '\n';
  return ret;
}

_buildFancyButtonOk(BuildContext context) {
  return AnimatedButton(
    pressEvent: () {
      Navigator.of(context).pop();

    },
    text:   'Ok',
    color: Color(0xFF00CA71),

  );
}



void GetImageURL(String uid) async{
  globals.itemList.clear();
  final QuerySnapshot result =
  await Firestore.instance.collection('ARC_items').getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  List<String> itemList = [];
  documents.forEach((data) => itemList.add(data.documentID));

  for(var i = 0; i < itemList.length; i++){
    String currentOne = itemList[i];
    Firestore.instance
        .collection('reservation')
        .document('$currentOne')
        .get()
        .then((DocumentSnapshot ds) {
      // use ds as a snapshot
      if(currentOne == uid){
        ItemNameLocation aItem;
        aItem.itemName = ds["name"];
        aItem.imageURL = ds["imageURL"];
        myList.add(aItem);
      }
    });
  }

}