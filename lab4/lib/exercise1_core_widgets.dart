import 'package:flutter/material.dart';

/// Exercise 1 – Core Widgets: Text, Image, Icon, Card, ListTile
/// Goal: Build a simple UI demonstrating essential Flutter display widgets.
class CoreWidgetsDemo extends StatelessWidget {
  const CoreWidgetsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 1 – Core Widgets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Headline Text widget
            const Text(
              'Welcome to Flutter UI',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // 2. Icon using Material Icons
            const Center(
              child: Icon(
                Icons.movie_creation,
                size: 64,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 16),

            // 3. Image loaded from network
            Center(
              child: Image.network(
                'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                // Show a loading indicator while the image downloads
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                // Show an error icon if image fails to load
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 180,
                    child: Center(child: Icon(Icons.broken_image, size: 64)),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 4. Card containing a ListTile
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text('Movie Item'),
                subtitle: const Text('This is a sample ListTile inside a Card.'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle tap – show a snackbar for demonstration
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ListTile tapped!')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}