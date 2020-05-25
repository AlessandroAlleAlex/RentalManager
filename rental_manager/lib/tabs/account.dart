import 'package:flutter/cupertino.dart';
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

Future<List<globals.ReservationItem>> setData() async {
  List<globals.ReservationItem> itemList = new List();

  final QuerySnapshot result = await Firestore.instance
      .collection(returnReservationCollection())
      .where('uid', isEqualTo: globals.uid)
      .getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  List<globals.ReservationItem> reservationList = new List();
  int count = 0;
  documents.forEach((ds) => reservationList.add(globals.ReservationItem(
        ds["amount"],
        ds["startTime"],
        ds["endTime"],
        ds["item"],
        ds["status"],
        ds["uid"],
        ds["name"],
        ds["imageURL"],
        ds.documentID,
      )));

  return reservationList;
}

class FourthTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
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
    Color accountBackgroundColor() {
      if (globals.dark == true) {
        return Colors.black;
      } else {
        return Colors.white;
      }
    }

    if (globals.isiOS) {
      return Scaffold(
        appBar: CupertinoNavigationBar(
          heroTag: "tab4Account",
          transitionBetweenRoutes: false,
          backgroundColor: backgroundcolor(),
        ),
        backgroundColor: backgroundcolor(),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 100,
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: globals.UserImageUrl == ""
                        ? AssetImage('images/appstore.png')
                        : NetworkImage(globals.UserImageUrl),
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
              Container(
                decoration: new BoxDecoration(
                  color: BoxBackground(),
                ),
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.tag,
                    color: textcolor(),
                  ),
                  title: Text(
                    langaugeSetFunc("History"),
                    style: TextStyle(color: textcolor()),
                  ),
                  trailing: Icon(
                    CupertinoIcons.right_chevron,
                    color: textcolor(),
                  ),
                  onTap: () async {
                    await pr.show();

                    var mylist = await setData();

                    List<globals.ReservationItem> sort_list = [];
                    mylist.forEach((element) {
                      sort_list.add(element);
                    });

                    for (int i = 0; i < sort_list.length - 1; i++) {
                      for (int j = 0; j < sort_list.length - i - 1; j++) {
                        var a = sort_list[j].startTime,
                            b = sort_list[j + 1].startTime;
                        if (a == null || b == null) {
                          continue;
                        }

                        if (isEarly(a, b)) {
                          var swap = sort_list[j];
                          sort_list[j] = sort_list[j + 1];
                          sort_list[j + 1] = swap;
                        }
                      }
                    }
                    globals.itemList = sort_list;

                    pr.hide();
                    print(mylist.length.toString());
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HistoryReservation()));
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: new BoxDecoration(
                  color: BoxBackground(),
                ),
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.profile_circled,
                    color: textcolor(),
                  ),
                  title: Text(
                    langaugeSetFunc("Account Details"),
                    style: TextStyle(color: textcolor()),
                  ),
                  trailing: Icon(
                    CupertinoIcons.right_chevron,
                    color: textcolor(),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EditProfile()));
                  },
                ),
              ),
              Container(
                decoration: new BoxDecoration(
                  color: BoxBackground(),
                ),
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.brightness,
                    color: textcolor(),
                  ),
                  title: Text(
                    langaugeSetFunc(("Theme Color")),
                    style: TextStyle(color: textcolor()),
                  ),
                  trailing: Icon(
                    CupertinoIcons.right_chevron,
                    color: textcolor(),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => changeColor()));
                  },
                ),
              ),
              Container(
                decoration: new BoxDecoration(
                  color: BoxBackground(),
                ),
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.gear,
                    color: textcolor(),
                  ),
                  title: Text(
                    langaugeSetFunc('Language Setting'),
                    style: TextStyle(color: textcolor()),
                  ),
                  trailing: Icon(
                    CupertinoIcons.right_chevron,
                    color: textcolor(),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => languageSetting()));
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(0.6),
                margin: EdgeInsets.only(
                  left: 0,
                  right: 0,
                ),
                color: BoxBackground(),
                child: FlatButton(
                  onPressed: () async {
                    print('Log out');
                    await pr.show();

                    Future.delayed(Duration(seconds: 2)).then((onValue) {});
                    var prefs = await SharedPreferences.getInstance();
                    prefs.remove("user");
                    pr.hide();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/LoginScreen', (Route route) => false);
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                    print(context);
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(langaugeSetFunc('Log Out'),
                              style: TextStyle(
                                fontSize: 20,
                                color: textcolor(),
                                fontFamily: 'Source Sans Pro',
                              )),
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
                      color: BoxBackground(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Rental Manager",
            style: TextStyle(fontFamily: 'Pacifico', color: textcolor()
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
                  SizedBox(
                    height: 100,
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: globals.UserImageUrl == ""
                        ? AssetImage('images/appstore.png')
                        : NetworkImage(globals.UserImageUrl),
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
              Container(
                decoration: new BoxDecoration(
                  color: BoxBackground(),
                ),
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.tag,
                    color: textcolor(),
                  ),
                  title: Text(
                    langaugeSetFunc("History"),
                    style: TextStyle(color: textcolor()),
                  ),
                  trailing: Icon(
                    CupertinoIcons.right_chevron,
                    color: textcolor(),
                  ),
                  onTap: () async {
                    await pr.show();

                    var mylist = await setData();

                    List<globals.ReservationItem> sort_list = [];
                    mylist.forEach((element) {
                      sort_list.add(element);
                    });

                    for (int i = 0; i < sort_list.length - 1; i++) {
                      for (int j = 0; j < sort_list.length - i - 1; j++) {
                        var a = sort_list[j].startTime,
                            b = sort_list[j + 1].startTime;
                        if (a == null || b == null) {
                          continue;
                        }

                        if (isEarly(a, b)) {
                          var swap = sort_list[j];
                          sort_list[j] = sort_list[j + 1];
                          sort_list[j + 1] = swap;
                        }
                      }
                    }
                    globals.itemList = sort_list;

                    pr.hide();
                    print(mylist.length.toString());
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HistoryReservation()));
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: new BoxDecoration(
                  color: BoxBackground(),
                ),
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.profile_circled,
                    color: textcolor(),
                  ),
                  title: Text(
                    langaugeSetFunc("Account Details"),
                    style: TextStyle(color: textcolor()),
                  ),
                  trailing: Icon(
                    CupertinoIcons.right_chevron,
                    color: textcolor(),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EditProfile()));
                  },
                ),
              ),
              Container(
                decoration: new BoxDecoration(
                  color: BoxBackground(),
                ),
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.brightness,
                    color: textcolor(),
                  ),
                  title: Text(
                    langaugeSetFunc(("Theme Color")),
                    style: TextStyle(color: textcolor()),
                  ),
                  trailing: Icon(
                    CupertinoIcons.right_chevron,
                    color: textcolor(),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => changeColor()));
                  },
                ),
              ),
              Container(
                decoration: new BoxDecoration(
                  color: BoxBackground(),
                ),
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.gear,
                    color: textcolor(),
                  ),
                  title: Text(
                    langaugeSetFunc('Language Setting'),
                    style: TextStyle(color: textcolor()),
                  ),
                  trailing: Icon(
                    CupertinoIcons.right_chevron,
                    color: textcolor(),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => languageSetting()));
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(0.6),
                margin: EdgeInsets.only(
                  left: 0,
                  right: 0,
                ),
                color: BoxBackground(),
                child: FlatButton(
                  onPressed: () async {
                    print('Log out');
                    await pr.show();

                    Future.delayed(Duration(seconds: 2)).then((onValue) {});
                    var prefs = await SharedPreferences.getInstance();
                    prefs.remove("user");
                    pr.hide();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/LoginScreen', (Route route) => false);
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                    print(context);
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(langaugeSetFunc('Log Out'),
                              style: TextStyle(
                                fontSize: 20,
                                color: textcolor(),
                                fontFamily: 'Source Sans Pro',
                              )),
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
                      color: BoxBackground(),
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
