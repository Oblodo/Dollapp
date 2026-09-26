import '../models/marketplace_link.dart';

/// Builds "where to find it / what it's going for" search links for a
/// catalogued item -- worldwide, not centred on any one country.
///
/// Deliberately does NOT attempt automatic valuation or reverse-image
/// search:
///
///  - Reverse image search would need either a paid vision API key reachable
///    from the app, or the Google Custom Search Image API (closed to new
///    customers). Both add cost, key-management and privacy surface this
///    project has chosen to avoid for now. Opening Google Images lets the
///    owner run a manual reverse-image search with their own photo in about
///    two taps instead, at zero API cost and zero extra permission.
///
///  - Automatic valuation would mean scraping or paying for sold-listing
///    data and boiling it down to one fabricated number. Dollfind's design
///    principle from day one is to never claim a confidence percentage or an
///    automatic value -- handing the owner the same search tools a careful
///    appraiser would use keeps that promise while still doing the useful
///    part of the job.
///
/// The set below is intentionally global first: general marketplaces and
/// specialist collectible/doll marketplaces that all ship internationally,
/// followed by one clearly-labelled regional option. Earlier drafts of this
/// helper put a single country first by default -- that's been corrected
/// here; nothing is prioritised by country unless the caller explicitly asks
/// for a region to be pinned to the top via [pinnedRegion].
class MarketplaceLinks {
  MarketplaceLinks._();

  static List<MarketplaceLink> build({
    String name = '',
    String brand = '',
    String era = '',
    String markings = '',
    String pinnedRegion = '',
  }) {
    final query = _joinNonEmpty(' ', [name, brand, era]);
    final encoded = Uri.encodeQueryComponent(query);
    final encodedWithMarkings = Uri.encodeQueryComponent(_joinNonEmpty(' ', [query, markings]));

    final global = <MarketplaceLink>[
      MarketplaceLink(
        'eBay – sold listings (use these for a realistic value)',
        'https://www.ebay.com/sch/i.html?_nkw=$encoded&LH_Sold=1&LH_Complete=1',
      ),
      MarketplaceLink('eBay – active listings', 'https://www.ebay.com/sch/i.html?_nkw=$encoded'),
      MarketplaceLink('Ruby Lane (antique & vintage doll specialists)', 'https://www.rubylane.com/search?q=$encoded'),
      MarketplaceLink('Etsy', 'https://www.etsy.com/search?q=$encoded'),
      MarketplaceLink('Catawiki (European specialist auctions)', 'https://www.catawiki.com/en/s?q=$encoded'),
      MarketplaceLink('LiveAuctioneers (auction houses worldwide)', 'https://www.liveauctioneers.com/search/?keyword=$encoded'),
      MarketplaceLink('WorthPoint (sold-price research archive)', 'https://www.worthpoint.com/worthopedia?searchTerm=$encoded'),
      MarketplaceLink('Mercari', 'https://www.mercari.com/search/?keyword=$encoded'),
      MarketplaceLink('Vinted', 'https://www.vinted.com/catalog?search_text=$encoded'),
      MarketplaceLink('Facebook Marketplace', 'https://www.facebook.com/marketplace/search/?query=$encoded'),
      MarketplaceLink('Google search (identification & background)', 'https://www.google.com/search?q=$encodedWithMarkings'),
      MarketplaceLink('Google Images (manual reverse-image search)', 'https://images.google.com/'),
    ];

    final regional = <String, MarketplaceLink>{
      'no': MarketplaceLink('FINN.no Torget (Norway)', 'https://www.finn.no/recommerce/forsale/search?q=$encoded'),
      'uk': MarketplaceLink('eBay.co.uk', 'https://www.ebay.co.uk/sch/i.html?_nkw=$encoded'),
      'de': MarketplaceLink('eBay Kleinanzeigen (Germany)', 'https://www.ebay-kleinanzeigen.de/s-anzeigen/$encoded/k0'),
      'jp': MarketplaceLink('Mercari Japan', 'https://jp.mercari.com/search?keyword=$encoded'),
      'au': MarketplaceLink('eBay.com.au', 'https://www.ebay.com.au/sch/i.html?_nkw=$encoded'),
    };

    final region = pinnedRegion.trim().toLowerCase();
    final links = <MarketplaceLink>[];
    if (region.isNotEmpty && regional.containsKey(region)) {
      links.add(regional[region]!);
    }
    links.addAll(global);
    // Always offer every regional option at the end too, clearly labelled,
    // rather than hiding them -- a Norwegian owner researching a doll made
    // in Japan may still want both FINN.no and Mercari Japan, for example.
    for (final entry in regional.entries) {
      if (entry.key != region) {
        links.add(entry.value);
      }
    }
    return links;
  }

  static String _joinNonEmpty(String sep, List<String> parts) {
    final cleaned = parts.map((p) => p.trim()).where((p) => p.isNotEmpty);
    return cleaned.join(sep);
  }
}
