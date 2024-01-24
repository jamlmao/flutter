import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
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
          _carName= data['name'];
        });
      } else {
        print('Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load car details: $e');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Car picked up successfully')),
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
        title: Text('Set your Pickup Date'),
      ),
      body: Container(// Set background color to blue-grey
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
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                  ),
                  Center(
                    child:Text(
                    _carName ?? '', // Model Name
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
                  ), 
                  ),
                  Center(
                    child:Text(
                    'Price/Day: $_carPrice', // Price
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  ),

                  Image.network(_carImage ?? ''),
                  TextFormField(
                    controller: _pickupDateController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
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
                      }
                    },
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Please input exact amount ( price x days)',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      return null;
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
                    child:ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        pickupCar(widget.carId);
                      }
                    },
                    child: Text('Submit'),
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
