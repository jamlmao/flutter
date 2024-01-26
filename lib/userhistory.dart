import 'dart:convert';

import 'package:finals/variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'PickUpForm.dart';


void main() {
  runApp(MaterialApp(
    home: History(),
  ));
}

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {

 Future<List<dynamic>> fetchUserRentalHistory() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('$ipaddress/rent/history'),
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );


  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return data['rentedCars'];
  } else {
    throw Exception('Failed to load rental history');
  }
}



  Future<void> _refresh() async {
    setState(() {}); // Add your refresh logic here
  }

  





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade500.withOpacity(0.4),
        title: Text('History'),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20.0),
        color: Colors.grey.shade100,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<dynamic>>(
            future: fetchUserRentalHistory(),
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
                      var car = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
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
                              leading: car['car_image'] != null
                                  ? Image.network(car['car_image'])
                                  : null,
                              title: Text(car['car_brand'] ?? ''),
                              subtitle: Text('Return Date: ${car['return_date'] ?? ''}'),
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
