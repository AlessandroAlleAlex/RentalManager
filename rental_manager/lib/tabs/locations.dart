import 'package:flutter/material.dart';
import 'package:rental_manager/Locations/arc.dart';
import 'package:rental_manager/Locations/library.dart';
//import 'package:rental_manager/Locations/library.dart';

class FirstTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Text(
                'Available Resources Locations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: <Widget>[
                  Text(
                    'The arc',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Pacifico',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              MaterialButton(
                onPressed: (){
                  print("Press arc");
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryRouteArc()));
                },
                child: Container(
                  width: 1100.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: AssetImage('images/arc.png'),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'The Memorial Union',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Pacifico',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              MaterialButton(
                onPressed: (){
                  print("Press MU");
                },
                child: Container(
                  width: 1100.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: AssetImage('images/mu.png'),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Peter Shields Library',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Pacifico',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              MaterialButton(
                onPressed: (){
                  print("Press Library");
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryRouteLibrary()));
                },
                child: Container(
                  width: 1100.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: AssetImage('images/library.png'),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}