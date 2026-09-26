import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';

/// Thin wrapper around SharedPreferences for the handful of settings the
/// app needs. Nothing sensitive is stored here except the optional bearer
/// token for the owner's own private identification server -- the same
/// trust model the original app documented (app-private storage, not a
/// hardware-backed secret; rotate the server token if the phone is lost).
class SettingsStore {
  static const _kLocale = 'locale';
  static const _kServerUrl = 'server_url';
  static const _kAccessToken = 'access_token';
  static const _kShowDedication = 'show_dedication';
  static const _kPinnedRegion = 'pinned_region';

  Future<AppLocaleCode> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kLocale);
    return v == 'en' ? AppLocaleCode.en : AppLocaleCode.nb;
  }

  Future<void> setLocale(AppLocaleCode code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, code == AppLocaleCode.en ? 'en' : 'nb');
  }

  Future<String> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kServerUrl) ?? '';
  }

  Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kServerUrl, url.trim());
  }

  Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccessToken) ?? '';
  }

  Future<void> setAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessToken, token.trim());
  }

  Future<bool> getShowDedication() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kShowDedication) ?? true;
  }

  Future<void> setShowDedication(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowDedication, value);
  }

  /// Optional two-letter region code (see MarketplaceLinks) to pin to the
  /// top of the marketplace panel, e.g. "no", "uk", "de", "jp", "au".
  /// Empty by default -- the panel is global-first out of the box.
  Future<String> getPinnedRegion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPinnedRegion) ?? '';
  }

  Future<void> setPinnedRegion(String region) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPinnedRegion, region.trim().toLowerCase());
  }
}
