import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu'),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.blueGrey.shade900],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'Box',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48, // Increased font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 200, // Increased width
                    height: 200, // Increased height
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 4), // Increased border width
                      color: Colors.transparent, // No internal color
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.5),
                          blurRadius: 30, // Increased blur radius
                          spreadRadius: 4, // Increased spread radius
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Breather',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36, // Increased font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40), // Increased spacing
              AnimatedButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 10.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Button color
            foregroundColor: Colors.white, // Text color
            side: BorderSide(color: Colors.blueAccent, width: 4), // Increased outline width
            shadowColor: Colors.blueAccent.withOpacity(0.5),
            elevation: _animation.value,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20), // Increased padding
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BoxBreathingScreen()),
            );
          },
          child: Text(
            'Breath',
            style: TextStyle(fontSize: 24), // Increased font size
          ),
        );
      },
    );
  }
}

class BoxBreathingScreen extends StatefulWidget {
  @override
  _BoxBreathingScreenState createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen> {
  double positionX = 0;
  double positionY = 0;
  double dynamicBoxSize = 10; // Further decreased initial size
  static const double outerBoxSize = 200; // Further decreased outer box size
  int phase = 0;
  int countdown = 1;
  late Timer timer;
  static const int duration = 4; // 4 seconds per phase
  static const double minBoxSize = 10; // Further decreased min box size
  static const double maxBoxSize = 20; // Further decreased max box size
  static const double lineThickness = 3; // Further decreased line thickness
  double elapsedTime = 0;
  double baseTextSize = 30; // Further decreased base text size
  double maxTextSize = 45; // Further decreased max text size

  @override
  void initState() {
    super.initState();
    startBreathingAnimation();
  }

  void resetCountdown() {
    setState(() {
      countdown = 1;
      elapsedTime = 0;
    });
  }

  void startBreathingAnimation() {
    timer = Timer.periodic(Duration(milliseconds: 40), (timer) {
      setState(() {
        double step = (outerBoxSize - minBoxSize) / (duration * 25);
        elapsedTime += 0.04;
        double progress = elapsedTime / duration;
        dynamicBoxSize = minBoxSize + (maxBoxSize - minBoxSize) * progress;
        countdown = (elapsedTime ~/ 1) + 1;

        if (phase == 0) {
          positionX += step;
          if (positionX >= outerBoxSize - minBoxSize) {
            phase = 1;
            resetCountdown();
          }
        } else if (phase == 1) {
          positionY += step;
          if (positionY >= outerBoxSize - minBoxSize) {
            phase = 2;
            resetCountdown();
          }
        } else if (phase == 2) {
          positionX -= step;
          if (positionX <= 0) {
            phase = 3;
            resetCountdown();
          }
        } else if (phase == 3) {
          positionY -= step;
          if (positionY <= 0) {
            phase = 0;
            resetCountdown();
            positionX = 0;
            positionY = 0;
            dynamicBoxSize = minBoxSize;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double cycle = elapsedTime / duration;
    double textScale = (0.5 - 0.5 * cos(cycle * pi));
    double textSize = baseTextSize + (maxTextSize - baseTextSize) * textScale;

    return Scaffold(
      appBar: AppBar(
        title: Text('Box Breathing'),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.blueGrey.shade900],
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0), // Further decreased padding
                  child: Text(
                    phase == 0
                        ? "Inhale"
                        : phase == 1
                            ? "Hold"
                            : phase == 2
                                ? "Exhale"
                                : "Hold",
                    style: TextStyle(
                      color: Colors.white, // Changed to white
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.blueAccent, offset: Offset(0, 0))
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: outerBoxSize,
                      height: outerBoxSize,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: lineThickness),
                        color: Colors.transparent, // No internal color
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.5),
                            blurRadius: 15, // Further decreased blur radius
                            spreadRadius: 1, // Further decreased spread radius
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: positionX,
                      top: positionY,
                      child: Container(
                        width: dynamicBoxSize,
                        height: dynamicBoxSize,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4), // Further decreased border radius
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.7),
                              blurRadius: 10, // Further decreased blur radius
                              spreadRadius: 1, // Further decreased spread radius
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      child: Text(
                        '$countdown',
                        style: TextStyle(
                          color: Colors.white, // Changed to white
                          fontSize: textSize,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.blueAccent, offset: Offset(0, 0))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}