import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'rate.dart';
import 'dart:core';
class myTime {
  String reservedTime;
  String pickUpTime;
  String returnTime;

  myTime(this.reservedTime, this.pickUpTime, this.returnTime);
}

int count = 0;
List<myTime> aList = [];
List<double> usedTimeList = [];
List<double>PickedUpTimeList = [];

class theItemSearch extends StatefulWidget {
  @override
  final String aname;
  List<DocumentSnapshot> documents;
  theItemSearch(this.aname, this.documents);
  _theItemSearchState createState() => _theItemSearchState();
}

class _theItemSearchState extends State<theItemSearch> {
  @override
  Widget build(BuildContext context) {
    String itemname = this.widget.aname;
    double value = 0, percentReserved = 0, copy_percentage = 0, rating = 0;
    setList();
    if (usedHours() > 0) {
      value = usedHours();
    }
    allNum();

    if (count != 0 && aList.length < count && aList.length != 0 && (aList.length / count).isNaN == false) {
      percentReserved = aList.length / count;
      copy_percentage = percentReserved;
    }

    double morningValue = 0, afternoonValue = 0, eveningValue = 0;
    double copy_morningValue = 0, copy_afternoonValue = 0, copy_eveningValue = 0;

    setPickUpTimeList();

    if(PickedUpTimeList.length == 3){
      morningValue = PickedUpTimeList[0];
      copy_morningValue = morningValue;

      afternoonValue = PickedUpTimeList[1];
      copy_afternoonValue = afternoonValue;

      eveningValue = PickedUpTimeList[2];
      copy_eveningValue = 1 - morningValue - afternoonValue;

    }

    copy_morningValue *= 100;
    copy_eveningValue *= 100;
    copy_afternoonValue *= 100;
    copy_percentage *= 100;


    String averageHourTime = value.toStringAsFixed(1),  percentReservedTime = copy_percentage.toStringAsFixed(1);
    String morningPercent = copy_morningValue.toStringAsFixed(1),
        afternoonPercent = copy_afternoonValue.toStringAsFixed(1),
        eveningPercent = copy_eveningValue.toStringAsFixed(1);
    GlobalKey theGlobalKey = new GlobalKey();
    return Scaffold(
      appBar: new AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        backgroundColor: backgroundcolor(),
        title: new Text("Usage Statistics: $itemname", style: TextStyle(color: textcolor()),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed:() async{
              //Share.share('check out my website https://example.com', subject: 'ok', image: NetworkImage(globals.UserImageUrl) );

              // If the widget was removed from the tree while the asynchronous platform
              // message was in flight, we want to discard the reply rather than calling
              // setState to update our non-existent appearance.
              RenderRepaintBoundary boundary = theGlobalKey.currentContext.findRenderObject();
              ui.Image image = await boundary.toImage();
              final directory = (await getApplicationDocumentsDirectory()).path;
              ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
              Uint8List pngBytes = byteData.buffer.asUint8List();


              try{
                await WcFlutterShare.share(
                    sharePopupTitle: 'Order Receipt',
                    fileName: 'Order Receipt.png',
                    mimeType: 'image/png',
                    bytesOfFile: pngBytes);
              }catch (e){
                print(e.toString());
              }
              print("OK");
            },
          )
        ],
      ),

      body: Center(
        child:  RepaintBoundary(
          key: theGlobalKey,
          child: ListView(children: <Widget>[
            Center(
              child: new Text(
                "$itemname Usage",
                style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            Divider(
              height: 20,
              indent: 100,
              endIndent: 100,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Center(
                    child: Text("Morning Usage",
                      style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),),
                  ),
                  Padding(
                    padding:EdgeInsets.fromLTRB(15.0, 5, 15, 15),
                    child: Wrap(
                      direction: Axis.vertical,
                      children: <Widget>[
                        new LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width * 0.618,
                          animation: true,

                          lineHeight: 20.0,
                          animationDuration: 2000,
                          percent: morningValue,
                          center: Text("$morningPercent%"),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: Colors.greenAccent,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text("Afternoon Usage",
                      style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(15.0, 5, 15, 15),
                    child: Wrap(
                      direction: Axis.vertical,
                      children: <Widget>[
                        new LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width * 0.618,
                          animation: true,

                          lineHeight: 20.0,
                          animationDuration: 2000,
                          percent: afternoonValue,
                          center: Text("$afternoonPercent%"),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: Colors.greenAccent,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text("Evening Usage",
                      style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(15.0, 5, 15, 15),
                    child: Wrap(
                      direction: Axis.vertical,
                      children: <Widget>[
                        new LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width *0.618,
                          animation: true,
                          lineHeight: 20.0,
                          animationDuration: 2000,
                          percent: eveningValue,
                          center: Text("$eveningPercent%"),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Wrap(
                      direction: Axis.vertical,
                      children: <Widget>[
                        new LinearPercentIndicator(
                          width: 140.0,
                          lineHeight: 14.0,
                          percent: 0.7,
                          leading: Text("Feedback"),
                          center: Text(
                            "70.0%",
                            style: new TextStyle(fontSize: 12.0),
                          ),
                          trailing: Icon(Icons.mood),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          backgroundColor: Colors.grey,
                          progressColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),

            Divider(
              height: 20,
              indent: 100,
              endIndent: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new CircularPercentIndicator(
                  radius: 100.0,
                  animation: true,
                  animationDuration: 2000,
                  lineWidth: 10.0,
                  percent: value / 6,
                  header: new Text(
                    "Average Hour",
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                  ),
                  center: new Text(
                    "$averageHourTime hours",
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                  ),

                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.red,
                ),
                new CircularPercentIndicator(
                  radius: 100.0,
                  lineWidth: 10.0,
                  animation: true,
                  animationDuration: 2000,
                  percent: percentReserved,
                  header: new Text(
                    "Preference",
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                  ),
                  center: new Text(
                    "$percentReservedTime%",
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                  ),

                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.purple,
                ),
              ],
            ),


          ]),
        ),
      ),
    );
  }

  void setList(){
    var documents = this.widget.documents;

    aList.clear();

    for (int i = 0; i < documents.length; i++) {
      var ds = documents[i];
      print(ds["picked Up time"] == "NULL");
      if (ds["name"] == this.widget.aname) {
        if(ds["reserved time"] == "NULL"|| ds["picked Up time"] == "NULL" || ds["return time"] == "NULL" ){
          continue;
        }
        try{
          aList.add(myTime(
            ds["reserved time"],
            ds["picked Up time"],
            ds["return time"],
          ));
        }catch(e){
          print(e);
        }

      }
    }

    print(this.widget.aname);
    for (int i = 0; i < aList.length; i++) {
      print(aList[i].reservedTime);
      if(aList[i].reservedTime == null){
        aList.removeAt(i);
      }
    }
  }

  double usedHours() {
    usedTimeList.clear();
    double sum = 0, a = 0;
    for (int i = 0; i < aList.length; i++) {
      var PickedUpTime = DateTime.parse(aList[i].pickUpTime);
      var ReturnedTime = DateTime.parse(aList[i].returnTime);

      int difference = ReturnedTime.difference(PickedUpTime).inSeconds;

      double hours_dir = difference / 3600;
      if (hours_dir > 0) {
        usedTimeList.add(hours_dir);
        sum += hours_dir;
      }
    }

    a = sum / usedTimeList.length;
    return a;
  }

  void allNum(){
    var documents = this.widget.documents;

    count = documents.length;
  }

  void setPickUpTimeList(){
    PickedUpTimeList.clear();

    int morning = 0, afternoon = 0, evening = 0;
    for(int i = 0 ; i < aList.length; i++){
      var PickUpTime = DateTime.parse(aList[i].pickUpTime);
      if(PickUpTime.hour >=  6 && PickUpTime.hour < 12){
        morning += 1;
      }else if(PickUpTime.hour >= 12 && PickUpTime.hour < 18){
        afternoon += 1;
      }else{
        evening += 1;
      }
    }

    double morningValue = morning / aList.length;
    double afternoonValue = afternoon / aList.length;
    double eveningValue = evening/ aList.length;

    if(morning != 0 || evening != 0 || afternoon != 0){
      PickedUpTimeList.add(morningValue);
      PickedUpTimeList.add(afternoonValue);
      PickedUpTimeList.add(eveningValue);
    }
  }
}
