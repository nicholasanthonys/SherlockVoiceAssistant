import 'package:sherlock_voice_assistant/model/nlp_response.dart';

class WordProcess {
  //* a function to find the highest sailence from list of entities.
  //* sailence is the most important thing in the context
  Entity findEntityWithHighestSailence(List<Entity> entities) {
    double min = -99999.0;
    Entity highestSailenceEntity;
    //* find highest entity sailence
    entities.forEach((element) {
      if (element.salience > min) {
        highestSailenceEntity = element;
        min = highestSailenceEntity.salience;
      }
    });
    return highestSailenceEntity;
  }

  //* a function to find entity with the type of number from list entities
  Entity findEntityNumber(List<Entity> entities) {
    Entity en;
    List<Entity> filtered =
        entities.where((element) => element.type == "NUMBER").toList();
    if (filtered.length > 0) {
      en = filtered[0];
    }
    return en;
  }

  //* a function to construct a sentence based on array of entity.
  //* we just iterate for each entities and make a sentence from it
  //* this sentence will be called as keyword.
  String getSentenceFromEntities(List<Entity> entities) {
    String sentence = "";
    entities.forEach((element) =>
    //* if entity is not number, then we append the sentence.
        element.type != "NUMBER" ? sentence += element.name + " " : null);
    return sentence.trim();
  }

  bool isAllLocation(List<Entity> entities) {
    bool isAllLocation = true;
    for (var i = 0; i < entities.length; i++) {
      if (entities[i].type != "LOCATION") {
        isAllLocation = false;
        break;
      }
    }
    return isAllLocation;
  }

  //* a function to determine the event from array of entities based on the entity type
  String determineEvent(List<Entity> entities) {
    //*if all entity is location or entity with the highest sailence is Location
    //* then the event is map
    if (isAllLocation(entities) ||
        findEntityWithHighestSailence(entities).type == "LOCATION") {
      return "map";
    }
    //* otherwise, the event is browser
    return "browser";
  }

  //* a function to construct a query form a keyword. Usually, if keyword contain space
  //* we replace it by %20 or + . In this function, we replace it by +
  String constructQuery(String keyword) {
    //*construct query by split sentence by space, and join it by +
    List<String> list = keyword.split(" ");
    //*join it by +
    String query = list.join("+");

    return query;
  }

  //* a function to convert number to specific unit of measurement.
  //* there are 3 unit measurement that we consider : km or kilometer, meter and mile
  int convertDistanceToMeter(String sentence, int number) {
    int result;
    //* we try to search if any unit measurement is within a sentence.
    if (sentence.contains("kilometer") || sentence.contains("km")) {
      result = number * 1000;
    } else if (sentence.contains("meter")) {
      result = number;
    } else if (sentence.contains("mile")) {
      result = number * 1600;
    }
    return result;
  }
}
