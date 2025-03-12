import 'package:flutter/material.dart';
import 'package:ui/Services/NotificationService.dart';
import 'package:provider/provider.dart';
import 'package:ui/Pages/Users/UserProvider.dart';

import '../../Services/RoomService.dart';

class AlertNursePage extends StatefulWidget {
  @override
  _AlertNursePageState createState() => _AlertNursePageState();
}

class _AlertNursePageState extends State<AlertNursePage> {
  String? _selectedUrgency;
  String? _selectedRequest;
  final TextEditingController _customRequestController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 40),
            _buildSectionTitle('Urgentie'),
            const SizedBox(height: 10),
            _buildUrgencyButtons(),
            const SizedBox(height: 40),
            _buildSectionTitle('Verzoek'),
            const SizedBox(height: 5),
            _buildRequestOptions(),
            const SizedBox(height: 20),
            _buildCustomRequestField(),
            const SizedBox(height: 40),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Roep een Verpleegkundige',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildUrgencyButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildUrgencyButton('Verzoek', Colors.blue),
        _buildUrgencyButton('Dringend', Colors.orange),
        _buildUrgencyButton('Nood', Colors.red),
      ],
    );
  }

  Widget _buildUrgencyButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedUrgency = label;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(100, 50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (_selectedUrgency == label)
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Icon(Icons.check, size: 18, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildRequestOptions() {
    return Column(
      children: [
        for (String option in ['Pijn', 'Medicatie', 'Eten/drinken', 'Toilet', 'Hulp'])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _selectedRequest,
              onChanged: (value) {
                setState(() {
                  _selectedRequest = value;
                  _customRequestController.clear();
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCustomRequestField() {
    return TextField(
      controller: _customRequestController,
      onChanged: (text) {
        if (text.isNotEmpty) {
          setState(() {
            _selectedRequest = null;
          });
        }
      },
      decoration: const InputDecoration(
        labelText: 'Ander verzoek',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSendButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (_selectedUrgency != null &&
              (_selectedRequest != null || _customRequestController.text.isNotEmpty)) {

            String message = _selectedUrgency! + ' - ' + (_customRequestController.text.isNotEmpty ? _customRequestController.text : _selectedRequest!);

            final userProvider = Provider.of<UserProvider>(context, listen: false);
            final patient = userProvider.domainUser;

            if (patient == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Geen ingelogde patiënt gevonden.')),
              );
              return;
            }

            try {
              final roomService = RoomService();
              final patientRoom = await roomService.getRoomByUserId(patient.id.toString());

              final notificationData = {
                'message': message,
                'status': _selectedUrgency,
                'timeStamp': DateTime.now().toIso8601String(),
                'patientId': patient.id,
                'roomNumber': patientRoom.roomNumber,
                'patientName': (patient.firstName ?? '') + ' ' + (patient.lastName ?? ''),
              };

              print('Sending notification data: $notificationData');
              await NotificationService.createNotification(notificationData);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verzoek succesvol verzonden!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fout bij verzenden: $e')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selecteer een urgentie en een verzoek.')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Versturen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

}
