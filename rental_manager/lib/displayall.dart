import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rental_manager/CurrentReservation.dart';
import 'package:rental_manager/Locations/arc.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/manager/manage_locations.dart';
import 'package:flutter_cupertino_data_picker/flutter_cupertino_data_picker.dart';
import 'package:rental_manager/tabs/account.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'globals.dart' as globals;
import "package:http/http.dart" as http;
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart'
    as slideDialog;
import 'package:image_picker/image_picker.dart';
import 'package:validators/validators.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' show Platform;
import 'managebooksHelper.dart';
import 'manager/manage_category.dart';
class Manager extends StatefulWidget {
  @override
  _ManagerState createState() => _ManagerState();
}
List<DocumentSnapshot> booksReservationList = [];
List<personInfo> tabPeopleList =[];
int view = 0;


class _ManagerState extends State<Manager> {
  @override
  Widget build(BuildContext context) {

    bool isAdminOrManager = false;
    isAdminOrManager = ((globals.isAdmin == true) || (globals.locationManager.isNotEmpty));
    if(isAdminOrManager == false){
      print(false);
    }else{
      print(true);
    }
    return isAdminOrManager? DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: textcolor(), //change your color here
          ),
          actions: <Widget>[
            globals.isiOS? IconButton(
              icon: Icon(
                CupertinoIcons.pen,
                color: textcolor(),
              ),
              onPressed: () async{
                Firestore.instance.collection(returnUserCollection()).document(globals.uid).get().then((value){
                  globals.isAdmin = value["Admin"];
                  globals.locationManager = value["LocationManager"];
                });
                isAdminOrManager = ((globals.isAdmin == true) || (globals.locationManager.isNotEmpty));
                if( isAdminOrManager == false){
                  print("Not");
                  pop_window("Warning", "You are no longer a Admin/Manager.\nYou cannot view this page as a guest", context);
                }else if(globals.isAdmin){
                 Navigator.push(context,
                     MaterialPageRoute(builder: (context) => ManageLocations()));
               }else{
                 var a = await Firestore.instance.collection(returnLocationsCollection()).where('name', isEqualTo: globals.locationManager).getDocuments();
                 if(a.documents.length == 1){
                   Navigator.push(context,
                       MaterialPageRoute(builder: (context) => ManageCategory(data: a.documents[0], documentID: a.documents[0].documentID)));
                 }
               }


              },
            ): IconButton(
              icon: Icon(
                Icons.assessment,
                color: textcolor(),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ManageLocations())
                );
              },
            ),
            IconButton(
              icon: Icon(
                CupertinoIcons.search,
                color: textcolor(),
              ),
              onPressed: ()async{
                 Firestore.instance.collection(returnUserCollection()).document(globals.uid).get().then((value){
                   globals.isAdmin = value["Admin"];
                   globals.locationManager = value["LocationManager"];
                 });
                 isAdminOrManager = ((globals.isAdmin == true) || (globals.locationManager.isNotEmpty));
                 if(isAdminOrManager == false){
                   print("Not");
                   pop_window("Warning", "You are no longer a Admin/Manager.\nYou cannot view this page as a guest", context);
                 }else{
                   if(view == 1){
                     print(booksReservationList.length);
                     //searchReservation
                     Navigator.push(context,
                         MaterialPageRoute(builder: (context) => searchReservation(booksReservationList))
                     );
                   }else if(view == 2){
                     print(tabPeopleList.length);
                     //searchPeople
                     Navigator.push(context,
                         MaterialPageRoute(builder: (context) =>searchPeople(tabPeopleList) )
                     );
                   }
                 }
              },
            )
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
    ) : Scaffold(
      appBar:CupertinoNavigationBar(
        heroTag: "tab3119dja0PeopleOrder",
        transitionBetweenRoutes: false,
        middle: Text("Recent orders"),
        backgroundColor: backgroundcolor(),
      ),
      backgroundColor: backgroundcolor(),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection(returnReservationCollection())
              .snapshots(),
          builder: (context, snapshot) {

            List<DocumentSnapshot> documents = [];
            try {
              documents = snapshot.data.documents;
            } catch (e) {
              print(e.toString());
            }



            return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, i){
                  return Column(
                    children: <Widget>[
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(documents[i]["imageURL"]),
                        ),
                        title: Text(documents[i]["name"], style: TextStyle(color: textcolor())),
                        subtitle: Text( getSubtitle(documents[i]["reserved time"], documents[i]["picked Up time"], documents[i]["return time"],
                            documents[i]["status"]
                        ), style: TextStyle(color: textcolor()) ),

                      ),
                      Divider(
                        height: 2.0,
                      ),
                    ],
                  );
                }
            );


            return Container();


          }),
    );

  }
  String getSubtitle(String reservedTime, String pickupTime, String returnTime, String status){
    reservedTime = parseTime(reservedTime);
    pickupTime = parseTime(pickupTime);
    returnTime = parseTime(returnTime);
    if(status == "Reserved"){
      return status + " at " + parseTime(reservedTime);
    }else if(status ==  "Picked Up"){
      return status + " at " + parseTime(pickupTime);

    }else if(status ==  "Returned"){
      return status + " at " + parseTime(returnTime);
      return pickupTime + status;
    }
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

  if(popWindow){
    pop_window(
        "Warning",
        "The CSV file format is not correct\nEach Row should have at least 2 indexs but at most three indexs : ItemName, Amount, imageURL(optional)",
        context);
    return;
  }else{
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
  String returnDifferenceTime(String reservationTime, String pickUpTime, String returnTime) {
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

    int isEarlyInSort(String a, String b) {
      var time_a = DateTime.parse(a), time_b = DateTime.parse(b);

      var difference = time_a.difference(time_b);
      if(!difference.isNegative){
        return -1;
      }
      return 1;
    }
    String get(DocumentSnapshot ds){
      try{
        if(ds["UserName"] != null && ds["status"] != null){
          return ds['status'] + " by " + ds["UserName"];
        }
      }catch(e){
        print(e.toString());
      }
      return "Error in geting name";
    }

    return Scaffold(
      backgroundColor: backgroundcolor(),
      body: StreamBuilder(
          stream: globals.isAdmin? Firestore.instance
              .collection(returnReservationCollection()).orderBy('startTime',descending:true)
              .snapshots(): Firestore.instance.collection(returnReservationCollection()).where('location', isEqualTo: globals.locationManager).orderBy('startTime', descending:true).snapshots(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) return Container(child: Center(child: CupertinoActivityIndicator()));
            List<String> userNameList = [];
            List<DocumentSnapshot> documents = snapshot.data.documents;
            booksReservationList = documents;
            view = 1;
            return ListView.builder(
                itemCount:  documents.length,
                itemBuilder: (context, i) {
                  return Column(
                    children: <Widget>[

                      Container(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage( documents[i]['imageURL']),
                          ),
                          trailing: new Text(
                              returnDifferenceTime(
                                documents[i]['startTime'],
                                documents[i]['picked Up time'],
                                documents[i]["return time"],
                              ),
                              style: TextStyle(color: textcolor())),
                          title: new Text(documents[i]['name'],
                              style: TextStyle(color: textcolor())),
                          subtitle: new Text( get(documents[i]),
                              style: TextStyle(color: textcolor())),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => Ticket(documents[i]))
                            );
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
  String documentID;
  personInfo(this.name, this.StudentID, this.email, this.imageURL,
      this.phoneNumber, this.latestTime, this.documentID);
}

class personRoot{
  bool isAdmin;
  String locationManager;
  personRoot(this.isAdmin, this.locationManager);
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


    if (latestTime != null && latestTime.length > 0) {
      return returnDifferenceTime(latestTime);
    }

    return "Non-Active";
  }

  String getTitle(String name, personRoot root){
    String firstName = "";
    for(int i = 0; i < name.length; i++){
      if(name[i] != ' '){
        firstName += name[i];
      }else{
        break;
      }
    }
    if(root.isAdmin){
      firstName += '(Admin)';
    }else{
      if(root.locationManager.isNotEmpty) {
        firstName += '(${root.locationManager}' + 'Manager)';
      }
    }
    if(firstName.contains('Admin') == false && firstName.contains('Manager') == false){
      firstName = name;
    }

    return firstName;

  }


  Widget build(BuildContext context) {
    setUidList();

    if(globals.isiOS){

      return Scaffold(
        backgroundColor: backgroundcolor(),
        body: StreamBuilder(
            stream:
            Firestore.instance.collection(returnUserCollection()).where('organization', isEqualTo: globals.organization).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('loading...');
              view = 2;

              List<DocumentSnapshot> documents = snapshot.data.documents;

              List<personInfo> peopleList = [];
              List<personRoot>peopleRootList = [];
              try {
                peopleList.clear();
                peopleRootList.clear();
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
                  var myisAdmin = false;
                  myisAdmin = element['Admin'];
                  var mylocationManager = "";
                  mylocationManager = element['LocationManager'];
                  var documentID = "";
                  documentID = element.documentID;
                  if (name == null) {
                  } else {
                    var tmp = personInfo(name, StudentID, email, imageURL,
                        phoneNumber, latestTime, documentID);
                    var temp = personRoot(myisAdmin, mylocationManager);
                    if (tmp != null ) {
                      peopleList.add(tmp);
                      if(temp != null) {
                        peopleRootList.add(temp);
                      }else{
                        peopleRootList.add(personRoot(false, ""));
                      }
                    } else {}

                  }
                });
              } catch (e) {
                print("a: " + e.toString());
              }
              //setUidList();
              List<personInfo>peopleList2 = [];
              peopleList.forEach((element) {
                peopleList2.add(element);
              });
              List<int>adminList = [];
              List<int>managerList = [];
              int count = 0;

              peopleRootList.forEach((element) {
                if(element.isAdmin){
                  adminList.add(count);
                }else if(element.locationManager.isNotEmpty){
                  managerList.add(count);
                }
                count += 1;
              });
              count = 0;
              List<personInfo> copy_peopleList = [];

              adminList.forEach((element) {
                copy_peopleList.add(peopleList[element]);

                copy_peopleList[copy_peopleList.length - 1].name =getTitle(peopleList[element].name, peopleRootList[element]);
              });

              managerList.forEach((element) {
                copy_peopleList.add(peopleList[element]);

                copy_peopleList[copy_peopleList.length - 1].name =getTitle(peopleList[element].name, peopleRootList[element]);
              });

              Map<int, int> map1 = new Map.fromIterable(adminList,
                  key: (item) => item,
                  value: (item) => item * item);

              Map<int, int> map2 = new Map.fromIterable(managerList,
                  key: (item) => item,
                  value: (item) => item * item);
              count = 0;
              List<personInfo> tmpList = [];

              tmpList.clear();
              peopleList.forEach((element) {
                if(map1[count] == null && map2[count] == null){
                  tmpList.add(element);
                }
                count += 1;
              });
              tmpList.sort((a,b)=> a.name.compareTo(b.name));
              tmpList.forEach((element) {
                copy_peopleList.add(element);
              });

              peopleList.clear();
              peopleList.addAll(copy_peopleList);
              int index = 0;
              bool leftbracket = false;

              for(int i = 0; i < peopleList.length; i++){
                if(peopleList[i].email == globals.email ){
                  String name = 'You: ', fullname = peopleList[i].name;

                  for(int j = 0; j < fullname.length; j++){
                    if(leftbracket && j < fullname.length - 1){
                      name += fullname[j];
                    }else{
                      if(fullname[j] == '('){
                        leftbracket = true;
                      }
                    }
                    peopleList[i].name = name;
                  }
                  index = i;
                  break;
                }
              }

              personInfo tmp = peopleList[index];
              peopleList.removeAt(index);
              peopleList.insert(0, tmp);

              tabPeopleList = peopleList;


              print("MyAdmin: " + globals.isAdmin.toString());

              try{
                var fullname = peopleList[0].name;
                if(fullname.contains("Admin") || fullname.contains("Manager")){
                  if(fullname.contains("Admin")){
                    globals.isAdmin = true;
                  }else{
                    int found = -1;
                    for(int i = 0; i < peopleList2.length;i++){
                      if(peopleList2[i].email == globals.email){
                        found = i;
                        break;
                      }
                    }
                    if(found != -1){
                      globals.locationManager = peopleRootList[found].locationManager;
                    }
                  }
                }else{
                  print("Non admins/location manager");
                  globals.isAdmin = false;
                  globals.locationManager = "";
                  return Container(child: Center(child: CupertinoActivityIndicator()));
                }
              }catch(e){
                print(e.toString());
              }




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
                            title: new Text(getTitle(peopleList[i].name, personRoot(false,"")),
                                style: TextStyle(color: textcolor())),
                            subtitle: new Text(cutEmail(peopleList[i].email),
                                style: TextStyle(color: textcolor())),
                            onTap: () {
                                var uid = peopleList[i].documentID;
                                var name = peopleList[i].name;
                                if(i > 0){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              managepeopleOrders(uid, name)));
                                }else{
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              managepeopleOrders(uid, 'You')));
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
                var documentID = "";
                documentID = element.documentID;
                if (name == null) {
                } else {
                  var tmp = personInfo(name, StudentID, email, imageURL,
                      phoneNumber, latestTime, documentID);
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
  Icon returnAdminOrnot() {
    if (globals.isAdmin) {
      return Icon(Icons.lock_open);
    } else {
      return Icon(Icons.lock);
    }
  }

  Widget build(BuildContext context) {
    var uid = this.widget.uid, name = this.widget.name;

    if(globals.isiOS){

      return Scaffold(
        appBar:CupertinoNavigationBar(
          heroTag: "tab3119dja0PeopleOrder",
          transitionBetweenRoutes: false,
          middle: Text(name == 'You'? 'Your'  + langaugeSetFunc(' Orders') :' $name \'s ' + langaugeSetFunc('Orders'), style: TextStyle(color: textcolor())),
          backgroundColor: backgroundcolor(),
          trailing: name != 'You' ?GestureDetector(
            child: Icon(
              CupertinoIcons.padlock_solid,
                  color:  textcolor(),
            ),
            onTap: () async{
              bool personisAdmin = name.contains("Admin");
              bool personisLocationManager = name.contains("Manager");
              String locationManagername = "";
              await Firestore.instance.collection(returnUserCollection()).document(uid).get().then((value){
                personisAdmin = value['Admin'];
                personisLocationManager = value['LocationManager'].toString().isNotEmpty;
                locationManagername = value['LocationManager'];
              });

              if(globals.isAdmin == false && personisAdmin){
                pop_window("Warning", langaugeSetFunc("Location Managers are not granted to change the access control of Admins"), context);
              }else if(globals.isAdmin == false && personisLocationManager){
                pop_window("Warning", langaugeSetFunc("Location Managers are not granted to change the access control of other Managers"), context);
              }else if((personisLocationManager == false && personisAdmin == false) || globals.isAdmin){
                final QuerySnapshot result = await Firestore.instance.collection(returnLocationsCollection()).getDocuments();
                var docList = result.documents;
                List<String>strList = [];
                List<String>copy_strList = [];

                if(globals.isAdmin){
                  copy_strList.add('Admin');
                }
                if(personisAdmin){
                  strList.add('Current Role: Admin');
                }else if(personisLocationManager){
                  if(locationManagername[locationManagername.length - 1] != ' '){
                    strList.add('Current Role: $locationManagername' + " Manager");
                  }else{
                    strList.add('Current Role: $locationManagername' + "Manager");
                  }
                }else{
                  strList.add('Current Role: Guest');
                }

                docList.forEach((element) {
                  String name = element['name'];
                  if( globals.isAdmin == false && name == globals.locationManager) {
                    copy_strList.add('${element['name']}');
                  }

                  if(globals.isAdmin){
                    copy_strList.add('${element['name']}');
                  }
                });
                copy_strList.sort();
                strList.addAll(copy_strList);
                _showDataPicker(strList, uid);
              }
            },
          ) : null,
        ),
        backgroundColor: backgroundcolor(),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection(returnReservationCollection()).where('uid', isEqualTo: uid).orderBy("startTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {

              List<DocumentSnapshot> documents = [];
              try {
                documents = snapshot.data.documents;
              } catch (e) {
                print(e.toString());
              }



              return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, i){
                    return Column(
                      children: <Widget>[
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: getImage(documents[i]["imageURL"]),
                          ),
                          title: Text(documents[i]["name"], style: TextStyle(color: textcolor())),
                          subtitle: Text( getSubtitle(documents[i]["reserved time"], documents[i]["picked Up time"], documents[i]["return time"],
                              documents[i]["status"]
                          ), style: TextStyle(color: textcolor()) ),
                          trailing: Icon(CupertinoIcons.right_chevron, color: textcolor(),),
                          onTap: (){
                            Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Ticket(documents[i])));
                          },
                        ),
                        Divider(
                          height: 2.0,
                        ),
                      ],
                    );
                  }
              );


              return Container();


            }),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        backgroundColor: backgroundcolor(),
        title: Text('$name \'s ' + langaugeSetFunc('Orders'),
            style: TextStyle(color: textcolor())),
        actions: <Widget>[
          IconButton(
            icon: returnAdminOrnot(),
            onPressed: () {
              String title = "Warning", content = "", actionText = "";
              if (globals.isAdmin) {
                content =
                    "$name is a admin. Do you want to lock his access and let him become a user";
                actionText = "Lock";
              } else {
                content =
                    "$name is a user. Do you want to un-lock his access and let him become a admin";
                actionText = "Unlock";
              }
              PlatformAlertDialog(
                title: title,
                content: content,
                cancelActionText: "Cancel",
                defaultActionText: actionText,
              ).show(context);
            },
          ),
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

//
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

  void _showDataPicker(List<String> list, String uid) {
    final bool showTitleActions = true;

    String firstName = '', name = this.widget.name;
    for(int i = 0; i < this.widget.name.length;i++){
      if(name[i] != ' '){
        firstName += name[i];
      }else{
        break;
      }
    }
    name = firstName;
    firstName = '';
    for(int i = 0; i < name.length; i++){
      if(name[i] != '('){
        firstName += name[i];
      }else{
        break;
      }
    }

    List<String>copy_list = [];
    list.forEach((element) {
      if(element.contains("Current") == false && element.contains("Admin") == false){
        if(element[element.length - 1] == ' '){
          copy_list.add(element + 'Manager');
        }else{
          copy_list.add(element + ' Manager');
        }
      }else{
        copy_list.add(element);
      }
    });
    copy_list.add('Guest');
    DataPicker.showDatePicker(
      context,
      showTitleActions: showTitleActions,
      locale: globals.langaugeSet == 'English'? 'en' : 'zh',
      datas: copy_list,
      title: 'Select the role',
      onChanged: (data) {
        print('onChanged date: $data');
      },
      onConfirm: (data) async{
        if(data == "Admin"){

          await Firestore.instance.collection(returnUserCollection()).document(uid).updateData({
            'Admin':true,
          });

          setState(() {
            this.widget.name = firstName + '(Admin)';
          });
        }else if(data != copy_list[0] && data != 'Guest'){
          int index = -1;
          for(int i = 0; i < copy_list.length; i++){
            if(copy_list[i] == data){
              index = i;
              break;
            }
          }
          if(index != -1){
            await Firestore.instance.collection(returnUserCollection()).document(uid).updateData({
              'Admin':false,
            });
            await Firestore.instance.collection(returnUserCollection()).document(uid).updateData({
              'LocationManager': list[index],
            });
          }
          setState(() {
            this.widget.name = firstName + '(' + data + ')';
          });
        }else if(data == "Guest"){
          await Firestore.instance.collection(returnUserCollection()).document(uid).updateData({
            'Admin':false,
          });
          await Firestore.instance.collection(returnUserCollection()).document(uid).updateData({
            'LocationManager': '',
          });
          setState(() {
            this.widget.name = firstName;
          });
        }


      },
    );
  }

  Future<void> _handleClickMeAccessChangeUser(String uid, String name) async {

    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            'Title',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              isDefaultAction: true,
              child: Text(
                'Assign $name as a Admin',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await Firestore.instance.collection(returnUserCollection()).document(uid).updateData({
                  'Admin': true,
                });
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              isDefaultAction: true,
              child: Text(
                'Assign $name as a Manager',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
  int isEarlyInSort(String a, String b) {
    var time_a = DateTime.parse(a), time_b = DateTime.parse(b);

    var difference = time_a.difference(time_b);
    if(!difference.isNegative){
      return -1;
    }
    return 1;
  }
  NetworkImage getImage(String url) {
    if (url == null || url.length == 0) {
      return NetworkImage(
          'https://images.unsplash.com/photo-1588342188135-ead0d7aa393e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1050&q=80');
    } else {
      return NetworkImage(url);
    }
  }

  String getSubtitle(String reservedTime, String pickupTime, String returnTime, String status){
    reservedTime = parseTime(reservedTime);
    pickupTime = parseTime(pickupTime);
    returnTime = parseTime(returnTime);
    if(status == "Reserved"){
      return status + " at " + parseTime(reservedTime);
    }else if(status ==  "Picked Up"){
      return status + " at " + parseTime(pickupTime);

    }else if(status ==  "Returned"){
      return status + " at " + parseTime(returnTime);
      return pickupTime + status;
    }
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

        var a = await Firestore.instance.collection(returnReservationCollection()).where('item', isEqualTo: documentID).getDocuments();
        print("DOc" +  documentID);
        for(int i = 0 ; i < a.documents.length; i++){
          print(a.documents[i]["name"]);
          await Firestore.instance.collection(returnReservationCollection()).document(a.documents[i].documentID).updateData({
            'name': modifyName,
            'imageURL': modifyimageURL,
          });
        }

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
            .document()
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
    var manageDatabaseContext = context;

    Future<void> _handleClickMeEdit() async {
      return showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              langaugeSetFunc("Please choose ONE of the options below to add items:"),
              style: TextStyle(color: Colors.black),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(
                  langaugeSetFunc('Manually'),
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await Firestore.instance
                      .collection('imageTmp')
                      .document(globals.uid)
                      .setData({
                    'imageURL':
                    'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png',
                  });
                  _showDialog2();

                },
              ),
              CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(
                  langaugeSetFunc('Upload CSV'),
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (manageDatabaseContext) => upLoadCSV(this.widget.catergory,
                              this.widget.locationName)));

                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          );
        },
      );
    }



    if(globals.isiOS){
      return Scaffold(
        appBar: CupertinoNavigationBar(
          heroTag: "Tab311de1eManage your Database",
          transitionBetweenRoutes: false,
          middle: Text(
            langaugeSetFunc("Manage your Database"),
            style: TextStyle(color: textcolor()),
          ),
          trailing: GestureDetector(
            onTap: ()async{
              _handleClickMeEdit();
            },
            child: Icon(
              CupertinoIcons.add,
              color: textcolor(),
            ),
          ),
          backgroundColor: backgroundcolor(),
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
        child: Text(langaugeSetFunc("Select All")),
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
        child: Text(langaugeSetFunc("Unselect All")),
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

    if(globals.isiOS){
      return Scaffold(
        appBar: CupertinoNavigationBar(
          heroTag: "Tab313e1OnHold items",
          transitionBetweenRoutes: false,
          middle:Text(
            langaugeSetFunc("OnHold items"),
            style: TextStyle(color: textcolor()),
          ),
          trailing:  Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  pickUpFile(context, this.widget.cater, subCollectionName);
                },
                child: Icon(
                  CupertinoIcons.folder_open,
                  color: textcolor(),
                ),
              ),
              GestureDetector(
                onTap: (){
                  setState(() {
                    oneMore = !oneMore;
                  });
                },
                child: Icon(
                  CupertinoIcons.create_solid,
                  color: textcolor(),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundcolor(),
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
