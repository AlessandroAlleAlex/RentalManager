import 'package:flutter/material.dart';
import '../reservations/reservationList.dart';
class SecondTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: reservationPage(title: 'Reservations'),
    );
  }
}

class reservationPage extends StatefulWidget {
  final String title;
  reservationPage({Key key, this.title}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _reservationPageState();
  }
}

class _reservationPageState extends State<reservationPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.teal,
        ),
      body: ReservationListPage(),
    );
  }
}


//RICK's Previous Version, updated in ReservationCell.dart
//   Widget build(BuildContext context) {
// class SecondTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var num = 2;
//     var totalnum = 10;
//     var TimeLimit = "4 hr";
//     var MaxAmount = "10";
//     var Location = "Gym";
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Column(
//             children: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   Text(
//                     'Item Information',
//                     style: TextStyle(
//                       fontFamily: 'Pacifico',
//                       color: Colors.teal,
//                       fontSize: 30,
//                       letterSpacing: 2.5,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: <Widget>[
//                   SizedBox(
//                     height: 10,
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   SizedBox(
//                     height: 20,
//                     width: 200,
//                     child: Divider(
//                       color: Colors.teal,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: <Widget>[
//                   Text(
//                     '· TimeLimit: $TimeLimit',
//                     style: TextStyle(
//                       fontFamily: 'Source Sans Pro',
//                       color: Colors.teal,
//                       fontSize: 20,
//                       letterSpacing: 2.5,
//                     ),

//                   ),
//                 ],
//               ),
//               Row(
//                 children: <Widget>[
//                   Text(
//                     '· MaxAmount: $MaxAmount',
//                     style: TextStyle(
//                       fontFamily: 'Source Sans Pro',
//                       color: Colors.teal,
//                       fontSize: 20,
//                       letterSpacing: 2.5,
//                     ),

//                   ),
//                 ],
//               ),
//               Row(
//                 children: <Widget>[
//                   Text(
//                     '· Location: $Location',
//                     style: TextStyle(
//                       fontFamily: 'Source Sans Pro',
//                       color: Colors.teal,
//                       fontSize: 20,
//                       letterSpacing: 2.5,
//                     ),

//                   ),
//                 ],
//               ),
//               Row(
//                 children: <Widget>[
//                   SizedBox(
//                     height: 100,
//                   ),
//                 ],
//               ),
//               Row(
//                 children: <Widget>[
//                   Text(
//                     'Available Item: ',
//                     style: TextStyle(
//                       color: Colors.teal,
//                       fontFamily: 'Pacifico',
//                       fontSize: 25,
//                       letterSpacing: 2.5,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                   Text(
//                     '$num/$totalnum',
//                     style: TextStyle(
//                       color: Colors.teal,
//                       fontFamily: 'Source Sans Pro',
//                       fontSize: 25,
//                       letterSpacing: 2.5,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: <Widget>[
//                   SizedBox(
//                     height: 100,
//                   ),
//                 ],
//               ),
//               Row(
//                 children: <Widget>[
//                   Text(
//                     'Time Left To Pick Up: ',
//                     style: TextStyle(
//                       color: Colors.teal,
//                       fontFamily: 'Pacifico',
//                       fontSize: 25,
//                     ),
//                   ),
//                   Text(
//                     '10 minutes',
//                     style: TextStyle(
//                       color: Colors.teal,
//                       fontFamily: 'Source Sans Pro',
//                       fontSize: 25,
//                       letterSpacing: 2.5,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: <Widget>[
//                   SizedBox(
//                     height: 20,
//                   ),
//                 ],
//               ),
//               MaterialButton(
//                 minWidth: 140,
//                 height: 50,
//                 color: Colors.teal,
//                 highlightColor: Colors.grey,

//                 splashColor: Colors.teal,

//                 highlightElevation: 2,
//                 onPressed: () {
//                   print("Reserve");
//                 },
//                 child: Text(
//                   'Reserve',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                   ),
//                 ),
//               ),
//               Row(
//                 children: <Widget>[
//                   SizedBox(
//                     height: 20,
//                   ),
//                 ],
//               ),
//               MaterialButton(
//                 minWidth: 140,
//                 height: 50,
//                 color: Colors.teal,
//                 splashColor: Colors.redAccent,
//                 onPressed: () {
//                   print("Cancel");
//                 },
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }