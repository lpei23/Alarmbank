import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:alarm_with_bank_transfer/history_helper.dart';
import 'package:alarm_with_bank_transfer/toss_api.dart';

import 'package:alarm_with_bank_transfer/views/alarm.dart';
import 'package:alarm_with_bank_transfer/views/setting.dart';
import 'package:alarm_with_bank_transfer/views/history.dart';
import 'package:alarm_with_bank_transfer/views/dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  SharedPreferences prefs;
  int _leftPenalty;
  bool ischecked = false;
  String _receivedAccountNo;
  String _receivedBankName;

  final TextStyle tabBarStyle = TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w400,
      fontSize: 21,
      color: Color.fromARGB(255, 202, 194, 186));

  @override
  void initState() {
    HistoryHelper().database.then((value) {
      print("----------initialize history database");
    });
    super.initState();
  }

  void checkleftPenalty() async {
    print('check left penalty');
    prefs = await SharedPreferences.getInstance();
    _leftPenalty = prefs.getInt('left') ?? 0;
    _receivedAccountNo =
        (prefs.getString('receivedAccountNo') ?? '00000000000000000');
    _receivedBankName = (prefs.getString('receivedBankName') ?? '은행명을 입력해주세요');
    if (_leftPenalty == 0) {
      print('there is no left penalty');
    } else {
      Future.delayed(Duration(seconds: 2), () {
        showDialog(
            context: context,
            builder: (BuildContext context) => PenaltyDialog(
                bankName: _receivedBankName,
                accountNo: _receivedAccountNo,
                left: _leftPenalty));
      });
    }

    setState(() {
      ischecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;

    if (!ischecked) {
      checkleftPenalty();
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Center(
          child: TabBarView(
            children: [
              AlarmTab(),
              SettingTab(),
              HistoryTab(),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Color.fromARGB(255, 35, 37, 43),
          child: Container(
            height: _height * 0.08,
            child: TabBar(
              indicatorColor: Color.fromARGB(255, 156, 143, 128),
              tabs: [
                _tab("Alarm"),
                _tab("Setting"),
                _tab("History"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Tab _tab(String title) {
    return Tab(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: "AppleSDGothicNeo",
            fontWeight: FontWeight.w400,
            fontSize: 24,
            color: Color.fromARGB(255, 202, 194, 186)),
      ),
    );
  }
}

class PenaltyDialog extends StatefulWidget {
  String bankName;
  String accountNo;
  int left;

  PenaltyDialog(
      {@required this.bankName, @required this.accountNo, @required this.left});

  @override
  _PenaltyDialogState createState() => _PenaltyDialogState();
}

class _PenaltyDialogState extends State<PenaltyDialog> {
  SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        titlePadding: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(0),
        backgroundColor: Color.fromARGB(255, 250, 249, 248),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 15, top: 20),
              child: Text("left penalty: ${widget.left}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "AppleSDGothicNeo",
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 18)),
            ),
            Container(
                height: 45,
                child: GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();
                      if (widget.bankName != '은행명을 입력해주세요' &&
                          widget.accountNo != '00000000000000000') {
                        prefs = await SharedPreferences.getInstance();
                        await prefs.setInt('left', 0);
                        print(prefs.getInt('left') ?? 0);
                        var url = await openToss(
                            widget.bankName, widget.accountNo, widget.left);
                        if (url != null) {
                          if (await canLaunch(url)) {
                            await launch(url,
                                forceSafariVC: false, forceWebView: false);
                          }
                        }
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailView(
                                    title: "Receiving Account",
                                    detailIndex: 1)));
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => ErrorDialog(
                                  errorMsg: "fill received Account",
                                ));
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(right: 50, bottom: 10),
                      alignment: Alignment.centerRight,
                      color: Colors.transparent,
                      child: Text(
                        "SEND",
                        style: TextStyle(
                          fontFamily: "AppleSDGothicNeo",
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 255, 80, 80),
                          fontSize: 15,
                        ),
                      ),
                    ))),
          ],
        ));
  }
}
