import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notably/screens/note_screen.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
// import 'package:notably/text_editor.dart';

//void main() => runApp(MyApp());

class SpeechConvertor extends StatefulWidget {
  @override
  _SpeechConvertor createState() => _SpeechConvertor();
}

class _SpeechConvertor extends State<SpeechConvertor> {
  bool _hasSpeech = false;
  //bool _hasSpeech = true;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  //String _currentLocaleId = "";
  //List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
    //initSpeechState();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    /*    
    if (hasSpeech) {
      _localeNames = await speech.locales();
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }*/

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    return Container(
      height: mediaQuery.size.height - 50,
      width: mediaQuery.size.width,
      color: theme.backgroundColor,
      child: Column(children: [
        /*
            Center(
              child: Text(
                'Speech recognition available',
                style: TextStyle(fontSize: 22.0),
              ),
            ),*/
        Container(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child: Text('Initialize'),
                    onPressed: _hasSpeech ? null : initSpeechState,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child: Text('Start'),
                    onPressed: !_hasSpeech || speech.isListening
                        ? null
                        : startListening,
                  ),
                  FlatButton(
                    child: Text('Stop'),
                    onPressed: speech.isListening ? stopListening : null,
                  ),
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: speech.isListening ? cancelListening : null,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  /*
                      DropdownButton(
                        onChanged: (selectedVal) => _switchLang(selectedVal),
                        value: _currentLocaleId,
                        items: _localeNames
                            .map(
                              (localeName) => DropdownMenuItem(
                                value: localeName.localeId,
                                child: Text(localeName.name),
                              ),
                            )
                            .toList(),
                      ),*/
                ],
              )
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: <Widget>[
              /*
                  Center(
                    child: Text(
                      'Recognized Words',
                      style: TextStyle(fontSize: 22.0),
                    ),
                  ),*/
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Container(
                      color: Theme.of(context).selectedRowColor,
                      child: Center(
                        child: Text(
                          lastWords,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      bottom: 10,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: .26,
                                  spreadRadius: level * 1.5,
                                  color: Colors.black.withOpacity(.05))
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.mic),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Center(
                child: Text(
                  'Error Status',
                  style: TextStyle(fontSize: 22.0),
                ),
              ),
              Center(
                child: Text(lastError),
              ),
              RaisedButton(
                child: //Icon(Icons.mic),
                    Text('Go to Editor',
                        style: TextStyle(
                            fontSize: 25,
                            //fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                onPressed: () {
                  print(lastWords);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NoteScreen(data: lastWords)),
                  );
                },
                //backgroundColor: Colors.pink,
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          color: Theme.of(context).backgroundColor,
          child: Center(
            child: speech.isListening
                ? Text(
                    "I'm listening...",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : Text(
                    'Not listening',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ]),
    );
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 300),
        //localeId: _currentLocaleId,
        localeId: 'en_GB',
        onSoundLevelChange: soundLevelListener,
        cancelOnError: false,
        partialResults: true);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
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
      lastWords = "${result.recognizedWords} - ${result.finalResult}";
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    //print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    print(
        "Received listener status: $status, listening: ${speech.isListening}");
    setState(() {
      lastStatus = "$status";
    });
  }
  /*
  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }
  */
}
