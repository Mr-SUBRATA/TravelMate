import 'package:flutter/material.dart';
import 'package:travel_Mate/theme/app_theme.dart';
import 'package:travel_Mate/main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = [
      'Adventure',
      'Photography',
      'Budget Friendly',
      'Local Cuisine',
    ];
    final appState = TravelMateApp.of(context);

    return Scaffold(
      backgroundColor: context.wBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
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
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () {},
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
                    right: -50,
                    bottom: -50,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: const ClipOval(
                                  child: Center(
                                    child: Text(
                                      '👤',
                                      style: TextStyle(fontSize: 44),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: TravelMateColors.amber,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: TravelMateColors.teal,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Subrata',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Explorer since Jan 2023',
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(value: '1', label: 'TRIPS'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(value: '1', label: 'COUNTRIES'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(value: '45k', label: 'KM'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Preferences
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Travel Preferences',
                      style: TextStyle(
                        color: context.wText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Edit',
                      style: TextStyle(
                        color: TravelMateColors.teal,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...prefs.map((p) => _Chip(label: p)),
                    const _Chip(label: '+ Add More', isAdd: true),
                  ],
                ),
                const SizedBox(height: 24),

                // Settings rows
                const _Row(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                ),
                const _Row(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Currency',
                  trail: 'USD (\$)',
                ),
                const _Row(
                  icon: Icons.group_outlined,
                  label: 'Linked Accounts',
                ),
                const _Row(
                  icon: Icons.lock_outline,
                  label: 'Privacy & Security',
                ),
                const _Row(icon: Icons.help_outline, label: 'Help Center'),
                const _Row(
                  icon: Icons.info_outline,
                  label: 'About TravelMate AI',
                ),
                const SizedBox(height: 14),

                // Sign out
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: TravelMateColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: TravelMateColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Sign Out',
                        style: TextStyle(
                          color: TravelMateColors.error,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'Version 2.4.1 (Build 1082)',
                    style: TextStyle(color: context.wTextSub, fontSize: 12),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [TravelMateColors.gradStart, TravelMateColors.gradEnd],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isAdd;

  const _Chip({required this.label, this.isAdd = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: isAdd
          ? TravelMateColors.teal.withOpacity(0.1)
          : TravelMateColors.teal.withOpacity(0.08),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(
        color: isAdd ? TravelMateColors.teal : context.wBorder,
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: isAdd ? TravelMateColors.teal : context.wText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trail;

  const _Row({required this.icon, required this.label, this.trail});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    decoration: BoxDecoration(
      color: context.wCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.wBorder),
    ),
    child: Row(
      children: [
        Icon(icon, color: TravelMateColors.teal, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: context.wText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (trail != null) ...[
          Text(trail!, style: TextStyle(color: context.wTextSub, fontSize: 13)),
          const SizedBox(width: 4),
        ],
        Icon(Icons.chevron_right, color: context.wTextSub, size: 18),
      ],
    ),
  );
}
