/// A single catalogued collectible (doll, action figure, plush, model, etc).
///
/// Mirrors the field set of the original native-Android Archive record
/// (name, brand, era, category, markings, condition, tags, notes, wish-list
/// flag, owner-verified flag, up to three photos) so nothing from the
/// original design is lost in the move to a single cross-platform codebase.
class Item {
  final String id;
  String name;
  String brand;
  String era;
  String category;
  String markings;
  String condition;
  List<String> tags;
  String notes;
  bool isWishlist;
  bool ownerVerified;

  /// Local file paths (app documents directory) of up to three photos.
  List<String> photoPaths;

  final DateTime createdAt;
  DateTime updatedAt;

  Item({
    required this.id,
    this.name = '',
    this.brand = '',
    this.era = '',
    this.category = '',
    this.markings = '',
    this.condition = '',
    List<String>? tags,
    this.notes = '',
    this.isWishlist = false,
    this.ownerVerified = false,
    List<String>? photoPaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : tags = tags ?? <String>[],
        photoPaths = photoPaths ?? <String>[],
        createdAt = createdAt ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'era': era,
        'category': category,
        'markings': markings,
        'condition': condition,
        'tags': tags,
        'notes': notes,
        'isWishlist': isWishlist,
        'ownerVerified': ownerVerified,
        'photoPaths': photoPaths,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        name: (json['name'] ?? '') as String,
        brand: (json['brand'] ?? '') as String,
        era: (json['era'] ?? '') as String,
        category: (json['category'] ?? '') as String,
        markings: (json['markings'] ?? '') as String,
        condition: (json['condition'] ?? '') as String,
        tags: ((json['tags'] as List?) ?? const []).map((e) => e.toString()).toList(),
        notes: (json['notes'] ?? '') as String,
        isWishlist: (json['isWishlist'] ?? false) as bool,
        ownerVerified: (json['ownerVerified'] ?? false) as bool,
        photoPaths: ((json['photoPaths'] as List?) ?? const []).map((e) => e.toString()).toList(),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc(),
      );

  /// Matches the free-text search fields the original app searched
  /// (name, brand, category, tags).
  bool matchesQuery(String query) {
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();
    return name.toLowerCase().contains(q) ||
        brand.toLowerCase().contains(q) ||
        category.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }
}
