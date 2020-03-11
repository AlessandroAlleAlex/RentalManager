import 'package:flutter/Material.dart';
import 'package:rental_manager/Locations/ItemDetails.dart';
class CategoryRouteLibrary extends StatelessWidget {
  final String data;

  CategoryRouteLibrary({
    Key key,
    @required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Available items in Library",
            style:  TextStyle(
              fontFamily: 'Source Sans Pro',
              // color: Colors.teal,
              // backgroundColor: Colors.teal,
            ),
          ),

          backgroundColor: Colors.teal,
        ),
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return StuffInTiles(listOfTiles[index]);
          },
          itemCount: listOfTiles.length,
        ));
  }
}

class StuffInTiles extends StatelessWidget {
  final MyTile myTile;
  BuildContext context;
  StuffInTiles(this.myTile);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    this.context = context;
    return _buildTiles(myTile);
  }

  Widget _buildTiles(MyTile t) {
    if (t.children.isEmpty) {
      return ListTile(
        title: Text(t.title),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ItemDetails(data: 'Selected ' + t.title + '!'),
            ),
          );
        },
      );
    }
    return ExpansionTile(
      key: PageStorageKey<MyTile>(t),
      title: Text(t.title),
      children: t.children.map(_buildTiles).toList(),
    );
  }
}

class MyTile {
  String title;
  BuildContext context;
  List<MyTile> children;
  MyTile(this.title, [this.children = const <MyTile>[]]);
}

List<MyTile> listOfTiles = <MyTile>[
  MyTile('Chargers', <MyTile>[
    MyTile('Charging Lockers',
        <MyTile>[MyTile('001'), MyTile('002'), MyTile('003')]),
    MyTile('Portable Battery Packs', <MyTile>[MyTile('001'), MyTile('002'), MyTile('003'), MyTile('005')]),
    MyTile('Power Adapter', <MyTile>[MyTile('001'), MyTile('002'), MyTile('003'), MyTile('005')]),
    MyTile('Power Cords'),
  ]),
    MyTile('Calculators',),
];
