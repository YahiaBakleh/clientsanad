import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clientsanad/AllScreens/LoginScreen.dart';
import 'package:clientsanad/AllWidgets/noAvailableSpecialistsDialog.dart';
import 'package:clientsanad/AllWidgets/progressDialog.dart';
import 'package:clientsanad/Assistants/geoFireAssistant.dart';
import 'package:clientsanad/DataHandler/appData.dart';
import 'package:clientsanad/Models/address.dart';
import 'package:clientsanad/Models/directionDetails.dart';
import 'package:clientsanad/Models/nearbyAvailableSpecialists.dart';
import 'package:clientsanad/configMaps.dart';
import 'package:clientsanad/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DirectionDetails? directionDetails;
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  // static final CameraPosition _kGooglePlex = CameraPosition(target: LatLng(37.42796133580664, -122.08832357078792), zoom: 14.4746);
  static final CameraPosition _kGooglePlex =
  CameraPosition(target: LatLng(33.50279062, 36.28587224), zoom: 14.4746);
  Position? currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0.0;
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  double detailsContainerHeight = 0.0,
      searchContainerHeight = 270.0,
      loadingContainerHeight = 0.0;
  bool drawerOpen = true;
  bool nearbyAvailableSpecialistKeyLoaded = false;
  DatabaseReference? userRequestRef;
  BitmapDescriptor? nearbyIcon;

  List<NearbyAvailableSpecialists>? availableSpecialists;

  List<MaterialColor> colorizeColors = [
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  TextStyle colorizeTextStyle = TextStyle(
    fontSize: 40.0,
    fontFamily: 'Brand Bold',
  );

  void resetApp() {
    /**in this function we reset the mainScrenn**/
    setState(() {
      drawerOpen = true;
      detailsContainerHeight = 0.0;
      loadingContainerHeight = 0.0;
      searchContainerHeight = 270.0;
      bottomPaddingOfMap = 0.0;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
    // to get updated address after rest the valus
    locatePosition();
  }

  void displayLoadingContainer() {
    setState(() {
      loadingContainerHeight = 250.0;
      detailsContainerHeight = 0.0;
      // searchContainerHeight = 0.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });
    saveUserRequest();
  }

  void displayDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      detailsContainerHeight = 300.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
    new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    // String address = await AssistantMethod.searchCoordinateAddress(position, context);
    String? address = await AssistantMethod.getAddressByCoordinate(
        position, context);
    initGeoFireListner();
  }

  void saveUserRequest() {
    userRequestRef =
        FirebaseDatabase.instance.reference().child("User Requests").push();
    Address? sessionLocation =
        Provider
            .of<AppData>(context, listen: false)
            .sessionLocation;
    Map sessionOnMap = {
      'latitude': sessionLocation?.latitude.toString(),
      'longitude': sessionLocation?.longitude.toString(),
    };
    // Address? pickUpLocation = Provider.of<AppData>(context,listen: false).pickUpLocation;
    // Map pickUpOnMap = {
    //   'latitude':sessionLocation?.latitude.toString(),
    //   'longitude':sessionLocation?.longitude.toString(),
    // };

    Map userInfoMap = {
      "user_id": userCurrentInfo?.id,
//       "spacialist_id": "waiting",
      "specialist_id": "waiting",
      //TODO: Now we had only on door cash as payment method later this should take an id for payment_method attribute
      "payment_method": "cash",
      "session_location": sessionOnMap,
      "session_address": sessionLocation?.placeName,
      "user_name": userCurrentInfo?.name,
      "user_mobile": userCurrentInfo?.mobile,
      "user_phone": userCurrentInfo?.phone,
      "create_at": DateTime.now().toString(),
    };
    userRequestRef?.set(userInfoMap);
  }

  void cancelUserRequest() {
    userRequestRef?.remove();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AssistantMethod.getCurrentOnlineUserInfo();
  }

  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      drawer: Container(
        color: Colors.white,
        width: 225.0,
        /** Drawer : Header + Body **/
        child: ListView(
          children: [
            /** Drawer Header **/
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
                          style: TextStyle(
                              fontSize: 16.0, fontFamily: "Brand Bold"),
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

            /** Drawer Body Controller **/
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
            GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.idScreen, (route) => false);
              },
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "Log out",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          /** GoogleMap **/
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 265.0;
              });

              locatePosition();
            },
          ), // GoogleMap end

          /**homburgerButton for Drawer**/
          Positioned(
            top: 38.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldKey.currentState?.openDrawer();
                } else {
                  resetApp();
                }
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
                    ((drawerOpen) ? Icons.menu : Icons.close),
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),

          /** Search map Panel **/
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight /*270.0*/,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0)),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
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
                        style:
                        TextStyle(fontSize: 22.0, fontFamily: 'Brand Bold'),
                      ), // Text
                      SizedBox(
                        height: 20.0,
                      ),
                      GestureDetector(
                        // on Tap  will run search screen which will run
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));
                          if (res == 'obtainDirection') {
                            displayDetailsContainer();
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
                                // Icon(Icons.search, color: Colors.indigo),
                                Icon(Icons.search, color: mainBlue),
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
                              Text(
                                  Provider
                                      .of<AppData>(context)
                                      .pickUpLocation !=
                                      null
                                      ? Provider
                                      .of<AppData>(context)
                                      .pickUpLocation!
                                      .placeName
                                      .toString()
                                      : "Add Home",
                                  textDirection: TextDirection.ltr),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Your home Address",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12.0),
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
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12.0),
                              ),
                            ],
                          ), // Column
                        ],
                      ), // Row
                    ],
                  ), // Column
                ), // Padding
              ),
            ), // Container
          ),

          /** Details Panel **/
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              duration: new Duration(milliseconds: 160),
              curve: Curves.bounceIn,
              vsync: this,
              /** Panel Shap **/
              child: Container(
                height: detailsContainerHeight /*300.0*/,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                /** Displays Panel Data :Details **/
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      /** Regular Session : Start **/
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset("images/normalSession.jpg",
                                  height: 70, width: 80.0),
                              SizedBox(
                                width: 16.0,
                              ),
                              /** Session Type + Distance**/
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /** Session Type**/
                                  Text(
                                    "Regular",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: "Brand Bold"),
                                  ),
                                  /** Distance **/
                                  // Text(
                                  //   "2.5 km",
                                  //   style: TextStyle(
                                  //       fontSize: 16.0,
                                  //       color: Colors.grey,
                                  //       fontFamily: "Brand Bold"),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      /** Sized Box height space **/
                      SizedBox(
                        height: 20.0,
                      ),

                      /** cash **/
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 20.0),
                      //   child: Row(
                      //     children: [
                      //       Icon(
                      //         FontAwesomeIcons.moneyBillAlt,
                      //         size: 18.0,
                      //         color: Colors.black45,
                      //       ),
                      //       SizedBox(
                      //         width: 16.0,
                      //       ),
                      //       Text('Cash'),
                      //       SizedBox(
                      //         width: 6.0,
                      //       ),
                      //       Icon(
                      //         Icons.keyboard_arrow_down,
                      //         size: 16.0,
                      //         color: Colors.black54,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 24.0,
                      // ),

                      /** Request Button **/
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: RaisedButton(
                          onPressed: () {
                            displayLoadingContainer();
                            availableSpecialists = GeoFireAssistant.nearByAvailableSpecialistList;
                            searchNearbySpecialists();
                          },
                          // color: Theme.of(context).accentColor,
                          color: mainBlue,
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Request',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Icon(
                                  FontAwesomeIcons.dotCircle,
                                  color: Colors.white,
                                  size: 26.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      /** Regular Session : End **/
                    ],
                  ),
                ),
              ),
            ),
          ),

          /** find Specialist panel **/
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16.0,
                    color: Colors.black45,
                    offset: Offset(.07, 0.7),
                  ),
                ],
              ),
              height: loadingContainerHeight /* 250 */,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText("Please Wait ...",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Looking For",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Specialist ...",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Please Wait ...",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Looking For",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Specialist ...",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Please Wait ...",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Looking For",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Specialist ...",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Please Wait ...",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Looking For",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Specialist ...",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                          ColorizeAnimatedText("Please Wait ...",
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {
                          print("Tap Event");
                        },
                      ),
                    ),
                    SizedBox(
                      height: 22.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        cancelUserRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(width: 2.0, color: Colors.grey),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 26.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    //HINT: initialPos is where specialist or doctor will come or accept the request
    // get pickUpLocation as initialPos and sessionLocation as sessionPos
    var initialPos =
        Provider
            .of<AppData>(context, listen: false)
            .pickUpLocation;
    var sessionPos =
        Provider
            .of<AppData>(context, listen: false)
            .sessionLocation;
    // convert initialPos and sessionPos to LatLng point
    var initialLatLng = LatLng(
        initialPos!.latitude!.toDouble(), initialPos.longitude!.toDouble());
    var sessionLatLng = LatLng(
        sessionPos!.latitude!.toDouble(), sessionPos.longitude!.toDouble());

    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(
              message: "Please wait...",
            ));

    var details = await AssistantMethod.obtainPlaceDirectionDetails(
        initialLatLng /*pickUpLatLng*/, sessionLatLng /*dropOffLatLng*/);

    setState(() {
      //   tripDirectionDetails = details;
      directionDetails = details;
    });
    Navigator.pop(context);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
    polylinePoints.decodePolyline(details!.encodedPoints.toString());

    pLineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
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

    LatLngBounds latLngBounds;
    if (initialLatLng.latitude > sessionLatLng.latitude &&
        initialLatLng.longitude > sessionLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: initialLatLng, northeast: sessionLatLng);
    } else if (initialLatLng.longitude > sessionLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(initialLatLng.latitude, sessionLatLng.longitude),
          northeast: LatLng(sessionLatLng.latitude, initialLatLng.longitude));
    } else if (initialLatLng.latitude > sessionLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(sessionLatLng.latitude, initialLatLng.longitude),
          northeast: LatLng(initialLatLng.latitude, sessionLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: initialLatLng, northeast: sessionLatLng);
    }

    newGoogleMapController
        ?.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker initialLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
      InfoWindow(title: initialPos.placeName, snippet: "my Location"),
      position: initialLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker sessionLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
      InfoWindow(title: sessionPos.placeName, snippet: "DropOff Location"),
      position: sessionLatLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(initialLocMarker);
      markersSet.add(sessionLocMarker);
    });

    Circle initialLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: initialLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle sessionLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: sessionLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circlesSet.add(initialLocCircle);
      circlesSet.add(sessionLocCircle);
    });
  }

  // initGeoFireListner: wil query live geo data
  // so any class instance deal with this function will deal with live data
  void initGeoFireListner() {
    // which firebase node will we query
    Geofire.initialize('availableSpecialist');
    // query availableSpecialist based on user currentPosition in readuse of 10 and listen to change in location
    Geofire.queryAtLocation(
        currentPosition!.latitude, currentPosition!.longitude, 10)?.listen((
        map) {
      //map is json object like
      //map={key:'asr44...',latitud:4.32..,longitude:2.543...};
      // so we can access the value by key
      if (map != null) {
        var callBack = map['callBack'];
        switch (callBack) {
        // specialist become online and his in user range , get his location and id
          case Geofire.onKeyEntered:
            NearbyAvailableSpecialists nearbyAvailableSpecialists = NearbyAvailableSpecialists(
                key: map['key'],
                latitude: map['latitude'],
                longitude: map['longitude']);
            // add specialist so we can use it later in GUI
            GeoFireAssistant.nearByAvailableSpecialistList.add(
                nearbyAvailableSpecialists);
            if (nearbyAvailableSpecialistKeyLoaded == true) {
              updateAvailableSpecialistsOnMap();
            }
            break;

        // user or specialist become offline or get out of range
          case Geofire.onKeyExited:
          // removeSpecialistFromList take sting value find the int index and remove it from nearByAvailableSpecialistList
            GeoFireAssistant.removeSpecialistFromList(
                map['key'] /*map['key'] return specialist id as string*/);
            updateAvailableSpecialistsOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableSpecialists nearbyAvailableSpecialists = NearbyAvailableSpecialists(
                key: map['key'],
                latitude: map['latitude'],
                longitude: map['longitude']);
            GeoFireAssistant.updateSpecialistNearbyLocation(
                nearbyAvailableSpecialists);
            updateAvailableSpecialistsOnMap();
            // Update your key's location
            break;

          case Geofire.onGeoQueryReady:
          // All Intial Data is loaded
            updateAvailableSpecialistsOnMap();
            break;
        }
      }
      setState(() {});
    });
  }

  // updateAvailableSpecailistsOnMap: to Display all Available Specailists on the map
  void updateAvailableSpecialistsOnMap() {
    // to remove all old marker from the map
    setState(() {
      markersSet.clear();
    });
    // new marker
    Set<Marker> tMarker = Set<Marker>();
    // legacy for loop example : for (var item in list/array)
    for (NearbyAvailableSpecialists specialist in GeoFireAssistant
        .nearByAvailableSpecialistList) {
      LatLng specialistsAvailablePosition = LatLng(
          specialist.latitude, specialist.longitude);
      Marker marker = Marker(
        markerId: MarkerId(('Specailist_${specialist.key}')),
        position: specialistsAvailablePosition /*= LatLng(specialist.latitude,specialist.longitude) */,
        icon: nearbyIcon as BitmapDescriptor,
        //BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        rotation: AssistantMethod.createRandomNumber(360),
      );
      tMarker.add(marker);
    }
    setState(() {
      markersSet = tMarker;
    });
  }

  void createIconMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
          context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
          imageConfiguration, 'images/specialist.png').then((value) =>
      nearbyIcon = value);
    }
  }

  void noSpecialistFound(){
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) =>NoAvailableSpecialistsDialog(),
    );
  }

  void searchNearbySpecialists() {
    //if no Specialist available cancel the request and rest the app
    if (availableSpecialists?.length == 0) {
      cancelUserRequest();
      resetApp();
      noSpecialistFound();
      return;
    }
    //TODO: filter Specialists: we sholud build function to filter Specialists based on specialize
    //TODO: then add them to availableSpecialists list
    //there are available Specialists pick 1st on in the list
    NearbyAvailableSpecialists? specialist = availableSpecialists?[0];
    notifySpecialist(specialist!);
    availableSpecialists?.removeAt(0);
  }

  void notifySpecialist(NearbyAvailableSpecialists specialists){
    //set newRequest node value to userRequest id (userRequestRef?.key)
    specialistRef.child(specialists.key).child('newRequest').set(userRequestRef?.key.toString());
    // get the token
    specialistRef.child(specialists.key).child('token').once().then((DataSnapshot snap){
      if(snap.value!=null){
        String token=snap.value.toString();
        //send th notification
        AssistantMethod.sendNotification(token, context, userRequestRef!.key);
      }
    });
  }
}
