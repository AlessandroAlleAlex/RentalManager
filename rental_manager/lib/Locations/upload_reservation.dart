import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import '../globals.dart' as globals;

void uploadReservation(String itemID, context) async {
  print(itemID);
  final now = new DateTime.now();
  final reservationStartTime = DateFormat.yMd().add_jm().format(now);
  final reservationEndTime =
      DateFormat.yMd().add_jm().format(now.add(new Duration(minutes: 10)));
  uploadData(
      itemID, globals.uid, reservationStartTime, reservationEndTime, context);
}

void uploadData(
    itemID, uid, reservationStartTime, reservationEndTime, context) async {
  String itemName, imageURL;
  final databaseReference = Firestore.instance;
  await Firestore.instance
      .collection('ARC_items')
      .document(itemID)
      .get()
      .then((DocumentSnapshot ds) {
    try {
      itemName = ds["name"];
      print("Found in ARC_items");
    } catch (e) {
      print(e);
    }
  });

  await Firestore.instance
      .collection('ARC_items')
      .document(itemID)
      .get()
      .then((DocumentSnapshot ds) {
    try {
      imageURL = ds["imageURL"];
      print("Found in ARC_items");
    } catch (e) {
      print(e);
    }
  });

  if (itemName == null) {
    print("UID Not Found");
    itemName = "UID Not Found";
  }
  if (imageURL == null) {
    print("UID Not Found");
    imageURL = "www.gooogle.com";
  }

  final FirebaseUser user = await FirebaseAuth.instance.currentUser();
  final userID = user.uid;

  await databaseReference.collection("reservation").document().setData({
    'imageURL': imageURL,
    'name': itemName,
    'uid': uid,
    'item': itemID,
    'userID': userID,
    'amount': "1",
    'startTime': reservationStartTime,
    'status': "Reserved",
    'endTime': reservationEndTime,
  });
  PlatformAlertDialog(
    title: 'Your item has placed',
    content:
        'Your reservation is successful confirmed, please pick it up on time',
    defaultActionText: Strings.ok,
  ).show(context);
}
