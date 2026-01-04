import 'package:flutter/material.dart';

class ResourceData {
  static List<Map<String, dynamic>> resourcesForSentiment(String sentiment) {
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
                "As little as 30 minutes of aerobic exercise per day can improve your sleep quality and overal health. Exercising outside might increase the benefits even more since exposure to natural light helps regulate your sleep cycle.",
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
      ];
    }

    // NEUTRAL
    return [
      {
        'title': "Daily Self Check-In",
        'type': "article",
        'desc': "Reflect on how you feel today",
        'icon': Icons.chat_bubble_outline,
        'content': [
          {
            'section': "Questions",
            'points': [
              "How do I feel?",
              "What do I need right now?",
            ],
          },
        ],
      },
    ];
  }
}
