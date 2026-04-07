import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notes_screen.dart'; // Contains NoteModel

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _notesCollection =>
      _firestore.collection('users').doc(_uid).collection('notes');

  // Stream all notes for current user (real-time)
  Stream<List<NoteModel>> notesStream() {
    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => NoteModel.fromFirestore(doc))
        .toList());
  }

  // Create a new note
  Future<void> createNote(NoteModel note) async {
    await _notesCollection.doc(note.id).set(note.toMap());
  }

  // Update existing note
  Future<void> updateNote(NoteModel note) async {
    await _notesCollection.doc(note.id).update(note.toMap());
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    await _notesCollection.doc(noteId).delete();
  }

  // Search notes by title/content
  Future<List<NoteModel>> searchNotes(String query) async {
    final snapshot = await _notesCollection.get();
    final all = snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
    final lq = query.toLowerCase();
    return all
        .where((n) =>
    n.title.toLowerCase().contains(lq) ||
        n.content.toLowerCase().contains(lq))
        .toList();
  }
}
