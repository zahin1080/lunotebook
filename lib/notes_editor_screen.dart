import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notes_service.dart';
import 'app_theme.dart';
import 'notes_screen.dart'; // Contains NoteModel

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  final _noteService = NoteService();
  bool _isSaving = false;
  bool _hasChanges = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _titleCtrl.addListener(_onChanged);
    _contentCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty && _contentCtrl.text.trim().isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        final updated = widget.note!.copyWith(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
        );
        await _noteService.updateNote(updated);
      } else {
        final note = NoteModel.create(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
        );
        await _noteService.createNote(note);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note. Try again.',
                style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Discard changes?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'You have unsaved changes. Save before leaving?',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Discard',
                style: GoogleFonts.poppins(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx, false);
              _save();
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(70, 38)),
            child: Text('Save', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop() && mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back_ios_rounded),
          ),
          title: Text(
            _isEditing ? 'Edit Note' : 'New Note',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            if (_hasChanges || !_isEditing)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.accentColor,
                  ),
                )
                    : TextButton(
                  onPressed: _save,
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              // Title field
              TextField(
                controller: _titleCtrl,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.primaryColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                minLines: 1,
              ),
              Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
              const SizedBox(height: 8),
              // Content field
              Expanded(
                child: TextField(
                  controller: _contentCtrl,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.7,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Start writing your note...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
