import 'dart:async';
import 'package:rental_manager/search.dart';
import 'package:rental_manager/uploadCSV.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/chatview/const.dart';
import 'package:rental_manager/tabs/help.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart' as slideDialog;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart'; //For creating the SMTP Server
import '../globals.dart';

String contents;

class ThirdTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      theme: ThemeData(
        primaryColor: Colors.teal,
      ),
      home: LoginScreen(title: 'Chat'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    prefs = await SharedPreferences.getInstance();

    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => MainScreen(currentUserId: prefs.getString('id'))),
//      );


    }
    print(isLoggedIn);
    this.setState(() {
      isLoading = false;
    });
  }

  Future<Null> handleSignIn() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });


    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = new GoogleSignIn();
    FirebaseUser firebaseUser;

    if(globals.mygoogleuser != null){
      firebaseUser = globals.mygoogleuser;
      Fluttertoast.showToast(msg: "Alredy Sign in with google account");
    }else {
      print(globals.mygoogleuser == null);
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      try {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        firebaseUser = (await _auth.signInWithCredential(credential)).user;
      } catch (e) {
        print(e);
      }
    }

    //final FirebaseUser firebaseUser = (await _auth.signInWithCredential(credential)).user;

//    GoogleSignInAccount googleUser = await googleSignIn.signIn();
//    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//    final AuthCredential credential = GoogleAuthProvider.getCredential(
//      accessToken: googleAuth.accessToken,
//      idToken: googleAuth.idToken,
//    );
//
//
//    FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result =
      await Firestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance.collection('users').document(firebaseUser.uid).setData({
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null
        });

        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
      }
      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });
      print("firebaseUser.uid:" + firebaseUser.uid);
      Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(currentUserId: firebaseUser.uid)));
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
    var buttonWidth = MediaQuery.of(context).size.width / 10 * 7;
    void _onSubmit(String email, String subject, String text) async{
      final form = _formKey.currentState;
      if (form.validate()) {
        form.save();
        String username = 'jagaoabc@gmail.com';
        String password = 'Aa123456!';
        text = 'UserEmail: $email\nText:\n$text';
        final smtpServer = gmail(username, password);
        // Creating the Gmail server


        // Create our email message.
        final message = Message()
          ..from = Address(username)
          ..recipients.add('jagaoabc@gmail.com') //recipent email
          ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com']) //cc Recipents emails
          ..bccRecipients.add(Address('bccAddress@example.com')) //bcc Recipents emails
          ..subject = subject //subject of the email
          ..text = text; //body of the email

        try {
          final sendReport = await send(message, smtpServer);
          print('Message sent: ' + sendReport.toString()); //print if the email is sent
        } on MailerException catch (e) {
          print('Message not sent. \n'+ e.toString()); //print if the email is not sent
          // e.toString() will show why the email is not sending
        }
        pop_window('Confirmed!', 'This informaton will be sent to our assistants', context);
      }
    }
    void _showDialog(String s) {
      String email, subject, atext;
      slideDialog.showSlideDialog(
        context: context,
        child:  Container(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[

                Text(
                  s,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 20,
                  width: MediaQuery.of(context).size.width / 10 * 6.87,
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                TextFormField(
                  onChanged:(text){
                    print("First text field: $text");
                    email = text;
                  },
                  validator: (String val){
                    if(VerifyEmail(val) == false){
                      var s = "Please enter your valid email address";
                      return s;
                    }
                    return null;
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
                  height: 10,
                ),
                TextFormField(
                  onChanged:(text){
                    print("First text field: $text");
                    subject = text;
                  },
                  validator: (String val){
                    if(val.isEmpty){
                      var s = "Please fill in the blank";
                      return s;
                    }
                    return null;
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
                    labelText: 'Subject',
                    prefixIcon: const Icon(Icons.title, color: Colors.black),
                    // labelStyle:
                    // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onChanged:(text){
                    print("First text field: $text");
                    atext = text;
                  },
                  validator: (String val){
                    if(val.isEmpty){
                      var s = "Please fill in the blank";
                      return s;
                    }
                    return null;
                  },
                  keyboardAppearance: Brightness.dark,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  cursorColor: Colors.teal.shade900,
                  scrollPadding:  const EdgeInsets.symmetric(vertical: 50.0,horizontal: 50),
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
                    labelText: 'Text',
                    prefixIcon: const Icon(Icons.content_paste, color: Colors.black),
                    // labelStyle:
                    // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                    contentPadding: const EdgeInsets.symmetric(vertical: 50.0,horizontal: 50),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: 200,
                  child: RaisedButton(
                    highlightElevation: 0.0,
                    splashColor: Colors.greenAccent,
                    highlightColor: Colors.green,
                    elevation: 0.0,
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "Submit",
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


                      _onSubmit(email, subject, atext);
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

    SpeedDial buildSpeedDial() {
      double height = MediaQuery.of(context).size.height;
      return SpeedDial(
        marginRight: 10,
        marginBottom: height/2,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // child: Icon(Icons.add),
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        visible: true,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: Icon(Icons.lock, color: Colors.white),
            backgroundColor: Colors.deepOrange,
            onTap: () => _showDialog("Describe the item and leave your contact"),
            label: 'Lost And Found',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.deepOrangeAccent,
          ),
          SpeedDialChild(
            child: Icon(Icons.lightbulb_outline, color: Colors.white),
            backgroundColor: Colors.blue,
            onTap: () => _showDialog("Write down your ideas"),
            labelWidget: Container(
              color: Colors.blue,
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.all(6),
              child: Text('Bring us your ideas '),
            ),
          ),
          SpeedDialChild(
            child: Icon(Icons.search, color: Colors.white),
            backgroundColor: Colors.teal,
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => track()));
            },
            label: 'Track',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.teal,
          ),
          SpeedDialChild(
            child: Icon(Icons.receipt, color: Colors.white),
            backgroundColor: Colors.green,
            onTap: (){
               pickUpFile(context);
               print(contents);
            },
            label: 'Upload file',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.green,
          ),

        ],
      );
    }
    //globals.AppBarheight = AppBar().preferredSize.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        floatingActionButton:buildSpeedDial(),
        body: Stack(
          children: <Widget>[
            Center(
              child: Container(
                width:  buttonWidth,

                child: FlatButton(
                    onPressed: handleSignIn,
                    child: Row(
                      children: <Widget>[
                        Image(image: NetworkImage('https://pluspng.com/img-png/google-logo-png-open-2000.png'), height: 30,),
                        SizedBox(width: 20.0),
                        Text(
                          'GOOGLE Sign In',
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),

                    ),
                    color: Colors.teal,
                    highlightColor: Color(0xffff7f7f),
                    splashColor: Colors.transparent,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
              ),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                ),
                color: Colors.white.withOpacity(0.8),
              )
                  : Container(),
            ),
          ],
        ));
  }
}

void pop_window(a, b, context){
  PlatformAlertDialog(
    title: a,
    content: b,
    defaultActionText: Strings.ok,
  ).show(context);
}




bool VerifyEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  return (!regex.hasMatch(value)) ? false : true;
}

void pickUpFile(BuildContext context)async{
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
  }catch(e){
    print(e);
  }
  print(mypath);
  var thefile = File(mypath);
  contents = await thefile.readAsString();
  for(int i = 0; i < contents.length; i++){
    if(contents[i] == "\n"){
      print("newline");

    }
  }

  PlatformAlertDialog(
    title: 'Confirmed',
    content: 'You dataBelow:\n$contents',
    defaultActionText: Strings.ok,
  ).show(context);

  print(contents);
}