import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../l10n/strings.dart';
import '../models/item.dart';
import '../services/archive_store.dart';

/// Create or edit a record. Works fully offline -- saving here never
/// touches the network.
class ItemEditScreen extends StatefulWidget {
  final S s;
  final ArchiveStore store;
  final Item? existing;

  const ItemEditScreen({super.key, required this.s, required this.store, this.existing});

  @override
  State<ItemEditScreen> createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends State<ItemEditScreen> {
  late Item _item;
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _eraCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _markingsCtrl = TextEditingController();
  final _conditionCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _item = widget.existing ?? Item(id: const Uuid().v4());
    _nameCtrl.text = _item.name;
    _brandCtrl.text = _item.brand;
    _eraCtrl.text = _item.era;
    _categoryCtrl.text = _item.category;
    _markingsCtrl.text = _item.markings;
    _conditionCtrl.text = _item.condition;
    _tagsCtrl.text = _item.tags.join(', ');
    _notesCtrl.text = _item.notes;
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _brandCtrl,
      _eraCtrl,
      _categoryCtrl,
      _markingsCtrl,
      _conditionCtrl,
      _tagsCtrl,
      _notesCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addPhoto() async {
    if (_item.photoPaths.length >= 3) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(widget.s.isNorwegian ? 'Kamera' : 'Camera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(widget.s.isNorwegian ? 'Galleri' : 'Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (picked != null) {
      setState(() => _item.photoPaths.add(picked.path));
    }
  }

  void _save() {
    _item
      ..name = _nameCtrl.text.trim()
      ..brand = _brandCtrl.text.trim()
      ..era = _eraCtrl.text.trim()
      ..category = _categoryCtrl.text.trim()
      ..markings = _markingsCtrl.text.trim()
      ..condition = _conditionCtrl.text.trim()
      ..tags = _tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
      ..notes = _notesCtrl.text.trim();
    Navigator.pop(context, _item);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? s.addItem : s.editItem),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.photos, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final path in _item.photoPaths)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(path), width: 72, height: 72, fit: BoxFit.cover),
                  ),
                ),
              if (_item.photoPaths.length < 3)
                InkWell(
                  onTap: _addPhoto,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_a_photo),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: s.name)),
          TextField(controller: _brandCtrl, decoration: InputDecoration(labelText: s.brand)),
          TextField(controller: _eraCtrl, decoration: InputDecoration(labelText: s.era)),
          TextField(controller: _categoryCtrl, decoration: InputDecoration(labelText: s.category)),
          TextField(controller: _markingsCtrl, decoration: InputDecoration(labelText: s.markings)),
          TextField(controller: _conditionCtrl, decoration: InputDecoration(labelText: s.condition)),
          TextField(controller: _tagsCtrl, decoration: InputDecoration(labelText: s.tags)),
          TextField(controller: _notesCtrl, decoration: InputDecoration(labelText: s.notes), maxLines: 3),
          SwitchListTile(
            title: Text(s.wishlist),
            value: _item.isWishlist,
            onChanged: (v) => setState(() => _item.isWishlist = v),
          ),
          SwitchListTile(
            title: Text(s.ownerVerified),
            value: _item.ownerVerified,
            onChanged: (v) => setState(() => _item.ownerVerified = v),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: Text(s.save)),
        ],
      ),
    );
  }
}
