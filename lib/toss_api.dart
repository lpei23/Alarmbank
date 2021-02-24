import 'package:dio/dio.dart';
import 'dart:async';

const tossAPIKey = '1d37c6abb67948ebbc65762e0d1659f5';
const createButtonUrl = 'https://toss.im/transfer-web/linkgen-api/link';

Future<String> openToss(String bankName, String accountNo, int penalty) async {
  print('openToss');
  try {
    final response = await Dio(BaseOptions(headers: {'Content-Type': 'application/json'})).post(
      createButtonUrl,
      data: {
        'apiKey': tossAPIKey,
        'bankName': bankName,
        'bankAccountNo': accountNo,
        'amount': penalty,
      }
    );
    print("get response");
    if (response.statusCode == 200) {
      var rawData = response.data;
      print(rawData);
      print(rawData['success']['link']);
      return rawData['success']['link'];
    }
  }catch(err){
    print(err);
    return "no/network";
  }
}