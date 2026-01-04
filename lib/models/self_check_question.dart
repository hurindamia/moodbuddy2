enum EmotionCategory { stress, anxiety, mood }

class SelfCheckQuestion {
  final String text;
  final EmotionCategory category;
  int score;

  SelfCheckQuestion({
    required this.text,
    required this.category,
    this.score = 0,
  });
}
