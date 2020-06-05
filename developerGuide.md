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

- **First Tab View**:
  * **[Location List View](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/Locations/custom_location_card.dart#L14-L111)**: lib/Locations/custom_location_card.dart Line 14- Line 111
   
   ``` 
  Widget customCard(int index, AsyncSnapshot snapshot, BuildContext context) 
  //This view is 

   ```


  * **[Grid Cell View](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/Locations/custom_gridcell.dart#L10-L40)**: lib/Locations/custom_gridcell.dart Line 10- Line 40)
   ``` 
   class CustomCell extends StatelessWidget{}
   // This view is 
   ```
  * **[Reserved View](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/Locations/detail_page.dart#L267-L340)**: lib/Locations/detail_page.dart Line267 - Line 340
   ``` 
   class CustomCell extends StatelessWidget{}
   // This view is for reservation view

   Below is database setting{
      'imageURL': 
      'name':  
      'uid':  
      'item':  
      'amount':  
      'startTime': 
      'status':  
      'reserved time': 
      'picked Up time': 
      'return time':  
      'endTime':  
      'UserName':  
      'location': (For Manager search )
      'category': 

   }


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
   Using listview builder to genterate a list view and set each row as a list tile which 
   contains leading image conver for reserved items or in use items, their names, the time
   the time they are reserved.
   ```

- **Third Tab View**:
  * **[Manager View](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/displayall.dart#L42-L207)**: lib/displayall.dart Line 42 - Line 207
   
   ``` 
  child: Scaffold(
        appBar: AppBar(...)
  )...
  This view contains two views in total;
  Swipe Left(Also as default view): for Admins and Managers to see recent activities happened in the Location(Manager) or organization(Organization) and 
  Swipe right: Admins and Managers are able to see all people in the ogranization. Admins are able to change all users' roles in the organzaion. However, managers cna only invite guests only to manage their locations.
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
   2. Changing the location name will also change the search options for Admins in the search Part.
    
   ```
  * **[Manage Category View ](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/manager/manage_category.dart#L729-L778)**:  lib/manager/manage_locations.dart Line729-L778
   ``` 
   Scaffold(.....)
   This is the view for managers/Admins to edit categories: 
   1. Adding/deleting/editing categories' cover images and names
   ``` 
  * **[Manage items View](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/displayall.dart#L2342-L2464)**:  lib/manager/manage_locations.dart Line 2342 - Line 2464
   ``` 
   Scaffold(.....)
   This is the view for managers/Admins to edit items:
   1. Adding/deleting/editing items' cover images and names
   2. Changing the location name will also change the search input for managers and admins.
    
   ``` 

  * **[Upload CSV View ](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/displayall.dart#L234-L390)**:  lib/displayall.dart Line 234 - Line 390
   ``` 
   void pickUpFile(BuildContext context, cater, subCollectionName) async 
   This is the view for managers/Admins to upload items via CSV File:
   1. Only CSV files can be picked up and all CSV files's columns' ranges should be 2 - 3.
   2. Allow managers and Admins to select all items and unselected all items.
   3. Add all selected items to storages and Delete all unselected items
    
   ```  

  * **[Track Item Usage View ](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/searchItem.dart#L28-L496)**:  lib/searchItem.dart Line 28 - Line 496
   ``` 
  class theItemSearch extends StatefulWidget{...}
  This is the view for all users(Guests/Managers/Admins) track items' usage
  ```

  * **[Pop up input window](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/tabs/help.dart#L132-L325)**: lib/tabs/help.dart Line 132-Line 325
   ``` 
  void _showDialog(String s)
  This is the widget as a pop up window to get users' input. This widget is used in Contact Us, Lost And Found, Manage Locations, Manage Categories, Manage items. 
  ```

  **Fourth Tab View**:
  * **[History Reservations](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/HistoryReservation.dart#L20-L219)**: lib/tabs/reservations.dart Line 20 - Line 219
   ``` 
   class _HistoryReservationState extends State<HistoryReservation>{}
   This view is to check users' history
   ```
  * **[Theme Color ](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/changeColor.dart#L15-L164)**: lib/changeColor.dart Line 15-Line 164
   ``` 
   class _changeColorState extends State<changeColor> {}
   This view is to change color: Light, Dark, system setting
   ```

  * **[Language Setting](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/changeColor.dart#L15-L164)**: lib/changeColor.dartLine 15-Line 164
  ``` 
  class _languageSettingState extends State<languageSetting>{}
  This view is to change language: English, Chinese, system setting
  ```




