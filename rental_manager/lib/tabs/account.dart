import 'package:flutter/material.dart';
import 'package:rental_manager/HistoryReservation.dart';
import 'package:rental_manager/data.dart';
import '../globals.dart' as globals;
import 'package:rental_manager/editProfile.dart';
import 'package:rental_manager/CurrentReservation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';

ProgressDialog pr;

Future<List<globals.ReservationItem>> setData() async{
  List<globals.ReservationItem> itemList = new List();

  final QuerySnapshot result =
  await Firestore.instance.collection('reservation').getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  List<String> reservationList = [];
  documents.forEach((data) => reservationList.add(data.documentID));

  for(var i = 0; i < reservationList.length; i++){
    String currentOne = reservationList[i];


    await Firestore.instance
        .collection('reservation')
        .document('$currentOne')
        .get()
        .then((DocumentSnapshot ds) {
      // use ds as a snapshot
      var item = new globals.ReservationItem(
        ds["amount"],
        ds["startTime"],
        ds["endTime"],
        ds["item"],
        ds["status"],
        ds["uid"],
      );
      item.name = ds["name"];
      item.imageURL = ds["imageURL"];
      itemList.add(item);
    });

    //print(itemList[i].status);

  }

  return itemList;
}

Future<List<globals.ReservationItem>> setDataNew() async{
  List<globals.ReservationItem> itemList = new List();

  final QuerySnapshot result =
  await Firestore.instance.collection('reservation').getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  List<String> reservationList = [];
  documents.forEach((data) => reservationList.add(data.documentID));

  for(var i = 0; i < reservationList.length; i++){
    String currentOne = reservationList[i];


    await Firestore.instance
        .collection('reservation')
        .document('$currentOne')
        .get()
        .then((DocumentSnapshot ds) {
      // use ds as a snapshot
      var item = new globals.ReservationItem(
        ds["amount"],
        ds["startTime"],
        ds["endTime"],
        ds["item"],
        ds["status"],
        ds["uid"],
      );
      item.name = ds["name"];
      item.imageURL = ds["imageURL"];

      itemList.add(item);
    });
    var index = itemList.length;

    if(itemList[index - 1 ].imageURL != null){
      print('URL: ' +  itemList[index - 1 ].imageURL);
    }else{
      itemList[index - 1 ].imageURL = "www.google.com";
    }


  }

  for(int i = 0; i < itemList.length; i++){
    print("URL:" + itemList[i].imageURL);
  }

  return itemList;
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

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Rental Manager",
            style:  TextStyle(
              fontFamily: 'Pacifico',
              // backgroundColor: Colors.teal,
            ),
          ),

          backgroundColor: Colors.teal,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('images/appstore.png'),
                  ),
                  Text(
                    globals.username,
                    style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      color: Colors.teal,
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
                  Text(
                    'Your Score: xxx',
                    style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      color: Colors.teal.shade900,
                      fontSize: 20,
                      letterSpacing: 1.5,
                    ),
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
                color: Colors.teal,
                child: FlatButton(
                  onPressed: () async{
                    await pr.show();
                    pr.update(
                      message: 'Please wait...',
                      progressWidget: CircularProgressIndicator(),
                      progressTextStyle: TextStyle(
                          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
                      messageTextStyle: TextStyle(
                          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
                    );
                    var mylist = await setDataNew();
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
                            color: Colors.white,
                          ),
                          Text(
                              'Current Reservation',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                          Text(
                              '>>',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
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
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding:EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: Colors.teal,
                child: FlatButton(
                  onPressed: () async{
                    await pr.show();
                    pr.update(
                      message: 'Please wait...',
                      progressWidget: CircularProgressIndicator(),
                      progressTextStyle: TextStyle(
                          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
                      messageTextStyle: TextStyle(
                          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
                    );
                    var mylist = await setDataNew();
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
                            color: Colors.white,
                          ),
                          Text(
                              'History Reservation',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                          Text(
                              '>>',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
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
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: Colors.teal,
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
                            color: Colors.white,
                          ),
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                          Text(
                            '>>',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
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
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(0.6),
                margin: EdgeInsets.only(),
                color: Colors.teal,
                child: FlatButton(
                  onPressed: (){
                    print("Theme Color");

                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                          ),
                          Text(
                            'Theme Color',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                          Text(
                            '>>',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
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
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding:EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: Colors.teal,
                child: FlatButton(
                  onPressed: () async{
                    print('Log out');
                    await pr.show();
                    pr.update(
                      message: 'Logging out...',
                      progressWidget: CircularProgressIndicator(),
                      progressTextStyle: TextStyle(
                          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
                      messageTextStyle: TextStyle(
                          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
                    );
                    Future.delayed(Duration(seconds: 2)).then((onValue){
                    });
                    pr.hide();
                    Navigator.of(context).pushReplacementNamed('/LoginScreen');
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.exit_to_app ,
                            color: Colors.white,
                          ),
                          Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                          Text(
                              '>>',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
