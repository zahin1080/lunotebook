import 'package:flutter/material.dart';
import 'app_theme.dart';

class NotesPage extends StatelessWidget {
  final String uid;
  const NotesPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
