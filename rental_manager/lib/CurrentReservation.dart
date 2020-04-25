import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:rental_manager/data.dart';
import 'package:rental_manager/reservations/reservationCell.dart';
import 'package:rental_manager/tabs/locations.dart';

import 'globals.dart' as globals;
import 'package:awesome_dialog/animated_button.dart';
import 'package:flutter/rendering.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter_ticket_widget/flutter_ticket_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

import 'package:meta/meta.dart' show visibleForTesting;

import 'dart:typed_data';

class ItemInfo {
  String imageUrl;
  String person;
  String date;
  String item;
  String status;
  String start;
  String Return;
  String timeNow;
  String uid;
  String documentID;
  ItemInfo(this.imageUrl, this.person, this.date, this.item, this.status,
      this.start, this.Return, this.timeNow, this.uid, this.documentID);
}


String parseTime(String time_str){
  final reservationStartTime = DateFormat.yMd().add_jm().format(DateTime.parse(time_str));
  print(reservationStartTime.toString());
  return reservationStartTime.toString();
}


List<globals.ReservationItem> globalitemList = [];

class CureentReservation extends StatefulWidget {
  @override
  _CureentReservationState createState() => _CureentReservationState();
}

class _CureentReservationState extends State<CureentReservation> {
  List<globals.ReservationItem> localList = new List();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();
    Timer(const Duration(seconds: 1), () {
      completer.complete();
    });
    return completer.future.then<void>((_) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: const Text('Refresh complete'),
          action: SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              })));
    });
  }

  int firstCount = 0;
  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for the major Material Components.

    List<Widget> _getListings(BuildContext context, itemList) {
      // <<<<< Note this change for the return type
      List listings = new List<Widget>();
      var list = itemList;

      for (var i = 0; i < list.length; i++) {
        if (list[i].uid != globals.uid) {
          continue;
        }

        if (list[i].status != "Returned") {
          var name = list[i].name;
          if (name == null) {
            name = 'Error no name';
          }
          if (list[i].imageURL != null) {
            //print("CR: " + list[i].imageURL);
          }

          var url = list[i].imageURL;
          listings.add(
            Column(
              children: <Widget>[
                new ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(url),
                    ),
                    //显示在title之后
                    trailing: new Icon(Icons.chevron_right),
                    title: new Text(name),
                    subtitle: new Text(parseTime(list[i].startTime)),
                    onTap: () {
                      String value = itemInfo(list[i]);
                      //ItemInfo(person, date, item, status, start, Return)
                      String person = globals.username,
                          date = list[i].startTime,
                          item = list[i].name;
                      String status = list[i].status,
                          start = list[i].startTime,
                          Return = list[i].endTime;
                      String uid = list[i].uid,
                          docuementID = list[i].documentID;
                      DateTime now = DateTime.now();
                      String timeNow =
                          DateFormat('kk:mm:ss \n EEE d MMM').format(now);

                      var theitem = ItemInfo(url, person, date, item, status,
                          start, Return, timeNow, uid, docuementID);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Ticket(theitem)));

//                AwesomeDialog(
//                  context: context,
//                  animType: AnimType.SCALE,
//                  customHeader: CircleAvatar(
//                    radius: 50,
//                    backgroundImage: NetworkImage(url),
//                  ),
//
//                  tittle: 'Item Information ',
//                  desc: itemInfo(list[i]),
//                  btnOk: _buildFancyButtonOk(context),
//                  //this is ignored
//                  btnOkOnPress: () {},
//                ).show();
//              },
                    }),
                Divider(
                  height: 2.0,
                ),
              ],
            ),
          );
        }
      }
      return listings;
    }

    bool isEarly(String a, String b) {
      var time_a = DateTime.parse(a), time_b = DateTime.parse(b);

      var difference = time_a.difference(time_b);
      return difference.isNegative;
    }

    void uploadMask() async {
      String test = "test";
      var url =
          'https://firebasestorage.googleapis.com/v0/b/rentalmanager-f94f1.appspot.com/o/item_images%2FRock%20Wall%20ATC-Carabiner.jpg?alt=media&token=f0e605fa-ed3e-40c1-b0d9-186ce01e3ab4';
      await Firestore.instance.collection(globals.collectionName).document().setData({
        'imageURL': url,
        'name': test,
        'item': 'FmkqMr7ta72O4eeDjal7',
        'uid': 'AppSignInUserjagaoabc@gmail.com',
        'amount': "1",
        'startTime': '2020-04-17 11:27:05',
        'status': "Reserved",
        'reserved time': '2020-04-17 11:27:05',
        'picked Up time': '2020-04-18 19:07:01',
        'return time': '2020-04-18 19:07:06',
        'endTime': "TBD",
      });
    }

    void deleteTestMode() async {
      var result =
          await Firestore.instance.collection(globals.collectionName).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      for (int i = 0; i < documents.length; i++) {
        if (documents[i]["name"] == "test") {
          Firestore.instance
              .collection(globals.collectionName)
              .document(documents[i].documentID)
              .delete();
        }
      }
    }

    bool isMultipleSeclect = false;

    Map<String, bool> titles = {};
    Map<String, String> subtitles = {};

    Map<String, String> urls = {};

    Map<String, int> index_map = {};

    List<globals.ReservationItem> mylist = [];

    Widget a(int i) {
      if (i == 0) {
        return MaterialButton(
          child: Text('Cancel',style: TextStyle(color: textcolor())),
          onPressed: () {
            setState(() {});
          },
        );
      } else {
        return Container();
      }
    }

    Widget b(int i) {
      if (i == 0) {
        return new MaterialButton(
          onPressed: () {
            List<int> returningList = [];
            titles.forEach((key, value) {

              if (value == true) {
                int i = index_map[key];
                returningList.add(i);
              }
            });

            int itemNum = returningList.length;
            String itemName = "";
            for(int i = 0; i < returningList.length; i++){
              String name = mylist[returningList[i]].name;
              if(i == 0){
                itemName += name;
              }else{
                itemName += '\n';
                itemName += name;
              }
            }

            if(returningList.length == 0) {
              PlatformAlertDialog(
                title: "Warning",
                content: "You did not select any items",
                defaultActionText: Strings.ok,
              ).show(context);
            }else{
              globals.returnDOCIDList.clear();
              for(int i = 0; i < returningList.length; i++){
                globals.returnDOCIDList.add(mylist[returningList[i]].documentID);
              }
              globals.ContextInOrder = context;
              PlatformAlertDialog(
                title: "Please Confirm",
                content: "You are returning $itemNum items:\n $itemName",
                defaultActionText: "Confirm",
                cancelActionText: "Cancel",
              ).show(context);
              setState(() {

              });
            }





//            titles.forEach((key, value) {
//
//              if (value == true) {
//                int i = index_map[key];
//                Firestore.instance
//                    .collection('reservation')
//                    .document(mylist[i].documentID)
//                    .delete();
//                setState(() {});
//              }
//            });

          },
          child: new Text("Confirm", style: TextStyle(color: textcolor())),
        );
      } else {
        return Container();
      }
    }

    Future<List<globals.ReservationItem>> getList() async {
      List<globals.ReservationItem> itemList = new List();
      var result =
          await Firestore.instance.collection(globals.collectionName).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;

      for (int i = 0; i < documents.length; i++) {
        if (documents[i]["name"] == "test") {
          Firestore.instance
              .collection(globals.collectionName)
              .document(documents[i].documentID)
              .delete();
        }
      }

      documents.forEach((ds) => itemList.add(globals.ReservationItem(
          ds["amount"],
          ds["startTime"],
          ds["endTime"],
          ds["item"],
          ds["status"],
          ds["uid"],
          ds["name"],
          ds["imageURL"],
          ds.documentID)));

      for (int i = 0; i < itemList.length; i++) {
        if (itemList[i].startTime == null || itemList[i].name == "test") {
          itemList.removeAt(i);
        }
      }

      List<globals.ReservationItem> copy_itemList = [];

      for(int i = 0 ; i < itemList.length; i++){
        copy_itemList.add(itemList[i]);
      }

      itemList.clear();


      for (int i = 0; i < copy_itemList.length; i++) {
        if (copy_itemList[i].uid == globals.uid &&
            copy_itemList[i].status == "Picked Up" &&
            copy_itemList[i].startTime != null ) {

          itemList.add(copy_itemList[i]);
        }
      }

      for (int i = 0; i < itemList.length - 1; i++) {
        for (int j = 0; j < itemList.length - i - 1; j++) {
          var a = itemList[j].startTime, b = itemList[j + 1].startTime;
          if (a == null || b == null) {
            continue;
          }

          if (isEarly(a, b) == false) {
            var swap = itemList[j];
            itemList[j] = itemList[j + 1];
            itemList[j + 1] = swap;
          }
        }
      }

      return itemList;
    }

    return new Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        title: Text('Orders', style: TextStyle(color: textcolor())),
        centerTitle: true,
        backgroundColor: backgroundcolor(),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.format_list_bulleted,
              color: textcolor(),
            ),
            onPressed: () async {
             
              isMultipleSeclect = !isMultipleSeclect;

              String test = "test";
              var url =
                  'https://firebasestorage.googleapis.com/v0/b/rentalmanager-f94f1.appspot.com/o/item_images%2FRock%20Wall%20ATC-Carabiner.jpg?alt=media&token=f0e605fa-ed3e-40c1-b0d9-186ce01e3ab4';
              await Firestore.instance
                  .collection(globals.collectionName)
                  .document()
                  .setData({
                'imageURL': url,
                'name': test,
                'item': 'FmkqMr7ta72O4eeDjal7',
                'uid': 'AppSignInUserjagaoabc@gmail.com',
                'amount': "1",
                'startTime': '2020-04-17 11:27:05',
                'status': "Reserved",
                'reserved time': '2020-04-17 11:27:05',
                'picked Up time': '2020-04-18 19:07:01',
                'return time': '2020-04-18 19:07:06',
                'endTime': "TBD",
              });
              var list = await getList();
              mylist = list;


              for (int i = 0; i < mylist.length; i++) {
                titles[mylist[i].name] = false;
                subtitles[mylist[i].name] = mylist[i].startTime;
                urls[mylist[i].name] = mylist[i].imageURL;
                index_map[mylist[i].name] = i;
              }
              deleteTestMode();
            },
          ),
        ],
      ),
      backgroundColor: backgroundcolor(),
      body: StreamBuilder(
          stream: Firestore.instance.collection(globals.collectionName).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('loading...');

            List<globals.ReservationItem> itemList = new List();

            deleteTestMode();

            if (isMultipleSeclect) {
              return Container(
                margin: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                child: ListView(
                  children: titles.keys.map((String key) {
                    return Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            a(index_map[key]),
                            b(index_map[key]),
                          ],
                        ),
                        new Theme(
                          data: ThemeData(unselectedWidgetColor: textcolor()),
                          child: CheckboxListTile(
                            activeColor: Colors.transparent,

                            title: new Text(key, style: TextStyle(color: textcolor()),),
                            subtitle: new Text(parseTime(subtitles[key]), style: TextStyle(color: textcolor()),),
                            secondary: CircleAvatar(
                              backgroundImage: NetworkImage(urls[key]),
                            ),
                            value: titles[key],
                            onChanged: (bool value) async {
                              titles[key] = value;
                              uploadMask();
                              deleteTestMode();
                            },
                          ),
                        ),
                        Divider(
                          height: 2.0,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            } else {
              final List<DocumentSnapshot> documents = snapshot.data.documents;

              for (int i = 0; i < documents.length; i++) {
                if (documents[i]["name"] == "test") {
                  Firestore.instance
                      .collection(globals.collectionName)
                      .document(documents[i].documentID)
                      .delete();
                }
              }

              documents.forEach((ds) => itemList.add(globals.ReservationItem(
                  ds["amount"],
                  ds["startTime"],
                  ds["endTime"],
                  ds["item"],
                  ds["status"],
                  ds["uid"],
                  ds["name"],
                  ds["imageURL"],
                  ds.documentID)));

              for (int i = 0; i < itemList.length; i++) {
                if (itemList[i].startTime == null ||
                    itemList[i].name == "test") {
                  itemList.removeAt(i);
                }
              }


              List<globals.ReservationItem> copy_itemList = [];

              for(int i = 0 ; i < itemList.length; i++){
                copy_itemList.add(itemList[i]);
              }

              itemList.clear();


              for (int i = 0; i < copy_itemList.length; i++) {
                if (copy_itemList[i].uid == globals.uid &&
                    copy_itemList[i].status == "Picked Up" &&
                    copy_itemList[i].startTime != null ) {

                    itemList.add(copy_itemList[i]);
                }
              }



              for (int i = 0; i < itemList.length - 1; i++) {
                for (int j = 0; j < itemList.length - i - 1; j++) {
                  var a = itemList[j].startTime, b = itemList[j + 1].startTime;
                  if (a == null || b == null) {
                    continue;
                  }

                  if (isEarly(a, b) == false) {
                    var swap = itemList[j];
                    itemList[j] = itemList[j + 1];
                    itemList[j + 1] = swap;
                  }
                }
              }
              titles = {};
              subtitles = {};
              urls = {};
              index_map = {};
              for (int i = 0; i < itemList.length; i++) {
                titles[itemList[i].name] = false;
                subtitles[itemList[i].name] = itemList[i].startTime;
                urls[itemList[i].name] = itemList[i].imageURL;
                index_map[itemList[i].name] = i;
              }
              return ListView.builder(
                  itemCount: itemList.length,
                  itemBuilder: (context, i) {
                    return Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(itemList[i].imageURL),
                            ),
                            trailing: new Icon(Icons.chevron_right, color: textcolor(),),
                            title: new Text(itemList[i].name, style: TextStyle(color: textcolor()) ),
                            subtitle: new Text(parseTime(itemList[i].startTime), style: TextStyle(color: textcolor())),
                            onTap: () {
                              var list = itemList;
                              var url = itemList[i].imageURL;
                              String value = itemInfo(list[i]);
                              //ItemInfo(person, date, item, status, start, Return)
                              String person = globals.username,
                                  date = list[i].startTime,
                                  item = list[i].name;
                              String status = list[i].status,
                                  start = list[i].startTime,
                                  Return = list[i].endTime;
                              String uid = list[i].uid,
                                  docuementID = list[i].documentID;
                              DateTime now = DateTime.now();
                              String timeNow =
                                  DateFormat('kk:mm:ss \n EEE d MMM')
                                      .format(now);

                              var theitem = ItemInfo(
                                  url,
                                  person,
                                  date,
                                  item,
                                  status,
                                  start,
                                  Return,
                                  timeNow,
                                  uid,
                                  docuementID);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Ticket(theitem)));
                            },
                          ),
                        ),
                        Divider(
                          height: 2.0,
                        ),
                      ],
                    );
                  });
            }
          }),
    );
  }
}

List<globals.ReservationItem> globallList = new List();

class ItemNameLocation {
  String itemName;
  String imageURL;
}

List<ItemNameLocation> myList = [];

String itemInfo(globals.ReservationItem item) {
  String ret = '';
  ret += 'Item Name:' + item.name + '\n';
  ret += 'Item Amount: ' + item.amount + '\n';
  ret += 'Item Status: ' + item.status + '\n';
  ret += 'Item Start Time: ' + item.startTime + '\n';
  ret += 'Item End Tiem: ' + item.endTime + '\n';
  return ret;
}

_buildFancyButtonOk(BuildContext context) {
  return AnimatedButton(
    pressEvent: () {
      Navigator.of(context).pop();
    },
    text: 'Ok',
    color: Color(0xFF00CA71),
  );
}

void GetImageURL(String uid) async {
  globals.itemList.clear();
  final QuerySnapshot result =
      await Firestore.instance.collection('ARC_items').getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  List<String> itemList = [];
  documents.forEach((data) => itemList.add(data.documentID));

  for (var i = 0; i < itemList.length; i++) {
    String currentOne = itemList[i];
    Firestore.instance
        .collection(globals.collectionName)
        .document('$currentOne')
        .get()
        .then((DocumentSnapshot ds) {
      // use ds as a snapshot
      if (currentOne == uid) {
        ItemNameLocation aItem;
        aItem.itemName = ds["name"];
        aItem.imageURL = ds["imageURL"];
        myList.add(aItem);
      }
    });
  }
}

class TicketView extends StatelessWidget {
  @override
  ItemInfo theItem;

  TicketView(theItem) {
    this.theItem = theItem;
  }
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Ticket(theItem),
    );
  }
}

class Ticket extends StatefulWidget {
  @override
  ItemInfo theItem;

  Ticket(ItemInfo theItem) {
    this.theItem = theItem;
  }
  _TicketState createState() => _TicketState(theItem);
}

class _TicketState extends State<Ticket> {
  ItemInfo theItem;

  _TicketState(ItemInfo theItem) {
    this.theItem = theItem;
  }

  GlobalKey theGlobalKey = new GlobalKey();

//  Future<void> _captureAndSharePng() async {
//    try {
//      RenderRepaintBoundary boundary = theGlobalKey.currentContext.findRenderObject();
//      var image = await boundary.toImage();
//      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
//      Uint8List pngBytes = byteData.buffer.asUint8List();
//      final tempDir = await getApplicationDocumentsDirectory();
//      final file = await new File('${tempDir.path}/image.png').create();
//      await file.writeAsBytes(pngBytes);
//      print(tempDir.path);
//      final channel = const MethodChannel('plugins.flutter.io/share');;
//      channel.invokeMethod('shareFile', 'image.png');
//
//      //final ByteData bytes = await image.toByteData(format: ImageByteFormat.png);
//
//
//    } catch(e) {
//      print(e.toString());
//    }
//  }

  @override
  Widget build(BuildContext context) {
    String person = theItem.person;
    String date = theItem.date.substring(0, 10);
    String item = theItem.item;
    String status = theItem.status;

    String start = theItem.start;
    start = start.substring(11);
    String Return = theItem.Return;
    String url = theItem.imageUrl;
    String uid = theItem.uid;
    String timeNow = theItem.timeNow;
    print(MediaQuery.of(context).size.width);

    var reservationID = theItem.documentID; // this is reservationID
    print(reservationID);

    File _imageFile;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        backgroundColor: backgroundcolor(),
        automaticallyImplyLeading: true,
        title: Text('Details', style: TextStyle(color: textcolor()),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              //Share.share('check out my website https://example.com', subject: 'ok', image: NetworkImage(globals.UserImageUrl) );

              // If the widget was removed from the tree while the asynchronous platform
              // message was in flight, we want to discard the reply rather than calling
              // setState to update our non-existent appearance.
              RenderRepaintBoundary boundary =
                  theGlobalKey.currentContext.findRenderObject();
              ui.Image image = await boundary.toImage();
              final directory = (await getApplicationDocumentsDirectory()).path;
              ByteData byteData =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              Uint8List pngBytes = byteData.buffer.asUint8List();

              try {
                await WcFlutterShare.share(
                    sharePopupTitle: 'Order Receipt',
                    fileName: 'Order Receipt.png',
                    mimeType: 'image/png',
                    bytesOfFile: pngBytes);
              } catch (e) {
                print(e.toString());
              }
              print("OK");
            },
          )
        ],
      ),
      backgroundColor: backgroundcolor(),
      body: Center(
        child: RepaintBoundary(
          key: theGlobalKey,
          child: FlutterTicketWidget(
            color: Colors.yellow,
            width: 350.0,
            height: 500.0,
            isCornerRounded: true,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 120.0,
                        height: 25.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60.0),
                          border: Border.all(width: 1.0, color: Colors.green),
                        ),
                        child: Center(
                          child: Text(
                            'The ARC',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.teal,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.teal,
                        backgroundImage: NetworkImage(url),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Column(
                      children: <Widget>[
                        ticketDetailsWidget(
                            'Person', '$person', 'Date', '$date'),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 12.0, right: 50.0),
                          child: ticketDetailsWidget(
                              'Item', '$item', 'Status', '$status'),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 12.0, right: 40.0),
                          child: ticketDetailsWidget(
                              'Start', '$start', 'Return', '$Return'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Center(
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: QrImage(
                          data: uid,
                          size: 0.3 * MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget ticketDetailsWidget(String firstTitle, String firstDesc,
      String secondTitle, String secondDesc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                firstTitle,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  firstDesc,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                secondTitle,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  secondDesc,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class Share {
  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/share');

  static Future<void> share(
    String text, {
    String subject,
    NetworkImage image,
    Rect sharePositionOrigin,
  }) {
    assert(text != null);
    assert(text.isNotEmpty);
    final Map<String, dynamic> params = <String, dynamic>{
      'text': text,
      'subject': subject,
      'image': image,
    };

    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }

    return channel.invokeMethod<void>('share', params);
  }
}

/*
*  Container(
              child: Column(children: <Widget>[

                Expanded(child:  LiquidPullToRefresh(
                  color: Colors.teal,
                  key: _refreshIndicatorKey,	// key if you want to add
                  onRefresh: _handleRefresh,
                  child: ListView(
                      padding: const EdgeInsets.all(20.0),
                      children:  _getListings(context, itemList)// <<<<< Note this change for the return type
                  ),
                ),
                )
              ]),
            );
*
*
* */
