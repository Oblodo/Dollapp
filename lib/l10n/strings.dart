/// Minimal, dependency-free bilingual strings (Norwegian Bokmål / English).
///
/// Kept as a plain Dart map instead of the full Flutter `intl`/ARB code-gen
/// pipeline so this compiles with zero extra build steps -- important since
/// nobody can run `flutter gen-l10n` by hand to check it in this environment.
/// If the project grows, migrating to ARB files later is straightforward;
/// every lookup already goes through [S.of].
library;

enum AppLocaleCode { nb, en }

class S {
  final AppLocaleCode code;
  const S(this.code);

  static S of(AppLocaleCode code) => S(code);

  bool get isNorwegian => code == AppLocaleCode.nb;

  String _t(String nb, String en) => isNorwegian ? nb : en;

  String get appTitle => _t('Dollfind', 'Dollfind');
  String get home => _t('Samling', 'Collection');
  String get addItem => _t('Legg til gjenstand', 'Add item');
  String get editItem => _t('Rediger gjenstand', 'Edit item');
  String get search => _t('Søk', 'Search');
  String get name => _t('Navn', 'Name');
  String get brand => _t('Merke', 'Brand');
  String get era => _t('Tidsperiode / år', 'Era / year');
  String get category => _t('Kategori', 'Category');
  String get markings => _t('Merking / stempel', 'Markings / stamp');
  String get condition => _t('Tilstand', 'Condition');
  String get tags => _t('Stikkord (kommaseparert)', 'Tags (comma separated)');
  String get notes => _t('Notater', 'Notes');
  String get wishlist => _t('Ønskeliste', 'Wish list');
  String get ownerVerified => _t('Eier har bekreftet identifikasjon', 'Owner-verified identification');
  String get photos => _t('Bilder (maks 3)', 'Photos (max 3)');
  String get addPhoto => _t('Legg til bilde', 'Add photo');
  String get save => _t('Lagre', 'Save');
  String get cancel => _t('Avbryt', 'Cancel');
  String get delete => _t('Slett', 'Delete');
  String get deleteConfirm => _t('Slette denne gjenstanden?', 'Delete this item?');
  String get findValue => _t('Finn verdi og hvor den selges', "Find value & where it's sold");
  String get openInBrowser => _t('Åpne i nettleser', 'Open in browser');
  String get identify => _t('Identifiser med AI (valgfritt)', 'Identify with AI (optional)');
  String get identifyConfirm => _t(
      'Send valgte bilder og notater til den private tjenesten for identifikasjon? Ingen samlingsnotater sendes.',
      'Send the selected photos and clues to your private service for identification? Collection notes are never sent.');
  String get identifying => _t('Identifiserer …', 'Identifying …');
  String get identificationTips => _t('Identifikasjonstips', 'Identification tips');
  String get settings => _t('Innstillinger', 'Settings');
  String get language => _t('Språk', 'Language');
  String get serverUrl => _t('Server-adresse (HTTPS)', 'Server address (HTTPS)');
  String get accessToken => _t('Tilgangsnøkkel', 'Access token');
  String get dedication => _t('Vis dedikasjon', 'Show dedication');
  String get exportBackup => _t('Eksporter sikkerhetskopi', 'Export backup');
  String get importBackup => _t('Importer sikkerhetskopi', 'Import backup');
  String get noServerConfigured =>
      _t('Ingen identifikasjonstjeneste er satt opp ennå. Dette er valgfritt -- resten av appen fungerer helt uten.',
          'No identification service is configured yet. This is optional -- the rest of the app works fully without it.');
  String get emptyCollection => _t('Samlingen er tom ennå. Trykk + for å legge til noe.',
      'Your collection is empty so far. Tap + to add something.');
  String get noResultsFor => _t('Ingen treff', 'No results found');
  String get marketplaceHelp => _t(
      'Se på SOLGTE annonser, ikke aktive. Bruk 5-15 sammenlignbare salg fra siste 60-90 dager og ta MEDIANEN, ikke gjennomsnittet -- noen få uteliggere kan forskyve et lite utvalg mye. En uåpnet/original emballasje kan gi 20-25% høyere pris enn en brukt gjenstand av samme modell.',
      'Look at SOLD listings, not active ones. Use 5-15 comparable sales from the last 60-90 days and take the MEDIAN, not the average -- a couple of outliers can skew a small sample a lot. Original, unopened packaging can add roughly 20-25% over a loose, played-with example of the same mould.');
}
