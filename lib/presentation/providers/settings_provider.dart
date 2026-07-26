import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TranslationProviderType { azure, myMemory, apertium, libreTranslate, auto }

class SettingsState {
  final double speechRate;
  final double pitch;
  final String selectedLanguage;
  final String? selectedVoice;
  final String myMemoryEmail;
  final TranslationProviderType selectedTranslationProvider;

  const SettingsState({
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.selectedLanguage = 'en',
    this.selectedVoice,
    this.myMemoryEmail = '',
    this.selectedTranslationProvider = TranslationProviderType.auto,
  });

  SettingsState copyWith({
    double? speechRate,
    double? pitch,
    String? selectedLanguage,
    String? selectedVoice,
    String? myMemoryEmail,
    TranslationProviderType? selectedTranslationProvider,
  }) {
    return SettingsState(
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      myMemoryEmail: myMemoryEmail ?? this.myMemoryEmail,
      selectedTranslationProvider:
          selectedTranslationProvider ?? this.selectedTranslationProvider,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void setSpeechRate(double rate) {
    state = state.copyWith(speechRate: rate);
  }

  void setPitch(double pitch) {
    state = state.copyWith(pitch: pitch);
  }

  void setSelectedLanguage(String language) {
    state = state.copyWith(selectedLanguage: language);
  }

  void setSelectedVoice(String? voice) {
    state = state.copyWith(selectedVoice: voice);
  }

  void setMyMemoryEmail(String email) {
    state = state.copyWith(myMemoryEmail: email);
  }

  void setSelectedTranslationProvider(TranslationProviderType provider) {
    state = state.copyWith(selectedTranslationProvider: provider);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);
