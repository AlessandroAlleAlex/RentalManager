## Getting Started

Live Demo : [Flutter Rental Manager App Web&Mobile Demo](https://youtu.be/uWN17YViIzk)

## How to Create and Deploy
Follow the links below to learn more about how to create and deploy applications in Flutter.

* [Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)

* [Build and release an iOS app](https://flutter.dev/docs/deployment/ios)

* [Build and release an Android app](https://flutter.dev/docs/deployment/android)

## How to Use 

**Step 1:**

Download or clone this repository into your local machine

**Step 2:**

Install the latest version of Flutter from this [link](https://flutter.dev/docs/get-started/install).

**Step 3:**

Go to project root and execute the following command in the console to get the required dependencies: 

``` 
flutter pub get 
```

**Step 4:**

Open any virtual emulator or connect your physical device to your machine and enter the follwing command to your console to check for available devices:

``` 
flutter devices 
```

**Step 5:**

Finally, enter the following command to run the application:

```
flutter run
```

## Overview

RentalManager is a cross-platform application that provides a convenient method for organizations to manage their inventory items where users can see available resources in real-time, and reserve, check out, and return.

**Please Note**: This appplication is internet dependent because we use Google's Firebase services. Please make sure you are not off-line while your are developing this appplication.

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
  * **[Location List View](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/Locations/list_page.dart)**: lib/Locations/list_page.dart Line 42-45
   
   ``` 
   return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) =>
                    customCard(index, snapshot, context));
   // I pass the locations retrieved from Firestore into the custom widget 'customCard' to be displayed.
   ```


  * **[Category List View](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/Locations/category_page.dart)**: lib/Locations/category_page.dart Line 10)
   ``` 
   class CategoryPage extends StatefulWidget {
   ...
   }
   // This view gets the selected location data from the previews view and displays its categories through a customized widget called 'displayGrids'.
   ```
   
  * **[Item List View](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/Locations/item_page.dart)**: lib/Locations/item_page.dart Line 60-73
  ```
  return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) => ListTile(
                title: Text(
                    snapshot.data.documents[index].data['name'].toString()),
                subtitle: Text(
                    langaugeSetFunc('Total amount:') + ' ${snapshot.data.documents[index].data['# of items'].toString()}'),
                onTap: () {
                  navigateToDetail(snapshot.data.documents[index]);
                  // testingReservations(
                  //     snapshot.data.documents[index].documentID);
                },
              ),
            );
  // From the previews views we got selected location and category, so we retrieve the categorized item list from Firestore as display them as ListTile. 
  ```
  
  
  * **[Reservation creation](https://github.com/AlessandroAlleAlex/RentalManager/blob/master/rental_manager/lib/Locations/detail_page.dart#L267-L340)**: lib/Locations/detail_page.dart Line 267-340
   ``` 
   void uploadData(itemID, uid, dateTime, locationName, catergoryName) async {
   ...
   await databaseReference
        .collection(returnReservationCollection())
        .document()
        .setData({
      'imageURL': imageURL,
      'name': itemName,
      'uid': uid,
      'item': itemID,
      'amount': _currentResAmount.toString(),
      'startTime': dateTime,
      'status': "Reserved",
      'reserved time': dateTime,
      'picked Up time': 'NULL',
      'return time': 'NULL',
      'endTime': "TBD",
      'UserName': globals.username,
      'location': locationName,
      'category': catergoryName,
    });
   ...
   }
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
  
### Created & Maintained By

> Team Cowculator

### License

    Copyright 2020 Abudureheman Adila, Jiayi Zhang, Jing Gao, Alessandro Liu @ UC Davis 

