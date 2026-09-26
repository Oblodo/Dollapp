import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/item.dart';

/// Local, offline, no-account archive of catalogued items.
///
/// Everything here works with zero network calls, matching the original
/// app's design: cataloguing, search, wish-list and export/import all
/// function before -- and entirely without -- any identification service
/// being configured.
///
/// Writes are atomic (write to a temp file, then rename over the real one)
/// so a crash mid-save can't corrupt the archive, the same guarantee the
/// original native app made.
class ArchiveStore {
  static const _fileName = 'dollfind_archive.json';
  List<Item> _items = [];
  bool _loaded = false;

  Future<File> _archiveFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<Item>> load() async {
    if (_loaded) return List.unmodifiable(_items);
    final file = await _archiveFile();
    if (await file.exists()) {
      try {
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _items = decoded
              .whereType<Map<String, dynamic>>()
              .map(Item.fromJson)
              .toList();
        }
      } catch (_) {
        // A corrupted or unreadable archive is treated as empty rather than
        // crashing the app; the file itself is left untouched on disk so a
        // manual recovery attempt is still possible.
        _items = [];
      }
    }
    _loaded = true;
    return List.unmodifiable(_items);
  }

  Future<void> _persist() async {
    final file = await _archiveFile();
    final tmp = File('${file.path}.tmp');
    final jsonStr = jsonEncode(_items.map((e) => e.toJson()).toList());
    await tmp.writeAsString(jsonStr, flush: true);
    await tmp.rename(file.path);
  }

  Future<List<Item>> upsert(Item item) async {
    await load();
    final index = _items.indexWhere((e) => e.id == item.id);
    item.updatedAt = DateTime.now().toUtc();
    if (index >= 0) {
      _items[index] = item;
    } else {
      _items.add(item);
    }
    await _persist();
    return List.unmodifiable(_items);
  }

  Future<List<Item>> remove(String id) async {
    await load();
    _items.removeWhere((e) => e.id == id);
    await _persist();
    return List.unmodifiable(_items);
  }

  /// Exports the whole archive (including embedded photo file paths, but
  /// not the photo bytes themselves) as a single JSON string, matching the
  /// "export/import includes photographs" intent of the original app for
  /// the metadata side. Bundling photo bytes into one portable file is a
  /// natural next step (e.g. with the `archive` package to zip them
  /// alongside this JSON) -- left out of this first cross-platform pass to
  /// keep the dependency list small; see README-BUILD.md.
  Future<String> exportJson() async {
    await load();
    return jsonEncode({
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'items': _items.map((e) => e.toJson()).toList(),
    });
  }

  /// Imports a backup produced by [exportJson]. Merges by id: an item
  /// already present locally is left unchanged rather than overwritten,
  /// matching the original app's import behaviour, and malformed input is
  /// rejected without touching the existing archive.
  Future<List<Item>> importJson(String raw) async {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['items'] is! List) {
      throw const FormatException('Not a recognised Dollfind backup file.');
    }
    await load();
    final incoming = (decoded['items'] as List)
        .whereType<Map<String, dynamic>>()
        .map(Item.fromJson);
    final existingIds = _items.map((e) => e.id).toSet();
    for (final item in incoming) {
      if (!existingIds.contains(item.id)) {
        _items.add(item);
      }
    }
    await _persist();
    return List.unmodifiable(_items);
  }
}
