import 'package:flutter/material.dart';

import 'Servicedetailspage.dart';

class ServicePage extends StatelessWidget {
  final List<String> services = [
    'Home maintance services',
    'beauty & Prsonal care',
    'Tailoring services',
    'car maintaince',

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
      ),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailsPage(serviceName: services[index]),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  services[index],
                  style: TextStyle(fontSize: 20.0),
                ),
                leading: Icon(Icons.star),
                trailing: Icon(Icons.arrow_forward),
              ),
            ),
          );
        },
      ),
    );
  }
}
