import 'dart:convert';
import 'dart:typed_data';

class UserProfile {
  String nombre;
  String correo;
  String sexo;            // "H", "M", "Otro"
  int edad;
  DateTime fechaNacimiento;
  String lugarNacimiento;
  Uint8List? avatarBytes; // foto guardada localmente (opcional)
  String? avatarUrl;      // por si quieres seguir usando una URL

  UserProfile({
    required this.nombre,
    required this.correo,
    required this.sexo,
    required this.edad,
    required this.fechaNacimiento,
    required this.lugarNacimiento,
    this.avatarBytes,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'correo': correo,
        'sexo': sexo,
        'edad': edad,
        'fechaNacimiento': fechaNacimiento.toIso8601String(),
        'lugarNacimiento': lugarNacimiento,
        'avatarBytes': avatarBytes != null ? base64Encode(avatarBytes!) : null,
        'avatarUrl': avatarUrl,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        nombre: j['nombre'] ?? '',
        correo: j['correo'] ?? '',
        sexo: j['sexo'] ?? 'H',
        edad: (j['edad'] is int) ? (j['edad'] as int) : int.tryParse('${j['edad']}') ?? 0,
        fechaNacimiento: DateTime.tryParse(j['fechaNacimiento'] ?? '') ?? DateTime(2003, 8, 21),
        lugarNacimiento: j['lugarNacimiento'] ?? '',
        avatarBytes: j['avatarBytes'] != null ? base64Decode(j['avatarBytes']) : null,
        avatarUrl: j['avatarUrl'] as String?,
      );

  static UserProfile defaults() => UserProfile(
        nombre: 'Alexis David Obil Colli',
        correo: 'esthalexboob06@gmail.com',
        sexo: 'H',
        edad: 21,
        fechaNacimiento: DateTime(2003, 8, 21),
        lugarNacimiento: 'Tuxtla Gutiérrez, Veracruz',
        avatarUrl: 'https://res.cloudinary.com/ds757fmhk/image/upload/v1748224627/abea88ab-0516-46d0-a01f-d0c5cc17c37b_cx7ttz.jpg',
      );
}
