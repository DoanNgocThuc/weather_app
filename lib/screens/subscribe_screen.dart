import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      var brevoApiKey = dotenv.env['BREVO_API_KEY'] ?? '';
      var senderEmail = dotenv.env['SENDER_EMAIL'] ?? '';
      final token = const Uuid().v4();

      // Store in Firestore
      await FirebaseFirestore.instance.collection('subscriptions').add({
        'email': _emailController.text.trim(),
        'city': _cityController.text.trim(),
        'confirmed': false,
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send confirmation email via Brevo
      final confirmLink = 'https://weatherapp-c634e.web.app/confirm?token=$token';
      final html = '''
        <p>Confirm your subscription for weather updates in ${_cityController.text.trim()}:</p>
        <p><a href="$confirmLink">Confirm</a></p>
      ''';

      final response = await http.post(
        Uri.parse('https://api.brevo.com/v3/smtp/email'),
        headers: {
          'accept': 'application/json',
          'api-key': brevoApiKey,
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'sender': {'name': 'Weather App', 'email': senderEmail},
          'to': [{'email': _emailController.text.trim()}],
          'subject': 'Confirm Weather Subscription',
          'htmlContent': html,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send email: ${response.body}');
      }

      setState(() {
        _message = 'Confirmation email sent! Please check your inbox.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscribe to Weather Updates',
          style: GoogleFonts.rubik(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5A7BD0),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Get weather updates for your city!',
                            style: GoogleFonts.rubik(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.email),
                              labelStyle: GoogleFonts.rubik(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              labelText: 'City',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.location_city),
                              labelStyle: GoogleFonts.rubik(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a city';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _subscribe,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: const Color(0xFF5A7BD0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Subscribe',
                                      style: GoogleFonts.rubik(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                          if (_message != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _message!,
                              style: GoogleFonts.rubik(
                                fontSize: 16,
                                color: _message!.startsWith('Error') ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}