import 'dart:convert';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/moment_item.dart';

const _bgUrl = 'https://res.cloudinary.com/ds757fmhk/image/upload/v1748226260/938827d6-fe31-4deb-a3b2-dc1342757b63_imygby.jpg';

class MomentDetailScreen extends StatefulWidget {
  final MomentItem item;
  const MomentDetailScreen({super.key, required this.item});

  @override
  State<MomentDetailScreen> createState() => _MomentDetailScreenState();
}

class _MomentDetailScreenState extends State<MomentDetailScreen> {
  late MomentItem _item;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _item = widget.item.copyWith();
  }

  Future<void> _rename() async {
    final c = TextEditingController(text: _item.title);
    final txt = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renombrar'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Título'),
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: ()=>Navigator.pop(context,c.text.trim()), child: const Text('Guardar')),
        ],
      ),
    );
    if (txt!=null && txt.isNotEmpty) setState(()=> _item = _item.copyWith(title: txt));
  }

  Future<void> _addFromGallery() async {
    final files = await _picker.pickMultiImage(imageQuality: 92);
    if (files.isEmpty) return;
    final newBase64 = <String>[];
    for (final f in files) {
      final b = await f.readAsBytes();
      newBase64.add(base64Encode(b));
    }
    setState(()=> _item.photos.addAll(newBase64));
  }

  Future<void> _takePhoto() async {
    final f = await _picker.pickImage(source: ImageSource.camera, imageQuality: 92);
    if (f==null) return;
    final b = await f.readAsBytes();
    setState(()=> _item.photos.add(base64Encode(b)));
  }

  void _deleteAt(int index) => setState(()=> _item.photos.removeAt(index));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_item.title),
        actions: [ IconButton(onPressed: _rename, icon: const Icon(Icons.edit)) ],
        backgroundColor: cs.surface.withOpacity(0.60),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      // === Fondo igual que el principal ===
      body: Stack(
        children: [
          Positioned.fill(child: Image.network(_bgUrl, fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: cs.surface.withOpacity(0.55))),

          // Contenedor glass centrado con el grid/fotos adentro
          LayoutBuilder(
            builder: (context, vb) {
              final maxCardWidth = vb.maxWidth < 1000 ? vb.maxWidth - 16 : 1000.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: vb.maxHeight, maxWidth: maxCardWidth),
                    child: Align(
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: cs.surface.withOpacity(.46),
                              border: Border.all(color: cs.outlineVariant.withOpacity(.25)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 18, offset: const Offset(0, 10)),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: _item.photos.isEmpty
                                  ? const SizedBox(
                                      height: 260,
                                      child: Center(child: Text('Sin fotos aún. Usa Tomar o Galería.')),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                      ),
                                      itemCount: _item.photos.length,
                                      itemBuilder: (_, i){
                                        final img = _item.photos[i];
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.memory(base64Decode(img), fit: BoxFit.cover),
                                              Positioned(
                                                right: 6, top: 6,
                                                child: CircleAvatar(
                                                  radius: 16, backgroundColor: Colors.black54,
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    iconSize: 18,
                                                    color: Colors.white,
                                                    onPressed: ()=>_deleteAt(i),
                                                    icon: const Icon(Icons.delete),
                                                    tooltip: 'Eliminar',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: Wrap(
        spacing: 12,
        children: [
          FloatingActionButton.extended(
            heroTag: 'cam',
            onPressed: _takePhoto,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Tomar'),
          ),
          FloatingActionButton.extended(
            heroTag: 'gal',
            onPressed: _addFromGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Galería'),
          ),
          FloatingActionButton.extended(
            heroTag: 'ok',
            onPressed: ()=> Navigator.pop(context, _item),
            icon: const Icon(Icons.check),
            label: const Text('Listo'),
            backgroundColor: cs.primary,
          ),
        ],
      ),
    );
  }
}
