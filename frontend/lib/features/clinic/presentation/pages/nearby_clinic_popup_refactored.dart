import 'package:flutter/material.dart';
import 'india_map_search_page.dart';
import 'widgets/clinic_card_widget.dart';

class NearbyClinicPopupPageRefactored extends StatelessWidget {
  const NearbyClinicPopupPageRefactored({Key? key}) : super(key: key);

  void _handleSearch(BuildContext context, String query) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IndiaMapSearchPage(initialQuery: query),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return const Text(
      'I will guide you to near by clinic',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'near clinics',
        hintStyle: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onSubmitted: (query) => _handleSearch(context, query),
    );
  }

  Widget _buildPopupContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCloseButton(context),
          _buildTitle(),
          const SizedBox(height: 24),
          _buildSearchField(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: Center(
        child: FractionallySizedBox(
          heightFactor: 0.5,
          widthFactor: 0.9,
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            child: _buildPopupContent(context),
          ),
        ),
      ),
    );
  }
} 