import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/tabs/locations.dart';
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
  int _currentResAmount = 1;
  int _itemTotalAmount = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _itemTotalAmount = widget.itemSelected.data['# of items'];
  }

  void _showNumberPickerDialog() {
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            initialIntegerValue: _currentResAmount,
            minValue: 1,
            maxValue: _itemTotalAmount,
            title: new Text("edit amount"),
          );
        }).then((value) {
      if (value != null) {
        setState(() => _currentResAmount = value);
      }
    });
  }

  Widget reserveButton() {
    return _currentResAmount < 1 || _itemTotalAmount < 1
        ? Text(
            'The item you have selected is currently not available.',
            style: TextStyle(
              color: Colors.red,
              fontSize: 22,
            ),
          )
        : SizedBox(
            height: 50,
            width: double.infinity,
            child: RaisedButton.icon(
              color: Colors.blue,
              textColor: Colors.white,
              elevation: 2.0,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(40.0),
              ),
              onPressed: () {
                testingReservations(widget.itemSelected.documentID);
              },
              icon: Icon(
                Icons.bookmark,
                size: 30.0,
              ),
              label: Text(
                langaugeSetFunc('Reserve') +
                    ': ${_currentResAmount.toString()}',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          );
  }

  Container picture() {
    return Container(
      // padding: EdgeInsets.only(left: 10.0),
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: NetworkImage(widget.itemSelected.data['imageURL']),
          // image: new AssetImage("drive-steering-wheel.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget bottom3Widgets() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(returnItemCollection())
          .document(widget.itemSelected.documentID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('loading...');
        _itemTotalAmount = snapshot.data['# of items'];
        return Column(
          children: <Widget>[
            Text(
                langaugeSetFunc('Remaining Amount:') +
                    ' ' +
                    snapshot.data['# of items'].toString(),
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.red,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10.0),
            snapshot.data['# of items'] < 2
                ? Container()
                : GestureDetector(
                    onTap: () {
                      _showNumberPickerDialog();
                    },
                    child: Text(
                      'click to edit reservation amount',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.red,
                          fontSize: 18.0),
                    ),
                  ),
            SizedBox(height: 40.0),
            reserveButton()
          ],
        );

        Text(
            langaugeSetFunc('Remaining Amount:') +
                ' ' +
                snapshot.data['# of items'].toString(),
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.red,
                fontWeight: FontWeight.bold));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        title: Text(
          widget.itemSelected.data['name'],
          style: TextStyle(color: textcolor()),
        ),
        backgroundColor: backgroundcolor(),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
          child: Column(
            children: <Widget>[
              picture(),
              SizedBox(height: 20.0),
              bottom3Widgets(),
              // SizedBox(height: 20.0),
              // reserveButton(),
            ],
          ),
        ),
      ),
    );
  }

  testingReservations(String itemID) async {
    print(globals.uid);
    var now = new DateTime.now();
    var time = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);
    var pickUpBefore = now.add(new Duration(minutes: 10));
    print("Reservation Created time: " + time);
    String itemName;
    await Firestore.instance
        .collection(returnItemCollection())
        .document(itemID)
        .get()
        .then((DocumentSnapshot ds) {
      try {
        itemName = ds["name"];
        print("Found in ${returnItemCollection()}");
      } catch (e) {
        print(e);
      }
    });
    sendEmail(
        "Order Confirmed",
        "Your order item is $itemName\nNumber: 1\nTime you ordered is $time",
        context);
    print("Reservation pickup before time: " +
        DateFormat("yyyy-MM-dd HH:mm:ss").format(pickUpBefore));
    uploadData(itemID, globals.uid, time);
  }

  void uploadData(itemID, uid, dateTime) async {
    String itemName, imageURL;
    final databaseReference = Firestore.instance;
    await Firestore.instance
        .collection(returnItemCollection())
        .document(itemID)
        .get()
        .then((DocumentSnapshot ds) {
      try {
        itemName = ds["name"];
        print("Found in ${returnItemCollection()}");
      } catch (e) {
        print(e);
      }
    });

    await Firestore.instance
        .collection(returnItemCollection())
        .document(itemID)
        .get()
        .then((DocumentSnapshot ds) {
      try {
        imageURL = ds["imageURL"];
        print("Found in ${returnItemCollection()}");
      } catch (e) {
        print(e);
      }
    });

    if (itemName == null) {
      print("UID Not Found");
      itemName = "UID Not Found";
    }
    if (imageURL == null) {
      print("UID Not Found");
      imageURL = "www.gooogle.com";
    }

    await databaseReference
        .collection(returnReservationCollection())
        .document()
        .setData({
      'imageURL': imageURL,
      'name': itemName,
      'uid': uid,
      'item': itemID,
      'amount': _currentResAmount.toString(),
      'startTime': dateTime,
      'status': "Reserved",
      'reserved time': dateTime,
      'picked Up time': 'NULL',
      'return time': 'NULL',
      'endTime': "TBD",
      'UserName': globals.username,
    });
    await databaseReference
        .collection(returnUserCollection())
        .document(globals.uid)
        .updateData({
      'LatestReservation': dateTime,
    });

    PlatformAlertDialog(
      title: 'Your item has placed',
      content:
          'Your reservation is successful confirmed, please pick it up on time\n You will soon receieved the confirmation email',
      defaultActionText: Strings.ok,
    ).show(context);
    print("success!");
  }
}
