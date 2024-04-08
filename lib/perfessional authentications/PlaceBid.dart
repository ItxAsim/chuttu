import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfessionalBidPage extends StatefulWidget {
  final String problemId;

  ProfessionalBidPage({required this.problemId});

  @override
  _ProfessionalBidPageState createState() => _ProfessionalBidPageState();
}

class _ProfessionalBidPageState extends State<ProfessionalBidPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitBid() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid, submit bid
      String description = _descriptionController.text;
      double price = double.parse(_priceController.text);

      setState(() {
        _isSubmitting = true;
      });

      try {
        // Save bid data to Firestore
        await FirebaseFirestore.instance.collection('bids').add({
          'problemId': widget.problemId,
          'professionalId': FirebaseAuth.instance.currentUser?.uid,
          'description': description,
          'price': price,
          'status': 'Pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Clear text fields
        _descriptionController.clear();
        _priceController.clear();

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bid submitted successfully'),
          ),
        );
      } catch (error) {
        print('Error submitting bid: $error');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit bid. Please try again later.'),
          ),
        );
      } finally {
        // Reset submitting state
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Bid'),
      ),
      body: _isSubmitting
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price (\$)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  // Validate if the entered value is a valid number
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitBid,
                child: Text('Submit Bid'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
