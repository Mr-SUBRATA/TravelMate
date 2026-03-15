import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_Mate/services/Api_services.dart';
import 'package:travel_Mate/theme/app_theme.dart';
import 'package:travel_Mate/bottomNavBar.dart';
//import 'package:travel_planer/services/api_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _step = 0;
  final int _total = 3;
  bool _isSaving = false;

  final _nameCtrl = TextEditingController();
  final Set<String> _dna = {'Adventure'};
  int _styleIdx = 1;

  final _dnaOptions = const [
    'Adventure','Beach & Relaxation','Culture & History',
    'Food & Nightlife','Nature & Wildlife','Arts & Festivals',
  ];
  final _styles = const [
    {'title':'Budget Explorer','sub':'Economical & local'},
    {'title':'Balanced Traveler','sub':'Comfort & value'},
    {'title':'Luxury Voyager','sub':'Premium & exclusive'},
  ];

  void _next() {
    if (_step < _total - 1) {
      setState(() => _step++);
      _page.animateToPage(_step,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOut);
    } else { _done(); }
  }

  void _prev() {
    if (_step > 0) {
      setState(() => _step--);
      _page.animateToPage(_step,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOut);
    }
  }

  // ── Save all data to backend then go to MainShell ─────────────
  Future<void> _done() async {
    setState(() => _isSaving = true);
    try {
      final api = ApiService.instance;
      final styleName = _styles[_styleIdx]['title']!;

      // 1. Save preferences
      await api.savePreferences(
        quizAnswers: _dna.toList(),
        travelPace: styleName,
        crowdTolerance: _crowdFromDna(),
        budgetRange: {'min': 2000, 'max': 3000},
        groupSizePreference: '1',
        dealBreakers: _dealBreakersFromDna(),
      );

      // 2. Persist local flags
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('user_name', _nameCtrl.text.trim());
      await prefs.setString('travel_style', styleName);
      await prefs.setDouble('budget', 2500);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not save: $e'),
          backgroundColor: TravelMateColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
    if (!mounted) return;
    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => const MainShell(),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 500),
    ));
  }

  String _crowdFromDna() {
    if (_dna.contains('Beach & Relaxation') || _dna.contains('Nature & Wildlife')) return 'low';
    if (_dna.contains('Food & Nightlife') || _dna.contains('Arts & Festivals')) return 'high';
    return 'medium';
  }

  List<String> _dealBreakersFromDna() {
    final b = <String>[];
    if (!_dna.contains('Adventure')) b.add('extreme_sports');
    if (!_dna.contains('Food & Nightlife')) b.add('nightlife');
    return b;
  }

  @override
  void dispose() {
    _page.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Widget _indicator() => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(_total, (i) {
      final active = i == _step;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        height: 3, width: active ? 28 : 16,
        decoration: BoxDecoration(
          color: active ? TravelMateColors.amber : context.wBorder,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }),
  );

  PreferredSizeWidget _appBar({bool gradient = false}) => AppBar(
    backgroundColor: gradient ? Colors.transparent : context.wSurface,
    flexibleSpace: gradient
        ? Container(decoration: const BoxDecoration(gradient: TravelMateGradients.brandV))
        : null,
    elevation: 0,
    leading: _step > 0
        ? IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: gradient ? TravelMateColors.white : TravelMateColors.teal, size: 20),
            onPressed: _prev)
        : const SizedBox.shrink(),
    title: Text('WAYFARER AI',
        style: TextStyle(
          color: gradient ? TravelMateColors.white : TravelMateColors.teal,
          fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 2,
        )),
    centerTitle: true,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        body: PageView(
          controller: _page,
          physics: const NeverScrollableScrollPhysics(),
          children: [_step1(), _step2(), _step3()],
        ),
      ),
      if (_isSaving)
        Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: TravelMateColors.amber),
              SizedBox(height: 16),
              Text('Saving your preferences...',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          )),
        ),
    ]);
  }

  // ── STEP 1: Name ──────────────────────────────────────────────
  Widget _step1() {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(gradient: true),
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: TravelMateGradients.brandV)),
        Positioned(top: -60, right: -60,
            child: Container(width: 220, height: 220,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: TravelMateColors.white.withOpacity(0.07)))),
        SafeArea(child: Column(children: [
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.06),
            child: Container(
              decoration: BoxDecoration(
                color: context.isDark
                    ? TravelMateColors.dCard.withOpacity(0.85)
                    : TravelMateColors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: context.wBorder.withOpacity(0.4)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12),
                    blurRadius: 30, offset: const Offset(0, 10))],
              ),
              padding: const EdgeInsets.all(28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('STEP ${_step + 1}/$_total  ',
                      style: const TextStyle(color: TravelMateColors.amber,
                          fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  _indicator(),
                ]),
                const SizedBox(height: 20),
                Text('Hello, Explorer.',
                    style: TextStyle(color: context.wText, fontSize: 32, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Let's personalize your journey.",
                    style: TextStyle(color: context.wTextSub, fontSize: 15)),
                const SizedBox(height: 24),
                const Text('WHAT SHOULD WE CALL YOU?',
                    style: TextStyle(color: TravelMateColors.teal,
                        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameCtrl,
                  style: TextStyle(color: context.wText, fontSize: 17),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: 'Enter your name'),
                ),
                const SizedBox(height: 28),
                SizedBox(width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nameCtrl.text.trim().isEmpty ? null : _next,
                      child: const Text("LET'S GO"),
                    )),
              ]),
            ),
          ),
          const Spacer(),
          Padding(padding: const EdgeInsets.only(bottom: 24),
              child: Text('SECURED BY WAYFARER CRYPTOGRAPHY',
                  style: TextStyle(color: TravelMateColors.white.withOpacity(0.6),
                      fontSize: 10, letterSpacing: 2))),
        ])),
      ]),
    );
  }

  // ── STEP 2: Travel DNA ────────────────────────────────────────
  Widget _step2() {
    return Scaffold(
      backgroundColor: context.wBg,
      appBar: _appBar(),
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: _indicator()),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your travel DNA',
                  style: TextStyle(color: context.wText, fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Pick what excites you most.',
                  style: TextStyle(color: context.wTextSub, fontSize: 15)),
            ])),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: _dnaOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12,
                  mainAxisSpacing: 12, childAspectRatio: 1.1),
              itemBuilder: (_, i) {
                final item = _dnaOptions[i];
                final sel = _dna.contains(item);
                return GestureDetector(
                  onTap: () => setState(() => sel ? _dna.remove(item) : _dna.add(item)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: sel ? TravelMateColors.teal.withOpacity(0.12) : context.wCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? TravelMateColors.teal : context.wBorder,
                          width: sel ? 2 : 1),
                    ),
                    child: Center(
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(item, textAlign: TextAlign.center,
                              style: TextStyle(
                                color: sel ? TravelMateColors.teal : context.wText,
                                fontSize: 15, fontWeight: FontWeight.w600))),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: SizedBox(width: double.infinity,
                child: ElevatedButton(
                    onPressed: _dna.isEmpty ? null : _next,
                    child: const Text('Next')))),
        Center(child: Padding(padding: const EdgeInsets.only(bottom: 16),
            child: Text('Step ${_step + 1} of $_total',
                style: TextStyle(color: context.wTextSub, fontSize: 13)))),
      ])),
    );
  }

  // ── STEP 3: Travel Style ──────────────────────────────────────
  Widget _step3() {
    return Scaffold(
      backgroundColor: context.wBg,
      appBar: _appBar(),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: _indicator()),
        const SizedBox(height: 16),
        Text('How do you like\nto travel?', textAlign: TextAlign.center,
            style: TextStyle(color: context.wText, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text("We'll tailor every recommendation.",
            style: TextStyle(color: context.wTextSub, fontSize: 14)),
        const Spacer(),
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.62, initialPage: _styleIdx),
            onPageChanged: (i) => setState(() => _styleIdx = i),
            itemCount: _styles.length,
            itemBuilder: (_, i) {
              final sel = i == _styleIdx;
              final s = _styles[i];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: sel ? 0 : 24),
                decoration: BoxDecoration(
                  color: sel ? TravelMateColors.teal.withOpacity(0.1) : context.wCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: sel ? TravelMateColors.teal : context.wBorder,
                      width: sel ? 2 : 1),
                ),
                child: Padding(padding: const EdgeInsets.all(24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (sel) Align(alignment: Alignment.topRight,
                          child: Container(width: 28, height: 28,
                              decoration: const BoxDecoration(
                                  color: TravelMateColors.teal, shape: BoxShape.circle),
                              child: const Icon(Icons.check, color: Colors.white, size: 16))),
                      const Spacer(),
                      Text(s['title']!,
                          style: TextStyle(color: context.wText, fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(s['sub']!,
                          style: const TextStyle(color: TravelMateColors.teal, fontSize: 13)),
                    ])),
              );
            },
          ),
        ),
        const Spacer(),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(width: double.infinity,
                child: ElevatedButton(
                    onPressed: _isSaving ? null : _done,
                    child: const Text('Start Exploring')))),
        TextButton(onPressed: _done,
            child: Text('Skip for now', style: TextStyle(color: context.wTextSub, fontSize: 14))),
        const SizedBox(height: 8),
      ])),
    );
  }

}
