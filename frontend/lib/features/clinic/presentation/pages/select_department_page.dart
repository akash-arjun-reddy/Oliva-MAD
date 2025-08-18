import 'package:flutter/material.dart';
import '../../../doctor/presentation/pages/choose_doctor_page.dart';

class SelectDepartmentPage extends StatefulWidget {
  const SelectDepartmentPage({Key? key}) : super(key: key);

  @override
  State<SelectDepartmentPage> createState() => _SelectDepartmentPageState();
}

class _SelectDepartmentPageState extends State<SelectDepartmentPage> {
  final List<String> _departments = [
    'General Physician',
    'Dermatologist',
    'Pediatrician',
    'Dentist',
    'Psychologist',
  ];
  String? _selectedDepartment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Department'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose a Department', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            ..._departments.map((dept) => Card(
              color: _selectedDepartment == dept ? const Color(0xFF667eea) : Colors.white,
              child: ListTile(
                title: Text(
                  dept,
                  style: TextStyle(
                    color: _selectedDepartment == dept ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => setState(() => _selectedDepartment = dept),
              ),
            )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDepartment == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChooseDoctorPage(department: _selectedDepartment!),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 