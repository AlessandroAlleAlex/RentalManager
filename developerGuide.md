##Getting Started
**Step 1:**

Please make sure you have the environment to run fluter via your terminal or IDE such as(Andriod Stdio). For the environment installation， please see details [here](https://flutter.dev/docs/get-started/install).

**Step 2:**

Download the zip file or use Git clone and set up the platform [iOS](https://flutter.dev/docs/get-started/install/macos#ios-setup) or [Andriod](https://flutter.dev/docs/get-started/install/macos#android-setup) to run our app. 

**Step 3:**

For IDE (such as Andriod Stdio) users, please just press "Run" Button after selecting the platrform(iOS simulator or Andriod emulator)

Otherwise, please use the following commands in your terminal to run this app:
 
 ``` 
flutter devices 
```


```
flutter run
```

## Overview

This is an app for keeping track of inventory for shared physical items and manager-friendly fo uploading items.

**Please Note**: This app is a firebase based app so most functionaliies need to be done while devices are connected with the Internet. Please make sure you are not off-line while your are developing this app.

## Functionaliies
- **Sign in**:
  * **[Google Sign in](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/main.dart#L151-L165)**: lib/main.dart Line 151-Line 165
   
   ``` 
  Future<FirebaseUser> _myGoogleSignIn() async {
     GoogleSignInAccount googleUser = await _googleSignIn.signIn();
     GoogleSignInAuthentication googleAuth = await googleUser.authentication;
     final AuthCredential credential = GoogleAuthProvider.getCredential(
       accessToken: googleAuth.accessToken,
       idToken: googleAuth.idToken,
     );
     final FirebaseUser user =
         (await _auth.signInWithCredential(credential)).user;

     print("signed in " + user.displayName);
     print("signed in " + user.email);

     return user;
  }
   ```
  * **[Firebase Sign in]((https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/main.dart#L446))**: lib/main.dart Line 446
   ``` 
   var authHandler = newAuth
   var e = await authHandler.signIn(username, password);
   ```
  

