import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'globals.dart' as globals;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_reactive_button/flutter_reactive_button.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppState {
  free,
  picked,
  cropped,
}

void getData() async {
  try {
    Firestore.instance
        .collection(returnUserCollection())
        .document(globals.uid)
        .get()
        .then((DocumentSnapshot ds) {
      // use ds as a snapshot
      var doc = ds.data;
      globals.studentID = doc["StudentID"];
      globals.username = doc["name"];
      globals.UserImageUrl = doc["imageURL"];

      if (doc["imageURL"] == null || doc["imageURL"].length == 0) {
        globals.UserImageUrl =
        "https://images.unsplash.com/photo-1588250003650-4dbcb25eaba8?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=933&q=80";
      }
      globals.phoneNumber = doc["PhoneNumber"];
    });
  } catch (e) {
    print(e);
  }
}

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  AppState state = AppState.free;
  File imageFile;
  String sex;
  Future<String> uploadImage(File image) async {
    StorageReference reference =
    FirebaseStorage.instance.ref().child(image.path.toString());
    StorageUploadTask uploadTask = reference.putFile(image);

    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

    String url = (await downloadUrl.ref.getDownloadURL());
    globals.UserImageUrl = url;
    var databaseReference = Firestore.instance;
    await databaseReference
        .collection(returnUserCollection())
        .document(globals.uid)
        .updateData({
      'imageURL': globals.UserImageUrl,
    });

    return url;
  }

  @override
  Widget build(BuildContext context) {

    ProgressDialog  pra;
    pra= new ProgressDialog(context, type: ProgressDialogType.Normal);
    pra.style(message: 'Uploading the image');

    var UserName = globals.username,
        StudentID = globals.studentID,
        Phone = globals.phoneNumber;
    getData();
    if (globals.UserImageUrl == null) {
      globals.UserImageUrl =
      "https://images.unsplash.com/photo-1588250003650-4dbcb25eaba8?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=933&q=80";
    }
    GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
    void _onSubmit() async {
      final form = _formKey.currentState;
      if (form.validate()) {
        form.save();
        String fullName = UserName;
        final databaseReference = Firestore.instance;

        if (globals.UserImageUrl == null) {
          globals.UserImageUrl =
          "https://images.unsplash.com/photo-1581660545544-83b8812f9516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80";
        }
        await databaseReference
            .collection(returnUserCollection())
            .document(globals.uid)
            .updateData({
          'name': fullName,
          'email': globals.email,
          'StudentID': globals.studentID,
          'PhoneNumber': globals.phoneNumber,
          'Sex': globals.sex,
          'imageURL': globals.UserImageUrl,
        });
        getData();

        List<String> userinfor = [];
        userinfor.add(globals.uid);
        userinfor.add(globals.studentID);
        userinfor.add(globals.username);
        userinfor.add(globals.UserImageUrl);
        userinfor.add(globals.phoneNumber);
        userinfor.add(globals.email);
        userinfor.add(globals.sex);
        var prefs = await SharedPreferences.getInstance();
        await prefs.setStringList("user", userinfor);
        print("OK");
        PlatformAlertDialog(
          title: 'Confirmed',
          content: 'Your information has been saved',
          defaultActionText: Strings.ok,
        ).show(context);
      }
    }

    return new Scaffold(
        appBar: new AppBar(
          iconTheme: IconThemeData(
            color: textcolor(), //change your color here
          ),
          title: new Text(
            langaugeSetFunc("Details"), style: TextStyle(color: textcolor()),
          ),
          centerTitle: true,
          backgroundColor: backgroundcolor(),
          actions: <Widget>[

          ],
        ),
        backgroundColor: backgroundcolor(),
        body: GestureDetector(
          onTap: () {
            // call this method here to hide soft keyboard
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection(returnUserCollection())
                  .document(globals.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text('loading...');
                return ListView(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                              NetworkImage(globals.UserImageUrl),
                            ),
                            onTap: () async {
                              File image = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);
                              if (image != null) {
                                await pra.show();
                                StorageReference reference = FirebaseStorage
                                    .instance
                                    .ref()
                                    .child(image.path.toString());
                                StorageUploadTask uploadTask =
                                reference.putFile(image);
                                StorageTaskSnapshot downloadUrl =
                                (await uploadTask.onComplete);
                                String url =
                                (await downloadUrl.ref.getDownloadURL());
                                globals.UserImageUrl = url;
                                var databaseReference = Firestore.instance;

                                await databaseReference
                                    .collection(returnUserCollection())
                                    .document(globals.uid)
                                    .updateData({
                                  'imageURL': globals.UserImageUrl,
                                });
                                await pra.hide();
                              }
                            },
                          ),
                          new Container(
                            alignment: Alignment(-1.0, 0.0),
                            child: new Text(
                              langaugeSetFunc('Username'),
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: textcolor()),
                            ),
                            margin: new EdgeInsets.only(
                                left: 10.0, bottom: 5.0, top: 10.0),
                          ),
                          new Container(
                            child: new TextFormField(
                              style: TextStyle(
                                  color: textcolor()
                              ),
                              initialValue: globals.username,
                              onChanged: (text) {
                                UserName = text;
                              },
                              validator: (String val) {
                                if (val.isEmpty) {
                                  return 'This Field Cannot Be Empty';
                                } else if (CheckInValidName(val) == true) {
                                  return 'Invalid Name. Try Again';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                UserName = value;
                                globals.username = UserName;
                              },
                              decoration: new InputDecoration(


                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: textcolor()),
                                  ),
                                  hintText: globals.username,
                                  border: new UnderlineInputBorder(),
                                  contentPadding: new EdgeInsets.all(5.0),
                                  hintStyle: new TextStyle(color: Colors.grey)),
                            ),
                            margin:
                            new EdgeInsets.only(left: 30.0, right: 30.0),
                          ),
                          new Container(
                            alignment: Alignment(-1.0, 0.0),
                            child: new Text(
                              langaugeSetFunc('Employer ID'),
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: textcolor()),
                            ),
                            margin: new EdgeInsets.only(
                                left: 10.0, top: 30.0, bottom: 5.0),
                          ),
                          new Container(
                            child: new TextFormField(
                              style: TextStyle(
                                  color: textcolor()
                              ),
                              initialValue: globals.studentID,
                              onChanged: (text) {
                                StudentID = text;
                                if (StudentID != null &&
                                    StudentID.length == 9) {
                                  globals.studentID = StudentID;
                                }
                              },
                              validator: (String num) {
                                if (num.isEmpty) {
                                  return null;
                                } else if (CheckInvalidNumber(num) == true) {
                                  return 'Input Must Be Numbers Only';
                                } else if (num.length != 9) {
                                  return 'Error! Must be nine digits';
                                }
                                return null;
                              },
                              decoration: new InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: textcolor()),
                                  ),
                                  hintText: '91xxxxxxx(Optional)',
                                  border: new UnderlineInputBorder(),
                                  contentPadding: new EdgeInsets.all(5.0),
                                  hintStyle: new TextStyle(color: Colors.grey)),
                              keyboardType: TextInputType.number,
                            ),
                            margin:
                            new EdgeInsets.only(left: 30.0, right: 30.0),
                          ),
                          new Container(
                            alignment: Alignment(-1.0, 0.0),
                            child: new Text(
                              langaugeSetFunc('Phone'),
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: textcolor()),
                            ),
                            margin: new EdgeInsets.only(
                                left: 10.0, top: 30.0, bottom: 5.0),
                          ),
                          new Container(
                            child: new TextFormField(
                              style: TextStyle(
                                  color: textcolor()
                              ),
                              initialValue: globals.phoneNumber,
                              onChanged: (text) {
                                Phone = text;
                                if (Phone != null && Phone.length == 10) {
                                  globals.phoneNumber = Phone;
                                }
                              },
                              validator: (String num) {
                                if (num.isEmpty) {
                                  return null;
                                } else if (CheckInvalidNumber(num) == true) {
                                  return 'Input Must Be Numbers Only';
                                } else if (num.length != 10) {
                                  return 'Error! Must be ten digits';
                                }
                                return null;
                              },
                              decoration: new InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: textcolor()),
                                  ),
                                  hintText: '530xxxxxxx(Optional)',
                                  border: new UnderlineInputBorder(),
                                  contentPadding: new EdgeInsets.all(5.0),
                                  hintStyle: new TextStyle(color: Colors.grey)),
                              keyboardType: TextInputType.number,
                            ),
                            margin:
                            new EdgeInsets.only(left: 30.0, right: 30.0),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text("Click image to change your photo"),
                          SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                RaisedButton(
                                    textColor: Colors.white,
                                    color: Colors.teal,
                                    child: Text(langaugeSetFunc('Confirm')),
                                    onPressed: () async {
                                      _onSubmit();
                                    }),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ));
  }
}





class EditProfileScreen extends StatefulWidget {
  @override
  State createState() => new EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  AppState state = AppState.free;
  File imageFile;
  String sex;
  Future<String> uploadImage(File image) async {
    StorageReference reference =
    FirebaseStorage.instance.ref().child(image.path.toString());
    StorageUploadTask uploadTask = reference.putFile(image);

    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

    String url = (await downloadUrl.ref.getDownloadURL());

    return url;
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

    String UserName = '', StudentID = '', Phone = '';
    void _onSubmit() async {
      final form = _formKey.currentState;
      if (form.validate()) {
        form.save();
        String fullName = UserName;
        final databaseReference = Firestore.instance;

        if (globals.UserImageUrl == null) {
          globals.UserImageUrl =
          "https://images.unsplash.com/photo-1581660545544-83b8812f9516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80";
        }
        await databaseReference
            .collection(returnUserCollection())
            .document(globals.uid)
            .updateData({
          'name': fullName,
          'email': globals.email,
          'StudentID': globals.studentID,
          'PhoneNumber': globals.phoneNumber,
          'Sex': globals.sex,
          'imageURL': globals.UserImageUrl,
        });
        getData();

        List<String> userinfor = [];
        userinfor.add(globals.uid);
        userinfor.add(globals.studentID);
        userinfor.add(globals.username);
        userinfor.add(globals.UserImageUrl);
        userinfor.add(globals.phoneNumber);
        userinfor.add(globals.email);
        userinfor.add(globals.sex);
        var prefs = await SharedPreferences.getInstance();
        await prefs.setStringList("user", userinfor);
        print("OK");
        PlatformAlertDialog(
          title: 'Confirmed',
          content: 'Your information has been saved',
          defaultActionText: Strings.ok,
        ).show(context);
      }
    }

    return new GestureDetector(
      onTap: () {
        // call this method here to hide soft keyboard
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: new Column(
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    Center(
                      child: InkWell(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(globals.UserImageUrl),
                        ),
                      ),
                    ),
                    // Username
                    new Container(
                      child: new Text(
                        langaugeSetFunc('Username'),
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.teal),
                      ),
                      margin: new EdgeInsets.only(
                          left: 10.0, bottom: 5.0, top: 10.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        initialValue: globals.username,
                        onChanged: (text) {
                          UserName = text;
                        },
                        validator: (String val) {
                          if (val.isEmpty) {
                            return 'This Field Cannot Be Empty';
                          } else if (CheckInValidName(val) == true) {
                            return 'Invalid Name. Try Again';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          UserName = value;
                          globals.username = UserName;
                        },
                        decoration: new InputDecoration(
                            hintText: globals.username,
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    new Container(
                      child: new Text(
                        langaugeSetFunc('Employer ID'),
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.teal),
                      ),
                      margin: new EdgeInsets.only(
                          left: 10.0, top: 30.0, bottom: 5.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        initialValue: globals.studentID,
                        onChanged: (text) {
                          StudentID = text;
                          if (StudentID != null && StudentID.length == 9) {
                            globals.studentID = StudentID;
                          }
                        },
                        validator: (String num) {
                          if (num.isEmpty) {
                            return null;
                          } else if (CheckInvalidNumber(num) == true) {
                            return 'Input Must Be Numbers Only';
                          } else if (num.length != 9) {
                            return 'Error! Must be nine digits';
                          }

                          return null;
                        },
                        decoration: new InputDecoration(
                            hintText: '91xxxxxxx(Optional)',
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                        keyboardType: TextInputType.number,
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    new Container(
                      child: new Text(
                        langaugeSetFunc('Phone'),
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.teal),
                      ),
                      margin: new EdgeInsets.only(
                          left: 10.0, top: 30.0, bottom: 5.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        initialValue: globals.phoneNumber,
                        onChanged: (text) {
                          Phone = text;
                          if (Phone != null && Phone.length == 10) {
                            globals.phoneNumber = Phone;
                          }
                        },
                        validator: (String num) {
                          if (num.isEmpty) {
                            return null;
                          } else if (CheckInvalidNumber(num) == true) {
                            return 'Input Must Be Numbers Only';
                          } else if (num.length != 10) {
                            return 'Error! Must be ten digits';
                          }
                          return null;
                        },
                        decoration: new InputDecoration(
                            hintText: '530xxxxxxx(Optional)',
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                        keyboardType: TextInputType.number,
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    SizedBox(
                      height: 30,
                    ),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedButton(
                              textColor: Colors.white,
                              color: Colors.teal,
                              child: Text(langaugeSetFunc('Confirm')),
                              onPressed: () async {
                                _onSubmit();
                              }),
                        ],
                      ),
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

bool CheckInValidName(String name) {
  Pattern pattern =
      r'^([a-zA-Z]{2,}\s[a-zA-z]{1,}?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)';

  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(name))
    return true;
  else
    return false;
}

bool CheckInvalidNumber(String number) {
  final n = num.tryParse(number);
  return n == null;
}
