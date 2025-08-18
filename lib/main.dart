import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();
  String _prompt = "";
  String _generatedText = "";
  bool _isLoading = false;

  final String _apiKey = "AIzaSyDoJ9XXLMOFVlH0DC82t50sMKUDZhgHUeQ";

  Future<void> _generateText() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
      final content = [Content.text("Make a poster heading" + _prompt)];

      final response = await model.generateContent(content);
      print(response.text);
      setState(() {
        _isLoading = false;

        _generatedText = response.text!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 240, 233, 233)),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 234, 170, 170),
          title: const Text('Adify.io'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name of the event:',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a prompt';
                    }
                    return null;
                  },
                  onSaved: (value) => _prompt = value!,
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _generateText,
                child: const Text('Generate'),
              ),
              const SizedBox(height: 5.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        Image.asset(
                          'assets/background.jpg',
                          height: 600,
                          width: 1700,
                        ),
                        Center(
                          child: Text(
                            _generatedText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 15.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
