import 'package:flutter/material.dart';
import 'package:ui/Services/UserService.dart';
import '../../Models/Enums/FunctionType.dart';

class SystemAdminPage extends StatefulWidget {
  @override
  _SystemAdminPageState createState() => _SystemAdminPageState();
}

class _SystemAdminPageState extends State<SystemAdminPage> {
  TextEditingController doctorController = TextEditingController();
  List<TextEditingController> nurseControllers = [TextEditingController()];
  List<TextEditingController> patientControllers = [TextEditingController()];

  Future<void> _createSupervision() async {
    try {
      final doctorEmail = doctorController.text.trim();
      if (doctorEmail.isEmpty) {
        throw Exception('Vul minstens een dokter in.');
      }

      final doctor = await UserService.getUserByEmail(doctorEmail);
      if (doctor == null || doctor.function != FunctionType.Doctor) {
        throw Exception('De eerste gebruiker moet een geldige dokter zijn.');
      }

      bool hasValidEntries = false;
      for (var controller in nurseControllers) {
        final email = controller.text.trim();
        if (email.isNotEmpty) {
          final nurse = await UserService.getUserByEmail(email);
          if (nurse == null || nurse.function != FunctionType.Nurse) {
            throw Exception('Verpleegster niet gevonden of ongeldig: $email');
          }
          await UserService.addUnderSupervision(doctor.id.toString(), nurse.id.toString());
          hasValidEntries = true;
        }
      }

      for (var controller in patientControllers) {
        final email = controller.text.trim();
        if (email.isNotEmpty) {
          final patient = await UserService.getUserByEmail(email);
          if (patient == null || patient.function != FunctionType.Patient) {
            throw Exception('Patiënt niet gevonden of ongeldig: $email');
          }
          await UserService.addUnderSupervision(doctor.id.toString(), patient.id.toString());
          hasValidEntries = true;
        }
      }

      if (!hasValidEntries) {
        throw Exception('Vul minstens één patiënt of verpleegster in.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koppeling succesvol aangemaakt!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij koppeling: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Systeembeheer - Koppelingen'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(doctorController, 'E-mail dokter (verplicht)'),
            _buildDynamicFields(nurseControllers, 'E-mail verpleegster (optioneel)', _addNurseField, _removeNurseField),
            _buildDynamicFields(patientControllers, 'E-mail patiënt (optioneel)', _addPatientField, _removePatientField),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createSupervision,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue, // Lichtblauwe knop
                foregroundColor: Colors.white, // Witte tekst
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text('Maak Koppeling', style: TextStyle(fontSize: 18)),
            ),
          ],
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
              if (controllers.length > 1)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => removeField(i),
                ),
            ],
          ),
        IconButton(
          icon: Icon(Icons.add_circle, color: Colors.blue),
          onPressed: addField,
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
