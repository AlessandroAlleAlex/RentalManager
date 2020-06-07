import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/main.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../Locations/list_page.dart';
import 'package:rental_manager/globals.dart' as globals;
import 'package:flutter_cupertino_data_picker/flutter_cupertino_data_picker.dart';

import 'help.dart';
class FirstTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationPage(title: 'Select a Location'),
    );
  }
}

class LocationPage extends StatefulWidget {
  final String title;
  LocationPage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LocationPageState();
  }
}

Color backgroundcolor() {
  if (globals.dark == false) {
    return Color.fromRGBO(237, 237, 237, 1);
  } else {
    return Color.fromRGBO(25, 25, 25, 1);
  }
}

Color BoxBackground(){
  return globals.dark == false?  Colors.white : Color.fromRGBO(35, 35, 35, 1);
}

Color textcolor() {
  if (globals.dark == false) {
    return Colors.black;
  } else {
    return Color.fromRGBO(211, 211, 211,1);
  }
}

List<PopupMenuItem<String>> copy_list = [];
List<String> organizationList = [];

class _LocationPageState extends State<LocationPage> {
  @override
  void initState() {
    // TODO: implement initState
    abc();
    super.initState();
  }

  void abc() async {
    organizationList.clear();
    QuerySnapshot list =
        await Firestore.instance.collection('organizations').getDocuments();
    list.documents.forEach((element) {
      String str = element.data['name'];
      if (str != null && str.isNotEmpty) {
        organizationList.add(str);
      }
    });
    print(organizationList.length);
    List<PopupMenuItem<String>> alist = [];
    organizationList.forEach((element) {
      alist.add(new PopupMenuItem(value: element, child: new Text(element)));
    });

    copy_list.clear();
    copy_list = alist;
  }

  Widget popMenuButton(context) {
    if(copy_list.length == null){
      return Icon(CupertinoIcons.ellipsis);
    }
    return new PopupMenuButton(
        icon: Icon(CupertinoIcons.ellipsis),
        onSelected: (String value) async {
          setState(() {
            globals.organization = value;
          });
        },
        itemBuilder: (BuildContext context) => copy_list);
  }

  CupertinoNavigationBar buildNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
        trailing: CupertinoButton(
          child: Text('Save', style: TextStyle(color: CupertinoColors.activeBlue)),
          onPressed: () => Navigator.pop(context),
        ));
  }



  void picker(){

    List<Text>nameList = [];
    List<String>copy_nameList = [];
    String selectedValue = globals.organization;
    organizationList.forEach((element) {
      copy_nameList.add(element);
    });
    copy_nameList.sort();
    copy_nameList = copy_nameList.toSet().toList();
    copy_nameList.forEach((element) {
      nameList.add(Text('$element'));
    });
    int initalIndex = 0;
    for(int i = 0; i < copy_nameList.length;i++) {
      if(copy_nameList[i].toString() == globals.organization){

        initalIndex = i;
        break;
      }
    }
    showCupertinoModalPopup<String>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xff999999),
                    width: 0.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'),
                    onPressed: () async{
                      Navigator.pop(context);
                      globals.organization = selectedValue;
                      organizationList.clear();
                      QuerySnapshot list =
                      await Firestore.instance.collection('organizations').getDocuments();
                      list.documents.forEach((element) {
                        String str = element.data['name'];
                        if (str != null && str.isNotEmpty) {
                          organizationList.add(str);
                        }
                      });
                      setState(() {
                        globals.organization = selectedValue;
                        ListPage();
                      });
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 320.0,
              color: Color(0xfff7f7f7),
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: initalIndex),
                onSelectedItemChanged:(int index){
                  selectedValue =  copy_nameList[index].toString();

                },
                children: nameList,
                itemExtent: 32,
              ),
            )
          ],
        );
      },
    );


  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    abc();


    if(globals.isiOS){


      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          heroTag: "Tab11",

          middle: Text(
          langaugeSetFunc('Select a Location'),
          style: TextStyle(color: textcolor()),),
          trailing: GestureDetector(
            onTap: () async{
              if(globals.username == "anonymous"){
                pop_window("Sorry", "anonymous cannot view this Page.\n Please go to the fourth tab and log out. Then sign up a new account.", context);
              }else{
                picker();
              }

          },
            child: Icon(
            CupertinoIcons.flag,
            color: textcolor(),
          ),
        ),


        backgroundColor: backgroundcolor(),
      ),
        backgroundColor: backgroundcolor(),
        child: ListPage(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          langaugeSetFunc('Select a Location'),
          style: TextStyle(color: textcolor()),
        ),
        backgroundColor: backgroundcolor(),
        actions: <Widget>[
          popMenuButton(context),
        ],
      ),
      body: ListPage(),
    );
  }
}
