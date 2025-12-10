import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DraggableItem {
  String content;
  Offset position;
  double scale;
  DraggableItem({required this.content, required this.position, this.scale = 1.0});
}

class FeelingWheelScreen extends StatefulWidget {
  const FeelingWheelScreen({super.key});

  @override
  State<FeelingWheelScreen> createState() => _FeelingWheelScreenState();
}

class _FeelingWheelScreenState extends State<FeelingWheelScreen> {
  final List<DraggableItem> _items = [];
  final List<Color> _segmentColors = List.generate(8, (_) => Colors.white);
  Color _selectedColor = const Color(0xFF9575CD);
  DraggableItem? _activeItem;
  final TextEditingController _textController = TextEditingController();

  final List<Color> _palette = [
    Colors.white, Colors.red[200]!, Colors.blue[200]!, Colors.green[200]!,
    Colors.yellow[200]!, Colors.orange[200]!, Colors.purple[200]!, Colors.pink[100]!
  ];

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("My Feeling Wheel Summary", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Reflections:"),
            pw.Bullet(text: "Draw where you felt that fear in your body."),
            pw.Bullet(text: "What color matches how you felt?"),
            pw.Bullet(text: "What was happening, and where were you?"),
            pw.SizedBox(height: 20),
            pw.Text("Recorded Feelings:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ..._items.map((item) => pw.Text("- ${item.content}")),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  void _handleCircleTap(Offset localPosition, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    double angle = math.atan2(dy, dx) * 180 / math.pi;
    angle = (angle + 90) % 360;
    if (angle < 0) angle += 360;
    int segmentIndex = (angle ~/ 45);
    setState(() {
      _segmentColors[segmentIndex] = _selectedColor;
      _activeItem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text("Feeling Wheel", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF9575CD)), onPressed: _generatePdf),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Done", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF9575CD))),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bullet("Draw where you felt that fear in your body."),
                      _bullet("What color do you think matches how you felt?"),
                      _bullet("What was happening, and where were you?"),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTapDown: (details) => _handleCircleTap(details.localPosition, 300),
                          child: CustomPaint(size: const Size(300, 300), painter: FullWheelPainter(_segmentColors)),
                        ),
                      ),
                    ],
                  ),
                ),
                ..._items.map((item) => Positioned(
                  left: item.position.dx,
                  top: item.position.dy,
                  child: GestureDetector(
                    onTap: () => setState(() => _activeItem = item),
                    onPanUpdate: (details) => setState(() => item.position += details.delta),
                    child: Transform.scale(
                      scale: item.scale,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: _activeItem == item ? Border.all(color: const Color(0xFF9575CD), width: 1) : Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(item.content, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          if (_activeItem != null) _buildEditBar(),
          _buildToolbox(),
        ],
      ),
    );
  }

  Widget _buildEditBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.zoom_in, size: 20, color: Colors.grey),
          Expanded(child: Slider(value: _activeItem!.scale, min: 0.5, max: 3.0, activeColor: const Color(0xFF9575CD), onChanged: (v) => setState(() => _activeItem!.scale = v))),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28), onPressed: () => setState(() { _items.remove(_activeItem); _activeItem = null; })),
        ],
      ),
    );
  }

  Widget _buildToolbox() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: "Add feeling word...",
              border: InputBorder.none,
              suffixIcon: IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFF9575CD), size: 30), onPressed: () {
                if (_textController.text.isNotEmpty) {
                  setState(() => _items.add(DraggableItem(content: _textController.text, position: const Offset(120, 120))));
                  _textController.clear();
                }
              }),
            ),
          ),
          const Divider(),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ["😊", "😔", "😠", "😰", "😴", "🥳", "✨", "❤️", "🫂", "🌊"].map((e) => GestureDetector(
                onTap: () => setState(() => _items.add(DraggableItem(content: e, position: const Offset(150, 150)))),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: Text(e, style: const TextStyle(fontSize: 30))),
              )).toList(),
            ),
          ),
          const Divider(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _palette.map((c) => GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: _selectedColor == c ? Colors.black87 : Colors.black12, width: 2)),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text("• $text", style: GoogleFonts.poppins(fontSize: 13)));
}

class FullWheelPainter extends CustomPainter {
  final List<Color> colors;
  FullWheelPainter(this.colors);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()..color = Colors.black..strokeWidth = 1.2..style = PaintingStyle.stroke;
    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2);
    for (int i = 0; i < 8; i++) {
      paint.color = colors[i];
      double startAngle = (i * 45 - 90) * math.pi / 180;
      canvas.drawArc(rect, startAngle, 45 * math.pi / 180, true, paint);
      canvas.drawArc(rect, startAngle, 45 * math.pi / 180, true, linePaint);
    }
  }
  @override
  bool shouldRepaint(covariant FullWheelPainter oldDelegate) => true;
}