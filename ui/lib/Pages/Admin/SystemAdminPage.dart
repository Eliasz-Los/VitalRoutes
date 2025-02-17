import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SystemAdminPage extends StatefulWidget {
  @override
  _SystemAdminPageState createState() => _SystemAdminPageState();
}

class _SystemAdminPageState extends State<SystemAdminPage> {
  List<TextEditingController> doctorControllers = [TextEditingController()];
  List<TextEditingController> nurseControllers = [TextEditingController()];
  TextEditingController patientController = TextEditingController();

  Future<void> _addSupervision(String supervisorEmail, String superviseeEmail) async {
    try {
      final supervisorResponse = await Dio().get('http://10.0.2.2:5028/api/user/$supervisorEmail');
      final superviseeResponse = await Dio().get('http://10.0.2.2:5028/api/user/$superviseeEmail');

      if (supervisorResponse.statusCode == 200 && superviseeResponse.statusCode == 200) {
        final supervisorId = supervisorResponse.data['id'];
        final superviseeId = superviseeResponse.data['id'];

        final response = await Dio().post('http://10.0.2.2:5028/api/user/$supervisorId/addUnderSupervision/$superviseeId');
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Supervision added successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add supervision')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not found')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding supervision: $e')));
    }
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
          _buildInputField(patientController, 'Naam patiënt'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              for (var doctorController in doctorControllers) {
                for (var nurseController in nurseControllers) {
                  _addSupervision(doctorController.text, nurseController.text);
                }
              }
            },
            child: Text('Koppel'),
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
      return _buildDoctorInput(index);
    });
  }

  Widget _buildDoctorInput(int index) {
    return Row(
      children: [
        Expanded(child: _buildInputField(doctorControllers[index], 'Naam dokter')),
        if (doctorControllers.length > 1)
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeDoctorField(index),
          ),
      ],
    );
  }

  List<Widget> _buildNurseFields() {
    return List.generate(nurseControllers.length, (index) {
      return _buildNurseInput(index);
    });
  }

  Widget _buildNurseInput(int index) {
    return Row(
      children: [
        Expanded(child: _buildInputField(nurseControllers[index], 'Naam verpleegster')),
        if (nurseControllers.length > 1)
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeNurseField(index),
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
        ),
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
      });
    }
  }

  void _removeNurseField(int index) {
    if (nurseControllers.length > 1) {
      setState(() {
        nurseControllers[index].dispose();
        nurseControllers.removeAt(index);
      });
    }
  }
}