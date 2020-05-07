import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rental_manager/CurrentReservation.dart';
import 'package:rental_manager/Locations/arc.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'globals.dart' as globals;
import "package:http/http.dart" as http;
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart'
    as slideDialog;
import 'package:image_picker/image_picker.dart';
import 'package:validators/validators.dart';

class Manager extends StatefulWidget {
  @override
  _ManagerState createState() => _ManagerState();
}

class _ManagerState extends State<Manager> {
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
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ManageDatabase()));
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
                  ds["name"],
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
  personInfo(this.name, this.StudentID, this.email, this.imageURL,
      this.phoneNumber, this.latestTime);
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
          stream: Firestore.instance.collection('global_users').snapshots(),
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
                var name = element["name"],
                    StudentID = element["StudentID"],
                    email = element.documentID;
                var imageURL = element["imageURL"],
                    phoneNumber = element["PhoneNumber"],
                    latestTime = value;
                peopleList.add(personInfo(
                    name, StudentID, email, imageURL, phoneNumber, latestTime));
              });
            } catch (e) {
              print("a: " + e.toString());
            }
            setUidList();

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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          managepeopleOrders(uid, name)));
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
  @override
  String uid;
  String name;
  managepeopleOrders(this.uid, this.name);
  _managepeopleOrdersState createState() => _managepeopleOrdersState();
}

void test(DocumentSnapshot ds, uid) {
  return ds.data["uid"] = uid;
}

class _managepeopleOrdersState extends State<managepeopleOrders> {
  @override
  Widget build(BuildContext context) {
    var uid = this.widget.uid, name = this.widget.name;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        backgroundColor: backgroundcolor(),
        title: Text('$name \'s ' + langaugeSetFunc('Orders'),
            style: TextStyle(color: textcolor())),
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
          }),
    );
  }
}

class ManageDatabase extends StatefulWidget {
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
        inputImageURL = item.imageURL;
    int modifyAmount = amount;
    void submit() async {
      final form = _formKey.currentState;
      if (form.validate()) {
        print(modifyName);
        print(modifyAmount);
        print(modifyimageURL);
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
                        onChanged: (text) {},
                        validator: (String val) {
                          print(val);
                          if (val == null || val.isEmpty) {
                            return null;
                          } else {
                            if (modifyimageURL != imageURL) {
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
                            hintText: "Leave it empty if this is not used",
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
    String modifyName = "", modifyimageURL = " ", inputImageURL = " ";
    int modifyAmount = 0;
    void submit() async {
      final form = _formKey.currentState;
      if (form.validate()) {
        print(modifyName);
        print(modifyAmount);
        print(modifyimageURL);
        await Firestore.instance
            .collection(returnItemCollection())
            .document("123")
            .setData({
          '# of items': modifyAmount,
          'category': 'sport',
          'imageURL': modifyimageURL,
          'name': modifyName,
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
                        onChanged: (text) {},
                        validator: (String val) {
                          print(val);
                          if (val == null || val.isEmpty) {
                            return null;
                          } else {
                            if (modifyimageURL != null) {
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
                            hintText: "Leave it empty if this is not used",
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

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: Icon(
              Icons.add,
              color: textcolor(),
            ),
            onPressed: () async {
              await Firestore.instance
                  .collection('imageTmp')
                  .document(globals.uid)
                  .setData({
                'imageURL': '123',
              });
              _showDialog2();
            },
          ),
        ],
      ),
      backgroundColor: backgroundcolor(),
      body: StreamBuilder(
          stream:
              Firestore.instance.collection(returnItemCollection()).snapshots(),
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

                documents.forEach((element) {
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
                              'Amount:' + itemList[i].amount.toString(),
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
