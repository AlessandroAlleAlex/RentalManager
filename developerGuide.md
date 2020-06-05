## Getting Started
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

## Main Functionaliies
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
  * **[Firebase Sign in](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/main.dart#L446)**: lib/main.dart Line 446)
   ``` 
   var authHandler = newAuth
   var e = await authHandler.signIn(username, password);
   ```
- **Second Tab View**:
  * **[iOS Sliding Segmented Control](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/tabs/reservations.dart#L276-L290)**: lib/tabs/reservations.dart Line 276-Line 290
   
   ``` 
  CupertinoSlidingSegmentedControl(

        padding: EdgeInsets.all(2.0),
        backgroundColor: Colors.grey,
        thumbColor: backgroundcolor(),
        groupValue: theriGroupVakue, // switch views from "Reserved" to "In Use"
        onValueChanged: (changeFromGroupValue) {
         setState(() { // this is to change the Edit to Button words from "Edit" to "Done"
            rightButton = "Edit";
            theriGroupVakue = changeFromGroupValue;
            view = theriGroupVakue + 1;
          });
        },
         children: logoWidgets,
  ) 
   ```
  * **[Generate List View ](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/tabs/reservations.dart#L45-L242)**:  lib/tabs/reservations.dart Line45-242)
   ``` 
   ListView.builder(.....)
   ```

- **Third Tab View**:
  * **[Manager View](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/displayall.dart#L42-L207)**: lib/displayall.dart Line 42 - Line 207
   
   ``` 
  child: Scaffold(
        appBar: AppBar(...)
  )...
   ```

  * **[Activities Search View ](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/managebooksHelper.dart#L79-L291)**: lib/managebooksHelper.dart Line 79 - Line 291
   ``` 
   class searchReservation extends StatefulWidget{
    ...
   }
   This is the view for managers/Admins to search activities(reservations/PickUp/Return) activities in the organization/location: 
   For Admin:
      They can search items' activities by different Locations 
   For Location Managers:
      They can search items' activities only in their Locations   
   The difference for this view between location managers and Admins is: 
   For Admins' search view, they can see a gear icon at their
   corner scrren and Admins can press this icon to see differnt locations.

   ```



  * **[Manage Location View ](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/manager/manage_locations.dart#L747-L795)**:  lib/manager/manage_locations.dart Line747-795
   ``` 
   Scaffold(.....) 
   This is the view for managers/Admins to edit locations: 
   1. Adding/deleting/editing locations' cover images and names
   2. Also potentially changed the tags for the items in that location. 
      ex. change the location name will also let Admins use that new location name to search item in the seach view
   ```
  * **[Manage Category View ](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/manager/manage_category.dart#L729-L778)**:  lib/manager/manage_locations.dart Line729-L778
   ``` 
   Scaffold(.....)
   This is the view for managers/Admins to edit categories: 
   1. Adding/deleting/editing categories' cover images and names
   2. Also potentially change the path to select an item. 
      ex. from Location A -> Category B' -> Item C to Location A -> Catgory B' -> Item C
   ``` 
  * **[Manage items](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/displayall.dart#L2342-L2464)**:  lib/manager/manage_locations.dart Line2342 - Line 2464
   ``` 
   Scaffold(.....)
   This is the view for managers/Admins to edit items:
   1. Adding/deleting/editing items' cover images and names
   2. Also potentially change the path to select an item. 
      ex. from Location A -> Category B' -> Item C to Location A -> Catgory B' -> Item C
   ``` 

   


  

