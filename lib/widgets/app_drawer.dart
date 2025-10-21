import "package:flutter/material.dart";
import "../screens/moments_grid_screen.dart";
import "../screens/profile_screen.dart";

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [cs.primary, cs.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: const UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.transparent),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage("https://res.cloudinary.com/ds757fmhk/image/upload/v1748224627/abea88ab-0516-46d0-a01f-d0c5cc17c37b_cx7ttz.jpg"),
                ),
                accountName: Text("Alexis David Obil Colli"),
                accountEmail: Text("esthalexboob06@gmail.com"),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_rounded),
              title: const Text("Inicio (Momentos)"),
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(MomentsGridScreen.routeName, (r) => r.isFirst),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Perfil"),
              onTap: () => Navigator.of(context).pushNamed(ProfileScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
