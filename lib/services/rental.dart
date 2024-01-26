import 'dart:convert';

import 'package:finals/model/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:finals/variables.dart';

class CarServices {
  static Future<ApiResponse> userRentalHistory(String? token) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response = await http.get(
        Uri.parse('$ipaddress/rent/history'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      switch (response.statusCode) {
        case 200:
          apiResponse.data = jsonDecode(response.body)['cars'];
          break;
        case 422:
          final errors = jsonDecode(response.body)['message'];
          apiResponse.error = errors;
          break;
        case 403:
          apiResponse.error = jsonDecode(response.body)['message'];
          break;
        default:
          apiResponse.error = 'Something went wrong.';
          break;
      }
    } catch (e) {
      apiResponse.error = 'Something went wrong.';
    }

    return apiResponse;
  }
}
