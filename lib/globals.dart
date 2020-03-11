library my_prj.globals;
import 'dart:collection';

String uid = '';
String username = 'Xu Liu';
String email = '';
String studentID = '91xxxxxx';
String phoneNumber = '530-xxx-xxxx';
String sex = 'Male';
String UserImageUrl = '';
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
  ReservationItem(this.amount, this.startTime, this.endTime, this.itemDocID, this.status, this.uid, this.name, this.imageURL);
}

List<ReservationItem> itemList = new List();

List<Item> detailList = [];
