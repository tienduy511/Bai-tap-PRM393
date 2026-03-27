import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../models/destination.dart';
import 'form_screen.dart';

class DetailScreen extends StatefulWidget {
  final Destination destination;

  const DetailScreen({super.key, required this.destination});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Destination _dest;
  final _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _dest = widget.destination;
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _toggleVisited() async {
    HapticFeedback.lightImpact();
    final newVal = !_dest.isVisited;
    await _db.toggleVisited(_dest.id!, newVal);
    setState(() => _dest = _dest.copyWith(isVisited: newVal));
  }

  Future<void> _toggleSaved() async {
    HapticFeedback.lightImpact();
    final newVal = !_dest.isSaved;
    await _db.toggleSaved(_dest.id!, newVal);
    setState(() => _dest = _dest.copyWith(isSaved: newVal));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            newVal ? 'Added to bucket list' : 'Removed from bucket list'),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _share() {
    Share.share(
      '${_dest.title}, ${_dest.location}\n\n${_dest.description}\n\n— Culture Trip The 100',
      subject: _dest.title,
    );
  }

  List<String> get _paragraphs {
    if (_dest.content.isEmpty) return [];
    return _dest.content
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  List<Map<String, String>> get _mediaBlocks {
    try {
      final raw = _dest.mediaBlocks;
      if (raw.isEmpty || raw == '[]') return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => {
        'url': (item['url'] as String?) ?? '',
        'caption': (item['caption'] as String?) ?? '',
      })
          .where((m) => m['url']!.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDark),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: _buildBody(context, isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A1A),
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 20),
        ),
      ),
      actions: [
        // Save to bucket list
        GestureDetector(
          onTap: _toggleSaved,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _dest.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline,
              color: _dest.isSaved
                  ? const Color(0xFFFFB300)
                  : Colors.white,
              size: 18,
            ),
          ),
        ),
        // Share
        GestureDetector(
          onTap: _share,
          child: Container(
            margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_outlined,
                color: Colors.white, size: 18),
          ),
        ),
        // Edit
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, anim, __) =>
                  FormScreen(destination: _dest),
              transitionsBuilder: (_, anim, __, child) => SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0, 1), end: Offset.zero)
                    .animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 380),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Edit',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'destination-image-${_dest.id}',
              child: Image.network(
                _dest.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: const Center(
                      child: Icon(Icons.image_outlined,
                          size: 80, color: Colors.white24)),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.78)
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _dest.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white, fontSize: 10,
                              fontWeight: FontWeight.w700, letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_dest.isVisited)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'VISITED',
                              style: TextStyle(
                                color: Colors.white, fontSize: 10,
                                fontWeight: FontWeight.w700, letterSpacing: 1.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Hero(
                      tag: 'destination-title-${_dest.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          '${_dest.category} — ${_dest.title}, ${_dest.location}',
                          style: const TextStyle(
                            color: Colors.white, fontSize: 22,
                            fontWeight: FontWeight.w800, height: 1.25,
                          ),
                        ),
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

  Widget _buildBody(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Text(
            '© ${_dest.location} / Unsplash',
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF999999),
                fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: 20),

        // Action buttons row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isDark
                            ? Colors.white12
                            : const Color(0xFFE0E0E0)),
                  ),
                  child: Icon(Icons.home_outlined,
                      size: 20,
                      color:
                      isDark ? Colors.white70 : const Color(0xFF333333)),
                ),
              ),
              const Spacer(),
              // Mark visited toggle
              _ActionChip(
                label: _dest.isVisited ? 'Visited' : 'Mark visited',
                icon: _dest.isVisited
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline,
                active: _dest.isVisited,
                activeColor: const Color(0xFF2196F3),
                onTap: _toggleVisited,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              // Save toggle
              _ActionChip(
                label: _dest.isSaved ? 'Saved' : 'Save',
                icon: _dest.isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline,
                active: _dest.isSaved,
                activeColor: const Color(0xFFFFB300),
                onTap: _toggleSaved,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _buildArticleContent(isDark),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildArticleContent(bool isDark) {
    final paragraphs = _paragraphs;
    final mediaBlocks = _mediaBlocks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParagraph(_dest.description, isLead: true, isDark: isDark),
        for (int i = 0; i < paragraphs.length; i++) ...[
          _buildParagraph(paragraphs[i], isDark: isDark),
          if (i < mediaBlocks.length)
            _buildMediaBlock(mediaBlocks[i]),
        ],
        if (mediaBlocks.length > paragraphs.length)
          for (int j = paragraphs.length; j < mediaBlocks.length; j++)
            _buildMediaBlock(mediaBlocks[j]),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildMetaCard(isDark),
        ),
      ],
    );
  }

  Widget _buildParagraph(String text,
      {bool isLead = false, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isLead ? 17 : 16,
          color: isDark ? Colors.white70 : const Color(0xFF2D3748),
          height: 1.85,
          letterSpacing: 0.1,
          fontWeight: isLead ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildMediaBlock(Map<String, String> block) {
    final url = block['url']!;
    final caption = block['caption'] ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              url,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                    child: Icon(Icons.image_outlined,
                        size: 40, color: Color(0xFF4CAF50))),
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF4CAF50), strokeWidth: 2)),
                );
              },
            ),
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              caption,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  fontStyle: FontStyle.italic,
                  height: 1.5),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '© ${_dest.location} / Unsplash',
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFAAAAAA),
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F8F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          _metaRow(Icons.category_outlined, 'Category',
              _dest.category, isDark),
          Divider(
              height: 20,
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFFE0E0E0)),
          _metaRow(Icons.label_outline, 'Tag', _dest.tag, isDark),
          Divider(
              height: 20,
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFFE0E0E0)),
          _metaRow(
            Icons.calendar_today_outlined,
            'Date Added',
            '${_dest.createdAt.day}/${_dest.createdAt.month}/${_dest.createdAt.year}',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _metaRow(
      IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF9E9E9E))),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? activeColor.withOpacity(0.12)
              : isDark
              ? Colors.white.withOpacity(0.07)
              : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? activeColor.withOpacity(0.4)
                : isDark
                ? Colors.white12
                : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: active
                    ? activeColor
                    : isDark
                    ? Colors.white54
                    : const Color(0xFF666666)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active
                    ? activeColor
                    : isDark
                    ? Colors.white54
                    : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}