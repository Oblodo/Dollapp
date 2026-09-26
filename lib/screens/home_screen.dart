import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/item.dart';
import '../services/archive_store.dart';
import '../services/identification_service.dart';
import '../services/settings_store.dart';
import 'item_detail_screen.dart';
import 'item_edit_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final S s;
  final ValueChanged<AppLocaleCode> onLocaleChanged;

  const HomeScreen({super.key, required this.s, required this.onLocaleChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = ArchiveStore();
  final _settings = SettingsStore();
  List<Item> _items = [];
  String _query = '';
  bool _showDedication = true;
  String _pinnedRegion = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _store.load();
    final showDedication = await _settings.getShowDedication();
    final region = await _settings.getPinnedRegion();
    setState(() {
      _items = List.of(items)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _showDedication = showDedication;
      _pinnedRegion = region;
    });
  }

  Future<IdentificationService> _identificationService() async {
    final url = await _settings.getServerUrl();
    final token = await _settings.getAccessToken();
    return IdentificationService(baseUrl: url, accessToken: token);
  }

  Future<void> _addItem() async {
    final s = widget.s;
    final created = await Navigator.push<Item>(
      context,
      MaterialPageRoute(builder: (_) => ItemEditScreen(s: s, store: _store)),
    );
    if (created != null) {
      await _store.upsert(created);
      _load();
    }
  }

  Future<void> _openItem(Item item) async {
    final s = widget.s;
    final identificationService = await _identificationService();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(
          s: s,
          store: _store,
          item: item,
          identificationService: identificationService,
          pinnedRegion: _pinnedRegion,
        ),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final filtered = _items.where((i) => i.matchesQuery(_query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(s: s, store: _store, onLocaleChanged: widget.onLocaleChanged),
                ),
              );
              _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showDedication)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                s.isNorwegian ? 'Laget for Silje, av Geir Erik.' : 'Made for Silje, by Geir Erik.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: s.search,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _items.isEmpty ? s.emptyCollection : s.noResultsFor,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return ListTile(
                        leading: item.photoPaths.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(File(item.photoPaths.first), width: 48, height: 48, fit: BoxFit.cover),
                              )
                            : const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                        title: Text(item.name.isEmpty ? '(${s.name})' : item.name),
                        subtitle: Text([item.brand, item.era].where((e) => e.isNotEmpty).join(' · ')),
                        trailing: item.isWishlist ? const Icon(Icons.star_outline) : null,
                        onTap: () => _openItem(item),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addItem, child: const Icon(Icons.add)),
    );
  }
}
