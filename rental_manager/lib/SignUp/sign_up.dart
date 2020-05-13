import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rental_manager/AuthLogin.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/globals.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/main.dart';

class SignUpPage extends StatefulWidget {
  String organization;
  SignUpPage({this.organization});
  @override
  _State createState() => _State();
}

class _State extends State<SignUpPage> {
  @override
  String email, usernameFirst, usernameLast, password, confirmpw;
  var authHandler = new Auth();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    ProgressDialog prSIGNUP;
    prSIGNUP = new ProgressDialog(context, type: ProgressDialogType.Normal);
    prSIGNUP.style(message: 'Successfully Sign Up...');

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Sign Up: ${widget.organization}'),
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
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: TextField(
                      onChanged: (text) {
                        email = text;
                        //print("First text field: $text");
                      },
                      cursorColor: Colors.teal.shade900,
                      scrollPadding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 50),
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
                        labelText: langaugeSetFunc('Email'),
                        prefixIcon: const Icon(Icons.email, color: Colors.black),
                        // labelStyle:
                        // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 50),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: TextField(
                      onChanged: (text) {
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
                        labelText: langaugeSetFunc('First Name'),
                        prefixIcon: const Icon(Icons.person, color: Colors.black),
                        // labelStyle:
                        // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 50),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: TextField(
                      onChanged: (text) {
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
                        labelText: langaugeSetFunc('Lastname'),
                        prefixIcon: const Icon(Icons.person, color: Colors.black),
                        // labelStyle:
                        // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 50),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: TextField(
                      onChanged: (text) {
                        password = text;
                        //print("First password field: $text");
                      },
                      obscureText: true,
                      cursorColor: Colors.teal.shade900,
                      scrollPadding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 50),
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
                        labelText: langaugeSetFunc('Password'),
                        prefixIcon: const Icon(Icons.lock, color: Colors.black),
                        // labelStyle:
                        // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 50),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: TextField(
                      onChanged: (text) {
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
                        labelText: langaugeSetFunc('Confirm Password'),
                        prefixIcon: const Icon(Icons.lock, color: Colors.black),
                        // labelStyle:
                        // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 50),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(langaugeSetFunc('Click sign up after entering all of above')),
                  RaisedButton(
                    textColor: Colors.white,
                    color: Colors.teal.shade900,
                    child: Text('SIGN UP'),
                    onPressed: () async {
//                final QuerySnapshot result =
//                await Firestore.instance.collection('users').getDocuments();
//                final List<DocumentSnapshot> documents = result.documents;
//                List<String> userNameList = [];
//                documents.forEach((data) => userNameList.add(data.documentID));

                      bool localCheck = true;
                      if (email == null ||
                          password == null ||
                          usernameFirst == null ||
                          usernameLast == null ||
                          confirmpw == null) {
                        localCheck = false;

                        String a = langaugeSetFunc('Warning'), b = langaugeSetFunc('Each Field should be filled in');
                        pop_window(a, b, context);
                      } else if (password != confirmpw) {
                        localCheck = false;
                        String a = langaugeSetFunc('Warning'), b = langaugeSetFunc('Your Password should be matched');
                        pop_window(a, b, context);
                      }

                      if (localCheck) {
                        var e = await authHandler.signUp(email, password);

                        if (ErrorDetect(e)) {
                          String a = errorDetect(e, pos: 0), b =  errorDetect(e, pos: 1);
                          pop_window(a, b, context);
                        } else {
                          await prSIGNUP.show();
                          await uploadData(usernameFirst, usernameLast, email,
                              errorDetect(e), widget.organization);
                          // print(errorDetect(e));
                          Future.delayed(Duration(seconds: 2))
                              .then((onValue) {});
                          prSIGNUP.hide();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => MyApp()));
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
