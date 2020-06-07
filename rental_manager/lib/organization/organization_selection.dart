import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rental_manager/SignUp/sign_up.dart';
import 'package:rental_manager/organization/add_organization.dart';
import 'package:rental_manager/globals.dart' as globals;

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

  Future inputDialog(BuildContext context) {
    TextEditingController inputText = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Create New Organization'),
            content: TextField(
                decoration:
                    InputDecoration(hintText: 'enter organization name'),
                controller: inputText,
                keyboardType: TextInputType.text),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue,
                onPressed: () {
                  // String noSpaceInput =
                  //     inputText.text.trim().replaceAll(' ', '');
                  String noSpaceInput = inputText.text.trim();
                  String compateInput =
                      noSpaceInput.toLowerCase().trim().replaceAll(' ', '');
                  List<String> toLowerList = [];
                  for (String s in globals.existingOrganizations) {
                    toLowerList.add(s.toLowerCase().trim().replaceAll(' ', ''));
                  }
                  if (!toLowerList.contains(compateInput)) {
                    Navigator.of(context).pop(noSpaceInput);
                  } else {
                    exisitDialog(context);
                  }
                },
                child: Text('add'),
                elevation: 0.0,
              )
            ],
          );
        });
  }

  Future exisitDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Error Message:',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: Text('the organization already exist.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child:
                      Text('OK', style: TextStyle(fontWeight: FontWeight.bold)))
            ],
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select an Organization'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              inputDialog(context).then((newOrganization) async {
                if (newOrganization != null && newOrganization != '') {
                  // await addOrganization(newOrganization.toString());
                  navigateToSignUp(newOrganization.toString(), context);
                }
              });
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('organizations').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: Text('Loading...'),
              );
            globals.existingOrganizations.clear();
            snapshot.data.documents.forEach((doc) {
              globals.existingOrganizations.add(doc['name']);
            });

            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) => ListTile(
                // title: Text(results.length.toString()),
                title: Center(
                  child: Text(
                    snapshot.data.documents[index].data['name'].toString(),
                    style: TextStyle(fontSize: 20, color: Colors.teal),
                  ),
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
              title: Center(
                child: Text(
                  results[index]['name'].toString(),
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
              ),
              onTap: () =>
                  navigateToSignUp(results[index]['name'].toString(), context),
            ),
          );
        });
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
              title: Center(
                child: Text(
                  results[index]['name'].toString(),
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
              ),
              onTap: () =>
                  navigateToSignUp(results[index]['name'].toString(), context),
            ),
          );
        });
  }
}
