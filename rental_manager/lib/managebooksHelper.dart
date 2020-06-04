import 'dart:core';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'package:rental_manager/tabs/reservations.dart';

import 'CurrentReservation.dart';
import 'displayall.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'language.dart';

class LocationsAndList{
  String location;
  String imageURL = "";
  List<DocumentSnapshot> list;

  LocationsAndList(this.location, this.imageURL,this.list);
}

int isEarlyInSort(String a, String b) {
  var time_a = DateTime.parse(a), time_b = DateTime.parse(b);

  var difference = time_a.difference(time_b);
  if(!difference.isNegative){
    return -1;
  }
  return 1;
}

List< LocationsAndList> getlocations(List<DocumentSnapshot> reservationList, String locationManagerpara){
  var locationList = [];
  locationList.addAll(globals.locationList);
  List< LocationsAndList> retList;
  if(locationManagerpara != ""){
    String location = locationManagerpara, imageURL;
    for(int i = 0; i < locationList.length; i++){
      if(locationList[i]["name"] == location){
        imageURL = locationList[i]["imageURL"];
        break;
      }
    }
    if(imageURL == null){
      imageURL = defaultImageURL;
    }
    reservationList.sort((a,b)=>isEarlyInSort(a['startTime'], b['startTime']));
    retList.add(LocationsAndList(location, imageURL, reservationList));
  }else{
    locationList.forEach((location) {
      List<DocumentSnapshot> thisList = [];
      try{
        thisList = reservationList.where((element) => element == location);
        String imageURL = location["imageURL"];
        if(imageURL == null){
          imageURL = defaultImageURL;
        }
        thisList.sort((a,b)=>isEarlyInSort(a['startTime'], b['startTime']));
        retList.add(LocationsAndList(location, imageURL, thisList));
      }catch(e){
        print(e);
      }
    });
  }
  return retList;
}

class Post {
  final String title;
  final String description;
  final String trailing;
  final String imageUrl;
  final String uid;
  Post(this.title, this.description,this.trailing, this.imageUrl, this.uid);
}
List<Post> postList = [];
class searchReservation extends StatefulWidget {
  @override
  List<DocumentSnapshot>reservationList;
  int currentDecision = 0;
  String location = "All Locations";
  searchReservation(this.reservationList);
  _searchReservationState createState() => _searchReservationState();
}

class _searchReservationState extends State<searchReservation> {
  Future<List<Post>> search(String search) async{
    List<Post> postList = [];
    List<DocumentSnapshot> copy_reservationList = [];
    print(this.widget.location);
    this.widget.reservationList.forEach((element) {
        if(element["location"] == this.widget.location || this.widget.location.contains("All Locations")){
          copy_reservationList.add(element);
        }
    });
   

    if(search == ""){
      copy_reservationList.forEach((element) {
        if(true){
          String title = element["name"], description = get(element), trailing = returnDifferenceTime(
            element['startTime'],
            element['picked Up time'],
            element["return time"],
          ), imageUrl = element["imageURL"];

          var post = Post(title, description, trailing, imageUrl, element.documentID);
          postList.add(post);
        }
      });
      return postList;
    }
    copy_reservationList.forEach((element) {
      if(element["name"].toString().toLowerCase().contains(search.toLowerCase())){
        String title = element["name"], description = get(element), trailing = returnDifferenceTime(
          element['startTime'],
          element['picked Up time'],
          element["return time"],
        ), imageUrl = element["imageURL"];

        var post = Post(title, description, trailing, imageUrl, element.documentID);
        postList.add(post);
      }
    });

    return List.generate(postList.length, (int i) {
      return Post( postList[i].title, postList[i].description, postList[i].trailing, postList[i].imageUrl, postList[i].uid
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    if(globals.isiOS){

      if(globals.isAdmin == false){
        this.widget.location = globals.locationManager;
      }
      return Scaffold(
        backgroundColor: backgroundcolor(),
        resizeToAvoidBottomPadding: false,
        appBar:  CupertinoNavigationBar(
          heroTag: "tab31111 itemsSearch for existing orders\' usage",
          transitionBetweenRoutes: false,
          middle: Text(
            langaugeSetFunc("Search orders at ") + this.widget.location,
            style: TextStyle(color: textcolor()),
          ),
          backgroundColor: backgroundcolor(),
          trailing: globals.isAdmin? GestureDetector(
            onTap: () async{
              var a = await Firestore.instance.collection(returnLocationsCollection()).getDocuments();
              List<DocumentSnapshot> locationList = a.documents;
              List<String>nameList = ['Default: All Locations'];

              locationList.forEach((element) {
                try{
                  nameList.add(element['name']);
                }catch(e){
                  print(e);
                }
              });

              var selectedValue = 0;
              List<Text> nameTextList = [];
              int count = 0;
              nameList.forEach((element) {
                if(this.widget.location.toLowerCase() == element.toLowerCase()){
                  selectedValue = count;
                }
                count += 1;
                nameTextList.add(Text(element));
              });
              showCupertinoModalPopup<String>(
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffffffff),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xff999999),
                              width: 0.0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            CupertinoButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 5.0,
                              ),
                            ),
                            CupertinoButton(
                              child: Text('Confirm'),
                              onPressed: () async{
                                setState(() {
                                  this.widget.currentDecision = selectedValue;
                                  if(nameList[selectedValue].contains("All Locations")){
                                    nameList[selectedValue] = "All Locations";
                                  }
                                  this.widget.location = nameList[selectedValue];
                                });
                                Navigator.pop(context);
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 5.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 320.0,
                        color: Color(0xfff7f7f7),
                        child: CupertinoPicker(

                          scrollController: FixedExtentScrollController(initialItem:selectedValue),
                          onSelectedItemChanged:(int index){
                            selectedValue = index;
                          },
                          children: nameTextList,
                          itemExtent: 32,
                        ),
                      )
                    ],
                  );
                },
              );
            },
            child: Icon(
              CupertinoIcons.gear,
              color: textcolor(),
            ),
          ): null,
        ),
        body:  GestureDetector(
          onPanDown: (_) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBar<Post>(
                minimumChars: 0,
                cancellationText: Text(langaugeSetFunc("Cancel"), style: TextStyle(color: textcolor()),),
                hintText: langaugeSetFunc("Type the item name here"),
                textStyle: TextStyle(color: textcolor()),
                onSearch: search,
                onItemFound: (Post post, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(post.imageUrl),
                    ),
                    title: Text(post.title,style: TextStyle(color: textcolor()),),
                    subtitle: Text(post.description, style: TextStyle(color: textcolor())),
                    trailing: Text(post.trailing, style: TextStyle(color: textcolor())),
                    onTap: () async {
                      int index = -1;
                      for(int i = 0; i < this.widget.reservationList.length; i++){
                        if(this.widget.reservationList[i].documentID == post.uid){
                          index = i;
                          break;
                        }
                      }
                      if(index != -1){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Ticket(this.widget.reservationList[index])));
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
  }
}

class searchPeople extends StatefulWidget {
  @override
  List<personInfo> searchPeopleList;

  String hint = "Type the person's name here";
  int currentdecision = 0;
  searchPeople(this.searchPeopleList);
  _searchPeopleState createState() => _searchPeopleState();
}

class _searchPeopleState extends State<searchPeople> {
  Future<List<Post>> search(String search) async{
    List<Post> postList = [];

    if(search == ""){
      this.widget.searchPeopleList.forEach((element) {
        if(true){
          String title = element.name, description = element.email, trailing = returnLatestTime(element.latestTime), imageUrl = element.imageURL;
          var post = Post(title, description, trailing, imageUrl, element.documentID);
          postList.add(post);
        }
      });
      return postList;
    }
    this.widget.searchPeopleList.forEach((element) {
      if(this.widget.currentdecision == 0 && element.name.toString().toLowerCase().contains(search.toLowerCase())){
        String title = element.name, description = element.email, trailing = returnLatestTime(element.latestTime), imageUrl = element.imageURL;
        var post = Post(title, description, trailing, imageUrl, element.documentID);
        postList.add(post);
      }
      if(this.widget.currentdecision == 1 && element.email.toString().toLowerCase().contains(search.toLowerCase())){
        String title = element.name, description = element.email, trailing = returnLatestTime(element.latestTime), imageUrl = element.imageURL;
        var post = Post(title, description, trailing, imageUrl, element.documentID);
        postList.add(post);
      }
    });

    return List.generate(postList.length, (int i) {
      return Post( postList[i].title, postList[i].description, postList[i].trailing, postList[i].imageUrl, postList[i].uid
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    if(globals.isiOS){
      return Scaffold(
        backgroundColor: backgroundcolor(),
        resizeToAvoidBottomPadding: false,
        appBar:  CupertinoNavigationBar(
          heroTag: "tab31Search for peoplefor existing orders\' usage",
          transitionBetweenRoutes: false,
          middle: Text(
            langaugeSetFunc('Search for people'),
            style: TextStyle(color: textcolor()),
          ),
          backgroundColor: backgroundcolor(),
          trailing: GestureDetector(
            onTap: (){
              var selectedValue = 0;
              var nameTextList = [Text("By Name"), Text("By Email")];
              showCupertinoModalPopup<String>(
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffffffff),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xff999999),
                              width: 0.0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            CupertinoButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 5.0,
                              ),
                            ),
                            CupertinoButton(
                              child: Text('Confirm'),
                              onPressed: () async{
                                setState(() {
                                  this.widget.currentdecision = selectedValue;
                                  if(this.widget.currentdecision == 0){
                                    this.widget.hint = "Type the person's name here";
                                  }else{
                                    this.widget.hint = "Type the person's email address here";
                                  }
                                });
                                Navigator.pop(context);
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 5.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 320.0,
                        color: Color(0xfff7f7f7),
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: this.widget.currentdecision),
                          onSelectedItemChanged:(int index){
                            selectedValue = index;
                          },
                          children: nameTextList,
                          itemExtent: 32,
                        ),
                      )
                    ],
                  );
                },
              );
            },
            child: Icon(
              CupertinoIcons.gear,
                  color: textcolor(),
            ),

          ),
        ),
        body:  GestureDetector(
          onPanDown: (_) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBar<Post>(
                minimumChars: 0,

                cancellationText: Text(langaugeSetFunc("Cancel"), style: TextStyle(color: textcolor()),),
                hintText: langaugeSetFunc("${this.widget.hint}"),
                textStyle: TextStyle(color: textcolor()),
                onSearch: search,
                onItemFound: (Post post, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(post.imageUrl),
                    ),
                    title: Text(post.title,style: TextStyle(color: textcolor()),),
                    subtitle: Text(post.description, style: TextStyle(color: textcolor())),
                    trailing: Text(post.trailing, style: TextStyle(color: textcolor())),
                    onTap: () async {
                      var uid = post.uid;
                      var name = post.title;



                      if(uid != globals.uid){
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
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
  }
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

  String returnLatestTime(String latestTime) {


    if (latestTime != null && latestTime.length > 0) {
      return returnDifferenceTime(latestTime);
    }

    return "Non-Active";
  }
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

String defaultImageURL =
    "https://firebasestorage.googleapis.com/v0/b/rentalmanager-f94f1.appspot.com/o/Users%2FGreatJing%2FLibrary%2FDeveloper%2FCoreSimulator%2FDevices%2F53FDF17D-97F8-4959-8E15-8D95BA06F180%2Fdata%2FContainers%2FData%2FApplication%2FA030E650-84A0-4ABA-9AD3-B3F0F8E15EB7%2Ftmp%2Fimage_picker_A493FE0D-E329-45C1-B034-761AA9839156-95280-000059A0760D876F.jpg?alt=media&token=a7ba4fb8-c82e-45a1-b55a-61063fecb0ca";


