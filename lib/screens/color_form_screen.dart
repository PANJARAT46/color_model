import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/color_provider.dart';
import '../models/color_model.dart';

class ColorFormScreen extends StatefulWidget {
  final ColorModel? initial;
  const ColorFormScreen({super.key, this.initial});

  @override
  State<ColorFormScreen> createState() => _ColorFormScreenState();
}

class _ColorFormScreenState extends State<ColorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _hexCtl = TextEditingController();
  final _noteCtl = TextEditingController();

  String _modelType = 'RGB';
  int? _r, _g, _b;
  double? _c, _m, _y, _k;
  bool _fav = false;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    if (c != null) {
      _nameCtl.text = c.name;
      _modelType = c.modelType;
      _r = c.r;
      _g = c.g;
      _b = c.b;
      _c = c.c;
      _m = c.m;
      _y = c.y;
      _k = c.k;
      _hexCtl.text = c.hex ?? '';
      _fav = c.isFavorite;
      _noteCtl.text = c.note ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _hexCtl.dispose();
    _noteCtl.dispose();
    super.dispose();
  }

  String? _vInt(String? v, int min, int max) {
    if (v == null || v.trim().isEmpty) return 'จำเป็น';
    final n = int.tryParse(v);
    if (n == null) return 'ตัวเลขเท่านั้น';
    if (n < min || n > max) return 'ช่วง $min–$max';
    return null;
  }

  String? _vDouble(String? v, double min, double max) {
    if (v == null || v.trim().isEmpty) return 'จำเป็น';
    final n = double.tryParse(v);
    if (n == null) return 'ตัวเลขเท่านั้น';
    if (n < min || n > max) return 'ช่วง $min–$max';
    return null;
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final now = DateTime.now().toIso8601String();
    final m = ColorModel(
      id: widget.initial?.id,
      name: _nameCtl.text.trim(),
      modelType: _modelType,
      r: _r,
      g: _g,
      b: _b,
      c: _c,
      m: _m,
      y: _y,
      k: _k,
      hex: _hexCtl.text.trim().isEmpty ? null : _hexCtl.text.trim(),
      isFavorite: _fav,
      createdAt: widget.initial?.createdAt ?? now,
      note: _noteCtl.text.trim().isEmpty ? null : _noteCtl.text.trim(),
    );

    final p = context.read<ColorProvider>();
    (m.id == null) ? await p.add(m) : await p.updateColor(m);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final swatch = _previewColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Add Color' : 'Edit Color'),
      ),
      body: Form(
        key: _formKey, // ใช้ GlobalKey<FormState> ตามบทฟอร์ม
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: swatch,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _nameCtl,
                    decoration: const InputDecoration(labelText: 'Name *'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'จำเป็น' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _modelType,
              items: const [
                'RGB',
                'CMYK',
                'HEX',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _modelType = v!),
              decoration: const InputDecoration(labelText: 'Model *'),
            ),
            const SizedBox(height: 8),

            if (_modelType == 'RGB') ...[
              TextFormField(
                initialValue: _r?.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'R (0–255) *'),
                validator: (v) => _vInt(v, 0, 255),
                onSaved: (v) => _r = int.tryParse(v ?? ''),
              ),
              TextFormField(
                initialValue: _g?.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'G (0–255) *'),
                validator: (v) => _vInt(v, 0, 255),
                onSaved: (v) => _g = int.tryParse(v ?? ''),
              ),
              TextFormField(
                initialValue: _b?.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'B (0–255) *'),
                validator: (v) => _vInt(v, 0, 255),
                onSaved: (v) => _b = int.tryParse(v ?? ''),
              ),
            ],

            if (_modelType == 'CMYK') ...[
              TextFormField(
                initialValue: _c?.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'C (0–100) *'),
                validator: (v) => _vDouble(v, 0, 100),
                onSaved: (v) => _c = double.tryParse(v ?? ''),
              ),
              TextFormField(
                initialValue: _m?.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'M (0–100) *'),
                validator: (v) => _vDouble(v, 0, 100),
                onSaved: (v) => _m = double.tryParse(v ?? ''),
              ),
              TextFormField(
                initialValue: _y?.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Y (0–100) *'),
                validator: (v) => _vDouble(v, 0, 100),
                onSaved: (v) => _y = double.tryParse(v ?? ''),
              ),
              TextFormField(
                initialValue: _k?.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'K (0–100) *'),
                validator: (v) => _vDouble(v, 0, 100),
                onSaved: (v) => _k = double.tryParse(v ?? ''),
              ),
            ],

            if (_modelType == 'HEX') ...[
              TextFormField(
                controller: _hexCtl,
                decoration: const InputDecoration(labelText: 'HEX (#RRGGBB) *'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'จำเป็น';
                  final ok = RegExp(r'^#([A-Fa-f0-9]{6})$').hasMatch(v.trim());
                  return ok ? null : 'รูปแบบไม่ถูกต้อง';
                },
                onChanged: (_) => setState(() {}),
              ),
            ],

            const SizedBox(height: 8),
            SwitchListTile(
              value: _fav,
              title: const Text('Favorite'),
              onChanged: (v) => setState(() => _fav = v),
            ),
            TextFormField(
              controller: _noteCtl,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              onPressed: _save,
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Color _previewColor() {
    // HEX
    if (_modelType == 'HEX' && _hexCtl.text.trim().isNotEmpty) {
      final s = _hexCtl.text.trim().replaceAll('#', '');
      final v = int.tryParse(s, radix: 16) ?? 0x000000;
      return Color(0xFF000000 | v);
    }

    // RGB
    if (_modelType == 'RGB' && _r != null && _g != null && _b != null) {
      return Color.fromARGB(
        255,
        _r!.clamp(0, 255),
        _g!.clamp(0, 255),
        _b!.clamp(0, 255),
      );
    }

    // ✅ CMYK → แปลงเป็น RGB ก่อน
    if (_modelType == 'CMYK' &&
        _c != null &&
        _m != null &&
        _y != null &&
        _k != null) {
      double c = _c!.clamp(0, 100) / 100;
      double m = _m!.clamp(0, 100) / 100;
      double y = _y!.clamp(0, 100) / 100;
      double k = _k!.clamp(0, 100) / 100;

      int r = ((1 - c) * (1 - k) * 255).round();
      int g = ((1 - m) * (1 - k) * 255).round();
      int b = ((1 - y) * (1 - k) * 255).round();

      return Color.fromARGB(255, r, g, b);
    }

    // Default ถ้ายังไม่มีค่า
    return Colors.grey.shade300;
  }
}
