import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// One unverified possibility returned by the identification service.
///
/// Deliberately has no confidence/probability field and no price field --
/// the backend is instructed never to invent either (see
/// value_research.py's IDENTIFICATION_ADDENDUM in the backend/ folder).
class IdentificationCandidate {
  final String name;
  final String brand;
  final String category;
  final String? eraHint;
  final String? manufactureStampHint;
  final List<String> reasons;
  final List<String> uncertainties;
  final List<String> searchPhrases;

  IdentificationCandidate({
    required this.name,
    required this.brand,
    required this.category,
    this.eraHint,
    this.manufactureStampHint,
    List<String>? reasons,
    List<String>? uncertainties,
    List<String>? searchPhrases,
  })  : reasons = reasons ?? const [],
        uncertainties = uncertainties ?? const [],
        searchPhrases = searchPhrases ?? const [];

  factory IdentificationCandidate.fromJson(Map<String, dynamic> json) => IdentificationCandidate(
        name: (json['name'] ?? '').toString(),
        brand: (json['brand'] ?? '').toString(),
        category: (json['category'] ?? '').toString(),
        eraHint: json['era_hint']?.toString(),
        manufactureStampHint: json['manufacture_stamp_hint']?.toString(),
        reasons: ((json['reasons'] as List?) ?? const []).map((e) => e.toString()).toList(),
        uncertainties: ((json['uncertainties'] as List?) ?? const []).map((e) => e.toString()).toList(),
        searchPhrases: ((json['search_phrases'] as List?) ?? const []).map((e) => e.toString()).toList(),
      );
}

class IdentificationResult {
  final List<IdentificationCandidate> candidates;
  final List<String> sourceUrls;
  final bool researchFailed;

  IdentificationResult({required this.candidates, this.sourceUrls = const [], this.researchFailed = false});
}

class IdentificationNotConfigured implements Exception {
  const IdentificationNotConfigured();
}

/// Talks to the owner's own private Dollfind backend (see backend/server.py
/// and README.md, "Activate the online service"). This is entirely
/// optional: every other feature of the app works with no server URL set.
///
/// No photo is sent anywhere without the caller having already shown an
/// explicit confirmation dialog -- this class only performs the network
/// call once asked; it never triggers on its own.
class IdentificationService {
  final String baseUrl;
  final String accessToken;

  const IdentificationService({required this.baseUrl, required this.accessToken});

  bool get isConfigured => baseUrl.trim().isNotEmpty && accessToken.trim().isNotEmpty;

  /// [photoFiles] should be 1-3 photos already selected by the owner.
  /// [clues] is free-text the owner typed (name/brand/markings/etc.) --
  /// never the collection's private notes field, matching the original
  /// app's privacy boundary.
  Future<IdentificationResult> identify({
    required List<File> photoFiles,
    required String clues,
  }) async {
    if (!isConfigured) {
      throw const IdentificationNotConfigured();
    }
    final uri = Uri.parse('$baseUrl/identify');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['clues'] = clues;
    for (final file in photoFiles.take(3)) {
      request.files.add(await http.MultipartFile.fromPath('photos', file.path));
    }

    final streamed = await request.send().timeout(const Duration(seconds: 50));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw HttpException('Identification service returned HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final candidatesJson = (decoded['candidates'] as List?) ?? const [];
    return IdentificationResult(
      candidates: candidatesJson
          .whereType<Map<String, dynamic>>()
          .map(IdentificationCandidate.fromJson)
          .toList(),
      sourceUrls: ((decoded['sources'] as List?) ?? const []).map((e) => e.toString()).toList(),
      researchFailed: (decoded['research_failed'] ?? false) as bool,
    );
  }
}
