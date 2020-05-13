import 'package:flutter/material.dart';
import 'package:rental_manager/HistoryReservation.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/QRCode/generate.dart';

import 'package:rental_manager/data.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/languageSet.dart';
import 'package:rental_manager/main.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../globals.dart' as globals;
import 'package:rental_manager/editProfile.dart';
import 'package:rental_manager/CurrentReservation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'map.dart';
import 'package:rental_manager/changeColor.dart';
ProgressDialog pr;

Future<List<globals.ReservationItem>> setData() async{
  List<globals.ReservationItem> itemList = new List();

  final QuerySnapshot result =
  await Firestore.instance.collection(returnReservationCollection()).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  List<globals.ReservationItem> reservationList = new List();
  int count = 0;
  documents.forEach((ds) => reservationList.add(globals.ReservationItem(ds["amount"],
    ds["startTime"],
    ds["endTime"],
    ds["item"],
    ds["status"],
    ds["uid"],
    ds["name"],
    ds["imageURL"],
    ds.documentID,
  )
  ));

  return reservationList;
}

class FourthTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
    pr.style(message: 'Showing some progress...');
    pr.style(
      message: 'Please wait...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    var screenwidth = MediaQuery.of(context).size.width;
    Color accountBackgroundColor(){
      if(globals.dark == true){
        return Colors.black;
      }else{
        return Colors.white;
      }
    }



    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Rental Manager",
            style:  TextStyle(
              fontFamily: 'Pacifico',
              color: textcolor()
              // backgroundColor: Colors.teal,
            ),
          ),

          backgroundColor: backgroundcolor(),
        ),
        backgroundColor: backgroundcolor(),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: globals.UserImageUrl == ""? AssetImage('images/appstore.png'): NetworkImage(globals.UserImageUrl),
                  ),
                  Text(
                    globals.username,
                    style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      color: textcolor(),
                      fontSize: 20,
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),

              Row(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                    width: 170,
                    child: Divider(
                      color: Colors.teal.shade100,
                    ),
                  ),
                ],
              ),
              Container(
                padding:EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: accountBackgroundColor(),
                child: FlatButton(
                  onPressed: () async{
                    await pr.show();

                    var mylist = await setData();
                    globals.itemList = mylist;

                    pr.hide();
                    print(mylist.length.toString());
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CureentReservation()));
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.book,
                            color: textcolor(),
                          ),
                          Text(
                              langaugeSetFunc('Orders'),
                              style: TextStyle(
                                fontSize: 20,
                                color: textcolor(),
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                          Text(
                              '>>',
                              style: TextStyle(
                                fontSize: 20,
                                color: textcolor(),
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 1,
                    width: screenwidth,
                    child: Divider(
                      color: backgroundcolor(),
                    ),
                  ),
                ],
              ),
              Container(
                padding:EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: accountBackgroundColor(),
                child: FlatButton(
                  onPressed: () async{
                    await pr.show();

                    var mylist = await setData();
                    globals.itemList = mylist;
                    pr.hide();
                    print(mylist.length.toString());
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryReservation()));
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.history ,
                            color: textcolor(),
                          ),
                          Text(
                              langaugeSetFunc('History'),
                              style: TextStyle(
                                fontSize: 20,
                                color: textcolor(),
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                          Text(
                              '>>',
                              style: TextStyle(
                                fontSize: 20,
                                color: textcolor(),
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 1,
                    width: screenwidth,
                    child: Divider(
                      color: backgroundcolor(),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: accountBackgroundColor(),
                child: FlatButton(
                  onPressed: (){

                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
                  },

                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.account_circle,
                            color: textcolor(),
                          ),
                          Text(
                            langaugeSetFunc('Account Details'),
                            style: TextStyle(
                              fontSize: 20,
                              color: textcolor(),
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                          Text(
                            '>>',
                            style: TextStyle(
                              fontSize: 20,
                              color: textcolor(),
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 1,
                    width: screenwidth,
                    child: Divider(
                      color: backgroundcolor(),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(0.6),
                margin: EdgeInsets.only(),
                color: accountBackgroundColor(),
                child: FlatButton(
                  onPressed: (){
                    print("Theme Color");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => changeColor()));
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.wb_sunny,
                            color: textcolor(),
                          ),
                          Text(
                            langaugeSetFunc('Theme Color'),
                            style: TextStyle(
                              fontSize: 20,
                              color: textcolor(),
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                          Text(
                            '>>',
                            style: TextStyle(
                              fontSize: 20,
                              color: textcolor(),
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 1,
                    width: screenwidth,
                    child: Divider(
                      color: backgroundcolor(),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(0.6),
                margin: EdgeInsets.only(),
                color: accountBackgroundColor(),
                child: FlatButton(
                  onPressed: (){

                    Navigator.push(context, MaterialPageRoute(builder: (context) => languageSetting()));
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.translate,
                            color: textcolor(),
                          ),
                          Text(
                            langaugeSetFunc('Language Setting'),
                            style: TextStyle(
                              fontSize: 20,
                              color: textcolor(),
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                          Text(
                            '>>',
                            style: TextStyle(
                              fontSize: 20,
                              color: textcolor(),
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 1,
                    width: screenwidth,
                    child: Divider(
                      color: backgroundcolor(),
                    ),
                  ),
                ],
              ),
              Container(
                padding:EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: accountBackgroundColor(),
                child: FlatButton(
                  onPressed: () async{
                    print('Log out');
                    await pr.show();

                    Future.delayed(Duration(seconds: 2)).then((onValue){
                    });
                    var prefs = await SharedPreferences.getInstance();
                    prefs.remove("user");
                    pr.hide();
                    Navigator.of(context).pushNamedAndRemoveUntil('/LoginScreen', (Route route) => false);
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                    print(context);
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.exit_to_app ,
                            color: textcolor(),
                          ),
                          Text(
                             langaugeSetFunc('Log Out'),
                              style: TextStyle(
                                fontSize: 20,
                                color: textcolor(),
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                          Text(
                              '>>',
                              style: TextStyle(
                                fontSize: 20,
                                color: textcolor(),
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 1,
                    width: screenwidth,
                    child: Divider(
                      color: backgroundcolor(),
                    ),
                  ),
                ],
              ),
              Container(
                padding:EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: accountBackgroundColor(),
                child: FlatButton(
                  onPressed: () async{
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GenerateScreen()));
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.perm_identity,
                            color: textcolor(),
                          ),
                          Text(
                              langaugeSetFunc('QR Code'),
                              style: TextStyle(
                                fontSize: 20,
                                color: textcolor(),
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                          Text(
                              '>>',
                              style: TextStyle(
                                fontSize: 20,
                                color: textcolor(),
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              children: <Widget>[
                SizedBox(
                  height: 1,
                  width: screenwidth,
                  child: Divider(
                    color: backgroundcolor(),
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}

//Future<List<globals.ReservationItem>> setDataNew() async{
//  List<globals.ReservationItem> itemList = new List();
//
//  final QuerySnapshot result =
//  await Firestore.instance.collection('reservation').getDocuments();
//  final List<DocumentSnapshot> documents = result.documents;
//  List<String> reservationList = [];
//  documents.forEach((data) => reservationList.add(data.documentID));
//
//  for(var i = 0; i < reservationList.length; i++){
//    String currentOne = reservationList[i];
//
//
//    await Firestore.instance
//        .collection('reservation')
//        .document('$currentOne')
//        .get()
//        .then((DocumentSnapshot ds) {
//      // use ds as a snapshot
//      var item = new globals.ReservationItem(
//        ds["amount"],
//        ds["startTime"],
//        ds["endTime"],
//        ds["item"],
//        ds["status"],
//        ds["uid"],
//      );
//      item.name = ds["name"];
//      item.imageURL = ds["imageURL"];
//
//      itemList.add(item);
//    });
//    var index = itemList.length;
//
//    if(itemList[index - 1 ].imageURL != null){
//      print('URL: ' +  itemList[index - 1 ].imageURL);
//    }else{
//      itemList[index - 1 ].imageURL = "www.google.com";
//    }
//
//
//  }
//
//  for(int i = 0; i < itemList.length; i++){
//    print("URL:" + itemList[i].imageURL);
//  }
//
//  return itemList;
//}