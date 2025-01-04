


import 'dart:math';

import 'package:flutter/material.dart';

class NewYearScreen extends StatefulWidget {
  const NewYearScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewYearScreenState createState() => _NewYearScreenState();
}

class _NewYearScreenState extends State<NewYearScreen> with TickerProviderStateMixin {
  List<Firework> fireworks = [];
  late AnimationController _textAnimationController;
  late Animation<double> _textScaleAnimation;
  late AnimationController _yearController;
  late Animation<double> _yearAnimation;
  int currentYear = 2024;
  
  @override
  void initState() {
    super.initState();
    // Controlador para la animación del texto
    _textAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _textScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeInOut),
    );

    // Controlador para la animación del año
    _yearController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _yearAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _yearController, curve: Curves.easeInOut),
    )..addListener(() {
      if (_yearAnimation.value >= 0.5 && currentYear == 2024) {
        setState(() => currentYear = 2025);
      }
    });

    // Iniciar las animaciones después de un delay
    Future.delayed(Duration(seconds: 1), () {
      _yearController.forward();
      _addFireworks();
    });
  }

  void _addFireworks() {
    Future.doWhile(() async {
      if (!mounted) return false;
      setState(() {
        fireworks.add(Firework(
          startX: Random().nextDouble() * MediaQuery.of(context).size.width,
          startY: MediaQuery.of(context).size.height,
          endX: Random().nextDouble() * MediaQuery.of(context).size.width,
          endY: Random().nextDouble() * MediaQuery.of(context).size.height * 0.7,
        ));
      });
      await Future.delayed(Duration(milliseconds: 800));
      return true;
    });
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fuegos artificiales
          ...fireworks.map((firework) => FireworkWidget(firework: firework)),
          
          // Texto central
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _textScaleAnimation,
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.purple, Colors.blue, Colors.red],
                    ).createShader(bounds),
                    child: Text(
                      '¡FELIZ AÑO NUEVO!',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _yearAnimation,
                  builder: (context, child) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001),
                      alignment: Alignment.center,
                      child: Text(
                        currentYear.toString(),
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Firework {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  
  Firework({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
  });
}

class FireworkWidget extends StatefulWidget {
  final Firework firework;
  
  const FireworkWidget({super.key, required this.firework});
  
  @override
  // ignore: library_private_types_in_public_api
  _FireworkWidgetState createState() => _FireworkWidgetState();
}

class _FireworkWidgetState extends State<FireworkWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationY;
  List<Particle> particles = [];
  bool exploded = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _animationY = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
      if (_animationY.value > 0.5 && !exploded) {
        _createParticles();
        exploded = true;
      }
    });
    
    _controller.forward();
  }

  void _createParticles() {
    final random = Random();
    for (int i = 0; i < 30; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final velocity = random.nextDouble() * 100 + 50;
      particles.add(Particle(
        angle: angle,
        velocity: velocity,
        color: Colors.primaries[random.nextInt(Colors.primaries.length)],
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!exploded) {
          return CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: RocketPainter(
              start: Offset(widget.firework.startX, widget.firework.startY),
              end: Offset(widget.firework.endX, widget.firework.endY),
              progress: _animationY.value,
            ),
          );
        } else {
          return CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: ExplosionPainter(
              center: Offset(widget.firework.endX, widget.firework.endY),
              particles: particles,
              progress: (_animationY.value - 0.5) * 2,
            ),
          );
        }
      },
    );
  }
}

class Particle {
  final double angle;
  final double velocity;
  final Color color;
  
  Particle({
    required this.angle,
    required this.velocity,
    required this.color,
  });
}

class RocketPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double progress;
  
  RocketPainter({
    required this.start,
    required this.end,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;
    
    final currentX = start.dx + (end.dx - start.dx) * progress;
    final currentY = start.dy + (end.dy - start.dy) * progress;
    
    canvas.drawCircle(Offset(currentX, currentY), 3, paint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ExplosionPainter extends CustomPainter {
  final Offset center;
  final List<Particle> particles;
  final double progress;
  
  ExplosionPainter({
    required this.center,
    required this.particles,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        // ignore: deprecated_member_use
        ..color = particle.color.withOpacity(1 - progress)
        ..strokeWidth = 2;
      
      final x = center.dx + cos(particle.angle) * particle.velocity * progress;
      final y = center.dy + sin(particle.angle) * particle.velocity * progress;
      
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}