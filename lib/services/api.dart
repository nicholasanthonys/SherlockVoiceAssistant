import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:sherlock_voice_assistant/constant.dart';
import 'package:sherlock_voice_assistant/model/nlp_request.dart';
import 'package:sherlock_voice_assistant/model/nlp_response.dart';
import 'package:sherlock_voice_assistant/model/translation_request.dart';
import 'package:sherlock_voice_assistant/model/translation_response.dart';

class Api {
  var logger = new Logger();
  //* a function to post request to Google Map NLP API
  Future<NLPResponse> getNER(NLPRequest request) async {
    final http.Response response = await http.post(
        'https://language.googleapis.com/v1/documents:analyzeEntities?key=' + DotEnv().env['GOOGLE_CLOUD_API_KEY'],
        body: jsonEncode(request));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        NLPResponse res = NLPResponse.fromJson(jsonDecode(response.body));
        return res;
      } catch (e) {
        logger.e("error");
        logger.e(e.toString());
        return null;
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to Response From Google Cloud NLP');
    }
  }
  //* a function to post request to Google Map Translation API
  Future<TranslationResponse> getTranslations(
      TranslationRequest translationRequest) async {
    var logger = new Logger();
    logger.i("translation request is");
    logger.i(translationRequest.q);

    final http.Response response = await http.post(
        'https://translation.googleapis.com/language/translate/v2?key=' + DotEnv().env['GOOGLE_CLOUD_API_KEY'],
        body: jsonEncode(translationRequest));

    logger.i("response is");
    logger.i(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        TranslationResponse res =
            TranslationResponse.fromJson(jsonDecode(response.body));
        return res;
      } catch (e) {
        logger.e(e.toString());
        return null;
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to Response From Google Cloud NLP');
    }
  }
}
