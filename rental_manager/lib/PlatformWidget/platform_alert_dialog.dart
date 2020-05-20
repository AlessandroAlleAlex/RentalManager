import 'dart:io';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/data.dart';
import 'package:rental_manager/globals.dart' as globals;
import 'package:rental_manager/PlatformWidget/platform_widget.dart';
import 'package:rental_manager/PlatformWidget/keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/tabs/reservations.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chatview/login.dart';
import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart' as slideDialog;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
class PlatformAlertDialog extends PlatformWidget {
  PlatformAlertDialog({
    @required this.title,
    @required this.content,
    this.cancelActionText,
    @required this.defaultActionText,
  })  : assert(title != null),
        assert(content != null),
        assert(defaultActionText != null);

  final String title;
  final String content;
  final String cancelActionText;
  final String defaultActionText;

  Future<bool> show(BuildContext context) async {
    return Platform.isIOS
        ? await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) => this,
    )
        : await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => this,
    );
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> actions = <Widget>[];
    if (cancelActionText != null) {
      actions.add(
        PlatformAlertDialogAction(
          child: Text(
            cancelActionText,
            key: Key(Keys.alertCancel),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      );
    }
    actions.add(
      PlatformAlertDialogAction(
        child: Text(
          defaultActionText,
          key: Key(Keys.alertDefault),
        ),
        onPressed: () async{


          Navigator.of(context).pop(true);

          if(content == "Are you going to delete this item"){
            print("Here");
            pop_window("Confirmed", "This item has been removed in your firebase", globals.contextInManageOneItemView);
            //print(globals.documentItemIDInManageView);
            await Firestore.instance.collection(returnItemCollection()).document(globals.documentItemIDInManageView).delete();
          }

          if("This item has been removed in your firebase" == content || "Upload a item Successfully" == content){
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.pop(context, false);
          }

          if("You will use a csv file with name amount imageURL(Optional) to add item(s)" == content){
            pickUpFile(context);
          }

          if(content.contains("Do you want to lock his access and let him become a user")){
            globals.isAdmin = false;
            pop_window("Access Locked", "This person becomes a user", context);
          }
          if(content.contains('Do you want to un-lock his access and let him become a admin')){
            globals.isAdmin = true;
            print("globals.isAdmin: " + globals.isAdmin.toString());
            pop_window("Access Unlocked", "This person becomes a admin", context);
          }

          if(content == "You should see the change on the list soon"){
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.pop(context, false);
          }


          if(defaultActionText == "Yes?") {
            Fluttertoast.showToast(
                msg: "You will be emailed when the item is in stock");
          }
          if(defaultActionText == "Yes"){


            print(globals.CancelledItemDocID);
            String itemName;
            await Firestore.instance.collection(returnReservationCollection()).document(globals.CancelledItemDocID).get().then((snapshot){
              itemName = snapshot.data['name'];
              print(snapshot.data['name']);

            });



            await Firestore.instance.collection(returnReservationCollection()).document(globals.CancelledItemDocID).delete();

            final firestore = Firestore.instance;
            QuerySnapshot itemListDOC =
            await firestore.collection(returnReservationCollection()).getDocuments();
            print(itemListDOC.documents);
            globals.myds = itemListDOC.documents;

            String time =  DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
            sendEmail("Order Cancelled","You chose to cancel your item: $itemName\n The time when you cancelled is $time", context);
            PlatformAlertDialog(
              title: 'Confirmed',
              content: "You've cancelled your order\nLeading You To The Reservation Tab",
              defaultActionText: "Dismiss",
            ).show(globals.mycontext );
            await Future.delayed(const Duration(seconds: 2), (){

              Navigator.pop(globals.mycontext);
            });
          }

          if(content.contains("We appreciate your evaluation!")){
            print("true");
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.pop(context, false);
            //Navigator.pop(globals.mycontext);
          }

          if(title == "Please Confirm"){

            double rate = 0;

            for(int i = 0 ; i < globals.returnDOCIDList.length; i++){
              String time =  DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
              await Firestore.instance.collection(returnReservationCollection()).document(globals.returnDOCIDList[i])
                  .updateData({
                'return time': time,
                'status' : 'Returned',
              });
            }

            slideDialog.showSlideDialog(
              context: context,
              child:  Container(
                child: Form(

                  child: Column(
                    children: <Widget>[
                      Center(
                        child:Text("Thanks for your returning!\nDid you enjoy this experience"),
                      ),

                      Center(
                        child:  RatingBar(
                          initialRating: 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            rate = rating;
                            print(rating);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 300,
                        child: RaisedButton(
                          highlightElevation: 0.0,
                          splashColor: Colors.greenAccent,
                          highlightColor: Colors.green,
                          elevation: 0.0,
                          color: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
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
                          onPressed: () async{
                            print('submit here\n');
                            for(int i = 0; i < globals.returnDOCIDList.length; i++){
                              await Firestore.instance.collection(returnReservationCollection()).document(globals.returnDOCIDList[i])
                                  .updateData({
                                'Review': rate / 5,

                              });
                            }

                            PlatformAlertDialog(
                              title: "Thanks for your review",
                              content: "We appreciate your evaluation!\nYour reviewe will be used in the Help- track Page",
                              defaultActionText: "OK",
                            ).show( globals.ContextInOrder );

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
                  children: <Widget>[
                  ],
                ),
              ),
              barrierColor: Colors.white.withOpacity(0.7),
            );

            for(int i = 0; i < globals.returnDOCIDList.length; i++){
              //await Firestore.instance.collection(globals.collectionName).document(globals.returnDOCIDList[i]).delete();
            }

          }
        },
      ),
    );
    return actions;
  }
}

class PlatformAlertDialogAction extends PlatformWidget {
  PlatformAlertDialogAction({this.child, this.onPressed});
  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoDialogAction(
      child: child,
      onPressed: onPressed,
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return FlatButton(
      child: child,
      onPressed: onPressed,
    );
  }

}


