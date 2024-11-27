import 'package:flutter/material.dart';

class CelestialInfoScreen extends StatelessWidget {
  final String name;
  final String description;
  final Map<String, String> details;

  const CelestialInfoScreen({
    super.key,
    required this.name,
    required this.description,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),

              // Image
        Center(
  child: Image.asset(
    'assets/${name.toLowerCase().replaceAll(' ', '')}.png',
    width: 300,
    height: 300,
    errorBuilder: (context, error, stackTrace) {
      return const Text(
        'Image not available',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      );
    },
  ),
),
               
              const SizedBox(height: 20),

              // Details
              ...details.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
