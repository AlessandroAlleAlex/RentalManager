import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:barcode_scan/barcode_scan.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:rental_manager/tabs/reservations.dart';
import 'globals.dart' as globals;
import 'mainView.dart';
import 'tabs/account.dart';
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart' as slideDialog;

Future<void> RemoveRecord(String jobId){
  return Firestore.instance.collection('LoginQRCode').document(jobId).delete();
}

class GenerateScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}


class GenerateScreenState extends State<GenerateScreen> {

  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "Device#1";
  String _inputErrorText;
  final TextEditingController _textController =  TextEditingController();

  @override
  Widget build(BuildContext context) {

    bool verified = false;
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
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('LoginQRCode')
              .snapshots(),
          builder: (context, snapshot){
            var docID = "RequestLogin$_dataString";
            if (!snapshot.hasData) return const Text('loading...');

            final List<DocumentSnapshot> documents = snapshot.data.documents;
            for(int i = 0; i < documents.length; i++){

              if(documents[i].documentID == docID){
                 if(documents[i].data["Confirmed"] == "true"){
                    globals.email = documents[i].data["email"];
                    globals.studentID = documents[i].data["studentID"];
                    globals.phoneNumber = documents[i].data["phoneNumber"];
                    globals.sex = documents[i].data["sex"];
                    globals.uid = documents[i].data["uid"];
                    globals.UserImageUrl = documents[i].data["UserImageUrl"];
                    globals.username = documents[i].data["username"];
                    RemoveRecord(docID);
                    verified = true;

                    break;
//                    Navigator.of(context).pushReplacementNamed('/MainViewScreen');
                 }
              }
            }



            if(verified){

              print("Verified!");

            }



            final bodyHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
            // print(snapshot.data.documents.length);
            return Container(
              color: const Color(0xFFFFFFFF),
              child:  Column(
                children: <Widget>[
                  FlatButton(
                    disabledColor: Colors.black12,
                    onPressed:(){
                      if(verified) {

                        }
                      },
                    child: Text("Button"),
                  ),
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
                  OKPrompt(verified),

                ],
              ),

            );;
          }),
    );
  }
  Future scan() async {
    try {
      String barcode = '';
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


  double  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
    return bodyHeight;
  }
}



Widget quick(BuildContext context ){
    //Navigator.of(context).pop();
 Navigator.push(context, MaterialPageRoute(builder: (context) => FourthTab()));
}


Widget OK(BuildContext context, bool verified){

  String email, subject, atext;
  Future.delayed(Duration(seconds: 1)).then((_){


    if(verified) {
      PlatformAlertDialog(
        title: 'Warning',
        content: 'You will be leading to the MainView',
        defaultActionText: Strings.ok,
      ).show(context);

    }

    if(verified){
      Future.delayed(Duration(seconds: 3)).then((_){

        Navigator.of(context).pushReplacementNamed('/MainViewScreen');
      });
    }
  });
}

class OKPrompt extends StatefulWidget {
  @override
  var verified = false;
  OKPrompt(this.verified);
  _OKPromptState createState() => _OKPromptState();
}

class _OKPromptState extends State<OKPrompt> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: OK(context, widget.verified),
    );
  }
}
