import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final double speechRate;
  final double pitch;
  final String selectedLanguage;
  final String? selectedVoice;

  const SettingsState({
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.selectedLanguage = 'en',
    this.selectedVoice,
  });

  SettingsState copyWith({
    double? speechRate,
    double? pitch,
    String? selectedLanguage,
    String? selectedVoice,
  }) {
    return SettingsState(
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedVoice: selectedVoice ?? this.selectedVoice,
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
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
