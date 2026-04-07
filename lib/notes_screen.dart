import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.color = '#FFFFFF',
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.create({
    required String title,
    required String content,
    String color = '#FFFFFF',
  }) {
    final now = DateTime.now();
    return NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      color: color,
      createdAt: now,
      updatedAt: now,
    );
  }

  NoteModel copyWith({
    String? title,
    String? content,
    String? color,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: data['id'] ?? doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      color: data['color'] ?? '#FFFFFF',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  String get preview {
    if (content.isEmpty) return 'No additional text';
    return content.length > 100 ? '${content.substring(0, 100)}...' : content;
  }
}