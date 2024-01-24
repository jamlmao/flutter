import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'variables.dart';

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
      body: Container(
        padding: const EdgeInsets.only(top: 20.0),
        color: Colors.grey.shade100,
        child: ListView.builder(
          itemCount: rentedCars.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final String? token = prefs.getString('token');

                bool? shouldReturn = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Return Car'),
                      content: Text('Do you want to return this car?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (shouldReturn == true) {
                  // Call the API to return the car
                  try {
                    final carId = rentedCars[index]['car_id'];
                    final response = await http.put(
                      Uri.parse('$ipaddress/rent/$carId/return'),
                      headers: {
                        'Authorization': 'Bearer $token',
                        'Accept': 'application/json'
                      },
                    );

                    if (response.statusCode == 200) {
                      final responseData = jsonDecode(response.body);
                      print('Response data: $responseData');
                      print('Car returned successfully');
                      // Refresh the list of rented cars
                      fetchRentedCars();
                    } else {
                      print(
                          'Failed to return car. Status code: ${response.statusCode}');
                      print('Response body: ${response.body}');
                      throw Exception('Failed to return car');
                    }
                  } catch (e) {
                    print('Failed to return car: $e');
                  }
                }
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Colors.blueGrey,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListTile(
                      leading: Container(
                        width: 105,
                        height: 120,
                        child: Image.network(rentedCars[index]['car_image']),
                      ),
                      title: Text(rentedCars[index]['car_name']),
                      subtitle: Text(
                          'Brand: ${rentedCars[index]['car_brand']}\nReturn Date: ${rentedCars[index]['return_date']}'),
                      trailing: Icon(Icons.assignment_return),
                  ),
                ),
              ),
              );
          },
        ),
      ),
    );
  }
}




