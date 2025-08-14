import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  String _message = 'Verifying...';

  @override
  void initState() {
    super.initState();
    _handleConfirmation();
  }

  Future<void> _handleConfirmation() async {
    final token = Uri.base.queryParameters['token'];
    if (token != null) {
      final query = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('token', isEqualTo: token)
          .get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({'confirmed': true});
        setState(() => _message = 'Subscription confirmed! You can now close this page.');
      } else {
        setState(() => _message = 'Invalid or expired token.');
      }
    } else {
      setState(() => _message = 'No token provided.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Confirm Subscription',
          style: GoogleFonts.rubik(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5A7BD0),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _message,
            style: GoogleFonts.rubik(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}