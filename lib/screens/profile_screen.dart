import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../data/user_profile.dart";
import "edit_profile_screen.dart";

class ProfileScreen extends StatefulWidget {
  static const routeName = "/perfil";
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile _profile = UserProfile.defaults();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString("user_profile");
    if (raw != null) {
      try {
        _profile = UserProfile.fromJson(jsonDecode(raw));
        setState(() {});
      } catch (_) {}
    }
  }

  Future<void> _save(UserProfile p) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString("user_profile", jsonEncode(p.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    ImageProvider avatar() {
      if (_profile.avatarBytes != null) {
        return MemoryImage(_profile.avatarBytes!);
      }
      if ((_profile.avatarUrl ?? "").isNotEmpty) {
        return NetworkImage(_profile.avatarUrl!);
      }
      return const AssetImage("assets/placeholder.png"); // opcional si tienes un asset
    }

    final chips = <Widget>[
      Chip(
        label: Text("Sexo: ${_profile.sexo}"),
        visualDensity: VisualDensity.compact,
      ),
      Chip(
        label: Text("Edad: ${_profile.edad}"),
        visualDensity: VisualDensity.compact,
      ),
      Chip(
        label: Text(
          "Nac.: ${_profile.fechaNacimiento.day.toString().padLeft(2,"0")}-"
                "${_profile.fechaNacimiento.month.toString().padLeft(2,"0")}-"
                "${_profile.fechaNacimiento.year}",
        ),
        visualDensity: VisualDensity.compact,
      ),
      Chip(
        label: Text(_profile.lugarNacimiento),
        visualDensity: VisualDensity.compact,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (_, vb) {
          final maxW = vb.maxWidth < 820 ? vb.maxWidth - 24 : 820.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 56, backgroundImage: avatar()),
                        const SizedBox(height: 12),
                        Text(
                          _profile.nombre,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profile.correo,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: chips,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text("Editar perfil"),
                            onPressed: () async {
                              final updated = await Navigator.of(context).push<UserProfile>(
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(initial: _profile),
                                ),
                              );
                              if (updated != null) {
                                setState(() => _profile = updated);
                                _save(updated);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Perfil actualizado")),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
