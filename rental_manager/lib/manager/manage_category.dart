import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rental_manager/Locations/custom_gridcell.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/data.dart';
import 'package:rental_manager/displayall.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/manager/manage_items.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'package:rental_manager/globals.dart' as globals;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart' as slideDialog;
import 'package:validators/validators.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ManageCategory extends StatefulWidget {
  var  data;
  String documentID;
  ManageCategory({this.data, this.documentID});

  @override
  _ManageCategoryState createState() => _ManageCategoryState();
}

List<String> categoryNameList = [];

class _ManageCategoryState extends State<ManageCategory> {

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Widget popupMenuButton(context) {
    return PopupMenuButton<String>(
        icon: Icon(Icons.add, size: 30.0),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(child: Text(langaugeSetFunc('add category')), value: 'add category'),
              PopupMenuItem(
                  child: Text(langaugeSetFunc('upload categories')), value: 'upload categories'),
            ],
        onSelected: (val) async {
          switch (val) {
            case 'add category':
              await Firestore.instance.collection('imageTmp').document(globals.uid).setData({
                'imageURL': 'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png',
              });
              dialogAddInCatergory();
              break;
            case 'upload categories':
              break;
          }
        });
  }


  void dialogAddInCatergory() {
    String modifyName = "",
        modifyimageURL =
            'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png',
        inputImageURL = "";
    int modifyAmount = 0;

    void submit() async {
      final form = _formKey.currentState;
      var categoryList = this.widget.data["categories"].toList();
      List<Map<dynamic, dynamic> > listcater = [];

      for(int i = 0;  i < categoryList.length; i++){
          var item = categoryList[i];
          listcater.add(item);
      }

      if (form.validate()) {


        if(inputImageURL.isNotEmpty){
          modifyimageURL = inputImageURL;
        }


        listcater.add({'name': modifyName, 'imageURL': modifyimageURL});

        print(listcater[listcater.length - 1]['imageURL']);
        await Firestore.instance.collection(returnLocationsCollection()).document(this.widget.documentID).updateData({
          "categories":  listcater,}
          );
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
                            if (modifyimageURL != 'https://ciat.cgiar.org/wp-content/uploads/image-not-found.png' && inputImageURL.isNotEmpty) {
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
                        langaugeSetFunc('Category Name'),
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
                          bool flagFound = false;
                          for(int i = 0; i < categoryNameList.length; i++){
                            if(categoryNameList[i] == val){
                              flagFound = true;
                              break;
                            }
                          }

                          if(flagFound){
                            return langaugeSetFunc("This name has been used. Please try another one");
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

  void dialogEditInCatergory(name, imageURL) {
    String modifyName = name,
        modifyimageURL = imageURL,
        inputImageURL = "";
    int modifyAmount = 0;
    void submit() async {
      final form = _formKey.currentState;
      var categoryList = this.widget.data['categories'];
      List<Map<dynamic, dynamic> > listcater = [];

      int count = -1;
      for(int i = 0;  i < categoryList.length; i++){
        var item = categoryList[i];
        if(count == -1 && item["name"] == name && item["imageURL"] == imageURL){
          count = i;
        }
        listcater.add(item);
      }




      if (form.validate()) {

        if(count >= 0){
          var item = categoryList[count];
          if(inputImageURL.isNotEmpty){
            modifyimageURL = inputImageURL;
          }
          item['name'] = modifyName;
          item['imageURL'] = modifyimageURL;
        }

        await Firestore.instance.collection(returnLocationsCollection()).document(this.widget.documentID).updateData({
          "categories": listcater,}
        );
        pop_window(langaugeSetFunc('Succeed'), langaugeSetFunc("Upload a item Successfully"), context);
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
                            if (modifyimageURL != imageURL && inputImageURL.isNotEmpty) {
                              print(modifyimageURL);
                              return langaugeSetFunc("Cannot use image URL after uploading a new image");
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
                            hintText: langaugeSetFunc("Leave it empty if this is not used"),
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
                        langaugeSetFunc('Category Name'),
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
                            return langaugeSetFunc('This Field Cannot Be Empty');
                          }
                          bool flagFound = false;
                          for(int i = 0; i < categoryNameList.length; i++){
                            if(categoryNameList[i] == val && val != name){
                              flagFound = true;
                              break;
                            }
                          }

                          if(flagFound){
                            return langaugeSetFunc("This name has been used. Please try another one");
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
                          String title = "Warning", content = "Are you sure you want to delete this item?";
                          categoryDelete(context, cancel, action, title, content, name);
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


  navigateToItem(String categorySelected) {
    String LocationName = widget.data["name"];
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ManageDatabase(catergory: categorySelected, locationName: LocationName)));
  }

  Widget displayGrids(data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              children: data.map<Widget>(
                (categoryInfo) {
                  return GestureDetector(
                    child: GridTile(
                      child: CustomCell(categoryInfo),
                    ),
                    onTap: () {
                      // print("tapped ${categoryInfo.toString()}");
                      navigateToItem(categoryInfo['name']);
                      Fluttertoast.showToast(
                        msg: 'Long Press To Edit',
                      );
                    },
                    onLongPress: () async{
                      await Firestore.instance.collection('imageTmp').document(globals.uid).setData({
                        'imageURL': categoryInfo['imageURL'],
                      });
                      dialogEditInCatergory(categoryInfo['name'], categoryInfo['imageURL']);
                    },
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundcolor(),
          iconTheme: IconThemeData(
            color: textcolor(), //change your color here
          ),
          title: Text(langaugeSetFunc('Manage category'), style: TextStyle(color: textcolor()),),
          actions: <Widget>[
            popupMenuButton(context),
          ],
        ),

        body: StreamBuilder(
            stream: Firestore.instance.collection(returnLocationsCollection()).document(this.widget.documentID).snapshots(),
            builder: (context, snapshot){

              var mydata = snapshot.data;
              categoryNameList.clear();
              this.widget.data =  snapshot.data;
              var lista = [];
              try{
                lista = mydata['categories'];
              }catch(e){
                print(e);
              }
              for(int i = 0; i < lista.length; i++){
                var item = lista[i];
                if(item['name'] != null){
                  if( item['name'].toString().isNotEmpty){
                    categoryNameList.add(item['name']);
                  }
                }
              }
              try{
                if(mydata == null){
                  return Container();
                }
              }catch(e){
                print(e);
              }

              return displayGrids(snapshot.data['categories']);
            }
        ),
    );
  }

  Future<void> categoryDelete(context, cancel, action, title, content, name ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(cancel ),
              onPressed: () {
                print(1);
                Navigator.of(context).pop(true);

              },
            ),
            CupertinoDialogAction(
              child: Text(action,),
              onPressed: () async{
                QuerySnapshot itemList = await Firestore.instance.collection(returnItemCollection()).where('category', isEqualTo: name).where('Location', isEqualTo: this.widget.data["name"]).getDocuments();
                for(int i = 0; i < itemList.documents.length;i++){
                  var doumentID = itemList.documents[i].documentID;
                  await Firestore.instance.collection(returnItemCollection()).document(doumentID).delete();
                }

                var categoryList = this.widget.data['categories'];
                List<Map<dynamic, dynamic> > listcater = [];

                for(int i = 0;  i < categoryList.length; i++){
                  var item = categoryList[i];
                  print((item['name'] == name));
                  if(item['name'] != name){
                    listcater.add(item);
                  }
                }

                await Firestore.instance.collection(returnLocationsCollection()).document(this.widget.documentID).updateData({
                  "categories": listcater,}
                );


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

