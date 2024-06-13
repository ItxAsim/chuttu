import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'SelectionLocation.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String professionalId;
  final int gigindex;

  OrderDetailsScreen({required this.professionalId, required this.gigindex});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? paymentIntentData;
  String price = '';
  bool isLoading = false;
  String userName = '';
  String phoneNumber = '';
  String location = '';
  String title = '';
  String details = '';
  String payment = '';



  @override
  void initState() {
    super.initState();
    getprice();
  }

  Future<void> getprice() async {
    final DocumentSnapshot professionalDoc =
    await FirebaseFirestore.instance
        .collection('perfessionals')
        .doc(widget.professionalId)
        .get();
    if (professionalDoc.exists) {
      final List<dynamic> gigs = professionalDoc['gigs'] ?? [];
      price = gigs[widget.gigindex]['price'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Your Details:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => userName = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) => phoneNumber = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Details'),
                onChanged: (value) => details = value,
              ),
              SizedBox(height: 20),
              Text('Location: $location'),
              ElevatedButton(
                onPressed: () async {
                  final selectedAddress = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectLocationScreen()),
                  );
                  if (selectedAddress != null) {
                    setState(() {
                      location = selectedAddress;
                    });
                  }
                },
                child: Text('Select Location'),
              ),
              SizedBox(height: 20),
              Text("Choose Payment method"),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        payment = 'cash in hand';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Cash in hand Selected successfully'),
                        ),
                      );
                    },
                    child: Text("Cash in Hand"),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await makePayment();
                    },
                    child: Text('Pay with Card'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() => isLoading = true);
                  try {
                    final User? user = _auth.currentUser;
                    final DocumentSnapshot professionalDoc =
                    await FirebaseFirestore.instance
                        .collection('perfessionals')
                        .doc(widget.professionalId)
                        .get();
                    if (professionalDoc.exists) {
                      final List<dynamic> gigs = professionalDoc['gigs'] ?? [];
                      title = gigs[widget.gigindex]['title'];
                      price = gigs[widget.gigindex]['price'];
                      setState(() {});
                    }

                    final orderId =
                        FirebaseFirestore.instance.collection('orders').doc().id;

                    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
                      'id': orderId,
                      'customer_id': user?.uid,
                      'customer_email': user?.email,
                      'userName': userName,
                      'phoneNumber': phoneNumber,
                      'location': location,
                      'title': title,
                      'price': price,
                      'details': details,
                      'status': 'pending',
                      'payment': payment,
                      'professionalId': widget.professionalId,
                      'gigindex': widget.gigindex,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Order submitted successfully!'),
                      ),
                    );

                    setState(() {
                      userName = '';
                      phoneNumber = '';
                      location = '';
                    });
                    Navigator.pop(context);
                  } catch (error) {
                    print(error);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('An error occurred: $error'),
                      ),
                    );
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                child: isLoading ? CircularProgressIndicator() : Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent('20', 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: 'sk_test_51PKey5RqpLRvpy66026DAL2U96UAKIrKYXiy7sfu9axdFdhA6TGYnzTqrWESzEEnm3g5Nvfeg8dAb6uDtFqv2lZU00GJ7Aj09N',
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          customFlow: true,
          style: ThemeMode.dark,
          merchantDisplayName: 'Chuttu',
        ),
      );
      displayPaymentSheet();
    } catch (e, s) {
      print('Payment exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((newValue) {
        print('payment intent' + paymentIntentData!['id'].toString());
        print('payment intent' + paymentIntentData!['client_secret'].toString());
        print('payment intent' + paymentIntentData!['amount'].toString());
        print('payment intent' + paymentIntentData.toString());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntentData = null;
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text("Cancelled "),
          ));
    } catch (e) {
      print('$e');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(price),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer ' + 'sk_test_51PKey5RqpLRvpy66026DAL2U96UAKIrKYXiy7sfu9axdFdhA6TGYnzTqrWESzEEnm3g5Nvfeg8dAb6uDtFqv2lZU00GJ7Aj09N',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
      throw Exception('Failed to create payment intent: $err');
    }
  }

  String calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }
}

