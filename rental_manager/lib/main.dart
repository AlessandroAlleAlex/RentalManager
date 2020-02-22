import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  await databaseReference.collection("usersByFullName")
      .document(email)
      .setData({
    'name': fullName,
    'uid': uid,
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


  @override
  Widget build(BuildContext context) {
//    resetData('ArcItemsByName');
    var authHandler = new Auth();
    var screenWidth = MediaQuery.of(context).size.width;
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


    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
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
                          AwesomeDialog(
                              context: context,
                              dialogType: DialogType.ERROR,
                              animType: AnimType.RIGHSLIDE,
                              headerAnimationLoop: false,
                              tittle: 'Warning',
                              desc:
                              'Email Adress and Password Cannot be empty',
                              btnOkOnPress: () {},
                              btnOkColor: Colors.red)
                              .show();

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


                            globals.email = email;

                            final QuerySnapshot result =
                            await Firestore.instance.collection('usersByFullName').getDocuments();
                            final List<DocumentSnapshot> documents = result.documents;
                            List<String> userNameList = [];
                            documents.forEach((data) => userNameList.add(data.documentID));
                            String value = '';
                            bool found = false;
                            for(var i = 0; i < userNameList.length; i++){
                              String currentOne = userNameList[i];
                              Firestore.instance
                                  .collection('usersByFullName')
                                  .document('$currentOne')
                                  .get()
                                  .then((DocumentSnapshot ds) {
                                // use ds as a snapshot


                                if(currentOne == email){
                                  globals.username = ds["name"];
                                  globals.uid = ds["uid"];
                                  found = true;
                                }

                              });

                              if(found){
                                break;
                              }
                            }
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
                              "Sign In with Google",
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
                           globals.username = googleuser.displayName;
                           globals.email = googleuser.email;

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
                           Navigator.of(context).pushReplacementNamed('/MainViewScreen');
                          }
                        }catch(e){
                          print(e);
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
      appBar: AppBar(
        title: Text('Account Sign Up'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

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
                        email = email.trim();

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
                              "Back to Login Page",
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
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                      },
                      padding: EdgeInsets.all(7.0),
                      //color: Colors.teal.shade900,
                      disabledColor: Colors.black,
                      disabledTextColor: Colors.black,

                    ),
                  ),



                ],
              ),
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

