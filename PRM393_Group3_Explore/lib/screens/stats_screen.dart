import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/destination.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper.instance;
  Map<String, int> _stats = {};
  int _totalDestinations = 0;
  int _totalVisited = 0;
  int _totalSaved = 0;
  bool _isLoading = true;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadStats();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final stats = await _db.getCategoryStats();
    final all = await _db.getAllDestinations();
    final saved = await _db.getSavedDestinations();
    setState(() {
      _stats = stats;
      _totalDestinations = all.length;
      _totalVisited = all.where((d) => d.isVisited).length;
      _totalSaved = saved.length;
      _isLoading = false;
    });
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Progress & Stats'),
        backgroundColor:
        isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : RefreshIndicator(
        color: const Color(0xFF4CAF50),
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSummaryRow(isDark),
            const SizedBox(height: 28),
            _buildSectionTitle('Progress by category'),
            const SizedBox(height: 16),
            ...kCategories.map((cat) => _buildCategoryBar(cat, isDark)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(bool isDark) {
    return Row(
      children: [
        _buildSummaryCard(
          label: 'Total',
          value: _totalDestinations,
          color: const Color(0xFF4CAF50),
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          label: 'Visited',
          value: _totalVisited,
          color: const Color(0xFF2196F3),
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          label: 'Saved',
          value: _totalSaved,
          color: const Color(0xFFFF9800),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required int value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFFEEEEEE),
          ),
        ),
        child: Column(
          children: [
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Text(
                '$v',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : const Color(0xFF9E9E9E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9E9E9E),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildCategoryBar(String category, bool isDark) {
    final total = _stats['${category}_total'] ?? 0;
    final visited = _stats['${category}_visited'] ?? 0;
    final progress = total > 0 ? visited / total : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Text(
                '$visited / $total',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (_, __) {
                final animated = Curves.easeOutCubic
                    .transform(_animController.value) * progress;
                return LinearProgressIndicator(
                  value: animated,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFF0F0F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF2196F3),
                  ),
                );
              },
            ),
          ),
          if (visited > 0 && visited == total) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Complete!',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}