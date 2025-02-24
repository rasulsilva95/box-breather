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
      home: BoxBreathingScreen(),
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
  double dynamicBoxSize = 8;
  static const double outerBoxSize = 150;
  int phase = 0;
  int countdown = 1;
  late Timer timer;
  static const int duration = 4; // 4 seconds per phase
  static const double minBoxSize = 8;
  static const double maxBoxSize = 16;
  static const double lineThickness = 3;
  double elapsedTime = 0;
  double baseTextSize = 28;
  double maxTextSize = 42;

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
              Text(
                phase == 0
                    ? "Inhale"
                    : phase == 1
                        ? "Hold"
                        : phase == 2
                            ? "Exhale"
                            : "Hold",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(blurRadius: 10, color: Colors.blueAccent, offset: Offset(0, 0))
                  ],
                ),
              ),
              SizedBox(height: 20),
              Stack(
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
                          blurRadius: 15,
                          spreadRadius: 2,
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
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.7),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    child: Text(
                      '$countdown',
                      style: TextStyle(
                        color: Colors.cyanAccent,
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
            ],
          ),
        ),
      ),
    );
  }
}
