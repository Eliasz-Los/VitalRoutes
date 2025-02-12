import 'package:flutter/material.dart';

class SystemAdminPage extends StatefulWidget {
  @override
  _SystemAdminPageState createState() => _SystemAdminPageState();
}

class _SystemAdminPageState extends State<SystemAdminPage> {
  List<TextEditingController> doctorControllers = [TextEditingController()];
  List<TextEditingController> nurseControllers = [TextEditingController()];
  TextEditingController patientController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('System Admin', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('Koppeling Dokter - Patiënt'),

            // Dokters sectie
            _buildSectionTitle('Dokter(s)'),
            ..._buildDoctorFields(),
            _buildAddButton(_addDoctorField),

            // Verpleegsters sectie
            _buildSectionTitle('Verpleegster(s)'),
            ..._buildNurseFields(),
            _buildAddButton(_addNurseField),

            // Patiënt sectie (geen plus knop)
            _buildSectionTitle('Patiënt'),
            _buildInputField(patientController, 'Naam patiënt'),

            SizedBox(height: 20),
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
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> _buildDoctorFields() {
    return doctorControllers.map((controller) {
      return _buildDoctorInput(controller);
    }).toList();
  }

  Widget _buildDoctorInput(TextEditingController controller) {
    return Row(
      children: [
        Text('Dr.', style: TextStyle(fontSize: 18)),
        SizedBox(width: 10),
        Expanded(child: _buildInputField(controller, 'Naam dokter')),
      ],
    );
  }

  List<Widget> _buildNurseFields() {
    return nurseControllers.map((controller) {
      return _buildInputField(controller, 'Naam verpleegster');
    }).toList();
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
}
