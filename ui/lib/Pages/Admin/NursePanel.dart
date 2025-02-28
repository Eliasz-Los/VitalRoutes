import 'package:flutter/material.dart';
import 'package:ui/Services/UserService.dart';
import '../../Models/Enums/FunctionType.dart';

class NursePanel extends StatefulWidget {
  @override
  _NursePanelState createState() => _NursePanelState();
}

class _NursePanelState extends State<NursePanel> {
  TextEditingController nurseController = TextEditingController();
  List<TextEditingController> patientControllers = [TextEditingController()];

  Future<void> _createSupervision() async {
    try {
      final nurseEmail = nurseController.text.trim();
      if (nurseEmail.isEmpty) {
        throw Exception('Please enter a nurse email.');
      }

      final nurse = await UserService.getUserByEmail(nurseEmail);
      if (nurse.function != FunctionType.Nurse) {
        throw Exception('The user must be a valid nurse.');
      }

      bool hasValidEntries = false;
      for (var controller in patientControllers) {
        final email = controller.text.trim();
        if (email.isNotEmpty) {
          final patient = await UserService.getUserByEmail(email);
          if (patient.function != FunctionType.Patient) {
            throw Exception('Patient not found or invalid: $email');
          }
          await UserService.addUnderSupervision(nurse.id.toString(), patient.id.toString());
          hasValidEntries = true;
        }
      }

      if (!hasValidEntries) {
        throw Exception('Please enter at least one patient.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assignment successfully created!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nurse's Supervision Panel",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSectionTitle('Nurse Email'),
            _buildInputField(nurseController, 'Enter nurse email'),
            SizedBox(height: 20),
            _buildSectionTitle('Patients'),
            _buildDynamicFields(patientControllers, 'Enter patient email', _addPatientField, _removePatientField),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createSupervision,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Create Supervision', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDynamicFields(List<TextEditingController> controllers, String placeholder, VoidCallback addField, Function(int) removeField) {
    return Column(
      children: [
        for (int i = 0; i < controllers.length; i++)
          Row(
            children: [
              Expanded(child: _buildInputField(controllers[i], placeholder)),
              IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => removeField(i),
              ),
            ],
          ),
        TextButton(
          onPressed: addField,
          child: Text('Add another patient'),
        ),
      ],
    );
  }

  void _addPatientField() {
    setState(() {
      patientControllers.add(TextEditingController());
    });
  }

  void _removePatientField(int index) {
    if (patientControllers.length > 1) {
      setState(() {
        patientControllers.removeAt(index);
      });
    }
  }

  Widget _buildInputField(TextEditingController controller, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: placeholder,
          labelStyle: TextStyle(color: Colors.blue[900]),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}