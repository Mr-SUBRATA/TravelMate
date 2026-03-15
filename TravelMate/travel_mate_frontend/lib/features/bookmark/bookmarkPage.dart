// import 'package:flutter/material.dart';
// import 'package:travel_Mate/theme/app_theme.dart';
// import 'package:travel_Mate/features/planning/tripResultPage.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // DEMO TRIPS — hardcoded, no backend needed
// // ─────────────────────────────────────────────────────────────────────────────
// final _demoTrips = <Map<String, dynamic>>[
//   {
//     'id': 'demo_1',
//     'destinationCity': 'Himachal Pradesh',
//     'destinationCountry': 'India',
//     'startDate': '2025-06-10',
//     'endDate': '2025-06-17',
//     'groupSize': 2,
//     'totalBudget': 45000,
//     'status': 'upcoming',
//     'emoji': '🏔️',
//   },
//   {
//     'id': 'demo_2',
//     'destinationCity': 'Goa',
//     'destinationCountry': 'India',
//     'startDate': '2025-08-01',
//     'endDate': '2025-08-05',
//     'groupSize': 4,
//     'totalBudget': 28000,
//     'status': 'upcoming',
//     'emoji': '🏖️',
//   },
//   {
//     'id': 'demo_3',
//     'destinationCity': 'Varanasi',
//     'destinationCountry': 'India',
//     'startDate': '2024-12-20',
//     'endDate': '2024-12-24',
//     'groupSize': 2,
//     'totalBudget': 18000,
//     'status': 'past',
//     'emoji': '🛕',
//   },
//   {
//     'id': 'demo_4',
//     'destinationCity': 'Rajasthan',
//     'destinationCountry': 'India',
//     'startDate': '2024-10-05',
//     'endDate': '2024-10-12',
//     'groupSize': 3,
//     'totalBudget': 35000,
//     'status': 'past',
//     'emoji': '🏰',
//   },
//   {
//     'id': 'demo_5',
//     'destinationCity': 'Andaman Islands',
//     'destinationCountry': 'India',
//     'startDate': '2025-12-15',
//     'endDate': '2025-12-22',
//     'groupSize': 2,
//     'totalBudget': 60000,
//     'status': 'draft',
//     'emoji': '🌊',
//   },
// ];

// // ─────────────────────────────────────────────────────────────────────────────
// // SAVED SCREEN
// // ─────────────────────────────────────────────────────────────────────────────
// class SavedScreen extends StatefulWidget {
//   const SavedScreen({super.key});
//   @override
//   State<SavedScreen> createState() => _SavedScreenState();
// }

// class _SavedScreenState extends State<SavedScreen> {
//   int _tab = 0;
//   final _tabs = const ['All', 'Upcoming', 'Past', 'Draft'];
//   late List<Map<String, dynamic>> _trips;

//   @override
//   void initState() {
//     super.initState();
//     // Load demo data — deep copy so deletes don't mutate the const list
//     _trips = _demoTrips.map((t) => Map<String, dynamic>.from(t)).toList();
//   }

//   void _deleteTrip(String id) {
//     setState(() => _trips.removeWhere((t) => t['id'] == id));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Trip removed.'),
//         backgroundColor: TravelMateColors.teal,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   List<Map<String, dynamic>> get _filtered {
//     if (_tab == 0) return _trips;
//     final now = DateTime.now();
//     return _trips.where((t) {
//       DateTime? start;
//       try {
//         start = DateTime.parse(t['startDate'] ?? '');
//       } catch (_) {}
//       switch (_tab) {
//         case 1:
//           return start != null && start.isAfter(now);
//         case 2:
//           return start != null && start.isBefore(now);
//         case 3:
//           return t['status'] == 'draft';
//         default:
//           return true;
//       }
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final trips = _filtered;
//     return Scaffold(
//       backgroundColor: context.wBg,
//       body: CustomScrollView(
//         slivers: [
//           // ── App bar ──────────────────────────────────────────────────────────
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: TravelMateColors.teal,
//             flexibleSpace: Container(
//               decoration: const BoxDecoration(
//                 gradient: TravelMateGradients.brand,
//               ),
//             ),
//             title: const Text(
//               'Saved Journeys',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 // ── Tabs ─────────────────────────────────────────────────────────
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//                   child: Row(
//                     children: List.generate(_tabs.length, (i) {
//                       final sel = i == _tab;
//                       return GestureDetector(
//                         onTap: () => setState(() => _tab = i),
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 24),
//                           child: Column(
//                             children: [
//                               Text(
//                                 _tabs[i],
//                                 style: TextStyle(
//                                   color: sel ? context.wText : context.wTextSub,
//                                   fontWeight: sel
//                                       ? FontWeight.w800
//                                       : FontWeight.w500,
//                                   fontSize: 15,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 height: 2,
//                                 width: sel ? 24 : 0,
//                                 decoration: BoxDecoration(
//                                   color: TravelMateColors.teal,
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//                 Divider(color: context.wDivider, height: 16),

//                 // ── Trip cards ───────────────────────────────────────────────────
//                 if (trips.isEmpty)
//                   _emptyState()
//                 else
//                   ...trips.asMap().entries.map((e) {
//                     final trip = e.value;
//                     return Padding(
//                       padding: EdgeInsets.fromLTRB(
//                         20,
//                         e.key == 0 ? 8 : 0,
//                         20,
//                         14,
//                       ),
//                       child: _JourneyCard(
//                         trip: trip,
//                         onDelete: () => _deleteTrip(trip['id']),
//                       ),
//                     );
//                   }),

//                 // ── Bottom CTA ───────────────────────────────────────────────────
//                 const SizedBox(height: 16),
//                 Container(
//                   width: 56,
//                   height: 56,
//                   decoration: const BoxDecoration(
//                     gradient: TravelMateGradients.brand,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Center(
//                     child: Text('🧭', style: TextStyle(fontSize: 24)),
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 Text(
//                   'Looking for more?',
//                   style: TextStyle(
//                     color: context.wText,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'Create a new journey to start\nyour next big adventure.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: context.wTextSub, fontSize: 14),
//                 ),
//                 const SizedBox(height: 18),
//                 OutlinedButton(
//                   onPressed: () {},
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: TravelMateColors.teal,
//                     side: const BorderSide(color: TravelMateColors.teal),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 28,
//                       vertical: 14,
//                     ),
//                   ),
//                   child: const Text(
//                     'Start Planning',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 const SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _emptyState() => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
//     child: Column(
//       children: [
//         const Text('🗺️', style: TextStyle(fontSize: 56)),
//         const SizedBox(height: 16),
//         Text(
//           'No saved journeys yet.',
//           style: TextStyle(
//             color: context.wText,
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           'Head to the Planner tab to start\nyour first adventure!',
//           textAlign: TextAlign.center,
//           style: TextStyle(color: context.wTextSub, fontSize: 14),
//         ),
//       ],
//     ),
//   );
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // JOURNEY CARD
// // ─────────────────────────────────────────────────────────────────────────────
// class _JourneyCard extends StatelessWidget {
//   final Map<String, dynamic> trip;
//   final VoidCallback onDelete;
//   const _JourneyCard({required this.trip, required this.onDelete});

//   String get _title => trip['destinationCity']?.toString() ?? 'Unknown';
//   String get _country => trip['destinationCountry']?.toString() ?? '';
//   String get _emoji => trip['emoji']?.toString() ?? '🌍';
//   String get _budget => '₹ ${trip['totalBudget']?.toString() ?? '?'}';

//   bool get _isUpcoming {
//     try {
//       return DateTime.parse(trip['startDate']).isAfter(DateTime.now());
//     } catch (_) {
//       return false;
//     }
//   }

//   bool get _isDraft => trip['status'] == 'draft';

//   String get _dates {
//     String fmt(String d) {
//       try {
//         final dt = DateTime.parse(d);
//         const months = [
//           'Jan',
//           'Feb',
//           'Mar',
//           'Apr',
//           'May',
//           'Jun',
//           'Jul',
//           'Aug',
//           'Sep',
//           'Oct',
//           'Nov',
//           'Dec',
//         ];
//         return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
//       } catch (_) {
//         return d;
//       }
//     }

//     final s = trip['startDate']?.toString() ?? '';
//     final e = trip['endDate']?.toString() ?? '';
//     if (s.isEmpty) return 'Date TBD';
//     return '${fmt(s)} → ${fmt(e)}';
//   }

//   Color get _statusColor {
//     if (_isDraft) return TravelMateColors.amber;
//     if (_isUpcoming) return TravelMateColors.teal;
//     return const Color(0xFF607D8B);
//   }

//   String get _statusLabel {
//     if (_isDraft) return 'DRAFT';
//     if (_isUpcoming) return 'UPCOMING';
//     return 'PAST';
//   }

//   List<Color> get _gradientColors {
//     if (_isDraft) return [const Color(0xFF4A3800), const Color(0xFF7A5F00)];
//     if (_isUpcoming) return [const Color(0xFF006B5F), const Color(0xFF00897B)];
//     return [const Color(0xFF0D3A35), const Color(0xFF1A5C52)];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: Key(trip['id']?.toString() ?? _title),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 24),
//         decoration: BoxDecoration(
//           color: TravelMateColors.error.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(
//               Icons.delete_outline_rounded,
//               color: TravelMateColors.error,
//               size: 26,
//             ),
//             SizedBox(height: 4),
//             Text(
//               'Remove',
//               style: TextStyle(
//                 color: TravelMateColors.error,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//       confirmDismiss: (_) async => await showDialog<bool>(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text('Remove Trip?'),
//           content: Text('Remove "$_title" from saved trips?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text(
//                 'Remove',
//                 style: TextStyle(color: TravelMateColors.error),
//               ),
//             ),
//           ],
//         ),
//       ),
//       onDismissed: (_) => onDelete(),
//       child: GestureDetector(
//         onTap: () => Navigator.of(context).push(
//           PageRouteBuilder(
//             transitionDuration: const Duration(milliseconds: 500),
//             pageBuilder: (_, anim, __) => FadeTransition(
//               opacity: anim,
//               child: const TripResultPage(planData: {}),
//             ),
//           ),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             color: context.wCard,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: context.wBorder),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Hero banner ────────────────────────────────────────────────
//               Stack(
//                 children: [
//                   Container(
//                     height: 130,
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(20),
//                       ),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: _gradientColors,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(_emoji, style: const TextStyle(fontSize: 52)),
//                     ),
//                   ),
//                   // Status badge
//                   Positioned(
//                     top: 12,
//                     right: 12,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 5,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _statusColor,
//                         borderRadius: BorderRadius.circular(50),
//                       ),
//                       child: Text(
//                         _statusLabel,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.w800,
//                           letterSpacing: 0.8,
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Group size badge
//                   Positioned(
//                     top: 12,
//                     left: 12,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 5,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.35),
//                         borderRadius: BorderRadius.circular(50),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.group_rounded,
//                             color: Colors.white,
//                             size: 12,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '${trip['groupSize'] ?? 1}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               // ── Trip info ──────────────────────────────────────────────────
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 _title,
//                                 style: TextStyle(
//                                   color: context.wText,
//                                   fontSize: 17,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                               if (_country.isNotEmpty) ...[
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   _country,
//                                   style: const TextStyle(
//                                     color: TravelMateColors.teal,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 7,
//                           ),
//                           decoration: BoxDecoration(
//                             color: TravelMateColors.teal.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(50),
//                             border: Border.all(
//                               color: TravelMateColors.teal.withOpacity(0.35),
//                             ),
//                           ),
//                           child: Text(
//                             _budget,
//                             style: const TextStyle(
//                               color: TravelMateColors.teal,
//                               fontWeight: FontWeight.w700,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 10),
//                     Divider(color: context.wDivider, height: 1),
//                     const SizedBox(height: 10),

//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.calendar_today_rounded,
//                           color: TravelMateColors.teal,
//                           size: 13,
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             _dates,
//                             style: TextStyle(
//                               color: context.wTextSub,
//                               fontSize: 12,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         // View button
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 5,
//                           ),
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [
//                                 TravelMateColors.gradStart,
//                                 TravelMateColors.gradEnd,
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           child: const Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 'View plan',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                               SizedBox(width: 4),
//                               Icon(
//                                 Icons.arrow_forward_rounded,
//                                 color: Colors.white,
//                                 size: 12,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_Mate/theme/app_theme.dart';
import 'package:travel_Mate/features/planning/tripResultPage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FALLBACK hardcoded trips shown before the user saves anything
// ─────────────────────────────────────────────────────────────────────────────
final _hardcodedTrips = <Map<String, dynamic>>[
  {
    'id': 'default_1',
    'destinationCity': 'Himachal Pradesh',
    'destinationCountry': 'India',
    'startDate': '2025-06-10',
    'endDate': '2025-06-17',
    'groupSize': 2,
    'totalBudget': 45000,
    'status': 'upcoming',
    'emoji': '🏔️',
  },
  {
    'id': 'default_2',
    'destinationCity': 'Goa',
    'destinationCountry': 'India',
    'startDate': '2025-08-01',
    'endDate': '2025-08-05',
    'groupSize': 4,
    'totalBudget': 28000,
    'status': 'upcoming',
    'emoji': '🏖️',
  },
  {
    'id': 'default_3',
    'destinationCity': 'Varanasi',
    'destinationCountry': 'India',
    'startDate': '2024-12-20',
    'endDate': '2024-12-24',
    'groupSize': 2,
    'totalBudget': 18000,
    'status': 'past',
    'emoji': '🛕',
  },
];

// ─────────────────────────────────────────────────────────────────────────────
// SAVED SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});
  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int _tab = 0;
  final _tabs = const ['All', 'Upcoming', 'Past', 'Draft'];

  // Each entry: { 'meta': { id, destinationCity, … }, 'planData': { … full plan … } }
  List<Map<String, dynamic>> _trips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('demo_saved_trips') ?? [];

    // Parse each saved JSON string
    final savedTrips = <Map<String, dynamic>>[];
    for (final json in saved) {
      try {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        savedTrips.add(decoded);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      // Show saved trips first, then hardcoded fallbacks
      _trips = [...savedTrips, ..._hardcodedTrips];
      _loading = false;
    });
  }

  Future<void> _deleteTrip(String id) async {
    // Remove from SharedPreferences if it's a saved trip
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('demo_saved_trips') ?? [];
    final updated = saved.where((json) {
      try {
        return jsonDecode(json)['meta']['id'] != id;
      } catch (_) {
        return true;
      }
    }).toList();
    await prefs.setStringList('demo_saved_trips', updated);

    setState(() => _trips.removeWhere((t) => _getId(t) == id));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip removed.'),
        backgroundColor: TravelMateColors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // A trip entry is either:
  //   { 'meta': {...}, 'planData': {...} }  ← saved from TripResultPage
  //   { 'id': ..., 'destinationCity': ... } ← hardcoded fallback
  String _getId(Map<String, dynamic> t) => t['meta'] != null
      ? t['meta']['id']?.toString() ?? ''
      : t['id']?.toString() ?? '';

  String _getCity(Map<String, dynamic> t) => t['meta'] != null
      ? t['meta']['destinationCity']?.toString() ?? 'Unknown'
      : t['destinationCity']?.toString() ?? 'Unknown';

  String _getCountry(Map<String, dynamic> t) => t['meta'] != null
      ? t['meta']['destinationCountry']?.toString() ?? ''
      : t['destinationCountry']?.toString() ?? '';

  int _getBudget(Map<String, dynamic> t) => t['meta'] != null
      ? (t['meta']['totalBudget'] as num?)?.toInt() ?? 0
      : (t['totalBudget'] as num?)?.toInt() ?? 0;

  String _getStartDate(Map<String, dynamic> t) => t['meta'] != null
      ? t['meta']['startDate']?.toString() ?? ''
      : t['startDate']?.toString() ?? '';

  String _getEndDate(Map<String, dynamic> t) => t['meta'] != null
      ? t['meta']['endDate']?.toString() ?? ''
      : t['endDate']?.toString() ?? '';

  int _getGroupSize(Map<String, dynamic> t) => t['meta'] != null
      ? (t['meta']['groupSize'] as num?)?.toInt() ?? 1
      : (t['groupSize'] as num?)?.toInt() ?? 1;

  String _getEmoji(Map<String, dynamic> t) {
    // Hardcoded trips carry an emoji directly
    if (t['emoji'] != null) return t['emoji'].toString();
    final city = _getCity(t).toLowerCase();
    if (city.contains('goa') || city.contains('beach') || city.contains('bali')) {
      return '🏖️';
    }
    if (city.contains('himachal') ||
        city.contains('manali') ||
        city.contains('leh')) {
      return '🏔️';
    }
    if (city.contains('varanasi') || city.contains('ayodhya')) return '🛕';
    if (city.contains('rajasthan') || city.contains('jaipur')) return '🏰';
    if (city.contains('andaman') || city.contains('kerala')) return '🌊';
    if (city.contains('delhi') || city.contains('agra')) return '🕌';
    return '🌍';
  }

  // Full planData to pass to TripResultPage — saved trips carry it; fallbacks use {}
  Map<String, dynamic> _getPlanData(Map<String, dynamic> t) =>
      t['planData'] != null
      ? Map<String, dynamic>.from(t['planData'] as Map)
      : {};

  List<Map<String, dynamic>> get _filtered {
    if (_tab == 0) return _trips;
    final now = DateTime.now();
    return _trips.where((t) {
      DateTime? start;
      try {
        start = DateTime.parse(_getStartDate(t));
      } catch (_) {}
      switch (_tab) {
        case 1:
          return start != null && start.isAfter(now);
        case 2:
          return start != null && start.isBefore(now);
        case 3:
          final status = (t['meta'] != null ? t['meta']['status'] : t['status'])
              ?.toString();
          return status == 'draft';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final trips = _filtered;
    return Scaffold(
      backgroundColor: context.wBg,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: TravelMateColors.teal,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: TravelMateGradients.brand,
              ),
            ),
            title: const Text(
              'Saved Journeys',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white.withOpacity(0.85),
                ),
                onPressed: _loadTrips,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Tabs ─────────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
                      final sel = i == _tab;
                      return GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: Column(
                            children: [
                              Text(
                                _tabs[i],
                                style: TextStyle(
                                  color: sel ? context.wText : context.wTextSub,
                                  fontWeight: sel
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 2,
                                width: sel ? 24 : 0,
                                decoration: BoxDecoration(
                                  color: TravelMateColors.teal,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Divider(color: context.wDivider, height: 16),

                // ── Body ─────────────────────────────────────────────────────────
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: CircularProgressIndicator(
                      color: TravelMateColors.teal,
                    ),
                  )
                else if (trips.isEmpty)
                  _emptyState()
                else
                  ...trips.asMap().entries.map((e) {
                    final trip = e.value;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        e.key == 0 ? 8 : 0,
                        20,
                        14,
                      ),
                      child: _JourneyCard(
                        city: _getCity(trip),
                        country: _getCountry(trip),
                        budget: _getBudget(trip),
                        startDate: _getStartDate(trip),
                        endDate: _getEndDate(trip),
                        groupSize: _getGroupSize(trip),
                        emoji: _getEmoji(trip),
                        planData: _getPlanData(trip),
                        onDelete: () => _deleteTrip(_getId(trip)),
                      ),
                    );
                  }),

                // ── Bottom CTA ───────────────────────────────────────────────────
                const SizedBox(height: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    gradient: TravelMateGradients.brand,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🧭', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Looking for more?',
                  style: TextStyle(
                    color: context.wText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create a new journey to start\nyour next big adventure.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.wTextSub, fontSize: 14),
                ),
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TravelMateColors.teal,
                    side: const BorderSide(color: TravelMateColors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Start Planning',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
    child: Column(
      children: [
        const Text('🗺️', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(
          'No saved journeys yet.',
          style: TextStyle(
            color: context.wText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Generate a plan and tap "Save" to\nsee it here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.wTextSub, fontSize: 14),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// JOURNEY CARD
// ─────────────────────────────────────────────────────────────────────────────
class _JourneyCard extends StatelessWidget {
  final String city, country, startDate, endDate, emoji;
  final int budget, groupSize;
  final Map<String, dynamic> planData;
  final VoidCallback onDelete;

  const _JourneyCard({
    required this.city,
    required this.country,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.groupSize,
    required this.emoji,
    required this.planData,
    required this.onDelete,
  });

  bool get _isUpcoming {
    try {
      return DateTime.parse(startDate).isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String get _dates {
    String fmt(String d) {
      try {
        final dt = DateTime.parse(d);
        const m = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
      } catch (_) {
        return d;
      }
    }

    if (startDate.isEmpty) return 'Date TBD';
    return '${fmt(startDate)} → ${fmt(endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('$city$startDate'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: TravelMateColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.delete_outline_rounded,
              color: TravelMateColors.error,
              size: 26,
            ),
            SizedBox(height: 4),
            Text(
              'Remove',
              style: TextStyle(
                color: TravelMateColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async => await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Remove Trip?'),
          content: Text('Remove "$city" from saved trips?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Remove',
                style: TextStyle(color: TravelMateColors.error),
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, anim, __) => FadeTransition(
              opacity: anim,
              // Pass planData — TripResultPage falls back to demo if empty {}
              child: TripResultPage(planData: planData),
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.wCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.wBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero banner ──────────────────────────────────────────────
              Stack(
                children: [
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isUpcoming
                            ? [const Color(0xFF006B5F), const Color(0xFF00897B)]
                            : [
                                const Color(0xFF0D3A35),
                                const Color(0xFF1A5C52),
                              ],
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 52)),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _isUpcoming
                            ? TravelMateColors.teal
                            : const Color(0xFF607D8B),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        _isUpcoming ? 'UPCOMING' : 'PAST',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  // Group size badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.group_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$groupSize',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Info ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city,
                                style: TextStyle(
                                  color: context.wText,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (country.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  country,
                                  style: const TextStyle(
                                    color: TravelMateColors.teal,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: TravelMateColors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: TravelMateColors.teal.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            '₹$budget',
                            style: const TextStyle(
                              color: TravelMateColors.teal,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Divider(color: context.wDivider, height: 1),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: TravelMateColors.teal,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _dates,
                            style: TextStyle(
                              color: context.wTextSub,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                TravelMateColors.gradStart,
                                TravelMateColors.gradEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View plan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
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
