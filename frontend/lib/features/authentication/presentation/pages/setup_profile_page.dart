import 'package:flutter/material.dart';
import '../../../clinic/presentation/pages/booking_success_page.dart';
import '../widgets/gender_selection_widget.dart';
import '../widgets/primary_button_widget.dart';

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({Key? key}) : super(key: key);

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _gender;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookingSuccessPage()),
    );
  }

  void _handleGenderSelection(String gender) {
    setState(() {
      _gender = gender;
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Setup Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'It only takes a minute and makes your consultation more effective.',
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter full name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00BFAE), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Age', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter your age',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00BFAE), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: const [
            Icon(Icons.info_outline, size: 16, color: Colors.black38),
            SizedBox(width: 4),
            Text('Age must be between 18 to 70 years', style: TextStyle(fontSize: 13, color: Colors.black38)),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            GenderSelectionWidget(
              gender: 'Male',
              assetPath: 'assets/images/male_icon.png',
              isSelected: _gender == 'Male',
              onTap: () => _handleGenderSelection('Male'),
            ),
            const SizedBox(width: 24),
            GenderSelectionWidget(
              gender: 'Female',
              assetPath: 'assets/images/female_icon.png',
              isSelected: _gender == 'Female',
              onTap: () => _handleGenderSelection('Female'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildNameInput(),
              const SizedBox(height: 18),
              _buildAgeInput(),
              const SizedBox(height: 18),
              _buildGenderSelection(),
              const SizedBox(height: 32),
              PrimaryButtonWidget(
                text: 'Continue',
                onPressed: _handleContinue,
                height: 48,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
} 