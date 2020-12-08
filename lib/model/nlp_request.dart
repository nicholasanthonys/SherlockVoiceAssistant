import 'dart:convert';

class NLPRequest {
  String encodingType;
  Document document;

  NLPRequest({this.encodingType, this.document});

  Map<String, dynamic> toJson() => {
        "encodingType": encodingType,
        "document": document,
      };
}

class Document {
  String type;
  String content;

  Document({this.type, this.content});

  Map<String, dynamic> toJson() => {
        "type": type,
        "content": content,
      };
}
