import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/platform_exception_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';
import 'package:flutter/services.dart';
import 'globals.dart' as globals;


class Auth {
  PlatformException errorCatch;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userID = '';
  bool isSignUp = false;
  Future<String> signIn(username,password) async {
    try {
      FirebaseUser user = (await auth.signInWithEmailAndPassword(
          email: username, password: password)).user;

      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await auth.currentUser();
      assert(user.uid == currentUser.uid);
      return user.uid;
    } catch (e) {
      print(e);
      return e.toString();
    }

  }

  Future<String> signUp(email, password) async {

    FirebaseUser user;

    try {
      AuthResult authResult = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      isSignUp = true;
      print('True here');
      user = authResult.user;
      userID = user.uid;
      return user.uid;
    }catch(e){
      //errorHands(e);
      print(e);
      userID = e.toString();
      return e.toString();
    }



  }



}