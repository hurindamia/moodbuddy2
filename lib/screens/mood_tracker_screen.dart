import 'package:flutter/material.dart';
import '../widgets/mood_card.dart';

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Tracker')),
      body: GridView.count(
        crossAxisCount: 2,
        children: const [
          MoodCard(mood: 'Happy', emoji: '😄'),
          MoodCard(mood: 'Sad', emoji: '😢', description: 'Feeling down'),
          MoodCard(mood: 'Excited', emoji: '🤩'),
          MoodCard(mood: 'Angry', emoji: '😡'),
        ],
      ),
    );
  }
}
