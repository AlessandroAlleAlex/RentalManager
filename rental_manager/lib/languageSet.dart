import 'package:flutter/material.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'package:devicelocale/devicelocale.dart';

int systemLanguage = -1;
class languageSetting extends StatefulWidget {
  @override
  _languageSettingState createState() => _languageSettingState();
}

class _languageSettingState extends State<languageSetting> {
  @override

  Widget selectLanguage(String getlanguage){
    if( systemLanguage == -1){
      print("1");
      if(getlanguage == "English"){
         if(globals.langaugeSet == "English"){
           return Icon(Icons.check, color: textcolor(),);
         }
      }else if(getlanguage == "SimplifiedChinese"){
        if(globals.langaugeSet == "SimplifiedChinese" ){
          return Icon(Icons.check, color: textcolor(),);
        }
      }
    }else{
      if(getlanguage == "By system Defaulting Setting"){
        return Icon(Icons.check, color: textcolor(),);
      }else{

      }
    }

  }

  List<Widget> _getListings(BuildContext context){
    List listings = new List<Widget>();
    listings.add(
      Column(
        children: <Widget>[
          new ListTile(
            title: Text("English", style: TextStyle(color: textcolor()),),
            trailing: selectLanguage("English"),
            onTap: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('mylanguage', "English");

              setState(() {
               globals.langaugeSet = "English";
               systemLanguage = -1;

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
            title: Text('简体中文', style: TextStyle(color: textcolor()),),
            trailing: selectLanguage("SimplifiedChinese"),
            onTap: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('mylanguage', "SimplifiedChinese");
              setState(() {
                globals.langaugeSet = "SimplifiedChinese";
                systemLanguage = -1;
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
            title: Text(langaugeSetFunc('By system Defaulting Setting'), style: TextStyle(color: textcolor()),),
            trailing: selectLanguage("By system Defaulting Setting"),
            onTap: () async{
              List languages = await Devicelocale.preferredLanguages;
              print(languages[0]);
              setState(() {
                if(languages[0].toString().contains("en")){
                 systemLanguage = 1;
                 globals.langaugeSet = "English";
                }else if(languages[0].toString().contains("zh-Hans")){
                  systemLanguage = 1;
                  globals.langaugeSet = "SimplifiedChinese";
                }else{
                  systemLanguage = 1;
                  globals.langaugeSet = "English";
                }
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('mylangauge', globals.langaugeSet);

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
          title: Text(langaugeSetFunc("Language Setting"), style: TextStyle(color: textcolor()),),
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
