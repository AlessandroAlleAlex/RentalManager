import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class reservationCell extends StatefulWidget {
  final DocumentSnapshot passedFirestoreData;
  reservationCell({this.passedFirestoreData});
  @override
  State<StatefulWidget> createState() {
    print(passedFirestoreData.data);

    // TODO: implement createState
    return _reservationCell();
  }
}
// List lala = passedFirestoreData.data['categories']
//                     .map<String>((categoryInfo) {
//                   return GridTile(
//                     child: CustomCell(categoryInfo),
//                   );
//                 }).toList(),

class _reservationCell extends State<reservationCell> {
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
        title: Text('Reservation Details'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Item Information',
                  style: TextStyle(
                    fontFamily: '',
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
                  '· Item Name: ${widget.passedFirestoreData.data["name"]}',
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
                  '· Amount: ${widget.passedFirestoreData.data["amount"]}',
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
                  '· Status: ${widget.passedFirestoreData.data["status"]}',
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
            //  Row(
            //   children: <Widget>[
            //     Text(
            //       '· User ID: ${widget.passedFirestoreData.data["uid"]}',
            //       style: TextStyle(
            //         fontFamily: 'Source Sans Pro',
            //         color: Colors.teal,
            //         fontSize: 20,
            //         letterSpacing: 2.5,
            //       ),

            //     ),
            //   ],
            // ),
            Row(
              children: <Widget>[
                SizedBox(
                  height: 50,
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
              children: <Widget>[
                Text(
                  '  Time Left To Pick Up: ',
                  style: TextStyle(
                    color: Colors.teal,
                    fontFamily: 'Source Sans Pro',
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
                print("Cancel Reservation");
              },
              child: Text(
                'Cancel Reservation',
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
