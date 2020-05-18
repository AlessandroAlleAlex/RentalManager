

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:rental_manager/CurrentReservation.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/tabs/locations.dart';
import '../CurrentReservation.dart';
import '../Locations/show_all.dart';
import '../Locations/show_all.dart';
import '../Locations/show_all.dart';
import '../Locations/show_all.dart';
import '../Locations/show_all.dart';
import '../Locations/show_all.dart';
import '../chatview/login.dart';
import '../language.dart';
import '../language.dart';
import '../reservations/reservationCell.dart';
import '../reservations/reservationList.dart';
import 'package:rental_manager/globals.dart' as globals;
import 'package:fluttertoast/fluttertoast.dart';
import 'locations.dart';
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart' as slideDialog;

BuildContext secondTabContext;

class SecondTab extends StatefulWidget {
  @override
  _SecondTabState createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> {
  int theriGroupVakue = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    secondTabContext = context;
  }

  Widget giveCenter(String yourText, [List<DocumentSnapshot> resetList]) {


    if (rightButton == "Edit") {
      if (yourText == "Reserved Page") {
        return ListView.builder(
            itemCount: reservationList.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                        NetworkImage(reservationList[index]["imageURL"]),
                      ),
                      title: Text(reservationList[index]["name"],
                          style: TextStyle(color: textcolor())),
                      subtitle: Text(
                        langaugeSetFunc("Amount: ") +
                            reservationList[index]["amount"],
                        style: TextStyle(color: textcolor()),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            getAMPM(reservationList[index]['startTime']),
                            style: TextStyle(color: textcolor(), fontSize: 15),
                          ),
                          Icon(
                            CupertinoIcons.info,
                            color: textcolor(),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) => reservationCell(passedFirestoreData: reservationList[index])))
                            .then((value) {
                          print(value.length);
                          setState(() {
                            var mylist = reservationList;
                            try{
                              if(value != null) {
                                if (reservationList.length != value.length) {
                                  reservationList = value;
                                }
                              }
                            }catch(e){
                              print(e);
                            }
                            giveCenter("Reserved Page", mylist);

                          });

                        });
                      }
                  ),
                  Divider(
                    height: 2.0,
                    color: textcolor(),
                  ),
                ],
              );
            });
      } else {
        return ListView.builder(
            itemCount: inUseList.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                      NetworkImage(inUseList[index]["imageURL"]),
                    ),
                    title: Text(
                      inUseList[index]["name"],
                      style: TextStyle(color: textcolor()),
                    ),
                    subtitle: Text(
                      langaugeSetFunc("Amount: ") +
                          inUseList[index]["amount"],
                      style: TextStyle(color: textcolor()),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          getAMPM(inUseList[index]['startTime']), style: TextStyle(color: textcolor(), fontSize: 15),
                        ),
                        Icon(
                          CupertinoIcons.info,
                          color: textcolor(),
                        ),
                      ],
                    ),
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Ticket(inUseList[index])));
                    },
                  ),
                  Divider(
                    height: 2.0,
                    color: textcolor(),
                  ),
                ],
              );
            });
      }
    } else {
      if (yourText == "Reserved Page") {
        return ListView.builder(
            itemCount: reservationMap.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                        NetworkImage(reservationList[index]["imageURL"]),
                      ),
                      title: Text(
                        reservationList[index]["name"],
                        style: TextStyle(color: textcolor()),
                      ),
                      subtitle: Text(
                        langaugeSetFunc("Amount: ") +
                            reservationList[index]["amount"],
                        style: TextStyle(color: textcolor()),
                      ),
                      trailing:  Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            getAMPM(reservationList[index]['startTime']), style: TextStyle(color: textcolor(), fontSize: 15),
                          ),
                          checkBox(reservationMap[index]),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          reservationMap[index] = !reservationMap[index];
                        });
                      }),
                  Divider(
                    height: 2.0,
                    color: textcolor(),
                  ),
                ],
              );
            });
      }else{
        return ListView.builder(
            itemCount: inUseMap.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                        NetworkImage(inUseList[index]["imageURL"]),
                      ),
                      title: Text(
                        inUseList[index]["name"],
                        style: TextStyle(color: textcolor()),
                      ),
                      subtitle: Text(
                        langaugeSetFunc("Amount: ") +
                            inUseList[index]["amount"],
                        style: TextStyle(color: textcolor()),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            getAMPM(inUseList[index]['startTime']), style: TextStyle(color: textcolor(), fontSize: 15),
                          ),
                          checkBox(inUseMap[index]),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          inUseMap[index] = !inUseMap[index];
                        });
                      }),
                  Divider(
                    height: 2.0,
                    color: textcolor(),
                  ),
                ],
              );
            });
      }
    }
    return Container();
  }

  @override

  Widget build(BuildContext context) {
    getList();

    Map<int, Widget> logoWidgets = <int, Widget>{
      0: Text(
        "Reserved",
        style: TextStyle(color: textcolor(), fontSize: 15),
      ),
      1: Text(
        "In Use",
        style: TextStyle(color: textcolor(), fontSize: 15),
      ),
    };

    List<Widget> bodies = [
      giveCenter("Reserved Page"),
      giveCenter("Using Page"),
    ];
    return Scaffold(
      body: bodies[theriGroupVakue],
      backgroundColor: backgroundcolor(),
      appBar: AppBar(
        elevation: 2.0,
        leading: leadingIcon(),
        backgroundColor: backgroundcolor(),
        centerTitle: true,
        title: CupertinoSlidingSegmentedControl(
          backgroundColor: Colors.grey,
          thumbColor: backgroundcolor(),
          groupValue: theriGroupVakue,
          onValueChanged: (changeFromGroupValue) {
            setState(() {
              rightButton = "Edit";
              theriGroupVakue = changeFromGroupValue;
              view = theriGroupVakue + 1;

            });
          },
          children: logoWidgets,
        ),
        actions: <Widget>[
          CupertinoButton(
            child: Text((langaugeSetFunc(rightButton))),
            onPressed: () {
              setState(() {
                if (rightButton == "Edit") {
                  rightButton = "Done";
                  print(rightButton);
                } else {
                  rightButton = "Edit";
                }
                reservationMap = [];
                inUseMap = [];
                for (int i = 0; i < reservationList.length; i++) {
                  reservationMap.add(false);
                }
                for (int i = 0; i < inUseList.length; i++) {
                  inUseMap.add(false);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  bool checkPickOrReturn(){
    if(rightButton != "Edit"){
      print(view);
      if(view == 1){
        PickUpList.clear();
        for(int i = 0; i < reservationMap.length; i++){
          if(reservationMap[i]){
            var value = reservationList[i];
            PickUpList.add(value);
          }
        }
      }else{
        ReturnList.clear();
        for(int i = 0; i < inUseMap.length; i++){
          if(inUseMap[i]){
            var value = inUseList[i];
            ReturnList.add(value);
          }
        }
      }
    }
    if(view == 1){
      print(PickUpList.isNotEmpty);
      return PickUpList.isEmpty;
    }else{
      return ReturnList.isEmpty;
    }
  }

  Widget leadingIcon(){
    if(rightButton != "Edit") {
      return IconButton(
        icon: Icon(Icons.check, color:  Colors.blue,),
        onPressed: checkPickOrReturn()? (){Fluttertoast.showToast(
          msg: 'Please select item(s)',
        );}:(){
          _handleClickMePickUP();
        },
      );

    }
  }
  Future<void> _handleClickMePickUP() async {
    String infor = "";
    if(view == 1) {
      infor = 'Are you going to pick up below item(s):\n';
      PickUpList.forEach((element) {
        String name = element['name'];
        String amount = element['amount'].toString();
        infor += name + '(' + amount + ')' + '\n';
      });
    }else{
      infor = 'Are you going to return below item(s):\n';
      ReturnList.forEach((element) {
        String name = element['name'];
        String amount = element['amount'].toString();
        infor += name + '(' + amount + ')' + '\n';
      });
    }





    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(

          title: Text(infor, style: TextStyle(color: Colors.black),),

          actions: <Widget>[
            CupertinoActionSheetAction(
              isDefaultAction: true,
              child: Text('Confirm', style: TextStyle(color: Colors.red),),
              onPressed: () async{
                var time = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
                var copyReturnList = ReturnList;
                if(view == 1){
                  PickUpList.forEach((element) {
                    Firestore.instance.collection(returnReservationCollection()).document(element.documentID).updateData(
                        {'status': 'Picked Up',
                          'picked Up time': time,
                        }
                    );
                  });
                }else{
                  ReturnList.forEach((element) {
                    Firestore.instance.collection(returnReservationCollection()).document(element.documentID).updateData({
                      'status' : 'Returned',
                      'return time': time,
                    });
                    var amount = element['amount'];
                    var num = int.parse(amount);
                    Firestore.instance.collection(returnItemCollection()).document(element['item']).get().then((value){
                      Firestore.instance.collection(returnItemCollection()).document(element['item']).updateData({
                        '# of items': int.parse(element['amount']) + value.data['# of items'],
                      });
                    });

                  });
                }

                QuerySnapshot documents1 = await Firestore.instance
                    .collection(returnReservationCollection())
                    .where('uid', isEqualTo: globals.uid)
                    .where('status', isEqualTo: 'Reserved')
                    .getDocuments();
                QuerySnapshot documents2 = await Firestore.instance
                    .collection(returnReservationCollection())
                    .where('uid', isEqualTo: globals.uid)
                    .where('status', isEqualTo: 'Picked Up')
                    .getDocuments();

                reservationMap.clear();
                inUseMap.clear();
                PickUpList.clear();
                ReturnList.clear();
                reservationList = documents1.documents;
                inUseList = documents2.documents;
                reservationList.forEach((element) {
                  reservationMap.add(false);
                });
                inUseList.forEach((element) {
                  inUseMap.add(false);
                });

                String View = "In Use";
                if(view == 1){
                  setState(() {
                    giveCenter("Reserved Page");
                  });
                }else{
                  setState(() {
                    giveCenter("Using Page");
                  });
                }
                Navigator.pop(context);
                var rate = 5.0;
                if(view == 2){
                  slideDialog.showSlideDialog(
                    context: secondTabContext,
                    child:  Container(
                      child: Form(

                        child: Column(
                          children: <Widget>[
                            Center(
                              child:Text("Thanks for your returning!\nDid you enjoy this experience"),
                            ),

                            Center(
                              child:  RatingBar(
                                initialRating: 5,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  rate = rating;
                                  print(rating);
                                },
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 300,
                              child: RaisedButton(
                                highlightElevation: 0.0,
                                splashColor: Colors.greenAccent,
                                highlightColor: Colors.green,
                                elevation: 0.0,
                                color: Colors.green,
                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        langaugeSetFunc("Submit"),
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
                                onPressed: () async{
                                  context = secondTabContext;
                                  copyReturnList.forEach((element) {
                                    Firestore.instance.collection(returnReservationCollection()).document(element.documentID).updateData({
                                      'rate': rate,
                                    });
                                  });
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  Navigator.pop(context, false);
                                  pop_window('Awesome', "Thanks for your review!", context);
                                  //await ReturnOrdersPopWindow2(globals.ContextInOrder, '','OK',"Thanks for your review","We appreciate your evaluation!\nYour review will be used in the Help- track Page");

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
                    ),
                    textField: Container(
                      child: Column(
                        children: <Widget>[
                        ],
                      ),
                    ),
                    barrierColor: Colors.white.withOpacity(0.7),
                  );
                }


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
}



class reservationPage extends StatefulWidget {
  final String title;
  reservationPage({Key key, this.title}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _reservationPageState();
  }
}

int view = 1;
String rightButton = "Edit";
List<DocumentSnapshot> reservationList = [];
List<DocumentSnapshot> inUseList = [];
List<String> namelist = [];
List<bool> reservationMap = [];
List<bool> inUseMap = [];
List<DocumentSnapshot>PickUpList = [];
List<DocumentSnapshot>ReturnList = [];
String getAMPM(String time_str) {
  time_str = parseTime(time_str);
  return time_str.substring(10);
}

Widget checkBox(bool check) {
  if (!check) {
    return Icon(
      CupertinoIcons.circle,
      color: textcolor(),
    );
  } else {
    return Icon(
      CupertinoIcons.check_mark_circled_solid,
      color: Colors.green,
    );
  }
}
void getList() async {
  QuerySnapshot documents1 = await Firestore.instance
      .collection(returnReservationCollection())
      .where('uid', isEqualTo: globals.uid)
      .where('status', isEqualTo: 'Reserved')
      .getDocuments();
  QuerySnapshot documents2 = await Firestore.instance
      .collection(returnReservationCollection())
      .where('uid', isEqualTo: globals.uid)
      .where('status', isEqualTo: 'Picked Up')
      .getDocuments();

  reservationList = documents1.documents;
  inUseList = documents2.documents;
}
class _reservationPageState extends State<reservationPage> {
  int theriGroupVakue = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget giveCenter(String yourText, [List<DocumentSnapshot> resetList]) {


    if (rightButton == "Edit") {
      if (yourText == "Reserved Page") {
        return ListView.builder(
            itemCount: reservationList.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(reservationList[index]["imageURL"]),
                    ),
                    title: Text(reservationList[index]["name"],
                        style: TextStyle(color: textcolor())),
                    subtitle: Text(
                      langaugeSetFunc("Amount: ") +
                          reservationList[index]["amount"],
                      style: TextStyle(color: textcolor()),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          getAMPM(reservationList[index]['startTime']),
                          style: TextStyle(color: textcolor(), fontSize: 15),
                        ),
                        Icon(
                          CupertinoIcons.info,
                          color: textcolor(),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => reservationCell(passedFirestoreData: reservationList[index])))
                          .then((value) {
                            print(value.length);
                            setState(() {
                              var mylist = reservationList;
                              try{
                                if(value != null) {
                                  if (reservationList.length != value.length) {
                                    reservationList = value;
                                  }
                                }
                              }catch(e){
                                print(e);
                              }
                              giveCenter("Reserved Page", mylist);

                            });

                      });
                    }
                  ),
                  Divider(
                    height: 2.0,
                    color: textcolor(),
                  ),
                ],
              );
            });
      } else {
        return ListView.builder(
            itemCount: inUseList.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(inUseList[index]["imageURL"]),
                    ),
                    title: Text(
                      inUseList[index]["name"],
                      style: TextStyle(color: textcolor()),
                    ),
                    subtitle: Text(
                      langaugeSetFunc("Amount: ") +
                          inUseList[index]["amount"],
                      style: TextStyle(color: textcolor()),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          getAMPM(inUseList[index]['startTime']), style: TextStyle(color: textcolor(), fontSize: 15),
                        ),
                        Icon(
                          CupertinoIcons.info,
                          color: textcolor(),
                        ),
                      ],
                    ),
                    onTap: (){
                      Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Ticket(inUseList[index])));
                    },
                  ),
                  Divider(
                    height: 2.0,
                    color: textcolor(),
                  ),
                ],
              );
            });
      }
    } else {
      if (yourText == "Reserved Page") {
        return ListView.builder(
            itemCount: reservationMap.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(reservationList[index]["imageURL"]),
                      ),
                      title: Text(
                        reservationList[index]["name"],
                        style: TextStyle(color: textcolor()),
                      ),
                      subtitle: Text(
                        langaugeSetFunc("Amount: ") +
                            reservationList[index]["amount"],
                        style: TextStyle(color: textcolor()),
                      ),
                      trailing: checkBox(reservationMap[index]),
                      onTap: () {
                        setState(() {
                          reservationMap[index] = !reservationMap[index];
                        });
                      }),
                  Divider(
                    height: 2.0,
                    color: textcolor(),
                  ),
                ],
              );
            });
      }else{
        return ListView.builder(
            itemCount: inUseMap.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                        NetworkImage(inUseList[index]["imageURL"]),
                      ),
                      title: Text(
                        inUseList[index]["name"],
                        style: TextStyle(color: textcolor()),
                      ),
                      subtitle: Text(
                        langaugeSetFunc("Amount: ") +
                            inUseList[index]["amount"],
                        style: TextStyle(color: textcolor()),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            getAMPM(inUseList[index]['startTime']), style: TextStyle(color: textcolor(), fontSize: 15),
                          ),
                          checkBox(inUseMap[index]),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          inUseMap[index] = !inUseMap[index];
                        });
                      }),
                  Divider(
                    height: 2.0,
                    color: textcolor(),
                  ),
                ],
              );
            });
      }
    }
    return Container();
  }

  @override


  Widget build(BuildContext context) {
    getList();

    Map<int, Widget> logoWidgets = <int, Widget>{
      0: Text(
        "Reserved",
        style: TextStyle(color: textcolor(), fontSize: 15),
      ),
      1: Text(
        "In Use",
        style: TextStyle(color: textcolor(), fontSize: 15),
      ),
    };

    List<Widget> bodies = [
      giveCenter("Reserved Page"),
      giveCenter("Using Page"),
    ];
    return Scaffold(
      body: bodies[theriGroupVakue],
      backgroundColor: backgroundcolor(),
      appBar: AppBar(
        elevation: 2.0,
        leading: leadingIcon(),
        backgroundColor: backgroundcolor(),
        centerTitle: true,
        title: CupertinoSlidingSegmentedControl(
          backgroundColor: Colors.grey,
          thumbColor: backgroundcolor(),
          groupValue: theriGroupVakue,
          onValueChanged: (changeFromGroupValue) {
            setState(() {
              rightButton = "Edit";
              theriGroupVakue = changeFromGroupValue;
              view = theriGroupVakue + 1;

            });
          },
          children: logoWidgets,
        ),
        actions: <Widget>[
          CupertinoButton(
            child: Text((langaugeSetFunc(rightButton))),
            onPressed: () {
              setState(() {
                if (rightButton == "Edit") {
                  rightButton = "Done";
                  print(rightButton);
                } else {
                  rightButton = "Edit";
                }
                reservationMap = [];
                inUseMap = [];
                for (int i = 0; i < reservationList.length; i++) {
                  reservationMap.add(false);
                }
                for (int i = 0; i < inUseList.length; i++) {
                  inUseMap.add(false);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  bool checkPickOrReturn(){
    if(rightButton != "Edit"){
      print(view);
      if(view == 1){
        PickUpList.clear();
        for(int i = 0; i < reservationMap.length; i++){
          if(reservationMap[i]){
            var value = reservationList[i];
            PickUpList.add(value);
          }
        }
      }else{
        ReturnList.clear();
        for(int i = 0; i < inUseMap.length; i++){
          if(inUseMap[i]){
            var value = inUseList[i];
            ReturnList.add(value);
          }
        }
      }
    }
    if(view == 1){
      print(PickUpList.isNotEmpty);
      return PickUpList.isEmpty;
    }else{
      return ReturnList.isEmpty;
    }
  }

  Widget leadingIcon(){
    if(rightButton != "Edit") {
      return IconButton(
        icon: Icon(Icons.check, color:  Colors.blue,),
        onPressed: checkPickOrReturn()? (){Fluttertoast.showToast(
          msg: 'Please select item(s)',
        );}:(){
          _handleClickMePickUP();
        },
      );

    }
  }
  Future<void> _handleClickMePickUP() async {
    String infor = "";
    if(view == 1) {
      infor = 'Are you going to pick up below item(s):\n';
      PickUpList.forEach((element) {
        String name = element['name'];
        String amount = element['amount'].toString();
        infor += name + '(' + amount + ')' + '\n';
      });
    }else{
      infor = 'Are you going to return below item(s):\n';
      ReturnList.forEach((element) {
        String name = element['name'];
        String amount = element['amount'].toString();
        infor += name + '(' + amount + ')' + '\n';
      });
    }





    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(

          title: Text(infor, style: TextStyle(color: Colors.black),),

          actions: <Widget>[
            CupertinoActionSheetAction(
              isDefaultAction: true,
              child: Text('Confirm', style: TextStyle(color: Colors.red),),
              onPressed: () async{
                var time = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
                var copyReturnList = ReturnList;
                if(view == 1){
                  PickUpList.forEach((element) {
                    Firestore.instance.collection(returnReservationCollection()).document(element.documentID).updateData(
                        {'status': 'Picked Up',
                          'picked Up time': time,
                        }
                    );
                  });
                }else{
                  ReturnList.forEach((element) {
                    Firestore.instance.collection(returnReservationCollection()).document(element.documentID).updateData({
                      'status' : 'Returned',
                      'return time': time,
                    });
                    var amount = element['amount'];
                    var num = int.parse(amount);
                    Firestore.instance.collection(returnItemCollection()).document(element['item']).get().then((value){
                      Firestore.instance.collection(returnItemCollection()).document(element['item']).updateData({
                      '# of items': int.parse(element['amount']) + value.data['# of items'],
                      });
                    });

                  });
                }

                QuerySnapshot documents1 = await Firestore.instance
                    .collection(returnReservationCollection())
                    .where('uid', isEqualTo: globals.uid)
                    .where('status', isEqualTo: 'Reserved')
                    .getDocuments();
                QuerySnapshot documents2 = await Firestore.instance
                    .collection(returnReservationCollection())
                    .where('uid', isEqualTo: globals.uid)
                    .where('status', isEqualTo: 'Picked Up')
                    .getDocuments();

                reservationMap.clear();
                inUseMap.clear();
                PickUpList.clear();
                ReturnList.clear();
                reservationList = documents1.documents;
                inUseList = documents2.documents;
                reservationList.forEach((element) {
                  reservationMap.add(false);
                });
                inUseList.forEach((element) {
                  inUseMap.add(false);
                });

                String View = "In Use";
                if(view == 1){
                  setState(() {
                    giveCenter("Reserved Page");
                  });
                }else{
                  setState(() {
                    giveCenter("Using Page");
                  });
                }
                Navigator.pop(context);
                var rate = 5.0;
                if(view == 2){
                  slideDialog.showSlideDialog(
                    context: secondTabContext,
                    child:  Container(
                      child: Form(

                        child: Column(
                          children: <Widget>[
                            Center(
                              child:Text("Thanks for your returning!\nDid you enjoy this experience"),
                            ),

                            Center(
                              child:  RatingBar(
                                initialRating: 5,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  rate = rating;
                                  print(rating);
                                },
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 300,
                              child: RaisedButton(
                                highlightElevation: 0.0,
                                splashColor: Colors.greenAccent,
                                highlightColor: Colors.green,
                                elevation: 0.0,
                                color: Colors.green,
                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        langaugeSetFunc("Submit"),
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
                                onPressed: () async{
                                  context = secondTabContext;
                                  copyReturnList.forEach((element) {
                                    Firestore.instance.collection(returnReservationCollection()).document(element.documentID).updateData({
                                      'rate': rate,
                                    });
                                  });
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  Navigator.pop(context, false);
                                  pop_window('Awesome', "Thanks for your review!", context);
                                  //await ReturnOrdersPopWindow2(globals.ContextInOrder, '','OK',"Thanks for your review","We appreciate your evaluation!\nYour review will be used in the Help- track Page");

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
                    ),
                    textField: Container(
                      child: Column(
                        children: <Widget>[
                        ],
                      ),
                    ),
                    barrierColor: Colors.white.withOpacity(0.7),
                  );
                }


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

}
