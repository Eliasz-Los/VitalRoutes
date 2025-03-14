import 'package:flutter/material.dart';
import 'package:ui/Services/UserService.dart';
import '../../Models/Enums/FunctionType.dart';

class DoctorPanel extends StatefulWidget {
  @override
  _DoctorPanelState createState() => _DoctorPanelState();
}

class _DoctorPanelState extends State<DoctorPanel> {
  TextEditingController doctorController = TextEditingController();
  List<TextEditingController> nurseControllers = [TextEditingController()];
  List<TextEditingController> patientControllers = [TextEditingController()];

  Future<void> _createSupervision() async {
    try {
      final doctorEmail = doctorController.text.trim();
      if (doctorEmail.isEmpty) {
        throw Exception('Geef een dokter in.');
      }

      final doctor = await UserService.getUserByEmail(doctorEmail);
      if (doctor.function != FunctionType.Doctor) {
        throw Exception('De eerste gebruiker moet een geldige dokter zijn.');
      }

      bool hasValidEntries = false;
      for (var controller in nurseControllers) {
        final email = controller.text.trim();
        if (email.isNotEmpty) {
          final nurse = await UserService.getUserByEmail(email);
          if (nurse.function != FunctionType.Nurse) {
            throw Exception('Verpleegkundige ongeldig: $email');
          }
          await UserService.addUnderSupervision(doctor.id.toString(), nurse.id.toString());
          hasValidEntries = true;
        }
      }

      for (var controller in patientControllers) {
        final email = controller.text.trim();
        if (email.isNotEmpty) {
          final patient = await UserService.getUserByEmail(email);
          if (patient.function != FunctionType.Patient) {
            throw Exception('Patient ongeldig: $email');
          }
          await UserService.addUnderSupervision(doctor.id.toString(), patient.id.toString());
          hasValidEntries = true;
        }
      }

      if (!hasValidEntries) {
        throw Exception('Geef minstens een patient of verpleegkundige.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opdracht succesvol aangemaakt!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error voor aanmaken opdracht: $e')),
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
                  'Dokterspaneel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 40),

              _buildSectionTitle('Dokter'),
              _buildDoctorInputField(doctorController, 'Dokter email (verplicht)'),

              SizedBox(height: 30),

              _buildSectionTitle('Verpleegkundige(n)'),
              _buildDynamicFields(nurseControllers, 'Verpleegkundige email (optioneel)', _addNurseField, _removeNurseField),

              SizedBox(height: 30),

              _buildSectionTitle('Patiënt(en)'),
              _buildDynamicFields(patientControllers, 'Patiënt email (optioneel)', _addPatientField, _removePatientField),

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

  Widget _buildDoctorInputField(TextEditingController controller, String placeholder) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: placeholder,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 57),
        ],
      ),
    );
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
