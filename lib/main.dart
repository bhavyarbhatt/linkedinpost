import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_frame/device_frame.dart';
import 'dart:math' as math;
import 'dart:async';

void main() {
  runApp(const DeviceFrameDemo());
}

class DeviceFrameDemo extends StatelessWidget {
  const DeviceFrameDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const DeviceFrameScreen(),
    );
  }
}

class DeviceFrameScreen extends StatefulWidget {
  const DeviceFrameScreen({super.key});

  @override
  State<DeviceFrameScreen> createState() => _DeviceFrameScreenState();
}

class _DeviceFrameScreenState extends State<DeviceFrameScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          // Animated background particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticleBackgroundPainter(_particleController.value),
                child: Container(),
              );
            },
          ),

          // Main content - now scrollable
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        children: [
                          Text(
                            'AI POEM GENERATOR',
                            style: GoogleFonts.orbitron(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: [Colors.purpleAccent, Colors.deepPurple],
                                ).createShader(const Rect.fromLTWH(0, 0, 300, 50)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Day 1 Development • iPhone Demo',
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              color: Colors.purpleAccent,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Device Frame with iPhone - with size constraints
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: DeviceFrame(
                          device: Devices.ios.iPhone13,
                          screen: const AIPoemApp(),
                        ),
                      ),
                    ),

                    // Development status
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.purpleAccent),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              '📱 AI Poem Generator • Day 1 Build',
                              style: GoogleFonts.orbitron(
                                fontSize: 14,
                                color: Colors.purpleAccent,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AIPoemApp extends StatefulWidget {
  const AIPoemApp({super.key});

  @override
  State<AIPoemApp> createState() => _AIPoemAppState();
}

class _AIPoemAppState extends State<AIPoemApp> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _loadingController;

  bool _isGenerating = false;
  String _userInput = "";
  String _displayedPoem = "";
  String _fullPoem = "";
  Timer? _typewriterTimer;
  int _currentCharIndex = 0;
  final TextEditingController _textController = TextEditingController();

  final List<String> _poemTemplates = [
    "In the quiet of night, where dreams take flight,\nA word whispered soft, '{input}' in the pale moonlight.\nIt dances on breezes, through starlit skies,\nA fleeting thought that never dies.",
    "'{input}' echoes in valleys, on mountains so high,\nA secret kept safe as the world passes by.\nIn the heart of the forest, where ancient trees stand,\nIt becomes part of nature's grand, timeless plan.",
    "When morning arrives with its golden hue,\n'{input}' awakens, fresh and new.\nIt rides on the sunbeams, so warm and bright,\nChasing away the shadows of night.",
    "Through autumn leaves that twirl and fall,\n'{input}' answers the season's call.\nA crisp, cool word in the harvest air,\nA treasure beyond compare.",
    "In winter's grasp, with frost so deep,\n'{input}' is a promise the snowflakes keep.\nA crystal word in the ice and snow,\nA sparkling secret only the north winds know.",
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _loadingController.dispose();
    _typewriterTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _startTypewriterEffect() {
    _typewriterTimer?.cancel();
    _currentCharIndex = 0;
    _displayedPoem = "";

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_currentCharIndex < _fullPoem.length) {
        setState(() {
          _displayedPoem = _fullPoem.substring(0, _currentCharIndex + 1);
          _currentCharIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _generatePoem() async {
    if (_userInput.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _displayedPoem = "";
      _currentCharIndex = 0;
    });

    // Cancel any existing typewriter effect
    _typewriterTimer?.cancel();

    // Show "AI thinking" animation
    _loadingController.reset();
    _loadingController.repeat();

    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 2));

    // Generate poem by selecting random template
    final random = math.Random();
    int templateIndex = random.nextInt(_poemTemplates.length);
    _fullPoem = _poemTemplates[templateIndex].replaceAll('{input}', _userInput);

    // Stop loading animation
    _loadingController.stop();

    setState(() {
      _isGenerating = false;
    });

    // Start typewriter effect
    _startTypewriterEffect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8 + 0.1 * _pulseController.value,
                    colors: [
                      Colors.deepPurple.withOpacity(0.1),
                      const Color(0xFF1A1A2E),
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating words animation
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: FloatingWordsPainter(_pulseController.value),
                  );
                },
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App header
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        "POETIC AI",
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.purpleAccent.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Input area
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.deepPurple.shade400),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Inspire the AI",
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _textController,
                        onChanged: (value) => _userInput = value,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter a word or phrase...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          filled: true,
                          fillColor: Colors.deepPurple.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.purpleAccent),
                            onPressed: () {
                              _textController.clear();
                              _userInput = "";
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Generate button
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return ElevatedButton(
                            onPressed: _isGenerating ? null : _generatePoem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 10,
                              shadowColor: Colors.purpleAccent.withOpacity(0.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isGenerating)
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                else
                                  const Icon(Icons.auto_awesome, size: 24),
                                const SizedBox(width: 10),
                                Text(
                                  _isGenerating ? "AI IS THINKING..." : "GENERATE POEM",
                                  style: GoogleFonts.orbitron(
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Poem display area
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI-GENERATED POEM",
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            color: Colors.purpleAccent,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_displayedPoem.isEmpty && !_isGenerating)
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            size: 60,
                                            color: Colors.deepPurple.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            "Enter a word and let the AI\ncreate a beautiful poem for you",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else if (_isGenerating && _displayedPoem.isEmpty)
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          AnimatedBuilder(
                                            animation: _loadingController,
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: _loadingController.value * 2 * math.pi,
                                                child: Icon(
                                                  Icons.auto_awesome,
                                                  size: 60,
                                                  color: Colors.purpleAccent,
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            "AI is crafting your poem...",
                                            style: GoogleFonts.orbitron(
                                              fontSize: 16,
                                              color: Colors.purpleAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _displayedPoem,
                                            style: GoogleFonts.crimsonPro(
                                              fontSize: 20,
                                              height: 1.6,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        // Blinking cursor during typing
                                        if (_currentCharIndex < _fullPoem.length)
                                          AnimatedBuilder(
                                            animation: _pulseController,
                                            builder: (context, child) {
                                              return Container(
                                                width: 2,
                                                height: 24,
                                                margin: const EdgeInsets.only(left: 2, top: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.purpleAccent.withOpacity(
                                                    _pulseController.value,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade300, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Share your poem on social media",
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          color: Colors.amber.shade300,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingWordsPainter extends CustomPainter {
  final double animationValue;

  FloatingWordsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final words = ["poem", "verse", "rhyme", "words", "lyric", "dream", "art", "soul"];
    final textStyle = TextStyle(
      color: Colors.deepPurple.withOpacity(0.2),
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < 15; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      final x = baseX + math.sin(animationValue * 2 * math.pi + i) * 20;
      final y = baseY + math.cos(animationValue * 2 * math.pi + i) * 20;

      final word = words[random.nextInt(words.length)];
      final textPainter = TextPainter(
        text: TextSpan(text: word, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(animationValue + i);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticleBackgroundPainter extends CustomPainter {
  final double animationValue;

  ParticleBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw particles
    for (int i = 0; i < 50; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      final x = baseX + math.sin(animationValue * 2 * math.pi + i) * 10;
      final y = baseY + math.cos(animationValue * 2 * math.pi + i) * 10;

      final radius = random.nextDouble() * 3;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}