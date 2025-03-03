import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<_MainMenuState> mainMenuKey = GlobalKey<_MainMenuState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainMenu(key: mainMenuKey),
      navigatorObservers: [MyNavigatorObserver(mainMenuKey)],
    );
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  final GlobalKey<_MainMenuState> mainMenuKey;

  MyNavigatorObserver(this.mainMenuKey);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.name == '/') {
      mainMenuKey.currentState?._resetFadeIn(isInitial: false);
    }
  }
}

class MainMenu extends StatefulWidget {
  MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  double breatherOpacity = 0.0;
  double buttonOpacity = 0.0;
  late AnimationController _controller;
  late Animation<double> _blurRadiusAnimation;
  late Animation<double> _spreadRadiusAnimation;
  bool isInitial = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _blurRadiusAnimation = Tween<double>(begin: 20.0, end: 50.0).animate(_controller);
    _spreadRadiusAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(_controller);

    _startFadeIn();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetFadeIn({required bool isInitial}) {
    setState(() {
      breatherOpacity = 0.0;
      buttonOpacity = 0.0;
      this.isInitial = isInitial;
    });

    Future.delayed(Duration(milliseconds: 0), () {
      _startFadeIn();
    });
  }

  void _startFadeIn() {
    if (isInitial) {
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          breatherOpacity = 1.0;
        });
      });
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {
          buttonOpacity = 1.0;
        });
      });
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          breatherOpacity = 1.0;
        });
      });
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          buttonOpacity = 1.0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(height: 20), // Added spacing between texts
                  Hero(
                    tag: 'outerBox',
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: 200, // Increased width
                          height: 200, // Increased height
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 4), // Increased border width
                            color: Colors.transparent, // No internal color
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.8), // Increased opacity
                                blurRadius: _blurRadiusAnimation.value, // Animated blur radius
                                spreadRadius: _spreadRadiusAnimation.value, // Animated spread radius
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedOpacity(
                              opacity: breatherOpacity,
                              duration: Duration(seconds: 1),
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
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40), // Increased spacing
              AnimatedOpacity(
                opacity: buttonOpacity,
                duration: Duration(seconds: 1),
                child: AnimatedButton(),
              ),
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
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => BoxBreathingScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Text(
            'Breathe',
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

class _BoxBreathingScreenState extends State<BoxBreathingScreen> with SingleTickerProviderStateMixin {
  double positionX = 0;
  double positionY = 0;
  double dynamicBoxSize = 10; // Further decreased initial size
  static const double outerBoxSize = 200; // Further decreased outer box size
  int phase = 0;
  int countdown = 1;
  late Timer timer;
  int duration = 4; // Default duration is 4 seconds
  static const double minBoxSize = 10; // Further decreased min box size
  static const double maxBoxSize = 20; // Further decreased max box size
  static const double lineThickness = 3; // Further decreased line thickness
  double elapsedTime = 0;
  double baseTextSize = 30; // Further decreased base text size
  double maxTextSize = 45; // Further decreased max text size
  late AnimationController _controller;
  late Animation<double> _blurRadiusAnimation;
  late Animation<double> _spreadRadiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _blurRadiusAnimation = Tween<double>(begin: 20.0, end: 50.0).animate(_controller);
    _spreadRadiusAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(_controller);

    startBreathingAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    timer.cancel();
    super.dispose();
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

  void increaseDuration() {
    setState(() {
      if (duration < 10) {
        duration++;
      }
    });
  }

  void decreaseDuration() {
    setState(() {
      if (duration > 1) {
        duration--;
      }
    });
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0), // Added padding to move the icon lower
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 36), // Increased icon size
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0), // Added padding to move the icon lower
                  child: PopupMenuButton<int>(
                    icon: Icon(Icons.build, color: Colors.white, size: 36), // Wrench icon
                    onSelected: (item) => onSelected(context, item),
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                        value: 0,
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              children: [
                                Text('Duration'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          decreaseDuration();
                                        });
                                      },
                                    ),
                                    Text('$duration'),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          increaseDuration();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                    Hero(
                      tag: 'outerBox',
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Container(
                            width: outerBoxSize,
                            height: outerBoxSize,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: lineThickness),
                              color: Colors.transparent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.8),
                                  blurRadius: _blurRadiusAnimation.value,
                                  spreadRadius: _spreadRadiusAnimation.value,
                                ),
                              ],
                            ),
                          );
                        },
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

  void onSelected(BuildContext context, int item) {
    // Handle menu item selection
  }
}