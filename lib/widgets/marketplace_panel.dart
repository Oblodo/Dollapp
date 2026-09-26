import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';
import '../models/item.dart';
import '../services/marketplace_links.dart';

/// Collapsed-by-default "Find value & where it's sold" panel.
///
/// Just opens links in the device browser -- see marketplace_links.dart for
/// why this deliberately never computes or displays a single number.
class MarketplacePanel extends StatelessWidget {
  final Item item;
  final S s;
  final String pinnedRegion;

  const MarketplacePanel({super.key, required this.item, required this.s, this.pinnedRegion = ''});

  @override
  Widget build(BuildContext context) {
    final links = MarketplaceLinks.build(
      name: item.name,
      brand: item.brand,
      era: item.era,
      markings: item.markings,
      pinnedRegion: pinnedRegion,
    );

    return ExpansionTile(
      title: Text(s.findValue),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            s.marketplaceHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 4),
        for (final link in links)
          ListTile(
            dense: true,
            leading: const Icon(Icons.open_in_new),
            title: Text(link.label),
            onTap: () => _open(context, link.url),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.isNorwegian ? 'Kunne ikke åpne lenken.' : 'Could not open that link.')),
      );
    }
  }
}
