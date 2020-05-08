import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rental_manager/CurrentReservation.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/manager/manage_locations.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'globals.dart' as globals;

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
                    MaterialPageRoute(builder: (context) => ManageLocations()));
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
