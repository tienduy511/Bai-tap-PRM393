import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/destination.dart';
import '../widget/destination_card.dart';
import '../widget/category_filter.dart';
import '../main.dart';
import 'detail_screen.dart';
import 'form_screen.dart';
import 'bucket_list_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _db = DatabaseHelper.instance;
  List<Destination> _destinations = [];
  String _selectedCategory = 'Overview';
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  late AnimationController _fabController;
  late Animation<double> _fabScaleAnim;
  late AnimationController _headerController;
  late Animation<double> _headerFadeAnim;
  late AnimationController _bannerController;
  late Animation<double> _bannerFadeAnim;

  String _displayedCategory = 'Overview';

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fabScaleAnim =
        CurvedAnimation(parent: _fabController, curve: Curves.elasticOut);
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _headerFadeAnim =
        CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _bannerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _bannerFadeAnim =
        CurvedAnimation(parent: _bannerController, curve: Curves.easeOut);
    _bannerController.value = 1.0;
    _loadDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    _headerController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _loadDestinations() async {
    setState(() => _isLoading = true);
    try {
      final data = _searchQuery.isNotEmpty
          ? await _db.searchDestinations(_searchQuery)
          : _selectedCategory == 'Overview'
          ? await _db.getAllDestinations()
          : await _db.getByCategory(_selectedCategory);
      setState(() {
        _destinations = data;
        _isLoading = false;
      });
      _headerController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _fabController.forward(from: 0);
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _changeCategory(String cat) {
    if (cat == _selectedCategory) return;
    _bannerController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _displayedCategory = cat;
        _selectedCategory = cat;
        _searchQuery = '';
        _searchController.clear();
        _isSearching = false;
      });
      _bannerController.forward();
      _loadDestinations();
    });
  }

  Future<void> _deleteDestination(Destination dest) async {
    await _db.deleteDestination(dest.id!);
    HapticFeedback.lightImpact();
    await _loadDestinations();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text('"${dest.title}" has been removed')),
      ]),
      backgroundColor: const Color(0xFF1A1A1A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: SnackBarAction(
        label: 'Close',
        textColor: const Color(0xFF4CAF50),
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    ));
  }

  void _goToDetail(Destination dest) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => DetailScreen(destination: dest),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) => _loadDestinations());
  }

  void _goToForm({Destination? destination}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => FormScreen(destination: destination),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
              CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 380),
      ),
    ).then((_) => _loadDestinations());
  }

  Map<String, String> get _currentHero =>
      kCategoryHero[_displayedCategory] ?? kCategoryHero['Overview']!;
  bool get _isOverview => _selectedCategory == 'Overview';

  @override
  Widget build(BuildContext context) {
    final appState = CultureTripApp.of(context);
    final isDark = appState?.isDark ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(isDark, appState),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildAppBar(isDark)],
        body: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSearching
                  ? _buildSearchBar(isDark)
                  : const SizedBox(height: 12),
            ),
            const SizedBox(height: 4),
            CategoryFilter(
              selected: _selectedCategory,
              onChanged: _changeCategory,
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(isDark)),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnim,
        child: FloatingActionButton.extended(
          onPressed: () => _goToForm(),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 6,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Destination',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildDrawer(bool isDark, CultureTripAppState? appState) {
    return Drawer(
      backgroundColor:
      isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF1A1A1A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.explore_outlined,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text('Culture Trip',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const Text('The 100 — 2026',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 8),

            _drawerItem(
              icon: Icons.home_outlined,
              label: 'Home',
              onTap: () => Navigator.pop(context),
              isDark: isDark,
            ),
            _drawerItem(
              icon: Icons.bookmark_outline,
              label: 'Bucket List',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const BucketListScreen()))
                    .then((_) => _loadDestinations());
              },
              isDark: isDark,
            ),
            _drawerItem(
              icon: Icons.bar_chart_rounded,
              label: 'Progress & Stats',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const StatsScreen()));
              },
              isDark: isDark,
            ),

            const Spacer(),

            // Dark mode toggle
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDark
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: isDark ? Colors.white70 : const Color(0xFF666666),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Dark mode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF333333),
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: isDark,
                      onChanged: (val) =>
                          appState?.toggleDarkMode(val),
                      activeColor: const Color(0xFF4CAF50),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: isDark ? Colors.white70 : const Color(0xFF333333)),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  SliverAppBar _buildAppBar(bool isDark) {
    final hero = _currentHero;
    final isOverview = _displayedCategory == 'Overview';

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A1A),
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _bannerFadeAnim,
          child: Stack(fit: StackFit.expand, children: [
            Image.network(hero['imageUrl']!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1A1A1A))),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _headerFadeAnim,
              child: Positioned(
                bottom: 20, left: 20, right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isOverview ? 'THE 100' : _displayedCategory.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w700, letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isOverview) ...[
                      const Text("Culture Trip's\nbest of the best",
                          style: TextStyle(
                              color: Colors.white, fontSize: 26,
                              fontWeight: FontWeight.w800, height: 1.2)),
                      Row(children: [
                        const Text('for 2026',
                            style: TextStyle(
                                color: Color(0xFF4CAF50), fontSize: 26,
                                fontWeight: FontWeight.w800)),
                        const Spacer(),
                        if (!_isLoading) _buildCountBadge(),
                      ]),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Text(hero['tagline']!,
                            style: const TextStyle(
                                color: Color(0xFF1A1A1A), fontSize: 22,
                                fontWeight: FontWeight.w800, height: 1.15)),
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: Text(hero['subtitle']!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14,
                                  fontWeight: FontWeight.w500, height: 1.4)),
                        ),
                        const SizedBox(width: 8),
                        if (!_isLoading) _buildCountBadge(),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isSearching ? Icons.search_off_rounded : Icons.search_rounded,
              color: Colors.white,
              key: ValueKey(_isSearching),
            ),
          ),
          onPressed: () => setState(() => _isSearching = !_isSearching),
        ),
      ],
    );
  }

  Widget _buildCountBadge() => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white24),
    ),
    child: Text('${_destinations.length} destinations',
        style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500)),
  );

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
        onChanged: (val) {
          setState(() => _searchQuery = val);
          _loadDestinations();
        },
        decoration: InputDecoration(
          hintText: 'Search destinations...',
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF9E9E9E), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear_rounded, size: 18),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
              _loadDestinations();
            },
          )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFE0E0E0))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFF4CAF50), width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: Color(0xFF4CAF50), strokeWidth: 3),
          SizedBox(height: 16),
          Text('Loading...',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
        ]),
      );
    }
    if (_isOverview && _searchQuery.isEmpty) {
      return _buildOverviewGrid();
    }
    if (_destinations.isEmpty) return _buildEmptyState();
    return RefreshIndicator(
      color: const Color(0xFF4CAF50),
      backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      strokeWidth: 2.5,
      onRefresh: _loadDestinations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _destinations.length,
        itemBuilder: (_, i) => DestinationCard(
          destination: _destinations[i],
          index: i,
          onTap: () => _goToDetail(_destinations[i]),
          onEdit: () => _goToForm(destination: _destinations[i]),
          onDelete: () => _deleteDestination(_destinations[i]),
        ),
      ),
    );
  }

  Widget _buildOverviewGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: kCategories.length,
      itemBuilder: (_, i) {
        final cat = kCategories[i];
        final hero = kCategoryHero[cat];
        if (hero == null) return const SizedBox.shrink();
        return _buildCategoryCard(
          category: cat,
          imageUrl: hero['imageUrl']!,
          subtitle: hero['subtitle']!,
          index: i,
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required String category,
    required String imageUrl,
    required String subtitle,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 65),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.scale(
        scale: 0.88 + 0.12 * v,
        child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _changeCategory(category);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(fit: StackFit.expand, children: [
            Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF2A2A2A)),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFFE8E8E8),
                    child: const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF4CAF50), strokeWidth: 2)),
                  );
                }),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.3, 1.0],
                  colors: [Colors.transparent, Color(0xEE000000)],
                ),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 15,
                          fontWeight: FontWeight.w800, height: 1.2,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                        )),
                    const SizedBox(height: 5),
                    Text(subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11, height: 1.4)),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.25),
                                blurRadius: 6, offset: const Offset(0, 2))
                          ],
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            size: 15, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.scale(
        scale: 0.8 + 0.2 * v,
        child: Opacity(opacity: v.clamp(0, 1), child: child),
      ),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FFF4), shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFB9F5C8), width: 2),
            ),
            child: const Icon(Icons.explore_outlined,
                size: 40, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 20),
          const Text('No destinations yet',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: Color(0xFF333333))),
          const SizedBox(height: 8),
          const Text('Add your first destination!',
              style: TextStyle(fontSize: 13, color: Color(0xFFBBBBBB))),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: const Color(0xFF4CAF50).withOpacity(0.4),
            ),
            onPressed: () => _goToForm(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Destination',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }
}