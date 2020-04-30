import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'qrcodelogin.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'dart:ui' as ui;
import 'package:devicelocale/devicelocale.dart';
void getData() async{
  Firestore.instance
      .collection('usersByFullName')
      .document(globals.uid)
      .get()
      .then((DocumentSnapshot ds) {
    // use ds as a snapshot
    var doc = ds.data;
    globals.studentID = doc["StudentID"];
    globals.username = doc["name"];
    globals.UserImageUrl = doc["imageURL"];
    if(globals.UserImageUrl == null){
      globals.UserImageUrl = "https://images.unsplash.com/photo-1581660545544-83b8812f9516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80";
    }
    globals.phoneNumber = doc["PhoneNumber"];
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
        '/SecondTab':(context) => SecondTab(),
        '/CR View': (context) => CureentReservation(),
      },
      initialRoute: 'LoginScreen',
    );
  }
  @override
  Widget know (BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance.collection('CollectionA').document('DOc1').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('1');
            return new Text("Loading");
          }
          var userDocument = snapshot.data;
          print('2');
          return new Text(userDocument["a"]);
        }
    );
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

void uploadData(usernameFirst, usernameLast,email,uid) async{

  String fullName = usernameFirst + ' ' + usernameLast;
  final databaseReference = Firestore.instance;
  String doc = "AppSignInUser" + email;
  await databaseReference.collection("usersByFullName")
      .document(doc)
      .setData({
    'name': fullName,
    'imageURL': "https://images.unsplash.com/photo-1581660545544-83b8812f9516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80",
    'PhoneNumber': '',
    'Sex': '',
    'StudentID': '',
    'email': email,
  });
}

void updateData(String collectionName) async{
  final QuerySnapshot result =
  await Firestore.instance.collection(collectionName).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  List<String> userNameList = [];
  documents.forEach((data) => userNameList.add(data.documentID));

  for(var i = 0; i < userNameList.length; i++){

    await Firestore.instance.collection(collectionName)
        .document(userNameList[i])
        .updateData({
      'Rentable': true,
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
    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

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
  void testfunc() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("user");
    if(list != null && list.length > 0){
      globals.uid = list[0];
      globals.studentID = list[1];
      globals.username = list[2];
      globals.UserImageUrl = list[3];
      globals.phoneNumber = list[4];
      globals.email = list[5];
      globals.sex = list[6];
      Navigator.of(context).pushReplacementNamed('/MainViewScreen');
    }
   try{
     var isDark = prefs.getBool('isDark'), userSelectTheme = prefs.getInt('userSelectTheme');
     if(isDark == null || userSelectTheme == null){
       final Brightness brightnessValue = MediaQuery.of(context).platformBrightness;
       bool Dark = brightnessValue == Brightness.dark;
       globals.dark = Dark;
       globals.userSelectTheme = -1;
     }
     globals.dark = isDark;
     globals.userSelectTheme = -1;

     print('isDark:' + isDark.toString());
     print('userSelectTheme: ' + userSelectTheme.toString());
   }catch(e){
      print(e);
   }

    for(int i = 0; i < list.length; i++){
      print(list[i]);
    }

    var language =  prefs.getString('mylanguage');
    print(language);
    if(language != null){
      if(language == 'English' || language == 'SimplifiedChinese') {
        globals.langaugeSet = language;
      }else{
        globals.langaugeSet = "English";
      }
    }else{
      globals.langaugeSet = "English";
    }



  }

  @override
  Widget build(BuildContext context) {
//    resetData('ArcItemsByName');

    var authHandler = new Auth();
    var screenWidth = MediaQuery.of(context).size.width;
    bool userExist = false;
    ProgressDialog prLOGIN;
    prLOGIN = new ProgressDialog(context,type: ProgressDialogType.Normal);
    prLOGIN.style(message: 'Showing some progress...');
    prLOGIN.update(
      message: 'Successfully Login...',
      progressWidget: CircularProgressIndicator(),
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
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
                    SizedBox(
                        height: 10, width: 150
                    ),

                    TextField(
                      onChanged:(text){
                        username = text;
                        print("First text field: $text");
                      },
                      // controller: _username,
                      cursorColor: Colors.teal.shade900,
                      scrollPadding:  const EdgeInsets.symmetric(vertical: 10.0,horizontal: 30),
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
                        labelText: 'Enter your Email Address',
                        prefixIcon: const Icon(Icons.person, color: Colors.black),
                        // labelStyle:
                        // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 30),

                      ),

                    ),
                    SizedBox(
                        height: 20,width: 150
                    ),
                    TextField(

                      onChanged:(text){
                        password = text;

                        //print("First text field: $text");
                      },

                      obscureText: true,
                      cursorColor: Colors.teal.shade900,
                      decoration: InputDecoration(
                        contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 100.0, 10.0),
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(8.0),
                          ),
                          borderSide: new BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                        labelText: 'Enter your Password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.black),
                        // labelStyle:
                        // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                        // contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
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
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    "LOGIN",
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

                              if(username == null || password == null){
//                          AwesomeDialog(
//                              context: context,
//                              dialogType: DialogType.ERROR,
//                              animType: AnimType.RIGHSLIDE,
//                              headerAnimationLoop: false,
//                              tittle: 'Warning',
//                              desc:
//                              'Email Adress and Password Cannot be empty',
//                              btnOkOnPress: () {
//                                Navigator.of(context).pop();
//                              },
//                              btnOkColor: Colors.red)
//                              .show();
                                showDialog(
                                    context: context,
                                    builder: (_) => NetworkGiffyDialog(
                                      key: keys[1],
                                      image: Image.network(
                                        "https://i.pinimg.com/originals/2c/dd/d1/2cddd1796354e90f4aab7fb1e48eafb4.gif",
                                        fit: BoxFit.cover,
                                      ),
                                      entryAnimation: EntryAnimation.TOP_RIGHT,
                                      title: Text(
                                        'Warning',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 22.0, fontWeight: FontWeight.w600),
                                      ),
                                      description: Text(
                                        'Email Adress and Password Cannot be empty',
                                        textAlign: TextAlign.center,

                                      ),
                                      onlyCancelButton: true,
                                      buttonCancelColor: Colors.teal,
                                      buttonCancelText: Text('Try Again!'),
                                    ));



                              }else{
                                var e = await authHandler.signIn(username, password);
                                if(e == "false"){
                                  AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.ERROR,
                                      animType: AnimType.RIGHSLIDE,
                                      headerAnimationLoop: false,
                                      tittle: 'ERROR Email NEED VERFIED',
                                      desc:
                                      'Verify Your Email Please',
                                      btnOkOnPress: () {},
                                      btnOkColor: Colors.red)
                                      .show();
                                }else if(ErrorDetect(e)){
                                  AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.ERROR,
                                      animType: AnimType.RIGHSLIDE,
                                      headerAnimationLoop: false,
                                      tittle: errorDetect(e, pos: 0),
                                      desc:errorDetect(e, pos: 1),
                                      btnOkOnPress: () {},
                                      btnOkColor: Colors.red)
                                      .show();

                                }else{
                                  prLOGIN.update(
                                    message: 'Successfully Login...',
                                    progressWidget: CircularProgressIndicator(),
                                    progressTextStyle: TextStyle(
                                        color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
                                    messageTextStyle: TextStyle(
                                        color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
                                  );
                                  await prLOGIN.show();
                                  username = username.trim();
                                  var email = username;
                                  globals.uid = 'AppSignInUser' + email;


                                  Firestore.instance
                                      .collection('usersByFullName')
                                      .document(globals.uid)
                                      .get()
                                      .then((DocumentSnapshot ds) {
                                    // use ds as a snapshot
                                    var doc = ds.data;
                                    globals.studentID = doc["StudentID"];
                                    globals.username = doc["name"];
                                    globals.UserImageUrl = doc["imageURL"];
                                    globals.phoneNumber = doc["PhoneNumber"];
                                    globals.email = doc["email"];
                                  });
                                  List<String>userinfor = [];
                                  userinfor.add(globals.uid);
                                  userinfor.add(globals.studentID);
                                  userinfor.add(globals.username );
                                  userinfor.add(globals.UserImageUrl);
                                  userinfor.add(globals.phoneNumber);
                                  userinfor.add(globals.email );
                                  userinfor.add(globals.sex );
                                  var prefs = await SharedPreferences.getInstance();
                                  await prefs.setStringList("user", userinfor);
                                  await prefs.setBool('isDark', false);
                                  await prefs.setInt('userSelectTheme', -1);



                                  prLOGIN.hide();
                                  Navigator.of(context).pushReplacementNamed('/MainViewScreen');
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
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image(image: NetworkImage('https://pluspng.com/img-png/google-logo-png-open-2000.png'), height: 30,),
                                SizedBox(width: 20.0),
                                Center(
                                  child: Text(
                                    "Sign In With Google",
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
                              //_handleSignIn();

                              try{
                                FirebaseUser googleuser = await _myGoogleSignIn();

                                if(googleuser != null){
                                  globals.mygoogleuser = googleuser;

                                  globals.username = googleuser.displayName;
                                  globals.email = googleuser.email;
                                  globals.uid = 'GoogleSignInUser' + globals.email;
                                  prLOGIN.update(
                                    message: 'Successfully Login...',
                                    progressWidget: CircularProgressIndicator(),
                                    progressTextStyle: TextStyle(
                                        color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
                                    messageTextStyle: TextStyle(
                                        color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
                                  );
                                  await prLOGIN.show();
                                  prLOGIN.hide();
                                  String fullName = globals.username;
                                  final databaseReference = Firestore.instance;

                                  final QuerySnapshot result =
                                  await Firestore.instance.collection('usersByFullName').getDocuments();
                                  final List<DocumentSnapshot> documents = result.documents;

                                  for(var i = 0; i < documents.length; i++){
                                    if(documents[i].documentID == globals.uid ){
                                      userExist = true;
                                      break;
                                    }
                                  }
                                  print(userExist == true);
                                  if(userExist){
                                    print("UserExists\n");
                                    try{
                                      await Firestore.instance
                                          .collection('usersByFullName')
                                          .document(globals.uid)
                                          .get()
                                          .then((DocumentSnapshot ds) {
                                        // use ds as a snapshot
                                        var doc = ds.data;
                                        globals.UserImageUrl = doc["imageURL"];
                                        globals.studentID = doc["StudentID"];
                                        globals.phoneNumber = doc["PhoneNumber"];
                                        globals.sex = doc["Sex"];
                                        if(globals.UserImageUrl == null){
                                          globals.UserImageUrl = "https://images.unsplash.com/photo-1581660545544-83b8812f9516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80";
                                        }
                                        if( globals.studentID == null){
                                          globals.studentID = "";
                                        }
                                        if(globals.phoneNumber == null){
                                          globals.phoneNumber = "";
                                        }
                                        if(globals.sex == null){
                                          globals.sex = "";
                                        }
                                      });


                                    }catch(e){
                                      print(e);
                                    }
                                  }else{

                                    await databaseReference.collection("usersByFullName")
                                        .document(globals.uid)
                                        .setData({
                                      'name': fullName,
                                      'email': globals.email,
                                      'imageURL':  globals.UserImageUrl,
                                    });
                                    globals.UserImageUrl = "https://images.unsplash.com/photo-1581660545544-83b8812f9516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80";
                                  }

                                  List<String>userinfor = [];
                                  userinfor.add(globals.uid);
                                  userinfor.add(globals.studentID);
                                  userinfor.add(globals.username );
                                  userinfor.add(globals.UserImageUrl);
                                  userinfor.add(globals.phoneNumber);
                                  userinfor.add(globals.email );
                                  userinfor.add(globals.sex );
                                  var prefs = await SharedPreferences.getInstance();
                                  await prefs.setStringList("user", userinfor);
                                  await prefs.setBool('isDark', false);
                                  await prefs.setInt('userSelectTheme', -1);

                                  Navigator.of(context).pushReplacementNamed('/MainViewScreen');
                                  getData();
                                }
                              }catch(e){
                                print("Erro Line 515 Main.dart:" + e.toString());
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
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[

                                SizedBox(width: 20.0),
                                Center(
                                  child: Text(
                                    "Sign In With Scan",
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
                              //_handleSignIn();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GenerateScreen()));


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
                        Text(
                          'New to Rental Manager?',
                          style: TextStyle(fontFamily: 'Montserrat'),
                        ),
                        SizedBox(width: 5.0),
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                          },
                          child: Text(
                            'Register',
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => resetPassword()));
                          },
                          child: Text(
                            'Forgot Password',
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
                      children: <Widget>[
                      ],
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
class SignUpPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<SignUpPage> {
  @override
  String email, usernameFirst, usernameLast, password, confirmpw;
  var authHandler = new Auth();


  Widget build(BuildContext context) {
    ProgressDialog prSIGNUP;
    prSIGNUP = new ProgressDialog(context,type: ProgressDialogType.Normal);
    prSIGNUP.style(message: 'Successfully Sign Up...');
    prSIGNUP.update(
      message: 'Successfully Sign Up...',
      progressWidget: CircularProgressIndicator(),
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Sign Up Page'),
        backgroundColor: Colors.teal,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        onTap: () {
          // call this method here to hide soft keyboard
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: ListView(
          children:[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50
                    ,
                  ),
                  TextField(
                    onChanged:(text){
                      email = text;
                      //print("First text field: $text");
                    },
                    cursorColor: Colors.teal.shade900,
                    scrollPadding:  const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
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
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email, color: Colors.black),
                      // labelStyle:
                      // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    onChanged:(text){
                      usernameFirst = text;
                      //print("username: $text");
                    },
                    // obscureText: true,
                    cursorColor: Colors.teal.shade900,
                    decoration: InputDecoration(
                      // contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 100.0, 10.0),
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(8.0),
                        ),
                        borderSide: new BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                      labelText: 'First Name',
                      prefixIcon: const Icon(Icons.person, color: Colors.black),
                      // labelStyle:
                      // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    onChanged:(text){
                      usernameLast = text;
                      //print("username: $text");
                    },
                    // obscureText: true,
                    cursorColor: Colors.teal.shade900,
                    decoration: InputDecoration(
                      // contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 100.0, 10.0),
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(8.0),
                        ),
                        borderSide: new BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                      labelText: 'Lastname',
                      prefixIcon: const Icon(Icons.person, color: Colors.black),
                      // labelStyle:
                      // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    onChanged:(text){
                      password = text;
                      //print("First password field: $text");
                    },
                    obscureText: true,
                    cursorColor: Colors.teal.shade900,
                    scrollPadding:  const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
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
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock, color: Colors.black),
                      // labelStyle:
                      // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    onChanged:(text){
                      confirmpw = text;
                      //print("Second password field: $text");
                    },

                    obscureText: true,
                    cursorColor: Colors.teal.shade900,
                    decoration: InputDecoration(
                      // contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 100.0, 10.0),
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(8.0),
                        ),
                        borderSide: new BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock, color: Colors.black),
                      // labelStyle:
                      // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Click sign up after entering all of above'),
                  RaisedButton(
                    textColor: Colors.white,
                    color: Colors.teal.shade900,
                    child: Text('SIGN UP'),

                    onPressed: () async{
//                final QuerySnapshot result =
//                await Firestore.instance.collection('users').getDocuments();
//                final List<DocumentSnapshot> documents = result.documents;
//                List<String> userNameList = [];
//                documents.forEach((data) => userNameList.add(data.documentID));

                      bool localCheck = true;
                      if(email == null || password == null ||  usernameFirst == null || usernameLast == null|| confirmpw == null){
                        localCheck = false;

                        AwesomeDialog(
                            context: context,
                            dialogType: DialogType.ERROR,
                            animType: AnimType.RIGHSLIDE,
                            headerAnimationLoop: false,
                            tittle: 'Warning',
                            desc:
                            'Each Field should be filled in',
                            btnOkOnPress: () {},
                            btnOkColor: Colors.red)
                            .show();
                      }else if(password != confirmpw){
                        localCheck = false;
                        AwesomeDialog(
                            context: context,
                            dialogType: DialogType.ERROR,
                            animType: AnimType.RIGHSLIDE,
                            headerAnimationLoop: false,
                            tittle: 'Warning',
                            desc:
                            'Your Password should be matched',
                            btnOkOnPress: () {},
                            btnOkColor: Colors.red)
                            .show();
                      }
//                else if(FindSameName(userNameList, username)){
//                  localCheck = false;
//                  PlatformAlertDialog(
//                    title: 'Warning',
//                    content: 'Same User Name Found In Our Records',
//                    defaultActionText: Strings.ok,
//                  ).show(context);
//                }


                      if(localCheck){
                        var e = await authHandler.signUp(email, password);


                        if(ErrorDetect(e)) {
                          AwesomeDialog(
                              context: context,
                              dialogType: DialogType.ERROR,
                              animType: AnimType.RIGHSLIDE,
                              headerAnimationLoop: false,
                              tittle: errorDetect(e, pos: 0),
                              desc:
                              errorDetect(e, pos: 1),
                              btnOkOnPress: () {},
                              btnOkColor: Colors.red)
                              .show();
                        }else {
                          prSIGNUP.update(
                            message: 'Successfully Sign Up...',
                            progressWidget: CircularProgressIndicator(),
                            progressTextStyle: TextStyle(
                                color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
                            messageTextStyle: TextStyle(
                                color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
                          );
                          await prSIGNUP.show();
                          uploadData(usernameFirst, usernameLast, email,  errorDetect(e));
                          print(errorDetect(e));
                          Future.delayed(Duration(seconds: 2)).then((onValue){
                          });
                          prSIGNUP.hide();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                        }
                      }
                    },
                    padding: EdgeInsets.all(10.0),
                    disabledColor: Colors.black,
                    disabledTextColor: Colors.black,

                  ),

                ],
              ),
            ),
          ],
        ),
      ),
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
          title: Text('Reset PassWord'),
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
              SizedBox(
                  height: 10, width: 150
              ),

              TextField(
                onChanged:(text){
                  email = text;
                },
                // controller: _username,
                cursorColor: Colors.teal.shade900,
                scrollPadding:  const EdgeInsets.symmetric(vertical: 10.0,horizontal: 30),
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
                  labelText: 'Enter your Email Address',
                  prefixIcon: const Icon(Icons.email, color: Colors.black),
                  // labelStyle:
                  // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 30),

                ),

              ),
              SizedBox(
                  height: 20,width: 150
              ),

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
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Text(
                              "Send Verification Email",
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

                        bool isEmpty = false;
                        if(email == null){
                          isEmpty = true;
                          AwesomeDialog(
                              context: context,
                              dialogType: DialogType.ERROR,
                              animType: AnimType.RIGHSLIDE,
                              headerAnimationLoop: false,
                              tittle: 'Warning',
                              desc:
                              'Email Adress Cannot be empty',
                              btnOkOnPress: () {},
                              btnOkColor: Colors.red)
                              .show();
                        }

                        for(int i = 0; i < 100000; i++) {
                          email = email.trim();
                        }

                        final QuerySnapshot result =
                        await Firestore.instance.collection('usersByFullName').getDocuments();
                        final List<DocumentSnapshot> documents = result.documents;
                        List<String> userNameList = [];
                        documents.forEach((data) => userNameList.add(data.documentID));
                        bool found = false;
                        for(var i = 0; i < userNameList.length; i++){
                          if(email == userNameList[i]){
                            found = true;
                            break;
                          }
                        }

                        if(found){
                          ProgressDialog prForgetPassword;
                          prForgetPassword= new ProgressDialog(context,type: ProgressDialogType.Normal);
                          prForgetPassword.update(
                            message: 'Sending Email...',
                            progressWidget: CircularProgressIndicator(),
                            progressTextStyle: TextStyle(
                                color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
                            messageTextStyle: TextStyle(
                                color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
                          );
                          await prForgetPassword.show();
                          Future.delayed(Duration(seconds: 2)).then((onValue){
                            prForgetPassword.update(

                              message: "Email Sent",
                              progressWidget: Container(
                                  padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),

                              progressTextStyle: TextStyle(
                                  color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
                              messageTextStyle: TextStyle(
                                  color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
                            );
                            Future.delayed(Duration(seconds: 2)).then((value){
                              authHandler.resetPassword(email);
                              prForgetPassword.hide();
                            });


                          });


                          print('Founding');



                        }else{
                          AwesomeDialog(
                              context: context,
                              dialogType: DialogType.ERROR,
                              animType: AnimType.RIGHSLIDE,
                              headerAnimationLoop: false,
                              tittle: 'Warning',
                              desc:
                              'Email Adress Not Found in Records',
                              btnOkOnPress: () {},
                              btnOkColor: Colors.red)
                              .show();
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



bool ErrorDetect(String e){
  if(e.contains('PlatformException')){
    return true;
  }else{
    return false;
  }
}

String errorDetect(String e, {int pos = 1}){
  if(e.contains('PlatformException')){
    List<String> strList = e.split(",");
    String _retstr = strList[pos];


    if(pos == 0){
      strList.clear();
      strList = _retstr.split("(");
      _retstr = strList[1];
      try{
        _retstr = _retstr.replaceAll("_", " ");
      }catch (e){
        print(e);
      }
    }


    return _retstr;
  }else{
    return e;
  }
}

void resetData(String collectionName) async{
  await Firestore.instance.collection(collectionName).document('Badminton Racquet').setData({'name': 'Badminton Racquet', 'num': 30,});
  await Firestore.instance.collection(collectionName).document('Badminton Birdie').setData({'name': 'Badminton Birdie/Shuttle Cock-White', 'num': 30,});
  await Firestore.instance.collection(collectionName).document('Band-Resistance (Orange) "').setData({'name': 'Band-Resistance (Orange) 1/2"', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Band-Resistance (Green)  "').setData({'name': 'Band-Resistance (Green) 3/4"', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Band-Resistance (Red)"').setData({'name': 'Band-Resistance (Red) 1"', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Band-Resistance (Blue)"').setData({'name': 'Band-Resistance (Blue) 1-3/4"', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Band-Resistance (Purple)"').setData({'name': 'Band-Resistance (Purple) 2-1/2"', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Band-Tube: Very Light (Yellow)').setData({'name': 'Band-Tube: Very Light (Yellow)', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Band-Tube: Light (Green)').setData({'name': 'Band-Tube: Light (Green)', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Band-Tube: Medium (Red)').setData({'name': 'Band-Tube: Medium (Red)', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Band-Tube: Heavy (Blue)').setData({'name': 'Band-Tube: Heavy (Blue)', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Band-Tube: Ultra Heavy (Purple)').setData({'name': 'Band-Tube: Ultra Heavy (Purple)', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Barbell Pad-Blue').setData({'name': 'Barbell Pad-Blue', 'num': 10,});
  await Firestore.instance.collection(collectionName).document('Basketball (Men\'s)').setData({'name': 'Basketball (Men\'s)', 'num': 10,});
  await Firestore.instance.collection(collectionName).document('Basketball (Men\'s)').setData({'name': 'Basketball (Men\'s)', 'num': 10,});
  await Firestore.instance.collection(collectionName).document('Basketball (Women\'s)').setData({'name': 'Basketball (Women\'s)', 'num': 5,});
  await Firestore.instance.collection(collectionName).document('Belt-Chain').setData({'name': 'Belt-Chain', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Belt-Weight (Small)').setData({'name': 'Belt-Weight (Small)', 'num': 2,});
  await Firestore.instance.collection(collectionName).document('Belt-Weight (Medium)').setData({'name': 'Belt-Weight (Medium)', 'num': 2,});
  await Firestore.instance.collection(collectionName).document('Belt-Weight (Large)').setData({'name': 'Belt-Weight (Large)', 'num': 2,});
  await Firestore.instance.collection(collectionName).document('Belt-Weight (X-Large)').setData({'name': 'Belt-Weight (X-Large)', 'num': 2,});
  await Firestore.instance.collection(collectionName).document('Belt-Weight (XX-Large)').setData({'name': 'Belt-Weight (XX-Large)', 'num': 2,});
  await Firestore.instance.collection(collectionName).document('Dumbbells (1 lbs.)').setData({'name': 'Dumbbells (1 lbs.)', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Dumbbells (2 lbs.)').setData({'name': 'Dumbbells (2 lbs.)', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Dumbbells (3 lbs.)').setData({'name': 'Dumbbells (3 lbs.)', 'num': 3,});
  await Firestore.instance.collection(collectionName).document('Foam Rollers').setData({'name': 'Foam Rollers', 'num': 20,});
  await Firestore.instance.collection(collectionName).document('Goggles').setData({'name': 'Goggles', 'num': 50,});
  await Firestore.instance.collection(collectionName).document('Indoor Soccer Ball').setData({'name': 'Indoor Soccer Ball', 'num': 5,});
  await Firestore.instance.collection(collectionName).document('Jump Rope (7 foot)').setData({'name': 'Jump Rope (7 foot)', 'num': 2,});
  await Firestore.instance.collection(collectionName).document('Jump Rope (8 foot)').setData({'name': 'Jump Rope (8 foot)', 'num': 2,});
  await Firestore.instance.collection(collectionName).document('Jump Rope (9 foot)').setData({'name': 'Jump Rope (9 foot)', 'num': 2,});
  await Firestore.instance.collection(collectionName).document('Racquetball Racquet').setData({'name': 'Racquetball Racquet', 'num': 30,});
  await Firestore.instance.collection(collectionName).document('Racquetball Ball').setData({'name': 'Racquetball Ball', 'num': 20,});
  await Firestore.instance.collection(collectionName).document('Rock Wall ATC').setData({'name': 'Rock Wall ATC', 'num': 20,});
  await Firestore.instance.collection(collectionName).document('Rock Wall Carabiner').setData({'name': 'Rock Wall Carabiner', 'num': 20,});
  await Firestore.instance.collection(collectionName).document('Rock Wall Harnesses').setData({'name': 'Rock Wall Harnesses', 'num': 20,});
  await Firestore.instance.collection(collectionName).document('Rock Wall Shoes (Rock Wall Staff)').setData({'name': 'Rock Wall Shoes (Rock Wall Staff)', 'num': 50,});
  await Firestore.instance.collection(collectionName).document('squash Racquet').setData({'name': 'squash Racquet', 'num': 8,});
  await Firestore.instance.collection(collectionName).document('squash Ball-Single Dot').setData({'name': 'squash Ball-Single Dot', 'num': 5,});
  await Firestore.instance.collection(collectionName).document('squash Ball-Double Dot').setData({'name': 'squash Ball-Double Dot', 'num': 5,});
  await Firestore.instance.collection(collectionName).document('Table Tennis Paddle').setData({'name': 'Table Tennis Paddle', 'num': 20,});
  await Firestore.instance.collection(collectionName).document('Table Tennis Ball').setData({'name': 'Table Tennis Ball', 'num': 30,});
  await Firestore.instance.collection(collectionName).document('Volleyball').setData({'name': 'Volleyball', 'num': 8,});
  await Firestore.instance.collection(collectionName).document('Walleyball').setData({'name': 'Walleyball', 'num': 2,});
}

