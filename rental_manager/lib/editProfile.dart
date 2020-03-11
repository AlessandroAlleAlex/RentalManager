import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'globals.dart' as globals;
import 'package:flutter_reactive_button/flutter_reactive_button.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
enum AppState {
  free,
  picked,
  cropped,
}

class EditProfile extends StatelessWidget {
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
  Future<Null> _pickImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {

        state = AppState.picked;

    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;

        state = AppState.cropped;

    }
  }

  void _clearImage() {
    imageFile = null;

      state = AppState.free;

  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          "Edit Profile",
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: <Widget>[
          new PopupMenuButton(
              icon: Icon(Icons.camera_alt),
              onSelected: (String value) async {
                if(value == "Crop"){
                  if(imageFile != null){
                    _cropImage();
                    var url = await uploadImage(imageFile);
                    globals.UserImageUrl = url;
                  }else{
                    PlatformAlertDialog(
                      title: 'Error',
                      content:
                      'Please Upload Image First',
                      defaultActionText: Strings.ok,
                    ).show(context);
                  }
                }else if(value == 'Camera'){
                  _pickImage();
                  var url = await uploadImage(imageFile);
                  globals.UserImageUrl = url;
                }else if(value == 'Remove'){
                  globals.UserImageUrl = "";
                  _clearImage();
                }
              },
              itemBuilder: (BuildContext context) =>
              <PopupMenuItem<String>>[
                new PopupMenuItem(
                    value: "Camera",
                    child:  new Text("Choose Photos")
                ),
                new PopupMenuItem(
                    value: "Crop", child: new Text("Crop Photos")),
                new PopupMenuItem(
                    value: "Remove", child: new Text("Dismiss Photos"))
              ])
        ],
      ),
      body: new EditProfileScreen(),
    );
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
    String _name;
    String _color;
    String _config;

    Widget _buildButtonIcon() {
      if (state == AppState.free)
        return Icon(Icons.camera_alt);
      else if (state == AppState.picked)
        return Icon(Icons.crop);
      else if (state == AppState.cropped)
        return Icon(Icons.clear);
      else
        return Container();
    }

    Future<Null> _pickImage() async {
      imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        setState(() {
          state = AppState.picked;
        });
      }
    }

    Future<Null> _cropImage() async {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: imageFile.path,
          aspectRatioPresets: Platform.isAndroid
              ? [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio5x3,
                  CropAspectRatioPreset.ratio5x4,
                  CropAspectRatioPreset.ratio7x5,
                  CropAspectRatioPreset.ratio16x9
                ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            title: 'Cropper',
          ));
      if (croppedFile != null) {
        imageFile = croppedFile;
        setState(() {
          state = AppState.cropped;
        });
      }
    }

    void _clearImage() {
      imageFile = null;
      setState(() {
        state = AppState.free;
      });
    }

    void _onSubmit() {
      final form = _formKey.currentState;
      if (form.validate()) {
        form.save();
      }
    }
    //floatingActionButton: FloatingActionButton.extended
    String UserName = '', StudentID = '', Phone = '';
    return Material(
      child: Form(
        key: _formKey,
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 0,
                right: 0,
              child: Container(
                child: new PopupMenuButton(
                    icon: Icon(Icons.camera_alt),
                    onSelected: (String value) async {
                      if(value == "Crop"){
                        if(imageFile != null){
                          _cropImage();
                          var url = await uploadImage(imageFile);
                          globals.UserImageUrl = url;
                        }else{
                          PlatformAlertDialog(
                            title: 'Error',
                            content:
                            'Please Upload Image First',
                            defaultActionText: Strings.ok,
                          ).show(context);
                        }
                      }else if(value == 'Camera'){
                        _pickImage();
                        var url = await uploadImage(imageFile);
                        globals.UserImageUrl = url;
                      }else if(value == 'Remove'){
                        globals.UserImageUrl = "";
                        _clearImage();
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                    <PopupMenuItem<String>>[
                      new PopupMenuItem(
                          value: "Camera",
                          child:  new Text("Choose Photos")
                      ),
                      new PopupMenuItem(
                          value: "Crop", child: new Text("Crop Photos")),
                      new PopupMenuItem(
                          value: "Remove", child: new Text("Dismiss Photos"))
                    ]),
              ),
            ),
            new Column(
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
                        'Username',
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.teal),
                      ),
                      margin:
                      new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),
                    new Container(
                      child: new TextFormField(
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
                        },
                        keyboardType: TextInputType.number,
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
                        'Student ID',
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.teal),
                      ),
                      margin:
                      new EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        onChanged: (text) {
                          StudentID = text;
                        },
                        validator: (String num) {
                          if (num.isEmpty) {
                            return null;
                          } else if (CheckInvalidNumber(num) == true) {
                            return 'Input Must Be Numbers Only';
                          } else if (num.length != 9) {
                            return 'Should be Nine Digits';
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
                        'Phone',
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.teal),
                      ),
                      margin:
                      new EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        onChanged: (text) {
                          Phone = text;
                          print(text);
                        },
                        validator: (String num) {
                          if (num.isEmpty) {
                            return null;
                          } else if (CheckInvalidNumber(num) == true) {
                            return 'Input Must Be Numbers Only';
                          } else if (num.length != 10) {
                            return 'Should be Ten Digits';
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

                    // Sex
                    new Container(
                      child: new Text(
                        'Sex',
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.teal),
                      ),
                      margin:
                      new EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                    ),
                    new Container(
                      child: new DropdownButton<String>(
                        items: <String>['Male', 'Female', 'Do not want to tell']
                            .map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            sex = value;
                            globals.sex = sex;
                            print(globals.sex);
                          });
                        },
                        hint: sex == null
                            ? new Text(globals.sex)
                            : new Text(
                          sex,
                          style: new TextStyle(color: Colors.black),
                        ),
                        style: new TextStyle(color: Colors.black),
                      ),
                      margin: new EdgeInsets.only(left: 50.0),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedButton(
                              textColor: Colors.white,
                              color: Colors.teal,
                              child: Text('Confirm'),
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
          ],
        ),
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
