
import 'dart:async';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/services.dart';
import 'package:rental_manager/Locations/show_all.dart';
import 'package:rental_manager/language.dart';

import '../CurrentReservation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../reservations/reservationCell.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../globals.dart' as globals;

class ReservationListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ReservationListPage();
  }
}

class _ReservationListPage extends State<ReservationListPage> {
  Future getFirestoreData() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final userID = globals.uid;
    final firestore = Firestore.instance;
    QuerySnapshot itemListDOC = await firestore
        .collection(returnReservationCollection())
        .where('uid', isEqualTo: userID)
        .where('status', isEqualTo: 'Reserved')
        .getDocuments();
    return itemListDOC.documents;
  }

  navigateToDetail(DocumentSnapshot indexedData) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                reservationCell(passedFirestoreData: indexedData)));
  }

  @override
  Widget build(BuildContext context) {



    return FutureBuilder(
      future: getFirestoreData(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text(langaugeSetFunc('Loading...')),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data.length,
            // add change here make the itemBuilder return Dismissible type
            itemBuilder: (context, index) {
              // print(snapshot.data[index]['name'].toString());
              return Container(
                // padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 3.0),
                  borderRadius: BorderRadius.all(Radius.circular(
                      40.0) //                 <--- border radius here
                  ),
                ),
                child: ListTile(
                  leading: Icon(Icons.timer, size: 35.0),
                  trailing: Icon(Icons.arrow_forward, size: 28.0),
                  onTap: () async{
                    print(123);

                    navigateToDetail(snapshot.data[index]);
                  },
                  title: Text(
                    snapshot.data[index]['name'],
                    style: TextStyle(fontSize: 20.0),
                  ),
                  subtitle: Text( parseTime(snapshot.data[index]['startTime']) +
                      ' - quantity: ' +
                      snapshot.data[index]['amount']),
                ),
              );
            },
          );
        }
      },
    );
  }

// TODO: implement build
// add for the refresh page
// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//     GlobalKey<RefreshIndicatorState>();
// Future<void> _handleRefresh() {
//   final Completer<void> completer = Completer<void>();
//   Timer(const Duration(seconds: 1), () {
//     completer.complete();
//   });
//   return completer.future.then<void>((_) {
//     _scaffoldKey.currentState?.showSnackBar(SnackBar(
//         content: const Text('Refresh complete'),
//         action: SnackBarAction(
//             label: 'RETRY',
//             onPressed: () {
//               _refreshIndicatorKey.currentState.show();
//             })));
//   });
// }

// add CancelReservation buttoon
// Future<void> CancelReservation(String jobId) {
//   return Firestore.instance
//       .collection('reservation')
//       .document(jobId)
//       .delete();
// }

// return Container(
//     child: FutureBuilder(
//         future: getFirestoreData(),
//         builder: (_, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: Text('Loading...'),
//             );
//           } else {
//             return LiquidPullToRefresh(
//               color: Colors.black,
//               showChildOpacityTransition: false,
//               key: _refreshIndicatorKey, // key if you want to add
//               onRefresh: _handleRefresh,
//               child: ListView.builder(
//                   itemCount: snapshot.data.length,
//                   // add change here make the itemBuilder return Dismissible type
//                   itemBuilder: (context, index) {
//                     return Dismissible(
//                       background: stackBehindDismiss(),
//                       onDismissed: (DismissDirection direction) {
//                         setState(() {
//                           try {
//                             print('cancel called...................');
//                             print(snapshot.data[index].documentID);
//                             CancelReservation(
//                                 snapshot.data[index].documentID);
//                           } catch (e) {
//                             print(e);
//                             print('error...................');
//                           }
//                         });
//                       },
//                       key: ObjectKey(snapshot.data[index]),
//                       child: customCell(index, snapshot),
//                     );
//                   }),
//             );
//           }
//         }));
}

// Widget stackBehindDismiss() {
//   return Container(
//     alignment: Alignment.centerRight,
//     padding: EdgeInsets.only(right: 20.0),
//     color: Colors.red,
//     child: Icon(
//       Icons.delete,
//       color: Colors.white,
//     ),
//   );
// }

String lala;
String getItemName(String id) {
  String res = "";
  DocumentReference itemRef =
  Firestore.instance.collection("items").document(id);
  itemRef.get().then((datasnapshot) {
    //print(datasnapshot.data);
    if (datasnapshot.data.containsKey('name')) {
      print(datasnapshot.data['name']);
      // lala = datasnapshot.data['name'].toString();
      res = datasnapshot.data['name'].toString();
    } else {
      // lala = "null";
      // lala = "null";
      res = "null";
      print("No such item in database!?");
    }
  });
  return res;
}

// Widget customCell(int index, AsyncSnapshot snapshot) {
//   String res = "lalalalala";
//   // getItemName(snapshot.data[index].data['item']);
//   // print("Got this: " + lala);
//   Future<String> getFirestoreItemData() async {
//     // final firestoreItem = Firestore.instance;
//     DocumentReference itemListDOC = Firestore.instance
//         .collection("items")
//         .document(snapshot.data[index].data['item']);
//     itemListDOC.get().then((datasnapshot) {
//       //print(datasnapshot.data);
//       if (datasnapshot.data.containsKey('name')) {
//         // print(datasnapshot.data['name']);
//         return datasnapshot.data['name'].toString();
//       } else {
//         return "null1";
//         print("No such item in database!?");
//       }
//     });
//     return "null3";
//     // return res;
//   }

//   if (snapshot.data[index].data["uid"] != globals.uid) {
//     return null;
//   }

//   return Material(
//     child: InkWell(
//       onTap: () => navigateToDetail(snapshot.data[index]),
//       child: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey,
//               blurRadius: 10.0,
//             ),
//           ],
//         ),
//         child: Card(
//           child: Container(
//             child: Padding(
//               padding: const EdgeInsets.all(30.0),
//               child: Column(
//                 children: <Widget>[
//                   // FutureBuilder(
//                   // future: getFirestoreItemData(),
//                   // builder: (_, stringItem)
//                   // ),
//                   Row(
//                     children: <Widget>[
//                       Stack(
//                         children: <Widget>[
//                           Column(
//                             children: <Widget>[
//                               Text(
//                                 // getItemName(snapshot.data[index].data['item']),
//                                 // res,
//                                 // getFirestoreItemData().toString(),
//                                 snapshot.data[index].data['name'],
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 snapshot.data[index].data['startTime'],
//                                 // 'Reservation Cell',
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   // fontWeight: FontWeight.bold,
//                                   color: Colors.purple,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Spacer(),
//                       Stack(
//                         children: <Widget>[
//                           Text(
//                             'Status',
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.teal,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }

//import 'dart:async';
//
//import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import '../reservations/reservationCell.dart';
//import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
//import '../globals.dart' as globals;
//
//class ReservationListPage extends StatefulWidget {
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return _ReservationListPage();
//  }
//}
//
//Future getFirestoreData() async {
//  final firestore = Firestore.instance;
//  QuerySnapshot itemListDOC =
//  await firestore.collection(globals.collectionName).getDocuments();
//  print(itemListDOC.documents);
//  globals.myds = itemListDOC.documents;
//  return globals.myds;
//
//}
//
//
//class _ReservationListPage extends State<ReservationListPage> {
//
//
//  navigateToDetail(DocumentSnapshot indexedData) {
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (context) =>
//                reservationCell(passedFirestoreData: indexedData)));
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    // add for the refresh page
//    globals.mycontext = context;
//    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
//    Future<void> _handleRefresh() async {
//      final Completer<void> completer = Completer<void>();
//      Timer(const Duration(seconds: 1), () {
//        completer.complete();
//      });
//      await getFirestoreData();
//      return completer.future.then<void>((_) {
//        _scaffoldKey.currentState?.showSnackBar(SnackBar(
//            content: const Text('Refresh complete'),
//            action: SnackBarAction(
//                label: 'RETRY',
//                onPressed: () {
//                  _refreshIndicatorKey.currentState.show();
//                  setState(() {
//                    getFirestoreData();
//                  });
//
//                })));
//      });
//    }
//
//    // add CancelReservation buttoon
//    Future<void> CancelReservation(String jobId){
//      return Firestore.instance.collection(globals.collectionName).document(jobId).delete();
//    }
//    int count =  1;
//    setState(() {
//      count += 1;
//    });
//
//
//    return Container(
//        child: FutureBuilder(
//            future: getFirestoreData(),
//            builder: (_, snapshot) {
//              if (snapshot.connectionState == ConnectionState.waiting) {
//                return Center(
//                  child: Text('Loading...'),
//                );
//              } else {
//                return LiquidPullToRefresh(
//                  color: Colors.teal,
//                  showChildOpacityTransition: false,
//                  key: _refreshIndicatorKey,	// key if you want to add
//                  onRefresh: _handleRefresh,
//                  child: ListView.builder(
//                      itemCount: snapshot.data.length,
//                      // add change here make the itemBuilder return Dismissible type
//                      itemBuilder: (context,index) {
//                        return Dismissible(
//                          direction: DismissDirection.endToStart,
//
//                          background: stackBehindDismiss1(),
//                          onDismissed: (DismissDirection direction){
//                            setState(() {
//                             try{
//                                print(snapshot.data[index].documentID);
//                                CancelReservation(snapshot.data[index].documentID);
//                             }catch(e){
//                               print(e);
//                             }
//                            });
//                          },
//                          confirmDismiss:(DismissDirection direction) async{
//                            print(1111);
//
//                            var a = false;
//                            return a;
//                          },
//                          key: ObjectKey(snapshot.data[index]),
//                          child: customCell(index, snapshot),
//
//                        );
//                      }
//                  ),
//                );
//
//              }
//            }));
//  }
//
//  Widget stackBehindDismiss1() {
//    return Container(
//      alignment: Alignment.centerRight,
//      padding: EdgeInsets.only(right: 70.0),
//      color: Colors.grey,
//       child:  Icon(
//         Icons.delete,
//         size: 60,
//         color: Colors.yellow,
//       ),
//    );
//  }
//
//  Widget stackBehindDismiss2() {
//    return Container(
//      alignment: Alignment.centerRight,
//      padding: EdgeInsets.only(right: 30.0),
//      color: Colors.red,
//      child:
//        Icon(
//          Icons.delete,
//          size: 30,
//          color: Colors.white,
//        ),
//
//    );
//  }
//
//  String lala;
//  String getItemName(String id) {
//    String res = "";
//    DocumentReference itemRef =
//        Firestore.instance.collection("items").document(id);
//    itemRef.get().then((datasnapshot) {
//      //print(datasnapshot.data);
//      if (datasnapshot.data.containsKey('name')) {
//        print(datasnapshot.data['name']);
//        // lala = datasnapshot.data['name'].toString();
//        res = datasnapshot.data['name'].toString();
//      } else {
//        // lala = "null";
//        // lala = "null";
//        res = "null";
//        print("No such item in database!?");
//      }
//    });
//    return res;
//  }
//
//  Widget customCell(int index, AsyncSnapshot snapshot) {
//    String res = "lalalalala";
//    // getItemName(snapshot.data[index].data['item']);
//    // print("Got this: " + lala);
//    Future<String> getFirestoreItemData() async {
//      // final firestoreItem = Firestore.instance;
//      DocumentReference itemListDOC = Firestore.instance
//          .collection("items")
//          .document(snapshot.data[index].data['item']);
//      itemListDOC.get().then((datasnapshot) {
//        //print(datasnapshot.data);
//        if (datasnapshot.data.containsKey('name')) {
//          // print(datasnapshot.data['name']);
//          return datasnapshot.data['name'].toString();
//        } else {
//          return "null1";
//          print("No such item in database!?");
//        }
//      });
//
//      return "null3";
//      // return res;
//    }
//
//
//    if(snapshot.data[index].data["uid"] != globals.uid && snapshot.data[index].data["status"] != "Returned"){
//      return null;
//    }
//
//    return Material(
//      child: InkWell(
//        onTap: () => navigateToDetail(snapshot.data[index]),
//        child: Container(
//          decoration: BoxDecoration(
//            boxShadow: [
//              BoxShadow(
//                color: Colors.grey,
//                blurRadius: 10.0,
//              ),
//            ],
//          ),
//          child: Card(
//            child: Container(
//              child: Padding(
//                padding: const EdgeInsets.all(30.0),
//                child: Column(
//                  children: <Widget>[
//                    // FutureBuilder(
//                    // future: getFirestoreItemData(),
//                    // builder: (_, stringItem)
//                    // ),
//                    Row(
//                      children: <Widget>[
//                        Stack(
//                          children: <Widget>[
//                            Column(
//                              children: <Widget>[
//                                Text(
//                                  // getItemName(snapshot.data[index].data['item']),
//                                  // res,
//                                  // getFirestoreItemData().toString(),
//                                  snapshot.data[index].data['name'],
//                                  style: TextStyle(
//                                    fontSize: 20,
//                                    fontWeight: FontWeight.bold,
//                                  ),
//                                ),
//                                Text(
//                                  snapshot.data[index].data['startTime'],
//                                  // 'Reservation Cell',
//                                  style: TextStyle(
//                                    fontSize: 15,
//                                    // fontWeight: FontWeight.bold,
//                                    color: Colors.purple,
//                                  ),
//                                ),
//                              ],
//                            ),
//                          ],
//                        ),
//                        Spacer(),
//                        Stack(
//                          children: <Widget>[
//                            Text(
//                              'Status',
//                              style: TextStyle(
//                                fontSize: 10,
//                                color: Colors.teal,
//                              ),
//                            ),
//                          ],
//                        ),
//                      ],
//                    ),
//                  ],
//                ),
//              ),
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//}
//
//
//
