import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/displayall.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/search.dart';
import 'package:rental_manager/uploadCSV.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:rental_manager/tabs/help.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart'
    as slideDialog;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart'; //For creating the SMTP Server
import '../globals.dart';

String contents;

void sendEmail(String subject, String text, BuildContext context) async {
  String username = 'jagaoabc@gmail.com';
  String password = 'Aa123456!';
  text = 'UserEmail: $email\nText:\n$text';
  final smtpServer = gmail(username, password);
// Creating the Gmail server

// Create our email message.
  final message = Message()
    ..from = Address(username)
    ..recipients.add(globals.email) //recipent email
    ..ccRecipients.addAll(
        ['jagaoabc@gmail.com', 'jagaoabc2@gmail.com']) //cc Recipents emails
    ..bccRecipients
        .add(Address('bccAddress@example.com')) //bcc Recipents emails
    ..subject = subject //subject of the email
    ..text = text; //body of the email

  try {
    final sendReport = await send(message, smtpServer);
    print(
        'Message sent: ' + sendReport.toString()); //print if the email is sent
  } on MailerException catch (e) {
    print(
        'Message not sent. \n' + e.toString()); //print if the email is not sent
// e.toString() will show why the email is not sending
  }
}

class ThirdTab extends StatefulWidget {
  @override
  _ThirdTabState createState() => _ThirdTabState();
}

class _ThirdTabState extends State<ThirdTab> {
  SpeedDialChild returnManagerWidget() {
    if (globals.isAdmin) {
      return SpeedDialChild(
        child: Icon(Icons.receipt, color: Colors.white),
        backgroundColor: Colors.green,
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Manager()));
          //pickUpFile(context);
          print(contents);
        },
        label: langaugeSetFunc('Manager View'),
        labelStyle: TextStyle(fontWeight: FontWeight.w500),
        labelBackgroundColor: Colors.green,
      );
    } else if (!globals.isAdmin && globals.locationManager != "") {
      return SpeedDialChild(
        child: Icon(Icons.receipt, color: Colors.white),
        backgroundColor: Colors.green,
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Manager()));
          //pickUpFile(context);
          print(contents);
        },
        label: langaugeSetFunc('Location Manager') +
            ': ${globals.locationManager}',
        labelStyle: TextStyle(fontWeight: FontWeight.w500),
        labelBackgroundColor: Colors.green,
      );
    } else {
      return SpeedDialChild(
        child: Icon(Icons.keyboard_hide, color: Colors.white),
        backgroundColor: Colors.green,
        label: langaugeSetFunc('Click to Hide'),
        labelBackgroundColor: Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
    var buttonWidth = MediaQuery.of(context).size.width / 10 * 7;
    void _onSubmit(String email, String subject, String text) async {
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
          ..ccRecipients.addAll([
            'destCc1@example.com',
            'destCc2@example.com'
          ]) //cc Recipents emails
          ..bccRecipients
              .add(Address('bccAddress@example.com')) //bcc Recipents emails
          ..subject = subject //subject of the email
          ..text = text; //body of the email

        try {
          final sendReport = await send(message, smtpServer);
          print('Message sent: ' +
              sendReport.toString()); //print if the email is sent
        } on MailerException catch (e) {
          print('Message not sent. \n' +
              e.toString()); //print if the email is not sent
          // e.toString() will show why the email is not sending
        }
        pop_window('Confirmed!',
            'This informaton will be sent to our assistants', context);
      }
    }

    void _showDialog(String s) {
      String email, subject, atext;
      slideDialog.showSlideDialog(
        context: context,
        child: Container(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  langaugeSetFunc(s),
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
                  onChanged: (text) {
                    print("First text field: $text");
                    email = text;
                  },
                  validator: (String val) {
                    if (VerifyEmail(val) == false) {
                      var str_mssage = "Please enter your valid email address";
                      return langaugeSetFunc(str_mssage);
                    }
                    return null;
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
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onChanged: (text) {
                    print("First text field: $text");
                    subject = text;
                  },
                  validator: (String val) {
                    if (val.isEmpty) {
                      var str_message = "Please fill in the blank";
                      return langaugeSetFunc(str_message);
                    }
                    return null;
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
                    labelText: langaugeSetFunc('Subject'),
                    prefixIcon: const Icon(Icons.title, color: Colors.black),
                    // labelStyle:
                    // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 50),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onChanged: (text) {
                    print("First text field: $text");
                    atext = text;
                  },
                  validator: (String val) {
                    if (val.isEmpty) {
                      var str_message = "Please fill in the blank";
                      return langaugeSetFunc(str_message);
                    }
                    return null;
                  },
                  keyboardAppearance: Brightness.dark,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  cursorColor: Colors.teal.shade900,
                  scrollPadding: const EdgeInsets.symmetric(
                      vertical: 50.0, horizontal: 50),
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
                    labelText: langaugeSetFunc('Text'),
                    prefixIcon:
                        const Icon(Icons.content_paste, color: Colors.black),
                    // labelStyle:
                    // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 50.0, horizontal: 50),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
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
                    onPressed: () async {
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
            children: <Widget>[],
          ),
        ),
        barrierColor: Colors.white.withOpacity(0.7),
      );
    }

    SpeedDial buildSpeedDial() {
      double height = MediaQuery.of(context).size.height;
      return SpeedDial(
        marginRight: 10,
        marginBottom: height / 3,
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
            onTap: () =>
                _showDialog("Describe the item and leave your contact"),
            label: langaugeSetFunc('Lost And Found'),
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
              child: Text(langaugeSetFunc('Contact us')),
            ),
          ),
          SpeedDialChild(
            child: Icon(Icons.search, color: Colors.white),
            backgroundColor: Colors.teal,
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => track()));
            },
            label: langaugeSetFunc('Track'),
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.teal,
          ),
          returnManagerWidget(),
        ],
      );
    }

    //globals.AppBarheight = AppBar().preferredSize.height;
    List<String> helpList = [
      "Manager View",
      "Track items' usage",
      "Lost and found",
      "Contact us"
    ];

    Widget returnListTile(String name) {
      if (name == helpList[0]) {
        return Column(
          children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                color: BoxBackground(),
              ),
              child: ListTile(
                leading: Icon(
                  CupertinoIcons.person_solid,
                  color: textcolor(),
                ),
                title: Text(
                  langaugeSetFunc(name),
                  style: TextStyle(color: textcolor()),
                ),
                trailing: Icon(
                  CupertinoIcons.right_chevron,
                  color: textcolor(),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Manager()));
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        );
      } else if (name == helpList[1]) {
        return Container(
          decoration: new BoxDecoration(
            color: BoxBackground(),
          ),
          child: ListTile(
            leading: Icon(
              CupertinoIcons.search,
              color: textcolor(),
            ),
            title: Text(
              langaugeSetFunc(name),
              style: TextStyle(color: textcolor()),
            ),
            trailing: Icon(
              CupertinoIcons.right_chevron,
              color: textcolor(),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => track()));
            },
          ),
        );
      } else if (name == helpList[3]) {
        return Container(
          decoration: new BoxDecoration(
            color: BoxBackground(),
          ),
          child: ListTile(
            leading: Icon(
              CupertinoIcons.pencil,
              color: textcolor(),
            ),
            title: Text(
              langaugeSetFunc(name),
              style: TextStyle(color: textcolor()),
            ),
            trailing: Icon(
              CupertinoIcons.right_chevron,
              color: textcolor(),
            ),
            onTap: () {
              _showDialog("Write down your ideas");
            },
          ),
        );
      } else {
        return Container(
          decoration: new BoxDecoration(
            color: BoxBackground(),
          ),
          child: ListTile(
            leading: Icon(
              CupertinoIcons.info,
              color: textcolor(),
            ),
            title: Text(
              langaugeSetFunc(name),
              style: TextStyle(color: textcolor()),
            ),
            trailing: Icon(
              CupertinoIcons.right_chevron,
              color: textcolor(),
            ),
            onTap: () {
              _showDialog("Describe the item and leave your contact");
            },
          ),
        );
      }
    }

    if (globals.isiOS) {
      return MaterialApp(
        home: Scaffold(
          appBar: CupertinoNavigationBar(
            heroTag: "tab31",
            transitionBetweenRoutes: false,
            middle: Text(
              langaugeSetFunc('Help'),
              style: TextStyle(color: textcolor()),
            ),
            backgroundColor: backgroundcolor(),
          ),
          backgroundColor: backgroundcolor(),
          body: ListView.builder(
            itemBuilder: (BuildContext context, int index) =>
                returnListTile(helpList[index]),
            itemCount: helpList.length,
          ),
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            langaugeSetFunc("Help"),
            style: TextStyle(color: textcolor()),
          ),
          backgroundColor: backgroundcolor(),
          centerTitle: true,
        ),
        backgroundColor: backgroundcolor(),
        // floatingActionButton: buildSpeedDial(),
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              returnListTile(helpList[index]),
          itemCount: helpList.length,
        ),
      ),
    );
  }
}

void pop_window(a, b, context) {
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

void pickUpFile(BuildContext context) async {
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
  for (int i = 0; i < contents.length; i++) {
    if (contents[i] == "\n") {
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

class itemInformation {}

class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  final List<Entry> children;
}

final List<Entry> data = <Entry>[
  Entry(
    langaugeSetFunc('How to place an order as a user'),
    <Entry>[
      Entry(
        'Section A0',
        <Entry>[
          Entry('Item A0.1'),
          Entry('Item A0.2'),
          Entry('Item A0.3'),
        ],
      ),
      Entry('Section A1'),
      Entry('Section A2'),
    ],
  ),
  Entry(
    'Chapter B',
    <Entry>[
      Entry('Section B0'),
      Entry('Section B1'),
    ],
  ),
  Entry(
    'Chapter C',
    <Entry>[
      Entry('Section C0'),
      Entry('Section C1'),
      Entry(
        'Section C2',
        <Entry>[
          Entry('Item C2.0'),
          Entry('Item C2.1'),
          Entry('Item C2.2'),
          Entry('Item C2.3'),
        ],
      ),
    ],
  ),
];

class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}
