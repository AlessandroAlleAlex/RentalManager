// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_manager/tabs/locations.dart';
import 'detail_page.dart';
import 'custom_gridcell.dart';
import 'package:rental_manager/globals.dart' as globals;
class showAll extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _showAllState();
  }
}

String returnItemCollection(){

  return '${globals.organization}_items';
}

String returnReservationCollection(){

  return '${globals.organization}_reservations';
}

String returnUserCollection(){
  return 'global_users';
}

String returnLocationsCollection(){
  return '${globals.organization}_locations';
}



class _showAllState extends State<showAll> {
  navigateToDetail(DocumentSnapshot indexedData, context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailPage(itemSelected: indexedData)));
  }



  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textcolor(), //change your color here
        ),
        title: Text('All Items', style: TextStyle(color: textcolor()),),
        backgroundColor: backgroundcolor(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection(returnItemCollection()).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('loading...');

            return ListView.builder(
              reverse: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) => ListTile(
                title: Text(
                    snapshot.data.documents[index].data['name'].toString()),
                subtitle: Text(
                    'Total amount: ${snapshot.data.documents[index].data['# of items'].toString()}'),
                onTap: () {
                  navigateToDetail(snapshot.data.documents[index], context);
                  // testingReservations(
                  //     snapshot.data.documents[index].documentID);
                },
              ),
            );
          }),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  navigateToDetail(DocumentSnapshot indexedData, context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailPage(itemSelected: indexedData)));
  }

  displayGrids(data, context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              children: data.map<Widget>(
                (categoryInfo) {
                  return GestureDetector(
                    child: GridTile(
                      child: CustomCell(categoryInfo),
                    ),
                    onTap: () {
                      // print("tapped ${categoryInfo.toString()}");
                      navigateToDetail(categoryInfo, context);
                    },
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return StreamBuilder(
        stream: Firestore.instance.collection(returnReservationCollection()).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('loading...');
          // print(snapshot.data.documents.length);
          final results = snapshot.data.documents.where(
            (DocumentSnapshot a) =>
                a.data['name'].toString().toLowerCase().contains(
                      query.trim().toLowerCase(),
                    ),
          );
          return displayGrids(results, context);
        });
  }
}
