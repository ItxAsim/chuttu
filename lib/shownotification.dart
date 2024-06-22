import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_services.dart';
import 'notification_services.dart';

class shownotification extends StatefulWidget {
  @override
  _shownotificationState createState() => _shownotificationState();
}

class _shownotificationState extends State<shownotification> {
  final NotificationServices _notificationServices = NotificationServices();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _notificationServices.requestNotificationPermission();
    _notificationServices.firebaseInit(context);
    _notificationServices.setupInteractMessage(context);
    _notificationServices.isTokenRefresh();
  }

  Future<void> _sendDummyNotification() async {
    String deviceToken = await _notificationServices.getDeviceToken();
    String accessToken = await _authService.getAccessToken();

    var data = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': 'Dummy Notification',
          'body': 'This is a test notification.',
        },
        'android': {
          'notification': {
            'notification_count': 1,
          },
        },
        'data': {
          'type': 'msj',
          'id': 'dummy_id',
        }
      }
    };

    var response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/chuttu-29802/messages:send'),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully.');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _sendDummyNotification,
          child: Text('Send Dummy Notification'),
        ),
      ),
    );
  }
}
