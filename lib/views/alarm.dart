import 'package:alarm_with_bank_transfer/views/alarm_manager.dart';
import 'package:alarm_with_bank_transfer/views/dialog.dart';
import 'package:alarm_with_bank_transfer/views/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmTab extends StatefulWidget {
  @override
  _AlarmTabState createState() => _AlarmTabState();
}

class _AlarmTabState extends State<AlarmTab> {
  SharedPreferences prefs;
  DateTime _alarmTime;
  String _targetTime;
  String initTime = '00:00';
  bool doesExist;
  bool isLoad;

  @override
  void initState() {
    isLoad = false;
    _targetTime = DateTime.now().toString();
    loadData();
    super.initState();
  }

  checkSet() async {
    prefs = await SharedPreferences.getInstance();
    var check = prefs.getBool('alarmTimeSet') ?? false;
    if (check) {
      await Future.delayed(Duration(milliseconds: 500));
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
                builder: (context) => AlarmManager(alarmTime: _alarmTime)));
      }
    }
  }

  Future<bool> loadData() async {
    prefs = await SharedPreferences.getInstance();
    _targetTime = prefs.getString('alarmTime') ?? '';
    if (_targetTime == '') {
      doesExist = false;
      _alarmTime = DateTime.now();
    } else {
      doesExist = true;
      // print("sharedPreference: $_targetTime");
    }
    setState(() {
      isLoad = true;
    });
    checkSet();
  }

  // ignore: non_constant_identifier_names
  @override
  Widget build(BuildContext context) {
    final BoxDecoration _boxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            // end: Alignment(0.0, 0.8),
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 235, 235, 235),
              Color.fromARGB(255, 207, 207, 207),
            ]),
        boxShadow: [
          BoxShadow(
            blurRadius: 6.0,
            color: Colors.black.withOpacity(.2),
            offset: Offset(5.0, 6.0),
          ),
        ]);
    // print("----------------alarm tab build");
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;

    TextStyle clockStyle = TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w800,
      fontSize: 65,
      color: Color.fromARGB(255, 235, 235, 235),
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
                  print(_alarmTime);
                  prefs.setBool('alarmTimeSet', true);
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
      color: Color.fromARGB(255, 235, 235, 235),
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
              // print("onTimeChange");
              setState(() {
                var setAlarm = prefs.getBool('alarmTimeSet');
                if (!setAlarm)
                  prefs.setString('alarmTime', time.toString().split('.')[0]);
                _alarmTime = time;
                print(_alarmTime);
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
}
