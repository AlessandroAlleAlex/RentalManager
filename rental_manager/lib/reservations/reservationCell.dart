import 'dart:async';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/tabs/locations.dart';

import '../Locations/show_all.dart';
import '../globals.dart' as globals;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../CurrentReservation.dart';
import '../tabs/reservations.dart';

class reservationCell extends StatefulWidget {
  final DocumentSnapshot passedFirestoreData;
  reservationCell({this.passedFirestoreData});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _reservationCell();
  }
}

class _reservationCell extends State<reservationCell> {
  final firestore =
      Firestore.instance.collection(returnReservationCollection());
  Timer _timer;
  int displayRemainingTime = -1;
  String itemID;
  int itemAmount;

  Future pickedUp() async {
    String date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    await firestore
        .document(widget.passedFirestoreData.documentID.toString())
        .updateData({
      'status': 'Picked Up',
      'picked Up time': date,
    }).catchError((error) => print(error));
  }

  Future timeExpired() async {
    await firestore
        .document(widget.passedFirestoreData.documentID.toString())
        .updateData({'status': 'Returned'}).catchError((error) => print(error));
  }

  Future incrementItemAmount() {
    return Firestore.instance
        .collection(returnItemCollection())
        .document(itemID)
        .get()
        .then(
      (doc) {
        Firestore.instance
            .collection(returnItemCollection())
            .document(itemID)
            .updateData({'# of items': doc.data['# of items'] + itemAmount});
      },
    );
  }

  Future cancelReservation() async {
    await firestore
        .document(widget.passedFirestoreData.documentID.toString())
        .updateData({'status': 'Returned'}).catchError((error) => print(error));
    await incrementItemAmount();
    // await Firestore.instance.collection(returnItemCollection()).document(itemID).setData({'# of items': +itemAmount});
  }

  void _showCancelDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reservation Cancelled!'),
            content: Text(
                'The reservation\'s record is being saved in your history\'s list.'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text('Close'))
            ],
          );
        });
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Time Expired!'),
            content: Text(
                'The reservation\'s record is being saved in your history\'s list.'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text('Close'))
            ],
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemID = widget.passedFirestoreData.data['item'];
    itemAmount = int.parse(widget.passedFirestoreData.data['amount']);
    // pickedUp();
    // Firestore.instance
    //     .collection(returnReservationCollection())
    //     .where('uid', isEqualTo: globals.uid)
    //     .where('status', isEqualTo: 'Reserved')
    //     .getDocuments()
    //     .then((doc) => Navigator.of(context).pop(doc.documents));
    // _showDialog();

    // Navigator.pushAndRemoveUntil(context, newRoute, (route) => false);
    startTimer();
    if (displayRemainingTime > -1) {
      _timer = Timer.periodic(Duration(seconds: 60), (Timer t) => startTimer());
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_timer != null) {
      _timer.cancel(); // cancel the timer when you go to another view
    }
  }

  void startTimer() {
    final startTime = DateTime.parse(widget.passedFirestoreData['startTime']);
    final endTime = startTime.add(new Duration(minutes: 10));

    final remainingTime = endTime.difference(DateTime.now()).inMinutes;
    displayRemainingTime = remainingTime;
    if (remainingTime > -1) {
      setState(() {
        displayRemainingTime = remainingTime;
      });
    } else {
      timeExpired().whenComplete(
        () async {
          await incrementItemAmount().whenComplete(() async {
            await Firestore.instance
                .collection(returnReservationCollection())
                .where('uid', isEqualTo: globals.uid)
                .where('status', isEqualTo: 'Reserved')
                .getDocuments()
                .then((doc) => Navigator.of(context).pop(doc.documents));
            _showDialog();
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        backgroundColor: backgroundcolor(),
        title: Text(
          langaugeSetFunc('Reservation Details'),
          style: TextStyle(color: textcolor()),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: '- ' + langaugeSetFunc('item name:') + ' ',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 16.0)),
                    TextSpan(
                        text: widget.passedFirestoreData['name'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.teal)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: '- ' + langaugeSetFunc('start time:') + ' ',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 16.0)),
                    TextSpan(
                        text:
                            parseTime(widget.passedFirestoreData['startTime']),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: '- ' + langaugeSetFunc('end time:') + ' ',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 16.0)),
                    TextSpan(
                        text: DateFormat.yMd().add_jm().format(DateTime.parse(
                                widget.passedFirestoreData['startTime'])
                            .add(new Duration(minutes: 10))),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: '- ' + langaugeSetFunc('quantity:') + ' ',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 16.0)),
                    TextSpan(
                        text: widget.passedFirestoreData['amount'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.teal)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: '- ' + langaugeSetFunc('item status:') + ' ',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 16.0)),
                    TextSpan(
                        text: langaugeSetFunc(
                            widget.passedFirestoreData['status']),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.teal)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                langaugeSetFunc('Time Left To Pick Up:'),
                style: TextStyle(
                  color: Colors.teal,
                  fontFamily: 'Source Sans Pro',
                  fontSize: 25,
                ),
              ),
              Text(
                '$displayRemainingTime ' + langaugeSetFunc('Minutes'),
                style: TextStyle(
                  color: Colors.teal,
                  fontFamily: 'Source Sans Pro',
                  fontSize: 25,
                  letterSpacing: 2.5,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: RaisedButton.icon(
                  color: Colors.blue,
                  textColor: Colors.white,
                  elevation: 2.0,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(40.0),
                  ),
                  onPressed: () async {
                    // print(widget.passedFirestoreData.documentID.toString());

                    pickedUp();
                    QuerySnapshot documents = await Firestore.instance
                        .collection(returnReservationCollection())
                        .where('uid', isEqualTo: globals.uid)
                        .where('status', isEqualTo: 'Reserved')
                        .getDocuments();
                    Navigator.of(context).pop(documents.documents);
                  },
                  icon: Icon(Icons.insert_emoticon, size: 30.0),
                  label: Text(
                    langaugeSetFunc('Pick Up'),
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: RaisedButton.icon(
                  color: Colors.red,
                  textColor: Colors.white,
                  elevation: 2.0,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(40.0),
                  ),
                  onPressed: () async {
                    await cancelReservation().whenComplete(() async {
                      QuerySnapshot documents = await Firestore.instance
                          .collection(returnReservationCollection())
                          .where('uid', isEqualTo: globals.uid)
                          .where('status', isEqualTo: 'Reserved')
                          .getDocuments();
                      Navigator.of(context).pop(documents.documents);
                      _showCancelDialog();
                    });
                  },
                  icon: Icon(
                    Icons.cancel,
                    size: 30.0,
                  ),
                  label: Text(
                    langaugeSetFunc('Cancel Reservation'),
                    style: TextStyle(fontSize: 20.0),
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
