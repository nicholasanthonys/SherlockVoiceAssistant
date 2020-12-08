class TranslationRequest {
  String q;
  String target;

  TranslationRequest({this.q, this.target});

  Map<String, dynamic> toJson() => {
        "q": q,
        "target": target,
      };
}
