// import 'package:flutter/material.dart';
// import 'package:travel_Mate/theme/app_theme.dart';

// class TripResultPage extends StatefulWidget {
//   final Map<String, dynamic> planData;

//   const TripResultPage({super.key, required this.planData});

//   @override
//   State<TripResultPage> createState() => _TripResultPageState();
// }

// class _TripResultPageState extends State<TripResultPage>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   late AnimationController _fadeCtrl;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _fadeCtrl = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
//     _fadeCtrl.forward();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _fadeCtrl.dispose();
//     super.dispose();
//   }

//   // ── Data helpers ──────────────────────────────────────────────────────────

//   Map<String, dynamic> get _tripReq =>
//       (widget.planData['trip_request'] as Map<String, dynamic>?) ?? {};
//   Map<String, dynamic> get _journey =>
//       (widget.planData['journey'] as Map<String, dynamic>?) ?? {};
//   Map<String, dynamic> get _budgetBreak =>
//       (widget.planData['budget_breakdown'] as Map<String, dynamic>?) ?? {};
//   Map<String, dynamic> get _destInfo =>
//       (widget.planData['destination_info'] as Map<String, dynamic>?) ?? {};
//   List<dynamic> get _itinerary =>
//       (widget.planData['itinerary'] as List<dynamic>?) ?? [];
//   List<dynamic> get _topRated =>
//       (_destInfo['top_rated'] as List<dynamic>?) ?? [];

//   String get _source => _tripReq['source']?.toString() ?? '';
//   String get _destination => _tripReq['destination']?.toString() ?? '';
//   int get _days => (_tripReq['days'] as num?)?.toInt() ?? 0;
//   int get _totalBudget => (_budgetBreak['total_budget'] as num?)?.toInt() ?? 0;

//   // ── Build ─────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.wBg,
//       body: FadeTransition(
//         opacity: _fadeAnim,
//         child: NestedScrollView(
//           headerSliverBuilder: (ctx, innerScrolled) => [
//             _buildSliverAppBar(),
//             SliverPersistentHeader(
//               pinned: true,
//               delegate: _TabBarDelegate(
//                 TabBar(
//                   controller: _tabController,
//                   labelColor: TravelMateColors.teal,
//                   unselectedLabelColor: context.wTextSub,
//                   indicatorColor: TravelMateColors.teal,
//                   indicatorWeight: 3,
//                   labelStyle: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 13,
//                   ),
//                   tabs: const [
//                     Tab(text: 'Itinerary'),
//                     Tab(text: 'Places'),
//                     Tab(text: 'Budget'),
//                   ],
//                 ),
//                 context,
//               ),
//             ),
//           ],
//           body: TabBarView(
//             controller: _tabController,
//             children: [
//               _ItineraryTab(itinerary: _itinerary, days: _days),
//               _PlacesTab(
//                 places: (_destInfo['places'] as List<dynamic>?) ?? [],
//                 topRated: _topRated,
//               ),
//               _BudgetTab(budgetBreak: _budgetBreak),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Sliver App Bar ────────────────────────────────────────────────────────

//   Widget _buildSliverAppBar() {
//     final transport = _journey['transport'] as Map<String, dynamic>? ?? {};
//     final emoji = transport['emoji']?.toString() ?? '🚂';
//     final mode = transport['mode']?.toString() ?? '';
//     final duration = transport['duration']?.toString() ?? '';
//     final distance = transport['distance']?.toString() ?? '';

//     return SliverAppBar(
//       expandedHeight: 220,
//       pinned: true,
//       stretch: true,
//       backgroundColor: TravelMateColors.teal,
//       flexibleSpace: FlexibleSpaceBar(
//         stretchModes: const [StretchMode.zoomBackground],
//         background: Container(
//           decoration: const BoxDecoration(gradient: TravelMateGradients.brand),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Source → Destination
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           _source,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       const Icon(
//                         Icons.arrow_forward_rounded,
//                         color: Colors.white70,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           _destination,
//                           textAlign: TextAlign.right,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.w900,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '$_days-Day Trip • ₹$_totalBudget Budget',
//                     style: const TextStyle(color: Colors.white70, fontSize: 13),
//                   ),
//                   const SizedBox(height: 16),
//                   // Journey pill
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.18),
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text('$emoji ', style: const TextStyle(fontSize: 16)),
//                         Text(
//                           '$mode  ·  $duration  ·  $distance',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
//         onPressed: () => Navigator.pop(context),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // TAB: Itinerary
// // ─────────────────────────────────────────────────────────────────────────────

// class _ItineraryTab extends StatefulWidget {
//   final List<dynamic> itinerary;
//   final int days;

//   const _ItineraryTab({required this.itinerary, required this.days});

//   @override
//   State<_ItineraryTab> createState() => _ItineraryTabState();
// }

// class _ItineraryTabState extends State<_ItineraryTab> {
//   final Set<int> _expanded = {0};

//   @override
//   Widget build(BuildContext context) {
//     if (widget.itinerary.isEmpty) {
//       return const Center(child: Text('No itinerary data available.'));
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//       itemCount: widget.itinerary.length,
//       itemBuilder: (ctx, i) {
//         final day = widget.itinerary[i] as Map<String, dynamic>;
//         final dayNum = (day['day'] as num?)?.toInt() ?? (i + 1);
//         final activities = (day['activities'] as List<dynamic>?) ?? [];
//         final dayTotal = (day['total_cost'] as num?)?.toInt() ?? 0;
//         final withinBudget = day['within_budget'] as bool? ?? true;
//         final isOpen = _expanded.contains(i);

//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           decoration: BoxDecoration(
//             color: context.wCard,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: context.wBorder),
//           ),
//           child: Column(
//             children: [
//               // Day header
//               InkWell(
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(20),
//                   bottom: Radius.circular(20),
//                 ),
//                 onTap: () => setState(() {
//                   if (isOpen) {
//                     _expanded.remove(i);
//                   } else {
//                     _expanded.add(i);
//                   }
//                 }),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 18,
//                     vertical: 14,
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 42,
//                         height: 42,
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [TravelMateColors.teal, Color(0xFF00BFA5)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Center(
//                           child: Text(
//                             'D$dayNum',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w900,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 14),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Day $dayNum',
//                               style: TextStyle(
//                                 color: context.wText,
//                                 fontWeight: FontWeight.w800,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             Text(
//                               '${activities.length} activities',
//                               style: TextStyle(
//                                 color: context.wTextSub,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       _CostBadge(cost: dayTotal, withinBudget: withinBudget),
//                       const SizedBox(width: 8),
//                       AnimatedRotation(
//                         turns: isOpen ? 0.5 : 0,
//                         duration: const Duration(milliseconds: 200),
//                         child: Icon(
//                           Icons.keyboard_arrow_down_rounded,
//                           color: context.wTextSub,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Activities
//               AnimatedSize(
//                 duration: const Duration(milliseconds: 250),
//                 curve: Curves.easeInOut,
//                 child: isOpen
//                     ? Column(
//                         children: [
//                           Divider(
//                             color: context.wDivider,
//                             height: 1,
//                             indent: 18,
//                           ),
//                           ...activities.map(
//                             (act) => _ActivityTile(
//                               activity: act as Map<String, dynamic>,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                         ],
//                       )
//                     : const SizedBox.shrink(),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _ActivityTile extends StatelessWidget {
//   final Map<String, dynamic> activity;
//   const _ActivityTile({required this.activity});

//   @override
//   Widget build(BuildContext context) {
//     final name = activity['name']?.toString() ?? '';
//     final time = activity['time']?.toString() ?? '';
//     final desc = activity['description']?.toString() ?? '';
//     final imageUrl = activity['image_url']?.toString() ?? '';
//     final rating = (activity['rating'] as num?)?.toDouble() ?? 0.0;
//     final cost = (activity['cost'] as num?)?.toInt() ?? 0;
//     final cats =
//         (activity['categories'] as List<dynamic>?)
//             ?.map((e) => e.toString())
//             .toList() ??
//         [];

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Left: time + vertical line
//           SizedBox(
//             width: 60,
//             child: Column(
//               children: [
//                 Text(
//                   time.split(' - ').first,
//                   style: TextStyle(
//                     color: TravelMateColors.teal,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(width: 2, height: 80, color: context.wDivider),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           // Right: card content
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 10),
//               decoration: BoxDecoration(
//                 color: context.wBg,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: context.wBorder),
//               ),
//               clipBehavior: Clip.antiAlias,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Image
//                   if (imageUrl.isNotEmpty)
//                     SizedBox(
//                       height: 110,
//                       width: double.infinity,
//                       child: Image.network(
//                         imageUrl,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => Container(
//                           color: TravelMateColors.teal.withOpacity(0.1),
//                           child: const Icon(
//                             Icons.image_not_supported_outlined,
//                             color: TravelMateColors.teal,
//                           ),
//                         ),
//                       ),
//                     ),
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 name,
//                                 style: TextStyle(
//                                   color: context.wText,
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               '₹$cost',
//                               style: const TextStyle(
//                                 color: TravelMateColors.teal,
//                                 fontWeight: FontWeight.w800,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                         if (rating > 0)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4, bottom: 6),
//                             child: Row(
//                               children: [
//                                 const Icon(
//                                   Icons.star_rounded,
//                                   color: TravelMateColors.amber,
//                                   size: 14,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   rating.toStringAsFixed(1),
//                                   style: TextStyle(
//                                     color: context.wTextSub,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         if (desc.isNotEmpty)
//                           Text(
//                             desc.length > 100
//                                 ? '${desc.substring(0, 100)}…'
//                                 : desc,
//                             style: TextStyle(
//                               color: context.wTextSub,
//                               fontSize: 12,
//                             ),
//                           ),
//                         if (cats.isNotEmpty) ...[
//                           const SizedBox(height: 8),
//                           Wrap(
//                             spacing: 6,
//                             runSpacing: 4,
//                             children: cats
//                                 .take(3)
//                                 .map((c) => _Chip(label: c))
//                                 .toList(),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // TAB: Places
// // ─────────────────────────────────────────────────────────────────────────────

// class _PlacesTab extends StatelessWidget {
//   final List<dynamic> places;
//   final List<dynamic> topRated;

//   const _PlacesTab({required this.places, required this.topRated});

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         if (topRated.isNotEmpty) ...[
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//               child: Text(
//                 '⭐  Top Rated',
//                 style: TextStyle(
//                   color: context.wText,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 220,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 itemCount: topRated.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 12),
//                 itemBuilder: (ctx, i) {
//                   final p = topRated[i] as Map<String, dynamic>;
//                   return _PlaceHeroCard(place: p);
//                 },
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
//               child: Text(
//                 '📍  All Places (${places.length})',
//                 style: TextStyle(
//                   color: context.wText,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//         ],
//         SliverPadding(
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
//           sliver: SliverGrid(
//             delegate: SliverChildBuilderDelegate(
//               (ctx, i) =>
//                   _PlaceGridCard(place: places[i] as Map<String, dynamic>),
//               childCount: places.length,
//             ),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.75,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PlaceHeroCard extends StatelessWidget {
//   final Map<String, dynamic> place;
//   const _PlaceHeroCard({required this.place});

//   @override
//   Widget build(BuildContext context) {
//     final name = place['name']?.toString() ?? '';
//     final imageUrl = place['image_url']?.toString() ?? '';
//     final rating = (place['rating'] as num?)?.toDouble() ?? 0.0;

//     return Container(
//       width: 160,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         color: context.wCard,
//         border: Border.all(color: context.wBorder),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           if (imageUrl.isNotEmpty)
//             Image.network(
//               imageUrl,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) =>
//                   Container(color: TravelMateColors.teal.withOpacity(0.1)),
//             ),
//           // gradient overlay
//           Positioned.fill(
//             child: DecoratedBox(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             left: 10,
//             right: 10,
//             bottom: 10,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 13,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.star_rounded,
//                       color: TravelMateColors.amber,
//                       size: 13,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       rating.toStringAsFixed(1),
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 11,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PlaceGridCard extends StatelessWidget {
//   final Map<String, dynamic> place;
//   const _PlaceGridCard({required this.place});

//   @override
//   Widget build(BuildContext context) {
//     final name = place['name']?.toString() ?? '';
//     final imageUrl = place['image_url']?.toString() ?? '';
//     final rating = (place['rating'] as num?)?.toDouble() ?? 0.0;
//     final priceLevel = (place['price_level'] as num?)?.toInt() ?? 1;
//     final desc = place['description']?.toString() ?? '';

//     return Container(
//       decoration: BoxDecoration(
//         color: context.wCard,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: context.wBorder),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: 110,
//             width: double.infinity,
//             child: imageUrl.isNotEmpty
//                 ? Image.network(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Container(
//                       color: TravelMateColors.teal.withOpacity(0.08),
//                       child: const Icon(
//                         Icons.image_not_supported_outlined,
//                         color: TravelMateColors.teal,
//                       ),
//                     ),
//                   )
//                 : Container(color: TravelMateColors.teal.withOpacity(0.08)),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: context.wText,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 12,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.star_rounded,
//                         color: TravelMateColors.amber,
//                         size: 12,
//                       ),
//                       Text(
//                         ' ${rating.toStringAsFixed(1)}',
//                         style: TextStyle(color: context.wTextSub, fontSize: 11),
//                       ),
//                       const Spacer(),
//                       Text(
//                         '₹' * priceLevel,
//                         style: const TextStyle(
//                           color: TravelMateColors.teal,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (desc.isNotEmpty) ...[
//                     const SizedBox(height: 4),
//                     Expanded(
//                       child: Text(
//                         desc,
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(color: context.wTextSub, fontSize: 10),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // TAB: Budget
// // ─────────────────────────────────────────────────────────────────────────────

// class _BudgetTab extends StatelessWidget {
//   final Map<String, dynamic> budgetBreak;
//   const _BudgetTab({required this.budgetBreak});

//   @override
//   Widget build(BuildContext context) {
//     final total = (budgetBreak['total_budget'] as num?)?.toInt() ?? 0;
//     final transport = (budgetBreak['transport_cost'] as num?)?.toInt() ?? 0;
//     final remaining =
//         (budgetBreak['remaining_for_activities'] as num?)?.toInt() ?? 0;
//     final daily = (budgetBreak['daily_budget'] as num?)?.toDouble() ?? 0;
//     final activities =
//         (budgetBreak['actual_activities_cost'] as num?)?.toInt() ?? 0;
//     final buffer = (budgetBreak['remaining_buffer'] as num?)?.toDouble() ?? 0;

//     double transportFrac = total > 0 ? transport / total : 0;
//     double activitiesFrac = total > 0 ? activities / total : 0;
//     double bufferFrac = (1 - transportFrac - activitiesFrac).clamp(0.0, 1.0);

//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
//       child: Column(
//         children: [
//           // Big total card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [TravelMateColors.teal, Color(0xFF00BFA5)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Column(
//               children: [
//                 const Text(
//                   'TOTAL BUDGET',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 11,
//                     letterSpacing: 2,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '₹$total',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 42,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '₹${daily.toStringAsFixed(0)} per day',
//                   style: const TextStyle(color: Colors.white70, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),

//           // Stacked progress bar
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: context.wCard,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: context.wBorder),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'BUDGET BREAKDOWN',
//                   style: TextStyle(
//                     color: context.wTextSub,
//                     fontSize: 11,
//                     letterSpacing: 1.8,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Bar
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Row(
//                     children: [
//                       Flexible(
//                         flex: (transportFrac * 100).round().clamp(1, 90),
//                         child: Container(
//                           height: 16,
//                           color: TravelMateColors.error,
//                         ),
//                       ),
//                       Flexible(
//                         flex: (activitiesFrac * 100).round().clamp(1, 90),
//                         child: Container(
//                           height: 16,
//                           color: TravelMateColors.amber,
//                         ),
//                       ),
//                       Flexible(
//                         flex: (bufferFrac * 100).round().clamp(1, 90),
//                         child: Container(
//                           height: 16,
//                           color: TravelMateColors.teal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 _BudgetRow(
//                   label: 'Transport',
//                   amount: transport,
//                   color: TravelMateColors.error,
//                 ),
//                 _BudgetRow(
//                   label: 'Activities',
//                   amount: activities,
//                   color: TravelMateColors.amber,
//                 ),
//                 _BudgetRow(
//                   label: 'Buffer / Remaining',
//                   amount: buffer.toInt(),
//                   color: TravelMateColors.teal,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Stat cards row
//           Row(
//             children: [
//               Expanded(
//                 child: _StatCard(
//                   icon: Icons.directions_transit,
//                   label: 'Transport',
//                   value: '₹$transport',
//                   sub: 'to destination',
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _StatCard(
//                   icon: Icons.savings_outlined,
//                   label: 'Remaining',
//                   value: '₹$remaining',
//                   sub: 'for activities',
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _StatCard(
//                   icon: Icons.today_outlined,
//                   label: 'Daily Budget',
//                   value: '₹${daily.toStringAsFixed(0)}',
//                   sub: 'per day',
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _StatCard(
//                   icon: Icons.emoji_events_outlined,
//                   label: 'Saved',
//                   value: '₹${buffer.toStringAsFixed(0)}',
//                   sub: 'buffer left',
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BudgetRow extends StatelessWidget {
//   final String label;
//   final int amount;
//   final Color color;
//   const _BudgetRow({
//     required this.label,
//     required this.amount,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(color: context.wTextSub, fontSize: 13),
//             ),
//           ),
//           Text(
//             '₹$amount',
//             style: TextStyle(
//               color: context.wText,
//               fontWeight: FontWeight.w700,
//               fontSize: 13,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final IconData icon;
//   final String label, value, sub;
//   const _StatCard({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.sub,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: context.wCard,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: context.wBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: TravelMateColors.teal, size: 20),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               color: context.wText,
//               fontWeight: FontWeight.w800,
//               fontSize: 18,
//             ),
//           ),
//           Text(sub, style: TextStyle(color: context.wTextSub, fontSize: 11)),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // SHARED WIDGETS
// // ─────────────────────────────────────────────────────────────────────────────

// class _Chip extends StatelessWidget {
//   final String label;
//   const _Chip({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: TravelMateColors.teal.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(50),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: TravelMateColors.teal,
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }

// class _CostBadge extends StatelessWidget {
//   final int cost;
//   final bool withinBudget;
//   const _CostBadge({required this.cost, required this.withinBudget});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: (withinBudget ? TravelMateColors.teal : TravelMateColors.error)
//             .withOpacity(0.1),
//         borderRadius: BorderRadius.circular(50),
//       ),
//       child: Text(
//         '₹$cost',
//         style: TextStyle(
//           color: withinBudget ? TravelMateColors.teal : TravelMateColors.error,
//           fontWeight: FontWeight.w700,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // TAB BAR DELEGATE
// // ─────────────────────────────────────────────────────────────────────────────

// class _TabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;
//   final BuildContext context;
//   _TabBarDelegate(this.tabBar, this.context);

//   @override
//   double get minExtent => tabBar.preferredSize.height + 1;
//   @override
//   double get maxExtent => tabBar.preferredSize.height + 1;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(
//       color: context.wBg,
//       child: Column(
//         children: [
//           tabBar,
//           Divider(color: context.wDivider, height: 1),
//         ],
//       ),
//     );
//   }

//   @override
//   bool shouldRebuild(_TabBarDelegate old) => false;
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_Mate/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// DEMO DATA — replace with real planData from your /plan endpoint
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, dynamic> _demoData = {
  'trip_request': {
    'source': 'Kolkata',
    'destination': 'Himachal Pradesh',
    'budget': 45000,
    'days': 7,
    'categories': ['adventure', 'trekking', 'mountain'],
    'timestamp': '2025-03-15T09:00:00',
  },
  'journey': {
    'from': 'Kolkata',
    'to': 'Manali',
    'transport': {
      'mode': 'Flight + Volvo Bus',
      'emoji': '✈️',
      'duration': '13–15 hours',
      'distance': '1,980 km',
      'cost': 7200,
    },
    'route_stops': ['Kolkata (CCU)', 'Delhi (DEL)', 'Manali Bus Stand'],
    'summary':
        'Fly Kolkata → Delhi, then overnight Volvo bus to Manali via NH3.',
  },
  'budget_breakdown': {
    'total_budget': 45000,
    'transport_cost': 7200,
    'remaining_for_activities': 37800,
    'daily_budget': 5400.0,
    'actual_activities_cost': 41800,
    'remaining_buffer': 3200.0,
  },
  'destination_info': {
    'city': 'Himachal Pradesh',
    'total_places_found': 21,
    'top_rated': [
      {
        'place_id': 'hp_01',
        'name': 'Rohtang Pass',
        'categories': ['mountain', 'adventure'],
        'price_level': 2,
        'rating': 4.9,
        'description':
            'High-altitude pass at 3,978m with glaciers and snowfields. One of India\'s most dramatic drives.',
        'city': 'Manali',
        'best_time_to_visit': 'morning',
        'duration_hours': 4,
        'address': 'Rohtang Pass, Himachal Pradesh',
        'image_url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Rohtang_pass_India.jpg/800px-Rohtang_pass_India.jpg',
      },
      {
        'place_id': 'hp_02',
        'name': 'Solang Valley',
        'categories': ['outdoor', 'adventure'],
        'price_level': 3,
        'rating': 4.8,
        'description':
            'Premier adventure hub for paragliding, zorbing, and snowfields near Manali.',
        'city': 'Manali',
        'best_time_to_visit': 'morning',
        'duration_hours': 3,
        'address': 'Solang Valley, Manali, Himachal Pradesh',
        'image_url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Solang_Valley_Manali.jpg/800px-Solang_Valley_Manali.jpg',
      },
      {
        'place_id': 'hp_03',
        'name': 'Kheerganga',
        'categories': ['trekking', 'nature'],
        'price_level': 1,
        'rating': 4.9,
        'description':
            '12 km moderate trek through forest and meadows to natural hot springs at 2,960m elevation.',
        'city': 'Kasol',
        'best_time_to_visit': 'morning',
        'duration_hours': 6,
        'address': 'Kheerganga, Parvati Valley, Himachal Pradesh',
        'image_url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Kheerganga.jpg/800px-Kheerganga.jpg',
      },
    ],
    'places': [
      {
        'place_id': 'hp_01',
        'name': 'Rohtang Pass',
        'categories': ['mountain', 'adventure'],
        'price_level': 2,
        'rating': 4.9,
        'description': 'High-altitude pass at 3,978m with glaciers.',
        'city': 'Manali',
        'best_time_to_visit': 'morning',
        'duration_hours': 4,
        'address': 'Rohtang Pass, HP',
        'image_url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Rohtang_pass_India.jpg/800px-Rohtang_pass_India.jpg',
      },
      {
        'place_id': 'hp_02',
        'name': 'Solang Valley',
        'categories': ['outdoor', 'adventure'],
        'price_level': 3,
        'rating': 4.8,
        'description': 'Adventure hub for paragliding and snow activities.',
        'city': 'Manali',
        'best_time_to_visit': 'morning',
        'duration_hours': 3,
        'address': 'Solang Valley, Manali',
        'image_url': '',
      },
      {
        'place_id': 'hp_03',
        'name': 'Kheerganga',
        'categories': ['trekking', 'nature'],
        'price_level': 1,
        'rating': 4.9,
        'description': 'Hot springs trek through pine forest.',
        'city': 'Kasol',
        'best_time_to_visit': 'morning',
        'duration_hours': 6,
        'address': 'Kheerganga, Parvati Valley',
        'image_url': '',
      },
      {
        'place_id': 'hp_04',
        'name': 'Hadimba Devi Temple',
        'categories': ['religious', 'landmark'],
        'price_level': 1,
        'rating': 4.7,
        'description': 'Ancient wooden temple in cedar forest.',
        'city': 'Manali',
        'best_time_to_visit': 'morning',
        'duration_hours': 2,
        'address': 'Old Manali, HP',
        'image_url': '',
      },
      {
        'place_id': 'hp_05',
        'name': 'Kasol Village',
        'categories': ['culture', 'nature'],
        'price_level': 1,
        'rating': 4.6,
        'description': 'Mini Israel of India along the Parvati River.',
        'city': 'Kasol',
        'best_time_to_visit': 'afternoon',
        'duration_hours': 3,
        'address': 'Kasol, Kullu District, HP',
        'image_url': '',
      },
      {
        'place_id': 'hp_06',
        'name': 'Shimla Mall Road',
        'categories': ['culture', 'landmark'],
        'price_level': 2,
        'rating': 4.5,
        'description':
            'Colonial promenade with Christ Church and Gaiety Theatre.',
        'city': 'Shimla',
        'best_time_to_visit': 'afternoon',
        'duration_hours': 3,
        'address': 'Mall Road, Shimla, HP',
        'image_url': '',
      },
    ],
  },
  'itinerary': [
    {
      'day': 1,
      'activities': [
        {
          'time': '06:00 – 08:00',
          'name': 'Arrival at Manali',
          'categories': ['travel', 'scenic'],
          'cost': 0,
          'rating': 0.0,
          'description':
              'Scenic arrival through Kullu valley after overnight bus from Delhi. Check into hotel in Old Manali.',
          'address': 'Old Manali, HP',
          'image_url': '',
        },
        {
          'time': '11:00 – 13:00',
          'name': 'Old Manali exploration',
          'categories': ['walking', 'culture'],
          'cost': 400,
          'rating': 4.5,
          'description':
              'Stroll through artisan shops, local cafes and the vibrant backpacker street.',
          'address': 'Old Manali, HP',
          'image_url': '',
        },
        {
          'time': '15:00 – 17:30',
          'name': 'Hadimba Devi Temple',
          'categories': ['religious', 'landmark'],
          'cost': 150,
          'rating': 4.7,
          'description':
              'Ancient 16th century wooden temple in a cedar forest. A crown jewel of Himachali architecture.',
          'address': 'Old Manali, HP',
          'image_url': '',
        },
        {
          'time': '19:00 – 20:30',
          'name': "Dinner at Johnson's Café",
          'categories': ['food'],
          'cost': 700,
          'rating': 4.6,
          'description':
              'Try the fresh river trout and Himachali dham in a riverside candlelit setting.',
          'address': 'Near Hadimba, Manali',
          'image_url': '',
        },
      ],
      'total_cost': 1250,
      'within_budget': true,
    },
    {
      'day': 2,
      'activities': [
        {
          'time': '08:00 – 12:00',
          'name': 'Solang Valley',
          'categories': ['adventure', 'outdoor'],
          'cost': 2500,
          'rating': 4.8,
          'description':
              'Paragliding, zorbing and snowfield activities. Book paragliding in advance for better pricing.',
          'address': 'Solang Valley, Manali',
          'image_url': '',
        },
        {
          'time': '13:00 – 14:30',
          'name': 'Lunch at Chopsticks',
          'categories': ['food'],
          'cost': 350,
          'rating': 4.5,
          'description':
              'Best momos and thukpa in the valley — a legendary stop for mountain trekkers.',
          'address': 'The Mall, Manali',
          'image_url': '',
        },
        {
          'time': '16:00 – 18:00',
          'name': 'Manu Temple Trek',
          'categories': ['trekking', 'religious'],
          'cost': 0,
          'rating': 4.4,
          'description':
              'Short 2 km hike through deodar forest to the hilltop temple dedicated to sage Manu.',
          'address': 'Old Manali, HP',
          'image_url': '',
        },
      ],
      'total_cost': 2850,
      'within_budget': true,
    },
    {
      'day': 3,
      'activities': [
        {
          'time': '06:30 – 10:00',
          'name': 'Rohtang Pass (3,978m)',
          'categories': ['mountain', 'adventure'],
          'cost': 1800,
          'rating': 4.9,
          'description':
              'High altitude pass with glaciers and snowfields. Government permit required — book online a day ahead.',
          'address': 'Rohtang Pass, HP',
          'image_url':
              'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Rohtang_pass_India.jpg/800px-Rohtang_pass_India.jpg',
        },
        {
          'time': '10:00 – 14:00',
          'name': 'Snow activities at Rohtang',
          'categories': ['adventure', 'outdoor'],
          'cost': 1200,
          'rating': 4.8,
          'description':
              'Sledging, snowmobiling and photography at one of India\'s most breathtaking high passes.',
          'address': 'Rohtang Pass, HP',
          'image_url': '',
        },
        {
          'time': '15:00 – 17:00',
          'name': 'Rahala Falls',
          'categories': ['nature', 'scenic'],
          'cost': 0,
          'rating': 4.6,
          'description':
              'Majestic cascading waterfall on the return route, fed by glacial meltwater from the Rohtang glacier.',
          'address': 'Manali–Leh Highway, HP',
          'image_url': '',
        },
      ],
      'total_cost': 3000,
      'within_budget': true,
    },
    {
      'day': 4,
      'activities': [
        {
          'time': '08:00 – 11:00',
          'name': 'Drive to Kasol',
          'categories': ['travel', 'scenic'],
          'cost': 600,
          'rating': 4.7,
          'description':
              '3-hour bus through the Parvati valley. The mini Israel of India along the stunning river gorge.',
          'address': 'Kasol, Kullu District',
          'image_url': '',
        },
        {
          'time': '11:30 – 14:00',
          'name': 'Chalal Trek',
          'categories': ['trekking', 'nature'],
          'cost': 0,
          'rating': 4.5,
          'description':
              'Easy 2 km riverside trail through pine forest to the quiet village of Chalal.',
          'address': 'Chalal, Kasol',
          'image_url': '',
        },
        {
          'time': '19:00 – 20:30',
          'name': 'Dinner at Evergreen Café',
          'categories': ['food'],
          'cost': 500,
          'rating': 4.7,
          'description':
              'Famous for Israeli dishes and Himachali recipes. The pasta and fresh lassi are must-tries.',
          'address': 'Main Street, Kasol',
          'image_url': '',
        },
      ],
      'total_cost': 1100,
      'within_budget': true,
    },
    {
      'day': 5,
      'activities': [
        {
          'time': '07:00 – 13:00',
          'name': 'Kheerganga Trek (12 km)',
          'categories': ['trekking', 'adventure'],
          'cost': 0,
          'rating': 4.9,
          'description':
              'Moderate 6-hour forest and meadow trek to the natural hot spring at 2,960m. Pack trail snacks.',
          'address': 'Barshaini Trailhead, Parvati Valley',
          'image_url': '',
        },
        {
          'time': '13:30 – 15:30',
          'name': 'Kheerganga Hot Springs',
          'categories': ['nature', 'wellness'],
          'cost': 100,
          'rating': 4.9,
          'description':
              'Natural geothermal pool at the summit. Sacred Shiva temple nearby. Perfect reward after the climb.',
          'address': 'Kheerganga Summit, HP',
          'image_url': '',
        },
        {
          'time': '16:00 – 20:00',
          'name': 'Return trek & overnight camp',
          'categories': ['trekking', 'camping'],
          'cost': 800,
          'rating': 4.5,
          'description':
              'Trek back as the valley lights up at sunset. Camp or cozy guesthouse stay in Kasol.',
          'address': 'Kasol, HP',
          'image_url': '',
        },
      ],
      'total_cost': 900,
      'within_budget': true,
    },
    {
      'day': 6,
      'activities': [
        {
          'time': '08:00 – 11:00',
          'name': 'Drive to Shimla',
          'categories': ['travel'],
          'cost': 450,
          'rating': 0.0,
          'description':
              '3-hour bus through the Shivalik foothills to the colonial hill station capital of Himachal.',
          'address': 'HRTC Bus Stand, Kasol',
          'image_url': '',
        },
        {
          'time': '11:30 – 14:00',
          'name': 'Mall Road & Christ Church',
          'categories': ['landmark', 'culture'],
          'cost': 200,
          'rating': 4.5,
          'description':
              'Walk the famous promenade, visit the neo-Gothic Christ Church and historic Gaiety Theatre.',
          'address': 'Mall Road, Shimla',
          'image_url': '',
        },
        {
          'time': '14:30 – 16:30',
          'name': 'Jakhu Temple & Hanuman Statue',
          'categories': ['religious', 'landmark'],
          'cost': 700,
          'rating': 4.6,
          'description':
              'Rope-way to Jakhu Hill at 8,048 ft. Home to the iconic 33m Hanuman statue and 360° valley views.',
          'address': 'Jakhu Hill, Shimla',
          'image_url': '',
        },
        {
          'time': '18:00 – 20:00',
          'name': 'Board Delhi overnight bus',
          'categories': ['travel'],
          'cost': 900,
          'rating': 0.0,
          'description':
              'Evening Volvo bus from Shimla ISBT back towards Delhi for next morning departure.',
          'address': 'ISBT Shimla, HP',
          'image_url': '',
        },
      ],
      'total_cost': 2250,
      'within_budget': true,
    },
    {
      'day': 7,
      'activities': [
        {
          'time': '06:00 – 09:00',
          'name': 'Delhi transfer to airport',
          'categories': ['travel'],
          'cost': 400,
          'rating': 0.0,
          'description':
              'Taxi from ISBT Kashmere Gate to IGI Airport T2. Time for a quick breakfast at the terminal.',
          'address': 'ISBT Kashmere Gate, Delhi',
          'image_url': '',
        },
        {
          'time': '11:00 – 13:30',
          'name': 'Delhi → Kolkata flight',
          'categories': ['travel'],
          'cost': 2200,
          'rating': 0.0,
          'description':
              '2.5 hour flight home. Stow those mountains in your heart and your phone full of epic photos.',
          'address': 'IGI Airport T2, Delhi',
          'image_url': '',
        },
      ],
      'total_cost': 2600,
      'within_budget': true,
    },
  ],
  'metadata': {
    'generated_by': 'TravelMate ML Service',
    'ai_model': 'Google Gemini 2.5 Flash',
    'generated_at': '2025-03-15T09:00:00',
    'version': '2.0.0',
  },
};

// ─────────────────────────────────────────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────────────────────────────────────────
class TripResultPage extends StatefulWidget {
  final Map<String, dynamic> planData;

  // Pass planData from your API call; falls back to demo data if empty.
  const TripResultPage({super.key, required this.planData});

  @override
  State<TripResultPage> createState() => _TripResultPageState();
}

class _TripResultPageState extends State<TripResultPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeCtrl;
  late AnimationController _heroCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _heroSlide;

  bool _isSaved = false;

  // Use passed data, fall back to demo
  late final Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.planData.isNotEmpty ? widget.planData : _demoData;

    _tabController = TabController(length: 3, vsync: this);

    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _heroCtrl = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeCtrl.dispose();
    _heroCtrl.dispose();
    super.dispose();
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  Map<String, dynamic> get _req =>
      (_data['trip_request'] as Map<String, dynamic>?) ?? {};
  Map<String, dynamic> get _journey =>
      (_data['journey'] as Map<String, dynamic>?) ?? {};
  Map<String, dynamic> get _budget =>
      (_data['budget_breakdown'] as Map<String, dynamic>?) ?? {};
  Map<String, dynamic> get _dest =>
      (_data['destination_info'] as Map<String, dynamic>?) ?? {};
  List<dynamic> get _itinerary => (_data['itinerary'] as List<dynamic>?) ?? [];

  String get _source => _req['source']?.toString() ?? 'Origin';
  String get _destination => _req['destination']?.toString() ?? 'Destination';
  int get _days => (_req['days'] as num?)?.toInt() ?? 0;
  int get _totalBudget => (_budget['total_budget'] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: context.wBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            _buildAppBar(),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabDelegate(_buildTabBar(), context),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _ItineraryTab(itinerary: _itinerary),
              _PlacesTab(
                places: (_dest['places'] as List<dynamic>?) ?? [],
                topRated: (_dest['top_rated'] as List<dynamic>?) ?? [],
              ),
              _BudgetTab(budget: _budget, journey: _journey),
            ],
          ),
        ),
      ),
    );
  }

  TabBar _buildTabBar() => TabBar(
    controller: _tabController,
    labelColor: TravelMateColors.teal,
    unselectedLabelColor: context.wTextSub,
    indicatorColor: TravelMateColors.teal,
    indicatorSize: TabBarIndicatorSize.label,
    indicatorWeight: 2.5,
    labelStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 13,
      letterSpacing: 0.3,
    ),
    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 13,
    ),
    tabs: const [
      Tab(text: 'Itinerary'),
      Tab(text: 'Places'),
      Tab(text: 'Budget'),
    ],
  );

  SliverAppBar _buildAppBar() {
    final transport = _journey['transport'] as Map<String, dynamic>? ?? {};
    final emoji = transport['emoji']?.toString() ?? '✈️';
    final mode = transport['mode']?.toString() ?? '';
    final duration = transport['duration']?.toString() ?? '';
    final distance = transport['distance']?.toString() ?? '';
    final stops =
        (_journey['route_stops'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return SliverAppBar(
      expandedHeight: 330,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: TravelMateColors.gradEnd,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () async {
              if (_isSaved) return; // Prevent saving multiple times
              final prefs = await SharedPreferences.getInstance();
              final demoTrip = {
                'id': 'demo_123_${DateTime.now().millisecondsSinceEpoch}',
                'destinationCity': _destination,
                'destinationCountry': '', // Approximation
                'startDate': DateTime.now()
                    .add(const Duration(days: 7))
                    .toIso8601String(),
                'endDate': DateTime.now()
                    .add(Duration(days: 7 + _days))
                    .toIso8601String(),
                'totalBudget': _totalBudget,
                'groupSize': 1, // Approximation
              };

              List<String> savedTrips =
                  prefs.getStringList('demo_saved_trips') ?? [];
              savedTrips.add(jsonEncode(demoTrip));
              await prefs.setStringList('demo_saved_trips', savedTrips);

              if (!mounted) return;
              setState(() => _isSaved = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demo trip saved to bookmarks!'),
                  backgroundColor: TravelMateColors.teal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isSaved
                    ? TravelMateColors.teal
                    : Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isSaved ? 'Saved' : 'Save',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(gradient: TravelMateGradients.brand),
          child: SafeArea(
            child: SlideTransition(
              position: _heroSlide,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 60, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // AI badge
                    const SizedBox(height: 10),

                    // Route
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            _source,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 1,
                                color: Colors.white38,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.flight_rounded,
                                  color: Colors.white60,
                                  size: 14,
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 1,
                                color: Colors.white38,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _destination,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_days-day trip  ·  ₹$_totalBudget budget',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Journey pill with stops
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '$emoji  $mode',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '$duration  ·  $distance',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (stops.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _StopRow(stops: stops),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STOP ROW — animated dots
// ─────────────────────────────────────────────────────────────────────────────
class _StopRow extends StatelessWidget {
  final List<String> stops;
  const _StopRow({required this.stops});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (int i = 0; i < stops.length; i++) {
      items.add(
        Text(
          stops[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      if (i < stops.length - 1) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: List.generate(
                4,
                (j) => Container(
                  width: 3,
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: const BoxDecoration(
                    color: Colors.white38,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: items);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: ITINERARY
// ─────────────────────────────────────────────────────────────────────────────
class _ItineraryTab extends StatefulWidget {
  final List<dynamic> itinerary;
  const _ItineraryTab({required this.itinerary});

  @override
  State<_ItineraryTab> createState() => _ItineraryTabState();
}

class _ItineraryTabState extends State<_ItineraryTab> {
  final Set<int> _expanded = {0};

  @override
  Widget build(BuildContext context) {
    if (widget.itinerary.isEmpty) {
      return Center(
        child: Text(
          'No itinerary available.',
          style: TextStyle(color: context.wTextSub),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: widget.itinerary.length,
      itemBuilder: (_, i) {
        final day = widget.itinerary[i] as Map<String, dynamic>;
        final dayNum = (day['day'] as num?)?.toInt() ?? (i + 1);
        final acts = (day['activities'] as List<dynamic>?) ?? [];
        final total = (day['total_cost'] as num?)?.toInt() ?? 0;
        final ok = day['within_budget'] as bool? ?? true;
        final open = _expanded.contains(i);

        // Day title from first activity or generic
        final dayTitles = [
          'Arrival & Old Manali',
          'Solang Valley',
          'Rohtang Pass',
          'Kasol & Parvati Valley',
          'Kheerganga Trek',
          'Shimla Day Trip',
          'Return to Kolkata',
        ];
        final title = i < dayTitles.length ? dayTitles[i] : 'Day $dayNum';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.wCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.wBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // Header
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() {
                      open ? _expanded.remove(i) : _expanded.add(i);
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Day number bubble
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  TravelMateColors.teal,
                                  TravelMateColors.tealDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'D',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  '$dayNum',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: context.wText,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${acts.length} activities',
                                  style: TextStyle(
                                    color: context.wTextSub,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Cost badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: ok
                                  ? TravelMateColors.teal.withOpacity(0.1)
                                  : TravelMateColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              '₹$total',
                              style: TextStyle(
                                color: ok
                                    ? TravelMateColors.teal
                                    : TravelMateColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: open ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: context.wTextSub,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Activities (animated)
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  child: open
                      ? Column(
                          children: [
                            Divider(
                              color: context.wDivider,
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                            ...List.generate(acts.length, (j) {
                              return _ActivityRow(
                                activity: acts[j] as Map<String, dynamic>,
                                isLast: j == acts.length - 1,
                              );
                            }),
                            const SizedBox(height: 4),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Map<String, dynamic> activity;
  final bool isLast;
  const _ActivityRow({required this.activity, required this.isLast});

  static const _catColors = {
    'adventure': Color(0xFF7C3AED),
    'trekking': Color(0xFF059669),
    'mountain': Color(0xFF0891B2),
    'nature': Color(0xFF16A34A),
    'food': Color(0xFFD97706),
    'religious': Color(0xFF9333EA),
    'landmark': Color(0xFF0284C7),
    'culture': Color(0xFFDB2777),
    'outdoor': Color(0xFF047857),
    'travel': Color(0xFF6B7280),
    'scenic': Color(0xFF0369A1),
    'wellness': Color(0xFF0F766E),
    'camping': Color(0xFF15803D),
    'walking': Color(0xFF7C3AED),
  };

  Color _catColor(String cat) =>
      _catColors[cat.toLowerCase()] ?? TravelMateColors.teal;

  @override
  Widget build(BuildContext context) {
    final name = activity['name']?.toString() ?? '';
    final time = activity['time']?.toString() ?? '';
    final desc = activity['description']?.toString() ?? '';
    final imageUrl = activity['image_url']?.toString() ?? '';
    final rating = (activity['rating'] as num?)?.toDouble() ?? 0.0;
    final cost = (activity['cost'] as num?)?.toInt() ?? 0;
    final cats =
        (activity['categories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final timeParts = time.split('–');
    final startTime = timeParts.isNotEmpty ? timeParts[0].trim() : time;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline column
            SizedBox(
              width: 52,
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Text(
                    startTime,
                    style: TextStyle(
                      color: TravelMateColors.teal,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: TravelMateColors.teal,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                      color: context.wCard,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: context.wDivider,
                        margin: const EdgeInsets.only(bottom: 0),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Content card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: context.wBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.wBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    if (imageUrl.isNotEmpty)
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _ImagePlaceholder(name: name),
                        ),
                      )
                    else if (cats.isNotEmpty)
                      Container(height: 4, color: _catColor(cats.first)),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color: context.wText,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              if (cost > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TravelMateColors.amber.withOpacity(
                                      0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '₹$cost',
                                    style: const TextStyle(
                                      color: TravelMateColors.amber,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TravelMateColors.teal.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Free',
                                    style: TextStyle(
                                      color: TravelMateColors.teal,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (rating > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: TravelMateColors.amber,
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: context.wTextSub,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (desc.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              desc.length > 110
                                  ? '${desc.substring(0, 110)}…'
                                  : desc,
                              style: TextStyle(
                                color: context.wTextSub,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                          if (cats.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 5,
                              runSpacing: 4,
                              children: cats.take(3).map((c) {
                                final col = _catColor(c);
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: col.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    c,
                                    style: TextStyle(
                                      color: col,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: PLACES
// ─────────────────────────────────────────────────────────────────────────────
class _PlacesTab extends StatelessWidget {
  final List<dynamic> places;
  final List<dynamic> topRated;
  const _PlacesTab({required this.places, required this.topRated});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Top rated horizontal strip
        if (topRated.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: TravelMateColors.amber,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Top rated',
                    style: TextStyle(
                      color: context.wText,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: topRated.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) =>
                    _HeroCard(place: topRated[i] as Map<String, dynamic>),
              ),
            ),
          ),
        ],

        // All places grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: TravelMateColors.teal,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'All places (${places.length})',
                  style: TextStyle(
                    color: context.wText,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _PlaceCard(place: places[i] as Map<String, dynamic>),
              childCount: places.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.78,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Map<String, dynamic> place;
  const _HeroCard({required this.place});

  @override
  Widget build(BuildContext context) {
    final name = place['name']?.toString() ?? '';
    final imageUrl = place['image_url']?.toString() ?? '';
    final rating = (place['rating'] as num?)?.toDouble() ?? 0.0;
    final cats =
        (place['categories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Container(
      width: 175,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.wCard,
        border: Border.all(color: context.wBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: TravelMateColors.teal.withOpacity(0.15)),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: TravelMateGradients.brand,
              ),
            ),
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cats.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      cats.first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: TravelMateColors.amber,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
}

class _PlaceCard extends StatelessWidget {
  final Map<String, dynamic> place;
  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    final name = place['name']?.toString() ?? '';
    final imageUrl = place['image_url']?.toString() ?? '';
    final rating = (place['rating'] as num?)?.toDouble() ?? 0.0;
    final priceLevel = (place['price_level'] as num?)?.toInt() ?? 1;
    final desc = place['description']?.toString() ?? '';
    final duration = (place['duration_hours'] as num?)?.toInt() ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: context.wCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.wBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ImagePlaceholder(name: name),
                  )
                : _ImagePlaceholder(name: name),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.wText,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: TravelMateColors.amber,
                        size: 12,
                      ),
                      Text(
                        ' ${rating.toStringAsFixed(1)}',
                        style: TextStyle(color: context.wTextSub, fontSize: 11),
                      ),
                      const Spacer(),
                      Text(
                        '₹' * priceLevel,
                        style: const TextStyle(
                          color: TravelMateColors.teal,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (duration > 0) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: context.wTextSub,
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$duration hrs',
                          style: TextStyle(
                            color: context.wTextSub,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        desc,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.wTextSub,
                          fontSize: 10,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: BUDGET
// ─────────────────────────────────────────────────────────────────────────────
class _BudgetTab extends StatelessWidget {
  final Map<String, dynamic> budget;
  final Map<String, dynamic> journey;
  const _BudgetTab({required this.budget, required this.journey});

  @override
  Widget build(BuildContext context) {
    final total = (budget['total_budget'] as num?)?.toInt() ?? 0;
    final transport = (budget['transport_cost'] as num?)?.toInt() ?? 0;
    final remaining =
        (budget['remaining_for_activities'] as num?)?.toInt() ?? 0;
    final daily = (budget['daily_budget'] as num?)?.toDouble() ?? 0;
    final activities = (budget['actual_activities_cost'] as num?)?.toInt() ?? 0;
    final buffer = (budget['remaining_buffer'] as num?)?.toDouble() ?? 0;

    final transportFrac = total > 0 ? transport / total : 0.0;
    final activitiesFrac = total > 0 ? activities / total : 0.0;
    final bufferFrac = (1 - transportFrac - activitiesFrac).clamp(0.0, 1.0);

    // Line items
    final lines = [
      _BudgetLine('✈️  Flight (Kolkata ↔ Delhi)', 5400, TravelMateColors.error),
      _BudgetLine(
        '🚌  Volvo bus (Delhi ↔ Manali)',
        1800,
        const Color(0xFFEF8C38),
      ),
      _BudgetLine('🏨  Accommodation (6 nights)', 12600, TravelMateColors.teal),
      _BudgetLine(
        '🎯  Activities & sightseeing',
        9800,
        TravelMateColors.tealDark,
      ),
      _BudgetLine('🍜  Food & local transport', 8400, const Color(0xFF26A69A)),
      _BudgetLine('🎒  Miscellaneous', 3800, context.wTextSub),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        children: [
          // Hero total card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TravelMateColors.gradStart, TravelMateColors.gradEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  'TOTAL BUDGET',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${daily.toStringAsFixed(0)} avg per day',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Inline stat row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _HeroStat(label: 'Transport', value: '₹$transport'),
                    Container(width: 1, height: 30, color: Colors.white24),
                    _HeroStat(label: 'Activities', value: '₹$activities'),
                    Container(width: 1, height: 30, color: Colors.white24),
                    _HeroStat(label: 'Buffer', value: '₹${buffer.toInt()}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stacked bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.wCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.wBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Breakdown',
                  style: TextStyle(
                    color: context.wText,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                // Segmented bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: [
                      Flexible(
                        flex: (transportFrac * 100).round().clamp(1, 90),
                        child: Container(
                          height: 18,
                          color: TravelMateColors.error,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        flex: (activitiesFrac * 100).round().clamp(1, 90),
                        child: Container(
                          height: 18,
                          color: TravelMateColors.amber,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        flex: (bufferFrac * 100).round().clamp(1, 90),
                        child: Container(
                          height: 18,
                          color: TravelMateColors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _BarLegend(
                      color: TravelMateColors.error,
                      label: 'Transport',
                    ),
                    const SizedBox(width: 14),
                    _BarLegend(
                      color: TravelMateColors.amber,
                      label: 'Activities',
                    ),
                    const SizedBox(width: 14),
                    _BarLegend(color: TravelMateColors.teal, label: 'Buffer'),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: context.wDivider, height: 1),
                const SizedBox(height: 14),
                // Line items
                ...lines.map((l) => _LineItem(line: l)),
                const SizedBox(height: 10),
                Divider(color: context.wDivider, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Total spent',
                      style: TextStyle(
                        color: context.wText,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹$activities',
                      style: const TextStyle(
                        color: TravelMateColors.teal,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2×2 stat cards
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.directions_bus_rounded,
                  label: 'Transport',
                  value: '₹$transport',
                  note: 'to destination',
                  iconColor: TravelMateColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'For activities',
                  value: '₹$remaining',
                  note: 'after travel',
                  iconColor: TravelMateColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.today_rounded,
                  label: 'Daily avg',
                  value: '₹${daily.toStringAsFixed(0)}',
                  note: 'per day',
                  iconColor: TravelMateColors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  icon: Icons.savings_rounded,
                  label: 'Buffer saved',
                  value: '₹${buffer.toInt()}',
                  note: 'emergency fund',
                  iconColor: const Color(0xFF26A69A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetLine {
  final String label;
  final int amount;
  final Color color;
  const _BudgetLine(this.label, this.amount, this.color);
}

class _LineItem extends StatelessWidget {
  final _BudgetLine line;
  const _LineItem({required this.line});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: line.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              line.label,
              style: TextStyle(color: context.wTextSub, fontSize: 13),
            ),
          ),
          Text(
            '₹${line.amount}',
            style: TextStyle(
              color: context.wText,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _BarLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: context.wTextSub, fontSize: 11)),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label, value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label, value, note;
  final Color iconColor;
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.wCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.wBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: context.wTextSub, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: context.wText,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text(note, style: TextStyle(color: context.wTextSub, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  final String name;
  const _ImagePlaceholder({required this.name});

  static const List<List<Color>> _palettes = [
    [Color(0xFF1D9E75), Color(0xFF0F6E56)],
    [Color(0xFF00B89C), Color(0xFF00897B)],
    [Color(0xFF0891B2), Color(0xFF0E7490)],
    [Color(0xFF7C3AED), Color(0xFF6D28D9)],
    [Color(0xFFD97706), Color(0xFFB45309)],
  ];

  @override
  Widget build(BuildContext context) {
    final idx = name.isEmpty ? 0 : name.codeUnitAt(0) % _palettes.length;
    final pal = _palettes[idx];
    final initials = name.length >= 2
        ? '${name[0]}${name[1]}'.toUpperCase()
        : name.isEmpty
        ? '?'
        : name[0].toUpperCase();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pal,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB BAR DELEGATE
// ─────────────────────────────────────────────────────────────────────────────
class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final BuildContext ctx;
  _TabDelegate(this.tabBar, this.ctx);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: context.wBg,
      child: Column(
        children: [
          tabBar,
          Divider(color: context.wDivider, height: 1),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabDelegate old) => false;
}



























// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:travel_Mate/theme/app_theme.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // DEMO DATA — replace with real planData from your /plan endpoint
// // ─────────────────────────────────────────────────────────────────────────────
// const Map<String, dynamic> _demoData = {
//   'trip_request': {
//     'source': 'Kolkata',
//     'destination': 'Himachal Pradesh',
//     'budget': 45000,
//     'days': 7,
//     'categories': ['adventure', 'trekking', 'mountain'],
//     'timestamp': '2025-03-15T09:00:00',
//   },
//   'journey': {
//     'from': 'Kolkata',
//     'to': 'Manali',
//     'transport': {
//       'mode': 'Flight + Volvo Bus',
//       'emoji': '✈️',
//       'duration': '13–15 hours',
//       'distance': '1,980 km',
//       'cost': 7200,
//     },
//     'route_stops': [
//       'Kolkata (CCU)',
//       'Delhi (DEL)',
//       'Manali Bus Stand',
//     ],
//     'summary':
//         'Fly Kolkata → Delhi, then overnight Volvo bus to Manali via NH3.',
//   },
//   'budget_breakdown': {
//     'total_budget': 45000,
//     'transport_cost': 7200,
//     'remaining_for_activities': 37800,
//     'daily_budget': 5400.0,
//     'actual_activities_cost': 41800,
//     'remaining_buffer': 3200.0,
//   },
//   'destination_info': {
//     'city': 'Himachal Pradesh',
//     'total_places_found': 21,
//     'top_rated': [
//       {
//         'place_id': 'hp_01',
//         'name': 'Rohtang Pass',
//         'categories': ['mountain', 'adventure'],
//         'price_level': 2,
//         'rating': 4.9,
//         'description':
//             'High-altitude pass at 3,978m with glaciers and snowfields. One of India\'s most dramatic drives.',
//         'city': 'Manali',
//         'best_time_to_visit': 'morning',
//         'duration_hours': 4,
//         'address': 'Rohtang Pass, Himachal Pradesh',
//         'image_url':
//             'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Rohtang_pass_India.jpg/800px-Rohtang_pass_India.jpg',
//       },
//       {
//         'place_id': 'hp_02',
//         'name': 'Solang Valley',
//         'categories': ['outdoor', 'adventure'],
//         'price_level': 3,
//         'rating': 4.8,
//         'description':
//             'Premier adventure hub for paragliding, zorbing, and snowfields near Manali.',
//         'city': 'Manali',
//         'best_time_to_visit': 'morning',
//         'duration_hours': 3,
//         'address': 'Solang Valley, Manali, Himachal Pradesh',
//         'image_url':
//             'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Solang_Valley_Manali.jpg/800px-Solang_Valley_Manali.jpg',
//       },
//       {
//         'place_id': 'hp_03',
//         'name': 'Kheerganga',
//         'categories': ['trekking', 'nature'],
//         'price_level': 1,
//         'rating': 4.9,
//         'description':
//             '12 km moderate trek through forest and meadows to natural hot springs at 2,960m elevation.',
//         'city': 'Kasol',
//         'best_time_to_visit': 'morning',
//         'duration_hours': 6,
//         'address': 'Kheerganga, Parvati Valley, Himachal Pradesh',
//         'image_url':
//             'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Kheerganga.jpg/800px-Kheerganga.jpg',
//       },
//     ],
//     'places': [
//       {
//         'place_id': 'hp_01',
//         'name': 'Rohtang Pass',
//         'categories': ['mountain', 'adventure'],
//         'price_level': 2,
//         'rating': 4.9,
//         'description': 'High-altitude pass at 3,978m with glaciers.',
//         'city': 'Manali',
//         'best_time_to_visit': 'morning',
//         'duration_hours': 4,
//         'address': 'Rohtang Pass, HP',
//         'image_url':
//             'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Rohtang_pass_India.jpg/800px-Rohtang_pass_India.jpg',
//       },
//       {
//         'place_id': 'hp_02',
//         'name': 'Solang Valley',
//         'categories': ['outdoor', 'adventure'],
//         'price_level': 3,
//         'rating': 4.8,
//         'description': 'Adventure hub for paragliding and snow activities.',
//         'city': 'Manali',
//         'best_time_to_visit': 'morning',
//         'duration_hours': 3,
//         'address': 'Solang Valley, Manali',
//         'image_url': '',
//       },
//       {
//         'place_id': 'hp_03',
//         'name': 'Kheerganga',
//         'categories': ['trekking', 'nature'],
//         'price_level': 1,
//         'rating': 4.9,
//         'description': 'Hot springs trek through pine forest.',
//         'city': 'Kasol',
//         'best_time_to_visit': 'morning',
//         'duration_hours': 6,
//         'address': 'Kheerganga, Parvati Valley',
//         'image_url': '',
//       },
//       {
//         'place_id': 'hp_04',
//         'name': 'Hadimba Devi Temple',
//         'categories': ['religious', 'landmark'],
//         'price_level': 1,
//         'rating': 4.7,
//         'description': 'Ancient wooden temple in cedar forest.',
//         'city': 'Manali',
//         'best_time_to_visit': 'morning',
//         'duration_hours': 2,
//         'address': 'Old Manali, HP',
//         'image_url': '',
//       },
//       {
//         'place_id': 'hp_05',
//         'name': 'Kasol Village',
//         'categories': ['culture', 'nature'],
//         'price_level': 1,
//         'rating': 4.6,
//         'description': 'Mini Israel of India along the Parvati River.',
//         'city': 'Kasol',
//         'best_time_to_visit': 'afternoon',
//         'duration_hours': 3,
//         'address': 'Kasol, Kullu District, HP',
//         'image_url': '',
//       },
//       {
//         'place_id': 'hp_06',
//         'name': 'Shimla Mall Road',
//         'categories': ['culture', 'landmark'],
//         'price_level': 2,
//         'rating': 4.5,
//         'description': 'Colonial promenade with Christ Church and Gaiety Theatre.',
//         'city': 'Shimla',
//         'best_time_to_visit': 'afternoon',
//         'duration_hours': 3,
//         'address': 'Mall Road, Shimla, HP',
//         'image_url': '',
//       },
//     ],
//   },
//   'itinerary': [
//     {
//       'day': 1,
//       'activities': [
//         {
//           'time': '06:00 – 08:00',
//           'name': 'Arrival at Manali',
//           'categories': ['travel', 'scenic'],
//           'cost': 0,
//           'rating': 0.0,
//           'description':
//               'Scenic arrival through Kullu valley after overnight bus from Delhi. Check into hotel in Old Manali.',
//           'address': 'Old Manali, HP',
//           'image_url': '',
//         },
//         {
//           'time': '11:00 – 13:00',
//           'name': 'Old Manali exploration',
//           'categories': ['walking', 'culture'],
//           'cost': 400,
//           'rating': 4.5,
//           'description':
//               'Stroll through artisan shops, local cafes and the vibrant backpacker street.',
//           'address': 'Old Manali, HP',
//           'image_url': '',
//         },
//         {
//           'time': '15:00 – 17:30',
//           'name': 'Hadimba Devi Temple',
//           'categories': ['religious', 'landmark'],
//           'cost': 150,
//           'rating': 4.7,
//           'description':
//               'Ancient 16th century wooden temple in a cedar forest. A crown jewel of Himachali architecture.',
//           'address': 'Old Manali, HP',
//           'image_url': '',
//         },
//         {
//           'time': '19:00 – 20:30',
//           'name': "Dinner at Johnson's Café",
//           'categories': ['food'],
//           'cost': 700,
//           'rating': 4.6,
//           'description':
//               'Try the fresh river trout and Himachali dham in a riverside candlelit setting.',
//           'address': 'Near Hadimba, Manali',
//           'image_url': '',
//         },
//       ],
//       'total_cost': 1250,
//       'within_budget': true,
//     },
//     {
//       'day': 2,
//       'activities': [
//         {
//           'time': '08:00 – 12:00',
//           'name': 'Solang Valley',
//           'categories': ['adventure', 'outdoor'],
//           'cost': 2500,
//           'rating': 4.8,
//           'description':
//               'Paragliding, zorbing and snowfield activities. Book paragliding in advance for better pricing.',
//           'address': 'Solang Valley, Manali',
//           'image_url': '',
//         },
//         {
//           'time': '13:00 – 14:30',
//           'name': 'Lunch at Chopsticks',
//           'categories': ['food'],
//           'cost': 350,
//           'rating': 4.5,
//           'description':
//               'Best momos and thukpa in the valley — a legendary stop for mountain trekkers.',
//           'address': 'The Mall, Manali',
//           'image_url': '',
//         },
//         {
//           'time': '16:00 – 18:00',
//           'name': 'Manu Temple Trek',
//           'categories': ['trekking', 'religious'],
//           'cost': 0,
//           'rating': 4.4,
//           'description':
//               'Short 2 km hike through deodar forest to the hilltop temple dedicated to sage Manu.',
//           'address': 'Old Manali, HP',
//           'image_url': '',
//         },
//       ],
//       'total_cost': 2850,
//       'within_budget': true,
//     },
//     {
//       'day': 3,
//       'activities': [
//         {
//           'time': '06:30 – 10:00',
//           'name': 'Rohtang Pass (3,978m)',
//           'categories': ['mountain', 'adventure'],
//           'cost': 1800,
//           'rating': 4.9,
//           'description':
//               'High altitude pass with glaciers and snowfields. Government permit required — book online a day ahead.',
//           'address': 'Rohtang Pass, HP',
//           'image_url':
//               'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Rohtang_pass_India.jpg/800px-Rohtang_pass_India.jpg',
//         },
//         {
//           'time': '10:00 – 14:00',
//           'name': 'Snow activities at Rohtang',
//           'categories': ['adventure', 'outdoor'],
//           'cost': 1200,
//           'rating': 4.8,
//           'description':
//               'Sledging, snowmobiling and photography at one of India\'s most breathtaking high passes.',
//           'address': 'Rohtang Pass, HP',
//           'image_url': '',
//         },
//         {
//           'time': '15:00 – 17:00',
//           'name': 'Rahala Falls',
//           'categories': ['nature', 'scenic'],
//           'cost': 0,
//           'rating': 4.6,
//           'description':
//               'Majestic cascading waterfall on the return route, fed by glacial meltwater from the Rohtang glacier.',
//           'address': 'Manali–Leh Highway, HP',
//           'image_url': '',
//         },
//       ],
//       'total_cost': 3000,
//       'within_budget': true,
//     },
//     {
//       'day': 4,
//       'activities': [
//         {
//           'time': '08:00 – 11:00',
//           'name': 'Drive to Kasol',
//           'categories': ['travel', 'scenic'],
//           'cost': 600,
//           'rating': 4.7,
//           'description':
//               '3-hour bus through the Parvati valley. The mini Israel of India along the stunning river gorge.',
//           'address': 'Kasol, Kullu District',
//           'image_url': '',
//         },
//         {
//           'time': '11:30 – 14:00',
//           'name': 'Chalal Trek',
//           'categories': ['trekking', 'nature'],
//           'cost': 0,
//           'rating': 4.5,
//           'description':
//               'Easy 2 km riverside trail through pine forest to the quiet village of Chalal.',
//           'address': 'Chalal, Kasol',
//           'image_url': '',
//         },
//         {
//           'time': '19:00 – 20:30',
//           'name': 'Dinner at Evergreen Café',
//           'categories': ['food'],
//           'cost': 500,
//           'rating': 4.7,
//           'description':
//               'Famous for Israeli dishes and Himachali recipes. The pasta and fresh lassi are must-tries.',
//           'address': 'Main Street, Kasol',
//           'image_url': '',
//         },
//       ],
//       'total_cost': 1100,
//       'within_budget': true,
//     },
//     {
//       'day': 5,
//       'activities': [
//         {
//           'time': '07:00 – 13:00',
//           'name': 'Kheerganga Trek (12 km)',
//           'categories': ['trekking', 'adventure'],
//           'cost': 0,
//           'rating': 4.9,
//           'description':
//               'Moderate 6-hour forest and meadow trek to the natural hot spring at 2,960m. Pack trail snacks.',
//           'address': 'Barshaini Trailhead, Parvati Valley',
//           'image_url': '',
//         },
//         {
//           'time': '13:30 – 15:30',
//           'name': 'Kheerganga Hot Springs',
//           'categories': ['nature', 'wellness'],
//           'cost': 100,
//           'rating': 4.9,
//           'description':
//               'Natural geothermal pool at the summit. Sacred Shiva temple nearby. Perfect reward after the climb.',
//           'address': 'Kheerganga Summit, HP',
//           'image_url': '',
//         },
//         {
//           'time': '16:00 – 20:00',
//           'name': 'Return trek & overnight camp',
//           'categories': ['trekking', 'camping'],
//           'cost': 800,
//           'rating': 4.5,
//           'description':
//               'Trek back as the valley lights up at sunset. Camp or cozy guesthouse stay in Kasol.',
//           'address': 'Kasol, HP',
//           'image_url': '',
//         },
//       ],
//       'total_cost': 900,
//       'within_budget': true,
//     },
//     {
//       'day': 6,
//       'activities': [
//         {
//           'time': '08:00 – 11:00',
//           'name': 'Drive to Shimla',
//           'categories': ['travel'],
//           'cost': 450,
//           'rating': 0.0,
//           'description':
//               '3-hour bus through the Shivalik foothills to the colonial hill station capital of Himachal.',
//           'address': 'HRTC Bus Stand, Kasol',
//           'image_url': '',
//         },
//         {
//           'time': '11:30 – 14:00',
//           'name': 'Mall Road & Christ Church',
//           'categories': ['landmark', 'culture'],
//           'cost': 200,
//           'rating': 4.5,
//           'description':
//               'Walk the famous promenade, visit the neo-Gothic Christ Church and historic Gaiety Theatre.',
//           'address': 'Mall Road, Shimla',
//           'image_url': '',
//         },
//         {
//           'time': '14:30 – 16:30',
//           'name': 'Jakhu Temple & Hanuman Statue',
//           'categories': ['religious', 'landmark'],
//           'cost': 700,
//           'rating': 4.6,
//           'description':
//               'Rope-way to Jakhu Hill at 8,048 ft. Home to the iconic 33m Hanuman statue and 360° valley views.',
//           'address': 'Jakhu Hill, Shimla',
//           'image_url': '',
//         },
//         {
//           'time': '18:00 – 20:00',
//           'name': 'Board Delhi overnight bus',
//           'categories': ['travel'],
//           'cost': 900,
//           'rating': 0.0,
//           'description':
//               'Evening Volvo bus from Shimla ISBT back towards Delhi for next morning departure.',
//           'address': 'ISBT Shimla, HP',
//           'image_url': '',
//         },
//       ],
//       'total_cost': 2250,
//       'within_budget': true,
//     },
//     {
//       'day': 7,
//       'activities': [
//         {
//           'time': '06:00 – 09:00',
//           'name': 'Delhi transfer to airport',
//           'categories': ['travel'],
//           'cost': 400,
//           'rating': 0.0,
//           'description':
//               'Taxi from ISBT Kashmere Gate to IGI Airport T2. Time for a quick breakfast at the terminal.',
//           'address': 'ISBT Kashmere Gate, Delhi',
//           'image_url': '',
//         },
//         {
//           'time': '11:00 – 13:30',
//           'name': 'Delhi → Kolkata flight',
//           'categories': ['travel'],
//           'cost': 2200,
//           'rating': 0.0,
//           'description':
//               '2.5 hour flight home. Stow those mountains in your heart and your phone full of epic photos.',
//           'address': 'IGI Airport T2, Delhi',
//           'image_url': '',
//         },
//       ],
//       'total_cost': 2600,
//       'within_budget': true,
//     },
//   ],
//   'metadata': {
//     'generated_by': 'TravelMate ML Service',
//     'ai_model': 'Google Gemini 2.5 Flash',
//     'generated_at': '2025-03-15T09:00:00',
//     'version': '2.0.0',
//   },
// };

// // ─────────────────────────────────────────────────────────────────────────────
// // MAIN PAGE
// // ─────────────────────────────────────────────────────────────────────────────
// class TripResultPage extends StatefulWidget {
//   final Map<String, dynamic> planData;

//   // Pass planData from your API call; falls back to demo data if empty.
//   const TripResultPage({super.key, required this.planData});

//   @override
//   State<TripResultPage> createState() => _TripResultPageState();
// }

// class _TripResultPageState extends State<TripResultPage>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   late AnimationController _fadeCtrl;
//   late AnimationController _heroCtrl;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _heroSlide;

//   bool _isSaved = false;

//   // Use passed data, fall back to demo
//   late final Map<String, dynamic> _data;

//   @override
//   void initState() {
//     super.initState();
//     _data = widget.planData.isNotEmpty ? widget.planData : _demoData;

//     _tabController = TabController(length: 3, vsync: this);

//     _fadeCtrl = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

//     _heroCtrl = AnimationController(
//       duration: const Duration(milliseconds: 700),
//       vsync: this,
//     );
//     _heroSlide = Tween<Offset>(
//       begin: const Offset(0, 0.12),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

//     _fadeCtrl.forward();
//     _heroCtrl.forward();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _fadeCtrl.dispose();
//     _heroCtrl.dispose();
//     super.dispose();
//   }

//   // ── Getters ───────────────────────────────────────────────────────────────
//   Map<String, dynamic> get _req =>
//       (_data['trip_request'] as Map<String, dynamic>?) ?? {};
//   Map<String, dynamic> get _journey =>
//       (_data['journey'] as Map<String, dynamic>?) ?? {};
//   Map<String, dynamic> get _budget =>
//       (_data['budget_breakdown'] as Map<String, dynamic>?) ?? {};
//   Map<String, dynamic> get _dest =>
//       (_data['destination_info'] as Map<String, dynamic>?) ?? {};
//   List<dynamic> get _itinerary =>
//       (_data['itinerary'] as List<dynamic>?) ?? [];

//   String get _source => _req['source']?.toString() ?? 'Origin';
//   String get _destination => _req['destination']?.toString() ?? 'Destination';
//   int get _days => (_req['days'] as num?)?.toInt() ?? 0;
//   int get _totalBudget =>
//       (_budget['total_budget'] as num?)?.toInt() ?? 0;

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
//     return Scaffold(
//       backgroundColor: context.wBg,
//       body: FadeTransition(
//         opacity: _fadeAnim,
//         child: NestedScrollView(
//           headerSliverBuilder: (ctx, _) => [
//             _buildAppBar(),
//             SliverPersistentHeader(
//               pinned: true,
//               delegate: _TabDelegate(_buildTabBar(), context),
//             ),
//           ],
//           body: TabBarView(
//             controller: _tabController,
//             children: [
//               _ItineraryTab(itinerary: _itinerary),
//               _PlacesTab(
//                 places:
//                     (_dest['places'] as List<dynamic>?) ?? [],
//                 topRated:
//                     (_dest['top_rated'] as List<dynamic>?) ?? [],
//               ),
//               _BudgetTab(budget: _budget, journey: _journey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   TabBar _buildTabBar() => TabBar(
//         controller: _tabController,
//         labelColor: TravelMateColors.teal,
//         unselectedLabelColor: context.wTextSub,
//         indicatorColor: TravelMateColors.teal,
//         indicatorSize: TabBarIndicatorSize.label,
//         indicatorWeight: 2.5,
//         labelStyle: const TextStyle(
//           fontWeight: FontWeight.w700,
//           fontSize: 13,
//           letterSpacing: 0.3,
//         ),
//         unselectedLabelStyle: const TextStyle(
//           fontWeight: FontWeight.w500,
//           fontSize: 13,
//         ),
//         tabs: const [
//           Tab(text: 'Itinerary'),
//           Tab(text: 'Places'),
//           Tab(text: 'Budget'),
//         ],
//       );

//   SliverAppBar _buildAppBar() {
//     final transport =
//         _journey['transport'] as Map<String, dynamic>? ?? {};
//     final emoji = transport['emoji']?.toString() ?? '✈️';
//     final mode = transport['mode']?.toString() ?? '';
//     final duration = transport['duration']?.toString() ?? '';
//     final distance = transport['distance']?.toString() ?? '';
//     final stops = (_journey['route_stops'] as List<dynamic>?)
//             ?.map((e) => e.toString())
//             .toList() ??
//         [];

//     return SliverAppBar(
//       expandedHeight: 270,
//       pinned: true,
//       stretch: true,
//       elevation: 0,
//       backgroundColor: TravelMateColors.gradEnd,
//       leading: Padding(
//         padding: const EdgeInsets.all(8),
//         child: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.18),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.arrow_back_ios_new_rounded,
//               color: Colors.white,
//               size: 18,
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 12),
//           child: GestureDetector(
//             onTap: () async {
//               if (_isSaved) return;
//               final prefs = await SharedPreferences.getInstance();
//               final entry = {
//                 'meta': {
//                   'id': 'saved_\${DateTime.now().millisecondsSinceEpoch}',
//                   'destinationCity': _destination,
//                   'destinationCountry': '',
//                   'startDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
//                   'endDate': DateTime.now().add(Duration(days: 7 + _days)).toIso8601String(),
//                   'totalBudget': _totalBudget,
//                   'groupSize': (_req['members'] as num?)?.toInt() ?? 2,
//                   'status': 'upcoming',
//                 },
//                 'planData': _data,
//               };
//               final saved = prefs.getStringList('demo_saved_trips') ?? [];
//               saved.insert(0, jsonEncode(entry));
//               await prefs.setStringList('demo_saved_trips', saved);
//               if (!mounted) return;
//               setState(() => _isSaved = true);
//               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                 content: Text('Trip saved to bookmarks!'),
//                 backgroundColor: TravelMateColors.teal,
//                 behavior: SnackBarBehavior.floating,
//               ));
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.18),
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: Row(
//                 children: const [
//                   Icon(Icons.bookmark_border_rounded,
//                       color: Colors.white, size: 16),
//                   SizedBox(width: 6),
//                   Text(
//                     'Save',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         stretchModes: const [StretchMode.zoomBackground],
//         background: Container(
//           decoration: const BoxDecoration(gradient: TravelMateGradients.brand),
//           child: SafeArea(
//             child: SlideTransition(
//               position: _heroSlide,
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(22, 60, 22, 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // AI badge
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.20),
//                         borderRadius: BorderRadius.circular(50),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const [
//                           Icon(Icons.auto_awesome,
//                               color: Colors.white, size: 11),
//                           SizedBox(width: 5),
//                           Text(
//                             'Gemini 2.5 Flash',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 10),

//                     // Route
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             _source,
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Row(
//                             children: [
//                               Container(
//                                   width: 20,
//                                   height: 1,
//                                   color: Colors.white38),
//                               const Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 4),
//                                 child: Icon(Icons.flight_rounded,
//                                     color: Colors.white60, size: 14),
//                               ),
//                               Container(
//                                   width: 20,
//                                   height: 1,
//                                   color: Colors.white38),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Text(
//                             _destination,
//                             textAlign: TextAlign.right,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       '$_days-day trip  ·  ₹$_totalBudget budget',
//                       style: const TextStyle(
//                         color: Colors.white60,
//                         fontSize: 13,
//                       ),
//                     ),
//                     const SizedBox(height: 14),

//                     // Journey pill with stops
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 14, vertical: 10),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(
//                             color: Colors.white.withOpacity(0.2), width: 0.5),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 '$emoji  $mode',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Text(
//                                 '$duration  ·  $distance',
//                                 style: const TextStyle(
//                                   color: Colors.white60,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (stops.isNotEmpty) ...[
//                             const SizedBox(height: 8),
//                             _StopRow(stops: stops),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // STOP ROW — animated dots
// // ─────────────────────────────────────────────────────────────────────────────
// class _StopRow extends StatelessWidget {
//   final List<String> stops;
//   const _StopRow({required this.stops});

//   @override
//   Widget build(BuildContext context) {
//     final items = <Widget>[];
//     for (int i = 0; i < stops.length; i++) {
//       items.add(
//         Text(
//           stops[i],
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       );
//       if (i < stops.length - 1) {
//         items.add(
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 6),
//             child: Row(
//               children: List.generate(
//                 4,
//                 (j) => Container(
//                   width: 3,
//                   height: 3,
//                   margin: const EdgeInsets.symmetric(horizontal: 1),
//                   decoration: const BoxDecoration(
//                     color: Colors.white38,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }
//     }
//     return Wrap(
//       crossAxisAlignment: WrapCrossAlignment.center,
//       children: items,
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // TAB: ITINERARY
// // ─────────────────────────────────────────────────────────────────────────────
// class _ItineraryTab extends StatefulWidget {
//   final List<dynamic> itinerary;
//   const _ItineraryTab({required this.itinerary});

//   @override
//   State<_ItineraryTab> createState() => _ItineraryTabState();
// }

// class _ItineraryTabState extends State<_ItineraryTab> {
//   final Set<int> _expanded = {0};

//   @override
//   Widget build(BuildContext context) {
//     if (widget.itinerary.isEmpty) {
//       return Center(
//         child: Text('No itinerary available.',
//             style: TextStyle(color: context.wTextSub)),
//       );
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//       itemCount: widget.itinerary.length,
//       itemBuilder: (_, i) {
//         final day = widget.itinerary[i] as Map<String, dynamic>;
//         final dayNum = (day['day'] as num?)?.toInt() ?? (i + 1);
//         final acts = (day['activities'] as List<dynamic>?) ?? [];
//         final total = (day['total_cost'] as num?)?.toInt() ?? 0;
//         final ok = day['within_budget'] as bool? ?? true;
//         final open = _expanded.contains(i);

//         // Day title from first activity or generic
//         final dayTitles = [
//           'Arrival & Old Manali',
//           'Solang Valley',
//           'Rohtang Pass',
//           'Kasol & Parvati Valley',
//           'Kheerganga Trek',
//           'Shimla Day Trip',
//           'Return to Kolkata',
//         ];
//         final title = i < dayTitles.length ? dayTitles[i] : 'Day $dayNum';

//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           margin: const EdgeInsets.only(bottom: 12),
//           decoration: BoxDecoration(
//             color: context.wCard,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: context.wBorder),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: Column(
//               children: [
//                 // Header
//                 Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () => setState(() {
//                       open ? _expanded.remove(i) : _expanded.add(i);
//                     }),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Row(
//                         children: [
//                           // Day number bubble
//                           Container(
//                             width: 46,
//                             height: 46,
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 colors: [
//                                   TravelMateColors.teal,
//                                   TravelMateColors.tealDark
//                                 ],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'D',
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.75),
//                                     fontSize: 9,
//                                     fontWeight: FontWeight.w700,
//                                     height: 1,
//                                   ),
//                                 ),
//                                 Text(
//                                   '$dayNum',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w900,
//                                     height: 1,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 14),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   title,
//                                   style: TextStyle(
//                                     color: context.wText,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 15,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   '${acts.length} activities',
//                                   style: TextStyle(
//                                     color: context.wTextSub,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           // Cost badge
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 5),
//                             decoration: BoxDecoration(
//                               color: ok
//                                   ? TravelMateColors.teal.withOpacity(0.1)
//                                   : TravelMateColors.error.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             child: Text(
//                               '₹$total',
//                               style: TextStyle(
//                                 color: ok
//                                     ? TravelMateColors.teal
//                                     : TravelMateColors.error,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           AnimatedRotation(
//                             turns: open ? 0.5 : 0,
//                             duration: const Duration(milliseconds: 250),
//                             child: Icon(
//                               Icons.keyboard_arrow_down_rounded,
//                               color: context.wTextSub,
//                               size: 22,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Activities (animated)
//                 AnimatedSize(
//                   duration: const Duration(milliseconds: 280),
//                   curve: Curves.easeInOutCubic,
//                   child: open
//                       ? Column(
//                           children: [
//                             Divider(
//                               color: context.wDivider,
//                               height: 1,
//                               indent: 16,
//                               endIndent: 16,
//                             ),
//                             ...List.generate(acts.length, (j) {
//                               return _ActivityRow(
//                                 activity:
//                                     acts[j] as Map<String, dynamic>,
//                                 isLast: j == acts.length - 1,
//                               );
//                             }),
//                             const SizedBox(height: 4),
//                           ],
//                         )
//                       : const SizedBox.shrink(),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class _ActivityRow extends StatelessWidget {
//   final Map<String, dynamic> activity;
//   final bool isLast;
//   const _ActivityRow({required this.activity, required this.isLast});

//   static const _catColors = {
//     'adventure': Color(0xFF7C3AED),
//     'trekking': Color(0xFF059669),
//     'mountain': Color(0xFF0891B2),
//     'nature': Color(0xFF16A34A),
//     'food': Color(0xFFD97706),
//     'religious': Color(0xFF9333EA),
//     'landmark': Color(0xFF0284C7),
//     'culture': Color(0xFFDB2777),
//     'outdoor': Color(0xFF047857),
//     'travel': Color(0xFF6B7280),
//     'scenic': Color(0xFF0369A1),
//     'wellness': Color(0xFF0F766E),
//     'camping': Color(0xFF15803D),
//     'walking': Color(0xFF7C3AED),
//   };

//   Color _catColor(String cat) =>
//       _catColors[cat.toLowerCase()] ?? TravelMateColors.teal;

//   @override
//   Widget build(BuildContext context) {
//     final name = activity['name']?.toString() ?? '';
//     final time = activity['time']?.toString() ?? '';
//     final desc = activity['description']?.toString() ?? '';
//     final imageUrl = activity['image_url']?.toString() ?? '';
//     final rating = (activity['rating'] as num?)?.toDouble() ?? 0.0;
//     final cost = (activity['cost'] as num?)?.toInt() ?? 0;
//     final cats = (activity['categories'] as List<dynamic>?)
//             ?.map((e) => e.toString())
//             .toList() ??
//         [];
//     final timeParts = time.split('–');
//     final startTime = timeParts.isNotEmpty ? timeParts[0].trim() : time;

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
//       child: IntrinsicHeight(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Timeline column
//             SizedBox(
//               width: 52,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 14),
//                   Text(
//                     startTime,
//                     style: TextStyle(
//                       color: TravelMateColors.teal,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 6),
//                   Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                           color: TravelMateColors.teal, width: 2),
//                       shape: BoxShape.circle,
//                       color: context.wCard,
//                     ),
//                   ),
//                   if (!isLast)
//                     Expanded(
//                       child: Container(
//                         width: 1.5,
//                         color: context.wDivider,
//                         margin: const EdgeInsets.only(bottom: 0),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 10),
//             // Content card
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.only(top: 10, bottom: 10),
//                 decoration: BoxDecoration(
//                   color: context.wBg,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: context.wBorder),
//                 ),
//                 clipBehavior: Clip.antiAlias,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Image
//                     if (imageUrl.isNotEmpty)
//                       SizedBox(
//                         height: 120,
//                         width: double.infinity,
//                         child: Image.network(
//                           imageUrl,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) =>
//                               _ImagePlaceholder(name: name),
//                         ),
//                       )
//                     else if (cats.isNotEmpty)
//                       Container(
//                         height: 4,
//                         color: _catColor(cats.first),
//                       ),
//                     Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   name,
//                                   style: TextStyle(
//                                     color: context.wText,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 14,
//                                     height: 1.3,
//                                   ),
//                                 ),
//                               ),
//                               if (cost > 0)
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: TravelMateColors.amber
//                                         .withOpacity(0.12),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     '₹$cost',
//                                     style: const TextStyle(
//                                       color: TravelMateColors.amber,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                 )
//                               else
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: TravelMateColors.teal
//                                         .withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     'Free',
//                                     style: TextStyle(
//                                       color: TravelMateColors.teal,
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           if (rating > 0) ...[
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Icon(Icons.star_rounded,
//                                     color: TravelMateColors.amber, size: 13),
//                                 const SizedBox(width: 3),
//                                 Text(
//                                   rating.toStringAsFixed(1),
//                                   style: TextStyle(
//                                     color: context.wTextSub,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                           if (desc.isNotEmpty) ...[
//                             const SizedBox(height: 6),
//                             Text(
//                               desc.length > 110
//                                   ? '${desc.substring(0, 110)}…'
//                                   : desc,
//                               style: TextStyle(
//                                 color: context.wTextSub,
//                                 fontSize: 12,
//                                 height: 1.5,
//                               ),
//                             ),
//                           ],
//                           if (cats.isNotEmpty) ...[
//                             const SizedBox(height: 8),
//                             Wrap(
//                               spacing: 5,
//                               runSpacing: 4,
//                               children: cats.take(3).map((c) {
//                                 final col = _catColor(c);
//                                 return Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: col.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(50),
//                                   ),
//                                   child: Text(
//                                     c,
//                                     style: TextStyle(
//                                       color: col,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // TAB: PLACES
// // ─────────────────────────────────────────────────────────────────────────────
// class _PlacesTab extends StatelessWidget {
//   final List<dynamic> places;
//   final List<dynamic> topRated;
//   const _PlacesTab({required this.places, required this.topRated});

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         // Top rated horizontal strip
//         if (topRated.isNotEmpty) ...[
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
//               child: Row(
//                 children: [
//                   const Icon(Icons.star_rounded,
//                       color: TravelMateColors.amber, size: 18),
//                   const SizedBox(width: 6),
//                   Text(
//                     'Top rated',
//                     style: TextStyle(
//                       color: context.wText,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 230,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 itemCount: topRated.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 12),
//                 itemBuilder: (_, i) => _HeroCard(
//                   place: topRated[i] as Map<String, dynamic>,
//                 ),
//               ),
//             ),
//           ),
//         ],

//         // All places grid
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
//             child: Row(
//               children: [
//                 const Icon(Icons.location_on_rounded,
//                     color: TravelMateColors.teal, size: 16),
//                 const SizedBox(width: 6),
//                 Text(
//                   'All places (${places.length})',
//                   style: TextStyle(
//                     color: context.wText,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SliverPadding(
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
//           sliver: SliverGrid(
//             delegate: SliverChildBuilderDelegate(
//               (_, i) => _PlaceCard(
//                   place: places[i] as Map<String, dynamic>),
//               childCount: places.length,
//             ),
//             gridDelegate:
//                 const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.78,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _HeroCard extends StatelessWidget {
//   final Map<String, dynamic> place;
//   const _HeroCard({required this.place});

//   @override
//   Widget build(BuildContext context) {
//     final name = place['name']?.toString() ?? '';
//     final imageUrl = place['image_url']?.toString() ?? '';
//     final rating = (place['rating'] as num?)?.toDouble() ?? 0.0;
//     final cats = (place['categories'] as List<dynamic>?)
//             ?.map((e) => e.toString())
//             .toList() ??
//         [];

//     return Container(
//       width: 175,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: context.wCard,
//         border: Border.all(color: context.wBorder),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           if (imageUrl.isNotEmpty)
//             Image.network(imageUrl, fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) =>
//                     Container(color: TravelMateColors.teal.withOpacity(0.15)))
//           else
//             Container(
//               decoration: const BoxDecoration(
//                   gradient: TravelMateGradients.brand),
//             ),
//           // Gradient overlay
//           Positioned.fill(
//             child: DecoratedBox(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     Colors.black.withOpacity(0.8),
//                   ],
//                   stops: const [0.4, 1.0],
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             left: 12,
//             right: 12,
//             bottom: 12,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (cats.isNotEmpty)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8, vertical: 3),
//                     margin: const EdgeInsets.only(bottom: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: Text(
//                       cats.first,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 Text(
//                   name,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 14,
//                     height: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Row(
//                   children: [
//                     const Icon(Icons.star_rounded,
//                         color: TravelMateColors.amber, size: 13),
//                     const SizedBox(width: 3),
//                     Text(
//                       rating.toStringAsFixed(1),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PlaceCard extends StatelessWidget {
//   final Map<String, dynamic> place;
//   const _PlaceCard({required this.place});

//   @override
//   Widget build(BuildContext context) {
//     final name = place['name']?.toString() ?? '';
//     final imageUrl = place['image_url']?.toString() ?? '';
//     final rating = (place['rating'] as num?)?.toDouble() ?? 0.0;
//     final priceLevel = (place['price_level'] as num?)?.toInt() ?? 1;
//     final desc = place['description']?.toString() ?? '';
//     final duration = (place['duration_hours'] as num?)?.toInt() ?? 0;

//     return Container(
//       decoration: BoxDecoration(
//         color: context.wCard,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: context.wBorder),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: 100,
//             width: double.infinity,
//             child: imageUrl.isNotEmpty
//                 ? Image.network(imageUrl, fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) =>
//                         _ImagePlaceholder(name: name))
//                 : _ImagePlaceholder(name: name),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: context.wText,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 12,
//                       height: 1.3,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(Icons.star_rounded,
//                           color: TravelMateColors.amber, size: 12),
//                       Text(
//                         ' ${rating.toStringAsFixed(1)}',
//                         style: TextStyle(
//                             color: context.wTextSub, fontSize: 11),
//                       ),
//                       const Spacer(),
//                       Text(
//                         '₹' * priceLevel,
//                         style: const TextStyle(
//                           color: TravelMateColors.teal,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (duration > 0) ...[
//                     const SizedBox(height: 3),
//                     Row(
//                       children: [
//                         Icon(Icons.schedule_rounded,
//                             color: context.wTextSub, size: 11),
//                         const SizedBox(width: 3),
//                         Text(
//                           '$duration hrs',
//                           style: TextStyle(
//                               color: context.wTextSub, fontSize: 10),
//                         ),
//                       ],
//                     ),
//                   ],
//                   if (desc.isNotEmpty) ...[
//                     const SizedBox(height: 4),
//                     Expanded(
//                       child: Text(
//                         desc,
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: context.wTextSub,
//                           fontSize: 10,
//                           height: 1.4,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // TAB: BUDGET
// // ─────────────────────────────────────────────────────────────────────────────
// class _BudgetTab extends StatelessWidget {
//   final Map<String, dynamic> budget;
//   final Map<String, dynamic> journey;
//   const _BudgetTab({required this.budget, required this.journey});

//   @override
//   Widget build(BuildContext context) {
//     final total = (budget['total_budget'] as num?)?.toInt() ?? 0;
//     final transport = (budget['transport_cost'] as num?)?.toInt() ?? 0;
//     final remaining =
//         (budget['remaining_for_activities'] as num?)?.toInt() ?? 0;
//     final daily = (budget['daily_budget'] as num?)?.toDouble() ?? 0;
//     final activities =
//         (budget['actual_activities_cost'] as num?)?.toInt() ?? 0;
//     final buffer = (budget['remaining_buffer'] as num?)?.toDouble() ?? 0;

//     final transportFrac = total > 0 ? transport / total : 0.0;
//     final activitiesFrac = total > 0 ? activities / total : 0.0;
//     final bufferFrac =
//         (1 - transportFrac - activitiesFrac).clamp(0.0, 1.0);

//     // Line items
//     final lines = [
//       _BudgetLine('✈️  Flight (Kolkata ↔ Delhi)', 5400,
//           TravelMateColors.error),
//       _BudgetLine('🚌  Volvo bus (Delhi ↔ Manali)', 1800,
//           const Color(0xFFEF8C38)),
//       _BudgetLine('🏨  Accommodation (6 nights)', 12600,
//           TravelMateColors.teal),
//       _BudgetLine('🎯  Activities & sightseeing', 9800,
//           TravelMateColors.tealDark),
//       _BudgetLine('🍜  Food & local transport', 8400,
//           const Color(0xFF26A69A)),
//       _BudgetLine('🎒  Miscellaneous', 3800, context.wTextSub),
//     ];

//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
//       child: Column(
//         children: [
//           // Hero total card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [
//                   TravelMateColors.gradStart,
//                   TravelMateColors.gradEnd
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Column(
//               children: [
//                 const Text(
//                   'TOTAL BUDGET',
//                   style: TextStyle(
//                     color: Colors.white60,
//                     fontSize: 11,
//                     letterSpacing: 2,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '₹$total',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 46,
//                     fontWeight: FontWeight.w900,
//                     height: 1,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   '₹${daily.toStringAsFixed(0)} avg per day',
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Inline stat row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _HeroStat(
//                         label: 'Transport', value: '₹$transport'),
//                     Container(
//                         width: 1, height: 30, color: Colors.white24),
//                     _HeroStat(
//                         label: 'Activities',
//                         value: '₹$activities'),
//                     Container(
//                         width: 1, height: 30, color: Colors.white24),
//                     _HeroStat(
//                         label: 'Buffer',
//                         value: '₹${buffer.toInt()}'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),

//           // Stacked bar
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: context.wCard,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: context.wBorder),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Breakdown',
//                   style: TextStyle(
//                     color: context.wText,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Segmented bar
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Row(
//                     children: [
//                       Flexible(
//                         flex:
//                             (transportFrac * 100).round().clamp(1, 90),
//                         child: Container(
//                             height: 18,
//                             color: TravelMateColors.error),
//                       ),
//                       const SizedBox(width: 2),
//                       Flexible(
//                         flex:
//                             (activitiesFrac * 100).round().clamp(1, 90),
//                         child: Container(
//                             height: 18,
//                             color: TravelMateColors.amber),
//                       ),
//                       const SizedBox(width: 2),
//                       Flexible(
//                         flex:
//                             (bufferFrac * 100).round().clamp(1, 90),
//                         child: Container(
//                             height: 18,
//                             color: TravelMateColors.teal),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     _BarLegend(
//                         color: TravelMateColors.error,
//                         label: 'Transport'),
//                     const SizedBox(width: 14),
//                     _BarLegend(
//                         color: TravelMateColors.amber,
//                         label: 'Activities'),
//                     const SizedBox(width: 14),
//                     _BarLegend(
//                         color: TravelMateColors.teal,
//                         label: 'Buffer'),
//                   ],
//                 ),
//                 const SizedBox(height: 18),
//                 Divider(color: context.wDivider, height: 1),
//                 const SizedBox(height: 14),
//                 // Line items
//                 ...lines.map((l) => _LineItem(line: l)),
//                 const SizedBox(height: 10),
//                 Divider(color: context.wDivider, height: 1),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Text('Total spent',
//                         style: TextStyle(
//                           color: context.wText,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 15,
//                         )),
//                     const Spacer(),
//                     Text(
//                       '₹$activities',
//                       style: const TextStyle(
//                         color: TravelMateColors.teal,
//                         fontWeight: FontWeight.w800,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),

//           // 2×2 stat cards
//           Row(
//             children: [
//               Expanded(
//                 child: _MiniStat(
//                   icon: Icons.directions_bus_rounded,
//                   label: 'Transport',
//                   value: '₹$transport',
//                   note: 'to destination',
//                   iconColor: TravelMateColors.error,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _MiniStat(
//                   icon: Icons.account_balance_wallet_rounded,
//                   label: 'For activities',
//                   value: '₹$remaining',
//                   note: 'after travel',
//                   iconColor: TravelMateColors.teal,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _MiniStat(
//                   icon: Icons.today_rounded,
//                   label: 'Daily avg',
//                   value: '₹${daily.toStringAsFixed(0)}',
//                   note: 'per day',
//                   iconColor: TravelMateColors.amber,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _MiniStat(
//                   icon: Icons.savings_rounded,
//                   label: 'Buffer saved',
//                   value: '₹${buffer.toInt()}',
//                   note: 'emergency fund',
//                   iconColor: const Color(0xFF26A69A),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BudgetLine {
//   final String label;
//   final int amount;
//   final Color color;
//   const _BudgetLine(this.label, this.amount, this.color);
// }

// class _LineItem extends StatelessWidget {
//   final _BudgetLine line;
//   const _LineItem({required this.line});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 11),
//       child: Row(
//         children: [
//           Container(
//             width: 9,
//             height: 9,
//             decoration: BoxDecoration(
//                 color: line.color, shape: BoxShape.circle),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(line.label,
//                 style:
//                     TextStyle(color: context.wTextSub, fontSize: 13)),
//           ),
//           Text(
//             '₹${line.amount}',
//             style: TextStyle(
//               color: context.wText,
//               fontWeight: FontWeight.w700,
//               fontSize: 13,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BarLegend extends StatelessWidget {
//   final Color color;
//   final String label;
//   const _BarLegend({required this.color, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
//         const SizedBox(width: 4),
//         Text(label,
//             style: TextStyle(color: context.wTextSub, fontSize: 11)),
//       ],
//     );
//   }
// }

// class _HeroStat extends StatelessWidget {
//   final String label, value;
//   const _HeroStat({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(value,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w800,
//                 fontSize: 14)),
//         const SizedBox(height: 2),
//         Text(label,
//             style:
//                 const TextStyle(color: Colors.white60, fontSize: 11)),
//       ],
//     );
//   }
// }

// class _MiniStat extends StatelessWidget {
//   final IconData icon;
//   final String label, value, note;
//   final Color iconColor;
//   const _MiniStat({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.note,
//     required this.iconColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: context.wCard,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: context.wBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: iconColor.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: iconColor, size: 18),
//           ),
//           const SizedBox(height: 10),
//           Text(label,
//               style: TextStyle(color: context.wTextSub, fontSize: 11)),
//           const SizedBox(height: 2),
//           Text(value,
//               style: TextStyle(
//                 color: context.wText,
//                 fontWeight: FontWeight.w800,
//                 fontSize: 18,
//               )),
//           Text(note,
//               style: TextStyle(color: context.wTextSub, fontSize: 11)),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // SHARED HELPERS
// // ─────────────────────────────────────────────────────────────────────────────
// class _ImagePlaceholder extends StatelessWidget {
//   final String name;
//   const _ImagePlaceholder({required this.name});

//   static const List<List<Color>> _palettes = [
//     [Color(0xFF1D9E75), Color(0xFF0F6E56)],
//     [Color(0xFF00B89C), Color(0xFF00897B)],
//     [Color(0xFF0891B2), Color(0xFF0E7490)],
//     [Color(0xFF7C3AED), Color(0xFF6D28D9)],
//     [Color(0xFFD97706), Color(0xFFB45309)],
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final idx = name.isEmpty ? 0 : name.codeUnitAt(0) % _palettes.length;
//     final pal = _palettes[idx];
//     final initials = name.length >= 2
//         ? '${name[0]}${name[1]}'.toUpperCase()
//         : name.isEmpty
//             ? '?'
//             : name[0].toUpperCase();

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: pal,
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Center(
//         child: Text(
//           initials,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.w800,
//             letterSpacing: 2,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // TAB BAR DELEGATE
// // ─────────────────────────────────────────────────────────────────────────────
// class _TabDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;
//   final BuildContext ctx;
//   _TabDelegate(this.tabBar, this.ctx);

//   @override
//   double get minExtent => tabBar.preferredSize.height + 1;
//   @override
//   double get maxExtent => tabBar.preferredSize.height + 1;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: context.wBg,
//       child: Column(
//         children: [
//           tabBar,
//           Divider(color: context.wDivider, height: 1),
//         ],
//       ),
//     );
//   }

//   @override
//   bool shouldRebuild(_TabDelegate old) => false;
// }