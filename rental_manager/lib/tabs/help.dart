import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/chatview/chat.dart';
import 'package:rental_manager/chatview/const.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/chatview/settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart' as slideDialog;
class MainScreen extends StatefulWidget {
  final String currentUserId;

  MainScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => MainScreenState(currentUserId: currentUserId);
}

class MainScreenState extends State<MainScreen> {
  MainScreenState({Key key, @required this.currentUserId});

  final String currentUserId;
  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  @override
  void initState() {
    super.initState();
    registerNotification();
    configLocalNotification();
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance.collection('users').document(currentUserId).updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      handleSignOut();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
    }
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.dfa.flutterchatdemo': 'com.duytq.flutterchatdemo',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics =
    new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);

                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }



  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ThirdTab()), (Route<dynamic> route) => false);
  }

  Future<Null> handleSignOutCopy() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'MAIN',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: primaryColor,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: primaryColor),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            // List
            Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                },
              ),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                child: Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                ),
                color: Colors.white.withOpacity(0.8),
              )
                  : Container(),
            )
          ],
        ),
        onWillPop: handleSignOut,
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document['photoUrl'] != null
                    ? CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                    width: 50.0,
                    height: 50.0,
                    padding: EdgeInsets.all(15.0),
                  ),
                  imageUrl: document['photoUrl'],
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.account_circle,
                  size: 50.0,
                  color: greyColor,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Name: ${document['nickname']}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'About me: ${document['aboutMe'] ?? 'Student'}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                      peerId: document.documentID,
                      peerAvatar: document['photoUrl'],
                    )));
          },
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}





//import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart'; // IOS的Cupertino控件库
//import 'package:flutter/foundation.dart'; //一个用于识别操作系统的工具库，其内的defaultTargetPlatform值可帮助我们识别操作系统
//import 'package:draggable_fab/draggable_fab.dart';
//import '../globals.dart' as globals;
//import 'package:flutter_speed_dial/flutter_speed_dial.dart';
//import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
//import 'package:rental_manager/PlatformWidget/strings.dart';
//import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart' as slideDialog;
//
//String NAME = "Team Cowculator";
//double screenWidth;
//final ThemeData kIOSTheme = new ThemeData(
//  primarySwatch: Colors.orange,
//  primaryColor: Colors.grey[100],
//  primaryColorBrightness: Brightness.light,
//);
//
//final ThemeData kDefaultTheme = new ThemeData(
//    primarySwatch: Colors.purple, accentColor: Colors.orangeAccent[400]);
//
//class ThirdTab extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return new MaterialApp(
//        title: "Help",
//        theme: defaultTargetPlatform == TargetPlatform.iOS
//            ? kIOSTheme
//            : kDefaultTheme,
//        home: new ChatScreen());
//  }
//}
//
//// 聊天页面的主界面
//class ChatScreen extends StatefulWidget {
//  @override
//  State createState() => new ChatScreenState();
//}
//
//// 单个聊天的界面无状态
//class ChatMessage extends StatelessWidget {
//  final String text;
//  final AnimationController animationController;
//  ChatMessage({this.text, this.animationController});
//
//  @override
//  Widget build(BuildContext context) {
//    screenWidth = MediaQuery.of(context).size.width;
//    return new SizeTransition(
//        sizeFactor: new CurvedAnimation(
//            parent: animationController, curve: Curves.easeInOut),
//        axisAlignment: 0.0,
//        child: new Container(
//          margin: const EdgeInsets.symmetric(vertical: 10.0),
//          child: new Row(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              new Container(
//                  margin: const EdgeInsets.only(right: 16.0),
//                  child: new CircleAvatar(child: new Text(NAME[0]))),
//              new Expanded(
//                  child: new Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  new Text(NAME, style: Theme.of(context).textTheme.subhead),
//                  new Container(
//                      margin: const EdgeInsets.only(top: 5.0),
//                      child: new Text(text))
//                ],
//              ))
//            ],
//          ),
//        ));
//  }
//}
//
//class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
//  final List<ChatMessage> chatMessages = <ChatMessage>[];
//
//  final TextEditingController textEditingController =
//      new TextEditingController();
//  bool _isComposing = false;
//
//  void handleSubmitted(String text) {
//    textEditingController.clear();
//    setState(() {
//      _isComposing = false;
//    });
//    ChatMessage chatMessage = new ChatMessage(
//        text: text,
//        animationController: new AnimationController(
//            duration: new Duration(milliseconds: 2000), vsync: this));
//    setState(() {
//      chatMessages.insert(0, chatMessage);
//    });
//    chatMessage.animationController.forward();
//  }
//
//  Widget _fixTextWeight() {
//    return new Container(
//        margin: const EdgeInsets.symmetric(horizontal: 8.0),
//        child: new Row(
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//            new Flexible(
//                child: new TextField(
//                    autofocus: true,
//                    keyboardAppearance: Brightness.dark,
//                    controller: textEditingController,
//                    onChanged: (String text) {
//                      setState(() {
//                        _isComposing = text.length > 0;
//                      });
//                    },
//                    decoration: new InputDecoration.collapsed(
//                        hintText: "Need Help?  Send a message to us"),
//                    onSubmitted: handleSubmitted)),
//            new Container(
//                margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                child: defaultTargetPlatform == TargetPlatform.iOS
//                    ? new CupertinoButton(
//                        child: new Text("Send"),
//                        onPressed: _isComposing
//                            ? () => handleSubmitted(textEditingController.text)
//                            : null)
//                    : new IconButton(
//                        icon: new Icon(Icons.send),
//                        onPressed: _isComposing
//                            ? () => handleSubmitted(textEditingController.text)
//                            : null))
//          ],
//        ));
//  }
//  bool dialVisible = true;
//
//  void _showDialog() {
//    slideDialog.showSlideDialog(
//      context: context,
//      child: Text(
//        "Share Your Ideas With Us",
//      ),
//      textField: Container(
//        child: Column(
//          children: <Widget>[
//            TextField(
//              onChanged:(text){
//                print("First text field: $text");
//              },
//              cursorColor: Colors.teal.shade900,
//              scrollPadding:  const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
//              decoration: InputDecoration(
//                border: new OutlineInputBorder(
//                  borderRadius: const BorderRadius.all(
//                    const Radius.circular(8.0),
//                  ),
//                  borderSide: new BorderSide(
//                    color: Colors.transparent,
//                    width: 1.0,
//                  ),
//                ),
//                labelText: 'Email',
//                prefixIcon: const Icon(Icons.email, color: Colors.black),
//                // labelStyle:
//                // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
//                contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
//              ),
//            ),
//            SizedBox(
//              height: 10,
//            ),
//            TextField(
//              onChanged:(text){
//                print("First text field: $text");
//              },
//              cursorColor: Colors.teal.shade900,
//              scrollPadding:  const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
//              decoration: InputDecoration(
//                border: new OutlineInputBorder(
//                  borderRadius: const BorderRadius.all(
//                    const Radius.circular(8.0),
//                  ),
//                  borderSide: new BorderSide(
//                    color: Colors.transparent,
//                    width: 1.0,
//                  ),
//                ),
//                labelText: 'Title',
//                prefixIcon: const Icon(Icons.title, color: Colors.black),
//                // labelStyle:
//                // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
//                contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
//              ),
//            ),
//            SizedBox(
//              height: 10,
//            ),
//            Container(
//              child: TextField(
//                onChanged:(text){
//                  print("First text field: $text");
//                },
//                cursorColor: Colors.teal.shade900,
//                scrollPadding:  const EdgeInsets.symmetric(vertical: 50.0,horizontal: 50),
//                decoration: InputDecoration(
//                  border: new OutlineInputBorder(
//                    borderRadius: const BorderRadius.all(
//                      const Radius.circular(8.0),
//                    ),
//                    borderSide: new BorderSide(
//                      color: Colors.transparent,
//                      width: 1.0,
//                    ),
//                  ),
//                  labelText: 'Content',
//                  prefixIcon: const Icon(Icons.content_paste, color: Colors.black),
//                  // labelStyle:
//                  // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
//                  contentPadding: const EdgeInsets.symmetric(vertical: 50.0,horizontal: 50),
//                ),
//              ),
//            ),
//            SizedBox(
//              height: 15,
//            ),
//            SizedBox(
//              width: 200,
//              child: RaisedButton(
//                highlightElevation: 0.0,
//                splashColor: Colors.greenAccent,
//                highlightColor: Colors.green,
//                elevation: 0.0,
//                color: Colors.blue,
//                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    Center(
//                      child: Text(
//                        "Submit",
//                        style: TextStyle(
//                          fontSize: 15,
//                          // backgroundColor:  Colors.teal[50],
//                          color: Colors.white,
//                          fontFamily: 'Montserrat',
//                        ),
//                      ),
//                    ),
//
//                  ],
//                ),
//                onPressed: () async{
//                  //_handleSignIn();
//
//                  //rewriteData();
//                  //Navigator.of(context).pushReplacementNamed('/MainViewScreen');
//
//
//                },
//                padding: EdgeInsets.all(7.0),
//                //color: Colors.teal.shade900,
//                disabledColor: Colors.black,
//                disabledTextColor: Colors.black,
//
//              ),
//            ),
//          ],
//        ),
//      ),
//      barrierColor: Colors.white.withOpacity(0.7),
//    );
//  }
//
//  SpeedDial buildSpeedDial() {
//    double height = MediaQuery.of(context).size.height;
//    return SpeedDial(
//      marginRight: 10,
//      marginBottom: height/2,
//      animatedIcon: AnimatedIcons.menu_close,
//      animatedIconTheme: IconThemeData(size: 22.0),
//      // child: Icon(Icons.add),
//      onOpen: () => print('OPENING DIAL'),
//      onClose: () => print('DIAL CLOSED'),
//      visible: dialVisible,
//      curve: Curves.bounceIn,
//      children: [
//        SpeedDialChild(
//          child: Icon(Icons.lock, color: Colors.white),
//          backgroundColor: Colors.deepOrange,
//          onTap: () {
//            PlatformAlertDialog(
//              title: 'Some Information',
//              content:
//              'Let Users sumbit their request in the textfield or leading them to a new page',
//              defaultActionText: Strings.ok,
//            ).show(context);
//          },
//          label: 'Lost And Found',
//          labelStyle: TextStyle(fontWeight: FontWeight.w500),
//          labelBackgroundColor: Colors.deepOrangeAccent,
//        ),
//        SpeedDialChild(
//          child: Icon(Icons.lightbulb_outline, color: Colors.white),
//          backgroundColor: Colors.blue,
//          onTap: () => _showDialog(),
//          labelWidget: Container(
//            color: Colors.blue,
//            margin: EdgeInsets.only(right: 10),
//            padding: EdgeInsets.all(6),
//            child: Text('Want To Share Some Ideas '),
//          ),
//        ),
//        SpeedDialChild(
//          child: Icon(Icons.receipt, color: Colors.white),
//          backgroundColor: Colors.green,
//          onTap: () => print('3'),
//          label: 'Questions about Reservations',
//          labelStyle: TextStyle(fontWeight: FontWeight.w500),
//          labelBackgroundColor: Colors.green,
//        ),
//      ],
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    String appBarTitle = "Help Chat";
//
//    return new Scaffold(
//        appBar: new AppBar(
//            backgroundColor: Colors.teal,
//            title: new Text(
//              appBarTitle,
//              style: TextStyle(
//                color: Colors.white,
//              ),
//            ),
//            elevation: defaultTargetPlatform == TargetPlatform.iOS ? 0.0 : 4.0),
//      floatingActionButton:buildSpeedDial(),
//        body: new Column(children: <Widget>[
//          new Flexible(
//              child: new ListView.builder(
//                  padding: new EdgeInsets.all(8.0),
//                  reverse: true,
//                  itemBuilder: (BuildContext context, int index) =>
//                      chatMessages[index],
//                  itemCount: chatMessages.length)),
//          new Divider(height: 1.0),
//          new Container(
//              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
//              child: _fixTextWeight()),
//
//        ]),
//    );
//  }
//}
//

//
//  @override
//  Widget build(BuildContext context) {
//    String appBarTitle = "Help Chat";
//
//    return new Scaffold(
//        appBar: new AppBar(
//            backgroundColor: Colors.teal,
//            title: new Text(
//              appBarTitle,
//              style: TextStyle(
//                color: Colors.white,
//              ),
//            ),
//            elevation: defaultTargetPlatform == TargetPlatform.iOS ? 0.0 : 4.0),
//      floatingActionButton:buildSpeedDial(),
//        body: new Column(children: <Widget>[
//          new Flexible(
//              child: new ListView.builder(
//                  padding: new EdgeInsets.all(8.0),
//                  reverse: true,
//                  itemBuilder: (BuildContext context, int index) =>
//                      chatMessages[index],
//                  itemCount: chatMessages.length)),
//          new Divider(height: 1.0),
//          new Container(
//              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
//              child: _fixTextWeight()),
//
//        ]),
//    );
//  }
//}
//
