import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:logger/logger.dart';
import 'package:sherlock_voice_assistant/map_screen.dart';
import 'package:sherlock_voice_assistant/model/translation_request.dart';
import 'package:sherlock_voice_assistant/model/translation_response.dart';
import 'package:sherlock_voice_assistant/services/api.dart';
import 'package:sherlock_voice_assistant/services/word_process.dart';
import 'package:sherlock_voice_assistant/web_screen.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import 'model/nlp_request.dart';
import 'model/nlp_response.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "Say something...";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();
  int playerId;
  int counter = 0;
  var logger = Logger(
    printer: PrettyPrinter(),
  );
  WordProcess wordProcess = WordProcess();
  FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  String speakerText =
      "My Name is Sherlock. I’m Your Virtual Assistant. What can i do for you ? ";
  NLPResponse response;
  String translation;
  String idnLangCode = "id-ID";
  String enLangCode = "en-GB";
  Api api = new Api();
  bool isListening = false;

  @override
  void initState() {
    super.initState();

    //*initialization speech instance
    initSpeechState();

    //* let the flutterTTS speak
    _speak(speakerText, enLangCode);
  }

  //* function that tells flutterTTS to speak based on sentence and language code
  Future<void> _speak(String sentence, String languageCode) async {
    setState(() {
      isSpeaking = true;
    });
    await flutterTts.setLanguage(languageCode);
    await flutterTts.awaitSpeakCompletion(true);
    var result = await flutterTts.speak(sentence);
    setState(() {
      isSpeaking = false;
    });
    logger.i("result is ", result);
    if (result > 0) {
      logger.i("speak success");
    } else {
      logger.e("error _speak");
      logger.i(result.toString());
    }
  }

  //*function to initialize speech instance
  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener, debugLogging: true);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(355, 896), allowFontScaling: false);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: LoadingOverlay(
          color: Colors.black,
          isLoading: isLoading,
          progressIndicator: SpinKitCubeGrid(
            color: Colors.white,
            size: ScreenUtil().setWidth(50),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(30),
                child: Text(speakerText,
                    style: Theme.of(context)
                        .textTheme
                        .headline1
                        .copyWith(fontSize: ScreenUtil().setSp(36.0))),
              ),
              Text(
                response != null && response.entities.length > 0
                    ? response.entities[0].type
                    : '',
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(
                height: 8.0,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        speech.isListening
                            ? Container(
                                height: 60,
                                padding:
                                    EdgeInsets.only(top: 60.0, bottom: 30.0),
                                margin: EdgeInsets.only(bottom: 60.0),
                                child: WaveWidget(
                                  config: CustomConfig(
                                    gradients: [
                                      [Colors.blue, Color(0xFF00BCD4)],
                                      [Colors.blue[300], Color(0xFF4DD0E1)],
                                      [Colors.blue[100], Color(0xFFB2EBF2)],
                                      [Colors.blue[50], Color(0xFFE0F7FA)]
                                    ],
                                    durations: [35000, 19440, 10800, 6000],
                                    heightPercentages: [0.20, 0.23, 0.25, 0.20],
                                    blur: MaskFilter.blur(BlurStyle.solid, 10),
                                    gradientBegin: Alignment.bottomLeft,
                                    gradientEnd: Alignment.topRight,
                                  ),
                                  duration: 2,
                                  waveAmplitude: 0,
                                  heightPercentange: 0.2,
                                  size: Size(
                                    double.infinity,
                                    double.infinity,
                                  ),
                                ),
                              )
                            : Container(),
                        Text(
                          lastWords,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(40),
                        ),
                        _determineWidgetTranslation(context)
                      ],
                    ),
                  ),
                ),
              ),
              // ignore: unrelated_type_equality_checks

              Align(
                alignment: Alignment.bottomCenter,
                child: AvatarGlow(
                  glowColor: Color(0xffFF0E0D),
                  animate: speech.isListening,
                  endRadius: ScreenUtil().setWidth(100),
                  child: GestureDetector(
                    child: Container(
                      child: Image.asset("assets/images/mic.png"),
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                      decoration: BoxDecoration(
                          color: !isSpeaking ? Color(0xffFF0E0D) : Colors.grey,
                          shape: BoxShape.circle),
                    ),
                    onLongPress:
                        !isSpeaking || isListening ? startListening : null,
                    onLongPressUp: stopListening,

                    // onLongPressUp: speech.isListening ? stopListening : null,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //* if translation not null, then show the text, otherwise show empty container
  Widget _determineWidgetTranslation(BuildContext context) {
    if (translation != null) {
      return Column(children: [
        Text(
          "Translation",
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
        Text(
          translation,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ]);
    }
    return Container();
  }

  //* function that use Google API Translation to translate text
  Future<String> getTranslation(String text) async {
    //*construct the request
    TranslationRequest tReq = new TranslationRequest(q: text, target: "in");
    //* get translation from current text(lastword) to indonesia
    TranslationResponse tRes = await api.getTranslations(tReq);

    if (tRes != null) {
      return tRes.data.translations[0].translatedText;
    }
    return '';
  }

  //* a function that determine event based on entity response.
  //* there are 2 events to handle, if entity is location then open map screen
  //* if entity is other that that, open the browser
  Future<void> _determineEvent(NLPResponse response) async {
    if (response != null && response.entities.length > 0) {
      //*let's determine the event based on the entity type
      String event = wordProcess.determineEvent(response.entities);
      //* construct array of entity to become a sentence.
      String keyword = wordProcess.getSentenceFromEntities(response.entities);
      switch (event) {
        case "map":
          {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MapScreen(
                        keyword: keyword,
                        originalSentence: lastWords,
                        entities: response.entities)));
            break;
          }

        case "browser":
          {
            String sentence;
            if (keyword.contains("search")) {
              sentence = keyword;
            } else {
              sentence = "searching $keyword for you";
            }
            await _speak(sentence, enLangCode);
            await _openWebView(keyword);
            break;
          }
      }
    }

    return Container();
  }

  //* a function that push current screen to web screen. We initialize url
  //* so when we go to the web screen, the browser automatically search
  Future<void> _openWebView(String keyword) async {
    String query = wordProcess.constructQuery(keyword);
    String url = 'https://google.com/search?q=$query';

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebScreen(url: url),
        ));
  }

  //* function that tells flutter speech to text to listen
  void startListening() {
    setState(() {
      isListening = true;
      translation = null;
    });
    lastWords = "Listening...";
    lastError = "";
    setState(() {
      response = null;
    });
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 9999),
        localeId: "en_US",
        //*set the language as english (United States)
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
  }

  //* a function that handle the event after the flutter speech to text stop listening
  Future<void> stopListening() async {
    speech.stop();
    setState(() {
      isListening = false;
    });
    setState(() {
      level = 0.0;
    });

    if (lastWords.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      //* lets get the translation in indonesia
      String translationId = await getTranslation(lastWords);
      setState(() {
        isLoading = false;
      });

      setState(() {
        translation = translationId;
      });

      //* tell flutterTTS to speak the translation in indonesia
      await _speak("Translation.", enLangCode);
      await _speak(translation, idnLangCode);

      sleep(Duration(seconds: 1));

      //* let request to google NLP API to get NER
      await doNLPRequest();
    }
  }

  //* this is function to do NEP Request
  Future<void> doNLPRequest() async {
    setState(() {
      isLoading = true;
    });
    //*construct data
    Document document = Document(type: "PLAIN_TEXT", content: lastWords);
    NLPRequest request = NLPRequest(encodingType: "UTF8", document: document);
    //* call the function to get ENTITY
    NLPResponse res = await getNer(request);
    if (res != null) {
      setState(() {
        response = res;
        isLoading = false;
      });

      //*let's handle the Entity
      await _determineEvent(response);
    }
    setState(() {
      isLoading = false;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    // print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      logger.e("error " + error.errorMsg);
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    // print(
    // "Received listener status: $status, listening: ${speech.isListening}");
    setState(() {
      lastStatus = "$status";
    });
  }

  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }

  //* a function to get ENTITY from Google NLP API
  Future<NLPResponse> getNer(NLPRequest request) async {
    NLPResponse response = await api.getNER(request);
    return response;
  }
}
