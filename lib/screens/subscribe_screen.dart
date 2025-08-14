import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  final String backendUrl = "http://localhost:3000";

  Future<void> _subscribe() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final res = await http.post(
        Uri.parse("$backendUrl/subscribe"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _emailController.text}),
      );

      final data = jsonDecode(res.body);
      setState(() {
        _message = data['message'] ?? 'Something happened';
      });
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _unsubscribe() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final res = await http.post(
        Uri.parse("$backendUrl/unsubscribe"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _emailController.text}),
      );

      final data = jsonDecode(res.body);
      setState(() {
        _message = data['message'] ?? 'Something happened';
      });
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather Email Alerts")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Enter your email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _subscribe,
                      child: const Text("Subscribe"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: _unsubscribe,
                      child: const Text("Unsubscribe"),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (_message != null)
              Text(
                _message!,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
