

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rental_manager/chatview/login.dart';
import 'dart:async';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/tabs/reservations.dart';
import 'package:rental_manager/globals.dart' as globals;
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart' as slideDialog;
import '../rate.dart';
DocumentSnapshot ds;

class reservationCell extends StatefulWidget {
  final DocumentSnapshot passedFirestoreData;
  reservationCell({this.passedFirestoreData});
  @override
  State<StatefulWidget> createState() {
    print(passedFirestoreData.data);
    ds = passedFirestoreData;

    // TODO: implement createState
    return _reservationCell();
  }
}






class _reservationCell extends State<reservationCell> {


  Timer _timer;
  int _start = 10;
  String a = "";
  String OK1 = "Cancel Reservation";
  String OK2 = "Confirm Pick Up";
  String OK3 = "Returned";
  String status = ds["status"];
  void startTimer() {

    var difference = DateTime.now().difference(DateTime.parse(ds["startTime"])).inMinutes;
    print(difference);
    if(difference > 10){
      _start = 0;
    }else{
      _start -= difference;
    }

    const oneSec = const Duration(seconds: 5);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    var Location = "Gym";
    // TODO: implement build
    double rate = 0;
    Future<bool> _showDialog(String s) async{
      double review;
      slideDialog.showSlideDialog(
        context: context,
        child:  Container(
          child: Form(

            child: Column(
              children: <Widget>[
                Center(
                  child:Text("Thanks for your returning!\nDid you enjoy this experience"),
                ),

                Center(
                  child:  RatingBar(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      rate = rating;
                      print(rating);
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 300,
                  child: RaisedButton(
                    highlightElevation: 0.0,
                    splashColor: Colors.greenAccent,
                    highlightColor: Colors.green,
                    elevation: 0.0,
                    color: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: 15,
                              // backgroundColor:  Colors.teal[50],
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),

                      ],
                    ),
                    onPressed: () async{

                    await Firestore.instance.collection('reservation').document(ds.documentID)
                    .updateData({
                      'Review': rate / 5,
                    });
                    pop_window("Confirmed", "We appreciate your evaluation!\nYour reviewe will be used in the Help- track Page", context);

                    },
                    padding: EdgeInsets.all(7.0),
                    //color: Colors.teal.shade900,
                    disabledColor: Colors.black,
                    disabledTextColor: Colors.black,

                  ),
                ),
              ],
            ),
          ),
        ),
        textField: Container(
          child: Column(
            children: <Widget>[
            ],
          ),
        ),
        barrierColor: Colors.white.withOpacity(0.7),
      );
      return true;
    }
    Widget aButton1(String ok){
      if(ok == "" || ok == "Returned" || ok.contains("Picked Up") ){
        return Container();
      }else{
        return MaterialButton(
          minWidth: 140,
          height: 50,
          color: Colors.teal,
          splashColor: Colors.redAccent,
          onPressed: () async{
            var difference = DateTime.now().difference(DateTime.parse(ds["startTime"])).inSeconds;

            if(difference >= 120){
              pop_window("Warning!", "Exceed 2 minues and item cannot be canceled", context);
            }else{
              globals.CancelledItemDocID = ds.documentID;
              PlatformAlertDialog(
                title: "Warning",
                content: "Type \"Yes\" to cancel your order and You Will receieve an cancellation email",
                cancelActionText: "No",
                defaultActionText: "Yes",
              ).show(context);
            }
            globals.mycontext = context;

            print("Cancel Reservation");
          },
          child: Text(
            '$OK1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        );
      }


    }

    Widget aButton2(String ok){
      if(ok != "Confirm Pick Up"){
        return Container();
      }else{
        return MaterialButton(
          minWidth: 140,
          height: 50,
          color: Colors.teal,
          splashColor: Colors.redAccent,

          onPressed: () async{
            Firestore.instance.collection("reservation").document(ds.documentID).updateData(
                {'picked Up time':  DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
                  'status': 'Picked Up',
                }

            );
            status = 'Picked Up';

          },
          child: Text(
            'Confirm Pick Up',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        );
      }
    }

    Widget aButton3(String ok){
      if(ok != "Returned"){
        return Container();
      }else{
        return MaterialButton(
          minWidth: 140,
          height: 50,
          color: Colors.teal,
          splashColor: Colors.redAccent,

          onPressed: () async{
            Firestore.instance.collection("reservation").document(ds.documentID).updateData(
                {'return time':  DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
                  'status': "Returned",
                }
            );
            _showDialog("Thanks for your returning\n Did your enjoy this item?");

          },
          child: Text(
            'Returned',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        );
      }
    }



    setState(() {

      print(status);


      if(_start == 0){
        if(status != "Returned"){
          OK1 = "";
          OK2 = "Confirm Pick Up";
          OK3 = "";
        }else{

          OK1 = "";
          OK2 = "";
          OK3 = "Returned";
        }
      }else{
        OK1 = "Cancel your reservation";
        OK2 = "Confirm Pick Up";
        OK3 = "";
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Details'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Item Information',
                  style: TextStyle(
                    fontFamily: '',
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  height: 20,
                  width: 200,
                  child: Divider(
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  '· Item Name: ${widget.passedFirestoreData.data["name"]}',
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
                Text(
                  '· Amount: ${widget.passedFirestoreData.data["amount"]}',
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
                Text(
                  '· Status: ${widget.passedFirestoreData.data["status"]}',
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
                Text(
                  '· Location: $Location',
                  style: TextStyle(
                    fontFamily: 'Source Sans Pro',
                    color: Colors.teal,
                    fontSize: 20,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
            //  Row(
            //   children: <Widget>[
            //     Text(
            //       '· User ID: ${widget.passedFirestoreData.data["uid"]}',
            //       style: TextStyle(
            //         fontFamily: 'Source Sans Pro',
            //         color: Colors.teal,
            //         fontSize: 20,
            //         letterSpacing: 2.5,
            //       ),

            //     ),
            //   ],
            // ),
            Row(
              children: <Widget>[
                SizedBox(
                  height: 50,
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
                  '  Time Left To Pick Up: ',
                  style: TextStyle(
                    color: Colors.teal,
                    fontFamily: 'Source Sans Pro',
                    fontSize: 25,
                  ),
                ),
                Text(
                  '$_start Minutes',
                  style: TextStyle(
                    color: Colors.teal,
                    fontFamily: 'Source Sans Pro',
                    fontSize: 25,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
              ],
            ),

            Row(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            aButton1(OK1),
            Divider(
              height: 10,
            ),
            aButton2(OK2),
            Divider(
              height: 10,
            ),
            aButton3(OK3),
          ],
        ),
      ),
    );
  }


}
