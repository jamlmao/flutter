import 'package:finals/UserReservedCar.dart';
import 'package:finals/cars.dart';
import 'package:finals/variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'carlist.dart';
import 'main.dart';


void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}


      Future<List<dynamic>> fetchMostRentedCars() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('token');

        final response = await http.get(
          Uri.parse('$ipaddress/cars/mostrented'),
          headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
           // Print received data
          return data['cars'];
        } else {
          print('Failed to load most rented cars. Status code: ${response.statusCode}');
          throw Exception('Failed to load most rented cars');
        }
      }


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

      // Navigate to different pages based on the selected tab
      switch (_currentIndex) {
        case 0:
          // Navigate to CarViewPage for "View Cars" tab
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  ViewCars()),
          );
        case 1:
          // Navigate to reserve Cars page for the respective tab
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>   UserRentedCarPage()),
          );

          break;
        case 2:
          // Navigate to Available Cars page for the respective tab
          // Replace the code below with your desired navigation logic
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CarList()),
          );
          break;
        case 3:
        // Navigate to Available Cars page for the respective tab
        // Replace the code below with your desired navigation logic
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ViewCars()),
          );
          break;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
      bottomNavigationBar: buildBottomNavigationBar(),
      backgroundColor: Colors.blueGrey,
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      actions: <Widget>[
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(child: Text('Log Out'), value: 'logout'),
          ],
          onSelected: (value) {
            if (value == 'logout') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyLogin()),
              );
            }
          },
        ),
      ],
    );
  }

  Widget buildBody() {
    return Stack(
      children: [
        buildTopContainer(),
        buildMostRentedCarsContainer(),
      ],
    );
  }

  Widget buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.grey.shade400,
    );
  }

  Widget buildTopContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.only(top: 10),
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white38, Colors.black26],
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: buildTopContainerContent(),
      ),
    );
  }

  Widget buildTopContainerContent() {
    return Container(
      color:Colors.grey,
      child:Stack(
      children: [
        Positioned(
          left: 5,
          top: 15,
          child: Image.asset(
            'assets/bg.png',
            width: MediaQuery.of(context).size.width /2,
            height: MediaQuery.of(context).size.height /6,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.5,
          top: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome!',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Rent your Dream Car',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
              Text(
                'Here with us!',
               style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            ],
          ),
        ),
      ],
    ),
    );
  }



    Widget buildMostRentedCarsContainer() {
      return Align(
        alignment: Alignment.bottomCenter, // Align to the bottom
        child: Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2 + 10),
          height: MediaQuery.of(context).size.height * 0.7, // Increase the height
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: buildMostRentedCars(),
        ),
      );
    }

      Widget buildMostRentedCars() {
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: FutureBuilder<List<dynamic>>(
            future: fetchMostRentedCars(),
            builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!.isEmpty
                    ? Center(
                  child: Text(
                    'No cars are available.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
                    : ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var car = snapshot.data![index];
                    return Card(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 7,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white38, Colors.grey],
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Center(
                            child: ListTile(
                              leading: Image.network(
                                '${car['image']}',
                                width: 110.0,
                                height: 105.0,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                '${car['brand']}',
                                style: TextStyle(
                                    fontSize: 18, fontStyle: FontStyle.italic),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${car['name']}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontStyle: FontStyle.italic)),
                                  Text(
                                      'Rent counter: ${car['pickup_counter']}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'No cars are available.',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        );
      }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: _currentIndex,
      backgroundColor: Colors.blueGrey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'View Cars',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.car_rental),
          label: 'Reserved Cars',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_taxi),
          label: 'Available Cars',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Rented Cars',
        ),
      ],
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.blue,
    );
  }


}