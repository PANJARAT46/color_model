import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/color_model.dart';

class ColorProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  final String _table = 'color_models';

  List<ColorModel> _items = [];
  String _keyword = '';
  String _orderBy = 'isFavorite DESC, name ASC';

  List<ColorModel> get items => _items;
  String get keyword => _keyword;

  Future<void> load() async {
    final where = (_keyword.trim().isEmpty)
        ? null
        : '(name LIKE ? OR modelType LIKE ? OR hex LIKE ?)';
    final args = (_keyword.trim().isEmpty)
        ? null
        : ['%$_keyword%', '%$_keyword%', '%$_keyword%'];

    final maps = await _db.queryAll(
      _table,
      where: where,
      whereArgs: args,
      orderBy: _orderBy,
    );
    _items = maps.map(ColorModel.fromMap).toList();
    notifyListeners(); // เปลี่ยน state → แจ้ง UI ตาม Provider pattern
  }

  void setKeyword(String k) {
    _keyword = k;
    load();
  }

  void setOrderBy(String ob) {
    _orderBy = ob;
    load();
  }

  Future<void> add(ColorModel c) async {
    await _db.insert(_table, c.toMap());
    await load();
  }

  Future<void> updateColor(ColorModel c) async {
    if (c.id == null) return;
    await _db.update(_table, c.toMap(), c.id!);
    await load();
  }

  Future<void> deleteColor(int id) async {
    await _db.delete(_table, id);
    await load();
  }

  Future<void> toggleFavorite(int id, bool to) async {
    await _db.update(_table, {'isFavorite': to ? 1 : 0}, id);
    await load();
  }
}
