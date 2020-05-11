import 'package:cloud_firestore/cloud_firestore.dart';

Future addOrganization(String newOrganization) async {
  await Firestore.instance
      .collection('organizations')
      .document()
      .setData({'name': newOrganization});
}
