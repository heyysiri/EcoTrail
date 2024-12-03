import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:math';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class RoadmapBadge {
  final int id;
  final String title;
  final String description;
  final int pointsRequired;
  int unlockedPoints;
  final String requiredAction;
  final IconData icon;
  final LinearGradient gradient;

  RoadmapBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.unlockedPoints,
    required this.requiredAction,
    required this.icon,
    required this.gradient,
  });
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  final List<RoadmapBadge> _badges = [
    RoadmapBadge(
        id: 1,
        title: 'Green Spark',
        description: 'First eco journey begins!',
        pointsRequired: 20,
        unlockedPoints: 0,
        requiredAction: 'Complete your first sustainable commute!',
        icon: Icons.local_fire_department,
        gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.green.shade600])),
    RoadmapBadge(
        id: 2,
        title: 'Pedal Pioneer',
        description: '10 bike rides conquered',
        pointsRequired: 100,
        unlockedPoints: 50,
        requiredAction: 'Bike 50 more miles to unlock!',
        icon: Icons.directions_bike,
        gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade700])),
    RoadmapBadge(
        id: 3,
        title: 'Transit Trailblazer',
        description: '30 public transit trips',
        pointsRequired: 300,
        unlockedPoints: 150,
        requiredAction: 'Take 15 more public transit trips!',
        icon: Icons.train,
        gradient: LinearGradient(
            colors: [Colors.purple.shade200, Colors.purple.shade700])),
    RoadmapBadge(
        id: 4,
        title: 'Carbon Crusher',
        description: '50 sustainable commutes',
        pointsRequired: 500,
        unlockedPoints: 250,
        requiredAction: 'Complete 25 more sustainable commutes!',
        icon: Icons.electric_bolt,
        gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade700])),
    RoadmapBadge(
        id: 5,
        title: 'Eco Warrior',
        description: '100 sustainable commutes',
        pointsRequired: 1000,
        unlockedPoints: 500,
        requiredAction: 'Push through 50 more eco-friendly commutes!',
        icon: Icons.nature_people,
        gradient: LinearGradient(
            colors: [Colors.orange.shade200, Colors.orange.shade700])),
    RoadmapBadge(
        id: 6,
        title: 'Renewable Ranger',
        description: '200 sustainable commutes',
        pointsRequired: 2000,
        unlockedPoints: 1000,
        requiredAction: 'Continue your eco-journey!',
        icon: Icons.solar_power,
        gradient: LinearGradient(
            colors: [Colors.amber.shade200, Colors.amber.shade700])),
    RoadmapBadge(
        id: 7,
        title: 'Climate Champion',
        description: '500 sustainable commutes',
        pointsRequired: 5000,
        unlockedPoints: 2500,
        requiredAction: 'You are making a difference!',
        icon: Icons.public,
        gradient: LinearGradient(
            colors: [Colors.indigo.shade200, Colors.indigo.shade700])),
    RoadmapBadge(
        id: 8,
        title: 'Global Guardian',
        description: '1000 sustainable commutes',
        pointsRequired: 10000,
        unlockedPoints: 5000,
        requiredAction: 'Ultimate eco legend!',
        icon: Icons.public,
        gradient:
            LinearGradient(colors: [Colors.red.shade200, Colors.red.shade700])),
  ];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOutQuart));

    _animationController.forward();
  }

  void _showBadgeDetails(RoadmapBadge badge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 300,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.bottomCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFffffff).withOpacity(0.1),
            Color(0xFFFFFFFF).withOpacity(0.05),
          ],
          stops: [0.1, 1],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFffffff).withOpacity(0.5),
            Color((0xFFFFFFFF)).withOpacity(0.5),
          ],
          stops: [0.2, 1],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                badge.icon,
                size: 60,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                badge.title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                badge.requiredAction,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Progress: ${badge.unlockedPoints}/${badge.pointsRequired}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Path _createRoadPath(Size size) {
    final Path roadPath = Path();

    // Copy the path creation logic from the CurvedRoadmapPainter
    roadPath.moveTo(50, size.height * 0.1);
    roadPath.cubicTo(size.width * 0.1, size.height * 0.05, size.width * 0.3,
        size.height * 0.2, size.width * 0.5, size.height * 0.15);
    roadPath.cubicTo(size.width * 0.7, size.height * 0.1, size.width * 0.6,
        size.height * 0.3, size.width * 0.8, size.height * 0.25);
    roadPath.cubicTo(size.width * 0.9, size.height * 0.2, size.width * 0.8,
        size.height * 0.4, size.width - 50, size.height * 0.35);
    roadPath.cubicTo(size.width * 0.7, size.height * 0.45, size.width * 0.3,
        size.height * 0.5, 50, size.height * 0.6);
    roadPath.cubicTo(size.width * 0.2, size.height * 0.7, size.width * 0.5,
        size.height * 0.8, size.width * 0.7, size.height * 0.75);
    roadPath.cubicTo(size.width * 0.9, size.height * 0.7, size.width * 0.8,
        size.height * 0.9, size.width - 50, size.height * 0.85);

    return roadPath;
  }

  void _handleBadgeTap(TapUpDetails details, Path roadPath, Size size) {
    final pathMetrics = roadPath.computeMetrics();
    final pathMetric = pathMetrics.elementAt(0);

    for (int i = 0; i < _badges.length; i++) {
      final distance = pathMetric.length * (i / (_badges.length - 1));
      final tangent = pathMetric.getTangentForOffset(distance);

      if (tangent != null) {
        final badgeCenter = tangent.position;
        final badgeRadius = 30.0;

        final tapOffset = details.localPosition;
        final dx = tapOffset.dx - badgeCenter.dx;
        final dy = tapOffset.dy - badgeCenter.dy;
        final distanceFromCenter = sqrt(dx * dx + dy * dy);

        if (distanceFromCenter <= badgeRadius) {
          _showBadgeDetails(_badges[i]);
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            // Starry background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Eco Journey :)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2
                    ),
                  ),
                ],
              ),
            ),

            // Roadmap
            Positioned(
  top: 30, // Adjust this value for the desired downward shift
  left: 0,
  right: 0,
  child: AnimatedBuilder(
    animation: _progressAnimation,
    builder: (context, child) {
      final Path roadPath = _createRoadPath(MediaQuery.of(context).size);
      return CustomPaint(
        painter: CurvedRoadmapPainter(
          badges: _badges,
          animationProgress: _progressAnimation.value,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: GestureDetector(
            onTapUp: (details) {
              // Pass the roadPath to the tap handler
              _handleBadgeTap(details, roadPath, MediaQuery.of(context).size);
            },
          ),
        ),
      );
    },
  ),
),


            // Progress Indicator
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 50,
                borderRadius: 20,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFffffff).withOpacity(0.1),
                    Color(0xFFFFFFFF).withOpacity(0.05),
                  ],
                  stops: [0.1, 1],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFffffff).withOpacity(0.5),
                    Color((0xFFFFFFFF)).withOpacity(0.5),
                  ],
                  stops: [0.2, 1],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total Eco Points',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Text(
                        '${_badges.map((b) => b.unlockedPoints).reduce((a, b) => a + b)}/10000',
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class CurvedRoadmapPainter extends CustomPainter {
  final List<RoadmapBadge> badges;
  final double animationProgress;

  CurvedRoadmapPainter({required this.badges, required this.animationProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final Path roadPath = Path();

    // Even more dynamic and curvy path
    roadPath.moveTo(50, size.height * 0.1);
    roadPath.cubicTo(size.width * 0.1, size.height * 0.05, size.width * 0.3,
        size.height * 0.2, size.width * 0.5, size.height * 0.15);
    roadPath.cubicTo(size.width * 0.7, size.height * 0.1, size.width * 0.6,
        size.height * 0.3, size.width * 0.8, size.height * 0.25);
    roadPath.cubicTo(size.width * 0.9, size.height * 0.2, size.width * 0.8,
        size.height * 0.4, size.width - 50, size.height * 0.35);
    roadPath.cubicTo(size.width * 0.7, size.height * 0.45, size.width * 0.3,
        size.height * 0.5, 50, size.height * 0.6);
    roadPath.cubicTo(size.width * 0.2, size.height * 0.7, size.width * 0.5,
        size.height * 0.8, size.width * 0.7, size.height * 0.75);
    roadPath.cubicTo(size.width * 0.9, size.height * 0.7, size.width * 0.8,
        size.height * 0.9, size.width - 50, size.height * 0.85);

    canvas.drawPath(roadPath, roadPaint);

    // Draw badges
    final pathMetrics = roadPath.computeMetrics();
    final pathMetric = pathMetrics.elementAt(0);

    for (int i = 0; i < badges.length; i++) {
      final progress = (animationProgress * badges.length) - i;
      final badge = badges[i];

      if (progress > 0) {
        final distance = pathMetric.length * (i / (badges.length - 1));
        final tangent = pathMetric.getTangentForOffset(distance);

        if (tangent != null) {
          // Badge background - reduced size
          final badgePaint = Paint()
            ..shader = badge.gradient.createShader(
                Rect.fromCircle(center: tangent.position, radius: 30))
            ..style = PaintingStyle.fill;

          canvas.drawCircle(
              tangent.position, 30 * progress.clamp(0, 1), badgePaint);

          // Badge icon - reduced size
          final iconPainter = TextPainter(
            text: TextSpan(
              text: String.fromCharCode(badge.icon.codePoint),
              style: TextStyle(
                color: Colors.white,
                fontSize: 30 * progress.clamp(0, 1),
                fontFamily: badge.icon.fontFamily,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          iconPainter.paint(
              canvas,
              Offset(tangent.position.dx - (iconPainter.width / 2),
                  tangent.position.dy - (iconPainter.height / 2)));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
