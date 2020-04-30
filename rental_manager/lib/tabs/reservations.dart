import 'package:flutter/material.dart';
import 'package:rental_manager/language.dart';
import 'package:rental_manager/tabs/locations.dart';
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
        title: Text(langaugeSetFunc(widget.title), style: TextStyle(color: textcolor()),),
        backgroundColor: backgroundcolor(),
        ),
      body: ReservationListPage(),
    );
  }
}

