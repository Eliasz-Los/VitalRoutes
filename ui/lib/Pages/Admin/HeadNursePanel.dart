import 'package:flutter/material.dart';
import 'package:ui/Services/UserService.dart';
import '../../Models/Enums/FunctionType.dart';

class HeadNursePanel extends StatefulWidget {
  @override
  _HeadNursePanelState createState() => _HeadNursePanelState();
}

class _HeadNursePanelState extends State<HeadNursePanel> {
  TextEditingController headNurseController = TextEditingController();
  List<TextEditingController> nurseControllers = [TextEditingController()];
  List<TextEditingController> patientControllers = [TextEditingController()];

  Future<void> _createSupervision() async {
    try {
      final headNurseEmail = headNurseController.text.trim();
      if (headNurseEmail.isEmpty) {
        throw Exception('Please enter a headnurse.');
      }

      final headNurse = await UserService.getUserByEmail(headNurseEmail);
      if (headNurse.function != FunctionType.Headnurse) {
        throw Exception('The first user must be a valid headnurse.');
      }

      bool hasValidEntries = false;
      for (var controller in nurseControllers) {
        final email = controller.text.trim();
        if (email.isNotEmpty) {
          final nurse = await UserService.getUserByEmail(email);
          if (nurse.function != FunctionType.Nurse) {
            throw Exception('Nurse not found or invalid: $email');
          }
          await UserService.addUnderSupervision(headNurse.id.toString(), nurse.id.toString());
          hasValidEntries = true;
        }
      }

      for (var controller in patientControllers) {
        final email = controller.text.trim();
        if (email.isNotEmpty) {
          final patient = await UserService.getUserByEmail(email);
          if (patient.function != FunctionType.Patient) {
            throw Exception('Patient not found or invalid: $email');
          }
          await UserService.addUnderSupervision(headNurse.id.toString(), patient.id.toString());
          hasValidEntries = true;
        }
      }

      if (!hasValidEntries) {
        throw Exception('Please enter at least one patient or nurse.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assignment successfully created!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during assignment: $e')),
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
                  "Headnurse's Supervision Panel",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 40),

              _buildSectionTitle('Headnurse'),
              _buildInputField(headNurseController, 'Headnurse email (required)'),

              SizedBox(height: 30),

              _buildSectionTitle('Nurse(s)'),
              _buildDynamicFields(nurseControllers, 'Nurse email (optional)', _addNurseField, _removeNurseField),

              SizedBox(height: 30),

              _buildSectionTitle('Patient(s)'),
              _buildDynamicFields(patientControllers, 'Patient email (optional)', _addPatientField, _removePatientField),

              SizedBox(height: 40),

              ElevatedButton(
                onPressed: _createSupervision,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Create Assignment', style: TextStyle(fontSize: 18)),
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
                icon: Icon(Icons.add_circle, color: Colors.blue),
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

  void _addNurseField() {
    setState(() {
      nurseControllers.add(TextEditingController());
    });
  }

  void _removeNurseField(int index) {
    if (nurseControllers.length > 1) {
      setState(() {
        nurseControllers[index].dispose();
        nurseControllers.removeAt(index);
      });
    }
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
