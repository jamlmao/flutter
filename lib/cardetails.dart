import 'package:finals/variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CarDetailsPage extends StatefulWidget {
  final dynamic car;

  CarDetailsPage({Key? key, required this.car}) : super(key: key);

  @override
  _CarDetailsPageState createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  Future<void> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$ipaddress/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<bool> reserveCar(int carId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$ipaddress/rent/$carId/reserve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      var errorData = jsonDecode(response.body);
      throw Exception('Failed to reserve car: ${errorData['message']}');
    }

    return true;
  }

  Future<bool?> _showCancelConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Reservation'),
          content: Text('Are you sure you want to cancel the reservation?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Colors.grey.shade500.withOpacity(0.4),
        title: Text('Car Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.network(widget.car['image']),
            Text('Brand: ${widget.car['brand']}'),
            Text('Price: ${widget.car['price']}'),
            Text('Rents: ${widget.car['pickup_counter']}'),
            Text('Description: ${widget.car['desc']}'),
            ElevatedButton(
              onPressed: () async {
                bool? userConfirmed = await _showCancelConfirmation(context);
                if (userConfirmed != null && userConfirmed) {
                  getUserId().then((userId) {
                    if (widget.car['id'] != null && widget.car['id'] is int) {
                      reserveCar(widget.car['id']).then((reserved) {
                        if (reserved) {
                          Navigator.of(context).pop(reserved);
                        }
                      }).catchError((e) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Success'),
                              content: Text('Car reserved successfully!'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                   Navigator.popUntil(context, ModalRoute.withName('/'));
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }).catchError((e) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('Failed to reserve car: $e'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      });
                    }
                  });
                }
              },
              child: Text('Reserve Car'),
            ),
          ],
        ),
      ),
    );
  }
}
