import 'package:indiakart/widgets/product_card.dart'; // Change this import if you rename the folder
import 'package:flutter/material.dart';

// Sample data remains the same
const List<Map<String, dynamic>> sampleProducts = [
  // ... (no changes here)
];


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indiakart'), // <-- Name changed here
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {
            // TODO: Implement Search functionality
          }),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {
            // TODO: Implement Filter functionality
          }),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: sampleProducts.length,
        itemBuilder: (context, index) {
          final product = sampleProducts[index];
          return ProductCard(
            name: product['name'],
            category: product['category'],
            price: product['price'],
            rating: product['rating'],
            distance: product['distance'],
            imageUrl: product['imageUrl'],
          );
        },
      ),
    );
  }
}
