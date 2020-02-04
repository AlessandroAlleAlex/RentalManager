import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_manager/mainView.dart';

// import 'loginPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/LoginScreen': (context) => MyApp(),
        '/MainViewScreen': (context) => MyHome1(),
      },
      initialRoute: 'LoginScreen',
    );
  }
  @override
  Widget know (BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance.collection('CollectionA').document('DOc1').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('1');
            return new Text("Loading");
          }
          var userDocument = snapshot.data;
          print('2');
          return new Text(userDocument["a"]);
        }
    );
  }

}

showAlertDialog(BuildContext context) {

  // set up the buttons
  Widget remindButton = RaisedButton(
    child: Text("Remind me later"),
    onPressed:  () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Warning"),
    content: Text("Your account or your password is not correct!"),
    actions: [
      remindButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String username;
  String password;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('images/appstore.png'),
              ),
              SizedBox(height: 10, width: 150),
              Text(
                'Rental Manager',
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 20,
                  color: Colors.teal.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10, width: 150),
              Text(
                'Weclome',
                style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  color: Colors.teal.shade900,
                  fontSize: 20,
                  letterSpacing: 2.5,
                ),
              ),
              SizedBox(
                height: 20,
                width: 150,
                child: Divider(
                  color: Colors.teal.shade900,
                ),
              ),
              SizedBox(
                  height: 10, width: 150
              ),

              TextField(
                onChanged:(text){
                  password = text;
                  print("First text field: $text");
                },
                // controller: _username,
                cursorColor: Colors.teal.shade900,
                scrollPadding:  const EdgeInsets.symmetric(vertical: 10.0,horizontal: 30),
                decoration: InputDecoration(
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    ),
                    borderSide: new BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  labelText: 'Enter your username',
                  prefixIcon: const Icon(Icons.person, color: Colors.black),
                  // labelStyle:
                  // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 30),

                ),

              ),
              SizedBox(
                  height: 20,width: 150
              ),
              TextField(
                onChanged:(text){
                  password = text;
                  print("First text field: $text");
                },

                obscureText: true,
                cursorColor: Colors.teal.shade900,
                decoration: InputDecoration(
                  contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 100.0, 10.0),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    ),
                    borderSide: new BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  labelText: 'Enter your Password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
                  // labelStyle:
                  // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                  // contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
                ),
              ),

              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Row(
                      children: <Widget>[
                        Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 15,
                            // backgroundColor:  Colors.teal[50],
                            color: Colors.white,
                            fontFamily: 'Source Sans Pro',
                          ),
                        ),

                      ],
                    ),
                    onPressed: (){
                      if(username == null && password == null){
                        showAlertDialog(context);
                      }else{
                        Navigator.of(context).pushReplacementNamed('/MainViewScreen');
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => MyHome1()));
                      }

                    },
                    padding: EdgeInsets.all(10.0),
                    color: Colors.teal.shade900,
                    disabledColor: Colors.black,
                    disabledTextColor: Colors.black,

                  ),
                  RaisedButton(
                    onPressed: (){

                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                    },
                    color: Colors.teal.shade900,
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "SIGN UP",
                      style: TextStyle(
                        fontSize: 15,
                        // backgroundColor:  Colors.teal[50],
                        color: Colors.white,
                        fontFamily: 'Source Sans Pro',
                      ),
                    ),

                  ),
                ],
              ),
              Row(
                children: <Widget>[
                ],
              ),
            ],
          ),
        ),
      ),
      //home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }


}

class SignUpPage extends StatelessWidget {
  String email, username, password, confirmpw;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Sign Up'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            TextField(
              onChanged:(text){
                email = text;
                print("First text field: $text");
              },
              cursorColor: Colors.teal.shade900,
              scrollPadding:  const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
              decoration: InputDecoration(
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  borderSide: new BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                ),
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email, color: Colors.black),
                // labelStyle:
                // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              onChanged:(text){
                username = text;
                print("username: $text");
              },
              // obscureText: true,
              cursorColor: Colors.teal.shade900,
              decoration: InputDecoration(
                // contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 100.0, 10.0),
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  borderSide: new BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                ),
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person, color: Colors.black),
                // labelStyle:
                // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              onChanged:(text){
                password = text;
                print("First password field: $text");
              },
              obscureText: true,
              cursorColor: Colors.teal.shade900,
              scrollPadding:  const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
              decoration: InputDecoration(
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  borderSide: new BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                ),
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: Colors.black),
                // labelStyle:
                // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              onChanged:(text){
                confirmpw = text;
                print("Second password field: $text");
              },
              obscureText: true,
              cursorColor: Colors.teal.shade900,
              decoration: InputDecoration(
                // contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 100.0, 10.0),
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  borderSide: new BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                ),
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock, color: Colors.black),
                // labelStyle:
                // new TextStyle(color: Colors.teal.shade900, fontSize: 16.0),
                contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 50),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Click sign up after entering all of above'),
            RaisedButton(
              textColor: Colors.white,
              color: Colors.teal.shade900,
              child: Text('SIGN UP'),

              onPressed: () {
                Navigator.pop(context);
              },
              padding: EdgeInsets.all(10.0),
              disabledColor: Colors.black,
              disabledTextColor: Colors.black,

            )

          ],
        ),
      ),
    );
  }
}



