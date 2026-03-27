import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../models/destination.dart';

class FormScreen extends StatefulWidget {
  final Destination? destination;
  const FormScreen({super.key, this.destination});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper.instance;
  final _picker = ImagePicker();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _contentCtrl;

  String _selectedCategory = kCategories.first;
  String _selectedTag = kTags.first;
  bool _isSaving = false;
  bool _isGeneratingDesc = false;
  bool _isGeneratingArticle = false;

  // Ảnh bìa: có thể là URL hoặc file local
  File? _coverImageFile;

  final List<_MediaBlockEntry> _mediaEntries = [];

  bool get _isEditing => widget.destination != null;

  @override
  void initState() {
    super.initState();
    final d = widget.destination;
    _titleCtrl = TextEditingController(text: d?.title ?? '');
    _locationCtrl = TextEditingController(text: d?.location ?? '');
    _descCtrl = TextEditingController(text: d?.description ?? '');
    _imageCtrl = TextEditingController(text: d?.imageUrl ?? '');
    _contentCtrl = TextEditingController(text: d?.content ?? '');
    _selectedCategory = d?.category ?? kCategories.first;
    _selectedTag = d?.tag ?? kTags.first;
    _parseMediaBlocks(d?.mediaBlocks ?? '[]');
  }

  void _parseMediaBlocks(String json) {
    try {
      final list = jsonDecode(json) as List<dynamic>;
      for (final item in list) {
        _mediaEntries.add(_MediaBlockEntry(
          urlController:
          TextEditingController(text: (item['url'] as String?) ?? ''),
          captionController:
          TextEditingController(text: (item['caption'] as String?) ?? ''),
        ));
      }
    } catch (_) {}
    if (_mediaEntries.isEmpty) {
      _mediaEntries.add(_MediaBlockEntry(
        urlController: TextEditingController(),
        captionController: TextEditingController(),
      ));
    }
  }

  String _buildMediaBlocksJson() {
    final blocks = _mediaEntries
        .where((e) => e.urlController.text.trim().isNotEmpty || e.localFile != null)
        .map((e) => {
      'url': e.localFile != null
          ? e.localFile!.path
          : e.urlController.text.trim(),
      'caption': e.captionController.text.trim(),
    })
        .toList();
    return jsonEncode(blocks);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    _contentCtrl.dispose();
    for (final e in _mediaEntries) {
      e.urlController.dispose();
      e.captionController.dispose();
    }
    super.dispose();
  }

  // ─── Chọn ảnh bìa từ máy ──────────────────────────────────────────────────
  Future<void> _pickCoverImage() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _coverImageFile = File(picked.path);
        _imageCtrl.text = picked.path; // lưu đường dẫn local vào field
      });
    }
  }

  // ─── Chọn ảnh cho media block từ máy ─────────────────────────────────────
  Future<void> _pickMediaBlockImage(int index) async {
    final source = await _showImageSourceSheet();
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _mediaEntries[index].localFile = File(picked.path);
        _mediaEntries[index].urlController.text = picked.path;
      });
    }
  }

  // ─── Bottom sheet chọn nguồn ảnh ─────────────────────────────────────────
  Future<ImageSource?> _showImageSourceSheet() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Chọn nguồn ảnh',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_outlined,
                    color: Color(0xFF4CAF50)),
              ),
              title: const Text('Thư viện ảnh',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Chọn từ bộ sưu tập'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    color: Color(0xFF2196F3)),
              ),
              title: const Text('Camera',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Chụp ảnh mới'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _generateDescription() async {
    if (_titleCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter title and location first.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
  }

  Future<void> _generateArticle() async {
    if (_titleCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter title and location first.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final emptyBlock = _mediaEntries.indexWhere(
          (e) =>
      (e.urlController.text.trim().isEmpty && e.localFile == null) ||
          e.captionController.text.trim().isEmpty,
    );
    if (emptyBlock != -1) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text('Block ${emptyBlock + 1}: image and caption are required.'),
        ]),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final mediaJson = _buildMediaBlocksJson();
      final imageUrl = _coverImageFile != null
          ? _coverImageFile!.path
          : _imageCtrl.text.trim();

      if (_isEditing) {
        await _db.updateDestination(widget.destination!.copyWith(
          title: _titleCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          category: _selectedCategory,
          description: _descCtrl.text.trim(),
          imageUrl: imageUrl,
          tag: _selectedTag,
          content: _contentCtrl.text.trim(),
          mediaBlocks: mediaJson,
        ));
      } else {
        await _db.insertDestination(Destination(
          title: _titleCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          category: _selectedCategory,
          description: _descCtrl.text.trim(),
          imageUrl: imageUrl,
          tag: _selectedTag,
          content: _contentCtrl.text.trim(),
          mediaBlocks: mediaJson,
        ));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(_isEditing ? 'Destination updated!' : 'Added to The 100!'),
          ]),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Destination' : 'Add to The 100',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isSaving
                  ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : Text(_isEditing ? 'Update' : 'Save',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCoverImagePreview(isDark),

            _buildSection('Basic Info', isDark, [
              _buildField(
                  controller: _titleCtrl,
                  label: 'Destination Name',
                  hint: "e.g. Xi'an, Bali, Petra...",
                  icon: Icons.place_outlined,
                  validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Please enter a name' : null,
                  isDark: isDark),
              const SizedBox(height: 12),
              _buildField(
                  controller: _locationCtrl,
                  label: 'Country / Region',
                  hint: 'e.g. China, Indonesia',
                  icon: Icons.flag_outlined,
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Please enter a location'
                      : null,
                  isDark: isDark),
            ]),
            const SizedBox(height: 16),

            _buildSection('Classification', isDark, [
              _buildDropdown(
                  label: 'Category',
                  icon: Icons.category_outlined,
                  value: _selectedCategory,
                  items: kCategories,
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                  isDark: isDark),
              const SizedBox(height: 12),
              _buildDropdown(
                  label: 'Tag',
                  icon: Icons.label_outline,
                  value: _selectedTag,
                  items: kTags,
                  onChanged: (v) => setState(() => _selectedTag = v!),
                  isDark: isDark),
            ]),
            const SizedBox(height: 16),

            // ─── Cover Image section ─────────────────────────────────────
            _buildSection('Cover Image', isDark, [
              // Nút chọn ảnh từ máy
              _buildPickImageButton(
                label: 'Open Album',
                icon: Icons.photo_library_outlined,
                onTap: _pickCoverImage,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              // Divider "hoặc nhập URL"
              Row(children: [
                Expanded(
                    child: Divider(
                        color: isDark
                            ? Colors.white12
                            : const Color(0xFFE0E0E0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('hoặc nhập URL',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                          isDark ? Colors.white38 : const Color(0xFF9E9E9E))),
                ),
                Expanded(
                    child: Divider(
                        color: isDark
                            ? Colors.white12
                            : const Color(0xFFE0E0E0))),
              ]),
              const SizedBox(height: 10),
              _buildField(
                  controller: _imageCtrl,
                  label: 'Cover Image URL',
                  hint: 'https://images.unsplash.com/...',
                  icon: Icons.link_outlined,
                  validator: (v) {
                    // Hợp lệ nếu có file local hoặc URL hợp lệ
                    if (_coverImageFile != null) return null;
                    if (v?.trim().isEmpty ?? true)
                      return 'Vui lòng chọn ảnh hoặc nhập URL';
                    if (!(Uri.tryParse(v!.trim())?.isAbsolute ?? false))
                      return 'URL không hợp lệ';
                    return null;
                  },
                  onChanged: (_) => setState(() {
                    _coverImageFile = null; // reset file nếu user nhập URL
                  }),
                  isDark: isDark),
            ]),
            const SizedBox(height: 16),

            _buildSection('Short Description', isDark, [
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                validator: (v) =>
                (v?.trim().isEmpty ?? true) ? 'Please enter a description' : null,
                style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                decoration: _textAreaDecoration(
                    'A short summary about this destination...', isDark),
              ),
            ]),
            const SizedBox(height: 16),

            _buildSection('Full Article Content', isDark, [
              _buildHint(
                  'Separate paragraphs with a blank line (press Enter twice).',
                  isDark: isDark),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 12,
                validator: (v) => (v?.trim().isEmpty ?? true)
                    ? 'Please enter article content'
                    : null,
                style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                decoration: _textAreaDecoration(
                    'Write the full article content here...\n\nSeparate each paragraph with a blank line.',
                    isDark),
              ),
            ]),
            const SizedBox(height: 16),

            _buildMediaBlocksSection(isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Nút chọn ảnh từ máy ──────────────────────────────────────────────────
  Widget _buildPickImageButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Color(0xFF4CAF50)),
          foregroundColor: const Color(0xFF4CAF50),
          backgroundColor: const Color(0xFF4CAF50).withOpacity(0.05),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildAiButton({
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50), strokeWidth: 2),
              )
            else
              const Icon(Icons.auto_awesome_outlined,
                  size: 15, color: Color(0xFF4CAF50)),
            const SizedBox(width: 7),
            Text(
              isLoading ? 'Generating...' : label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaBlocksSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PHOTOS + CAPTIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                letterSpacing: 0.8,
              )),
          const SizedBox(height: 4),
          Text(
            'Each block contains one photo and a caption.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _mediaEntries.length; i++) ...[
            _buildMediaEntry(i, isDark),
            if (i < _mediaEntries.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFFEEEEEE)),
              ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _mediaEntries.add(_MediaBlockEntry(
                urlController: TextEditingController(),
                captionController: TextEditingController(),
              ))),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFF4CAF50)),
                foregroundColor: const Color(0xFF4CAF50),
              ),
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text('Add Photo + Caption Block',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaEntry(int index, bool isDark) {
    final entry = _mediaEntries[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Block ${index + 1}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32))),
          ),
          const Spacer(),
          if (_mediaEntries.length > 1)
            GestureDetector(
              onTap: () => setState(() {
                entry.urlController.dispose();
                entry.captionController.dispose();
                _mediaEntries.removeAt(index);
              }),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline,
                    size: 16, color: Color(0xFFFF3B30)),
              ),
            ),
        ]),
        const SizedBox(height: 12),

        // ─── Nút chọn ảnh từ máy cho block ─────────────────────────────
        _buildPickImageButton(
          label: 'Open Album',
          icon: Icons.photo_library_outlined,
          onTap: () => _pickMediaBlockImage(index),
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: Divider(
                  color:
                  isDark ? Colors.white12 : const Color(0xFFE0E0E0))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('Or Enter URL',
                style: TextStyle(
                    fontSize: 11,
                    color:
                    isDark ? Colors.white38 : const Color(0xFF9E9E9E))),
          ),
          Expanded(
              child: Divider(
                  color:
                  isDark ? Colors.white12 : const Color(0xFFE0E0E0))),
        ]),
        const SizedBox(height: 8),

        TextFormField(
          controller: entry.urlController,
          onChanged: (_) => setState(() {
            entry.localFile = null; // reset file nếu user nhập URL
          }),
          style:
          TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          validator: (v) {
            if (entry.localFile != null) return null;
            if (v == null || v.trim().isEmpty) return 'Image is required';
            if (!(Uri.tryParse(v.trim())?.isAbsolute ?? false))
              return 'Please enter a valid URL';
            return null;
          },
          decoration: _fieldDecoration('Image URL',
              'https://images.unsplash.com/...', Icons.link_outlined, isDark),
        ),

        // ─── Preview ảnh (local hoặc URL) ───────────────────────────────
        if (entry.localFile != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(entry.localFile!,
                height: 160, width: double.infinity, fit: BoxFit.cover),
          ),
        ] else if (entry.urlController.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
                entry.urlController.text,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  color: const Color(0xFFF5F5F5),
                  child: const Center(
                      child: Text('Invalid URL',
                          style:
                          TextStyle(color: Color(0xFF9E9E9E)))),
                )),
          ),
        ],
        const SizedBox(height: 10),
        TextFormField(
          controller: entry.captionController,
          maxLines: 2,
          style:
          TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Caption is required' : null,
          decoration: _fieldDecoration('Caption',
              'A short description of this photo...', Icons.short_text, isDark),
        ),
      ],
    );
  }

  Widget _buildCoverImagePreview(bool isDark) {
    if (_coverImageFile == null && _imageCtrl.text.isEmpty)
      return const SizedBox.shrink();
    return Container(
      height: 160,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFFE0E0E0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _coverImageFile != null
          ? Image.file(_coverImageFile!, fit: BoxFit.cover)
          : Image.network(_imageCtrl.text,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFF5F5F5),
            child: const Center(
                child: Text('Invalid cover image URL',
                    style: TextStyle(color: Color(0xFF9E9E9E)))),
          )),
    );
  }

  Widget _buildHint(String text, {required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline, size: 15, color: Color(0xFF4CAF50)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF2E7D32), height: 1.5)),
        ),
      ]),
    );
  }

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFFE8E8E8)),
      ),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
              letterSpacing: 0.8,
            )),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  InputDecoration _fieldDecoration(
      String label, String hint, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9E9E9E)),
      hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
      labelStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
      filled: true,
      fillColor:
      isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : const Color(0xFFE0E0E0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      style:
      TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
      decoration: _fieldDecoration(label, hint, icon, isDark),
    );
  }

  InputDecoration _textAreaDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
      filled: true,
      fillColor:
      isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : const Color(0xFFE0E0E0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      isExpanded: true,
      style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
      dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      decoration: _fieldDecoration(label, '', icon, isDark),
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(item, overflow: TextOverflow.ellipsis),
      ))
          .toList(),
    );
  }
}

class _MediaBlockEntry {
  final TextEditingController urlController;
  final TextEditingController captionController;
  File? localFile; // ảnh chọn từ máy

  _MediaBlockEntry({
    required this.urlController,
    required this.captionController,
    this.localFile,
  });
}