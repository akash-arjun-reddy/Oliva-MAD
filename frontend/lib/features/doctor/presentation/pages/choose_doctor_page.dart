import 'package:flutter/material.dart';

class ChooseDoctorPage extends StatelessWidget {
  final String department;
  const ChooseDoctorPage({Key? key, required this.department}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy doctor data by department
    final doctors = [
      {
        'name': 'Dr. A. Sharma',
        'qualification': 'MBBS, MD',
        'rating': 4.8,
        'department': 'General Physician',
      },
      {
        'name': 'Dr. B. Gupta',
        'qualification': 'MBBS, DDVL',
        'rating': 4.7,
        'department': 'Dermatologist',
      },
      {
        'name': 'Dr. C. Rao',
        'qualification': 'MBBS, DCH',
        'rating': 4.6,
        'department': 'Pediatrician',
      },
      {
        'name': 'Dr. D. Singh',
        'qualification': 'BDS, MDS',
        'rating': 4.5,
        'department': 'Dentist',
      },
      {
        'name': 'Dr. E. Kumar',
        'qualification': 'MBBS, MPhil',
        'rating': 4.9,
        'department': 'Psychologist',
      },
    ].where((doc) => doc['department'] == department).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Doctor'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: doctors.isEmpty
          ? Center(child: Text('No doctors available for $department'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: doctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final doc = doctors[i];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: AssetImage('assets/images/doctors_placeholder.png'),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 4),
                              Text(doc['qualification'] as String, style: const TextStyle(color: Colors.black54)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text('${doc['rating']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to SelectDateTimePage
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Book Now'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
} 