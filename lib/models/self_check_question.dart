class SelfCheckQuestion {
  final String text;
  int score; // 0–3 scale

  SelfCheckQuestion({
    required this.text,
    this.score = 0,
  });
}
