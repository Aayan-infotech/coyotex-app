import 'package:coyotex/core/services/model/notification_model.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UserViewModel>(context, listen: false).getNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Notification",
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const NotificationScreen();
                }));
              },
              child: const Icon(Icons.notifications))
        ],
      ),
      body: Consumer<UserViewModel>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (provider.lstNotification.isEmpty) {
            return const Center(
              child: Text(
                "No notifications available.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Your latest notifications will appear here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.lstNotification.length,
                    itemBuilder: (context, index) {
                      NotificationModel notification =
                          provider.lstNotification[index];
                      return _buildNotificationCard(
                        notification.title,
                        notification.body,
                        notification.createdAt,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(String title, String content, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child:
                const Icon(Icons.notifications, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
