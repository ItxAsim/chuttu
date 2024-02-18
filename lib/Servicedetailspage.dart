import 'package:flutter/material.dart';

class ServiceDetailsPage extends StatelessWidget {
  final String serviceName;

  ServiceDetailsPage({required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details of $serviceName',
                style: TextStyle(fontSize: 24.0),
              ),
              SizedBox(height: 20),
              ServiceCard(
                title: 'Home Maintenance',
                description: 'We provide home maintenance services including plumbing, electrical repairs, painting, and more.',
              ),
              ServiceCard(
                title: 'pLumber',
                description: 'We provide home maintenance services including plumbing,',
              ),
              ServiceCard(
                title: 'elctrical repairs',
                description: 'We provide home maintenance services including Electrical ',
              ),
              ServiceCard(
                title: 'Painting',
                description: 'We provide home maintenance services including Painting',
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String description;

  ServiceCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}