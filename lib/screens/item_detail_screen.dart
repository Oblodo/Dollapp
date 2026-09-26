import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/item.dart';
import '../services/archive_store.dart';
import '../services/identification_service.dart';
import '../widgets/identification_tips_sheet.dart';
import '../widgets/marketplace_panel.dart';
import 'item_edit_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final S s;
  final ArchiveStore store;
  final Item item;
  final IdentificationService identificationService;
  final String pinnedRegion;

  const ItemDetailScreen({
    super.key,
    required this.s,
    required this.store,
    required this.item,
    required this.identificationService,
    this.pinnedRegion = '',
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Item _item;
  bool _identifying = false;
  IdentificationResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<Item>(
      context,
      MaterialPageRoute(builder: (_) => ItemEditScreen(s: widget.s, store: widget.store, existing: _item)),
    );
    if (updated != null) {
      await widget.store.upsert(updated);
      setState(() => _item = updated);
    }
  }

  Future<void> _delete() async {
    final s = widget.s;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.delete),
        content: Text(s.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(s.delete)),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.store.remove(_item.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _identify() async {
    final s = widget.s;
    if (!widget.identificationService.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.noServerConfigured)));
      return;
    }
    if (_item.photoPaths.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.identify),
        content: Text(s.identifyConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(s.identify)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _identifying = true;
      _error = null;
    });
    try {
      final clues = [_item.name, _item.brand, _item.era, _item.markings, _item.category]
          .where((e) => e.trim().isNotEmpty)
          .join(', ');
      final result = await widget.identificationService.identify(
        photoFiles: _item.photoPaths.map((p) => File(p)).toList(),
        clues: clues,
      );
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _identifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.name.isEmpty ? s.appTitle : _item.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: ListView(
        children: [
          if (_item.photoPaths.isNotEmpty)
            SizedBox(
              height: 220,
              child: PageView(
                children: [
                  for (final path in _item.photoPaths) Image.file(File(path), fit: BoxFit.cover),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_item.brand.isNotEmpty) _row(s.brand, _item.brand),
                if (_item.era.isNotEmpty) _row(s.era, _item.era),
                if (_item.category.isNotEmpty) _row(s.category, _item.category),
                if (_item.markings.isNotEmpty) _row(s.markings, _item.markings),
                if (_item.condition.isNotEmpty) _row(s.condition, _item.condition),
                if (_item.tags.isNotEmpty) _row(s.tags, _item.tags.join(', ')),
                if (_item.notes.isNotEmpty) _row(s.notes, _item.notes),
                if (_item.isWishlist)
                  Padding(padding: const EdgeInsets.only(top: 8), child: Chip(label: Text(s.wishlist))),
                if (_item.ownerVerified)
                  Padding(padding: const EdgeInsets.only(top: 8), child: Chip(label: Text(s.ownerVerified))),
              ],
            ),
          ),
          const Divider(height: 1),
          MarketplacePanel(item: _item, s: s, pinnedRegion: widget.pinnedRegion),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(s.identificationTips),
            onTap: () => IdentificationTipsSheet.show(context, s),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: (_identifying || _item.photoPaths.isEmpty) ? null : _identify,
                  icon: _identifying
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome_outlined),
                  label: Text(_identifying ? s.identifying : s.identify),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                if (_result != null) ..._buildResult(context, _result!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResult(BuildContext context, IdentificationResult result) {
    final s = widget.s;
    if (result.candidates.isEmpty) {
      return [Padding(padding: const EdgeInsets.only(top: 8), child: Text(s.noResultsFor))];
    }
    return [
      const SizedBox(height: 12),
      for (final c in result.candidates)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${c.name}${c.brand.isNotEmpty ? ' – ${c.brand}' : ''}',
                    style: Theme.of(context).textTheme.titleSmall),
                if (c.eraHint != null) Text(c.eraHint!),
                if (c.manufactureStampHint != null) Text(c.manufactureStampHint!),
                for (final r in c.reasons) Text('• $r'),
                if (c.uncertainties.isNotEmpty)
                  Text(
                    c.uncertainties.join('; '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ),
      if (result.researchFailed)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            s.isNorwegian ? 'Bakgrunnsforskning feilet -- forslagene over er fortsatt uverifiserte.' : 'Background research failed -- the suggestions above are still unverified.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
    ];
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: value),
            ],
          ),
        ),
      );
}
