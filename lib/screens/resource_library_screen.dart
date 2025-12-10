import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

enum Mood { positive, neutral, negative }

class Resource {
  final String title;
  final String type; // 'article', 'video', 'book'
  final String link;

  Resource({required this.title, required this.type, required this.link});
}

class ResourceLibraryScreen extends StatelessWidget {
  final Mood userMood;

  const ResourceLibraryScreen({super.key, required this.userMood});

  // Sample resources based on mood
  List<Resource> getResources() {
    switch (userMood) {
      case Mood.positive:
        return [
          Resource(
            title: 'Gratitude Journaling',
            type: 'article',
            link: 'https://www.mindful.org/gratitude-journaling/',
          ),
          Resource(
            title: 'Self-Improvement Challenge Video',
            type: 'video',
            link: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          ),
          Resource(
            title: 'Books on Personal Growth',
            type: 'book',
            link: 'https://www.amazon.com/s?k=personal+growth',
          ),
        ];
      case Mood.neutral:
        return [
          Resource(
            title: 'Mindfulness for Beginners',
            type: 'article',
            link: 'https://www.mindful.org/mindfulness-for-beginners/',
          ),
          Resource(
            title: 'Breathing Exercises Video',
            type: 'video',
            link: 'https://www.youtube.com/watch?v=SEfs5TJZ6Nk',
          ),
          Resource(
            title: 'Books on Mindfulness',
            type: 'book',
            link: 'https://www.amazon.com/s?k=mindfulness',
          ),
        ];
      case Mood.negative:
        return [
          Resource(
            title: 'Managing Anxiety',
            type: 'article',
            link: 'https://www.mentalhealth.gov/anxiety',
          ),
          Resource(
            title: 'Relaxation & Guided Meditation Video',
            type: 'video',
            link: 'https://www.youtube.com/watch?v=inpok4MKVLM',
          ),
          Resource(
            title: 'Books on Stress Management',
            type: 'book',
            link: 'https://www.amazon.com/s?k=stress+management',
          ),
        ];
    }
  }

  // Launch URL
  void openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final resources = getResources();

    return Scaffold(
      appBar: AppBar(
        title: Text('Resource Library', style: GoogleFonts.poppins()),
        backgroundColor: Colors.purple[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final res = resources[index];
            Icon leadingIcon;
            switch (res.type) {
              case 'article':
                leadingIcon = const Icon(Icons.article, color: Colors.blue);
                break;
              case 'video':
                leadingIcon = const Icon(Icons.video_library, color: Colors.red);
                break;
              case 'book':
                leadingIcon = const Icon(Icons.book, color: Colors.green);
                break;
              default:
                leadingIcon = const Icon(Icons.help_outline);
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: leadingIcon,
                title: Text(res.title, style: GoogleFonts.poppins()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openLink(res.link),
              ),
            );
          },
        ),
      ),
    );
  }
}
