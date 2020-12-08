import 'package:logger/logger.dart';

class NLPResponse {
  List<Entity> entities;

  NLPResponse({this.entities});

  factory NLPResponse.fromJson(Map<String, dynamic> json) {
    return NLPResponse(
        entities:
            List<Entity>.from(json['entities'].map((e) => Entity.fromJson(e))));
  }
}

class Entity {
  String name;
  String type;
  double salience;

  Entity({this.name, this.type, this.salience});

  factory Entity.fromJson(dynamic json) {
    return Entity(
        name: json['name'] as String,
        type: json['type'] as String,
        salience: json['salience'] is double
            ? json['salience'] as double
            : double.parse(json['salience'].toString()));
  }

}
