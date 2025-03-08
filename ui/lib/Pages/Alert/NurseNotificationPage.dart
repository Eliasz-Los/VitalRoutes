import 'package:flutter/material.dart';
import 'package:ui/Services/NotificationService.dart';
import '../../Models/NotificationModel.dart';

class NurseNotificationPage extends StatefulWidget {
  final String nurseId;
  const NurseNotificationPage({Key? key, required this.nurseId}) : super(key: key);

  @override
  _NurseNotificationPageState createState() => _NurseNotificationPageState();
}

class _NurseNotificationPageState extends State<NurseNotificationPage> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final data = await NotificationService.getNotificationsForNurse(widget.nurseId);
      setState(() {
        notifications = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching notifications: $e');
    }
  }

  Future<void> updateStatus(String notificationId, String newStatus) async {
    try {
      await NotificationService.updateNotificationStatus(notificationId, newStatus);
      setState(() {
        notifications.firstWhere((n) => n.id == notificationId).status = newStatus;
      });
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  Widget buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        title: Text(
          notification.patientName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Level: ${notification.emergencyLevel}',
              style: TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
            const SizedBox(height: 4),
            Text('Verzoek: ${notification.message}', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text('Status: ${notification.status}', style: TextStyle(fontSize: 14)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            updateStatus(notification.id, value);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'in behandeling',
              child: Text('In behandeling'),
            ),
            const PopupMenuItem(
              value: 'behandeld',
              child: Text('Behandeld'),
            ),
          ],
        ),
        onTap: () {
          // Hier kun je eventueel naar een detailpagina navigeren
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meldingen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchNotifications,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text('Geen meldingen'))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) => buildNotificationCard(notifications[index]),
      ),
    );
  }
}
