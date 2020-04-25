import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_page.dart';
import 'custom_gridcell.dart';

class ItemPage extends StatefulWidget {
  String category;
  ItemPage({this.category});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return _ItemPageState();
  }
}

class _ItemPageState extends State<ItemPage> {
  navigateToDetail(DocumentSnapshot indexedData) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailPage(itemSelected: indexedData)));
  }

  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Category Selected: ${widget.category}'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(widget.category),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder(

          stream: Firestore.instance
              .collection('ARC_items')
              .where('category', isEqualTo: widget.category)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('loading...');
            // print(snapshot.data.documents.length);
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) => ListTile(
                title: Text(
                    snapshot.data.documents[index].data['name'].toString()),
                subtitle: Text(
                    'Total amount: ${snapshot.data.documents[index].data['# of items'].toString()}'),
                onTap: () {
                  navigateToDetail(snapshot.data.documents[index]);
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
  final String category;
  CustomSearchDelegate(this.category); // constructor

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
    print(category);
    return StreamBuilder(
        stream: Firestore.instance
            .collection('ARC_items')
            .where('category', isEqualTo: category)
            .snapshots(),
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
