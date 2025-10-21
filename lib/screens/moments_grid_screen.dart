import 'dart:ui' show ImageFilter;\nimport 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../models/moment_item.dart';
import '../data/moment_storage.dart';
import 'moment_detail_screen.dart';

const _bgUrl = 'https://res.cloudinary.com/ds757fmhk/image/upload/v1748226260/938827d6-fe31-4deb-a3b2-dc1342757b63_imygby.jpg';

class MomentsGridScreen extends StatefulWidget {
  static const routeName = '/momentos';
  const MomentsGridScreen({super.key});

  @override
  State<MomentsGridScreen> createState() => _MomentsGridScreenState();
}

class _MomentsGridScreenState extends State<MomentsGridScreen> {
  List<MomentItem> _items = <MomentItem>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await MomentStorage.load();
    if (loaded.isEmpty) {
      _items = [
        MomentItem(id: 'm1', title: 'Momentos inolvidables'),
        MomentItem(id: 'm2', title: 'Sábado en la mañana'),
        MomentItem(id: 'm3', title: 'Sábado en la tarde'),
        MomentItem(id: 'm4', title: 'Domingo en la noche'),
      ];
      await MomentStorage.save(_items);
    } else {
      _items = loaded;
    }
    if (mounted) setState((){});
  }

  Future<void> _persist() => MomentStorage.save(_items);

  int _columnsForWidth(double w) => w < 600 ? 1 : 2;

  Future<void> _addItem() async {
    final c = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo apartado'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'Título'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Agregar')),
        ],
      ),
    );
    if (title != null && title.isNotEmpty) {
      setState(()=> _items.add(MomentItem(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title)));
      await _persist();
    }
  }

  Future<bool> _confirmDelete(String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar “”?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    return ok ?? false;
  }

  void _showCreators() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 4),
            Text('Creadores', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 12),
            Text('Alexis David Obil Colli · Eliana Sarai Sima Tut'),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentos / Productos'),
        centerTitle: true,
        backgroundColor: cs.surface.withOpacity(0.60),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: _showCreators,
            icon: const Icon(Icons.info_outline),
            label: const Text('Creadores'),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),

      body: Stack(
        children: [
          Positioned.fill(child: Image.network(_bgUrl, fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: cs.surface.withOpacity(0.55))),
          LayoutBuilder(
            builder: (context, vb) {
              final paddingH = 12.0;
final available = vb.maxWidth.isFinite && vb.maxWidth > 0 ? vb.maxWidth : 360.0;
final maxCardWidth = (available - paddingH).clamp(280.0, 900.0);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 280, minHeight: vb.maxHeight, maxWidth: maxCardWidth),
                    child: Align(
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: cs.surface.withOpacity(.44),
                              border: Border.all(color: cs.outlineVariant.withOpacity(.2)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 14, offset: const Offset(0, 8))],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: LayoutBuilder(
                                builder: (context, c) {
                                  final cols = _columnsForWidth(c.maxWidth);
                                  const spacing = 4.0;
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cols,
                                      mainAxisSpacing: spacing,
                                      crossAxisSpacing: spacing,
                                      childAspectRatio: cols == 1 ? 6.0 : 4.2,
                                    ),
                                    itemCount: _items.length,
                                    itemBuilder: (context, i) {
                                      final item = _items[i];
                                      return Dismissible(
                                        key: ValueKey(item.id),
                                        direction: DismissDirection.endToStart,
                                        confirmDismiss: (_) => _confirmDelete(item.title),
                                        onDismissed: (_) async {
                                          setState(()=> _items.removeAt(i));
                                          await _persist();
                                        },
                                        background: Container(
                                          decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(14)),
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Icon(Icons.delete_forever, color: cs.onErrorContainer),
                                        ),
                                        child: _MomentCard(
                                          title: item.title,
                                          onOpen: () async {
                                            final updated = await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_)=> MomentDetailScreen(item: item)),
                                            );
                                            if (updated is MomentItem) {
                                              setState(()=> _items[i] = updated);
                                              await _persist();
                                            }
                                          },
                                          onDelete: () async {
                                            if (await _confirmDelete(item.title)) {
                                              setState(()=> _items.removeAt(i));
                                              await _persist();
                                            }
                                          },
                                        ),
                                      );
                                    },
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}

class _MomentCard extends StatelessWidget {
  final String title;
  final VoidCallback onDelete;
  final VoidCallback onOpen;
  const _MomentCard({required this.title, required this.onDelete, required this.onOpen, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceVariant.withOpacity(.28),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: cs.primary, child: const Icon(Icons.collections_bookmark_outlined, size: 16, color: Colors.white)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              IconButton(tooltip: 'Eliminar', onPressed: onDelete, icon: const Icon(Icons.delete_outline, size: 18)),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

