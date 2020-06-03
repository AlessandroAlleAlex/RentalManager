import 'package:flutter/cupertino.dart';
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

  Future decrementItemAmount() {
    return Firestore.instance
        .collection(returnItemCollection())
        .document(widget.itemSelected.documentID)
        .updateData({'# of items': _itemTotalAmount - _currentResAmount});
  }

  Widget reserveButton() {
    return _currentResAmount < 1 || _itemTotalAmount < 1
        ? Text(
            langaugeSetFunc(
                'The item you have selected is currently not available.'),
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
                if (globals.username == "anonymous") {
                  pop_window(
                      "Sorry", "anonymous cannot make a reservation", context);
                } else {
                  testingReservations(widget.itemSelected.documentID);
                }
                // Navigator.pop(context);
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
                      langaugeSetFunc('click to edit reservation amount'),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    if (globals.isiOS) {
      return Scaffold(
        appBar: CupertinoNavigationBar(
          heroTag: "tab14",
          transitionBetweenRoutes: false,
          middle: Text(
            widget.itemSelected.data['name'],
            style: TextStyle(color: textcolor()),
          ),
          backgroundColor: backgroundcolor(),
        ),
        backgroundColor: backgroundcolor(),
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

  void _showSuccessDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reserved!'),
            content: Text(
                'Please pick up your item/s within 10 mins.\nYou will soon receive a confirmation email.'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text('Ok'))
            ],
          );
        });
  }

  testingReservations(String itemID) async {
    // print(globals.uid);
    var now = new DateTime.now();
    var time = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);
    String itemName, locationName = "NULL", catergoryName = "NULL";
    await Firestore.instance
        .collection(returnItemCollection())
        .document(itemID)
        .get()
        .then((DocumentSnapshot ds) {
      try {
        itemName = ds["name"];
        locationName = ds["Location"];
        catergoryName = ds["category"];
      } catch (e) {
        print(e);
      }
    });
    sendEmail(
        "Order Confirmed",
        "Your order item is $itemName\nNumber: 1\nTime you ordered is $time",
        context);
    // print("Reservation pickup before time: " +
    //     DateFormat("yyyy-MM-dd HH:mm:ss").format(pickUpBefore));
    uploadData(itemID, globals.uid, time, locationName, catergoryName);
  }

  void uploadData(itemID, uid, dateTime, locationName, catergoryName) async {
    String itemName, imageURL;
    final databaseReference = Firestore.instance;
    await Firestore.instance
        .collection(returnItemCollection())
        .document(itemID)
        .get()
        .then((DocumentSnapshot ds) {
      try {
        itemName = ds["name"];
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
      'location': locationName,
      'category': catergoryName,
    });
    await databaseReference
        .collection(returnUserCollection())
        .document(globals.uid)
        .updateData({
      'LatestReservation': dateTime,
    });

    await decrementItemAmount();
    _showSuccessDialog();
    Navigator.pop(context);

    // PlatformAlertDialog(
    //   title: 'Your item has placed',
    //   content:
    //       'Your reservation is successful confirmed, please pick it up on time\n You will soon receieved the confirmation email',
    //   defaultActionText: Strings.ok,
    // ).show(context);
    print("success!");
  }
}
