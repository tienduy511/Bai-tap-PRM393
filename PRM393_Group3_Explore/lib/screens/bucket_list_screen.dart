import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/destination.dart';
import '../widget/destination_card.dart';
import 'detail_screen.dart';
import 'form_screen.dart';

class BucketListScreen extends StatefulWidget {
  const BucketListScreen({super.key});

  @override
  State<BucketListScreen> createState() => _BucketListScreenState();
}

class _BucketListScreenState extends State<BucketListScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper.instance;
  List<Destination> _saved = [];
  List<Destination> _visited = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final saved = await _db.getSavedDestinations();
    final visited = await _db.getVisitedDestinations();
    setState(() {
      _saved = saved;
      _visited = visited;
      _isLoading = false;
    });
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
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Bucket List'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          indicatorColor: const Color(0xFF4CAF50),
          indicatorWeight: 2,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Saved (${_saved.length})'),
            Tab(text: 'Visited (${_visited.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildList(_saved, 'No saved destinations yet.',
              'Tap the bookmark icon on any destination to save it.'),
          _buildList(_visited, 'No visited destinations yet.',
              'Mark destinations as visited from the detail screen.'),
        ],
      ),
    );
  }

  Widget _buildList(
      List<Destination> items, String emptyTitle, String emptySub) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF4),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFFB9F5C8), width: 2),
                ),
                child: const Icon(Icons.bookmark_outline,
                    size: 34, color: Color(0xFF4CAF50)),
              ),
              const SizedBox(height: 20),
              Text(
                emptyTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                emptySub,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF9E9E9E)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF4CAF50),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: items.length,
        itemBuilder: (_, i) => DestinationCard(
          destination: items[i],
          index: i,
          onTap: () => _goToDetail(items[i]),
          onEdit: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, __) =>
                  FormScreen(destination: items[i]),
              transitionsBuilder: (_, a, __, child) => SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0, 1), end: Offset.zero)
                    .animate(CurvedAnimation(
                    parent: a, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
          ).then((_) => _load()),
          onDelete: () async {
            await _db.deleteDestination(items[i].id!);
            _load();
          },
        ),
      ),
    );
  }
}