import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/SignUp/sign_up.dart';

class OrganizationSelection extends StatefulWidget {
  @override
  _OrganizationSelectionState createState() => _OrganizationSelectionState();
}

class _OrganizationSelectionState extends State<OrganizationSelection> {
  Future navigateToSignUp(String orgSelected, BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage(organization: orgSelected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select an oganization'),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () => print('add clicked'),
            icon: Icon(Icons.add),
            label: Text('Add'),
          ),
          FlatButton.icon(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
            icon: Icon(Icons.search),
            label: Text('Search'),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('organizations').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: Text('Loading...'));

            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) => ListTile(
                // title: Text(results.length.toString()),
                title: Text(
                  snapshot.data.documents[index].data['name'].toString(),
                ),
                onTap: () {
                  navigateToSignUp(
                      snapshot.data.documents[index].data['name'].toString(),
                      context);
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
  Future navigateToSignUp(String orgSelected, BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage(organization: orgSelected),
      ),
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
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('organizations').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: Text('Loading...'));
          var results = snapshot.data.documents
              .where(
                (DocumentSnapshot doc) =>
                    doc.data['name'].toString().toLowerCase().contains(
                          query.trim().toLowerCase(),
                        ),
              )
              .toList();
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) => ListTile(
              // title: Text(results.length.toString()),
              title: Text(results[index]['name'].toString()),
              onTap: () =>
                  navigateToSignUp(results[index]['name'].toString(), context),
            ),
          );
        });
  }
}
