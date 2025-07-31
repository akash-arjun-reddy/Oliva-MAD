import 'package:flutter/material.dart';
import 'add_more_skin_issues_page.dart';

class SkinConcernPage extends StatefulWidget {
  const SkinConcernPage({Key? key}) : super(key: key);

  @override
  State<SkinConcernPage> createState() => _SkinConcernPageState();
}

class _SkinConcernPageState extends State<SkinConcernPage> {
  int? _selectedIndex = null; // No option selected by default
  final List<Map<String, String>> _concerns = [
    {
      'title': 'Acne / Pimples',
      'desc': 'Comedonal, blackheads or pus-filled pimples',
    },

    {
      'title': 'Dark Spots / Marks',
      'desc': 'Flat spots, melanin buildup due to acne, sun exposure or hormonal changes',
    },
    {
      'title': 'Acne Scars',
      'desc': 'Pits or marks remaining after severe or prolonged acne',
    },
    {
      'title': 'Pigmentation',
      'desc': 'Irregular dark patches on the skin',
    },
    {
      'title': 'Dull Skin',
      'desc': 'Skin that lacks lustre, is flat, or even grey',
    },
  ];

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
            color: const Color(0xFF00B2B8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: const Text(
              'What is your concern?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _concerns.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final bool isSelected = _selectedIndex == index;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  tileColor: isSelected ? const Color(0xFFE0F7F4) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: isSelected
                        ? const BorderSide(color: Color(0xFF00B2B8), width: 1.5)
                        : BorderSide.none,
                  ),
                  leading: Radio<int>(
                    value: index,
                    groupValue: _selectedIndex,
                    activeColor: const Color(0xFF00B2B8),
                    onChanged: (val) {
                      setState(() {
                        _selectedIndex = val;
                      });
                    },
                  ),
                  title: Text(
                    _concerns[index]['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    _concerns[index]['desc']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_selectedIndex != null)
                          ? const Color(0xFF00B2B8) // dark teal
                          : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: (_selectedIndex != null)
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddMoreSkinIssuesPage(),
                              ),
                            );
                          }
                        : null,
                    child: const Text(
                      'Next',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = null; // Clear selection
                    });
                  },
                  child: const Text(
                    "I don't have any concern",
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