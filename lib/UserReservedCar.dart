import 'dart:convert';

import 'package:finals/variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'PickUpForm.dart';


void main() {
  runApp(MaterialApp(
    home: UserRentedCarPage(),
  ));
}

class UserRentedCarPage extends StatefulWidget {
  @override
  _UserRentedCarPageState createState() => _UserRentedCarPageState();
}

class _UserRentedCarPageState extends State<UserRentedCarPage> {
  Future<List<dynamic>> fetchUserReservedCars() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$ipaddress/user/reserveCars'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['reservedUnpaidCars'];
    } else {
      throw Exception('Failed to load most rented cars');
    }
  }

    


  Future<void> _refresh() async {
    setState(() {}); // Add your refresh logic here
  }

  void _onCarTap(Map car) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickupPage(carId: car['id']), // Pass the car ID
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Colors.grey.shade500.withOpacity(0.4),
        title: Text('Your Reserved Cars'),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20.0),
        color: Colors.grey.shade100,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<dynamic>>(
            future: fetchUserReservedCars(),
            builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('No reserved cars.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No reserved cars.'));
              } else {
                return Center(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      var car = snapshot.data![index]['car'];
                      return GestureDetector(
                        onTap: () => _onCarTap(car),
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
                              leading: Image.network(car['image']),
                              title: Text(car['brand']),
                              subtitle: Text('Rent counter: ${car['pickup_counter']}'),
                              trailing: Icon(Icons.lock_open),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
