import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String professionalId;
  final int gigindex;



  OrderDetailsScreen({required this.professionalId, required this.gigindex,});



  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  get professionalId => professionalId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? paymentIntentData;
  String price='';
  @override
  void initState() {
    // TODO: implement initState
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


    bool isLoading = false;
    String userName = ''; // Variables to store order details
    String phoneNumber = ''; // Initialize with empty strings
    String location = '';
    String title='';

    String details='';
    String payment="";


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
                onChanged: (value) => userName = value, // Update userName when user types
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) => phoneNumber = value, // Update phoneNumber when user types
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                onChanged: (value) => location = value, // Update location when user types
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Details'),
                onChanged: (value) => details = value, // Update location when user types
              ),
              SizedBox(height:20),
              Text("Choose Payment method "),
              SingleChildScrollView(
                child: Row(children: [

                  ElevatedButton(onPressed: ()=>{payment='cash in hand'
                  ,
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Cash in hand Selected successfully'),
                  ),
                  )}, child: Text("Cash in Hand")),
                  SizedBox(width: 20,),
                  ElevatedButton(onPressed:() async =>{await makePayment()} ,
                    child: Text(
                      'Pay with Card',
                    ),
                  ),
                
                ],),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setState(() => isLoading = true); // Set loading state

                  try {
                    final User? user=_auth.currentUser;
                    final DocumentSnapshot professionalDoc =
                    await FirebaseFirestore.instance
                        .collection('perfessionals')
                        .doc(widget.professionalId)
                        .get();
    if (professionalDoc.exists) {
      final List<dynamic> gigs = professionalDoc['gigs'] ?? [];
        title = gigs[widget.gigindex]['title'];
        setState(() {

        });
       price = gigs[widget.gigindex]['price'];
    }


    // Add unique identifier for each order
                    final orderId = FirebaseFirestore.instance.collection('orders').doc().id;

                    // Add order to Firestore
                    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
                      'id': orderId, // Unique order identifier
                      'customer_id':user?.uid,
                      'customer_email':user?.email,
                      'userName': userName,
                      'phoneNumber': phoneNumber,
                      'location': location,
                      'title': title,
                      'price': price,
                      'details':details,
                      'status':'pending',
                      'payment':payment,
                      'professionalId': widget.professionalId,
                      'gigindex': widget.gigindex,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    // Show success message and clear user details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Order submitted successfully!'),
                      ),
                    );


                    setState(() {
                      userName = ''; // Clear user details after successful order
                      phoneNumber = '';
                      location = '';
                    });
                    Navigator.pop(context);
                  } catch (error) {
                    // Handle errors
                    print(error);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('An error occurred: $error'),

                      ),

                    );
                  } finally {
                    setState(() => isLoading = false); // Reset loading state
                  }
                },
                child: isLoading
                    ? CircularProgressIndicator() // Show progress indicator
                    : Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> makePayment() async {
    try {
      paymentIntentData =
      await createPaymentIntent('20', 'USD'); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              setupIntentClientSecret: 'sk_test_51PKey5RqpLRvpy66026DAL2U96UAKIrKYXiy7sfu9axdFdhA6TGYnzTqrWESzEEnm3g5Nvfeg8dAb6uDtFqv2lZU00GJ7Aj09N',
              paymentIntentClientSecret:
              paymentIntentData!['client_secret'],
              //applePay: PaymentSheetApplePay.,
              //googlePay: true,
              //testEnv: true,
              customFlow: true,
              style: ThemeMode.dark,
              // merchantCountryCode: 'US',
              merchantDisplayName: 'Chuttu'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      print('Payment exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
        //       parameters: PresentPaymentSheetParameters(
        // clientSecret: paymentIntentData!['client_secret'],
        // confirmPayment: true,
        // )
      )
          .then((newValue) {
        print('payment intent' + paymentIntentData!['id'].toString());
        print(
            'payment intent' + paymentIntentData!['client_secret'].toString());
        print('payment intent' + paymentIntentData!['amount'].toString());
        print('payment intent' + paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("paid successfully")));

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

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(price),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer ' + 'sk_test_51PKey5RqpLRvpy66026DAL2U96UAKIrKYXiy7sfu9axdFdhA6TGYnzTqrWESzEEnm3g5Nvfeg8dAb6uDtFqv2lZU00GJ7Aj09N',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;

    return a.toString();
  }
}
