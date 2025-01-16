import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  // Track the expanded state of each question
  Map<int, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text('FAQ', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Add search functionality here
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Enter your keyword',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCategoryCard('Questions\nabout Started',
                            Icons.notifications, Colors.blue[100]!),
                        _buildCategoryCard('Questions\nabout Invest',
                            Icons.security, Colors.green[100]!),
                        _buildCategoryCard('Questions\nabout Stocks',
                            Icons.analytics, Colors.red[100]!),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildFAQItem(0, 'How to create a account?',
                        'Open the Tradebase app to get started and follow the steps. Tradebase doesn’t charge a fee to create or maintain your Tradebase account.'),
                    _buildFAQItem(
                        1, 'How to add a payment method by this app?', null),
                    _buildFAQItem(
                        2, 'What Time Does The Stock Market Open?', null),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.black),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(int index, String question, String? answer) {
    return Card(
      color: Colors.grey[900],
      child: ExpansionTile(
        key: PageStorageKey<int>(index),
        initiallyExpanded: _expanded[index] ?? false,
        onExpansionChanged: (bool expanded) {
          setState(() {
            _expanded[index] = expanded;
          });
        },
        title: Text(
          question,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        children: answer != null
            ? [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    answer,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}
