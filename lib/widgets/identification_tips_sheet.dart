import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../l10n/strings.dart';

/// Zero-network offline reference (bundled asset, never fetched), shown as
/// a modal bottom sheet from the item detail screen. See
/// assets/identification_tips_dolls.md for the content and its sources.
class IdentificationTipsSheet extends StatelessWidget {
  final S s;
  const IdentificationTipsSheet({super.key, required this.s});

  static Future<void> show(BuildContext context, S s) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => IdentificationTipsSheet(s: s),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (context, scrollController) {
        return FutureBuilder<String>(
          future: rootBundle.loadString('assets/identification_tips_dolls.md'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.identificationTips, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  // Plain text rendering keeps this dependency-free; a
                  // Markdown renderer package is an easy upgrade later if
                  // richer formatting is wanted.
                  Text(snapshot.data!),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
