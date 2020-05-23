import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rental_manager/Locations/custom_location_card.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/manager/manage_category.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'package:rental_manager/globals.dart' as globals;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart'
    as slideDialog;
import 'package:validators/validators.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ManageLocations extends StatefulWidget {
  @override
  _ManageLocationsState createState() => _ManageLocationsState();
}

class _ManageLocationsState extends State<ManageLocations> {
  final firestore = Firestore.instance.collection(returnLocationsCollection());
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Widget popupMenuButton() {
    return PopupMenuButton<String>(
        icon: Icon(Icons.add, size: 30.0),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(child: Text('add location'), value: 'add location'),
              PopupMenuItem(
                  child: Text('upload locations'), value: 'upload locations'),
            ],
        onSelected: (val) async {
          switch (val) {
            case 'add location':
              await Firestore.instance
                  .collection('imageTmp')
                  .document(globals.uid)
                  .updateData({
                'imageURL':
                    'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png',
              });
              _showDialog2();
              break;
            case 'upload locations':
              break;
          }
        });
  }

  void _showDialog2() {
    String modifyName = "",
        modifyimageURL =
            'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png',
        inputImageURL = "";
    int modifyAmount = 0;
    void submit() async {
      final form = _formKey.currentState;
      if (form.validate()) {
        if (inputImageURL.isNotEmpty) {
          modifyimageURL = inputImageURL;
        }
        await Firestore.instance
            .collection(returnLocationsCollection())
            .document()
            .setData({
          'imageURL': modifyimageURL,
          'name': modifyName,
          'categories': [],
        });
        pop_window('Succeed', "Upload a item Successfully", context);
      }
    }

    slideDialog.showSlideDialog(
      context: context,
      child: StreamBuilder(
          stream: Firestore.instance
              .collection('imageTmp')
              .document(globals.uid)
              .snapshots(),
          builder: (context, snapshot) {
            String theurl =
                'https://images.unsplash.com/photo-1588693273928-92fa26159c88?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=975&q=80';
            try {
              var ds = snapshot.data;
              theurl = ds.data["imageURL"];
            } catch (e) {
              print(e.toString());
            }
            print(theurl);
            return Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Text(langaugeSetFunc('Click Image to Change')),
                    InkWell(
                      onTap: () async {
                        ProgressDialog prUpdate;
                        prUpdate = new ProgressDialog(context,
                            type: ProgressDialogType.Normal);
                        prUpdate.style(message: 'Showing some progress...');
                        prUpdate.update(
                          message: 'Uploading...',
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

                        File imageFile;
                        imageFile = await ImagePicker.pickImage(
                            source: ImageSource.gallery);

                        if (imageFile != null) {
                          await prUpdate.show();
                          StorageReference reference = FirebaseStorage.instance
                              .ref()
                              .child(imageFile.path.toString());
                          StorageUploadTask uploadTask =
                              reference.putFile(imageFile);

                          StorageTaskSnapshot downloadUrl =
                              (await uploadTask.onComplete);

                          String url = (await downloadUrl.ref.getDownloadURL());
                          prUpdate.update(
                            message: 'Complete',
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
                          await Firestore.instance
                              .collection('imageTmp')
                              .document(globals.uid)
                              .setData({
                            'imageURL': '$url',
                          });
                          setState(() {
                            modifyimageURL = url;
                          });
                          modifyimageURL = url;
                          print("URL:" + url);
                          prUpdate.hide();
                        }
                      },
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.teal,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal,
                          backgroundImage: NetworkImage(theurl),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Use Image URL Instead'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        onChanged: (text) {
                          inputImageURL = text;
                        },
                        validator: (String val) {
                          print(val);
                          if (val == null || val.isEmpty) {
                            return null;
                          } else {
                            if (modifyimageURL !=
                                    'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png' &&
                                inputImageURL.isNotEmpty) {
                              return "Cannot use image URL after uploading a new image";
                            }
                            var match = isURL(val, requireTld: true);
                            print("Match: " + match.toString());
                            if (match) {
                              return null;
                            } else {
                              return "InValid URL";
                            }
                          }
                        },
                        onSaved: (value) {},
                        decoration: new InputDecoration(
                            hintText: "Leave it empty if this is not used",
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Location Name'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        initialValue: modifyName,
                        onChanged: (text) {
                          modifyName = text;
                        },
                        validator: (String val) {
                          if (val.isEmpty) {
                            return 'This Field Cannot Be Empty';
                          }

                          bool found = false;
                          for (int i = 0; i < locationNameList.length; i++) {
                            if (locationNameList[i] == val) {
                              found = true;
                              break;
                            }
                          }
                          if (found) {
                            return "This name has already been used in your locations. Please try another one";
                          }

                          return null;
                        },
                        onSaved: (value) {},
                        decoration: new InputDecoration(
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
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
                                langaugeSetFunc('Submit'),
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
                          submit();
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
            );
          }),
      textField: Container(
        child: Column(
          children: <Widget>[],
        ),
      ),
      barrierColor: Colors.white.withOpacity(0.7),
    );
  }

  void _showDialog1(name, imageURL, documentID) {
    String modifyName = name, modifyimageURL = imageURL, inputImageURL = "";
    int modifyAmount = 0;
    void submit() async {
      final form = _formKey.currentState;
      if (form.validate()) {
        if (inputImageURL.isNotEmpty) {
          modifyimageURL = inputImageURL;
        }

        await Firestore.instance
            .collection(returnLocationsCollection())
            .document(documentID)
            .updateData({
          'imageURL': modifyimageURL,
          'name': modifyName,
        });
        pop_window('Succeed', "Upload a item Successfully", context);
      }
    }

    slideDialog.showSlideDialog(
      context: context,
      child: StreamBuilder(
          stream: Firestore.instance
              .collection('imageTmp')
              .document(globals.uid)
              .snapshots(),
          builder: (context, snapshot) {
            String theurl = modifyimageURL;
            try {
              var ds = snapshot.data;
              theurl = ds.data["imageURL"];
            } catch (e) {
              print(e.toString());
            }
            print(theurl);
            return Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Text(langaugeSetFunc('Click Image to Change')),
                    InkWell(
                      onTap: () async {
                        ProgressDialog prUpdate;
                        prUpdate = new ProgressDialog(context,
                            type: ProgressDialogType.Normal);
                        prUpdate.style(message: 'Showing some progress...');
                        prUpdate.update(
                          message: 'Uploading...',
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

                        File imageFile;
                        imageFile = await ImagePicker.pickImage(
                            source: ImageSource.gallery);

                        if (imageFile != null) {
                          await prUpdate.show();
                          StorageReference reference = FirebaseStorage.instance
                              .ref()
                              .child(imageFile.path.toString());
                          StorageUploadTask uploadTask =
                              reference.putFile(imageFile);

                          StorageTaskSnapshot downloadUrl =
                              (await uploadTask.onComplete);

                          String url = (await downloadUrl.ref.getDownloadURL());
                          prUpdate.update(
                            message: 'Complete',
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
                          await Firestore.instance
                              .collection('imageTmp')
                              .document(globals.uid)
                              .setData({
                            'imageURL': '$url',
                          });
                          modifyimageURL = url;
                          print("URL:" + url);
                          prUpdate.hide();
                        }
                      },
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.teal,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal,
                          backgroundImage: NetworkImage(theurl),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Use Image URL Instead'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        onChanged: (text) {
                          inputImageURL = text;
                        },
                        validator: (String val) {
                          print(val);
                          if (val == null || val.isEmpty) {
                            return null;
                          } else {
                            if (modifyimageURL != imageURL &&
                                inputImageURL.isNotEmpty) {
                              return langaugeSetFunc(
                                  "Cannot use image URL after uploading a new image");
                            }
                            var match = isURL(val, requireTld: true);
                            print("Match: " + match.toString());
                            if (match) {
                              return null;
                            } else {
                              return "InValid URL";
                            }
                          }
                        },
                        onSaved: (value) {
                          inputImageURL = value;
                        },
                        decoration: new InputDecoration(
                            hintText: "Leave it empty if this is not used",
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Container(
                      alignment: Alignment(-1.0, 0.0),
                      child: new Text(
                        langaugeSetFunc('Location Name'),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    new Container(
                      child: new TextFormField(
                        initialValue: modifyName,
                        onChanged: (text) {
                          modifyName = text;
                        },
                        validator: (String val) {
                          if (val.isEmpty) {
                            return 'This Field Cannot Be Empty';
                          }
                          return null;
                        },
                        onSaved: (value) {},
                        decoration: new InputDecoration(
                            border: new UnderlineInputBorder(),
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: new TextStyle(color: Colors.grey)),
                      ),
                      margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
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
                                langaugeSetFunc('Submit'),
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
                          submit();
                        },
                        padding: EdgeInsets.all(7.0),
                        //color: Colors.teal.shade900,
                        disabledColor: Colors.black,
                        disabledTextColor: Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
                      child: RaisedButton(
                        highlightElevation: 0.0,
                        splashColor: Colors.greenAccent,
                        highlightColor: Colors.red,
                        elevation: 0.0,
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Text(
                                langaugeSetFunc('Delete'),
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
                          String cancel = "Cancel", action = "Delete";
                          String title = "Warning",
                              content =
                                  "Are you sure you want to delete this item";
                          String locationName = "";
                          await Firestore.instance
                              .collection(returnLocationsCollection())
                              .document(documentID)
                              .get()
                              .then((DocumentSnapshot a) {
                            try {
                              locationName = a["name"];
                              print(a["name"]);
                            } catch (e) {
                              print(e.toString());
                            }
                          });
                          locationDeleteDialog(context, cancel, action, title,
                              content, locationName, documentID);
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
            );
          }),
      textField: Container(
        child: Column(
          children: <Widget>[],
        ),
      ),
      barrierColor: Colors.white.withOpacity(0.7),
    );
  }

  void navToMangerCategory(data, BuildContext context, documentID) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ManageCategory(data: data, documentID: documentID)));
  }

  Widget managerLocationCard(data, context, documentID) {
    return InkWell(
      onTap: () {
        Fluttertoast.showToast(
          msg: 'Long Press To Edit',
        );
        print(data);
        navToMangerCategory(data, context, documentID);
      },
      onLongPress: () async {
        String name = data["name"], imageURL = data["imageURL"];
        await Firestore.instance
            .collection('imageTmp')
            .document(globals.uid)
            .updateData({
          'imageURL': imageURL,
        });
        _showDialog1(name, imageURL, documentID);
      },
      child: Container(
        // padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
        height: 100,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.blue,
              blurRadius: 50.0, // has the effect of softening the shadow
              // spreadRadius: 0, // has the effect of extending the shadow
              // offset: Offset(
              //   10.0, // horizontal, move right 10
              //   0.0, // vertical, move down 10
              // ),
            )
          ],
        ),
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(data['imageURL']),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Text(
                            data['name'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              // color: Colors.white,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6
                                ..color = Colors.blue[700],
                            ),
                          ),
                          Text(
                            data['name'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Stack(
                        children: <Widget>[
                          Text(
                            '>',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              // color: Colors.white,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6
                                ..color = Colors.blue[700],
                            ),
                          ),
                          Text(
                            '>',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // Icon(
                      //   Icons.keyboard_arrow_right,
                      //   color: Colors.white,
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  List<String> locationNameList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        title: Text(
          langaugeSetFunc('Manage Locations'),
          style: TextStyle(color: textcolor()),
        ),
        backgroundColor: backgroundcolor(),
        actions: <Widget>[
          popupMenuButton(),
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: firestore.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text(
                  langaugeSetFunc('Loading...'),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    var documentID = snapshot.data.documents[index].documentID;
                    locationNameList.clear();
                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                      var item = snapshot.data.documents[i];
                      locationNameList.add(item["name"]);
                    }

                    return
                        // ListTile(
                        //     title: Text('${snapshot.data.documents.length}'));
                        // print(snapshot.data.documents.length);
                        managerLocationCard(snapshot.data.documents[index].data,
                            context, documentID);
                  });
            }
          },
        ),
      ),
    );
  }

  Future<void> locationDeleteDialog(context, cancel, action, title, content,
      locationName, locationDocID) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(cancel),
              onPressed: () {
                print(1);
                Navigator.of(context).pop(true);
              },
            ),
            CupertinoDialogAction(
              child: Text(
                action,
              ),
              onPressed: () async {
                QuerySnapshot itemList = await Firestore.instance
                    .collection(returnItemCollection())
                    .where('Location', isEqualTo: locationName)
                    .getDocuments();
                for (int i = 0; i < itemList.documents.length; i++) {
                  var doumentID = itemList.documents[i].documentID;
                  await Firestore.instance
                      .collection(returnItemCollection())
                      .document(doumentID)
                      .delete();
                }

                await Firestore.instance
                    .collection(returnLocationsCollection())
                    .document(locationDocID)
                    .delete();

                Navigator.of(context).pop(true);
                FocusScope.of(context).requestFocus(FocusNode());
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }
}
