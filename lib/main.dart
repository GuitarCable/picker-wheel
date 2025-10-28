import 'package:flutter/material.dart';// Needed for debugPaintSizeEnabled
import 'dart:math';

void main()  {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World App',
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreenAccent,
          shadowColor: Colors.lightGreen,
          elevation: 5,
          title: Text('Picker Wheel'),
          titleTextStyle:
            TextStyle(
              fontSize: 42,
              fontFamily: 'Comic Sans',
              color: Colors.deepPurple,
            ), 
        ),
        body: Body(),
        backgroundColor: Colors.yellow,
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  double _finalAngle = 0;

  final List<String> labels = [];

  int _getSelectedIndex(double angle) {
    final normalized = angle % (2 * pi);
    final anglePerWedge = 2 * pi / labels.length;
    final index = labels.length - (normalized ~/ anglePerWedge) - 1;
    return index % labels.length;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _rotation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut
      ),
    );
  }

  void _startRotation() {
    if (_controller.isCompleted) {
      _controller.reset();
    }

    final random = Random();
    final spins = random.nextInt(3) + 2;
    final fractional = random.nextDouble();
    final targetTurns = spins + fractional;
    final targetAngle = targetTurns * 2 * pi;

    _rotation = Tween<double>(begin: 0, end: targetAngle).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut
      ),
    );

    _controller.forward().then((_) {
      setState(() {
        _finalAngle = targetAngle;
      });

      final selectedIndex = _getSelectedIndex(_finalAngle);
      final winner = labels[selectedIndex];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Winner'),
          content: Text('🎉 $winner won!'),
          actions: [
            TextButton(
              onPressed: () {
                labels.remove(winner);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row (
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding (
          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Stack (
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rotation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotation.value,
                      child: child,
                    );
                  },
                  child: WedgeWidget(labels)
                ),
                TextButton (
                  onPressed: _startRotation,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.transparent),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                    elevation: WidgetStateProperty.all(0),
                  ),
                  child: TickPoint()
                ),
              ]
            )
          ),
        ),
        Align (
          alignment: Alignment.topRight,
          child: DynamicListExample(labels)
        )
      ],
    );
  }
}

class WedgeWidget extends StatelessWidget {
  final List<String> _labels;

  const WedgeWidget(this._labels, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double lengthWidth = min(screenSize.width, screenSize.height) * 0.5;
    return CustomPaint(
      size: Size(lengthWidth, lengthWidth),
      painter: WedgeCirclePainter(_labels, lengthWidth),
    );
  }
}

class WedgeCirclePainter extends CustomPainter {
  final List<String> labels;
  final double lengthWidth;
  WedgeCirclePainter(this.labels, this.lengthWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final anglePerWedge = 2 * pi / labels.length;
    final paint = Paint()..style = PaintingStyle.fill;

    if(labels.isEmpty) {
      paint.color = Colors.grey;
      final startAngle = 0 * anglePerWedge;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerWedge,
        true,
        paint,
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black
          ..strokeWidth = lengthWidth * 0.01,
      );
    }
    for (int i = 0; i < labels.length; i++) {
      paint.color = Colors.primaries[i % Colors.primaries.length];
      final startAngle = i * anglePerWedge;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerWedge,
        true,
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerWedge,
        true,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black
          ..strokeWidth = lengthWidth * 0.01,
      );

      final double fontSize = min(lengthWidth * 0.1 / (labels[i].length / 6), lengthWidth * 0.1);
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style:
            TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontFamily: 'Comic Sans'
            ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final textOutlinePainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style:
            TextStyle(
              fontSize: fontSize,
              fontFamily: 'Comic Sans',
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = fontSize * 0.05
                ..color = Colors.black,
            ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textAngle = startAngle + anglePerWedge / 2;
      final textOffset = Offset(
        center.dx + radius / 2 * cos(textAngle) * 1.15,
        center.dy + radius / 2 * sin(textAngle) * 1.15,
      );

      canvas.save();
      canvas.translate(textOffset.dx, textOffset.dy);
      canvas.rotate(textAngle);

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      textOutlinePainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
class TickPoint extends StatefulWidget {
  const TickPoint({super.key});

  @override
  _TickPointState createState() => _TickPointState();
}

class _TickPointState extends State<TickPoint> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double lengthWidth = min(screenSize.width, screenSize.height) * 0.1;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        color: _hovering ? Colors.black.withValues(alpha: 0.1) : Colors.white,
        child: CustomPaint(
          size: Size(lengthWidth, lengthWidth),
          painter: TickerButton(_hovering),
        ),
      ),
    );
  }
}

class TickerButton extends CustomPainter {
  final bool _hovering;
  TickerButton(this._hovering);

  @override
  void paint(Canvas canvas, Size size) {
    Color fillColor = Colors.white;
    if (_hovering) {
      fillColor = Color.from(alpha: 1, red: 0.9, green: 0.9, blue: 0.9);
    }
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;
    
    double yCenter = size.height / 2;
    final path = Path();
    path.moveTo(size.width / 2, yCenter * 2.15);
    path.lineTo(size.width * 1.5, yCenter);
    path.lineTo(size.width / 2, -yCenter * .30);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 1.5;

    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius, borderPaint);

    final playPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final playPath = Path();
    playPath.moveTo(size.width / 3, yCenter * 1.5);
    playPath.lineTo(size.width / 1.3, yCenter);
    playPath.lineTo(size.width / 3, yCenter * .5);
    playPath.close();

    canvas.drawPath(playPath, playPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DynamicListExample extends StatefulWidget {
  final List<String> items;
  DynamicListExample(this.items);
  @override
  _DynamicListExampleState createState() => _DynamicListExampleState(items);
}

class _DynamicListExampleState extends State<DynamicListExample> {
  List<String> items;
  _DynamicListExampleState(this.items);
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _addItem(String name) {
    setState(() {
      items.add('$name');
    });
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack (
      children: [
        Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width / 2,
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width / 2
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Background color
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column (
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(items[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeItem(index),
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: 'Enter a name',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Comic Sans'
                  ),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  _addItem(value);
                  _controller.clear();
                  _focusNode.requestFocus();
                },
              )
            ]
          )
        )
      ]
    );
  }
}