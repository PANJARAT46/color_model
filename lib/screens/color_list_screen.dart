// lib/screens/color_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/color_provider.dart';
import '../models/color_model.dart';
import 'color_form_screen.dart';

class ColorListScreen extends StatefulWidget {
  const ColorListScreen({super.key});
  @override
  State<ColorListScreen> createState() => _ColorListScreenState();
}

class _ColorListScreenState extends State<ColorListScreen> {
  final _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ColorProvider>().load());
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ColorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Models'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Sort',
            onSelected: p.setOrderBy,
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: 'isFavorite DESC, name ASC',
                child: Text('Favorite first'),
              ),
              PopupMenuItem(value: 'name ASC', child: Text('Name A → Z')),
              PopupMenuItem(value: 'createdAt DESC', child: Text('Newest')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SearchField(
              controller: _searchCtl,
              onChanged: p.setKeyword,
              hintText: 'ค้นหาชื่อ/โมเดล/HEX…',
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ColorFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),

      body: p.items.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: p.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final m = p.items[i];
                final color = _makeColor(m);

                return Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.black12.withOpacity(0.06)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ColorFormScreen(initial: m),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // swatch
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // title + subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${m.modelType} • ${_displayCode(m)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // actions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: m.isFavorite
                                    ? 'Unfavorite'
                                    : 'Favorite',
                                icon: Icon(
                                  m.isFavorite ? Icons.star : Icons.star_border,
                                ),
                                onPressed: () => context
                                    .read<ColorProvider>()
                                    .toggleFavorite(m.id!, !m.isFavorite),
                              ),
                              IconButton(
                                tooltip: 'Edit',
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ColorFormScreen(initial: m),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('ลบรายการนี้?'),
                                      content: Text(
                                        'ต้องการลบ “${m.name}” ใช่ไหม',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('ยกเลิก'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('ลบ'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true)
                                    context.read<ColorProvider>().deleteColor(
                                      m.id!,
                                    );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ---------- Helpers: color & labels ----------
  Color _makeColor(ColorModel m) {
    if ((m.hex ?? '').isNotEmpty) {
      final s = m.hex!.replaceAll('#', '');
      final v = int.tryParse(s, radix: 16) ?? 0x000000;
      return Color(0xFF000000 | v);
    }
    if (m.r != null && m.g != null && m.b != null) {
      return Color.fromARGB(
        255,
        m.r!.clamp(0, 255),
        m.g!.clamp(0, 255),
        m.b!.clamp(0, 255),
      );
    }
    if (m.c != null && m.m != null && m.y != null && m.k != null) {
      final c = m.c!.clamp(0, 100) / 100;
      final mm = m.m!.clamp(0, 100) / 100;
      final y = m.y!.clamp(0, 100) / 100;
      final k = m.k!.clamp(0, 100) / 100;
      final r = ((1 - c) * (1 - k) * 255).round();
      final g = ((1 - mm) * (1 - k) * 255).round();
      final b = ((1 - y) * (1 - k) * 255).round();
      return Color.fromARGB(255, r, g, b);
    }
    return Colors.grey.shade300;
  }

  String? _rgbText(ColorModel m) => (m.r != null && m.g != null && m.b != null)
      ? 'RGB(${m.r},${m.g},${m.b})'
      : null;

  String? _cmykText(ColorModel m) =>
      (m.c != null && m.m != null && m.y != null && m.k != null)
      ? 'CMYK(${m.c?.toStringAsFixed(0)},${m.m?.toStringAsFixed(0)},${m.y?.toStringAsFixed(0)},${m.k?.toStringAsFixed(0)})'
      : null;

  String _displayCode(ColorModel m) =>
      m.hex ?? _rgbText(m) ?? _cmykText(m) ?? '-';
}

// --------- Widgets: Search field & empty state ----------
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  const _SearchField({
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search…',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black12.withOpacity(.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(.6),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.palette_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary.withOpacity(.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'ยังไม่มีสีในรายการ',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'กดปุ่ม “Add” มุมล่างขวาเพื่อสร้างรายการสีใหม่',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
