import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'variables.dart';

class Car {

  final String name;
  final String brand;

  final int pickupCounter;

  Car(this.brand, this.name,  this.pickupCounter);
}




class DashboardPage extends StatelessWidget {

    final List<Color> colorList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
    Colors.brown,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.lime,
  ];

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: FutureBuilder(
        future: fetchCarData(),
        builder: (BuildContext context, AsyncSnapshot<List<Car>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 80, // This creates the "doughnut" hole
                sections: snapshot.data?.asMap()?.map((index, car) => MapEntry(index, PieChartSectionData(
                  color: colorList[index % colorList.length], // Assign color from colorList
                  value: car.pickupCounter.toDouble(),
                  title: car.name,
                )))?.values?.toList(),
              ),
            );
          }
        },
      ),
    );
  }
}

  Future<List<Car>> fetchCarData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.get(Uri.parse('$ipaddress/cars'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},

    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> carList = data['cars'];
       return carList.map((item) => Car(item['brand'], item['name'], item['pickup_counter'])).toList();
    } else {
      throw Exception('Failed to load car data');
    }
  }



