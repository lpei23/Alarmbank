import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:screen/screen.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:alarm_with_bank_transfer/models/history_model.dart';
import 'package:alarm_with_bank_transfer/history_helper.dart';

import 'dart:async';

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
                    await audioPlayer.stop();
                    if (miss > 0) {
                      // create history
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      int _penalty = (prefs.getInt('penalty') ?? 0);
                      int _left = (prefs.getInt('left') ?? 0);
                      History history = new History(
                          date: _alarmTime,
                          timeExceeded:
                              _alarmTime.difference(widget.alarmTime).inMinutes,
                          penalty: _penalty * miss);
                      _left += (_penalty * miss);
                      await prefs.setInt('left', _left);
                      await HistoryHelper().createHistory(history);
                    }
                    if (_timer != null) {
                      _timer.cancel();
                      _timer = null;
                    }
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
      print("tick tok");
      timeDifference = _alarmTime.difference(now).inSeconds;
      startProgressBar();
    } else {
      print("countDown");
      if (timeDifference < 5) {
        print("more than 1 minutes left($timeDifference)");
        _timer = Timer.periodic(Duration(minutes: 1), (timer) {
          print("finish");
          setState(() {
            timer.cancel();
            timer = null;
          });
        });
      } else if (timeDifference < 30) {
        print("more than 5 minutes left($timeDifference)");
        _timer = Timer.periodic(Duration(minutes: 5), (timer) {
          print("finish");
          setState(() {
            timer.cancel();
            timer = null;
          });
        });
      } else if (timeDifference < 120) {
        print("more than 30 minutes left($timeDifference)");
        _timer = Timer.periodic(Duration(minutes: 30), (timer) {
          print("finish");
          setState(() {
            timer.cancel();
            timer = null;
          });
        });
      } else {
        print("more than 60 minutes left($timeDifference)");
        _timer = Timer.periodic(Duration(minutes: 60), (timer) {
          print("finish");
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

    print("waiting");
    _timer = Timer.periodic(Duration(minutes: 1), (timer) async {
      await audioPlayer.stop();
      print("restart");
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
      print("vibration, ring");
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
