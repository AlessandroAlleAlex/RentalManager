import 'package:flutter/material.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'package:rental_manager/tabs/reservations.dart';
import 'package:rental_manager/tabs/help.dart';
import 'package:rental_manager/tabs/account.dart';
import 'package:rental_manager/chatview/login.dart';


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
        color: Colors.teal,
        child: TabBar(
          tabs: <Tab>[
            Tab(icon: Icon(Icons.location_city ), text: 'Locations',),
            Tab(icon: Icon(Icons.book ), text: 'Reservation',),
            Tab(icon: Icon(Icons.help ), text: 'Help',),
            Tab(icon: Icon(Icons.account_circle ), text: 'Account',),
          ],
          controller: controller,
        ),
      ),


    );
  }
}



