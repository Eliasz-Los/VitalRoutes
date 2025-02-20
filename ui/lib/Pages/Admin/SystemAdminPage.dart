import 'package:flutter/material.dart';
import 'package:ui/Services/UserService.dart';

import '../../Models/Enums/FunctionType.dart';

class SystemAdminPage extends StatefulWidget {
  @override
  _SystemAdminPageState createState() => _SystemAdminPageState();
}

class _SystemAdminPageState extends State<SystemAdminPage> {
  List<TextEditingController> doctorControllers = [TextEditingController()];
  List<TextEditingController> nurseControllers = [TextEditingController()];
  TextEditingController patientController = TextEditingController();

  // Lijsten om de toegevoegde supervisierelaties bij te houden (optioneel, voor UI)
  List<Map<String, String>> doctorSupervisions = [];
  List<Map<String, String>> nurseSupervisions = [];

  Future<void> _addSupervision(String supervisorEmail, String superviseeEmail) async {
    try {
      final supervisor = await UserService.getUserByEmail(supervisorEmail);
      final supervisee = await UserService.getUserByEmail(superviseeEmail);

      if (supervisor == null) {
        throw Exception('Supervisor niet gevonden met e-mail: $supervisorEmail');
      }
      if (supervisee == null) {
        throw Exception('Supervisee niet gevonden met e-mail: $superviseeEmail');
      }

      print('Supervisor ID: ${supervisor.id}'); // Debug log
      print('Supervisee ID: ${supervisee.id}'); // Debug log

      if (supervisor.function == FunctionType.Doctor) {
        await UserService.addUnderSupervision(supervisor.id.toString(), supervisee.id.toString());
      } else if (supervisor.function == FunctionType.Nurse && supervisee.function == FunctionType.Patient) {
        await UserService.addUnderSupervision(supervisor.id.toString(), supervisee.id.toString());
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Supervision added successfully for ${supervisor.email} -> ${supervisee.email}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding supervision: $e')));
    }
  }

  @override
  void dispose() {
    // Dispose alle controllers om memory leaks te voorkomen
    for (var controller in doctorControllers) {
      controller.dispose();
    }
    for (var controller in nurseControllers) {
      controller.dispose();
    }
    patientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildSectionTitle('Koppeling Dokter - Patiënt'),
          _buildSectionTitle('Dokter(s)'),
          ..._buildDoctorFields(),
          _buildAddButton(_addDoctorField),
          _buildSectionTitle('Verpleegster(s)'),
          ..._buildNurseFields(),
          _buildAddButton(_addNurseField),
          _buildSectionTitle('Patiënt'),
          _buildPatientField(),
          SizedBox(height: 20),
          // Toon een samenvatting van toegevoegde relaties
          if (doctorSupervisions.isNotEmpty || nurseSupervisions.isNotEmpty)
            _buildSupervisionSummary(),
          ElevatedButton(
            onPressed: _showSummary,
            child: Text('Bekijk koppelingen'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> _buildDoctorFields() {
    return List.generate(doctorControllers.length, (index) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInputField(doctorControllers[index], 'Naam dokter')),
              if (doctorControllers.length > 1)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeDoctorField(index),
                ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _addDoctorSupervision(index),
            child: Text('Voeg toe'),
          ),
          // Toon toegevoegde supervisierelaties voor deze dokter (optioneel)
          if (doctorSupervisions.where((sup) => sup['supervisor'] == doctorControllers[index].text).isNotEmpty)
            _buildDoctorSupervisionList(index),
        ],
      );
    });
  }

  List<Widget> _buildNurseFields() {
    return List.generate(nurseControllers.length, (index) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInputField(nurseControllers[index], 'Naam verpleegster')),
              if (nurseControllers.length > 1)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeNurseField(index),
                ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _addNurseSupervision(index),
            child: Text('Voeg toe'),
          ),
          // Toon toegevoegde supervisierelaties voor deze verpleegster (optioneel)
          if (nurseSupervisions.where((sup) => sup['supervisor'] == nurseControllers[index].text).isNotEmpty)
            _buildNurseSupervisionList(index),
        ],
      );
    });
  }

  Widget _buildPatientField() {
    return Column(
      children: [
        _buildInputField(patientController, 'Naam patiënt'),
        ElevatedButton(
          onPressed: _addPatientSupervision,
          child: Text('Voeg toe'),
        ),
      ],
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
          errorText: controller.text.isEmpty ? 'Vul een e-mail in' : null,
        ),
        onChanged: (value) async {
          if (value.isNotEmpty) {
            try {
              final user = await UserService.getUserByEmail(value);
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gebruiker met e-mail $value niet gevonden')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fout bij validatie: $e')),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildAddButton(VoidCallback onPressed) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
        onPressed: onPressed,
      ),
    );
  }

  void _addDoctorField() {
    setState(() {
      doctorControllers.add(TextEditingController());
    });
  }

  void _addNurseField() {
    setState(() {
      nurseControllers.add(TextEditingController());
    });
  }

  void _removeDoctorField(int index) {
    if (doctorControllers.length > 1) {
      setState(() {
        doctorControllers[index].dispose();
        doctorControllers.removeAt(index);
        // Verwijder ook bijbehorende supervisierelaties uit de lijst
        doctorSupervisions.removeWhere((sup) => sup['supervisor'] == doctorControllers[index].text);
      });
    }
  }

  void _removeNurseField(int index) {
    if (nurseControllers.length > 1) {
      setState(() {
        nurseControllers[index].dispose();
        nurseControllers.removeAt(index);
        // Verwijder ook bijbehorende supervisierelaties uit de lijst
        nurseSupervisions.removeWhere((sup) => sup['supervisor'] == nurseControllers[index].text);
      });
    }
  }

  Future<void> _addDoctorSupervision(int index) async {
    try {
      final doctorEmail = doctorControllers[index].text.trim();
      final doctor = await UserService.getUserByEmail(doctorEmail);

      if (doctor == null) {
        throw Exception('Dokter niet gevonden met e-mail: $doctorEmail');
      }

      // Controleer of er een patiënt is ingevoerd
      final patientEmail = patientController.text.trim();
      final patient = await UserService.getUserByEmail(patientEmail);

      if (patient == null) {
        throw Exception('Patiënt niet gevonden met e-mail: $patientEmail');
      }

      if (doctor.function == FunctionType.Doctor) {
        await _addSupervision(doctorEmail, patientEmail);
        // Voeg de relatie toe aan de lijst voor UI-weergave
        setState(() {
          doctorSupervisions.add({
            'supervisor': doctorEmail,
            'supervisee': patientEmail,
          });
        });
      } else {
        throw Exception('Gebruiker ${doctorEmail} is geen dokter');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dokter ${doctor.email} gekoppeld aan patiënt ${patient.email}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij koppelen dokter: $e')),
      );
    }
  }

  Future<void> _addNurseSupervision(int index) async {
    try {
      final nurseEmail = nurseControllers[index].text.trim();
      final nurse = await UserService.getUserByEmail(nurseEmail);

      if (nurse == null) {
        throw Exception('Verpleegster niet gevonden met e-mail: $nurseEmail');
      }

      // Controleer of er een patiënt is ingevoerd
      final patientEmail = patientController.text.trim();
      final patient = await UserService.getUserByEmail(patientEmail);

      if (patient == null) {
        throw Exception('Patiënt niet gevonden met e-mail: $patientEmail');
      }

      if (nurse.function == FunctionType.Nurse && patient.function == FunctionType.Patient) {
        await _addSupervision(nurseEmail, patientEmail);
        // Voeg de relatie toe aan de lijst voor UI-weergave
        setState(() {
          nurseSupervisions.add({
            'supervisor': nurseEmail,
            'supervisee': patientEmail,
          });
        });
      } else {
        throw Exception('Gebruiker ${nurseEmail} is geen verpleegster of patiënt is geen patiënt');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verpleegster ${nurse.email} gekoppeld aan patiënt ${patient.email}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij koppelen verpleegster: $e')),
      );
    }
  }

  Future<void> _addPatientSupervision() async {
    try {
      final patientEmail = patientController.text.trim();
      final patient = await UserService.getUserByEmail(patientEmail);

      if (patient == null) {
        throw Exception('Patiënt niet gevonden met e-mail: $patientEmail');
      }

      // Hier kun je logica toevoegen om de patiënt toe te voegen aan bestaande dokters/verpleegsters
      // Bijv. voeg de patiënt toe aan alle dokters en verpleegsters in de lijsten
      for (var doctor in doctorControllers) {
        final doctorEmail = doctor.text.trim();
        if (doctorEmail.isNotEmpty) {
          final doctorUser = await UserService.getUserByEmail(doctorEmail);
          if (doctorUser != null && doctorUser.function == FunctionType.Doctor) {
            await _addSupervision(doctorEmail, patientEmail);
            setState(() {
              doctorSupervisions.add({
                'supervisor': doctorEmail,
                'supervisee': patientEmail,
              });
            });
          }
        }
      }

      for (var nurse in nurseControllers) {
        final nurseEmail = nurse.text.trim();
        if (nurseEmail.isNotEmpty) {
          final nurseUser = await UserService.getUserByEmail(nurseEmail);
          if (nurseUser != null && nurseUser.function == FunctionType.Nurse) {
            await _addSupervision(nurseEmail, patientEmail);
            setState(() {
              nurseSupervisions.add({
                'supervisor': nurseEmail,
                'supervisee': patientEmail,
              });
            });
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patiënt ${patient.email} toegevoegd aan supervisers')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij toevoegen patiënt: $e')),
      );
    }
  }

  Future<void> _showSummary() async {
    String summary = 'Koppelingen:\n';
    for (var sup in doctorSupervisions) {
      summary += 'Dokter ${sup['supervisor']} -> Patiënt ${sup['supervisee']}\n';
    }
    for (var sup in nurseSupervisions) {
      summary += 'Verpleegster ${sup['supervisor']} -> Patiënt ${sup['supervisee']}\n';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Samenvatting koppelingen'),
        content: Text(summary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisionSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Toegevoegde koppelingen:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...doctorSupervisions.map((sup) => Text('Dokter ${sup['supervisor']} -> Patiënt ${sup['supervisee']}')),
        ...nurseSupervisions.map((sup) => Text('Verpleegster ${sup['supervisor']} -> Patiënt ${sup['supervisee']}')),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDoctorSupervisionList(int index) {
    final supervisions = doctorSupervisions.where((sup) => sup['supervisor'] == doctorControllers[index].text).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: supervisions.map((sup) => Text('Gekoppeld aan: ${sup['supervisee']}')).toList(),
    );
  }

  Widget _buildNurseSupervisionList(int index) {
    final supervisions = nurseSupervisions.where((sup) => sup['supervisor'] == nurseControllers[index].text).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: supervisions.map((sup) => Text('Gekoppeld aan: ${sup['supervisee']}')).toList(),
    );
  }
}