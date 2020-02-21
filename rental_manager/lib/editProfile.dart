import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'globals.dart' as globals;

class EditProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(

        title: new Text(
          "Edit Profile",
          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
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
  File _image;
  String sex;

  Future getImage( ) async {
    var result = await ImagePicker.pickImage(source: ImageSource.gallery );
    setState(() {
      _image = result;
    });
  }

  uploadImage(File image) async {
    StorageReference reference =
    FirebaseStorage.instance.ref().child(image.path.toString());
    StorageUploadTask uploadTask = reference.putFile(image);

    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

    String url = (await downloadUrl.ref.getDownloadURL());


  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
    String _name;
    String _color;
    String _config;

    void _onSubmit() {
      final form = _formKey.currentState;
      if(form.validate()) {
        form.save();

      }
    }
//    Center(
//      child: _image == null
//          ? Text('')
//          : Image.file(_image),
//    ),

    String UserName = '', StudentID = '', Phone = '';
    return new SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: new Column(
          children: <Widget>[
            new Container(
              child: Row(

              ),
            ),
            RaisedButton(
              onPressed: getImage,
              child: Icon(Icons.add_a_photo),
            ),
            new Column(
              children: <Widget>[
                // Username
                new Container(
                  child: new Text(
                    'Username',
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.teal),
                  ),
                  margin: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                ),
                new Container(
                  child: new TextFormField(
                    onChanged: (text){
                      UserName = text;
                    },
                    validator: (String val) {
                      if(val.isEmpty){
                        return 'This Field Cannot Be Empty';
                      }else if( CheckInValidName(val) == true){
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
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.teal),
                  ),
                  margin: new EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                ),
                new Container(
                  child: new TextFormField(
                    onChanged:(text){
                      StudentID = text;

                    },
                    validator: (String num){
                      if(num.isEmpty){
                        return null;
                      }else if( CheckInvalidNumber(num) == true){
                        return 'Input Must Be Numbers Only';
                      }else if(num.length != 9){
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
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.teal),
                  ),
                  margin: new EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                ),
                new Container(
                  child: new TextFormField(
                    onChanged:(text){
                      Phone = text;
                      print(text);
                    },
                    validator: (String num){
                      if(num.isEmpty){
                        return null;
                      }else if( CheckInvalidNumber(num) == true){
                        return 'Input Must Be Numbers Only';
                      }else if(num.length != 10){
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
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.teal),
                  ),
                  margin: new EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                ),
                new Container(
                  child: new DropdownButton<String>(
                    items: <String>['Male', 'Female', 'Do not want to tell'].map((String value) {
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
                          onPressed: () async{
                            _onSubmit();
                          }
                      ),

                    ],

                  ),
                )

              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            )
          ],
        ),
      ),
      padding: new EdgeInsets.only(bottom: 20.0),
    );
  }
}

bool CheckInValidName(String name){
  Pattern pattern =
      r'^([a-zA-Z]{2,}\s[a-zA-z]{1,}?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)';

  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(name))
    return true;
  else
    return false;
}

bool CheckInvalidNumber(String number){
  final n = num.tryParse(number);
  return n == null;
}