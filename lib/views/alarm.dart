import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alarm_with_bank_transfer/views/alarm_manager.dart';
import 'package:alarm_with_bank_transfer/views/dialog.dart';
import 'package:alarm_with_bank_transfer/views/setting.dart';

class AlarmTab extends StatefulWidget {
  @override
  _AlarmTabState createState() => _AlarmTabState();
}

class _AlarmTabState extends State<AlarmTab> {
  SharedPreferences prefs;
  DateTime _alarmTime;
  String _targetTime;
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _targetDateTime;
  String initTime = '00:00';
  bool doesExist;
  bool isLoad;

  @override
  void initState() {
    isLoad = false;
    DateTime _now = DateTime.now();
    loadData().then((value) {
      setState(() {
        isLoad = value;
      });
    });
    super.initState();
  }

  Future<bool> loadData() async {
    prefs = await SharedPreferences.getInstance();
    _targetTime = (prefs.getString('alarmTime') ?? initTime);
    if (_targetTime == initTime) {
      doesExist = false;
      _alarmTime = DateTime.now();
    } else {
      doesExist = true;
      print("sharedPreference: $_targetTime");
      setAlarmTime();
    }
    return true;
  }

  // ignore: non_constant_identifier_names
  @override
  Widget build(BuildContext context) {
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
    print("----------------alarm tab build");
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;

    TextStyle clockStyle = TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w800,
      fontSize: 65,
      color: Color.fromARGB(255, 237, 234, 231),
    );

    TextStyle textStyle = TextStyle(
        fontFamily: "AppleSDGothicNeo",
        fontWeight: FontWeight.w400,
        fontSize: 45,
        color: Color.fromARGB(255, 35, 37, 43),
        shadows: [
          Shadow(
            blurRadius: 5.0,
            color: Colors.black.withOpacity(.3),
            offset: Offset(1.0, 1.0),
          )
        ]);

    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 35, 37, 43),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: _height * 0.15,
            child: Container(
                width: _width * 0.9,
                height: _height * 0.5,
                child: Stack(alignment: Alignment.center, children: [
                  Wrap(
                    children: [
                      timePickerSpinner(),
                    ],
                  ),
                  Center(
                    child: Text(
                      ":",
                      style: clockStyle,
                    ),
                  ),
                  Positioned(
                    top: _height * 0.3 + 3,
                    child: Row(
                      children: [
                        Center(
                          child: Text("HOURS",
                              style: clockStyle.copyWith(fontSize: 26)),
                        ),
                        Container(
                          width: _width * 0.1,
                        ),
                        Center(
                          child: Text("MINUTES",
                              style: clockStyle.copyWith(fontSize: 25)),
                        )
                      ],
                    ),
                  )
                ])),
          ),
          Positioned(
            bottom: _height * 0.1,
            child: GestureDetector(
              onTap: () {
                setAlarmTime();
                int penalty = prefs.getInt('penalty') ?? 0;
                if (penalty == 0) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailView(title: "Penalty", detailIndex: 0)));
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => ErrorDialog(
                            errorMsg: "fill penalty",
                          ));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AlarmManager(alarmTime: _alarmTime)));
                }
              },
              child: Container(
                alignment: Alignment.center,
                width: _width * 0.6,
                height: _height * 0.1,
                decoration: _boxDecoration,
                child: Text(
                  "SET",
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget timePickerSpinner() {
    TextStyle highlightTextStyle = new TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w800,
      fontSize: 85,
      color: Color.fromARGB(255, 250, 249, 248),
    );
    TextStyle normalTextStyle = new TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w800,
      fontSize: 80,
      color: Color.fromARGB(255, 75, 79, 93),
    );

    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;

    return isLoad
        ? new TimePickerSpinner(
            time: _alarmTime,
            normalTextStyle: normalTextStyle,
            highlightedTextStyle: highlightTextStyle,
            alignment: Alignment.center,
            itemHeight: _height * 0.15,
            itemWidth: _width * 0.32,
            isForce2Digits: true,
            onTimeChange: (time) async {
              print("onTimeChange");
              setState(() {
                _targetTime = DateFormat("HH:mm").format(time);
                prefs.setString('alarmTime', _targetTime);
                setAlarmTime();
              });
            },
          )
        : Container(
            child: Center(
              child: Text(
                "00 00",
                style: highlightTextStyle,
              ),
            ),
          );
  }

  void setAlarmTime() {
    _targetDateTime = _date + " " + _targetTime;
    _alarmTime = DateFormat('yyyy-MM-dd HH:mm').parse(_targetDateTime);
    print("new alarmTime: $_alarmTime");
    if (_alarmTime.difference(DateTime.now()).inSeconds <= 0) {
      DateTime aDayAfter = DateTime.now().add(Duration(days: 1));
      String _aDayAfterDate = DateFormat('yyyy-MM-dd').format(aDayAfter);
      _targetDateTime = _aDayAfterDate + " " + _targetTime;
      _alarmTime = DateFormat('yyyy-MM-dd HH:mm').parse(_targetDateTime);
      print('changed alarmTime: $_alarmTime');
    }
  }
}
