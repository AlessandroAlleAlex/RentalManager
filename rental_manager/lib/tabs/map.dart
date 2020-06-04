//import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:geolocator/geolocator.dart';
//import 'package:rental_manager/SlideDialog/slide_popup_dialog.dart' as slideDialog;
//import 'package:google_map_polyline/google_map_polyline.dart';
//import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
//
//class GoogleMapsServices {
//  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
//    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${l1
//        .latitude},${l1.longitude}&destination=${l2.latitude},${l2
//        .longitude}&key=$apiKey";
//    http.Response response = await http.get(url);
//    Map values = jsonDecode(response.body);
//    return values["routes"][0]["overview_polyline"]["points"];
//  }
//}
//GoogleMapsServices _googleMapsServices = GoogleMapsServices();
//
//String apiKey = "AIzaSyBajKBlmw4rmx1Vqu0cWXrxoqvBN03KhcI";
//GoogleMapPolyline googleMapPolyline =
//new  GoogleMapPolyline(apiKey: apiKey);
//
//const LatLng SOURCE_LOCATION = LatLng(38.539515, -121.751898);
//const LatLng DEST_LOCATION = LatLng(38.539834, -121.747486);
//
//class Location{
//  double a, b;
//
//  Location(this.a, this.b);
//}
//Location currentLocation = new Location(38.539834, -121.747486);
//BitmapDescriptor sourceIcon, destIcon;
//
//class TheMap extends StatefulWidget {
//  @override
//  _TheMapState createState() => _TheMapState();
//}
//
//class _TheMapState extends State<TheMap> {
//  GoogleMapController mapController;
//
//  Set<Marker> _markers = {};
//  Set<Polyline> _polylines = {};
//  List<LatLng> polylineCoordinates = [];
//  PolylinePoints polylinePoints = PolylinePoints();
//
//  void _onMapCreated(GoogleMapController controller) async{
//    //
//    // controller.setMapStyle(Utils.mapStyles);
//    mapController = controller;
//
//  }
//  void setMapPins() {
//    setState(() {
//      // source pin
//      _markers.add(Marker(
//          markerId: MarkerId('sourcePin'),
//          position: SOURCE_LOCATION,
//          icon: sourceIcon
//      ));
//      // destination pin
//      _markers.add(Marker(
//          markerId: MarkerId('destPin'),
//          position: DEST_LOCATION,
//          icon: destIcon
//      ));
//    });
//  }
//
//  void setPolylines() async {
//
//
//
//    List<PointLatLng> result = [];
//    try{
//         result = await polylinePoints.getRouteBetweenCoordinates(
//             "AIzaSyBajKBlmw4rmx1Vqu0cWXrxoqvBN03KhcI",
//        SOURCE_LOCATION.latitude,
//        SOURCE_LOCATION.longitude,
//        DEST_LOCATION.latitude,
//        DEST_LOCATION.longitude);
//    }catch (e){
//     print(e);
//    }
//
//
//
//    if (result.isNotEmpty) {
//      // loop through all PointLatLng points and convert them
//      // to a list of LatLng, required by the Polyline
//      print("Not Empty");
//      result.forEach((PointLatLng point) {
//        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//      });
//    }else{
//      print("Empty");
//    }
//    print("Here");
//    setState(() {
//      // create a Polyline instance
//      // with an id, an RGB color and the list of LatLng pairs
//      Polyline polyline = Polyline(
//          polylineId: PolylineId("poly"),
//          color: Color.fromARGB(255, 40, 122, 198),
//          points: polylineCoordinates
//      );
//
//      // add the constructed polyline as a set of points
//      // to the polyline set, which will eventually
//      // end up showing up on the map
//      _polylines.add(polyline);
//    });
//  }
//
//  @override
//  void initState() {
//    super.initState();
//    setSourceAndDestinationIcons();
//  }
//
//  void getPosition() async{
//    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//
//    setState(() {
//      currentLocation.a = position.latitude;
//      currentLocation.b = position.longitude;
//    });
//    print("OK");
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//    void _showDialog(String s) {
//      String email, subject, atext;
//      slideDialog.showSlideDialog(
//        context: context,
//        child:  Text("$s, \n Wrong class or wrong location? modify it in ->"),
//        textField: Container(
//          child: Column(
//            children: <Widget>[
//            ],
//          ),
//        ),
//        barrierColor: Colors.white.withOpacity(0.7),
//      );
//    }
//    return  Scaffold(
//      appBar: AppBar(
//        title: Text('Maps Route Sample'),
//        backgroundColor: Colors.teal,
//        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons. camera_alt),
//            onPressed:()async {
//              var info = "Our records show that you just finished ECS193A, and might need to head to Olson Hall in 30 miuntes Please Dismiss it to see the route";
//
//              _showDialog(info);
//              getPosition();
//              setMapPins();
//              setPolylines();
//              print(currentLocation.a);
//              print(currentLocation.b);
//              List<PointLatLng> polylinePoints = [];
//
//              String url = "https://maps.googleapis.com/maps/api/directions/json?origin=" +
//                  SOURCE_LOCATION.latitude.toString() +
//                  "," +
//                  SOURCE_LOCATION.longitude.toString() +
//                  "&destination=" +
//                  DEST_LOCATION.latitude.toString() +
//                  "," +
//                  DEST_LOCATION.longitude.toString() +
//                  "&mode=walking" +
//                  "&key=$apiKey";
//
//
//              print(url);
//
//              var response = await http.get(url);
//
//            }
//          ),
//        ],
//      ),
//      body: GoogleMap(
//        onMapCreated: _onMapCreated,
//        myLocationEnabled: true,
//        compassEnabled: true,
//        initialCameraPosition: CameraPosition(
//          target: DEST_LOCATION,
//          zoom: 17.0,
//        ),
//        markers: _markers,
//        polylines: _polylines,
//      ),
//    );
//  }
//}
//
//
//void setSourceAndDestinationIcons() async {
//  sourceIcon = BitmapDescriptor.defaultMarkerWithHue(12);
//  destIcon = BitmapDescriptor.defaultMarkerWithHue(14);
//
//}
//
//class Utils {
//  static String mapStyles = '''[
//  {
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#f5f5f5"
//      }
//    ]
//  },
//  {
//    "elementType": "labels.icon",
//    "stylers": [
//      {
//        "visibility": "off"
//      }
//    ]
//  },
//  {
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#616161"
//      }
//    ]
//  },
//  {
//    "elementType": "labels.text.stroke",
//    "stylers": [
//      {
//        "color": "#f5f5f5"
//      }
//    ]
//  },
//  {
//    "featureType": "administrative.land_parcel",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#bdbdbd"
//      }
//    ]
//  },
//  {
//    "featureType": "poi",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#eeeeee"
//      }
//    ]
//  },
//  {
//    "featureType": "poi",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#757575"
//      }
//    ]
//  },
//  {
//    "featureType": "poi.park",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#e5e5e5"
//      }
//    ]
//  },
//  {
//    "featureType": "poi.park",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#9e9e9e"
//      }
//    ]
//  },
//  {
//    "featureType": "road",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#ffffff"
//      }
//    ]
//  },
//  {
//    "featureType": "road.arterial",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#757575"
//      }
//    ]
//  },
//  {
//    "featureType": "road.highway",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#dadada"
//      }
//    ]
//  },
//  {
//    "featureType": "road.highway",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#616161"
//      }
//    ]
//  },
//  {
//    "featureType": "road.local",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#9e9e9e"
//      }
//    ]
//  },
//  {
//    "featureType": "transit.line",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#e5e5e5"
//      }
//    ]
//  },
//  {
//    "featureType": "transit.station",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#eeeeee"
//      }
//    ]
//  },
//  {
//    "featureType": "water",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#c9c9c9"
//      }
//    ]
//  },
//  {
//    "featureType": "water",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#9e9e9e"
//      }
//    ]
//  }
//]''';
//}
//
//List<PointLatLng> decodeEncodedPolyline(String encoded)
//{
//  List<PointLatLng> poly = [];
//  int index = 0, len = encoded.length;
//  int lat = 0, lng = 0;
//
//  while (index < len) {
//    int b, shift = 0, result = 0;
//    do {
//      b = encoded.codeUnitAt(index++) - 63;
//      result |= (b & 0x1f) << shift;
//      shift += 5;
//    } while (b >= 0x20);
//    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//    lat += dlat;
//
//    shift = 0;
//    result = 0;
//    do {
//      b = encoded.codeUnitAt(index++) - 63;
//      result |= (b & 0x1f) << shift;
//      shift += 5;
//    } while (b >= 0x20);
//    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//    lng += dlng;
//    PointLatLng p = new PointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
//    poly.add(p);
//  }
//  return poly;
//}