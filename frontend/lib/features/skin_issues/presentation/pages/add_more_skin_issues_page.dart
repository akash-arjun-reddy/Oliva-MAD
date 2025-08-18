import 'package:flutter/material.dart';
import '../../../dashboard/presentation/pages/newdashboard.dart';

class AddMoreSkinIssuesPage extends StatefulWidget {
  const AddMoreSkinIssuesPage({Key? key}) : super(key: key);

  @override
  State<AddMoreSkinIssuesPage> createState() => _AddMoreSkinIssuesPageState();
}

class _AddMoreSkinIssuesPageState extends State<AddMoreSkinIssuesPage> {
  final List<String> _issues = [
    'Acne Scars',
    'Pigmentation',
    'Dry Skin',
    'Oily Skin',
    'Open Pores',
    'Whiteheads',
    'Under Eye Dark Circles',
    'Sensitive skin',
    'Rashes',
  ];
  final Set<int> _selectedIndexes = {3, 6}; // Oily Skin, Under Eye Dark Circles selected by default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF38A89E),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: const Text(
              'Do you want to add more skin issues?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 14,
              children: List.generate(_issues.length, (index) {
                final bool isSelected = _selectedIndexes.contains(index);
                return ChoiceChip(
                  label: Text(
                    _issues[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF00B2B8),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF00B2B8) : Colors.black26,
                      width: 1.2,
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedIndexes.add(index);
                      } else {
                        _selectedIndexes.remove(index);
                      }
                    });
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                );
              }),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndexes.isNotEmpty
                          ? const Color(0xFF00B2B8)
                          : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _selectedIndexes.isNotEmpty ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewDashboardPage(),
                        ),
                      );
                    } : null,
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewDashboardPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Color(0xFF00B2B8),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 