import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/globals.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'package:rental_manager/tabs/reservations.dart';
import 'package:rental_manager/tabs/help.dart';
import 'package:rental_manager/tabs/account.dart';
import 'package:rental_manager/chatview/login.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'globals.dart' as globals;
bool get isIos => foundation.defaultTargetPlatform == foundation.TargetPlatform.iOS;


class MyHome1 extends StatefulWidget {
  @override

  MyHomeState createState() => MyHomeState();
}

// SingleTickerProviderStateMixin is used for animation
class MyHomeState extends State<MyHome1> with SingleTickerProviderStateMixin {
  // Create a tab controller
  TabController controller;

  @override
  void initState() {
    super.initState();

    // Initialize the Tab Controller
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {



    if(isIos){
      return CupertinoTabScaffold(
        backgroundColor: backgroundcolor(),
          tabBar:CupertinoTabBar(
            backgroundColor: backgroundcolor(),
              items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.location, color: textcolor()), title: Text(langaugeSetFunc("Locations"), style: TextStyle(color: textcolor()),)),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.bookmark, color: textcolor(),), title: Text(langaugeSetFunc("Reservation"), style: TextStyle(color: textcolor()),)),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search,  color: textcolor(),), title: Text(langaugeSetFunc("Help"), style: TextStyle(color: textcolor()),)),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person, color: textcolor(),), title: Text(langaugeSetFunc("User Info"), style: TextStyle(color: textcolor()),))
          ]),
        tabBuilder: (context, index){
            switch(index){
              case 0:
                return FirstTab();
              case 1:
                return SecondTab();
              case 2:
                return ThirdTab();
              case 3:
                return FourthTab();
              default:
                return FirstTab();
            }
        }

      );
    }else{
      return Scaffold(
        // Appbar
        // appBar: AppBar(
        //   // Title
        //   title: Text(
        //     "Rental Manager",
        //     style:  TextStyle(
        //       fontFamily: 'Pacifico',
        //       fontSize: 20,
        //       color: Colors.white,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        //   backgroundColor: Colors.teal,
        // ),

        body: TabBarView(
          // Add tabs as widgets
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[FirstTab(), SecondTab(), ThirdTab(), FourthTab()],
          // set the controller
          controller: controller,
        ),

        bottomNavigationBar: Material(

          color: backgroundcolor(),
          child: TabBar(
            indicatorColor: Colors.black,
            labelColor: textcolor(),
            tabs: <Tab>[
              Tab(icon: Icon(Icons.location_city, color: textcolor(),), text: langaugeSetFunc('Locations'),),
              Tab(icon: Icon(Icons.book, color: textcolor() ), text:  langaugeSetFunc('Reservation')),
              Tab(icon: Icon(Icons.help,color: textcolor() ), text: langaugeSetFunc('Help'),),
              Tab(icon: Icon(Icons.account_circle,color: textcolor() ), text: langaugeSetFunc('Account'),),
            ],
            controller: controller,
          ),
        ),


      );
    }


  }
}



