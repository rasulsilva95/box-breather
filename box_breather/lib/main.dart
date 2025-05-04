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
      Future.delayed(Duration(milliseconds: 1000), () {
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
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Hero(
                    tag: 'outerBox',
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.transparent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.8),
                                blurRadius: _blurRadiusAnimation.value,
                                spreadRadius: _spreadRadiusAnimation.value,
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
                                  fontSize: 36,
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
              SizedBox(height: 40),
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
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.blueAccent, width: 4),
            shadowColor: Colors.blueAccent.withOpacity(0.5),
            elevation: _animation.value,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          ),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => BoxBreathingScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0.0, 0.5),
                      end: Offset(0.0, 0.0),
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Text(
            'Breathe',
            style: TextStyle(fontSize: 24),
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

class _BoxBreathingScreenState extends State<BoxBreathingScreen> with TickerProviderStateMixin {
  double positionX = 0;
  double positionY = 0;
  double dynamicBoxSize = 10;
  static const double outerBoxSize = 200;
  int phase = 0;
  int countdown = 1;
  late Timer timer;
  int duration = 4;
  static const double minBoxSize = 10;
  static const double maxBoxSize = 20;
  static const double lineThickness = 3;
  double elapsedTime = 0;
  double baseTextSize = 30;
  double maxTextSize = 45;
  late AnimationController _glowController;
  late Animation<double> _blurRadiusAnimation;
  late Animation<double> _spreadRadiusAnimation;
  late AnimationController _textGlowController;
  late Animation<double> _textGlowAnimation;
  int preCountdown = 3;
  bool isPreCountdown = true;
  bool showPulse = false;
  bool showInfoOverlay = true;
  bool showBeginText = false;
  bool showGetReadyText = false;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _blurRadiusAnimation = Tween<double>(begin: 20.0, end: 50.0).animate(_glowController);
    _spreadRadiusAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(_glowController);

    _textGlowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _textGlowAnimation = Tween<double>(begin: 5.0, end: 20.0).animate(
      CurvedAnimation(parent: _textGlowController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final centerX = MediaQuery.of(context).size.width / 2;
      final centerY = MediaQuery.of(context).size.height / 2;
      final halfOuterBoxSize = outerBoxSize / 2;

      setState(() {
        positionX = centerX - halfOuterBoxSize;
        positionY = centerY - halfOuterBoxSize;
      });
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _textGlowController.dispose();
    timer.cancel();
    super.dispose();
  }

  void startPreCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (preCountdown > 1) {
          preCountdown--;
          showGetReadyText = true;
          print('showGetReadyText: $showGetReadyText');
        } else if (preCountdown == 1) {
          showGetReadyText = false;
          showBeginText = true;
          print('showGetReadyText: $showGetReadyText, showBeginText: $showBeginText');
          preCountdown--;

          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              showBeginText = false;
            });
          });
        } else {
          timer.cancel();
          isPreCountdown = false;
          startBreathingAnimation();
        }
      });
    });
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
        countdown = (elapsedTime ~/ 1) + 1;

        double halfOuterBoxSize = outerBoxSize / 2;
        double centerX = MediaQuery.of(context).size.width / 2;
        double centerY = MediaQuery.of(context).size.height / 2;

        if (phase == 0) {
          positionX = centerX - halfOuterBoxSize + step * (elapsedTime * 25);
          positionY = centerY - halfOuterBoxSize;
          if (positionX >= centerX + halfOuterBoxSize - minBoxSize) {
            phase = 1;
            resetCountdown();
          }
        } else if (phase == 1) {
          positionX = centerX + halfOuterBoxSize - minBoxSize;
          positionY = centerY - halfOuterBoxSize + step * (elapsedTime * 25);
          if (positionY >= centerY + halfOuterBoxSize - minBoxSize) {
            phase = 2;
            resetCountdown();
          }
        } else if (phase == 2) {
          positionX = centerX + halfOuterBoxSize - minBoxSize - step * (elapsedTime * 25);
          positionY = centerY + halfOuterBoxSize - minBoxSize;
          if (positionX <= centerX - halfOuterBoxSize) {
            phase = 3;
            resetCountdown();
          }
        } else if (phase == 3) {
          positionX = centerX - halfOuterBoxSize;
          positionY = centerY + halfOuterBoxSize - minBoxSize - step * (elapsedTime * 25);
          if (positionY <= centerY - halfOuterBoxSize) {
            phase = 0;
            resetCountdown();
            positionX = centerX - halfOuterBoxSize;
            positionY = centerY - halfOuterBoxSize;
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

  String getBreathingPhaseText() {
    switch (phase) {
      case 0:
        return "Inhale";
      case 1:
        return "Hold";
      case 2:
        return "Exhale";
      case 3:
        return "Hold";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building widget... showGetReadyText: $showGetReadyText');
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
                  padding: const EdgeInsets.only(top: 40.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 36),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: PopupMenuButton<int>(
                    icon: Icon(Icons.build, color: Colors.white, size: 36),
                    color: Colors.blueGrey.shade900.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    onSelected: (item) => onSelected(context, item),
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                        value: 0,
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              children: [
                                Text(
                                  'Duration',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, color: Colors.white),
                                      onPressed: () {
                                        setState(() {
                                          decreaseDuration();
                                        });
                                      },
                                    ),
                                    Text(
                                      '$duration',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, color: Colors.white),
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
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Hero(
                      tag: 'outerBox',
                      child: AnimatedBuilder(
                        animation: _glowController,
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
                    if (showPulse)
                      Positioned.fill(
                        child: PulseEffect(),
                      ),
                    if (isPreCountdown)
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '$preCountdown',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.blueAccent, offset: Offset(0, 0)),
                            ],
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: AnimatedOpacity(
                          opacity: showGetReadyText ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: Text(
                            'Get Ready',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(blurRadius: 100, color: Colors.blueAccent, offset: Offset(0, 0)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showBeginText)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: showBeginText
                                ? Text(
                                    'Begin',
                                    key: ValueKey<bool>(showBeginText),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(blurRadius: 100, color: Colors.blueAccent, offset: Offset(0, 0)),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                        ),
                      ),
                    if (!isPreCountdown)
                      Positioned(
                        left: positionX,
                        top: positionY,
                        child: Container(
                          width: minBoxSize,
                          height: minBoxSize,
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
                    if (!isPreCountdown)
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '$countdown',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.blueAccent, offset: Offset(0, 0))
                            ],
                          ),
                        ),
                      ),
                    if (!isPreCountdown)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              getBreathingPhaseText(),
                              key: ValueKey<String>(getBreathingPhaseText()),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: _textGlowAnimation.value,
                                    color: Colors.blueAccent,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (showInfoOverlay)
                      InfoOverlay(
                        onClose: () {
                          setState(() {
                            showInfoOverlay = false;
                            startPreCountdown();
                          });
                        },
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
  }
}

class PulseEffect extends StatefulWidget {
  @override
  _PulseEffectState createState() => _PulseEffectState();
}

class _PulseEffectState extends State<PulseEffect> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
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
        return Opacity(
          opacity: 1.0 - _animation.value,
          child: Container(
            width: 200 + 20 * _animation.value,
            height: 200 + 20 * _animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                color: Colors.blueAccent.withOpacity(0.8),
                width: 4.0 * _animation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class InfoOverlay extends StatelessWidget {
  final VoidCallback onClose;

  InfoOverlay({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black.withOpacity(0.8), Colors.blueGrey.shade900.withOpacity(0.8)],
            ),
          ),
        ),
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Box Breathing Technique',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.blueAccent,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Box breathing is a simple and effective breathing technique. '
                  'Follow the instructions below:\n\n'
                  '1. Inhale when it says "Inhale".\n'
                  '2. Hold your breath when it says "Hold".\n'
                  '3. Exhale when it says "Exhale".\n'
                  '4. Hold your breath again when it says "Hold".\n\n'
                  'Repeat this cycle to help calm your mind and body.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                  child: Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}