import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_manager/PlatformWidget/platform_alert_dialog.dart';
import 'package:rental_manager/PlatformWidget/strings.dart';

class Post {
  final String title;
  final String description;
  final String imageUrl;
  Post(this.title, this.description, this.imageUrl);
}

class itemList {
  String name;
  int num;
  String imageUrl;

  itemList(this.name, this.num, this.imageUrl);
}

List<itemList> myItemList = [];
List<String> myNamelist = [];
List<int> myNumlist = [];
List<String> myimageUrlist = [];
var itemFound = false;

class track extends StatefulWidget {
  @override
  _trackState createState() => _trackState();
}

class _trackState extends State<track> {
  Future<List<Post>> search(String search) async {
    List<itemList> alist = await searchBydocID(search);
    print(myNamelist.length);
    return List.generate(myNamelist.length, (int index) {
      var a = myNamelist[index];
      var stockNum = myNumlist[index];
      var imageUrl = myimageUrlist[index];
//      String name = a.name, imageUrl = a.imageUrl;
//      int num = a.num;
      return Post(
        "$a",
        "InStock :$stockNum",
        "$imageUrl",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Track you favor'),
        backgroundColor: Colors.teal,

      ),
      body: GestureDetector(
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchBar<Post>(
              onSearch: search,
              onItemFound: (Post post, int index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(post.imageUrl),
                  ),
                  title: Text(post.title),
                  subtitle: Text(post.description),
                  trailing: new Icon(Icons.chevron_right),
                  onTap: () async {
                    String str1 = "Item In Stock",
                        str2 = "Feel free to come and Check it in",
                        str3 = "Cancel",
                        strDecide = "OK";

                    int stockNum = int.parse(post.description.substring(9));

                    if (stockNum == 0) {
                      str1 = "You may have to wait";
                      String str;

                      final QuerySnapshot result = await Firestore.instance
                          .collection('reservation')
                          .getDocuments();
                      final List<DocumentSnapshot> documents = result.documents;

                      for (int i = 0; i < documents.length; i++) {
                        print("OK");
                        var ds = documents[i].data;

                        if (ds["name"] == post.title) {
                          var start = ds["startTime"];
                          print(start);
                          if (str == null) {
                            str = start;
                          } else {
                            for (int i = 0; i < str.length; i++) {
                              if (str[i] != start[i]) {
                                if (int.parse(str[i]) >= 0 &&
                                    int.parse(str[i]) <= 9) {
                                  if (int.parse(str[i]) > int.parse(start[i])) {
                                    str = start;
                                    break;
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                      if( str != null && str.contains("-")){
                        str = str.replaceAll('-', '/');
                      }
                      str2 =
                          "The Earliest time that being checking in for this item: $str";
                      str2 +=
                          "\nWant to know what time the item will be in Stock?";
                      strDecide = "Yes?";
                    }
                    PlatformAlertDialog(
                      title: str1,
                      content: str2,
                      cancelActionText: str3,
                      defaultActionText: strDecide,
                    ).show(context);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

Future<List<itemList>> searchBydocID(String pattern) async {
  final databaseReference = Firestore.instance;

  final QuerySnapshot result =
      await Firestore.instance.collection('ARC_items').getDocuments();
  final List<DocumentSnapshot> documents = result.documents;

  itemFound = false;
  List<itemList> alist = [];
  myNamelist.clear();
  myItemList.clear();
  myNumlist.clear();
  myimageUrlist.clear();
  for (var i = 0; i < documents.length; i++) {
    var ds = documents[i].data;
    try {
      String name = ds["name"];
      int num = ds["# of items"];
      String imageUrl = ds["imageURL"];
      print("Belt-Weight".contains("Be"));
      if (name.toLowerCase().contains(pattern.toLowerCase()) == true) {
        var a = new itemList(name, num, imageUrl);

        myNamelist.add(name);
        myNumlist.add(num);
        myimageUrlist.add(imageUrl);
        myItemList.add(a);
        alist.add(a);
      }
    } catch (e) {
      print(e);
    }
  }

  return alist;
}
