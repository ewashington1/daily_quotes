import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const DailyQuoteApp());
}

class DailyQuoteApp extends StatelessWidget {
  const DailyQuoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Quote App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QuotePage(title: 'Daily Quote'),
    );
  }
}

class QuotePage extends StatefulWidget {
  const QuotePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  Quote? _quote;
  String? _selectedCategory = 'happiness'; // default category

  // Complete categories list
  List<String> _categories = [
    'age', 'alone', 'amazing', 'anger', 'architecture', 'art', 'attitude',
    'beauty', 'best', 'birthday', 'business', 'car', 'change', 'communications',
    'computers', 'cool', 'courage', 'dad', 'dating', 'death', 'design', 'dreams',
    'education', 'environmental', 'equality', 'experience', 'failure', 'faith',
    'family', 'famous', 'fear', 'fitness', 'food', 'forgiveness', 'freedom',
    'friendship', 'funny', 'future', 'god', 'good', 'government', 'graduation',
    'great', 'happiness', 'health', 'history', 'home', 'hope', 'humor',
    'imagination', 'inspirational', 'intelligence', 'jealousy', 'knowledge',
    'leadership', 'learning', 'legal', 'life', 'love', 'marriage', 'medical',
    'men', 'mom', 'money', 'morning', 'movies', 'success'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              items: _categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            _quote == null
                ? const Text(
              'Press the button to fetch a quote.',
              style: TextStyle(fontSize: 18.0),
            )
                : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Text(
                    '"' + _quote!.quote + '"',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '- ' + _quote!.author,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchQuote,
        tooltip: 'Fetch a new quote',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<void> _fetchQuote() async {
    final String url =
        'https://api.api-ninjas.com/v1/quotes?category=$_selectedCategory';
    final response = await http.get(
      Uri.parse(url),
      headers: {'X-Api-Key': dotenv.env['API_KEY']!},
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        _quote = Quote.fromJson(json[0]);
      });
    } else {
      throw Exception('Failed to load quote');
    }
  }
}

class Quote {
  Quote({required this.quote, required this.author, required this.category});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      quote: json['quote'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
    );
  }

  final String quote;
  final String author;
  final String category;
}
