import 'dart:convert';

import '../model/api_response.dart';
import 'package:http/http.dart' as http;

import '../model/user.dart';
import '../variables.dart';

Future<ApiResponse> login(String email, String password) async {
  ApiResponse apiResponse = ApiResponse();

  try {
    final response = await http.post(Uri.parse('$ipaddress/login'),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password});

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['message'];
        apiResponse.error = errors;
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
       apiResponse.error = jsonDecode(response.body)['message'];
        break;
    }
  } catch (e) {
    apiResponse.error = 'Something went wrong.';
    
  }

  return apiResponse;
}

Future<ApiResponse> register(String name, String email, String password) async {
  ApiResponse apiResponse = ApiResponse();

  try {
    final response = await http.post(Uri.parse('$ipaddress/register'),
        headers: {'Accept': 'application/json'},
        body: {'name': name, 'email': email, 'password': password});

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['Success'];
        break;
      case 422:
        final errors = jsonDecode(response.body)['message'];
        apiResponse.error = errors;
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        apiResponse.error = "Something went wrong.";
        break;
    }
  } catch (e) {
    apiResponse.error = "Something went wrong.";
  }

  return apiResponse;
}


