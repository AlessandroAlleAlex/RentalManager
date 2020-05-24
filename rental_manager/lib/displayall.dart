import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rental_manager/CurrentReservation.dart';
import 'package:rental_manager/Locations/arc.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/manager/manage_locations.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'globals.dart' as globals;
import "package:http/http.dart" as http;
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart'
    as slideDialog;
import 'package:image_picker/image_picker.dart';
import 'package:validators/validators.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' show Platform;

import 'location_manager.dart';
import 'manager/manage_category.dart';

class Manager extends StatefulWidget {
  @override
  _ManagerState createState() => _ManagerState();
}

class _ManagerState extends State<Manager> {
  Future findLocationOfManager(BuildContext context) {
    return Firestore.instance
        .collection(returnLocationsCollection())
        .where('name', isEqualTo: globals.locationManager)
        .getDocuments()
        .then((doc) {
      doc.documents.forEach((element) {
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManageCategory(
                    data: element.data, documentID: element.documentID)));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: textcolor(), //change your color here
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.assessment,
                color: textcolor(),
              ),
              onPressed: () async {
                if (globals.isAdmin) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ManageLocations()));
                } else {
                  findLocationOfManager(context);
                }
              },
            ),
          ],
          title: Text(
            langaugeSetFunc('Manage'),
            style: TextStyle(color: textcolor()),
          ),
          centerTitle: true,
          backgroundColor: backgroundcolor(),
          bottom: TabBar(
            tabs: [
              Tab(
                  icon: Icon(
                Icons.book,
                color: textcolor(),
              )),
              Tab(
                  icon: Icon(
                Icons.people,
                color: textcolor(),
              )),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            booksTab(),
            peopleTab(),
          ],
        ),
      ),
    );
  }
}

class CSVItem {
  String name;
  int amount;
  String imageURL;
  CSVItem(this.name, this.amount, this.imageURL);
}

void pickUpFile(BuildContext context, cater, subCollectionName) async {
  String filelastnmae = "csv";
  String _extension = "csv";
  String mypath;
  try {
    print("OK");
    mypath = "";
    mypath += await FilePicker.getFilePath(
        type: FileType.custom,
        allowedExtensions: (filelastnmae?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '')?.split(',')
            : null);
  } catch (e) {
    print(e);
  }
  print(mypath);
  var thefile = File(mypath);
  contents = await thefile.readAsString();
  int start = 0;
  contents += "\n";
  List<String> contentsList = [];
  for (int i = 0; i < contents.length; i++) {
    if (contents[i] == "\n") {
      try {
        var substr = contents.substring(start, i);
        contentsList.add(contents.substring(start, i));
        //print(substr);
        if (i + 1 < contents.length) {
          start = i + 1;
        } else {
          start = i;
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  bool popWindow = false;
  for (int i = 0; i < contentsList.length; i++) {
    var element = contentsList[i];
    if (element.split(',').length > 3 || element.length < 2) {
      popWindow = true;
      break;
    }
  }

  if (popWindow) {
    pop_window(
        "Warning",
        "The CSV file format is not correct\nEach Row should have at least 2 indexs but at most three indexs : ItemName, Amount, imageURL(optional)",
        context);
  }

  List<List<String>> ListOfItemInfor = [];

  contentsList.forEach((element) {
    List<String> temp = element.split(',');
    ListOfItemInfor.add(temp);
  });

  List<CSVItem> CSVItemList = [];
  bool isadded = true;
  String errorName = "";
  for (int i = 0; i < ListOfItemInfor.length; i++) {
    var element = ListOfItemInfor[i];
    int amount = 0;
    String name = "",
        imageURL =
            'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png';

    if (element.length == 2) {
      name = element[0];
      if (isDigit(element[1])) {
        amount = int.parse(element[1]);
      } else {
        errorName = element[1];
        isadded = false;
        break;
      }
    } else if (element.length == 3) {
      name = element[0];
      if (isDigit(element[1])) {
        amount = int.parse(element[1]);
      } else {
        errorName = element[1];
        isadded = false;
        break;
      }
      imageURL = element[2];
    }
    CSVItemList.add(CSVItem(name, amount, imageURL));
  }

  if (isadded) {
    var map = {};

    for (int i = 0; i < CSVItemList.length; i++) {
      map[i] = "New";
    }
    QuerySnapshot list = await Firestore.instance
        .collection('TempItemCollectionHold')
        .document(subCollectionName)
        .collection('item')
        .getDocuments();
    for (int i = 0; i < list.documents.length; i++) {
      var ds = list.documents[i];

      for (int i = 0; i < CSVItemList.length; i++) {
        try {
          if (CSVItemList[i].name == ds["name"]) {
            map[i] = ds.documentID;
            break;
          }
        } catch (e) {
          print(e);
        }
      }
    }

    for (int i = 0; i < CSVItemList.length; i++) {
      if (map[i] == "New") {
        await Firestore.instance
            .collection('TempItemCollectionHold')
            .document(subCollectionName)
            .collection('item')
            .document()
            .setData({
          'name': CSVItemList[i].name,
          'status': 'Hold',
          'imageURL': CSVItemList[i].imageURL,
          'amount': CSVItemList[i].amount,
        });
      } else {
        await Firestore.instance
            .collection('TempItemCollectionHold')
            .document(subCollectionName)
            .collection('item')
            .document(map[i])
            .updateData({
          'name': CSVItemList[i].name,
          'status': 'Hold',
          'imageURL': CSVItemList[i].imageURL,
          'amount': CSVItemList[i].amount,
        });
      }
    }
  } else {
    pop_window(
        langaugeSetFunc('Warning'),
        langaugeSetFunc(
            'The item $errorName\'s amount must be an integer. Please double check with that'),
        context);
  }
}

bool isDigit(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

class booksTab extends StatefulWidget {
  @override
  _booksTabState createState() => _booksTabState();
}

class manageItemInfor {
  String name;
  String imageURL;
  String amount;
  String startTime;
  String endTime;
  String itemDocID;
  String status;
  String uid;
  String documentID;
  String userName;
  String returnTime;
  String pickUpTime;
  //ReservationItem(this.amount, this.startTime, this.endTime, this.itemDocID, this.status, this.uid, this.name, this.imageURL);
  manageItemInfor(
      this.amount,
      this.startTime,
      this.endTime,
      this.itemDocID,
      this.status,
      this.uid,
      this.name,
      this.imageURL,
      this.documentID,
      this.userName,
      this.returnTime,
      this.pickUpTime);
}

class _booksTabState extends State<booksTab> {
  @override
  String returnDifferenceTime(
      String reservationTime, String pickUpTime, String returnTime) {
    if (returnTime != null && returnTime.isNotEmpty) {
      if (returnTime != "NULL") {
        reservationTime = returnTime;
      }
    } else {
      if (pickUpTime != null && pickUpTime.isNotEmpty) {
        if (pickUpTime != "NULL") {
          pickUpTime = reservationTime;
        }
      }
    }

    var validTime = DateTime.parse(reservationTime);
    var difference = DateTime.now().difference(validTime);
    String ans = "NULL";
    var a = difference.inSeconds,
        b = difference.inMinutes,
        c = difference.inHours,
        d = difference.inDays;
    if (a < 60) {
      var tmp = "seconds";
      if (a == 1) {
        tmp = "second";
      }
      ans = "$a $tmp ago";
    } else if (b >= 1 && b <= 60) {
      var tmp = "minutes";
      if (b == 1) {
        tmp = "minute";
      }
      ans = "$b $tmp ago";
    } else if (c >= 1 && c <= 24) {
      var tmp = "hours";
      if (c == 1) {
        tmp = "hour";
      }
      ans = "$c $tmp ago";
    } else if (d >= 1) {
      var tmp = "days";
      if (d == 1) {
        tmp = "day";
      }
      ans = "$d $tmp ago";
    }
    return ans;
  }

  Widget build(BuildContext context) {
    bool isEarly(String a, String b) {
      var time_a = DateTime.parse(a), time_b = DateTime.parse(b);

      var difference = time_a.difference(time_b);
      return !difference.isNegative;
    }

    return Scaffold(
      backgroundColor: backgroundcolor(),
      body: StreamBuilder(
          // stream: globals.isAdmin ? Firestore.instance
          //     .collection(returnReservationCollection())
          //     .snapshots() : globals.locationManager != "" ? globals.isAdmin ? Firestore.instance
          //     .collection(returnReservationCollection()).where() // we need to add location to reservations on Firestore
          //     .snapshots() : Container(),
          stream: Firestore.instance
              .collection(returnReservationCollection())
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('loading...');
            List<String> userNameList = [];
            final List<DocumentSnapshot> documents = snapshot.data.documents;
            List<manageItemInfor> itemList = new List();
            documents.forEach((ds) => itemList.add(manageItemInfor(
                  ds["amount"],
                  ds["startTime"],
                  ds["endTime"],
                  ds["item"],
                  ds["status"],
                  ds["uid"],
                  ds['name'],
                  ds["imageURL"],
                  ds.documentID,
                  ds["UserName"],
                  ds["return time"],
                  ds["picked Up time"],
                )));

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

            return ListView.builder(
                itemCount: itemList.length,
                itemBuilder: (context, i) {
                  return Column(
                    children: <Widget>[
                      Container(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(itemList[i].imageURL),
                          ),
                          trailing: new Text(
                              returnDifferenceTime(
                                  itemList[i].startTime,
                                  itemList[i].pickUpTime,
                                  itemList[i].returnTime),
                              style: TextStyle(color: textcolor())),
                          title: new Text(itemList[i].name,
                              style: TextStyle(color: textcolor())),
                          subtitle: new Text(
                              itemList[i].status +
                                  " by " +
                                  itemList[i].userName,
                              style: TextStyle(color: textcolor())),
                          onTap: () {},
                        ),
                      ),
                      Divider(
                        height: 2.0,
                      ),
                    ],
                  );
                });
          }),
    );
  }
}

class peopleTab extends StatefulWidget {
  @override
  _peopleTabState createState() => _peopleTabState();
}

class personInfo {
  String name;
  String StudentID;
  String email;
  String imageURL;
  String phoneNumber;
  String latestTime;
  String locationManager;
  personInfo(this.name, this.StudentID, this.email, this.imageURL,
      this.phoneNumber, this.latestTime, this.locationManager);
}

class startAndUid {
  String startTime;
  String uid;
  startAndUid(this.startTime, this.uid);
}

class _peopleTabState extends State<peopleTab> {
  @override
  String returnDifferenceTime(String reservationTime) {
    var validTime = DateTime.parse(reservationTime);
    var difference = DateTime.now().difference(validTime);
    String ans = "NULL";
    var a = difference.inSeconds,
        b = difference.inMinutes,
        c = difference.inHours,
        d = difference.inDays;
    if (a < 60) {
      var tmp = "seconds";
      if (a == 1) {
        tmp = "second";
      }
      ans = "$a $tmp ago";
    } else if (b >= 1 && b <= 60) {
      var tmp = "minutes";
      if (b == 1) {
        tmp = "minute";
      }
      ans = "$b $tmp ago";
    } else if (c >= 1 && c <= 24) {
      var tmp = "hours";
      if (c == 1) {
        tmp = "hour";
      }
      ans = "$c $tmp ago";
    } else if (d >= 1) {
      var tmp = "days";
      if (d == 1) {
        tmp = "day";
      }
      ans = "$d $tmp ago";
    }
    return ans;
  }

  String cutEmail(String email) {
    var i = email.indexOf("User");
    if (i != -1) {
      return (email.substring(i + 4));
    }
    return email;
  }

  NetworkImage getImage(String url) {
    if (url == null || url.length == 0) {
      return NetworkImage(
          'https://images.unsplash.com/photo-1588342188135-ead0d7aa393e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1050&q=80');
    } else {
      return NetworkImage(url);
    }
  }

  List<startAndUid> uidList = [];

  int compareFunc(String a, String b) {
    var time_a = DateTime.parse(a), time_b = DateTime.parse(b);

    var difference = time_a.difference(time_b);
    if (difference.isNegative == true) {
      return 1;
    } else {
      return 0;
    }
  }

  void setUidList() async {}

  String returnLatestTime(String latestTime) {
    print("latestTime: " + latestTime);

    if (latestTime != null && latestTime.length > 0) {
      return returnDifferenceTime(latestTime);
    }

    return "Non-Active";
  }

  Widget build(BuildContext context) {
    setUidList();
    return Scaffold(
      backgroundColor: backgroundcolor(),
      body: StreamBuilder(
          stream:
              Firestore.instance.collection(returnUserCollection()).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('loading...');
            final List<DocumentSnapshot> documents = snapshot.data.documents;
            List<personInfo> peopleList = [];
            try {
              peopleList.clear();
              documents.forEach((element) {
                String value;
                if (element["LatestReservation"] == null ||
                    element["LatestReservation"].length == 0) {
                  value = "";
                } else {
                  value = element["LatestReservation"];
                }
                var name = element[globals.nameDababase],
                    StudentID = element[globals.rentalIDDatabase],
                    email = element["Email"];
                var imageURL = element["imageURL"],
                    phoneNumber = element["PhoneNumber"],
                    latestTime = value;
                if (name == null) {
                } else {
                  var tmp = personInfo(name, StudentID, email, imageURL,
                      phoneNumber, latestTime, element["LocationManager"]);
                  if (tmp != null) {
                    peopleList.add(tmp);
                  } else {}
                }
              });
            } catch (e) {
              print("a: " + e.toString());
            }
            //setUidList();

            return ListView.builder(
                itemCount: peopleList.length,
                itemBuilder: (context, i) {
                  return Column(
                    children: <Widget>[
                      Container(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: getImage(peopleList[i].imageURL),
                          ),
                          trailing: new Text(
                              returnLatestTime(peopleList[i].latestTime),
                              style: TextStyle(color: textcolor())),
                          title: new Text(peopleList[i].name,
                              style: TextStyle(color: textcolor())),
                          subtitle: new Text(cutEmail(peopleList[i].email),
                              style: TextStyle(color: textcolor())),
                          onTap: () {
                            if (returnLatestTime(peopleList[i].latestTime)
                                .contains("Non")) {
                              pop_window(
                                  "Sorry",
                                  "It appears that no reservations exist in this account",
                                  context);
                            } else {
                              var uid = peopleList[i].email;
                              var name = peopleList[i].name;
                              var locationManager =
                                  peopleList[i].locationManager;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => managepeopleOrders(
                                          uid, name, locationManager)));
                            }
                          },
                        ),
                      ),
                      Divider(
                        height: 2.0,
                      ),
                    ],
                  );
                });
          }),
    );
  }
}

class managepeopleOrders extends StatefulWidget {
  String uid;
  String name;
  String locationManager;
  managepeopleOrders(this.uid, this.name, this.locationManager);
  _managepeopleOrdersState createState() => _managepeopleOrdersState();
}

void test(DocumentSnapshot ds, uid) {
  return ds.data["uid"] = uid;
}

class _managepeopleOrdersState extends State<managepeopleOrders> {
  Icon returnAdminOrnot() {
    if (globals.isAdmin) {
      return Icon(Icons.lock_open);
    } else {
      return Icon(Icons.lock);
    }
  }

  Future _dialogrem(
    BuildContext context,
    String name,
  ) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Removed Successfully',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            content: Text('$name is NOT a manager anymore.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Done',
                      style: TextStyle(fontWeight: FontWeight.bold)))
            ],
          );
        });
  }

  Future _dialog(BuildContext context, String name, int index) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: index == 1
                ? Text(
                    'Removed Successfully',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  )
                : Text(
                    'Added Successfully',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
            content: index == 1
                ? Text('$name is NOT a manager anymore.',
                    style: TextStyle(fontWeight: FontWeight.bold))
                : Text('$name is now ${globals.locationManager}\'s manager'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text('Done',
                      style: TextStyle(fontWeight: FontWeight.bold)))
            ],
          );
        });
  }

  Future _dialogSelfDelete(BuildContext context, String name) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Removed Successfully',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            content: Text('$name is NOT a manager anymore.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/MainViewScreen');
                  },
                  child: Text('Done',
                      style: TextStyle(fontWeight: FontWeight.bold)))
            ],
          );
        });
  }

  Future removeLocationManager(String correctUID) {
    return Firestore.instance
        .collection('global_users')
        .document(correctUID)
        .updateData({'LocationManager': ""});
  }

  Future locationManagerAdd(String correctUID) {
    return Firestore.instance
        .collection('global_users')
        .document(correctUID)
        .updateData({'LocationManager': globals.locationManager});
  }

  Widget build(BuildContext context) {
    String uid = this.widget.uid,
        name = this.widget.name,
        userLocationManager = widget.locationManager;
    String correctUID = 'AppSignInUser' + uid;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        backgroundColor: backgroundcolor(),
        title: Text('$name \'s ' + langaugeSetFunc('Orders'),
            style: TextStyle(color: textcolor())),
        actions: <Widget>[
          userLocationManager != ""
              ? FlatButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text('$userLocationManager'),
                  onPressed: () {
                    removeLocationManager(correctUID).whenComplete(() {
                      if (globals.uid == correctUID) {
                        globals.locationManager = "";
                        _dialogSelfDelete(context, name);
                      } else {
                        _dialog(context, name, 1);
                      }
                    });
                  },
                )
              : FlatButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('As Manager'),
                  onPressed: () => globals.isAdmin
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LocationManager(uid: correctUID, name: name),
                          ),
                        )
                      : globals.locationManager != ""
                          ? locationManagerAdd(correctUID)
                              .whenComplete(() => _dialog(context, name, 2))
                          : Container(),
                ),
          // IconButton(
          //   icon: returnAdminOrnot(),
          //   onPressed: () async {
          //     String title = "Warning", content = "", actionText = "";
          //     if (globals.isAdmin) {
          //       content =
          //           "$name is a admin. Do you want to lock his access and let him become a user";
          //       actionText = "Lock";
          //     } else {
          //       content =
          //           "$name is a user. Do you want to un-lock his access and let him become a admin";
          //       actionText = "Unlock";
          //     }
          //     PlatformAlertDialog(
          //       title: title,
          //       content: content,
          //       cancelActionText: "Cancel",
          //       defaultActionText: actionText,
          //     ).show(context);
          //   },
          // ),
        ],
      ),
      backgroundColor: backgroundcolor(),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection(returnReservationCollection())
              .snapshots(),
          builder: (context, snapshot) {
            List<globals.ReservationItem> itemList = new List();
            try {
              final List<DocumentSnapshot> documents = snapshot.data.documents;
              print(documents == null);

              documents.forEach((ds) {
                if (uid == ds["uid"]) {
                  itemList.add(globals.ReservationItem(
                      ds["amount"],
                      ds["startTime"],
                      ds["endTime"],
                      ds["item"],
                      ds["status"],
                      ds["uid"],
                      ds["name"],
                      ds["imageURL"],
                      ds.documentID));
                }
              });
            } catch (e) {
              print(e.toString());
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
                            backgroundImage: NetworkImage(itemList[i].imageURL),
                          ),
                          trailing: new Icon(
                            Icons.chevron_right,
                            color: textcolor(),
                          ),
                          title: new Text(itemList[i].name,
                              style: TextStyle(color: textcolor())),
                          subtitle: new Text(parseTime(itemList[i].startTime),
                              style: TextStyle(color: textcolor())),
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
                                DateFormat('kk:mm:ss \n EEE d MMM').format(now);

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

//                            Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (context) => Ticket(theitem)));
                          },
                        ),
                      ),
                      Divider(
                        height: 2.0,
                      ),
                    ],
                  );
                });
          }),
    );
  }
}

class ManageDatabase extends StatefulWidget {
  String catergory;
  String locationName;
  ManageDatabase({this.catergory, this.locationName});

  @override
  _ManageDatabaseState createState() => _ManageDatabaseState();
}

class ItemInformation {
  String name;
  int amount;
  String imageURL;
  String documentID;
  ItemInformation(this.name, this.amount, this.imageURL, this.documentID);
}

Future<bool> urlCheck(String url) async {
  try {
    final response = await http.head(url);

    if (response.statusCode != 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print(e.toString());
  }
  return false;
}

class _ManageDatabaseState extends State<ManageDatabase> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  void _showDialog(ItemInformation item) {
    int amount = item.amount;
    String name = item.name,
        imageURL = item.imageURL,
        documentID = item.documentID;
    String modifyName = name,
        modifyimageURL = item.imageURL,
        inputImageURL = "";
    int modifyAmount = amount;
    void submit() async {
      final form = _formKey.currentState;
      if (form.validate()) {
        print(modifyName);
        print(modifyAmount);
        print(modifyimageURL);
        if (inputImageURL.isNotEmpty) {
          modifyimageURL = inputImageURL;
        }
        await Firestore.instance
            .collection(returnItemCollection())
            .document(documentID)
            .updateData({
          '# of items': modifyAmount,
          'imageURL': modifyimageURL,
          'name': modifyName,
          'category': widget.catergory,
        });

        pop_window(
            "Succeed", "You should see the change on the list soon", context);
      }
    }

    slideDialog.showSlideDialog(
      context: context,
      child: StreamBuilder(
          stream: Firestore.instance
              .collection('imageTmp')
              .document(globals.uid)
              .snapshots(),
          builder: (context, snapshot) {
            String theurl =
                "https://images.unsplash.com/photo-1588693273928-92fa26159c88?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=975&q=80";
            try {
              var ds = snapshot.data;
              theurl = ds.data["imageURL"];
            } catch (e) {
              print(e.toString());
            }
            return Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Text(langaugeSetFunc('Click Image to Change')),
                    InkWell(
                      onTap: () async {
                        ProgressDialog prUpdate;
                        prUpdate = new ProgressDialog(context,
                            type: ProgressDialogType.Normal);
                        prUpdate.style(message: 'Showing some progress...');
                        prUpdate.update(
                          message: 'Uploading...',
                          progressWidget: CircularProgressIndicator(),
                          progressTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400),
                          messageTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 19.0,
                              fontWeight: FontWeight.w600),
                        );

                        File imageFile;
                        imageFile = await ImagePicker.pickImage(
                            source: ImageSource.gallery);

                        if (imageFile != null) {
                          await prUpdate.show();
                          StorageReference reference = FirebaseStorage.instance
                              .ref()
                              .child(imageFile.path.toString());
                          StorageUploadTask uploadTask =
                              reference.putFile(imageFile);

                          StorageTaskSnapshot downloadUrl =
                              (await uploadTask.onComplete);

                          String url = (await downloadUrl.ref.getDownloadURL());
                          prUpdate.update(
                            message: 'Complete',
                            progressWidget: CircularProgressIndicator(),
                            progressTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w400),
                            messageTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 19.0,
                                fontWeight: FontWeight.w600),
                          );
                          await Firestore.instance
                              .collection('imageTmp')
                              .document(globals.uid)
                              .setData({
                            'imageURL': '$url',
                          });
                          modifyimageURL = url;
                          print("URL:" + url);
                          prUpdate.hide();
                        }
                      },
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.teal,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal,
                          backgroundImage: NetworkImage(theurl),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Use Image URL Instead'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        onChanged: (text) {
                          inputImageURL = text;
                        },
                        validator: (String val) {
                          print(val);
                          if (val == null || val.isEmpty) {
                            return null;
                          } else {
                            if (modifyimageURL != imageURL &&
                                inputImageURL.isNotEmpty) {
                              return "Cannot use image URL after uploading a new image";
                            }
                            var match = isURL(val, requireTld: true);
                            print("Match: " + match.toString());
                            if (match) {
                              return null;
                            } else {
                              return "InValid URL";
                            }
                          }
                        },
                        onSaved: (value) {
                          inputImageURL = value;
                        },
                        decoration: new InputDecoration(
                            hintText: langaugeSetFunc(
                                "Leave it empty if this is not used"),
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Item Name'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        initialValue: name,
                        onChanged: (text) {
                          modifyName = text;
                        },
                        validator: (String val) {
                          if (val.isEmpty) {
                            return 'This Field Cannot Be Empty';
                          }
                          bool found = false;
                          for (int i = 0; i < itemNameList.length; i++) {
                            if (itemNameList[i] == val && name != val) {
                              found = true;
                              break;
                            }
                          }

                          if (found) {
                            return langaugeSetFunc(
                                "This name has been used. Please try another one");
                          }

                          return null;
                        },
                        onSaved: (value) {},
                        decoration: new InputDecoration(
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Item Amount'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        initialValue: amount.toString(),
                        onChanged: (text) {
                          modifyAmount = int.parse(text);
                        },
                        validator: (String val) {
                          int amount = int.parse(val);
                          if (val.isEmpty) {
                            return 'This Field Cannot Be Empty';
                          } else if (amount == 0) {
                            return "Amount Cannot Be 0";
                          }
                          return null;
                        },
                        onSaved: (value) {},
                        decoration: new InputDecoration(
                            hintText: amount.toString(),
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                        keyboardType: TextInputType.number,
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
                      child: RaisedButton(
                        highlightElevation: 0.0,
                        splashColor: Colors.greenAccent,
                        highlightColor: Colors.green,
                        elevation: 0.0,
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Text(
                                langaugeSetFunc('Submit'),
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
                        onPressed: () async {
                          submit();
                        },
                        padding: EdgeInsets.all(7.0),
                        //color: Colors.teal.shade900,
                        disabledColor: Colors.black,
                        disabledTextColor: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
                      child: RaisedButton(
                        highlightElevation: 0.0,
                        splashColor: Colors.greenAccent,
                        highlightColor: Colors.red,
                        elevation: 0.0,
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Text(
                                langaugeSetFunc('Delete'),
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
                        onPressed: () async {
                          globals.documentItemIDInManageView = "";
                          globals.documentItemIDInManageView = documentID;
                          globals.contextInManageOneItemView = context;
                          PlatformAlertDialog(
                            title: "Warning",
                            content: "Are you going to delete this item",
                            defaultActionText: "Delete",
                            cancelActionText: "Cancel",
                          ).show(context);
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
            );
          }),
      textField: Container(
        child: Column(
          children: <Widget>[],
        ),
      ),
      barrierColor: Colors.white.withOpacity(0.7),
    );
  }

  void _showDialog2() {
    String modifyName = "",
        modifyimageURL =
            'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png',
        inputImageURL = "";
    int modifyAmount = 0;
    void submit() async {
      final form = _formKey.currentState;
      if (form.validate()) {
        if (modifyimageURL ==
                'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png' &&
            inputImageURL.isNotEmpty) {
          modifyimageURL = inputImageURL;
        }

        await Firestore.instance
            .collection(returnItemCollection())
            .document("123")
            .setData({
          '# of items': modifyAmount,
          'category': widget.catergory,
          'imageURL': modifyimageURL,
          'name': modifyName,
          'Location': this.widget.locationName,
        });
        pop_window('Succeed', "Upload a item Successfully", context);
      }
    }

    NetworkImage Netimage() {
      return NetworkImage(modifyimageURL);
    }

    slideDialog.showSlideDialog(
      context: context,
      child: StreamBuilder(
          stream: Firestore.instance
              .collection('imageTmp')
              .document(globals.uid)
              .snapshots(),
          builder: (context, snapshot) {
            String theurl =
                'https://images.unsplash.com/photo-1588693273928-92fa26159c88?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=975&q=80';
            try {
              var ds = snapshot.data;
              theurl = ds.data["imageURL"];
            } catch (e) {
              print(e.toString());
            }
            print(theurl);
            return Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Text(langaugeSetFunc('Click Image to Change')),
                    InkWell(
                      onTap: () async {
                        ProgressDialog prUpdate;
                        prUpdate = new ProgressDialog(context,
                            type: ProgressDialogType.Normal);
                        prUpdate.style(message: 'Showing some progress...');
                        prUpdate.update(
                          message: 'Uploading...',
                          progressWidget: CircularProgressIndicator(),
                          progressTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400),
                          messageTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 19.0,
                              fontWeight: FontWeight.w600),
                        );

                        File imageFile;
                        imageFile = await ImagePicker.pickImage(
                            source: ImageSource.gallery);

                        if (imageFile != null) {
                          await prUpdate.show();
                          StorageReference reference = FirebaseStorage.instance
                              .ref()
                              .child(imageFile.path.toString());
                          StorageUploadTask uploadTask =
                              reference.putFile(imageFile);

                          StorageTaskSnapshot downloadUrl =
                              (await uploadTask.onComplete);

                          String url = (await downloadUrl.ref.getDownloadURL());
                          prUpdate.update(
                            message: 'Complete',
                            progressWidget: CircularProgressIndicator(),
                            progressTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w400),
                            messageTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 19.0,
                                fontWeight: FontWeight.w600),
                          );
                          await Firestore.instance
                              .collection('imageTmp')
                              .document(globals.uid)
                              .setData({
                            'imageURL': '$url',
                          });
                          setState(() {
                            modifyimageURL = url;
                          });
                          modifyimageURL = url;
                          print("URL:" + url);
                          prUpdate.hide();
                        }
                      },
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.teal,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal,
                          backgroundImage: NetworkImage(theurl),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Use Image URL Instead'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        onChanged: (text) {
                          inputImageURL = text;
                        },
                        validator: (String val) {
                          print(val);
                          if (val == null || val.isEmpty) {
                            return null;
                          } else {
                            if (modifyimageURL !=
                                    'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png' &&
                                inputImageURL.isNotEmpty) {
                              return langaugeSetFunc(
                                  "Cannot use image URL after uploading a new image");
                            }
                            var match = isURL(val, requireTld: true);
                            print("Match: " + match.toString());
                            if (match) {
                              return null;
                            } else {
                              return langaugeSetFunc("InValid URL");
                            }
                          }
                        },
                        onSaved: (value) {
                          inputImageURL = value;
                        },
                        decoration: new InputDecoration(
                            hintText: langaugeSetFunc(
                                "Leave it empty if this is not used"),
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Item Name'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        initialValue: modifyName,
                        onChanged: (text) {
                          modifyName = text;
                        },
                        validator: (String val) {
                          if (val.isEmpty) {
                            return langaugeSetFunc(
                                'This Field Cannot Be Empty');
                          }

                          bool found = false;

                          for (int i = 0; i < itemNameList.length; i++) {
                            if (itemNameList[i] == val) {
                              found = true;
                              break;
                            }
                          }

                          if (found) {
                            return langaugeSetFunc(
                                "This name has been used. Please try another one");
                          }

                          return null;
                        },
                        onSaved: (value) {},
                        decoration: new InputDecoration(
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Item Amount'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        initialValue: modifyAmount.toString(),
                        onChanged: (text) {
                          modifyAmount = int.parse(text);
                        },
                        validator: (String val) {
                          if (val.isEmpty) {
                            return 'This Field Cannot Be Empty';
                          } else {
                            var amount = int.parse(val);

                            if (amount == 0) {
                              return "Amount Cannot Be 0";
                            }
                          }
                          return null;
                        },
                        onSaved: (value) {},
                        decoration: new InputDecoration(
                            hintText: modifyAmount.toString(),
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                        keyboardType: TextInputType.number,
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
                      child: RaisedButton(
                        highlightElevation: 0.0,
                        splashColor: Colors.greenAccent,
                        highlightColor: Colors.green,
                        elevation: 0.0,
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Text(
                                langaugeSetFunc('Submit'),
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
                        onPressed: () async {
                          submit();
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
            );
          }),
      textField: Container(
        child: Column(
          children: <Widget>[],
        ),
      ),
      barrierColor: Colors.white.withOpacity(0.7),
    );
  }

  List<String> itemNameList = [];
  @override
  Widget build(BuildContext context) {
    String cater = this.widget.catergory;
    globals.contextInManageItemView = context;
    List<String> _locations = ['A', 'B', 'C', 'D']; // Option 2
    String _selectedLocation; // Option 2
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        title: Text(
          langaugeSetFunc("Manage your Database"),
          style: TextStyle(color: textcolor()),
        ),
        backgroundColor: backgroundcolor(),
        actions: <Widget>[
          new PopupMenuButton(
              icon: Icon(Icons.add, color: textcolor()),
              onSelected: (String value) async {
                if ("Add items manually" == value) {
                  await Firestore.instance
                      .collection('imageTmp')
                      .document(globals.uid)
                      .setData({
                    'imageURL':
                        'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png',
                  });
                  _showDialog2();
                } else if (value == "Upload a CSV file") {
//                  pop_window(
//                      "Warning",
//                      "You will use a csv file with name amount imageURL(Optional) to add item(s)",
//                      context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => upLoadCSV(this.widget.catergory,
                              this.widget.locationName)));
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    new PopupMenuItem(
                        value: "Upload a CSV file",
                        child: new Text(
                            langaugeSetFunc("Add items via a CSV file"))),
                    new PopupMenuItem(
                        value: "Add items manually",
                        child: new Text(langaugeSetFunc("Add items manually"))),
                  ]),
        ],
      ),
      backgroundColor: backgroundcolor(),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection(returnItemCollection())
              .where('category', isEqualTo: this.widget.catergory)
              .where('Location', isEqualTo: this.widget.locationName)
              .snapshots(),
          builder: (context, snapshot) {
            List<ItemInformation> itemList = new List();

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text(
                  langaugeSetFunc('Loading...'),
                  style: TextStyle(color: textcolor()),
                ),
              );
            } else {
              try {
                final List<DocumentSnapshot> documents =
                    snapshot.data.documents;
                itemNameList.clear();
                documents.forEach((element) {
                  itemNameList.add(element['name']);
                  itemList.add(ItemInformation(
                      element['name'],
                      element['# of items'],
                      element['imageURL'],
                      element.documentID));
                });
              } catch (e) {
                print(e.toString());
              }
            }

            return ListView.builder(
                itemCount: itemList.length,
                itemBuilder: (context, i) {
                  return Column(
                    children: <Widget>[
                      Container(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(itemList[i].imageURL),
                          ),
                          trailing: new Icon(
                            Icons.chevron_right,
                            color: textcolor(),
                          ),
                          title: new Text(itemList[i].name,
                              style: TextStyle(color: textcolor())),
                          subtitle: new Text(
                              langaugeSetFunc('Amount:') +
                                  itemList[i].amount.toString(),
                              style: TextStyle(color: textcolor())),
                          onTap: () async {
                            String imageURL = itemList[i].imageURL;
                            await Firestore.instance
                                .collection('imageTmp')
                                .document(globals.uid)
                                .setData({
                              'imageURL': '$imageURL',
                            });
                            _showDialog(itemList[i]);
                          },
                        ),
                      ),
                      Divider(
                        height: 2.0,
                      ),
                    ],
                  );
                });
          }),
    );
  }
}

class OnHoldItems {
  String name;
  int amount;
  String imageURL;
  String status;
  String documentID;
  OnHoldItems(
      this.name, this.amount, this.imageURL, this.status, this.documentID);
}

Widget switchButton(OnHoldItems aitem, subCollectionName) {
  bool val = false;
  if (aitem.status == 'Hold') {
    val = true;
  }

  if (Platform.isAndroid == true) {
    return Switch(
      value: val,
      onChanged: (value) async {
        String result = 'hide';

        if (value == true) {
          result = 'Hold';
        }

        await Firestore.instance
            .collection('TempItemCollectionHold')
            .document(subCollectionName)
            .collection('item')
            .document(aitem.documentID)
            .updateData({
          'status': result,
        });
      },
    );
  }

  return CupertinoSwitch(
    value: val,
    onChanged: (bool value) async {
      String result = 'hide';

      if (value == true) {
        result = 'Hold';
      }

      await Firestore.instance
          .collection('TempItemCollectionHold')
          .document(subCollectionName)
          .collection('item')
          .document(aitem.documentID)
          .updateData({
        'status': result,
      });
    },
  );
}

class upLoadCSV extends StatefulWidget {
  String cater = "";
  String locationName = "";
  upLoadCSV(this.cater, this.locationName);
  @override
  _upLoadCSVState createState() => _upLoadCSVState();
}

BuildContext maincontxt;

class _upLoadCSVState extends State<upLoadCSV> {
  @override
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String subCollectionName = "";
  void _showDialog(OnHoldItems item) {
    int amount = item.amount;
    String name = item.name,
        imageURL = item.imageURL,
        documentID = item.documentID;
    String modifyName = name,
        modifyimageURL = item.imageURL,
        inputImageURL = '';
    int modifyAmount = amount;
    void submit() async {
      final form = _formKey.currentState;
      if (form.validate()) {
        print(modifyName);
        print(modifyAmount);
        print(modifyimageURL);
        if (inputImageURL.isNotEmpty) {
          modifyimageURL = imageURL;
        }
        await Firestore.instance
            .collection('TempItemCollectionHold')
            .document(subCollectionName)
            .collection('item')
            .document(item.documentID)
            .updateData({
          'amount': modifyAmount,
          'imageURL': modifyimageURL,
          'name': modifyName,
        });

        pop_window(
            "Succeed", "You should see the change on the list soon", context);
      }
    }

    slideDialog.showSlideDialog(
      context: context,
      child: StreamBuilder(
          stream: Firestore.instance
              .collection('TempItemCollectionHold')
              .document(subCollectionName)
              .collection('imageTemp')
              .document(item.documentID)
              .snapshots(),
          builder: (context, snapshot) {
            String theurl = imageURL;
            try {
              var ds = snapshot.data;
              theurl = ds.data["imageURL"];
            } catch (e) {
              print(e.toString());
            }
            return Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Text(langaugeSetFunc('Click Image to Change')),
                    InkWell(
                      onTap: () async {
                        ProgressDialog prUpdate;
                        prUpdate = new ProgressDialog(context,
                            type: ProgressDialogType.Normal);
                        prUpdate.style(message: 'Showing some progress...');
                        prUpdate.update(
                          message: 'Uploading...',
                          progressWidget: CircularProgressIndicator(),
                          progressTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400),
                          messageTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 19.0,
                              fontWeight: FontWeight.w600),
                        );

                        File imageFile;
                        imageFile = await ImagePicker.pickImage(
                            source: ImageSource.gallery);

                        if (imageFile != null) {
                          await prUpdate.show();
                          StorageReference reference = FirebaseStorage.instance
                              .ref()
                              .child(imageFile.path.toString());
                          StorageUploadTask uploadTask =
                              reference.putFile(imageFile);

                          StorageTaskSnapshot downloadUrl =
                              (await uploadTask.onComplete);

                          String url = (await downloadUrl.ref.getDownloadURL());
                          prUpdate.update(
                            message: 'Complete',
                            progressWidget: CircularProgressIndicator(),
                            progressTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w400),
                            messageTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 19.0,
                                fontWeight: FontWeight.w600),
                          );
                          await Firestore.instance
                              .collection('TempItemCollectionHold')
                              .document(subCollectionName)
                              .collection('imageTemp')
                              .document(item.documentID)
                              .setData({
                            'imageURL': '$url',
                          });
                          modifyimageURL = url;
                          print("URL:" + url);
                          prUpdate.hide();
                        }
                      },
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.teal,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal,
                          backgroundImage: NetworkImage(theurl),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Use Image URL Instead'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        onChanged: (text) {
                          inputImageURL = text;
                        },
                        validator: (String val) {
                          print(val);
                          if (val == null || val.isEmpty) {
                            return null;
                          } else {
                            if (modifyimageURL != imageURL &&
                                inputImageURL.isNotEmpty) {
                              return "Cannot use image URL after uploading a new image";
                            }
                            var match = isURL(val, requireTld: true);
                            print("Match: " + match.toString());
                            if (match) {
                              return null;
                            } else {
                              return "InValid URL";
                            }
                          }
                        },
                        onSaved: (value) {
                          inputImageURL = value;
                        },
                        decoration: new InputDecoration(
                            hintText: langaugeSetFunc(
                                "Leave it empty if this is not used"),
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Item Name'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        initialValue: name,
                        onChanged: (text) {
                          modifyName = text;
                        },
                        validator: (String val) {
                          if (val.isEmpty) {
                            return 'This Field Cannot Be Empty';
                          }
                          return null;
                        },
                        onSaved: (value) {},
                        decoration: new InputDecoration(
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Item Amount'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        initialValue: amount.toString(),
                        onChanged: (text) {
                          modifyAmount = int.parse(text);
                        },
                        validator: (String val) {
                          int amount = int.parse(val);
                          if (val.isEmpty) {
                            return 'This Field Cannot Be Empty';
                          } else if (amount == 0) {
                            return "Amount Cannot Be 0";
                          }
                          return null;
                        },
                        onSaved: (value) {},
                        decoration: new InputDecoration(
                            hintText: amount.toString(),
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                        keyboardType: TextInputType.number,
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
                      child: RaisedButton(
                        highlightElevation: 0.0,
                        splashColor: Colors.greenAccent,
                        highlightColor: Colors.green,
                        elevation: 0.0,
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Text(
                                langaugeSetFunc('Submit'),
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
                        onPressed: () async {
                          submit();
                        },
                        padding: EdgeInsets.all(7.0),
                        //color: Colors.teal.shade900,
                        disabledColor: Colors.black,
                        disabledTextColor: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
                      child: RaisedButton(
                        highlightElevation: 0.0,
                        splashColor: Colors.greenAccent,
                        highlightColor: Colors.red,
                        elevation: 0.0,
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Text(
                                langaugeSetFunc('Delete'),
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
                        onPressed: () async {
                          String cancel = "Cancel", action = "Delete";
                          String title = "Warning",
                              content =
                                  "Are you sure you want to delete this one in your InHold items?";
                          OnHoldDelete(context, cancel, action, title, content,
                              documentID, subCollectionName);
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
            );
          }),
      textField: Container(
        child: Column(
          children: <Widget>[],
        ),
      ),
      barrierColor: Colors.white.withOpacity(0.7),
    );
  }

  bool oneMore = false;
  Widget ButtonSelectAll(i) {
    if (i == 0 && oneMore) {
      return CupertinoButton(
        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 8, 0,
            MediaQuery.of(context).size.width / 8, 0),
        color: Colors.green,
        child: Text(langaugeSetFunc("Wake Up All")),
        onPressed: () async {
          QuerySnapshot list = await Firestore.instance
              .collection('TempItemCollectionHold')
              .document(subCollectionName)
              .collection('item')
              .getDocuments();

          for (int i = 0; i < list.documents.length; i++) {
            var ds = list.documents[i];
            await Firestore.instance
                .collection('TempItemCollectionHold')
                .document(subCollectionName)
                .collection('item')
                .document(ds.documentID)
                .updateData({'status': 'Hold'});
          }

          print("Select All");
        },
      );
    } else {
      return Container();
    }
  }

  Widget ButtonCancelAll(i) {
    if (i == 0 && oneMore) {
      return CupertinoButton(
        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 7, 0,
            MediaQuery.of(context).size.width / 7, 0),
        color: Colors.red,
        child: Text(langaugeSetFunc("Sleep All")),
        onPressed: () async {
          QuerySnapshot list = await Firestore.instance
              .collection('TempItemCollectionHold')
              .document(subCollectionName)
              .collection('item')
              .getDocuments();
          for (int i = 0; i < list.documents.length; i++) {
            var ds = list.documents[i];
            await Firestore.instance
                .collection('TempItemCollectionHold')
                .document(subCollectionName)
                .collection('item')
                .document(ds.documentID)
                .updateData({'status': 'hide'});
          }

          print("Cancel All");
        },
      );
    } else {
      return Container();
    }
  }

  Widget Submit(List<OnHoldItems> OnHoldItemsList, i) {
    if (!oneMore && i == 0) {
      return CupertinoButton(
        minSize: 10,
        color: Colors.blue,
        child: Text(langaugeSetFunc("Push")),
        onPressed: () async {
          QuerySnapshot list = await Firestore.instance
              .collection('TempItemCollectionHold')
              .document(subCollectionName)
              .collection('item')
              .getDocuments();

          QuerySnapshot theitemlist = await Firestore.instance
              .collection(returnItemCollection())
              .getDocuments();
          String updateDocumentID = "new";
          for (int i = 0; i < list.documents.length; i++) {
            var ds = list.documents[i];
            String imageURL =
                    'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png',
                name = 'NoName';
            int amount = 0;
            imageURL = ds["imageURL"];
            name = ds["name"];
            amount = ds["amount"];

            for (int j = 0; j < theitemlist.documents.length; j++) {
              var innerds = theitemlist.documents[j];
              var innerName = '';
              innerName = innerds['name'];
              if (name == innerName) {
                updateDocumentID = innerds.documentID;
                break;
              }
            }

            try {
              if (ds["status"] == "Hold") {
                if (updateDocumentID == "new") {
                  await Firestore.instance
                      .collection(returnItemCollection())
                      .document()
                      .setData({
                    'name': name,
                    '# of items': amount,
                    'category': this.widget.cater,
                    'imageURL': imageURL,
                    'Location': this.widget.locationName,
                  });
                } else {
                  await Firestore.instance
                      .collection(returnItemCollection())
                      .document(updateDocumentID)
                      .setData({
                    'name': name,
                    '# of items': amount,
                    'category': this.widget.cater,
                    'imageURL': imageURL,
                    'Location': this.widget.locationName,
                  });
                }
                await Firestore.instance
                    .collection('TempItemCollectionHold')
                    .document(subCollectionName)
                    .collection('item')
                    .document(ds.documentID)
                    .delete();
              }
            } catch (e) {
              print(e);
            }
            updateDocumentID = "new";
          }

          print("Push");
        },
      );
    } else {
      return Container();
    }
  }

  Widget Delete(List<OnHoldItems> OnHoldItemsList, i) {
    if (!oneMore && i == 0) {
      return CupertinoButton(
        minSize: 10,
        color: Colors.red,
        child: Text(langaugeSetFunc("Clear")),
        onPressed: () async {
          QuerySnapshot list = await Firestore.instance
              .collection('TempItemCollectionHold')
              .document(subCollectionName)
              .collection('item')
              .getDocuments();
          for (int i = 0; i < list.documents.length; i++) {
            var ds = list.documents[i];
            String imageURL =
                    'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png',
                name = 'NoName';
            int amount = 0;
            imageURL = ds["imageURL"];
            name = ds["name"];
            amount = ds["amount"];
            try {
              if (ds["status"] != "Hold") {
                await Firestore.instance
                    .collection('TempItemCollectionHold')
                    .document(subCollectionName)
                    .collection('item')
                    .document(ds.documentID)
                    .delete();
              }
            } catch (e) {
              print(e);
            }
          }

          print("Push");
        },
      );
    } else {
      return Container();
    }
  }

  Widget diviera(i) {
    if (i == 0 && oneMore) {
      return Divider(
        height: 2.0,
      );
    } else {
      return Container();
    }
  }

  Widget divierb(i) {
    if (i == 0 && !oneMore) {
      return Divider(
        height: 2.0,
      );
    } else {
      return Container();
    }
  }

  Widget build(BuildContext context) {
    maincontxt = context;
    subCollectionName = this.widget.locationName + this.widget.cater;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        title: Text(
          langaugeSetFunc("OnHold items"),
          style: TextStyle(color: textcolor()),
        ),
        backgroundColor: backgroundcolor(),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.file_upload,
              color: textcolor(),
            ),
            onPressed: () async {
              pickUpFile(context, this.widget.cater, subCollectionName);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.format_list_bulleted,
              color: textcolor(),
            ),
            onPressed: () async {
              setState(() {
                oneMore = !oneMore;
              });
            },
          ),
        ],
      ),
      backgroundColor: backgroundcolor(),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('TempItemCollectionHold')
              .document(subCollectionName)
              .collection('item')
              .snapshots(),
          builder: (context, snapshot) {
            List<OnHoldItems> OnHoldItemsList = [];

            try {
              var documents = snapshot.data.documents;
              for (int i = 0; i < documents.length; i++) {
                String name = "NoName", status = "hide";
                String imageURL =
                    'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png';
                String documentID = documents[i].documentID;
                int amount = 0;

                try {
                  name = documents[i]["name"];
                  status = documents[i]["status"];
                  imageURL = documents[i]["imageURL"];
                  amount = documents[i]["amount"];
                } catch (e) {
                  print(e);
                }
                var value =
                    OnHoldItems(name, amount, imageURL, status, documentID);
                OnHoldItemsList.add(value);
              }
            } catch (e) {
              print(e.toString());
            }

            return ListView.builder(
                itemCount: OnHoldItemsList.length,
                itemBuilder: (context, i) {
                  return Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ButtonCancelAll(i),
                          ButtonSelectAll(i),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Submit(OnHoldItemsList, i),
                          Delete(OnHoldItemsList, i),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(OnHoldItemsList[i].imageURL),
                          ),
                          trailing: switchButton(
                              OnHoldItemsList[i], subCollectionName),
                          title: new Text(OnHoldItemsList[i].name,
                              style: TextStyle(color: textcolor())),
                          subtitle: new Text(
                              langaugeSetFunc('Amount:') +
                                  '${OnHoldItemsList[i].amount}',
                              style: TextStyle(color: textcolor())),
                          onTap: () {
                            Fluttertoast.showToast(
                              msg: 'Long Press To Edit',
                            );
                          },
                          onLongPress: () {
                            _showDialog(OnHoldItemsList[i]);
                            print(1);
                          },
                        ),
                      ),
                      Divider(
                        height: 2.0,
                      ),
                    ],
                  );
                });
          }),
    );
  }
}

Future<void> OnHoldDelete(context, cancel, action, title, content, documentID,
    subCollectionName) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(cancel),
            onPressed: () {
              print(1);
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: Text(
              action,
            ),
            onPressed: () async {
              await Firestore.instance
                  .collection('TempItemCollectionHold')
                  .document(subCollectionName)
                  .collection('item')
                  .document(documentID)
                  .delete();

              Navigator.of(context).pop(true);
              FocusScope.of(context).requestFocus(FocusNode());
              Navigator.pop(context, false);
            },
          ),
        ],
      );
    },
  );
}
