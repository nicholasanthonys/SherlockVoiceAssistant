class PlaceResponse {
  List<Place> places;

  PlaceResponse({this.places});

  factory PlaceResponse.fromJson(Map<String, dynamic> json) => PlaceResponse(
      places: List<Place>.from(json['results'].map((e) => Place.fromJson(e))));
}

class Place {
  String placeId;
  String name;
  String vicinity;
  Geometry geometry;

  Place({this.placeId, this.name, this.vicinity, this.geometry});

  factory Place.fromJson(Map<String, dynamic> json) => Place(
      placeId: json['place_id'],
      name: json['name'],
      vicinity: json['vicinity'] != null ? json['vicinity'] : null,
      geometry: json['geometry'] != null
          ? Geometry.fromJson(json['geometry'])
          : null);
}

class Geometry {
  Location location;

  Geometry({this.location});

  factory Geometry.fromJson(Map<String, dynamic> json) =>
      Geometry(location: Location.fromJson(json['location']));
}

class Location {
  double latitude;
  double longitude;

  Location({this.latitude, this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) =>
      Location(latitude: json['lat'], longitude: json['lng']);
}
