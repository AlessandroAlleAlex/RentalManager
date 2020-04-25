import 'package:flutter/material.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;

class changeColor extends StatefulWidget {
  @override
  _changeColorState createState() => _changeColorState();
}

class _changeColorState extends State<changeColor> {
  @override

  Widget selectTheme(String mode){
    if(globals.userSelectTheme == -1){
      if(mode == "light"){
          if(globals.dark == false) {
            return Icon(Icons.check, color: textcolor(),);
          }else{
           // return Icon(Icons.delete, color: textcolor(),);
          }
      }else if(mode == "dark"){
        if(globals.dark == false){
          //return Icon(Icons.delete, color: textcolor(),);
        }else{
          return Icon(Icons.check, color: textcolor(),);
        }
      }
    }else{
      if(mode == "systemTheme"){
        return Icon(Icons.check, color: textcolor(),);
      }else{
        //return Icon(Icons.delete, color: textcolor(),);
      }
    }

  }

  List<Widget> _getListings(BuildContext context){
    List listings = new List<Widget>();
    listings.add(
        Column(
          children: <Widget>[
            new ListTile(
              title: Text('Light', style: TextStyle(color: textcolor()),),
              trailing: selectTheme("light"),
              onTap: () async{

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isDark', false);
                await prefs.setInt('userSelectTheme', -1);

                setState(() {
                  globals.dark = false;
                  globals.userSelectTheme = -1;
                });
              },
            ),
            Divider(height: 2.0,),
          ],
        ),
    );
    listings.add(
      Column(
        children: <Widget>[
          new ListTile(
            title: Text('Dark', style: TextStyle(color: textcolor()),),
            trailing: selectTheme("dark"),
            onTap: () async{

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isDark', true);
              await prefs.setInt('userSelectTheme', -1);

              setState(() {
                globals.dark = true;
                globals.userSelectTheme = -1;
              });
            },
          ),
          Divider(height: 2.0,),
        ],
      ),
    );

    listings.add(
      Column(
        children: <Widget>[
          new ListTile(
            title: Text('By System Default Setting', style: TextStyle(color: textcolor()),),
            trailing: selectTheme("systemTheme"),
            onTap: () async {
              final Brightness brightnessValue = MediaQuery.of(context).platformBrightness;
              bool isDark = brightnessValue == Brightness.dark;
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isDark', isDark);
              await prefs.setInt('userSelectTheme', 1);

              setState(() {

                globals.dark = isDark;
                globals.userSelectTheme = 1;
              });
            },
          ),
          Divider(height: 2.0,),
        ],
      ),
    );


    return listings;

  }


  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Color', style: TextStyle(color: textcolor()),),
        backgroundColor: backgroundcolor(),
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
      ),

      backgroundColor: backgroundcolor(),
      body:  new SafeArea(
          child: Container(child: Column(children: <Widget>[

            Expanded(child:  ListView(
              padding: const EdgeInsets.all(20.0),
              children: _getListings(context), // <<<<< Note this change for the return type
            ),
            )
          ])
          ))
    );
  }
}
