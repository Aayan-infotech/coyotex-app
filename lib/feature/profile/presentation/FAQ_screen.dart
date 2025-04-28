import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  // Track the expanded state of each question
  final Map<int, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('FAQ', style: TextStyle(color: Colors.white)),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.search, color: Colors.white),
          //   onPressed: () {
          //     // Add search functionality here
          //   },
          // ),
        ],
      ),
      body: Container(
      color: Colors.black,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
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
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildFAQItem(
                  0,
                  'Can I use Coyotex without an internet connection?',
                  'No, Coyotex requires an active internet connection to access maps, weather data, and sync your hunting logs.',
                ),
                _buildFAQItem(
                  1,
                  'How do I track wind direction and weather?',
                  'Coyotex integrates real-time and hyperlocal weather data, including wind direction. You’ll find it in your hunt dashboard while planning or during a session.',
                ),
                _buildFAQItem(
                  2,
                  'Does Coyotex support multiple hunting areas or states?',
                  'Yes, you can manage multiple hunting zones, and Coyotex adjusts weather and legal compliance info based on your selected region.',
                ),
                _buildFAQItem(
                  3,
                  'How do I create and manage hunting trips?',
                  'Go to the “Map” tab, tap on map “Create Trip,” and enter your details. You can start a hunt, track activity, mark routes, and save notes based on weather and terrain.',
                ),
                _buildFAQItem(
                  4,
                  'How does Coyotex track my movement during a hunt?',
                  'Coyotex uses your phone’s built-in GPS to display your real-time location and record your route with a blue tracking line, helping you retrace your path or plan better next time.',
                ),
                _buildFAQItem(
                  5,
                  'Can I save and review past hunting routes?',
                  'Yes, all recorded routes during a trip are saved. You can revisit them anytime from your trip history to analyze patterns or prepare for future hunts.',
                ),
                 SizedBox(height: MediaQuery.sizeOf(context).height*0.1),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'For support, please contact us at: \nhunt30@gmail.com',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.black),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(int index, String question, String? answer) {
    return Card(
      color: Colors.grey[900],
      child: ExpansionTile(
        iconColor: Colors.white,
        key: PageStorageKey<int>(index),
        initiallyExpanded: _expanded[index] ?? false,
        onExpansionChanged: (bool expanded) {
          setState(() {
            _expanded[index] = expanded;
          });
        },
        title: Text(
          question,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        children: answer != null
            ? [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    answer,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}
