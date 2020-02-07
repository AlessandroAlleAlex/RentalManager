import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<FirebaseUser> getCurrentUser();
  Future<void> signOut();
}
class Auth implements BaseAuth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<String> signIn(String email, String password) async {
    FirebaseUser user;
    try{
       user = (await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user;
       print("Successfully logged in!");
       return user.uid;
    }catch (e){
      return e.toString();
      
    }
  }

  Future<String> signUp(String email, String password) async {
    FirebaseUser user;
    try{
    user = (await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user;
    }catch (e){
      print(e);
    }
    //Also add user to the database.
    
    return user.uid;
  }
  static Future<bool> checkUserExist(String userId) async {
    bool exists = false;
    try {
      await Firestore.instance.document("users/$userId").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  // static void addUserSettingsDB(String userId) async {
  //   checkUserExist(userId).then((value) {
  //     if (!value) {
  //       print("user ${user.firstName} ${user.email} added");
  //       Firestore.instance
  //           .document("users/${user.userId}")
  //           .setData(user.toJson());
  //       _addSettings(new Settings(
  //         settingsId: userId,
  //       ));
  //     } else {
  //       print("user ${user.firstName} ${user.email} exists");
  //     }
  //   });
  // }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user;
    try{
    user = await _firebaseAuth.currentUser();
     }catch (e){
      print(e);
    }
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
  
}

class User {
  String name;
  String email;
  String userID;
  String username;

  User(String _name, String _email, String _userID, String _username){
    this.name = _name;
    this.email = _email;
    this.userID = _userID;
    this.username = _username;
  }

  void debugPrintUser() {
    print('User Information: $name  $email $userID'); 
  }
  void updateUserlocal(String userid){
    this.userID = userid;
    
    
    //Retireve from firestore data and set all local info.
  }
  

  void updateUserFb(){
    //Updating globally
  }
  String getName() {
    return name;
  }
  String getEmail() {
    return email;
  }
  String getUserName() {
    return username;
  }
  String getUserID() {
    return userID;
  }
  
}

class item{
  String name;
  String itemID;
  
}

class reservation{
  User user;
  item items;
}

