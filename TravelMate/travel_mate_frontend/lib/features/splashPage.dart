import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_Mate/features/onboarding/onboardingPage.dart';
import 'package:travel_Mate/theme/app_theme.dart';
//import 'package:travel_planer/onboarding/onboardingPage.dart';
import 'package:travel_Mate/bottomNavBar.dart';
import 'package:travel_Mate/features/auth/welcome_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotate =
      AnimationController(
        vsync: this,
        duration: const Duration(seconds: 8),
      )..repeat();

  late final AnimationController _pulse =
      AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat(reverse: true);

  late final AnimationController _fade =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      )..forward();

  late final AnimationController _progress =
      AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..forward();

  int _pct = 0;

  final _statuses = const [
    'MAPPING GLOBAL INFRASTRUCTURE',
    'LOADING TRAVEL DATABASE',
    'CALIBRATING AI CORE',
    'PERSONALIZING EXPERIENCE',
    'READY TO EXPLORE',
  ];

  String _status = 'MAPPING GLOBAL INFRASTRUCTURE';

  @override
  void initState() {
    super.initState();

    // Drive progress bar percentage and status label
    _progress.addListener(() {
      if (!mounted) return;
      setState(() {
        _pct = (_progress.value * 100).toInt();
        final idx =
            (_progress.value * (_statuses.length - 1)).floor();
        _status = _statuses[idx.clamp(0, _statuses.length - 1)];
      });
    });

    // Wait 3.5 s then decide where to send the user
    Timer(
      const Duration(milliseconds: 3500),
      _checkAuthAndNavigate,
    );
  }

  // ── Auth-state router ────────────────────────────────────────────────────
  //
  //  Three possible states stored in SharedPreferences:
  //
  //  Key                  │ Type   │ Meaning
  //  ─────────────────────┼────────┼──────────────────────────────────────────
  //  clerk_token          │ String │ Non-empty = user has a valid Clerk session
  //  onboarding_complete  │ bool   │ true = user finished the onboarding flow
  //
  //  Routing table:
  //  ┌─────────────────────────┬──────────────────────┬──────────────────────┐
  //  │ clerk_token             │ onboarding_complete  │ Destination          │
  //  ├─────────────────────────┼──────────────────────┼──────────────────────┤
  //  │ present (non-empty)     │ true                 │ MainShell (home)     │
  //  │ present (non-empty)     │ false / missing      │ OnboardingScreen     │
  //  │ absent / empty          │ (any)                │ WelcomePage          │
  //  └─────────────────────────┴──────────────────────┴──────────────────────┘
  //
  //  How to mark onboarding complete in onboardingPage.dart:
  //
  //    final prefs = await SharedPreferences.getInstance();
  //    await prefs.setBool('onboarding_complete', true);
  //    Navigator.pushReplacement(context,
  //        MaterialPageRoute(builder: (_) => const MainShell()));
  //
  // ────────────────────────────────────────────────────────────────────────
  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('clerk_token') ?? '';
    final onboardingDone =
        prefs.getBool('onboarding_complete') ?? false;

    final Widget destination;

    if (token.isNotEmpty && onboardingDone) {
      // ✅ Fully set-up user — go straight to home
      destination = const MainShell();
    } else if (token.isNotEmpty && !onboardingDone) {
      // ⚠️  Signed up but never finished onboarding
      destination = const OnboardingScreen();
    } else {
      // ❌ Not logged in — show welcome / auth screen
      destination = const WelcomePage();
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _rotate.dispose();
    _pulse.dispose();
    _fade.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compassR = size.width * 0.35;

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen gradient background ──
          Container(
            decoration: const BoxDecoration(
                gradient: TravelMateGradients.brandV),
          ),

          // ── Radial glow ──
          Center(
            child: Container(
              width: size.width * 1.2,
              height: size.width * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TravelMateColors.tealLight
                        .withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ──
          FadeTransition(
            opacity: _fade,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Title
                  const Text(
                    'TRAVEL MATE',
                    style: TextStyle(
                      color: TravelMateColors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Your world. Intelligently charted.',
                    style: TextStyle(
                      color: TravelMateColors.white
                          .withOpacity(0.75),
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Animated compass globe
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_rotate, _pulse]),
                    builder: (_, __) => SizedBox(
                      width: compassR * 2,
                      height: compassR * 2,
                      child: CustomPaint(
                        painter: _CompassPainter(
                          rotation:
                              _rotate.value * 2 * pi,
                          pulse: _pulse.value,
                          radius: compassR,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Progress section
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              'INITIALIZING AI CORE',
                              style: TextStyle(
                                color: TravelMateColors
                                    .white
                                    .withOpacity(0.9),
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              '$_pct%',
                              style: TextStyle(
                                color: TravelMateColors
                                    .white
                                    .withOpacity(0.9),
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Progress bar
                        AnimatedBuilder(
                          animation: _progress,
                          builder: (_, __) => ClipRRect(
                            borderRadius:
                                BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progress.value,
                              backgroundColor:
                                  TravelMateColors.white
                                      .withOpacity(0.25),
                              valueColor:
                                  const AlwaysStoppedAnimation(
                                TravelMateColors.amber,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Animated status label
                        Text(
                          _status,
                          style: TextStyle(
                            color: TravelMateColors.white
                                .withOpacity(0.65),
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compass / Globe CustomPainter ─────────────────────────────────────────
class _CompassPainter extends CustomPainter {
  final double rotation, pulse, radius;

  const _CompassPainter({
    required this.rotation,
    required this.pulse,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = radius;

    // Outer & inner rings
    final ringPaint = Paint()
      ..color = TravelMateColors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(c, r * 0.95, ringPaint);
    canvas.drawCircle(c, r * 0.72, ringPaint);

    // Slowly-rotating cross lines
    final linePaint = Paint()
      ..color = TravelMateColors.white.withOpacity(0.2)
      ..strokeWidth = 1;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rotation * 0.08);
    canvas.drawLine(Offset(0, -r * 0.95),
        Offset(0, r * 0.95), linePaint);
    canvas.drawLine(Offset(-r * 0.95, 0),
        Offset(r * 0.95, 0), linePaint);
    canvas.restore();

    // Cardinal direction amber dots
    final dotPaint = Paint()
      ..color = TravelMateColors.amber
      ..style = PaintingStyle.fill;
    for (final off in [
      Offset(0, -r * 0.72),
      Offset(0, r * 0.72),
      Offset(-r * 0.72, 0),
      Offset(r * 0.72, 0),
    ]) {
      canvas.drawCircle(c + off, 4, dotPaint);
    }

    // Pulsing centre glow
    canvas.drawCircle(
      c,
      26 + pulse * 10,
      Paint()
        ..color = TravelMateColors.white
            .withOpacity(0.08 + pulse * 0.1)
        ..style = PaintingStyle.fill,
    );

    // Globe: outer circle + equator ellipse + meridian
    final globePaint = Paint()
      ..color = TravelMateColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(c, 22, globePaint);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 44, height: 22),
      globePaint,
    );
    canvas.drawLine(
      c + const Offset(0, -22),
      c + const Offset(0, 22),
      globePaint,
    );
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.rotation != rotation ||
      old.pulse != pulse ||
      old.radius != radius;
}