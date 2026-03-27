import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/destination.dart';

class DestinationCard extends StatefulWidget {
  final Destination destination;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.index = 0,
  });

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 80),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateDelete() async {
    setState(() => _isDeleting = true);
    HapticFeedback.mediumImpact();
    await _controller.reverse(from: 1.0);
    widget.onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedOpacity(
            opacity: _isDeleting ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: _buildSwipeable(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeable(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.destination.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return await _showDeleteConfirm(context);
      },
      onDismissed: (_) => widget.onDelete?.call(),
      background: _buildSwipeBackground(),
      child: _buildCard(context),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_rounded, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text('Delete',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEEEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_rounded,
                  color: Color(0xFFFF3B30), size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete destination?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete\n"${widget.destination.title}"?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : const Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(
                        color: isDark
                            ? Colors.white24
                            : const Color(0xFFE0E0E0)),
                  ),
                  child: Text('Cancel',
                      style: TextStyle(
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF666666),
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Delete',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: isDark
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildContent(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        // Main image
        Hero(
          tag: 'destination-image-${widget.destination.id}',
          child: ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              widget.destination.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: const Color(0xFFE8F5E9),
                child: const Center(
                    child: Icon(Icons.image_outlined,
                        size: 48, color: Color(0xFF4CAF50))),
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 200,
                  color: const Color(0xFFF5F5F5),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFF4CAF50),
                      strokeWidth: 2,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Category badge (top left)
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.destination.category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),

        // Visited badge (top left, below category if both shown)
        if (widget.destination.isVisited)
          Positioned(
            top: 46,
            left: 12,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 11, color: Colors.white),
                  SizedBox(width: 3),
                  Text('Visited',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

        // Saved badge (top right corner area, below menu)
        if (widget.destination.isSaved)
          Positioned(
            top: 46,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.bookmark_rounded,
                  size: 12, color: Colors.white),
            ),
          ),

        // Actions menu (top right)
        Positioned(
          top: 8,
          right: 8,
          child: _buildActionsMenu(),
        ),
      ],
    );
  }

  Widget _buildActionsMenu() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2), blurRadius: 6),
          ],
        ),
        child:
        const Icon(Icons.more_vert, color: Colors.white, size: 16),
      ),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 8,
      shadowColor: Colors.black26,
      onSelected: (value) async {
        if (value == 'edit') widget.onEdit?.call();
        if (value == 'delete') {
          final confirm = await _showDeleteConfirm(context);
          if (confirm == true) _animateDelete();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_outlined,
                  size: 16, color: Color(0xFF333333)),
            ),
            const SizedBox(width: 12),
            const Text('Edit',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_outline,
                  size: 16, color: Color(0xFFFF3B30)),
            ),
            const SizedBox(width: 12),
            const Text('Delete',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF3B30))),
          ]),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.location_on_outlined,
                size: 14, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
            const SizedBox(width: 4),
            Text(
              widget.destination.location,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                  letterSpacing: 0.5),
            ),
            const Spacer(),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF4CAF50).withOpacity(0.15)
                    : const Color(0xFFF0FFF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isDark
                        ? const Color(0xFF4CAF50).withOpacity(0.3)
                        : const Color(0xFFB9F5C8)),
              ),
              child: Text(
                widget.destination.tag,
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Hero(
            tag: 'destination-title-${widget.destination.id}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.destination.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.destination.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : const Color(0xFF666666),
                height: 1.6),
          ),
          const SizedBox(height: 12),
          Row(children: [
            GestureDetector(
              onTap: widget.onTap,
              child: Row(children: [
                Text('Read More',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1A1A1A))),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward,
                    size: 14,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF1A1A1A)),
              ]),
            ),
            const Spacer(),
            Row(children: [
              Icon(Icons.swipe_left_outlined,
                  size: 13,
                  color: isDark ? Colors.white24 : Colors.grey.shade400),
              const SizedBox(width: 3),
              Text('Swipe to delete',
                  style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white24
                          : Colors.grey.shade400)),
            ]),
          ]),
        ],
      ),
    );
  }
}