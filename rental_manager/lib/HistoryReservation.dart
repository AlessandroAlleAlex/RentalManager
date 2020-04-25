import 'package:flutter/material.dart';
import 'package:rental_manager/CurrentReservation.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:rental_manager/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'globals.dart' as globals;

class HistoryReservation extends StatefulWidget {
  @override
  _HistoryReservationState createState() => _HistoryReservationState();
}

class _HistoryReservationState extends State<HistoryReservation> {
  List<globals.ReservationItem> localList = new List();

  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for the major Material Components.
    return new Scaffold(
        appBar: AppBar(
          title: Text('History Reservation', style: TextStyle(color: textcolor()),),
          backgroundColor: backgroundcolor(),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.repeat_one,
                  color: Colors.white,
                ),
            ),
          ],
          iconTheme: IconThemeData(
            color: textcolor(), //change your color here
          ),
        ),
        backgroundColor: backgroundcolor(),
        body: new SafeArea(
            child: Container(child: Column(children: <Widget>[

              Expanded(child:  ListView(
                padding: const EdgeInsets.all(20.0),
                children: _getListings(context), // <<<<< Note this change for the return type
              ),
              )
            ])
            ))
    );
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
    if(list[i].uid != globals.uid){
      continue;
    }
    print(list[i].status);
    if(list[i].status == "Returned"){

      var name = list[i].name;
      var url = list[i].imageURL;


      listings.add(
        Column(
          children: <Widget>[
            new ListTile(

              leading: CircleAvatar(
                backgroundImage: NetworkImage(url),
              ),
              //显示在title之后
              trailing: new Icon(Icons.chevron_right, color: textcolor(),),
              title: new Text(name, style: TextStyle(color: textcolor()),),
              subtitle:new Text(parseTime(list[i].startTime), style: TextStyle(color: textcolor()),) ,
              onTap: (){
                String value = itemInfo(list[i]);
                //Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryReservation()));
                PlatformAlertDialog(
                  title: 'Item Information',
                  content: value,
                  defaultActionText: Strings.ok,
                ).show(context);

              },

            ),
            Divider(height: 2.0, color: textcolor(),),
          ],
        ),

      );
    }
  }
  return listings;
}


String itemInfo(globals.ReservationItem item){
  String ret;
  ret = 'Item Name:' + item.name + '\n';
  ret += 'Item Amount: ' + item.amount + '\n';
  ret += 'Item Status: ' + item.status + '\n';
  ret += 'Item Start Time: ' + item.startTime + '\n';
  ret += 'Item End Tiem: ' + item.endTime + '\n';
  return ret;
}