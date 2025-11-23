import 'package:flutter/material.dart';

class ResourceLibraryScreen extends StatelessWidget {
  const ResourceLibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resource Library')),
      body: const Center(
        child: Text(
          'Resource Library Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
