import 'dart:async';
import 'package:clientsanad/AllWidgets/progressDialog.dart';
import 'package:clientsanad/DataHandler/appData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clientsanad/AllWidgets/Divider.dart';
import 'package:clientsanad/Assistants/assistantMethod.dart';
import 'package:clientsanad/AllScreens/searchScreen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static const idScreen = 'mainScreen';
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  static final CameraPosition _kGooglePlex = CameraPosition(target: LatLng(37.42796133580664, -122.08832357078792), zoom: 14.4746);
  Position? currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0.0;

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    // String address = await AssistantMethod.searchCoordinateAddress(position, context);
    String? address = await AssistantMethod.getAddressByCoordinate(position, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      drawer: Container(
        color: Colors.white,
        width: 225.0,
        child: ListView(
          children: [
            //Drawer Header
            Container(
              height: 165.0,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Image.asset(
                      'images/user_icon.png',
                      height: 65.0,
                      width: 65.0,
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Profile Name",
                          style: TextStyle(fontSize: 16.0, fontFamily: "Brand Bold"),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Text("Visit Profile"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            DividerWidget(),

            SizedBox(
              height: 12.0,
            ),

            //Drawer Body Controller
            ListTile(
              leading: Icon(Icons.history),
              title: Text(
                "History",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                "Visit Profile",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(
                "About",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            polylines: polylineSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 265.0;
              });

              locatePosition();
            },
          ), // GoogleMap

          //homburgerButton for Drawer
          Positioned(
            top: 45.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState?.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),

          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: 270.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ), // BoxShadow
                ],
              ), // BoxDecoration
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.0),
                    Text(
                      "Hi there,",
                      style: TextStyle(fontSize: 14.0),
                    ), // Text
                    Text(
                      "Where you want us ?",
                      style: TextStyle(fontSize: 22.0, fontFamily: 'Brand Bold'),
                    ), // Text
                    SizedBox(
                      height: 20.0,
                    ),
                    GestureDetector(
                      onTap: () async {
                        var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
                        if (res == 'obtainDirection') {
                          await getPlaceDirection();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 6.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            ), // BoxShadow
                          ],
                        ), // BoxDecoration
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.indigo),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text("Search...")
                            ],
                          ), // Row
                        ), // Padding
                      ), // Container
                    ), // GestureDetector
                    // Container
                    SizedBox(
                      height: 12.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.home,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Provider.of<AppData>(context).pickUpLocation != null ? Provider.of<AppData>(context).pickUpLocation!.placeName.toString() : "Add Home", textDirection: TextDirection.ltr),
                            SizedBox(
                              height: 4.0,
                            ),
                            Text(
                              "Your home Address",
                              style: TextStyle(color: Colors.black54, fontSize: 12.0),
                            ),
                          ],
                        ), // Column
                      ],
                    ), // Row
                    SizedBox(
                      height: 10.0,
                    ),
                    DividerWidget(),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add Location"),
                            SizedBox(
                              height: 4.0,
                            ),
                            Text(
                              "Your Current Location",
                              style: TextStyle(color: Colors.black54, fontSize: 12.0),
                            ),
                          ],
                        ), // Column
                      ],
                    ), // Row
                  ],
                ), // Column
              ), // Padding
            ), // Container
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    //HINT: initialPos is where spacialist or doctor will come or accept the request
    var initialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var sessionPos = Provider.of<AppData>(context, listen: false).sessionLocation;
    var initialLatLng = LatLng(initialPos!.latitude!.toDouble(), initialPos.longitude!.toDouble());
    var sessionLatLng = LatLng(sessionPos!.latitude!.toDouble(), sessionPos.longitude!.toDouble());

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));

    var details = await AssistantMethod.obtainPlaceDirectionDetails(initialLatLng, sessionLatLng);

    // setState(() {
    //   tripDirectionDetails = details;
    // });
    Navigator.pop(context);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult = polylinePoints.decodePolyline(details!.encodedPoints);

    pLineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });
  }
}
