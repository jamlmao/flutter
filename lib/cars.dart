import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finals/services/car_servicesv2.dart';
import 'package:finals/model/api_response.dart';
import 'package:finals/main.dart';
import 'package:finals/cardetails.dart';
import 'package:transparent_image/transparent_image.dart';

class ViewCars extends StatefulWidget {
  const ViewCars({Key? key}) : super(key: key);

  @override
  State<ViewCars> createState() => _ViewCarsState();
}

class _ViewCarsState extends State<ViewCars> {
  List<dynamic> cars = [];
  bool isRefreshing = false;

  Future<void> getCars() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    ApiResponse response = await getAvailcars(token);

    if (response.error == null) {
      setState(() {
        cars = response.data as List<dynamic>;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  Future<void> _refreshCars() async {
    setState(() {
      isRefreshing = true;
    });

    await getCars();

    setState(() {
      isRefreshing = false;
    });
  }

  @override
  void initState() {
    getCars();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("View Cars"),
          actions: [
            IconButton(
              onPressed: () async {
                final SharedPreferences prefs =
                await SharedPreferences.getInstance();
                await prefs.remove('token');
                await prefs.remove('userId');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MyLogin()),
                );
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: WillPopScope(
          onWillPop: () async {
            // Handle back button press
            return true; // Return true to allow back navigation
          },
          child: RefreshIndicator(
            onRefresh: _refreshCars,
            child: Container(
              color: Colors.grey.shade400,
              child: ListView.builder(
                itemCount: cars.length,
                itemBuilder: (BuildContext context, int index) {
                  Map car = cars[index] as Map;
                  return Card(
                    elevation: 6.0,
                    margin: const EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.blueGrey,
                    child: InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio:
                            16 / 9, // Adjust the aspect ratio as needed
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: car['image'],
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${car['brand']} ${car['name']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${car['price']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const Icon(
                                  Icons.garage,
                                  color: Colors.black,
                                  size: 18,
                                ),
                                Text(
                                  '${car['status']}'.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                               Icon(
                                car['status'] == 'rented' ? Icons.lock : Icons.lock_open,
                                color: Colors.black,
                                size: 18,
                              ),
                              ],
                              
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
