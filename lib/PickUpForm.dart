import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'variables.dart';

class PickupPage extends StatefulWidget {
  final int carId;

  const PickupPage({Key? key, required this.carId}) : super(key: key);

  @override
  _PickupPageState createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  final _formKey = GlobalKey<FormState>();
  final _pickupDateController = TextEditingController();
  final _amountController = TextEditingController();
  final _daysController = TextEditingController();

  String? _carImage;
  String? _carPrice;
  String? _carBrand;
  String? _carName;

  @override
  void initState() {
    super.initState();
    fetchCarDetails(widget.carId);
  }

  Future<void> fetchCarDetails(int carId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$ipaddress/cars/$carId'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _carImage = data['image'];
          _carPrice = data['price'];
          _carBrand = data['brand'];
          _carName = data['name'];
        });
      } else {
        print('Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load car details: $e');
    }
  }

      Future<void> cancelReservation(int carId) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
         final String? token = prefs.getString('token');
        var response = await http.post(
          Uri.parse('$ipaddress/rent/$carId/cancel'),
          headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',

          },
        );

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirmation'),
                content: Text('Reservation cancelled successfully.'),
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
        } else {
          // handle error
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to cancel')),
              );
        }
      }

  Future<void> pickupCar(int carId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$ipaddress/rent/${carId}/pickup'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'pickup_date': _pickupDateController.text,
        'amount': _amountController.text,
        'days': _daysController.text,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text(
                'Car picked up successfully. \nPlease pay: ${data['total_price']} at the shop'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick up car')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
         backgroundColor: Colors.grey.shade500.withOpacity(0.4),
        title: Text('Set your Pickup Date'),
      ),
      body: Container(
        // Set background color to blue-grey
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Remove Car ID Text
                  Center(
                    child: Text(
                      'Brand: $_carBrand', // Brand
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                  ),
                  Center(
                    child: Text(
                      _carName ?? '', // Model Name
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Price/Day: $_carPrice', // Price
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                  ),

                  Image.network(_carImage ?? ''),
                  TextFormField(
                    controller: _pickupDateController,
                    decoration: InputDecoration(
                      prefixIcon:
                          Icon(Icons.calendar_today, color: Colors.black),
                      labelText: 'Set your Pickup Date',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pickup date';
                      }
                      return null;
                    },
                    onTap: () async {
                      FocusScope.of(context).requestFocus(
                          new FocusNode()); // to prevent opening the onscreen keyboard
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        _pickupDateController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                        final numberOfDays =
                            picked.difference(DateTime.now()).inDays +
                                1; // +1 to include the current day
                        if (_carPrice != null) {
                          _amountController.text =
                              (_carPrice! * numberOfDays).toString();
                        } else {
                          // _carPrice is null, handle this case as you see fit
                          _amountController.text = 'Price not available';
                        }
                      }
                      ;
                    },
                  ),

                  TextFormField(
                    controller: _daysController,
                    decoration: InputDecoration(
                      labelText: 'Number of days',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of days';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final proceed = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmation'),
                                content: Text('Do you want to continue?'),
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

                          if (proceed) {
                            pickupCar(widget.carId);
                          }
                        }
                      },
                      child: Text('Submit'),
                    )
                  ),
                  Center (
                    child: ElevatedButton(
                      onPressed: () async {
                        final proceed = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirmation'),
                              content: Text('Do you want to cancel the reservation?'),
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

                        if (proceed) {
                          cancelReservation(widget.carId);
                        }
                      },
                      child: Text('Cancel Reservation'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
