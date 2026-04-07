import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'forget_password_page.dart';
import 'notes_home_screen.dart';
import 'notes_editor_screen.dart';
import 'notes_screen.dart'; // Contains NoteModel

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String noteEditor = '/note-editor';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _slide(const LoginPage());
      case register:
        return _slide(const RegisterPage());
      case forgotPassword:
        return _slide(ForgotPasswordPage());
      case home:
        return _fade(const NotesHomeScreen());
      case noteEditor:
        final note = settings.arguments is NoteModel ? settings.arguments as NoteModel : null;
        return _slide(NoteEditorScreen(note: note));
      case splash:
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
    }
  }

  static PageRoute _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 400),
  );

  static PageRoute _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 350),
  );
}
