# FindRentalManager
# What is FindRentalManager?
  This is the APP can help  UCD students to have the online reservations  in the arc and library and  this app can support manager view
  This app will help users to do the reservations and keep track of different items' usage 
# How to reserve on FindRentalManager?
  The first tab-> select an location -> select an category -> select an item-> to reserve.
# How to check your reservation?
  The second tab->swap the block where locates the top app bar. 
# How to pick up an item/ return item?
  The second tab-> Edit-> Select the item->Pick up/Return
 
if you need tech support while using our iOS App “FindRentalManager” on App Store
 
# To Contact us:

Abudureheman Adila aadila@ucdavis.edu

Alessandro Liu aleliu@ucdavis.edu

Jiayi Zhang pkazhang@ucdavis.edu

Jing Gao jagao@ucdavis.edu

Please see the screenshots of iOS app here: https://photos.app.goo.gl/4jebWVzzVUo9aBDq6
Privacy Policy: https://github.com/AlessandroAlleAlex/RentalManager/blob/master/Privacy%20Policy
# RentalManagerAdmin Repository Link: https://github.com/aadila6/RentalManagerAdmin.git

# RentalAdmin

This is a flutter web application for rental manager app.

## Getting Started

Live Demo : [Flutter Rental Manager App Web&Mobile Demo](https://youtu.be/uWN17YViIzk)


## How to Create and Deploy
Follow the links below to learn more about how to create and deploy web applications in flutter.

* Flutter For Web: [A Complete Guide to Create & Run a Web Application](https://medium.com/@zubairehman.work/flutter-for-web-c75011a41956)

* Flutter For Web: [A Complete Guide to Deploy a Web Application](https://medium.com/@zubairehman.work/flutter-for-web-a-complete-guide-to-deploy-a-web-application-3fa9463377a8)

## How to Use 

**Step 1:**

Download or clone this repo by using the link below:

```

```

**Step 2:**

Go to project root and execute the following command in console to get the required dependencies: 

``` 
flutter pub get 
```

**Step 3:**

To use the Flutter SDK with the flutter_web preview make sure you have upgraded Flutter. 
Follow the link to learn more about how to configure flutter for web: https://medium.com/@zubairehman.work/flutter-for-web-c75011a41956

**Step 4:**

To run this application simply type in the following command:

```
flutter run -d chrome
```

## Folder Structure
Here is the core folder structure which flutter provides.

```
flutter-app/
|- android
|- build
|- ios
|- lib
|- test
```

Here is the folder structure we have been using in this project

```
lib/
|- views/
|- widgets/
|- main.dart
```

Now, lets dive into the lib folder which has the main code for the application.

```
1- views - All the application level views files including inventory,SuperUser and signin/signout views 
2- widgets — Contains the common widgets for the applications, but mainly components like widgets that gets called repeatedly.
3- main.dart - This is the starting point of the application. All the application level configurations are defined in this file.
```

### Views

This directory contains all the application level constants. A separate file is created for each type as shown in example below:

```
views/
|- 
```

### SuperUser

This directory contains all the ui of your application. Each screen is located in a separate folder making it easy to combine group of files related to that particular screen. All the screen specific widgets will be placed in `widgets` directory as shown in the example below:

```
SuperUser /
|- 
```

### User

Contains the common file(s) and utilities used in a project. The folder structure is as follows: 

```
|- 

```

### Widgets

Contains the common widgets that are shared across multiple screens. For example, Button, TextField etc.

```
widgets/
|- 


```

### Main

This is the starting point of the application. All the application level configurations are defined in this file i.e, theme, routes, title, orientation etc.

```
import 'package:flutter/material.dart';
import 'package:RentalAdmin/views/signInScreen.dart';
import 'views/signInScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: SuperuserPanel(),
      home: signInScreen(),
    );
  }
}

```
### Created & Maintained By

> Team Cowculator

### License

    Copyright 2020 Abudureheman Adila, Jiayi Zhang, Jing Gao, Alessandro Liu @ UC Davis 




