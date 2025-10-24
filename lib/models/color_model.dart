class ColorModel {
  final int? id;
  final String name;
  final String modelType; // 'RGB' | 'CMYK' | 'HEX'
  final int? r, g, b; // 0..255
  final double? c, m, y, k; // 0..100
  final String? hex; // '#RRGGBB'
  final bool isFavorite;
  final String createdAt;
  final String? note;

  ColorModel({
    this.id,
    required this.name,
    required this.modelType,
    this.r,
    this.g,
    this.b,
    this.c,
    this.m,
    this.y,
    this.k,
    this.hex,
    this.isFavorite = false,
    required this.createdAt,
    this.note,
  });

  ColorModel copyWith({
    int? id,
    String? name,
    String? modelType,
    int? r,
    int? g,
    int? b,
    double? c,
    double? m,
    double? y,
    double? k,
    String? hex,
    bool? isFavorite,
    String? createdAt,
    String? note,
  }) {
    return ColorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      modelType: modelType ?? this.modelType,
      r: r ?? this.r,
      g: g ?? this.g,
      b: b ?? this.b,
      c: c ?? this.c,
      m: m ?? this.m,
      y: y ?? this.y,
      k: k ?? this.k,
      hex: hex ?? this.hex,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'modelType': modelType,
    'r': r,
    'g': g,
    'b': b,
    'c': c,
    'm': m,
    'y': y,
    'k': k,
    'hex': hex,
    'isFavorite': isFavorite ? 1 : 0,
    'createdAt': createdAt,
    'note': note,
  };

  factory ColorModel.fromMap(Map<String, dynamic> m) => ColorModel(
    id: m['id'] as int?,
    name: m['name'],
    modelType: m['modelType'],
    r: m['r'] as int?,
    g: m['g'] as int?,
    b: m['b'] as int?,
    c: (m['c'] as num?)?.toDouble(),
    m: (m['m'] as num?)?.toDouble(),
    y: (m['y'] as num?)?.toDouble(),
    k: (m['k'] as num?)?.toDouble(),
    hex: m['hex'] as String?,
    isFavorite: (m['isFavorite'] ?? 0) == 1,
    createdAt: m['createdAt'],
    note: m['note'] as String?,
  );
}
