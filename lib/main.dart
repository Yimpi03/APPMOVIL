import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "screens/moments_grid_screen.dart";
import "widgets/app_drawer.dart";
import "screens/profile_screen.dart";

void main() => runApp(const MiPrimeraTareaApp());

class MiPrimeraTareaApp extends StatelessWidget {
  const MiPrimeraTareaApp({super.key});

  ThemeData _theme(Brightness b) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorSchemeSeed: const Color(0xFF6E59D9),
    );
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: base.appBarTheme.copyWith(centerTitle: true, elevation: 0),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ELIALEX - Mi Primera Tarea",
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      // INICIO = MomentsGridScreen
      routes: {
        "/": (_) => const MomentsGridScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        MomentsGridScreen.routeName: (_) => const MomentsGridScreen(),
      },
    );
  }
}
