import 'package:flutter/material.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            SizedBox(height: 40),
            _buildSectionTitle('Urgentie'),
            SizedBox(height: 10),
            _buildUrgencyButtons(),
            SizedBox(height: 40),
            _buildSectionTitle('Verzoek'),
            SizedBox(height: 5),
            _buildRequestOptions(),
            SizedBox(height: 20),
            _buildCustomRequestField(),
            SizedBox(height: 40),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Roep een Verpleegkundige',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
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
        minimumSize: Size(100, 50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (_selectedUrgency == label)
            Padding(
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
            padding: const EdgeInsets.symmetric(vertical: 1), // Minder ruimte tussen opties
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
      decoration: InputDecoration(
        labelText: 'Ander verzoek',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSendButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_selectedUrgency != null && (_selectedRequest != null || _customRequestController.text.isNotEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verzoek succesvol verzonden!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selecteer een urgentie en een verzoek.')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: Size(double.infinity, 50),
        ),
        child: Text(
          'Versturen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}