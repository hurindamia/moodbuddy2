import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'article_detailed_screen.dart';
import 'youtube_video_screen.dart';
import 'book_detailed_screen.dart';

class ResourceLibraryScreen extends StatefulWidget {
  const ResourceLibraryScreen({super.key});

  @override
  State<ResourceLibraryScreen> createState() => _ResourceLibraryScreenState();
}

class _ResourceLibraryScreenState extends State<ResourceLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Color _cardColor(String sentiment) {
    switch (sentiment) {
      case "NEGATIVE":
        return Colors.red.shade50;
      case "POSITIVE":
        return Colors.green.shade50;
      default:
        return Colors.blueGrey.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view resources")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Resource Library",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF9575CD),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Articles"),
            Tab(text: "Videos"),
            Tab(text: "Books"),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listen to the latest mood entry
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('mood_entries')
            .orderBy('last_updated', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          String sentiment = "NEUTRAL";

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            sentiment =
                snapshot.data!.docs.first['last_note_sentiment'] ?? "NEUTRAL";
          }

          final resources = _resourcesForSentiment(sentiment);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(resources, "article", sentiment),
              _buildList(resources, "video", sentiment),
              _buildList(resources, "book", sentiment),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(
      List<Map<String, dynamic>> all, String type, String sentiment) {
    final items = all.where((e) => e['type'] == type).toList();

    if (items.isEmpty) {
      return Center(
        child: Text(
          "No $type resources available",
          style: GoogleFonts.poppins(),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          color: _cardColor(sentiment),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(item['icon'], size: 40, color: Colors.deepPurple),
            title: Text(
              item['title'],
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              item['desc'],
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            onTap: () {
              if (type == "article") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleDetailScreen(
                      title: item['title'],
                      sections: List<Map<String, dynamic>>.from(item['content']),
                      sentiment: sentiment,
                    ),
                  ),
                );
              } else if (type == "video") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => YoutubeVideoScreen(
                      videoId: item['videoId'],
                      title: item['title'],
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailScreen(
                      title: item['title'],
                      desc: item['desc'],
                      thumbnail: item['thumbnail'],
                      link: item['link'],
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }


  // ================= RESOURCE DATA =================

  List<Map<String, dynamic>> _resourcesForSentiment(String sentiment) {
    if (sentiment == "NEGATIVE") {
      return [
        {
          'title': "Low Mood - Tips and Self-help",
          'type': "article",
          'desc':
          "A distressing event or major change in your life can affect your mood. But sometimes it's possible to feel low for no clear reason.",
          'icon': Icons.self_improvement,
          'content': [
            {
              'section': "Signs of low mood",
              'points': [
                "Feeling sad or not enjoying things as much as you did",
                "Feeling anxious or panicky",
                "Being more tired than usual or having sleep problems",
                "Feeling worthless or guilty",
              ],
            },
            {
              'section': "Causes of low mood",
              'points': [
                "Pressure at work",
                "Relationship problems",
                "Illness or injury",
                "Caring for someone",
              ],
            },
            {
              'section': "Tips to help with low mood",
              'points': [
                "Connect with other people",
                "Talk about your feelings",
                "Do things you enjoy",
                "Do something creative",
              ],
            },
          ],
        },
        {
          'title': "Stress Management",
          'type': "article",
          'desc':
          "Stress relievers: Tips to tame stress",
          'icon': Icons.self_improvement,
          'content': [
            {
              'section': "Eat a healthy diet",
              'points': [
                "Eating a healthy diet is an important part of taking care of yourself. Aim to eat many fruits, vegetables and whole grains",
              ],
            },
            {
              'section': "Laugh more",
              'points': [
                "A good sense of humor can't cure all ailments. But it can help you feel better, even if you have to force a fake laugh through your grumpiness.",
              ],
            },
            {
              'section': "Keep a journal",
              'points': [
                "Writing down your thoughts and feelings can be a good release for otherwise pent-up feelings. Don't think about what to write, let it happen. Write anything that comes to mind.",
              ],
            },
            {
              'section': "Connect with others",
              'points': [
                "When you're stressed and irritable, you may want to isolate yourself. Instead, reach out to family and friends and make social connections.",
              ],
            },
          ],
        },
        {
          'title': "Quick and Easy Mood-Boosting Activities",
          'type': "article",
          'desc':
          "Try these 5 ways to turn your day around for the better",
          'icon': Icons.self_improvement,
          'content': [
            {
              'section': "Make a happy meal",
              'points': [
                "Certains food rich in the happy hormone called serotonin may help us experience more joy, calmness and even better sleep. Some of these foods include tomatoes, walnuts, pineapples. Try adding them to your meals or make a colorful, cheerful smooties",
              ],
            },
            {
              'section': "Enjoy a happy meal",
              'points': [
                "Now that you have made your happy-infused food, sit down and make it a nice meal. Set the table, plate the food and take the time to really enjoy and savor the moment and flavours.",
              ],
            },
            {
              'section': "Read a feel-good book",
              'points': [
                "There's nothing like getting lost in a good story. Grab one off your shelf, pick a cozy spot near natural light ad get to reading. ",
              ],
            },
            {
              'section': "Spend time with your family",
              'points': [
                "Crack open those old home movies, board games or family photos and take time to reconnect with those who love you the most. This one is sure to bring on some laughs, smiles and maybe even a few happy tears. ",
              ],
            },
            {
              'section': "Do good",
              'points': [
                "Raising awareness for a cause close to your heart can also help lift your spirits. Search for how you can best support your community.",
              ],
            },
          ],
        },
        {
          'title': "Guided Meditation for Anxiety",
          'type': "video",
          'desc': "10-minute calming meditation",
          'icon': Icons.video_library,
          'videoId': "ZToicYcHIOU",
        },
        {
          'title': "Stress Relief Tips",
          'type': "video",
          'desc': "7 ways on how to lower stress",
          'icon': Icons.video_library,
          'videoId': "eGVWRvNe1-A",
        },
        {
          'title': "Good Stress vs Bad Stress",
          'type': "video",
          'desc': "10-minute stress explanation",
          'icon': Icons.video_library,
          'videoId': "tMcw-7cHD7A&t=60s",
        },
        {
          'title': "Breathing Exercise",
          'type': "video",
          'desc': "Breathing exercise for stress and anxiety",
          'icon': Icons.video_library,
          'videoId': "eZBa63NZbbE",
        },
        {
          'title': "Mindfulness for Beginners",
          'type': "book",
          'desc': "Learn mindfulness techniques to reduce stress",
          'icon': Icons.book,
          'thumbnail': "https://images-na.ssl-images-amazon.com/images/I/51b5YG6Y1rL._SX258_BO1,204,203,200_.jpg",
          'link': "https://www.amazon.com/dp/162625211X",
        },
        {
          'title': "Why has Nobody Told Me This Before? - Julie Smith",
          'type': "book",
          'desc': "In this bestselling book, clinical psychologist Julie Smith shares exercises and tips to help readers navigate the ups and downs of life. This is done by developing new coping skills and build resilience. ",
          'icon': Icons.book,
          'thumbnail': "https://d26olvxuieoyaa.cloudfront.net/catalog/product/cache/1/small_image/1000x1000/9df78eab33525d08d6e5fb8d27136e95/9/7/9780241529720.jpg",
          'link': "https://www.popularonline.com.my/default/catalog/product/view/id/201234/s/9780241529720/?did=8",
        },
        {
          'title': "The Happiness Trap: Stop Struggling and Start Living - Russ Harris",
          'type': "book",
          'desc': "This book is a classic self-help guide to building psychological resilience using acceptance and commitment therapy(ACT). ACT is a mindfulness-based coaching intervention focused on values-driven behavioral change regardless of challenges and setbacks. ",
          'icon': Icons.book,
          'thumbnail': "https://bci.kinokuniya.com/jsp/images/book-img/97814/97814721/9781472147172.JPG",
          'link': "https://malaysia.kinokuniya.com/Happiness_Trap_2nd_Edition_:_Stop_Struggling,_Start_Living_--_Paperback_-_softback/bw/9781472147172?srsltid=AfmBOopOkLxsDMMhbVACdSmYEWnqXnqVDOl-N3__JUJxAwEsOYna7UOI",
        },
        {
          'title': "Looking after Your Mental Health ",
          'type': "book",
          'desc': "We talk about our physical health - but not so much about how we're feeling. With lots of practical advice, this lively, accessible guide explains why we have emotions, and what can influence them. Covering everything from friendships, social media and bullying to divorce, depression and eating disorders.",
          'icon': Icons.book,
          'thumbnail': "https://bci.kinokuniya.com/jsp/images/book-img/97814/97814749/9781474937290.JPG",
          'link': "https://malaysia.kinokuniya.com/bw/9781474937290?srsltid=AfmBOori4JPnD3WWaHi24mG80Anjs70Mla6V9tcFt9sWuRK82kvYAVEY",
        },
        {
          'title': "Healthy Mind, Happy You: How to Take Care of Your Mental Health",
          'type': "book",
          'desc': "Healthy mind, happy you! This reassuring, fact-packed book for girls and boys is all about how to maintain good mental health while growing up. ",
          'icon': Icons.book,
          'thumbnail': "https://book.goldenhouse.com.my/wp-content/uploads/2025/01/HealthyMindHappyYou-01-820x820.jpg",
          'link': "https://book.goldenhouse.com.my/shop/english-books/children-young-adult/young-adult/inspirational-growth-juvenile/health-mindset-juvenile/healthy-mind-happy-you/",
        },
      ];
    }

    if (sentiment == "POSITIVE") {
      return [
        {
          'title': "Gratitude Journaling",
          'type': "article",
          'desc': "Build happiness through gratitude.",
          'icon': Icons.edit_note,
          'content': [
            {
              'section': "How to Practice Gratitude",
              'points': [
                "Write 3 good things daily",
                "Reflect on why they happened",
                "Notice positive emotions",
              ],
            },
          ],
        },
        {
          'title': "Healthy Sleep Hygiene Tips",
          'type': "article",
          'desc': "Developing certain habits, like keeping a consistent schedule and limiting blue light exposure before bed can improve your sleep hygiene and promote quality sleep.",
          'icon': Icons.edit_note,
          'content': [
            {
              'section': "Keep a consistent sleep schedule",
              'points': [
                "Try to go to sleep and wake ip at about the same times every day even on weekends. This reinforces your body's sleep cycle, which make it easier for you to fall asleep and wake up everyday.",
              ],
            },
            {
              'section': "Create a relaxing bedtime routine",
              'points': [
                "A relaxing bedtime routine helps you unwind so you're ready to sleep. Keeping the routine consistent helps your body recognize that it's bedtime when you start the routine. This may help you fall asleep more quickly.",
              ],
            },
            {
              'section': "Turn off electronic devices before you go to sleep",
              'points': [
                "Keeping your phone near your bed can disrupt your sleep, even if you're not aware of it. Message notifications, buzzing, and light that can suddenly pop on in the middle of the night can interrupt your sleep. ",
              ],
            },
            {
              'section': "Exercise regularly",
              'points': [
                "As little as 30 minutes of aerobic exercise per day can improve your sleep quality and overall health. Exercising outside might increase the benefits even more since exposure to natural light helps regulate your sleep cycle.",
              ],
            },
            {
              'section': "Limit your caffeine intake",
              'points': [
                "The effects of caffeine can last 3-7 hours after you consume it. This means that your afternoon cup of coffee may keep you awake and alert a lot longer than you'd like. ",
              ],
            },
          ],
        },
        {
          'title': "Self-Compassion in Stressful Times",
          'type': "article",
          'desc': "Four Everyday Practices that Help",
          'icon': Icons.edit_note,
          'content': [
            {
              'section': "Notice and honor your feelings",
              'points': [
                "As you go about your day, notice what emotion arise for you. Try giving it space rather than pushing it away. Consider, What might this feeling be trying to tell me? ",
              ],
            },
            {
              'section': "Choose with compassion",
              'points': [
                "It's natural to feel pressure to complete everything while juggling commitments. When we realise we can't keep everything together, we turn to self-compassion. The practice isn't in holding them all in the air, but in determining which ones are delicate and which will bounce if dropped.",
              ],
            },
            {
              'section': "Offer yourself comfort",
              'points': [
                "As you begin your self-compassion practice, you might notice that it often requires opening yourself to deep vulnerabilities and fears.",
                "You might try a simple daily check-in: pause for a few breaths, and ask, What does my body need right now? and respond with one small act of comfort. ",
                "Offering yourself comfort throughout the day helps you stay grounded and remind you that you deserve care amidst a busy and stressful day.",
              ],
            },
            {
              'section': "Practice loving-kindness",
              'points': [
                "Take a few slow breaths",
                "Place a hand on your chest or belly",
                "silently repeat: May I be at peace. May I be kind to myself. May I give myself the compassion I need.",
              ],
            },
          ],
        },
        {
          'title': "Growth Mindset vs Fixed Mindset",
          'type': "article",
          'desc': "How what you think affects what you achieve",
          'icon': Icons.edit_note,
          'content': [
            {
              'section': "What is a growth mindset",
              'points': [
                "A growth mindset views intelligence and talent as qualities that can be developed over time. This doesn't mean believing everyone can be genius- it simply means that progress is possible with effort and practice.",
              ],
            },
            {
              'section': "What is a fixed mindset",
              'points': [
                "A fixed-minded person may avoid challenges, give up easily, or feel threatened by other's success. They see failure as proof of limitation rather than an opportunity to learn.",
              ],
            },
            {
              'section': "How to develop a growth mindset",
              'points': [
                "Realise that scientifically, you can improve. The brain and body are designed to adapt. Every time you learn, new neural pathways form strengthening your ability to grow",
                "Remove the 'fixed mindset' inner voice. Replace negative inner thoughts like 'I can't do this' with 'I can learn with practice'.",
                "Reward the process. Celebrate effort and progress, not just outcomes. Praise the steps you took to improve.",
                "Get feedback. use constructive feedback as information, not judgement",
                "Get out of your comfort zone. Growth happens when you stretch beyond what's easy or familiar.",
                "Accept failure as part of the process. Mistakes are data from learning. Each setback teaches something about what works next time.",
              ],
            },
          ],
        },

        {
          'title': "Motivation Booster",
          'type': "video",
          'desc': "Stay inspired",
          'icon': Icons.video_library,
          'videoId': "mgmVOuLgFB0",
        },
        {
          'title': "A Self Compassion",
          'type': "video",
          'desc': "It's all too easy to be extremely tough on ourselves. We need at points to get better at self-compassion. Here is an exercise in how to lessen the voices of self-flagellation.",
          'icon': Icons.video_library,
          'videoId': "-kfUE41-JFw",
        },
        {
          'title': "6 Tips for Better Sleep",
          'type': "video",
          'desc': "Want to not only fall asleep quickly but also stay asleep longer? Sleep scientist Matt Walker explains how your room temperature, lighting and other easy to fix factors ca set the stage for a better night's rest.",
          'icon': Icons.video_library,
          'videoId': "t0kACis_dJE",
        },
        {
          'title': "6 Journaling Technique That Will Change Your Life",
          'type': "video",
          'desc': "Journaling is more than just putting pen to paper- it's a transformative journey of self-discovery and personal growth. In this video, we're diving deep into the world of journaling to explore techniques that will truly change your life. Discover how to journal for self-growth and harness the power of journaling for personal development.",
          'icon': Icons.video_library,
          'videoId': "WI-j39vOqmk",
        },


        {
          'title': "The Mindful Self-Compassion Workbook: A Proven Way to Accept Yourself, Build Inner Strength, and Thrive",
          'type': "book",
          'desc': "Are you kinder to others than you are to yourself? More than a thousand research studies show the benefits of being supportive friend to yourself, especially in times of need. This science-based workbook offers a step-by-step approach to breaking free of harsh self-judgments and impossible standards in order to cultivate emotional well-being.",
          'icon': Icons.book,
          'thumbnail': "https://bci.kinokuniya.com/jsp/images/book-img/97814/97814625/9781462526789.JPG",
          'link': "https://malaysia.kinokuniya.com/The_Mindful_Self-Compassion_Workbook_:_A_Proven_Way_to_Accept_Yourself,_Build_Inner_Strength,_and_Thrive/bw/9781462526789?srsltid=AfmBOopyrmX2DUksiidlIb9lTGWMDGdXtXRFHJEzrOgziI__kacEJvch",
        },
        {
          'title': "Mindful Me: Choose Gratitude Journal",
          'type': "book",
          'desc': "This is a place where you can write about all the good things in life, focus on the positives and be thankful. The Mindful Me Choose Gratitude Journal is a 96-page book filled with inspirational quotes, mindful activities and a space to practice gratitude. There are writing prompts related to you, your family, friends, school and the world, as well as ideas on how to give back with kindness. ",
          'icon': Icons.book,
          'thumbnail': "https://mphonline.com/cdn/shop/products/9781488925887.jpg?v=1633485121&width=840",
          'link': "https://mphonline.com/products/mindful-me-choose-gratitude-journal?srsltid=AfmBOorSbVjxfEAqV7N_UJoLzDzPrQJRx8MjGdmSCOYEse9T4TqmAkiQ",
        },
        {
          'title': "Wellbeing & Mindfulness",
          'type': "book",
          'desc': "Wellbeing and Mindfulness guide you through the maze of holistic living and explains clearly and concisely how to incorporate natural health, emotional healing and spirituality into everyday life with simple, effective information and technique that work. ",
          'icon': Icons.book,
          'thumbnail': "https://www.bookxcess.com/cdn/shop/products/9781780976204_1_d8efe776-c44f-4473-bcb2-f781918ae7e4_1100x.jpg?v=1648784463",
          'link': "https://www.bookxcess.com/products/wellbeing-and-mindfulness?srsltid=AfmBOorOxwqUmPNKKg6KhUewle5QtpRDt3iT8Hq_nvq3V7TYuWZ1xUWs",
        },
        {
          'title': "A Guide To Happiness: Using Mindfulness And Meditation",
          'type': "book",
          'desc': "A guide to happiness is a seven-step personal development programme that will help you rediscover your zest for life. The techniques and exercise in this book are designed to help you plot out your own way to happiness in small, actionable steps.",
          'icon': Icons.book,
          'thumbnail': "https://www.bookxcess.com/cdn/shop/files/9781838577605_aaaa_576x.png?v=1736833100",
          'link': "https://www.bookxcess.com/products/guide-to-happiness-9781838577605?srsltid=AfmBOorsXLehrVs08pJp-KJor9Lf8MptSB8uo5l1IthzAWkxt-uMIXcE",
        },
        {
          'title': "The Mindfulness Playbook: How To Bring Calm And Happiness Into Your Daily Life",
          'type': "book",
          'desc': "This short reassuring book is rich in science but low in jargon. It is underpinned by a model which provides proven solutions for combatting stress, anxiety and burnout. The simple, easily learned mindfulness techniques will enable you to rewrite your brain and participate fully and enthusiastically with life.",
          'icon': Icons.book,
          'thumbnail': "https://www.bookxcess.com/cdn/shop/products/the-mindfulness-playbook-how-to-bring-calm-and-happiness-into-your-daily-life-9781473636194-32252144648370_288x.jpg?v=1648796137",
          'link': "https://www.bookxcess.com/products/the-mindfulness-playbook-9781473636194?srsltid=AfmBOoqBCXLmwTYuxqFoTwPjtlFtNY0_CF7Rbb0r1yOv8tZFWefOhgKb",
        },
      ];
    }

    return [
      {
        'title': "Daily Self Check-In",
        'type': "article",
        'desc': "Reflect on your current state.",
        'icon': Icons.chat_bubble_outline,
        'content': [
          {
            'section': "Reflection Questions",
            'points': [
              "How do I feel today?",
              "What do I need right now?",
              "What can help me feel balanced?",
            ],
          },
        ],
      },
      {
        'title': "Gentle Stretching",
        'type': "video",
        'desc': "Relax your body",
        'icon': Icons.video_library,
        'videoId': "sTANio_2E0Q",
      },
      {
        'title': "The Mindful Journal",
        'type': "book",
        'desc': "Daily journaling guide",
        'icon': Icons.book,
        'content': "The Mindful Journal by Anna Black",
      },
    ];
  }
}
