import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../history_helper.dart';
import '../models/history_model.dart';

class HistoryTab extends StatefulWidget {
  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<History> _allHistory;

  final tableTitleStyle = TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w500,
      color: Colors.black,
      fontSize: 17,
      height: 1.8);

  final tableDetailStyle = TextStyle(
    fontFamily: "AppleSDGothicNeo",
    fontWeight: FontWeight.w400,
    color: Colors.black,
    fontSize: 15,
  );

  final BoxDecoration _tableDecoration = BoxDecoration(
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

  Future<int> loadHistory() async {
    // print("load all history");
    // print(DateFormat('yy-MM-dd').format(DateTime.now()));
    _allHistory = await HistoryHelper().getAllHistory();
    // print("_allHistory :${_allHistory}");
    // print(_allHistory.length);
    setState(() {});
    return _allHistory.length;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return FutureBuilder(
      future: loadHistory(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            width: _width,
            height: _height,
            color: Color.fromARGB(255, 35, 37, 43),
            padding: EdgeInsets.all(20).copyWith(top: 35),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: _width * 0.9,
                  height: _height * 0.8,
                  decoration: _tableDecoration,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: _height * 0.01,
                      ),
                      Wrap(
                        children: [
                          Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: {
                              0: FractionColumnWidth(.26),
                              1: FractionColumnWidth(.4),
                              2: FractionColumnWidth(.34),
                            },
                            children: [
                              // title of each columns
                              TableRow(
                                  // Title of each Column
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(0, 0, 0, 0),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color.fromARGB(255, 35, 37, 43),
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 1.5),
                                      child: Text(
                                        "Date",
                                        style: tableTitleStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 1.5),
                                      child: Text(
                                        "TimeExceeded",
                                        style: tableTitleStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 1.5),
                                      child: Text(
                                        "Penalty",
                                        style: tableTitleStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ]),
                            ],
                          )
                        ],
                      ),
                      Flexible(
                        child: snapshot.data == 0
                            ? Container(
                                child: Center(
                                  child: Text("there is no history",
                                      style: tableDetailStyle),
                                ),
                              )
                            : SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Table(
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  columnWidths: {
                                    0: FractionColumnWidth(.27),
                                    1: FractionColumnWidth(.39),
                                    2: FractionColumnWidth(.34),
                                  },
                                  children: [
                                    for (int i = 0; i < snapshot.data; i++)
                                      dataRow(i),
                                  ],
                                ),
                              ),
                      ),
                      SizedBox(
                        height: _height * 0.01,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  TableRow dataRow(int i) {
    History history = _allHistory[i];
    String date = DateFormat('yy-MM-dd').format(history.date);
    return TableRow(
        decoration: BoxDecoration(
          color: Color.fromARGB(0, 0, 0, 0),
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              date,
              style: tableDetailStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              history.timeExceeded.toString() + " min",
              style: tableDetailStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              history.penalty.toString(),
              style: tableDetailStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ]);
  }
}
