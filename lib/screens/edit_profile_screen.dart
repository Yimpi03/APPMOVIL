import "dart:typed_data";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "../data/user_profile.dart";

class EditProfileScreen extends StatefulWidget {
  final UserProfile initial;
  const EditProfileScreen({super.key, required this.initial});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _lugar;
  late final TextEditingController _url;
  late int _edad;
  late String _sexo;
  late DateTime _fecha;
  Uint8List? _avatarBytes;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name  = TextEditingController(text: p.nombre);
    _email = TextEditingController(text: p.correo);
    _lugar = TextEditingController(text: p.lugarNacimiento);
    _url   = TextEditingController(text: p.avatarUrl ?? "");
    _edad  = p.edad;
    _sexo  = p.sexo;
    _fecha = p.fechaNacimiento;
    _avatarBytes = p.avatarBytes;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _lugar.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,   // importante en Web/Windows para obtener bytes
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() {
        _avatarBytes = res.files.single.bytes;
        // si eliges foto local, limpiamos URL para evitar conflictos visuales
        _url.text = "";
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 100, 1, 1);
    final last  = DateTime(now.year, 12, 31);
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final updated = UserProfile(
      nombre: _name.text.trim(),
      correo: _email.text.trim(),
      sexo: _sexo,
      edad: _edad,
      fechaNacimiento: _fecha,
      lugarNacimiento: _lugar.text.trim(),
      avatarBytes: _avatarBytes,
      avatarUrl: _url.text.trim().isEmpty ? null : _url.text.trim(),
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    ImageProvider? avatar() {
      if (_avatarBytes != null) return MemoryImage(_avatarBytes!);
      if (_url.text.trim().isNotEmpty) return NetworkImage(_url.text.trim());
      return null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Editar perfil"), centerTitle: true, elevation: 0),
      body: LayoutBuilder(
        builder: (_, vb) {
          final maxW = vb.maxWidth < 780 ? vb.maxWidth - 24 : 780.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatar + botones
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundImage: avatar(),
                                child: avatar() == null ? const Icon(Icons.person) : null,
                              ),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text("Cargar foto"),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => setState((){ _avatarBytes = null; _url.clear(); }),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text("Quitar"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Campos
                          TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(labelText: "Nombre", prefixIcon: Icon(Icons.badge_outlined)),
                            validator: (v) => (v==null || v.trim().isEmpty) ? "Escribe tu nombre" : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(labelText: "Correo", prefixIcon: Icon(Icons.email_outlined)),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v){
                              if (v==null || v.trim().isEmpty) return "Escribe tu correo";
                              final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                              return ok ? null : "Correo inválido";
                            },
                          ),
                          const SizedBox(height: 10),
                          // Fila compacta: Sexo + Edad
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _sexo,
                                  decoration: const InputDecoration(labelText: "Sexo", prefixIcon: Icon(Icons.wc_outlined)),
                                  items: const [
                                    DropdownMenuItem(value: "H", child: Text("Hombre")),
                                    DropdownMenuItem(value: "M", child: Text("Mujer")),
                                    DropdownMenuItem(value: "Otro", child: Text("Otro")),
                                  ],
                                  onChanged: (v)=> setState(()=> _sexo = v ?? "H"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _edad.toString(),
                                  decoration: const InputDecoration(labelText: "Edad", prefixIcon: Icon(Icons.numbers)),
                                  keyboardType: TextInputType.number,
                                  validator: (v){
                                    final n = int.tryParse(v ?? "");
                                    if (n == null || n<0 || n>120) return "Edad inválida";
                                    return null;
                                  },
                                  onChanged: (v)=> _edad = int.tryParse(v) ?? _edad,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Fecha de nacimiento
                          TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: "${_fecha.day.toString().padLeft(2,"0")}-${_fecha.month.toString().padLeft(2,"0")}-${_fecha.year}",
                            ),
                            decoration: const InputDecoration(
                              labelText: "Fecha de nacimiento",
                              prefixIcon: Icon(Icons.calendar_month_outlined),
                              suffixIcon: Icon(Icons.edit_calendar_outlined),
                            ),
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _lugar,
                            decoration: const InputDecoration(
                              labelText: "Lugar de nacimiento",
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _url,
                            decoration: const InputDecoration(
                              labelText: "URL de foto (opcional)",
                              prefixIcon: Icon(Icons.link_outlined),
                            ),
                            onChanged: (_)=> setState((){}),
                          ),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text("Guardar cambios"),
                            ),
                          )
                        ],
                      ),
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
