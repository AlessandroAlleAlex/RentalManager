import 'package:flutter/material.dart';

class ItemDetails extends StatelessWidget {
  final String data;

  ItemDetails({
    Key key,
    @required this.data,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var num = 2;
    var totalnum = 10;
    var TimeLimit = "4 hr";
    var MaxAmount = "10";
    var Location = "Gym";
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(data),
         backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Item Information',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    color: Colors.teal,
                    fontSize: 30,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  height: 20,
                  width: 200,
                  child: Divider(
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  '· TimeLimit: $TimeLimit',
                  style: TextStyle(
                    fontFamily: 'Source Sans Pro',
                    color: Colors.teal,
                    fontSize: 20,
                    letterSpacing: 2.5,
                  ),

                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  '· MaxAmount: $MaxAmount',
                  style: TextStyle(
                    fontFamily: 'Source Sans Pro',
                    color: Colors.teal,
                    fontSize: 20,
                    letterSpacing: 2.5,
                  ),

                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  '· Location: $Location',
                  style: TextStyle(
                    fontFamily: 'Source Sans Pro',
                    color: Colors.teal,
                    fontSize: 20,
                    letterSpacing: 2.5,
                  ),

                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  'Available Item: ',
                  style: TextStyle(
                    color: Colors.teal,
                    fontFamily: 'Pacifico',
                    fontSize: 25,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  '$num/$totalnum',
                  style: TextStyle(
                    color: Colors.teal,
                    fontFamily: 'Source Sans Pro',
                    fontSize: 25,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  'Time Left To Pick Up: ',
                  style: TextStyle(
                    color: Colors.teal,
                    fontFamily: 'Pacifico',
                    fontSize: 25,
                  ),
                ),
                Text(
                  '10 minutes',
                  style: TextStyle(
                    color: Colors.teal,
                    fontFamily: 'Source Sans Pro',
                    fontSize: 25,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            MaterialButton(
              minWidth: 140,
              height: 50,
              color: Colors.teal,
              highlightColor: Colors.grey,

              splashColor: Colors.teal,

              highlightElevation: 2,
              onPressed: () {
                print("Reserve");
              },
              child: Text(
                'Reserve',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            MaterialButton(
              minWidth: 140,
              height: 50,
              color: Colors.teal,
              splashColor: Colors.redAccent,
              onPressed: () {
                print("Cancel");
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
