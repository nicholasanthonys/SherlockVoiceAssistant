class TranslationResponse {
  Data data;

  TranslationResponse({this.data});

  factory TranslationResponse.fromJson(Map<String, dynamic> json) =>
      TranslationResponse(data: Data.fromJson(json['data']));
}

class Data {
  List<Translation> translations;

  Data({this.translations});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
      translations: List<Translation>.from(
          json['translations'].map((e) => Translation.fromJson(e))));
}

class Translation {
  String translatedText;

  Translation({this.translatedText});

  factory Translation.fromJson(Map<String, dynamic> json) =>
      Translation(translatedText: json['translatedText']);
}
