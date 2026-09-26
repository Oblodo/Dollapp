import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/strings.dart';
import '../services/archive_store.dart';
import '../services/settings_store.dart';

class SettingsScreen extends StatefulWidget {
  final S s;
  final ArchiveStore store;
  final ValueChanged<AppLocaleCode> onLocaleChanged;

  const SettingsScreen({super.key, required this.s, required this.store, required this.onLocaleChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsStore();
  final _serverCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  bool _showDedication = true;
  AppLocaleCode _locale = AppLocaleCode.nb;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _serverCtrl.text = await _settings.getServerUrl();
    _tokenCtrl.text = await _settings.getAccessToken();
    _showDedication = await _settings.getShowDedication();
    _locale = await _settings.getLocale();
    setState(() {});
  }

  Future<void> _exportBackup() async {
    final s = widget.s;
    final json = await widget.store.exportJson();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/dollfind_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(json);
    setState(() => _status = s.isNorwegian
        ? 'Sikkerhetskopi lagret: ${file.path}'
        : 'Backup saved to: ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.language, style: Theme.of(context).textTheme.titleMedium),
          RadioListTile<AppLocaleCode>(
            title: const Text('Norsk (Bokmål)'),
            value: AppLocaleCode.nb,
            groupValue: _locale,
            onChanged: (v) async {
              await _settings.setLocale(v!);
              widget.onLocaleChanged(v);
              setState(() => _locale = v);
            },
          ),
          RadioListTile<AppLocaleCode>(
            title: const Text('English'),
            value: AppLocaleCode.en,
            groupValue: _locale,
            onChanged: (v) async {
              await _settings.setLocale(v!);
              widget.onLocaleChanged(v);
              setState(() => _locale = v);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text(s.dedication),
            value: _showDedication,
            onChanged: (v) async {
              await _settings.setShowDedication(v);
              setState(() => _showDedication = v);
            },
          ),
          const Divider(),
          Text(s.isNorwegian ? 'Identifikasjonstjeneste (valgfritt)' : 'Identification service (optional)',
              style: Theme.of(context).textTheme.titleMedium),
          Text(s.noServerConfigured, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          TextField(
            controller: _serverCtrl,
            decoration: InputDecoration(labelText: s.serverUrl, hintText: 'https://your-private-server.example'),
            onSubmitted: (v) => _settings.setServerUrl(v),
          ),
          TextField(
            controller: _tokenCtrl,
            obscureText: true,
            decoration: InputDecoration(labelText: s.accessToken),
            onSubmitted: (v) => _settings.setAccessToken(v),
          ),
          FilledButton(
            onPressed: () async {
              await _settings.setServerUrl(_serverCtrl.text);
              await _settings.setAccessToken(_tokenCtrl.text);
              setState(() => _status = s.save);
            },
            child: Text(s.save),
          ),
          const Divider(),
          Text(s.isNorwegian ? 'Data' : 'Data', style: Theme.of(context).textTheme.titleMedium),
          OutlinedButton(onPressed: _exportBackup, child: Text(s.exportBackup)),
          if (_status.isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 12), child: Text(_status)),
        ],
      ),
    );
  }
}
