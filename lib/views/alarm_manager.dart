import 'dart:async';
import 'dart:math';

import 'package:alarm_with_bank_transfer/history_helper.dart';
import 'package:alarm_with_bank_transfer/models/history_model.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class AlarmManager extends StatefulWidget {
  DateTime alarmTime;

  AlarmManager({@required this.alarmTime});

  @override
  _AlarmManagerState createState() => _AlarmManagerState();
}

class _AlarmManagerState extends State<AlarmManager> {
  double restTime = 1.0;
  int timeDifference;
  String _targetTime;
  Timer _timer;
  bool _progressStart = false;
  double stride;
  DateTime _alarmTime;
  bool restart = false;
  bool ring = false;
  int miss = 0;

  List<String> collections = [
    "The Best Way To Get Started Is To Quit Talking And Begin Doing.",
    "시작 하기 가장 좋은 방법은 말을 아끼고 실천 하는것이다",
    "The Pessimist Sees Difficulty In Every Opportunity. The Optimist Sees Opportunity In Every Difficulty.",
    "낙관 주의자는 모든 기회에서 어려움을 찾고 낙천 주의자는 모든 어려움에서 기회를 찾는다",
    "Don’t Let Yesterday Take Up Too Much Of Today.",
    "어제의 일로 오늘을 채우지마라",
    "It’s Not Whether You Get Knocked Down, It’s Whether You Get Up.",
    "넘어지는것은 상관없다. 일어나는것이 중요하다",
    "We May Encounter Many Defeats But We Must Not Be Defeated.",
    "수 많은 패배를 겪을지언정, 그 패배에 사로잡히지 마라",
    "Knowing Is Not Enough; We Must Apply. Wishing Is Not Enough; We Must Do.",
    "아는것은 충분 하지 않다. 실천해야한다. 소원을 비는것은 충분 하지 않다. 행동해야한다.",
    "We Generate Fears While We Sit. We Overcome Them By Action.",
    "앉아있으면 겁이 날 수밖에 없다. 일어스면서 겁을 떨쳐내라.",
    "Life Is Either A Daring Adventure Or Nothing.",
    "인생은 모든것을 건 탐험이거나 아무것도 아니다",
    "Do What You Can With All You Have, Wherever You Are.",
    "어디에 있든 네가 가진것을 다 보여줘라"
  ];

  //
  AudioPlayer audioPlayer = AudioPlayer();

  AudioCache audioCache;

  final BoxDecoration _boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [Colors.white, Color.fromARGB(255, 202, 194, 186)]),
      boxShadow: [
        BoxShadow(
          blurRadius: 6.0,
          color: Colors.black.withOpacity(.2),
          offset: Offset(5.0, 6.0),
        ),
      ]);

  final TextStyle textStyle = TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w400,
      fontSize: 35,
      color: Color.fromARGB(255, 35, 37, 43),
      shadows: [
        Shadow(
          blurRadius: 5.0,
          color: Colors.black.withOpacity(.3),
          offset: Offset(1.0, 1.0),
        )
      ]);

  final TextStyle clockStyle = TextStyle(
    fontFamily: "AppleSDGothicNeo",
    fontWeight: FontWeight.w800,
    fontSize: 100,
    color: Color.fromARGB(255, 237, 234, 231),
  );

  @override
  void initState() {
    if (!restart) {
      _alarmTime = widget.alarmTime;
    }
    super.initState();
    audioCache = new AudioCache(fixedPlayer: audioPlayer);
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;

    _targetTime = DateFormat('HH:mm').format(_alarmTime);

    getRandomElement<T>(List<T> list) {
      final random = Random();
      var i = random.nextInt(list.length);
      return list[i];
    }

    if (ring) {
      waiting();
    } else {
      countDown();
    }

    Screen.keepOn(true);

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Color.fromARGB(255, 35, 37, 43),
          ),
          Positioned(
            top: _height * 0.2,
            child: Container(
              width: _width * 0.83,
              height: _width * 0.83,
              child: CircularProgressIndicator(
                backgroundColor: Colors.black87,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 250, 249, 248),
                ),
                value: restTime,
                strokeWidth: 4.5,
              ),
            ),
          ),
          Positioned(
            top: _height * 0.2,
            child: Container(
              width: _width * 0.83,
              height: _width * 0.83,
              child: Center(
                child: Text(
                  _targetTime,
                  style: clockStyle,
                ),
              ),
            ),
          ),
          Positioned(
              bottom: _height * 0.1,
              child: GestureDetector(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await audioPlayer.stop();
                    var text = getRandomElement(collections);
                    await showDialog(
                        context: context,
                        builder: (popUpContext) => AlertDialog(
                            titlePadding: EdgeInsets.all(0),
                            contentPadding: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 0.5,
                                              color: Color.fromARGB(
                                                  255, 35, 37, 43)))),
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontFamily: "Noto Sans CJK KR",
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.2,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                      color: Colors.transparent,
                                      height: 50,
                                      child: Center(
                                        child: Text(
                                          '확인',
                                          style: TextStyle(
                                            fontFamily: "Noto Sans CJK KR",
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(
                                                255, 236, 205, 152),
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      )),
                                )
                              ],
                            )));
                    int _penalty = (prefs.getInt('penalty') ?? 0);
                    int _left = (prefs.getInt('left') ?? 0);
                    History history = History(
                        date: _alarmTime,
                        timeExceeded:
                            _alarmTime.difference(widget.alarmTime).inMinutes,
                        penalty: _penalty * miss);
                    _left += (_penalty * miss);
                    await prefs.setInt('left', _left);
                    await HistoryHelper().createHistory(history);
                    if (_timer != null) {
                      _timer.cancel();
                      _timer = null;
                    }
                    await prefs.setBool('alarmTimeSet', false);
                    Vibration.cancel();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: _boxDecoration,
                    child: Text(
                      "Turn OFF",
                      style: textStyle,
                    ),
                  ))),
        ],
      ),
    );
  }

  void countDown() async {
    DateTime now = DateTime.now();

    // get time difference in minutes
    timeDifference = _alarmTime.difference(now).inMinutes;
    if (timeDifference < 0) {
      if (_timer != null) {
        _timer.cancel();
        _timer = null;
      }
      Navigator.pop(context);
    }

    // if difference is less than 2 minutes
    if (timeDifference < 2 && timeDifference >= 0) {
      // get time difference in seconds
      // print("tick tok");
      timeDifference = _alarmTime.difference(now).inSeconds;
      if (timeDifference < 0) timeDifference = 0;
      startProgressBar();
    } else {
      // print("countDown");
      if (timeDifference < 5) {
        // print("more than 1 minutes left($timeDifference)");
        _timer = Timer.periodic(Duration(minutes: 1), (timer) {
          // print("finish");
          setState(() {
            timer.cancel();
            timer = null;
          });
        });
      } else if (timeDifference < 30) {
        // print("more than 5 minutes left($timeDifference)");
        _timer = Timer.periodic(Duration(minutes: 5), (timer) {
          // print("finish");
          setState(() {
            timer.cancel();
            timer = null;
          });
        });
      } else if (timeDifference < 120) {
        // print("more than 30 minutes left($timeDifference)");
        _timer = Timer.periodic(Duration(minutes: 30), (timer) {
          // print("finish");
          setState(() {
            timer.cancel();
            timer = null;
          });
        });
      } else {
        // print("more than 60 minutes left($timeDifference)");
        _timer = Timer.periodic(Duration(minutes: 60), (timer) {
          // print("finish");
          setState(() {
            timer.cancel();
            timer = null;
          });
        });
      }
    }
  }

  void startProgressBar() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeDifference == 0) timeDifference = 1;
        if (!_progressStart) {
          stride = 1 / timeDifference;
          _progressStart = true;
        }
        restTime -= stride;
        if (restTime <= 0) {
          ring = true;
        }
        _timer.cancel();
      });
    });
  }

  Future<void> waiting() async {
    if (timeDifference < 0) {
      if (_timer != null) {
        _timer.cancel();
        _timer = null;
      }
      Navigator.pop(context);
    }

    // print("waiting");
    _timer = Timer.periodic(Duration(minutes: 1), (timer) async {
      await audioPlayer.stop();
      // print("restart");
      setState(() {
        _alarmTime = DateTime.now().add(Duration(minutes: 1));
        restart = true;
        ring = false;
        restTime = 1;
        miss += 1;
        Vibration.cancel();
        _timer.cancel();
      });
    });
    audioCache.loop("sounds/beep.mp3");
    if (await Vibration.hasVibrator()) {
      // print("vibration, ring");
      Vibration.vibrate(pattern: [
        2000,
        2000,
        4000,
        4000,
        4000,
        6000,
        4000,
        8000,
        2000,
        8000,
        2000,
        4000,
        5000,
        3000,
        2000,
        2000
      ]);
    }
  }
}
