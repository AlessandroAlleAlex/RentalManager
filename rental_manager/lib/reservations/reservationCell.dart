import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  final firestore = Firestore.instance.collection('reservation');
  Timer _timer;
  int displayRemainingTime = -1;

  Future pickedUp() async {
    await firestore
        .document(widget.passedFirestoreData.documentID.toString())
        .updateData({'status': 'Picked Up'}).catchError(
            (error) => print(error));
  }

  Future cancelReservation() async {
    await firestore
        .document(widget.passedFirestoreData.documentID.toString())
        .delete()
        .catchError((error) => print(error));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
    if (displayRemainingTime > 0) {
      _timer = Timer.periodic(Duration(seconds: 60), (Timer t) => startTimer());
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel(); // cancel the timer when you go to another view
  }

  void startTimer() {
    final startTime = DateFormat.yMd()
        .add_jm()
        .parse(widget.passedFirestoreData['startTime']);
    final endTime =
        DateFormat.yMd().add_jm().parse(widget.passedFirestoreData['endTime']);

    final remainingTime = endTime.difference(DateTime.now()).inMinutes;
    print(remainingTime);
    print('=================================');
    displayRemainingTime = remainingTime;
    if (remainingTime > 0) {
      setState(() {
        displayRemainingTime = remainingTime;
      });
    } else {
      print('time expired!!!');
    }
    // print(remainingTime);
    // print(timeDiff);
    // print(endTime.difference(startTime));
    // print(widget.passedFirestoreData["startTime"]);
    // if (timeDiff > 10) {
    //   remainingTime = 0;
    // } else {
    //   remainingTime -= timeDiff;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Reservation Details'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: '- item name: ',
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
                      text: '- start time: ',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 16.0)),
                  TextSpan(
                      text: widget.passedFirestoreData['startTime'],
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
                      text: '- end time: ',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 16.0)),
                  TextSpan(
                      text: widget.passedFirestoreData['endTime'],
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
                      text: '- quantity: ',
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
                      text: '- item status: ',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 16.0)),
                  TextSpan(
                      text: widget.passedFirestoreData['status'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.teal)),
                ],
              ),
            ),
            SizedBox(height: 50),
            Text(
              '  Time Left To Pick Up: ',
              style: TextStyle(
                color: Colors.teal,
                fontFamily: 'Source Sans Pro',
                fontSize: 25,
              ),
            ),
            Text(
              '$displayRemainingTime Minutes',
              style: TextStyle(
                color: Colors.teal,
                fontFamily: 'Source Sans Pro',
                fontSize: 25,
                letterSpacing: 2.5,
              ),
            ),
            SizedBox(height: 50),
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
                  Navigator.pop(context);
                },
                icon: Icon(Icons.insert_emoticon, size: 30.0),
                label: Text(
                  'Pick Up',
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
                  cancelReservation();
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.cancel,
                  size: 30.0,
                ),
                label: Text(
                  'Cancel Reservation',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
