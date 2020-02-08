import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class CustomCell extends StatelessWidget {
  var categoryInfo;
  CustomCell(this.categoryInfo);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(categoryInfo['imageURL']),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  categoryInfo['name'],
                  maxLines: 1,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
