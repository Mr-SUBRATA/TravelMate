import 'package:flutter/material.dart';
import 'package:travel_Mate/theme/app_theme.dart';
//import '../theme/app_theme.dart';
import 'package:travel_Mate/main.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final appState = TravelMateApp.of(context);

    return Scaffold(
      backgroundColor: context.wBg,
      body: CustomScrollView(
        slivers: [
          // ── Gradient hero SliverAppBar ──
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: TravelMateColors.teal,
            actions: [
              IconButton(
                icon: Icon(
                  context.isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: Colors.white,
                ),
                onPressed: () => appState?.toggleTheme(),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: _NotifBell(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: TravelMateGradients.brandV,
                    ),
                  ),
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -60,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '😊',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Text(
                                    'Hello, Subrata 👋',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Where to ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(
                                  text: 'next?',
                                  style: TextStyle(
                                    color: TravelMateColors.amber,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'TravelMate AI is ready to chart your journey.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13,
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

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ── Search ──
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.wCard,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: context.wBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: TravelMateColors.teal,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search destinations...',
                            style: TextStyle(
                              color: context.wTextSub,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(Icons.mic_none, color: context.wTextSub, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Trending ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trending Destinations',
                        style: TextStyle(
                          color: context.wText,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'View all',
                        style: TextStyle(
                          color: TravelMateColors.teal,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 190,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: const [
                      _DestCard(
                        name: 'Kyoto, Japan',
                        region: 'East Asia',
                        tag: 'TRENDING',
                        emoji: '⛩️',
                      ),
                      SizedBox(width: 12),
                      _DestCard(
                        name: 'Santorini',
                        region: 'Mediterranean',
                        tag: 'POPULAR',
                        emoji: '🏝️',
                      ),
                      SizedBox(width: 12),
                      _DestCard(
                        name: 'Patagonia',
                        region: 'South America',
                        tag: 'HIDDEN GEM',
                        emoji: '🏔️',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Saved plans ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Saved Plans',
                        style: TextStyle(
                          color: context.wText,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'See all',
                        style: TextStyle(
                          color: TravelMateColors.teal,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _PlanTile(
                  icon: '🏖️',
                  title: 'Summer in Amalfi Coast',
                  sub: '7 days • 3 activities • Planned by AI',
                ),
                const _PlanTile(
                  icon: '🗼',
                  title: 'Romantic Paris Getaway',
                  sub: '3 days • 5 activities • Planned by AI',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifBell extends StatelessWidget {
  const _NotifBell();

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.notifications_outlined,
      color: Colors.white,
      size: 20,
    ),
  );
}

class _DestCard extends StatelessWidget {
  final String name, region, tag, emoji;

  const _DestCard({
    required this.name,
    required this.region,
    required this.tag,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 170,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: context.isDark
            ? [TravelMateColors.dCard, TravelMateColors.dSurface]
            : [
                TravelMateColors.tealPale.withOpacity(0.3),
                TravelMateColors.lCard,
              ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.wBorder),
    ),
    child: Stack(
      children: [
        Center(child: Text(emoji, style: const TextStyle(fontSize: 56))),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: TravelMateColors.amber,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          right: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: context.wText,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: TravelMateColors.teal,
                    size: 12,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    region,
                    style: TextStyle(color: context.wTextSub, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PlanTile extends StatelessWidget {
  final String icon, title, sub;

  const _PlanTile({required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.wCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.wBorder),
    ),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: TravelMateColors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.wText,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                sub,
                style: TextStyle(color: context.wTextSub, fontSize: 12),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: context.wTextSub, size: 20),
      ],
    ),
  );
}
