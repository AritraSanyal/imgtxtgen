import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/business_profile.dart';
import '../models/ad_models.dart';
import '../services/claude_service.dart';
import '../services/storage_service.dart';

// ---------------------------------------------------------------
// Singletons
// ---------------------------------------------------------------

final storageServiceProvider = Provider<StorageService>(
  (_) => StorageService(),
);

final claudeServiceProvider = Provider<ClaudeService>(
  (_) => ClaudeService(),
);

// ---------------------------------------------------------------
// Business Profile
// ---------------------------------------------------------------

class ProfileNotifier extends StateNotifier<BusinessProfile> {
  final StorageService _storage;

  ProfileNotifier(this._storage) : super(const BusinessProfile()) {
    _load();
  }

  Future<void> _load() async {
    final profile = await _storage.loadProfile();
    if (profile != null) state = profile;
  }

  Future<void> update(BusinessProfile profile) async {
    state = profile;
    await _storage.saveProfile(profile);
  }

  void updateField(BusinessProfile Function(BusinessProfile) updater) {
    update(updater(state));
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, BusinessProfile>((ref) {
  return ProfileNotifier(ref.read(storageServiceProvider));
});

// ---------------------------------------------------------------
// Ad History
// ---------------------------------------------------------------

class AdHistoryNotifier extends StateNotifier<List<GeneratedAd>> {
  final StorageService _storage;

  AdHistoryNotifier(this._storage) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _storage.loadAds();
  }

  Future<void> addOrUpdate(GeneratedAd ad) async {
    await _storage.saveAd(ad);
    state = await _storage.loadAds();
  }

  Future<void> delete(String id) async {
    await _storage.deleteAd(id);
    state = state.where((a) => a.id != id).toList();
  }
}

final adHistoryProvider =
    StateNotifierProvider<AdHistoryNotifier, List<GeneratedAd>>((ref) {
  return AdHistoryNotifier(ref.read(storageServiceProvider));
});

// ---------------------------------------------------------------
// Current Ad being viewed / edited
// ---------------------------------------------------------------

final currentAdProvider = StateProvider<GeneratedAd?>((ref) => null);

// ---------------------------------------------------------------
// Generation state
// ---------------------------------------------------------------

enum GenerationStatus { idle, loading, success, error }

class GenerationState {
  final GenerationStatus status;
  final String? errorMessage;

  const GenerationState({
    this.status = GenerationStatus.idle,
    this.errorMessage,
  });

  GenerationState copyWith({GenerationStatus? status, String? errorMessage}) =>
      GenerationState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class GenerationNotifier extends StateNotifier<GenerationState> {
  final ClaudeService _claude;
  final Ref _ref;

  GenerationNotifier(this._claude, this._ref)
      : super(const GenerationState());

  Future<GeneratedAd?> generate(AdRequest request) async {
    state = const GenerationState(status: GenerationStatus.loading);

    try {
      final profile = _ref.read(profileProvider);
      final result = await _claude.generateAdCopy(
        request: request,
        profile: profile,
      );

      final ad = GeneratedAd(
        id: const Uuid().v4(),
        headline: result['headline'] ?? '',
        body: result['body'] ?? '',
        hashtags: List<String>.from(result['hashtags'] ?? []),
        imagePrompt: result['image_prompt'],
        platform: request.platform,
        format: request.format,
        status: AdStatus.draft,
        createdAt: DateTime.now(),
        originalPrompt: request.prompt,
      );

      // Save to history
      await _ref.read(adHistoryProvider.notifier).addOrUpdate(ad);
      // Set as current
      _ref.read(currentAdProvider.notifier).state = ad;

      state = const GenerationState(status: GenerationStatus.success);
      return ad;
    } on ClaudeApiException catch (e) {
      state = GenerationState(
        status: GenerationStatus.error,
        errorMessage: e.message,
      );
      return null;
    } catch (e) {
      state = GenerationState(
        status: GenerationStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const GenerationState(status: GenerationStatus.idle);
  }
}

final generationProvider =
    StateNotifierProvider<GenerationNotifier, GenerationState>((ref) {
  return GenerationNotifier(
    ref.read(claudeServiceProvider),
    ref,
  );
});

// ---------------------------------------------------------------
// Ad Request form state
// ---------------------------------------------------------------

class AdRequestNotifier extends StateNotifier<AdRequest> {
  AdRequestNotifier()
      : super(const AdRequest(
          prompt: '',
          platform: AdPlatform.instagram,
          format: AdFormat.square,
          includeHashtags: true,
          generateImagePrompt: true,
          applyBrandTone: true,
        ));

  void setPrompt(String v) => state = AdRequest(
        prompt: v,
        platform: state.platform,
        format: state.format,
        includeHashtags: state.includeHashtags,
        generateImagePrompt: state.generateImagePrompt,
        applyBrandTone: state.applyBrandTone,
      );

  void setPlatform(AdPlatform v) => state = AdRequest(
        prompt: state.prompt,
        platform: v,
        format: state.format,
        includeHashtags: state.includeHashtags,
        generateImagePrompt: state.generateImagePrompt,
        applyBrandTone: state.applyBrandTone,
      );

  void setFormat(AdFormat v) => state = AdRequest(
        prompt: state.prompt,
        platform: state.platform,
        format: v,
        includeHashtags: state.includeHashtags,
        generateImagePrompt: state.generateImagePrompt,
        applyBrandTone: state.applyBrandTone,
      );

  void setIncludeHashtags(bool v) => state = AdRequest(
        prompt: state.prompt,
        platform: state.platform,
        format: state.format,
        includeHashtags: v,
        generateImagePrompt: state.generateImagePrompt,
        applyBrandTone: state.applyBrandTone,
      );

  void setGenerateImagePrompt(bool v) => state = AdRequest(
        prompt: state.prompt,
        platform: state.platform,
        format: state.format,
        includeHashtags: state.includeHashtags,
        generateImagePrompt: v,
        applyBrandTone: state.applyBrandTone,
      );
}

final adRequestProvider =
    StateNotifierProvider<AdRequestNotifier, AdRequest>((ref) {
  return AdRequestNotifier();
});
