import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_Mate/theme/app_theme.dart';
import 'package:travel_Mate/features/planning/tripResultPage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LOADING OVERLAY
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingOverlay extends StatefulWidget {
  final String from;
  final String to;
  const _LoadingOverlay({required this.from, required this.to});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _progress;
  late final AnimationController _stepFadeCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _progressAnim;
  late final Animation<double> _stepFade;

  int _step = 0;
  static const _steps = [
    'Calling Gemini AI...',
    'Discovering places...',
    'Building itinerary...',
    'Optimising budget...',
    'Wrapping up...',
  ];

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();
    _progressAnim = CurvedAnimation(
      parent: _progress,
      curve: Curves.easeInOutCubic,
    );

    _stepFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
    _stepFade = CurvedAnimation(parent: _stepFadeCtrl, curve: Curves.easeOut);

    _startSteps();
  }

  void _startSteps() async {
    for (int i = 1; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 660));
      if (!mounted) return;
      await _stepFadeCtrl.reverse();
      if (!mounted) return;
      setState(() => _step = i);
      _stepFadeCtrl.forward();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _progress.dispose();
    _stepFadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(gradient: TravelMateGradients.brand),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // From → To chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Chip(widget.from.isEmpty ? 'Origin' : widget.from),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.flight_rounded,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ),
                    _Chip(widget.to.isEmpty ? 'Destination' : widget.to),
                  ],
                ),

                const SizedBox(height: 56),

                // Pulsing icon
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Step text
                FadeTransition(
                  opacity: _stepFade,
                  child: Text(
                    _steps[_step],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ' ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 44),

                // Progress bar
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Stack(
                          children: [
                            Container(
                              height: 5,
                              color: Colors.white.withOpacity(0.18),
                            ),
                            FractionallySizedBox(
                              widthFactor: _progressAnim.value,
                              child: Container(height: 5, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${(_progressAnim.value * 1000).toInt()}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Step dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _step == i ? 22 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _step == i
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.5),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PLANNER SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  double _budget = 2500;
  int _days = 7;
  String _month = 'May';
  int _groupSize = 1;
  final bool _isGenerating = false;
  String _travelStyle = 'Balanced Traveler';

  final _months = const [
    'Jan',
    'Feb',
    'Mar',
    'April',
    'May',
    'June',
    'July',
    'August',
    'Sept',
    'Oct',
    'Nov',
    'Dec',
  ];
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _requestsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _budget = prefs.getDouble('budget') ?? 2500;
      _travelStyle = prefs.getString('travel_style') ?? 'Balanced Traveler';
    });
  }

  // ── DEMO — show overlay then navigate to TripResultPage ───────────────────
  Future<void> _generateItinerary() async {
    // Navigate with a small delay for feedback
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: const TripResultPage(planData: {}),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _countryCtrl.dispose();
    _requestsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Main form ────────────────────────────────────────────────────────
        Scaffold(
          backgroundColor: context.wBg,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: TravelMateColors.teal,
                title: const Text(
                  'Plan Your Journey',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: TravelMateGradients.brand,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _card(
                      icon: Icons.swap_vert_rounded,
                      label: 'ROUTE',
                      child: Column(
                        children: [
                          _row('From', 'Departure City', _fromCtrl),
                          Divider(color: context.wDivider, height: 20),
                          _row('To', 'Destination City', _toCtrl),
                          Divider(color: context.wDivider, height: 20),
                          _row(
                            'Country',
                            'Destination Country (optional)',
                            _countryCtrl,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    _card(
                      icon: Icons.calendar_month_outlined,
                      label: 'DATES',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 42,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _months.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, i) {
                                final m = _months[i];
                                final sel = m == _month;
                                return GestureDetector(
                                  onTap: () => setState(() => _month = m),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? TravelMateColors.teal
                                          : context.wBg,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: sel
                                            ? TravelMateColors.teal
                                            : context.wBorder,
                                      ),
                                    ),
                                    child: Text(
                                      m,
                                      style: TextStyle(
                                        color: sel
                                            ? Colors.white
                                            : context.wTextSub,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Trip Duration',
                                style: TextStyle(color: context.wTextSub),
                              ),
                              Text(
                                '$_days Days',
                                style: const TextStyle(
                                  color: TravelMateColors.teal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _days.toDouble(),
                            min: 1,
                            max: 30,
                            onChanged: (v) => setState(() => _days = v.round()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    _card(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'BUDGET',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TravelMateColors.teal.withOpacity(
                                      0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '₹ ${_budget.toInt() * 10}',
                                    style: TextStyle(
                                      color: context.wText,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Total Budget\n(INR)',
                                style: TextStyle(
                                  color: context.wTextSub,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'ESTIMATED BREAKDOWN',
                            style: TextStyle(
                              color: TravelMateColors.teal,
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 40,
                                  child: SizedBox(
                                    height: 8,
                                    child: ColoredBox(
                                      color: TravelMateColors.teal,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 30,
                                  child: SizedBox(
                                    height: 8,
                                    child: ColoredBox(
                                      color: TravelMateColors.amber,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 30,
                                  child: SizedBox(
                                    height: 8,
                                    child: ColoredBox(
                                      color: TravelMateColors.tealPale,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              _Dot(
                                color: TravelMateColors.teal,
                                label: 'Stay (40%)',
                              ),
                              SizedBox(width: 14),
                              _Dot(
                                color: TravelMateColors.amber,
                                label: 'Food (30%)',
                              ),
                              SizedBox(width: 14),
                              _Dot(
                                color: TravelMateColors.tealPale,
                                label: 'Other (30%)',
                              ),
                            ],
                          ),
                          Slider(
                            value: _budget,
                            min: 500,
                            max: 10000,
                            onChanged: (v) => setState(() => _budget = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    _card(
                      icon: Icons.group_outlined,
                      label: 'GROUP SIZE',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Travelers',
                            style: TextStyle(
                              color: context.wText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              _btn(Icons.remove, () {
                                if (_groupSize > 1) {
                                  setState(() => _groupSize--);
                                }
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  '$_groupSize',
                                  style: TextStyle(
                                    color: context.wText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              _btn(Icons.add, () {
                                if (_groupSize < 20) {
                                  setState(() => _groupSize++);
                                }
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: () async {
                        final styles = [
                          'Balanced Traveler',
                          'Adventure Seeker',
                          'Culture Explorer',
                          'Foodie',
                          'Luxury Traveler',
                          'Budget Backpacker',
                          'Beach Lover',
                          'Family Friendly',
                        ];
                        final picked = await showModalBottomSheet<String>(
                          context: context,
                          backgroundColor: context.wCard,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (_) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: context.wDivider,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...styles.map(
                                (s) => ListTile(
                                  title: Text(
                                    s,
                                    style: TextStyle(color: context.wText),
                                  ),
                                  trailing: s == _travelStyle
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: TravelMateColors.teal,
                                        )
                                      : null,
                                  onTap: () => Navigator.pop(context, s),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                        if (picked != null) {
                          setState(() => _travelStyle = picked);
                        }
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('travel_style', _travelStyle);
                      },
                      child: _card(
                        icon: Icons.tune,
                        label: 'TRAVEL STYLE',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _travelStyle,
                              style: TextStyle(
                                color: context.wText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Icon(Icons.expand_more, color: context.wTextSub),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _card(
                      icon: Icons.text_fields_outlined,
                      label: 'SPECIAL REQUESTS',
                      child: TextField(
                        controller: _requestsCtrl,
                        maxLines: 3,
                        style: TextStyle(color: context.wText, fontSize: 14),
                        decoration: InputDecoration(
                          hintText:
                              'Dietary needs, accessibility, specific interests...',
                          hintStyle: TextStyle(
                            color: context.wTextSub,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateItinerary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TravelMateColors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: _isGenerating
                            ? const SizedBox.shrink()
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Generate My Itinerary',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),

        // ── Loading overlay — fades + slides up over the form ────────────────
        if (_isGenerating)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            builder: (_, v, child) => Transform.translate(
              offset: Offset(0, (1 - v) * 60),
              child: Opacity(opacity: v, child: child),
            ),
            child: _LoadingOverlay(
              from: _fromCtrl.text.trim(),
              to: _toCtrl.text.trim(),
            ),
          ),
      ],
    );
  }

  Widget _row(String label, String hint, TextEditingController ctrl) => Row(
    children: [
      SizedBox(
        width: 52,
        child: Text(
          label,
          style: TextStyle(color: context.wTextSub, fontSize: 13),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Autocomplete<String>(
          optionsBuilder: (tv) {
            if (tv.text.isEmpty) return const Iterable.empty();
            final q = tv.text.toLowerCase();
            const places = [
              'Mumbai',
              'Delhi',
              'Bangalore',
              'Kolkata',
              'Chennai',
              'Pune',
              'Jaipur',
              'Agra',
              'Goa',
              'Kochi',
              'Manali',
              'Leh',
              'Varanasi',
              'Udaipur',
              'Hyderabad',
              'Ahmedabad',
              'Himachal Pradesh',
              'Shimla',
              'Kasol',
              'Darjeeling',
              'Dubai',
              'Singapore',
              'London',
              'Paris',
              'New York',
              'Tokyo',
              'Bali',
              'Bangkok',
            ];
            return places.where((p) => p.toLowerCase().contains(q));
          },
          onSelected: (s) => ctrl.text = s,
          fieldViewBuilder: (context, tCtrl, fn, _) {
            if (tCtrl.text != ctrl.text) tCtrl.text = ctrl.text;
            tCtrl.addListener(() => ctrl.text = tCtrl.text);
            return TextField(
              controller: tCtrl,
              focusNode: fn,
              style: TextStyle(color: context.wText, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: context.wTextSub, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              color: context.wCard,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 120,
                height: 200,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    final opt = options.elementAt(i);
                    return ListTile(
                      title: Text(
                        opt,
                        style: TextStyle(color: context.wText, fontSize: 14),
                      ),
                      onTap: () => onSelected(opt),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _card({
    required IconData icon,
    required String label,
    required Widget child,
  }) => Container(
    decoration: BoxDecoration(
      color: context.wCard,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.wBorder),
    ),
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: TravelMateColors.teal, size: 17),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: TravelMateColors.teal,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );

  Widget _btn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: TravelMateColors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TravelMateColors.teal.withOpacity(0.3)),
      ),
      child: Icon(icon, color: TravelMateColors.teal, size: 16),
    ),
  );
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(color: context.wTextSub, fontSize: 12)),
    ],
  );
}
