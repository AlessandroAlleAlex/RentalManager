import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_manager/globals.dart' as globals;
class GenerateScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {

  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "Hello from this QR";
  String _inputErrorText;
  final TextEditingController _textController =  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons. camera_alt),
            onPressed: scan,
          )
        ],
      ),
      body: _contentWidget(),
    );
  }
  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setQRLoginIn(barcode);
      print("OK");
      PlatformAlertDialog(
        title: 'QR Code Scanned',
        content: barcode,
        defaultActionText: Strings.ok,
      ).show(context);
    } on PlatformException catch (e) {
      PlatformAlertDialog(
        title: 'QR Code Error',
        content: e.toString(),
        defaultActionText: Strings.ok,
      ).show(context);
    }
  }


  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
    return  Container(
      color: const Color(0xFFFFFFFF),
      child:  Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: _topSectionTopPadding,
              left: 20.0,
              right: 10.0,
              bottom: _topSectionBottomPadding,
            ),
            child:  Container(
              height: _topSectionHeight,
              child:  Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child:  TextField(
                      controller: _textController,
                      decoration:  InputDecoration(
                        hintText: "Enter keywords",
                        errorText: _inputErrorText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child:  FlatButton(
                      child:  Text("Confirm"),
                      onPressed: () {
                        setState((){
                          _dataString = _textController.text;
                          _inputErrorText = null;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),

                      ),
                      color: Colors.teal,
                      highlightColor: Color(0xffff7f7f),
                      splashColor: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child:  Center(
              child: RepaintBoundary(
                key: globalKey,
                child: QrImage(
                  data: _dataString,
                  size: 0.5 * bodyHeight,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void setQRLoginIn(String uniqueID) async{
  final databaseReference = Firestore.instance;
  await databaseReference.collection("LoginQRCode")
      .document("RequestLogin$uniqueID")
      .setData({
    'Confirmed': "true",
    'uid' : globals.uid,
    'email': globals.email,
    'studentID': globals.studentID,
    'phoneNumber':globals.phoneNumber,
    'sex': globals.sex,
    'UserImageUrl': globals.UserImageUrl,
    'FirebaseUser': globals.mygoogleuser.toString(),
    'username': globals.username,
  });
  print("Finished setting");
}
/*
* String uid = '';
String username = 'Xu Liu';
String email = '';
String studentID = '91xxxxxx';
String phoneNumber = '530-xxx-xxxx';
String sex = 'Male';
String UserImageUrl = '';
FirebaseUser mygoogleuser;
*
*
* */