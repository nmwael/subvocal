import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/settings_local_source.dart';

enum TranslationProviderType { azure, myMemory, apertium, libreTranslate, auto }

TranslationProviderType translationProviderTypeFromString(String name) {
  return TranslationProviderType.values.firstWhere(
    (e) => e.name == name,
    orElse: () => TranslationProviderType.auto,
  );
}

class SettingsState {
  final double speechRate;
  final double pitch;
  final String selectedLanguage;
  final String? selectedVoice;
  final String myMemoryEmail;
  final String subdlApiKey;
  final TranslationProviderType selectedTranslationProvider;
  final String appLocale;

  const SettingsState({
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.selectedLanguage = 'en',
    this.selectedVoice,
    this.myMemoryEmail = '',
    this.subdlApiKey = '',
    this.selectedTranslationProvider = TranslationProviderType.auto,
    this.appLocale = 'en',
  });

  SettingsState copyWith({
    double? speechRate,
    double? pitch,
    String? selectedLanguage,
    String? selectedVoice,
    String? myMemoryEmail,
    String? subdlApiKey,
    TranslationProviderType? selectedTranslationProvider,
    String? appLocale,
  }) {
    return SettingsState(
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      myMemoryEmail: myMemoryEmail ?? this.myMemoryEmail,
      subdlApiKey: subdlApiKey ?? this.subdlApiKey,
      selectedTranslationProvider:
          selectedTranslationProvider ?? this.selectedTranslationProvider,
      appLocale: appLocale ?? this.appLocale,
    );
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.5,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      selectedLanguage: json['selectedLanguage'] as String? ?? 'en',
      selectedVoice: json['selectedVoice'] as String?,
      myMemoryEmail: json['myMemoryEmail'] as String? ?? '',
      subdlApiKey: json['subdlApiKey'] as String? ?? '',
      selectedTranslationProvider: translationProviderTypeFromString(
        json['selectedTranslationProvider'] as String? ?? 'auto',
      ),
      appLocale: json['appLocale'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speechRate': speechRate,
      'pitch': pitch,
      'selectedLanguage': selectedLanguage,
      'selectedVoice': selectedVoice,
      'myMemoryEmail': myMemoryEmail,
      'subdlApiKey': subdlApiKey,
      'selectedTranslationProvider': selectedTranslationProvider.name,
      'appLocale': appLocale,
    };
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsLocalSource _localSource;

  SettingsNotifier(this._localSource) : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final saved = await _localSource.load();
    if (saved != null) {
      state = saved;
    }
  }

  void _persist() {
    _localSource.save(state);
  }

  void setSpeechRate(double rate) {
    state = state.copyWith(speechRate: rate);
    _persist();
  }

  void setPitch(double pitch) {
    state = state.copyWith(pitch: pitch);
    _persist();
  }

  void setSelectedLanguage(String language) {
    state = state.copyWith(selectedLanguage: language);
    _persist();
  }

  void setSelectedVoice(String? voice) {
    state = state.copyWith(selectedVoice: voice);
    _persist();
  }

  void setMyMemoryEmail(String email) {
    state = state.copyWith(myMemoryEmail: email);
    _persist();
  }

  void setSubdlApiKey(String key) {
    state = state.copyWith(subdlApiKey: key);
    _persist();
  }

  void setSelectedTranslationProvider(TranslationProviderType provider) {
    state = state.copyWith(selectedTranslationProvider: provider);
    _persist();
  }

  void setAppLocale(String locale) {
    const supported = ['en', 'da', 'es', 'fr'];
    if (!supported.contains(locale)) return;
    state = state.copyWith(appLocale: locale);
    _persist();
  }
}

final settingsLocalSourceProvider = Provider<SettingsLocalSource>((ref) {
  return SettingsLocalSource();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier(ref.watch(settingsLocalSourceProvider));
  },
);
