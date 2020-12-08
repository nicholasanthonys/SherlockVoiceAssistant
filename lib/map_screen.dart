import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:sherlock_voice_assistant/constant.dart';
import 'package:sherlock_voice_assistant/model/nlp_response.dart';
import 'package:sherlock_voice_assistant/services/word_process.dart';

import 'model/place_response.dart';

class MapScreen extends StatefulWidget {
  String keyword;

  final String originalSentence;
  final List<Entity> entities;

  MapScreen(
      {@required this.keyword,
      @required this.originalSentence,
      @required this.entities});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );
  Completer<GoogleMapController> _controller = Completer();

//   Camera Position Attributes
//   To customize the location and view point of the map you can alter attributes of intitialCameraPosition
//  the CameraPosition for the GoogleMap widget.
//   It allows you to set:
//   target: The latitude and longitude of where to center the map.
//   bearing: The direction the camera faces (north, south, east, west, etc.).
//   tilt: The angle the camera points to the center location.
//   zoom: The magnification level of the camera position on the map.
  CameraPosition _cameraPosition;

  List<Marker> markers;

  double latitude;
  double longitude;
  bool searching = false;
  Position position;
  WordProcess wp = WordProcess();
  GoogleMapController mapController;
  int radius = 3000;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    markers = [];
    latitude = -6.917464;
    longitude = 107.619125;
    _cameraPosition = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 12,
        bearing: 15.0,
        tilt: 17.0);

    //* let's do searching
    search(
      widget.keyword,
      widget.originalSentence,
      widget.entities,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.originalSentence,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: _cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          _controller.complete(controller);
        },
        markers: Set<Marker>.of(markers),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () async {
          await search(
            widget.keyword,
            widget.originalSentence,
            widget.entities,
          );
        },
        label: Text(
          'Places Nearby',
          style: TextStyle(color: Colors.white),
        ),
        // 3
        icon: Icon(Icons.place), // 4
      ),
    );
  }

  //* a function that set the state radius by converting number to meter
  void setRadius(Entity enNumber) {
    //*convert to meter
    int rad = wp.convertDistanceToMeter(
        widget.originalSentence, int.parse(enNumber.name));
    //* set current state radius
    setState(() {
      radius = rad;
    });
  }

  //* function to search if the original sentence contain  "near"
  bool isNearby(String originalSentence) {
    List<String> words = ["near", "nearby", "neared", "nearest"];
    bool isNearby = false;
    for (var i = 0; i < words.length; i++) {
      if (originalSentence.contains(words[i])) {
        isNearby = true;
        break;
      }
    }
    return isNearby;
  }

  //*function to do reques tto googleMapAPI text search
  Future<void> searchMapTextSearch(String keyword) async {
    String query = wp.constructQuery(keyword);

    String url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=" +
            DotEnv().env['GOOGLE_CLOUD_API_KEY'];
    ;

    final response = await http.get(url);

    // 5
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      _handleResponse(data);
    } else {
      throw Exception('An error occurred getting places nearby');
    }
  }

  Future<void> search(
      String keyword, String originalSentence, List<Entity> entities) async {
    setState(() {
      searching = true;
      markers.clear();
    });

    //*find entity with type number
    Entity enNumber = wp.findEntityNumber(entities);
    // get entities location
    Entity enLocation = wp.findEntityWithHighestSailence(entities);
    //* if the original sentence contain  number or 'near'
    if (isNearby(originalSentence) || enNumber != null) {
      //* get current location (langitude,longitude)
      await _getCurrentPosition();
      //*construct the query to be sent to google Map API
      String queryKeyword = wp.constructQuery(keyword);

      //* if entity with type number, set the radius
      if (enNumber != null) {
        setRadius(enNumber);
      }

      //* do searching to google map (nearbysearch)
      await googleMapSearchNearby(
          position.latitude, position.longitude, queryKeyword, enLocation);
    } else {
      //* do searching to google map (textsearch)
      await searchMapTextSearch(keyword);
    }

    setState(() {
      searching = false;
    });
  }

  //* function to search Google Map Search Nearby
  Future<void> googleMapSearchNearby(
      double latitude, double longitude, String keyword, Entity en) async {
    String url = '$GOOGLE_PLACE_NEARBY_URL?key=' +
        DotEnv().env['GOOGLE_CLOUD_API_KEY'] +
        '&location=$latitude,$longitude&radius=$radius&type=${en.type}&keyword=$keyword';
    logger.i("url search nearby is $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _handleResponse(data);
    } else {
      throw Exception('An error occurred getting places nearby');
    }
  }

  void showToast(String message, dynamic bgColor, dynamic textColor) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: bgColor,
        textColor: textColor,
        fontSize: 16.0);
  }

  Future<void> _getCurrentPosition() async {
    logger.i("get current position triggered");
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      position = pos;
    });
    if (position != null) {
      showToast("Location Enabled", Colors.green, Colors.white);
    } else {
      showToast("Location is not enabled", Colors.red, Colors.white);
    }
  }

  //* a function to handle response from google map api. the response is array of place
  //* in this function, we add the map marker based on place langitude and longitude
  void _handleResponse(dynamic data) {
    if (data['status'] == "OK") {
      setState(() {
        PlaceResponse _placeResponse = PlaceResponse.fromJson(data);

        latitude = _placeResponse.places[0].geometry.location.latitude;
        longitude = _placeResponse.places[0].geometry.location.longitude;

        mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(latitude, longitude), zoom: 14.0)));

        //* for each place from array of place, add marker
        for (int i = 0; i < _placeResponse.places.length; i++) {
          markers.add(
            Marker(
              markerId: MarkerId(_placeResponse.places[i].placeId),
              position: LatLng(
                  _placeResponse.places[i].geometry.location.latitude,
                  _placeResponse.places[i].geometry.location.longitude),
              infoWindow: InfoWindow(
                  title: _placeResponse.places[i].name,
                  snippet: _placeResponse.places[i].vicinity),
              onTap: () {},
            ),
          );
        }
      });
    }
  }
}
