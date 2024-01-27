import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'variables.dart';

class Car {
  final String brand;
  final String name;
  final String imageUrl;
  final int pickupCounter;

  Car(this.brand, this.name, this.imageUrl, this.pickupCounter);
}



class DashboardPage extends StatelessWidget {
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
            return CarChart(cars: snapshot.data!);
          }
        },
      ),
    );
  }

  Future<List<Car>> fetchCarData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.get(Uri.parse('$ipaddress/cars/mostrented'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},

    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> carList = data['cars'];
       return carList.map((item) => Car(item['brand'], item['name'], item['image'], item['pickup_counter'])).toList();
    } else {
      throw Exception('Failed to load car data');
    }
  }
}


class CarChart extends StatelessWidget {
  final List<Car> cars;

  CarChart({required this.cars});

  @override
  Widget build(BuildContext context) {
    Map<String, int> brandPickupCounters = {};
    for (var car in cars) {
      if (brandPickupCounters.containsKey(car.brand)) {
        brandPickupCounters[car.brand] = (brandPickupCounters[car.brand] ?? 0) + car.pickupCounter;
      } else {
        brandPickupCounters[car.brand] = car.pickupCounter;
      }
    }


    List<charts.Series<Car, String>> seriesList = [
      charts.Series<Car, String>(
        id: 'PickupCounter',
        domainFn: (Car car, _) => car.name,
        measureFn: (Car car, _) => car.pickupCounter,
        data: cars,
      )
    ];

    return charts.BarChart(seriesList);
  }
}