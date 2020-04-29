import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Container getImage() {
    return Container(
      alignment: Alignment.center,
      child: Image.network(
        widget.itemSelected.data['imageURL'],
        fit: BoxFit.cover,
        height: 300.0,
      ),
      // constraints: BoxConstraints.expand(height: 300.0),
    );
  }

  Container getDescription() {
    return Container(
      alignment: Alignment.center,
      // alignment: Alignment.topCenter,
      child: Text('some item description information...'),
    );
  }

  // Container reserveButton() {
  //   return Container(
  //     alignment: Alignment.center,
  //     child: RaisedButton(
  //       onPressed: () {
  //         print('button pressed! (reserve)');
  //         testingReservations(widget.itemSelected.documentID);
  //       },
  //       child: Text('Reserve Now', style: TextStyle(color: Colors.white)),
  //       color: Colors.teal,
  //     ),
  //   );
  // }

  Container reserveButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        onPressed: () {
          print('button pressed! (reserve)');
          testingReservations(widget.itemSelected.documentID);
        },
        child: Text(langaugeSetFunc('Reserve Now'), style: TextStyle(color: Colors.white)),
        color: Colors.teal,
      ),
    );
  }

  Container top() {
    return Container(
      // padding: EdgeInsets.only(left: 10.0),
      height: MediaQuery.of(context).size.height * 0.5,
      // width: MediaQuery.of(context).size.width * 0.5,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: NetworkImage(widget.itemSelected.data['imageURL']),
          // image: new AssetImage("drive-steering-wheel.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Text descriptionText() {
    return Text('Some Item Description???', style: TextStyle(fontSize: 18.0));
  }

  Widget amount() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 30, 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('ARC_items')
              .document(widget.itemSelected.documentID)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('loading...');
            return Text( langaugeSetFunc('Remaining Amount:')+ ' ${snapshot.data['# of items']}',
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold));
          },
        ),
      ),
    );
  }

  Container bottom() {
    return Container(
      // height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      // color: Theme.of(context).primaryColor,
      padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 30.0),
      // padding: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: <Widget>[descriptionText(), reserveButton()],
        ),
      ),
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
          title: Text( langaugeSetFunc('Details of:') + ' ${widget.itemSelected.data['name']}', style: TextStyle(color: textcolor()),),
          backgroundColor: backgroundcolor(),
        ),
        backgroundColor: Colors.blueGrey,
        // body: Image.network(
        //   widget.itemSelected.data['imageURL'],
        // ),
        body: Scaffold(
          body: Column(
            children: <Widget>[top(), amount(), bottom()],
          ),
        )

        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.stretch,
        //   children: <Widget>[
        //     getImage(),
        //     getDescription(),
        //     getButton(),
        //   ],
        // ),

        // constraints: BoxConstraints.expand(),
        // color: Colors.blueGrey,
        // child: Stack(children: <Widget>[
        //   getImage(),
        //   getDescription(),
        // ]),
        );
  }
// }

  testingReservations(String itemID) async {
    print(globals.uid);
    // final QuerySnapshot result =
    // await Firestore.instance.collection('items').getDocuments();
    // final List<DocumentSnapshot> documents = result.documents;
    // List<String> itemIDs = [];
    // documents.forEach((data) => itemIDs.add(data.documentID));
    // print(documents.length);
    //for(int i = 0; i< snapshot.length;i++){
    print(itemID);
    //}
    var now = new DateTime.now();
    var time = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);
    var pickUpBefore = now.add(new Duration(minutes: 10));
    print("Reservation Created time: " + time);
    String itemName, imageURL;
    final databaseReference = Firestore.instance;
    await Firestore.instance
        .collection('ARC_items')
        .document(itemID)
        .get()
        .then((DocumentSnapshot ds) {
      try {
        itemName = ds["name"];
        print("Found in ARC_items");
      } catch (e) {
        print(e);
      }
    });
    sendEmail("Order Confirmed", "Your order item is $itemName\nNumber: 1\nTime you ordered is $time", context);
    print("Reservation pickup before time: " +
        DateFormat("yyyy-MM-dd HH:mm:ss").format(pickUpBefore));
    uploadData(itemID, globals.uid, time);
  }

  void uploadData(itemID, uid, dateTime) async {
    String itemName, imageURL;
    final databaseReference = Firestore.instance;
    await Firestore.instance
        .collection('ARC_items')
        .document(itemID)
        .get()
        .then((DocumentSnapshot ds) {
      try {
        itemName = ds["name"];
        print("Found in ARC_items");
      } catch (e) {
        print(e);
      }
    });

    await Firestore.instance
        .collection('ARC_items')
        .document(itemID)
        .get()
        .then((DocumentSnapshot ds) {
      try {
        imageURL = ds["imageURL"];
        print("Found in ARC_items");
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

    await databaseReference.collection(globals.collectionName).document().setData({
      'imageURL': imageURL,
      'name': itemName,
      'uid': uid,
      'item': itemID,
      'uid': uid,
      'amount': "1",
      'startTime': dateTime,
      'status': "Reserved",
      'reserved time' : dateTime,
      'picked Up time' : 'NULL',
      'return time': 'NULL',
      'endTime': "TBD",
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
