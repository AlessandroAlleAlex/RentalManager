import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/CurrentReservation.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'globals.dart' as globals;

class HistoryReservation extends StatefulWidget {
  @override
  _HistoryReservationState createState() => _HistoryReservationState();
}

class _HistoryReservationState extends State<HistoryReservation> {
  List<globals.ReservationItem> localList = new List();
  String getSubtitle(String reservedTime, String pickupTime, String returnTime, String status){
    reservedTime = parseTime(reservedTime);
    pickupTime = parseTime(pickupTime);
    returnTime = parseTime(returnTime);
    if(status == "Reserved"){
      return status + " at " + parseTime(reservedTime);
    }else if(status ==  "Picked Up"){
      return status + " at " + parseTime(pickupTime);

    }else if(status ==  "Returned"){
      return status + " at " + parseTime(returnTime);
      return pickupTime + status;
    }
  }
  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for the major Material Components.
    if(globals.isiOS){
      return Scaffold(
          appBar:CupertinoNavigationBar(
            heroTag: "Tab4History Reservation'",
            transitionBetweenRoutes: false,
            middle:Text(langaugeSetFunc('History Reservation'), style: TextStyle(color: textcolor()),),

            backgroundColor: backgroundcolor(),
          ),
          backgroundColor: backgroundcolor(),
          body:StreamBuilder(
              stream: Firestore.instance
                  .collection(returnReservationCollection()).where('uid', isEqualTo: globals.uid).where('status', isEqualTo: "Returned")
                  .snapshots(),
              builder: (context, snapshot){
                List<DocumentSnapshot> documents = [];
                try {
                  documents = snapshot.data.documents;
                } catch (e) {
                  print(e.toString());
                }
                return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, i){
                      return Column(
                        children: <Widget>[
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(documents[i]["imageURL"]),
                            ),
                            title: Text(documents[i]["name"], style: TextStyle(color: textcolor())),
                            subtitle: Text( getSubtitle(documents[i]["reserved time"], documents[i]["picked Up time"], documents[i]["return time"],
                                documents[i]["status"]
                            ), style: TextStyle(color: textcolor()) ),
                            trailing: Icon(CupertinoIcons.right_chevron),
                            onTap: (){
                             if(globals.isAdmin || globals.locationManager.isNotEmpty){
                               Navigator.push(context,
                                   MaterialPageRoute(builder: (context) => Ticket(documents[i]))
                               );
                             }else{
                               var ds = documents[i].data;
                               String ret;
                               ret = 'Item Name:' + ds["name"] + '\n';
                               ret += 'Item Amount: ' + ds["amount"] + '\n';
                               ret += 'Item Status: ' + ds["status"] + '\n';
                               ret += 'Item Start Time: ' + ds["startTime"] + '\n';

                               pop_window("The Item Information", "$ret", context);
                             }
                            },
                          ),
                          Divider(
                            height: 2.0,
                          ),
                        ],
                      );
                    }
                );
              }
          ),
      );
    }

    return new Scaffold(
        appBar: AppBar(
          title: Text(langaugeSetFunc('History Reservation'), style: TextStyle(color: textcolor()),),
          backgroundColor: backgroundcolor(),
          actions: <Widget>[

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


bool isEarly(String a, String b) {
  var time_a = DateTime.parse(a), time_b = DateTime.parse(b);

  var difference = time_a.difference(time_b);
  return difference.isNegative;
}


List<Widget> _getListings(BuildContext context) { // <<<<< Note this change for the return type
  List listings = new List<Widget>();
  var list = globals.itemList;




  for (var i = 0; i < list.length; i++) {
    if(list[i].uid != globals.uid){
      continue;
    }

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