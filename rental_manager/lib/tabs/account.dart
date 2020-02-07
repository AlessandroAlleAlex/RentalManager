import 'package:flutter/material.dart';
import '../globals.dart' as globals;
class FourthTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('images/appstore.png'),
                  ),
                  Text(
                    globals.username,
                    style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      color: Colors.teal,
                      fontSize: 20,
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Your Score: xxx',
                    style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      color: Colors.teal.shade900,
                      fontSize: 20,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                    width: 170,
                    child: Divider(
                      color: Colors.teal.shade100,
                    ),
                  ),
                ],
              ),
              Container(
                padding:EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: Colors.teal,
                child: FlatButton(
                  onPressed: (){
                    print('Current Reservation');
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.book,
                            color: Colors.white,
                          ),
                          Text(
                              'Current Reservation',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                          Text(
                              '>>',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 1,
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding:EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: Colors.teal,
                child: FlatButton(
                  onPressed: (){
                    print('History Reservation');
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.history ,
                            color: Colors.white,
                          ),
                          Text(
                              'History Reservation',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                          Text(
                              '>>',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 1,
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: Colors.teal,
                child: FlatButton(
                  onPressed: (){
                    print('Edit Profile');
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.account_circle,
                            color: Colors.white,
                          ),
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                          Text(
                            '>>',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 1,
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(0.6),
                margin: EdgeInsets.only(),
                color: Colors.teal,
                child: FlatButton(
                  onPressed: (){
                    print("Theme Color");

                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                          ),
                          Text(
                            'Theme Color',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                          Text(
                            '>>',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 1,
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding:EdgeInsets.all(0.6),
                margin:EdgeInsets.only(left:0, right:0,),
                color: Colors.teal,
                child: FlatButton(
                  onPressed: (){
                    print('Log out');
                    Navigator.of(context).pushReplacementNamed('/LoginScreen');
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.history ,
                            color: Colors.white,
                          ),
                          Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                          Text(
                              '>>',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Source Sans Pro',
                              )
                          ),
                        ],
                      ),
                    ],
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