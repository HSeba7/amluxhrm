import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

class ApiService {
  static Future<Map<String, dynamic>?> postClockInOut({
    required String name,
    required String surname,
    required String birthYear,
    required String cardResponse,
    required String objectName,
    required String actionType,
  }) async {
    var headers = {'Content-Type': 'application/json'};
    var responseBody = json.encode({
      "name": name,
      "surname": surname,
      "birthyear": birthYear,
      "card_response": cardResponse,
      "object_name": objectName,
      "action_type": actionType
    });

    var response = await http.post(Uri.parse(ApiConstants.clockApi),
        headers: headers, body: responseBody);

    print("show response status code---${response.statusCode}");
    print("show response body---${response.body}");

    try {
      var jsonBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonBody};
      } else if (response.statusCode == 400 && jsonBody["error"] != null) {
        return {"success": false, "error": jsonBody["error"]};
      } else {
        return {"success": false, "error": jsonBody["error"]};
      }
    } catch (e) {
      var jsonBody = json.decode(response.body);
      return {"success": false, "error": jsonBody["error"]};
    }
  }

// static postClockInOut({
//   required String name,
//   required String surname,
//   required String birthYear,
//   required String cardResponse,
//   required String objectName,
//   required String actionType,
// }) async {
//   var headers = {'Content-Type': 'application/json'};
//   var responseBody = json.encode({
//     "name": name,
//     "surname": surname,
//     "birthyear": birthYear,
//     "card_response": cardResponse,
//     "object_name": objectName,
//     "action_type": actionType
//   });
//
//   var response = await http.post(Uri.parse(ApiConstants.clockApi),
//       headers: headers, body: responseBody);
//   print("show response status code---${response.statusCode}");
//   print("show response body---${response.body}");
//   if (response.statusCode == 200) {
//     var res = json.decode(response.body);
//     return res;
//   } else if (response.statusCode == 400) {
//     var responseBody = jsonDecode(response.body);
//     if (responseBody is Map && responseBody.containsKey("error")) {
//       Get.snackbar('Error', responseBody["error"],
//           backgroundColor: Colors.white, colorText: Colors.red);
//     }
//   } else {
//     print(response.reasonPhrase);
//   }
// }
}
