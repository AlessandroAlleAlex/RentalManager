import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/organization/organization_selection.dart';
import 'package:rental_manager/tabs/reservations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rental_manager/mainView.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/AuthLogin.dart';
import 'package:rental_manager/PlatformWidget/platform_exception_alert_dialog.dart';
import 'package:flutter/services.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
//import 'package:email_validator/email_validator.dart';
import 'dart:convert' show json;
import 'globals.dart' as globals;
import 'dart:core';
import 'package:rental_manager/CurrentReservation.dart';
import 'package:progress_dialog/progress_dialog.dart';
import "package:http/http.dart" as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:rental_manager/qrcodelogin.dart';
import 'language.dart';
import 'qrcodelogin.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'dart:ui' as ui;
import 'package:devicelocale/devicelocale.dart';

Future getData() async {
  Firestore.instance
      .collection('global_users')
      .document(globals.uid)
      .get()
      .then((DocumentSnapshot ds) {
    // use ds as a snapshot
    var doc = ds.data;
    globals.studentID = doc["StudentID"];
    globals.username = doc["name"];
    globals.UserImageUrl = doc["imageURL"];
    if (globals.UserImageUrl == null) {
      globals.UserImageUrl =
          "https://images.unsplash.com/photo-1581660545544-83b8812f9516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80";
    }
    globals.phoneNumber = doc["PhoneNumber"];
    globals.organization = doc['organization'];
  });
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/LoginScreen': (context) => MyApp(),
        '/MainViewScreen': (context) => MyHome1(),
        '/SecondTab': (context) => SecondTab(),
        '/CR View': (context) => CureentReservation(),
      },
      initialRoute: 'LoginScreen',
    );
  }

  @override
  Widget know(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('CollectionA')
            .document('DOc1')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text("Loading");
          }
          var userDocument = snapshot.data;
          return new Text(userDocument["a"]);
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// var isLoggedIn = await googleSignIn.isSignedIn();
final FirebaseAuth auth = FirebaseAuth.instance;

//Future<void> taskSignUp(email, password) async{
//  var authHandler = new Auth();
//  var mystr = await authHandler.signUp(email, password);
//
//  PlatformAlertDialog(
//    title: Strings.checkYourEmail,
//    content: Strings.activationLinkSent(_email),
//    defaultActionText: Strings.ok,
//  ).show(context);
//}

// setState(() => sessionID = info['session_id']);

Future uploadData(
    usernameFirst, usernameLast, email, uid, String organization) async {
  String fullName = usernameFirst + ' ' + usernameLast;
  final databaseReference = Firestore.instance;
  String doc = "AppSignInUser" + email;
  // String thiscollectionName = '${organization}_users';

  await databaseReference.collection('global_users').document(doc).setData({
    'name': fullName,
    'imageURL':
        "https://images.unsplash.com/photo-1581660545544-83b8812f9516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80",
    'PhoneNumber': '',
    'Sex': '',
    'StudentID': '',
    'email': email,
    'organization': organization,
    'Admin': false,
  });
}

void updateData(String collectionName) async {
  final QuerySnapshot result =
      await Firestore.instance.collection(collectionName).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  List<String> userNameList = [];
  documents.forEach((data) => userNameList.add(data.documentID));

  for (var i = 0; i < userNameList.length; i++) {
    await Firestore.instance
        .collection(collectionName)
        .document(userNameList[i])
        .updateData({
      'organization': true,
    });
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String username;
  String password;
  bool _Accountvalidate = false;
  String _contactText;
  GoogleSignInAccount _currentUser;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<FirebaseUser> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  String googleLogInName = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  FirebaseUser _user;

  Future<FirebaseUser> _myGoogleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;

    print("signed in " + user.displayName);
    print("signed in " + user.email);

    return user;
  }

  List<Key> keys = [
    Key("Network"),
    Key("NetworkDialog"),
    Key("Flare"),
    Key("FlareDialog"),
    Key("Asset"),
    Key("AssetDialog")
  ];

  @override
  /*
  * List<String>userinfor = [];
   userinfor.add(globals.studentID);
   userinfor.add(globals.username );
   userinfor.add(globals.UserImageUrl);
   userinfor.add(globals.phoneNumber);
   userinfor.add(globals.email );
   userinfor.add(globals.sex );
   var prefs = await SharedPreferences.getInstance();
   await prefs.setStringList("user", userinfor);
  * */
  void testfunc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("user");

    try {
      var isDark = prefs.getBool('isDark'),
          userSelectTheme = prefs.getInt('userSelectTheme');
      if (isDark == null || userSelectTheme == null) {
        final Brightness brightnessValue =
            MediaQuery.of(context).platformBrightness;
        bool Dark = brightnessValue == Brightness.dark;
        globals.dark = Dark;
        globals.userSelectTheme = -1;
      }
      globals.dark = isDark;
      globals.userSelectTheme = -1;

      print('isDark:' + isDark.toString());
      print('userSelectTheme: ' + userSelectTheme.toString());
    } catch (e) {
      print(e);
    }

    var language = prefs.getString('mylanguage');

    
    if (language != null) {
      if (language == 'English' || language == 'SimplifiedChinese') {
        globals.langaugeSet = language;
      } else {
        globals.langaugeSet = "English";
      }
    } else {
      globals.langaugeSet = "English";
    }
    if (list == null) {
      return;
    }

    try {
      if (list != null && list.length > 0) {
        globals.uid = list[0];
        globals.studentID = list[1];
        globals.username = list[2];
        print("List2: " + list[2]);
        globals.UserImageUrl = list[3];
        globals.phoneNumber = list[4];
        globals.email = list[5];
        globals.sex = list[6];
        if (list.length > 7) {
          globals.organization = list[7];
        }

        if (globals.organization == null || globals.organization.isEmpty) {
          await Firestore.instance
              .collection(returnUserCollection())
              .document(globals.uid)
              .get()
              .then((DocumentSnapshot ds) {
            // use ds as a snapshot
            var doc = ds.data;
            try {
              globals.organization = doc['organization'];
            } catch (e) {
              print(e);
            }
          });
        }
        Navigator.of(context).pushReplacementNamed('/MainViewScreen');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future getExistingOrganizations() async {
    await Firestore.instance
        .collection('organizations')
        .getDocuments()
        .then((organization) {
      organization.documents
          .forEach((org) => globals.existingOrganizations.add(org['name']));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getExistingOrganizations();
  }

  @override
  Widget build(BuildContext context) {
//    resetData('ArcItemsByName');

    var authHandler = new Auth();
    var screenWidth = MediaQuery.of(context).size.width;
    bool userExist = false;
    ProgressDialog prLOGIN;
    prLOGIN = new ProgressDialog(context, type: ProgressDialogType.Normal);
    prLOGIN.style(message: 'Showing some progress...');

    //testfunc();
    testfunc();

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            onTap: () {
              // call this method here to hide soft keyboard
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height / 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('images/appstore.png'),
                    ),
                    SizedBox(height: 10, width: 150),
                    Text(
                      'Rental Manager',
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        fontSize: 20,
                        color: Colors.teal.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10, width: 150),
                    Text(
                      'Weclome',
                      style: TextStyle(
                        fontFamily: 'Source Sans Pro',
                        color: Colors.teal.shade900,
                        fontSize: 20,
                        letterSpacing: 2.5,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: 150,
                      child: Divider(
                        color: Colors.teal.shade900,
                      ),
                    ),
                    SizedBox(height: 10, width: 150),
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: TextField(
                        onChanged: (text) {
                          username = text;
                          print("First text field: $text");
                        },
                        // controller: _username,
                        cursorColor: Colors.teal.shade900,
                        scrollPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 30),
                        decoration: InputDecoration(
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(8.0),
                            ),
                            borderSide: new BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          labelText:
                              langaugeSetFunc('Enter your Email Address'),
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.black),
                          // labelStyle:
                          // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 30),
                        ),
                      ),
                    ),
                    SizedBox(height: 20, width: 150),
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: TextField(
                        onChanged: (text) {
                          password = text;

                          //print("First text field: $text");
                        },
                        obscureText: true,
                        cursorColor: Colors.teal.shade900,
                        decoration: InputDecoration(
                          contentPadding:
                              new EdgeInsets.fromLTRB(20.0, 10.0, 100.0, 10.0),
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(8.0),
                            ),
                            borderSide: new BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          labelText: langaugeSetFunc('Enter your Password'),
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.black),
                          // labelStyle:
                          // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                          // contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: screenWidth / 6 * 5,
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
                                    langaugeSetFunc("LOGIN"),
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
                              if (username == null || password == null) {
                                String a = langaugeSetFunc('Warning'),
                                    b = langaugeSetFunc(
                                        'Email Adress and Password Cannot be empty');
                                pop_window(a, b, context);
                              } else {
                                var e = await authHandler.signIn(
                                    username, password);
                                if (e == "false") {
                                  String a = langaugeSetFunc(
                                          'ERROR Email NEED VERFIED'),
                                      b = langaugeSetFunc(
                                          'Verify Your Email Please');
                                  pop_window(a, b, context);
                                } else if (ErrorDetect(e)) {
                                  String a = errorDetect(e, pos: 0),
                                      b = errorDetect(e, pos: 1);
                                  pop_window(a, b, context);
                                } else {
                                  username = username.trim();
                                  var email = username;
                                  globals.uid = 'AppSignInUser' + email;

                                  await Firestore.instance
                                      .collection(returnUserCollection())
                                      .document(globals.uid)
                                      .get()
                                      .then((DocumentSnapshot ds) async {
                                    // use ds as a snapshot
                                    var doc = ds.data;
                                    if (!globals.existingOrganizations
                                            .contains(doc['organization']) &&
                                        doc['Admin'] == false) {
                                      await Firestore.instance
                                          .collection('global_users')
                                          .document(globals.uid)
                                          .updateData({'Admin': true});
                                      await Firestore.instance
                                          .collection('organizations')
                                          .document()
                                          .setData(
                                              {'name': doc['organization']});
                                    }
                                    try {
                                      globals.studentID = doc["StudentID"];
                                      globals.username = doc["name"];
                                      globals.UserImageUrl = doc["imageURL"];
                                      globals.phoneNumber = doc["PhoneNumber"];
                                      globals.email = doc["email"];
                                      globals.organization =
                                          doc['organization'];
                                    } catch (e) {
                                      print(e);
                                    }
                                    if (doc['Admin'] == true) {
                                      globals.isAdmin = true;
                                    } else {
                                      globals.isAdmin = false;
                                    }
                                  });
                                  print("Here: " + globals.organization);
                                  List<String> userinfor = [];
                                  userinfor.add(globals.uid);
                                  userinfor.add(globals.studentID);
                                  userinfor.add(globals.username);
                                  userinfor.add(globals.UserImageUrl);
                                  userinfor.add(globals.phoneNumber);
                                  userinfor.add(username);
                                  userinfor.add(globals.sex);
                                  userinfor.add(globals.organization);
                                  var prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setStringList("user", userinfor);
                                  await prefs.setBool('isDark', false);
                                  await prefs.setInt('userSelectTheme', -1);

                                  Navigator.of(context)
                                      .pushReplacementNamed('/MainViewScreen');
                                }
                              }
                            },
                            padding: EdgeInsets.all(7.0),
                            //color: Colors.teal.shade900,
                            disabledColor: Colors.black,
                            disabledTextColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: screenWidth / 6 * 5,
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
                                Image(
                                  image: NetworkImage(
                                      'https://pluspng.com/img-png/google-logo-png-open-2000.png'),
                                  height: 30,
                                ),
                                SizedBox(width: 20.0),
                                Center(
                                  child: Text(
                                    langaugeSetFunc("LOGIN With Google"),
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
                              //_handleSignIn();

                              try {
                                FirebaseUser googleuser =
                                    await _myGoogleSignIn();

                                if (googleuser != null) {
                                  globals.mygoogleuser = googleuser;

                                  globals.username = googleuser.displayName;
                                  globals.email = googleuser.email;
                                  globals.uid =
                                      'GoogleSignInUser' + globals.email;

                                  await prLOGIN.show();
                                  prLOGIN.hide();
                                  String fullName = globals.username;
                                  final databaseReference = Firestore.instance;

                                  final QuerySnapshot result = await Firestore
                                      .instance
                                      .collection(returnUserCollection())
                                      .getDocuments();
                                  final List<DocumentSnapshot> documents =
                                      result.documents;

                                  for (var i = 0; i < documents.length; i++) {
                                    if (documents[i].documentID ==
                                        globals.uid) {
                                      userExist = true;
                                      break;
                                    }
                                  }
                                  print(userExist == true);
                                  if (userExist) {
                                    print("UserExists\n");
                                    try {
                                      await Firestore.instance
                                          .collection(returnUserCollection())
                                          .document(globals.uid)
                                          .get()
                                          .then((DocumentSnapshot ds) {
                                        // use ds as a snapshot
                                        var doc = ds.data;
                                        globals.UserImageUrl = doc["imageURL"];
                                        globals.studentID = doc["StudentID"];
                                        globals.phoneNumber =
                                            doc["PhoneNumber"];
                                        globals.sex = doc["Sex"];
                                        if (globals.UserImageUrl == null) {
                                          globals.UserImageUrl =
                                              "https://images.unsplash.com/photo-1581660545544-83b8812f9516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80";
                                        }
                                        if (globals.studentID == null) {
                                          globals.studentID = "";
                                        }
                                        if (globals.phoneNumber == null) {
                                          globals.phoneNumber = "";
                                        }
                                        if (globals.sex == null) {
                                          globals.sex = "";
                                        }
                                      });
                                    } catch (e) {
                                      print(e);
                                    }
                                  } else {
                                    await databaseReference
                                        .collection(returnUserCollection())
                                        .document(globals.uid)
                                        .setData({
                                      'name': fullName,
                                      'email': globals.email,
                                      'imageURL': globals.UserImageUrl,
                                    });
                                    globals.UserImageUrl =
                                        "https://images.unsplash.com/photo-1581660545544-83b8812f9516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80";
                                  }

                                  List<String> userinfor = [];
                                  userinfor.add(globals.uid);
                                  userinfor.add(globals.studentID);
                                  userinfor.add(globals.username);
                                  userinfor.add(globals.UserImageUrl);
                                  userinfor.add(globals.phoneNumber);
                                  userinfor.add(globals.email);
                                  userinfor.add(globals.sex);
                                  var prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setStringList("user", userinfor);
                                  await prefs.setBool('isDark', false);
                                  await prefs.setInt('userSelectTheme', -1);
                                  getData().whenComplete(() => Navigator.of(
                                          context)
                                      .pushReplacementNamed('/MainViewScreen'));
                                }
                              } catch (e) {
                                print(
                                    "Erro Line 515 Main.dart:" + e.toString());
                              }

                              //rewriteData();
                              //Navigator.of(context).pushReplacementNamed('/MainViewScreen');
                            },
                            padding: EdgeInsets.all(7.0),
                            //color: Colors.teal.shade900,
                            disabledColor: Colors.black,
                            disabledTextColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: screenWidth / 6 * 5,
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
                                SizedBox(width: 20.0),
                                Center(
                                  child: Text(
                                    langaugeSetFunc("Sign In With Scan"),
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
                              //_handleSignIn();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GenerateScreen()));

                              //rewriteData();
                              //Navigator.of(context).pushReplacementNamed('/MainViewScreen');
                            },
                            padding: EdgeInsets.all(7.0),
                            //color: Colors.teal.shade900
                            disabledColor: Colors.black,
                            disabledTextColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          langaugeSetFunc('New to Rental Manager?'),
                          style: TextStyle(fontFamily: 'Montserrat'),
                        ),
                        SizedBox(width: 5.0),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    //SignUpPage(),
                                    OrganizationSelection(),
                              ),
                            );
                          },
                          child: Text(
                            langaugeSetFunc('Register'),
                            style: TextStyle(
                                color: Colors.green,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Container(
                        //alignment: Alignment(1.0, 0.0),
                        //padding: EdgeInsets.only(top: 15.0, left: 20.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => resetPassword()));
                          },
                          child: Text(
                            langaugeSetFunc('Forgot Password'),
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      //home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class resetPassword extends StatefulWidget {
  @override
  _resetPasswordState createState() => _resetPasswordState();
}

class _resetPasswordState extends State<resetPassword> {
  @override
  Widget build(BuildContext context) {
    var authHandler = new Auth();
    var screenWidth = MediaQuery.of(context).size.width;
    var email;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(langaugeSetFunc('Reset PassWord')),
          backgroundColor: Colors.teal,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10, width: 150),
              Text(
                'Rental Manager',
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 20,
                  color: Colors.teal.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10, width: 150),
              Text(
                'Enter your email address below',
                style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  color: Colors.teal.shade900,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
                width: 150,
                child: Divider(
                  color: Colors.teal.shade900,
                ),
              ),
              SizedBox(height: 10, width: 150),

              Container(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: TextField(
                  onChanged: (text) {
                    email = text;
                  },
                  // controller: _username,
                  cursorColor: Colors.teal.shade900,
                  scrollPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 30),
                  decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(8.0),
                      ),
                      borderSide: new BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                    ),
                    labelText: langaugeSetFunc('Enter your Email Address'),
                    prefixIcon: const Icon(Icons.email, color: Colors.black),
                    // labelStyle:
                    // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 30),
                  ),
                ),
              ),
              SizedBox(height: 20, width: 150),

              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: screenWidth / 6 * 5,
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
                              langaugeSetFunc("Send Verification Email"),
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
                        bool isEmpty = false;
                        if (email == null) {
                          isEmpty = true;
                          String a = 'Warning',
                              b = 'Email Adress Cannot be empty';
                          pop_window(a, b, context);
                        }

                        for (int i = 0; i < 100000; i++) {
                          email = email.trim();
                        }

                        final QuerySnapshot result = await Firestore.instance
                            .collection(returnUserCollection())
                            .getDocuments();
                        final List<DocumentSnapshot> documents =
                            result.documents;
                        List<String> userNameList = [];
                        documents.forEach(
                            (data) => userNameList.add(data.documentID));
                        bool found = false;
                        for (var i = 0; i < userNameList.length; i++) {
                          if (email == userNameList[i]) {
                            found = true;
                            break;
                          }
                        }

                        if (found) {
                          ProgressDialog prForgetPassword;
                          prForgetPassword = new ProgressDialog(context,
                              type: ProgressDialogType.Normal);
                          prForgetPassword.update(
                            message: 'Sending Email...',
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
                          await prForgetPassword.show();
                          Future.delayed(Duration(seconds: 2)).then((onValue) {
                            prForgetPassword.update(
                              message: "Email Sent",
                              progressWidget: Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator()),
                              progressTextStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w400),
                              messageTextStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.w600),
                            );
                            Future.delayed(Duration(seconds: 2)).then((value) {
                              authHandler.resetPassword(email);
                              prForgetPassword.hide();
                            });
                          });

                          print('Founding');
                        } else {
                          String a = 'Warning',
                              b = 'Email Adress Not Found in Records';
                          pop_window(a, b, context);
                        }
                      },
                      padding: EdgeInsets.all(7.0),
                      //color: Colors.teal.shade900,
                      disabledColor: Colors.black,
                      disabledTextColor: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
//              Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  SizedBox(
//                    width: screenWidth / 6 * 5,
//                    child: RaisedButton(
//                      highlightElevation: 0.0,
//                      splashColor: Colors.greenAccent,
//                      highlightColor: Colors.green,
//                      elevation: 0.0,
//                      color: Colors.green,
//                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          Center(
//                            child: Text(
//                              "Back to Login Page",
//                              style: TextStyle(
//                                fontSize: 15,
//                                // backgroundColor:  Colors.teal[50],
//                                color: Colors.white,
//                                fontFamily: 'Montserrat',
//                              ),
//                            ),
//                          ),
//
//                        ],
//                      ),
//                      onPressed: () {
//                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
//                      },
//                      padding: EdgeInsets.all(7.0),
//                      //color: Colors.teal.shade900,
//                      disabledColor: Colors.black,
//                      disabledTextColor: Colors.black,
//
//                    ),
//                  ),
//
//
//
//                ],
//              ),
            ],
          ),
        ),
      ),
      //home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

bool ErrorDetect(String e) {
  if (e.contains('PlatformException')) {
    return true;
  } else {
    return false;
  }
}

String errorDetect(String e, {int pos = 1}) {
  if (e.contains('PlatformException')) {
    List<String> strList = e.split(",");
    String _retstr = strList[pos];

    if (pos == 0) {
      strList.clear();
      strList = _retstr.split("(");
      _retstr = strList[1];
      try {
        _retstr = _retstr.replaceAll("_", " ");
      } catch (e) {
        print(e);
      }
    }

    return _retstr;
  } else {
    return e;
  }
}

void resetData(String collectionName) async {
  await Firestore.instance
      .collection(collectionName)
      .document('Badminton Racquet')
      .setData({
    'name': 'Badminton Racquet',
    'num': 30,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Badminton Birdie')
      .setData({
    'name': 'Badminton Birdie/Shuttle Cock-White',
    'num': 30,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Band-Resistance (Orange) "')
      .setData({
    'name': 'Band-Resistance (Orange) 1/2"',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Band-Resistance (Green)  "')
      .setData({
    'name': 'Band-Resistance (Green) 3/4"',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Band-Resistance (Red)"')
      .setData({
    'name': 'Band-Resistance (Red) 1"',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Band-Resistance (Blue)"')
      .setData({
    'name': 'Band-Resistance (Blue) 1-3/4"',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Band-Resistance (Purple)"')
      .setData({
    'name': 'Band-Resistance (Purple) 2-1/2"',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Band-Tube: Very Light (Yellow)')
      .setData({
    'name': 'Band-Tube: Very Light (Yellow)',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Band-Tube: Light (Green)')
      .setData({
    'name': 'Band-Tube: Light (Green)',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Band-Tube: Medium (Red)')
      .setData({
    'name': 'Band-Tube: Medium (Red)',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Band-Tube: Heavy (Blue)')
      .setData({
    'name': 'Band-Tube: Heavy (Blue)',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Band-Tube: Ultra Heavy (Purple)')
      .setData({
    'name': 'Band-Tube: Ultra Heavy (Purple)',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Barbell Pad-Blue')
      .setData({
    'name': 'Barbell Pad-Blue',
    'num': 10,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Basketball (Men\'s)')
      .setData({
    'name': 'Basketball (Men\'s)',
    'num': 10,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Basketball (Men\'s)')
      .setData({
    'name': 'Basketball (Men\'s)',
    'num': 10,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Basketball (Women\'s)')
      .setData({
    'name': 'Basketball (Women\'s)',
    'num': 5,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Belt-Chain')
      .setData({
    'name': 'Belt-Chain',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Belt-Weight (Small)')
      .setData({
    'name': 'Belt-Weight (Small)',
    'num': 2,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Belt-Weight (Medium)')
      .setData({
    'name': 'Belt-Weight (Medium)',
    'num': 2,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Belt-Weight (Large)')
      .setData({
    'name': 'Belt-Weight (Large)',
    'num': 2,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Belt-Weight (X-Large)')
      .setData({
    'name': 'Belt-Weight (X-Large)',
    'num': 2,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Belt-Weight (XX-Large)')
      .setData({
    'name': 'Belt-Weight (XX-Large)',
    'num': 2,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Dumbbells (1 lbs.)')
      .setData({
    'name': 'Dumbbells (1 lbs.)',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Dumbbells (2 lbs.)')
      .setData({
    'name': 'Dumbbells (2 lbs.)',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Dumbbells (3 lbs.)')
      .setData({
    'name': 'Dumbbells (3 lbs.)',
    'num': 3,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Foam Rollers')
      .setData({
    'name': 'Foam Rollers',
    'num': 20,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Goggles')
      .setData({
    'name': 'Goggles',
    'num': 50,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Indoor Soccer Ball')
      .setData({
    'name': 'Indoor Soccer Ball',
    'num': 5,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Jump Rope (7 foot)')
      .setData({
    'name': 'Jump Rope (7 foot)',
    'num': 2,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Jump Rope (8 foot)')
      .setData({
    'name': 'Jump Rope (8 foot)',
    'num': 2,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Jump Rope (9 foot)')
      .setData({
    'name': 'Jump Rope (9 foot)',
    'num': 2,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Racquetball Racquet')
      .setData({
    'name': 'Racquetball Racquet',
    'num': 30,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Racquetball Ball')
      .setData({
    'name': 'Racquetball Ball',
    'num': 20,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Rock Wall ATC')
      .setData({
    'name': 'Rock Wall ATC',
    'num': 20,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Rock Wall Carabiner')
      .setData({
    'name': 'Rock Wall Carabiner',
    'num': 20,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Rock Wall Harnesses')
      .setData({
    'name': 'Rock Wall Harnesses',
    'num': 20,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Rock Wall Shoes (Rock Wall Staff)')
      .setData({
    'name': 'Rock Wall Shoes (Rock Wall Staff)',
    'num': 50,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('squash Racquet')
      .setData({
    'name': 'squash Racquet',
    'num': 8,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('squash Ball-Single Dot')
      .setData({
    'name': 'squash Ball-Single Dot',
    'num': 5,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('squash Ball-Double Dot')
      .setData({
    'name': 'squash Ball-Double Dot',
    'num': 5,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Table Tennis Paddle')
      .setData({
    'name': 'Table Tennis Paddle',
    'num': 20,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Table Tennis Ball')
      .setData({
    'name': 'Table Tennis Ball',
    'num': 30,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Volleyball')
      .setData({
    'name': 'Volleyball',
    'num': 8,
  });
  await Firestore.instance
      .collection(collectionName)
      .document('Walleyball')
      .setData({
    'name': 'Walleyball',
    'num': 2,
  });
}
