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
        throw Exception('Geef een verpleegkundige email.');
      }

      final nurse = await UserService.getUserByEmail(nurseEmail);
      if (nurse.function != FunctionType.Nurse) {
        throw Exception('De gebruiker moet een geldige verpleegkundige zijn.');
      }

      bool hasValidEntries = false;
      for (var controller in patientControllers) {
        final email = controller.text.trim();
        if (email.isNotEmpty) {
          final patient = await UserService.getUserByEmail(email);
          if (patient.function != FunctionType.Patient) {
            throw Exception('Patiënt ongeldig: $email');
          }
          await UserService.addUnderSupervision(nurse.id.toString(), patient.id.toString());
          hasValidEntries = true;
        }
      }

      if (!hasValidEntries) {
        throw Exception('Geef minstens één patiënt in.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opdracht succesvol aangemaakt!')),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 4),
                ),
                child: Text(
                  'Verplegerspaneel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 40),

              _buildSectionTitle('Verpleegkundige'),
              _buildInputField(nurseController, 'Verpleegkundige email (verplicht)'),

              SizedBox(height: 30),

              _buildSectionTitle('Patiënt(en)'),
              _buildDynamicFields(patientControllers, 'Patiënt email', _addPatientField, _removePatientField),

              SizedBox(height: 40),

              ElevatedButton(
                onPressed: _createSupervision,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Creëer opdracht', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDynamicFields(List<TextEditingController> controllers, String placeholder, VoidCallback addField, Function(int) removeField) {
    return Column(
      children: [
        for (int i = 0; i < controllers.length; i++)
          Row(
            children: [
              Expanded(
                child: _buildInputField(controllers[i], placeholder),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.blue.shade700),
                onPressed: addField,
              ),
              if (controllers.length > 1)
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.black),
                    onPressed: () => removeField(i),
                  ),
                ),
            ],
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
        patientControllers[index].dispose();
        patientControllers.removeAt(index);
      });
    }
  }

  Widget _buildInputField(TextEditingController controller, String placeholder) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: placeholder,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
