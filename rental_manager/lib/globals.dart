library my_prj.globals;
import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

List<String> existingOrganizations = [];
String uid = '';
String username = 'Xu Liu';
String email = '';
String studentID = '91xxxxxx';
String phoneNumber = '530-xxx-xxxx';
String sex = 'Male';
String UserImageUrl = '';
FirebaseUser mygoogleuser;
BuildContext mycontext;
String CancelledItemDocID = "";
String  collectionName = 'TestModeNew';
List<DocumentSnapshot> myds;
String langaugeSet = "SimplifiedChinese";
String organization = "";
bool dark= false;
int userSelectTheme = -1;
BuildContext contextInManageOneItemView;
BuildContext contextInManageItemView;
String documentItemIDInManageView;
String selectOrg = "Choose your organization";
bool isAdmin = false;
bool isDeveloper = false;
String rentalIDDatabase = "RentalID";
String nameDababase = "Name";

class Item{
  String itemName;
  String itemLocation;
  bool isStock;
  bool needRepair;
  String imageURL;
}

class ItemNameLocation{
  String itemName;
  String imageURL;
}

BuildContext ContextInOrder;
var itemValueMap = new HashMap();

class ReservationItem{
  String name;
  String imageURL;
  String amount;
  String startTime;
  String endTime;
  String itemDocID;
  String status;
  String uid;
  String documentID;
  //ReservationItem(this.amount, this.startTime, this.endTime, this.itemDocID, this.status, this.uid, this.name, this.imageURL);
  ReservationItem(this.amount, this.startTime, this.endTime, this.itemDocID, this.status, this.uid, this.name, this.imageURL, this.documentID);
}

List<ReservationItem> itemList = new List();
List<String>returnDOCIDList = [];
List<Item> detailList = [];
