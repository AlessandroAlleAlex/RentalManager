import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_manager/mainView.dart';
import 'package:rental_manager/data.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:rental_manager/PlatformWidget/platform_exception_alert_dialog.dart';
import 'package:flutter/services.dart';
// import 'loginPage.dart';

// var user = new User();
void main() {
  // var user = new User(); // Creating Object

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/LoginScreen': (context) => MyApp(),
        '/MainViewScreen': (context) => MyHome1(),
      },
      initialRoute: 'LoginScreen',
    );
  }
}

// showAlertDialog(BuildContext context) {
//   // set up the buttons
//   Widget remindButton = RaisedButton(
//     child: Text("Remind me later"),
//     onPressed:  () {
//       Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
//     },
//   );

//   // set up the AlertDialog
//   AlertDialog alert = AlertDialog(
//     title: Text("Warning"),
//     content: Text("Your account or your password is not correct!"),
//     actions: [
//       remindButton,
//     ],
//   );

//   // show the dialog
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   );
// }

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  Auth authentication = Auth();
  String username;
  String password;
  User user;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
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
                height: 10,
                width: 150,
              ),
              TextField(
                onChanged: (text) {
                  widget.username = text;
                },
                cursorColor: Colors.teal.shade900,
                scrollPadding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
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
                  labelText: 'Enter your username',
                  prefixIcon: const Icon(Icons.person, color: Colors.black),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 30),
                ),
              ),
              SizedBox(height: 20, width: 150),
              TextField(
                onChanged: (text) {
                  widget.password = text;
                  print("First text field: $text");
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
                  labelText: 'Enter your Password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Row(
                      children: <Widget>[
                        Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontFamily: 'Source Sans Pro',
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      if (widget.username == null || widget.password == null) {
                        PlatformAlertDialog(
                          title: 'Warning',
                          content: 'Please enter all fields in order to log in',
                          defaultActionText: Strings.ok,
                        ).show(context);
                      } else {
                        validate();
                      }
                    },
                    padding: EdgeInsets.all(10.0),
                    color: Colors.teal.shade900,
                    disabledColor: Colors.black,
                    disabledTextColor: Colors.black,
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage()));
                    },
                    color: Colors.teal.shade900,
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "SIGN UP",
                      style: TextStyle(
                        fontSize: 15,
                        // backgroundColor:  Colors.teal[50],
                        color: Colors.white,
                        fontFamily: 'Source Sans Pro',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// String convertErrorString(PlatformException exception, int pos){
//   String mystr = exception.toString();
//   print("mystr: " + mystr);
//   List<String> msg = mystr.split(",");
//   if(msg.length >= 2){
//     print("Spliting value: " + msg[pos]);
//     return msg[pos];
//   }else{
//     return mystr;
//   }
// }
  String convertErrorString(PlatformException exception, int pos) {
    String mystr = exception.toString();
    print("mystr: " + mystr);
    List<String> msg = mystr.split(",");
    if (msg.length >= 2) {
      print("Spliting value: " + msg[pos]);
      return msg[pos];
    } else {
      return mystr;
    }
  }

  Future<void> validate() async {
    String userId = "";
    userId =
        await widget.authentication.signIn(widget.username, widget.password);
    print(userId);
    if (Error_Detect(userId)) {
      PlatformAlertDialog(
        title: errorDetect(userId, pos: 0),
        // title: "Strings.signInFailed",
        content: errorDetect(userId, pos: 1),
        // content: convertErrorString(e, 1),
        defaultActionText: Strings.ok,
      ).show(context);
    } else {
      Navigator.of(context).pushReplacementNamed('/MainViewScreen');
      print("Sucessfully logged in! ");
    }
    // try {
    //     userId = await widget.authentication.signIn(widget.username, widget.password);
    //   if (userId.length > 0) {
    //     // widget.user.updateUserlocal(userId);
    //     Navigator.of(context).pushReplacementNamed('/MainViewScreen');
    //     print("Sucessfully logged in! ");
    //   }
    // } catch (e) {
    //   print("Error logging in");
    //   //Working on Custom Allert.
    //   if(Error_Detect(e)) {
    //   PlatformAlertDialog(
    //       title: Strings.signInFailed,
    //       // title: "Strings.signInFailed",
    //        content: errorDetect(e,pos:1),
    //       // content: convertErrorString(e, 1),
    //       defaultActionText: Strings.ok,
    //       ).show(context);
    //     print("After parsing!!!");
    //     // print(e);
    //   }
    // }
  }

  bool Error_Detect(String e) {
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
          strList.clear();
          strList = _retstr.split('_');
          _retstr = strList[1] + ' ' + strList[2];
        } catch (e) {
          print(e);
        }
      }
      return _retstr;
    } else {
      return e;
    }
  }
}

class SignUpPage extends StatelessWidget {
  String email, username, password, confirmpw;
  Auth authentication = Auth();
  @override
  Widget build(BuildContext context) {
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
              onChanged: (text) {
                email = text;
                print("First text field: $text");
              },
              cursorColor: Colors.teal.shade900,
              scrollPadding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
              ),
            ),
            SizedBox(
              height: 20,
              width: 100,
            ),
            TextField(
              onChanged: (text) {
                username = text;
              },
              cursorColor: Colors.teal.shade900,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person, color: Colors.black),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  borderSide: new BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: (text) {
                password = text;
                print("First password field: $text");
              },
              obscureText: true,
              cursorColor: Colors.teal.shade900,
              scrollPadding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: (text) {
                confirmpw = text;
                print("Second password field: $text");
              },
              obscureText: true,
              cursorColor: Colors.teal.shade900,
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
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock, color: Colors.black),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
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
              onPressed: () {
                Navigator.pop(context);
                validate();
              },
              padding: EdgeInsets.all(10.0),
              disabledColor: Colors.black,
              disabledTextColor: Colors.black,
            )
          ],
        ),
      ),
    );
  }

  Future<void> validate() async {
    String userId = "";
    try {
      userId = await authentication.signUp(email, password);
      if (userId.length > 0) {
        print("Successfully Signed Up!");
        Firestore.instance
            .collection('users')
            .document()
            .setData({'Email': email, 'Username': username});
      }
    } catch (e) {
      print(e);
    }
  }
}
