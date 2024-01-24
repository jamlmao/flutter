import 'package:finals/variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RentedCarsPage extends StatefulWidget {
  @override
  _RentedCarsPageState createState() => _RentedCarsPageState();
}

class _RentedCarsPageState extends State<RentedCarsPage> {
  List<dynamic> rentedCars = [];

  @override
  void initState() {
    super.initState();
    fetchRentedCars();
  }

  fetchRentedCars() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$ipaddress/rentcars'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('Data received from API: $data');
      if (data['rented_cars'] != null) {
        rentedCars = data['rented_cars'];
      } else {
        rentedCars = [];
      }
      setState(() {});
    } else {
      throw Exception('Failed to load most rented cars');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rented Cars'),
      ),
      body: ListView.builder(
        itemCount: rentedCars.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(rentedCars[index]['car_image']),
            title: Text(rentedCars[index]['car_name']),
            subtitle: Text('Brand: ${rentedCars[index]['car_brand']}\nReturn Date: ${rentedCars[index]['return_date']}'),
          );
        },
      ),
    );
  }
}