import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/test_voice_provider.dart';

const _iso6392To6391 = {
  'afr': 'af', 'alb': 'sq', 'amh': 'am', 'ara': 'ar', 'arm': 'hy',
  'aze': 'az', 'baq': 'eu', 'bel': 'be', 'ben': 'bn', 'bos': 'bs',
  'bul': 'bg', 'bur': 'my', 'cat': 'ca', 'che': 'ce', 'zho': 'zh',
  'hrv': 'hr', 'cze': 'cs', 'dan': 'da', 'div': 'dv', 'dut': 'nl',
  'dzo': 'dz', 'eng': 'en', 'est': 'et', 'fao': 'fo', 'fij': 'fj',
  'fin': 'fi', 'fre': 'fr', 'glg': 'gl', 'geo': 'ka', 'ger': 'de',
  'ell': 'el', 'grn': 'gn', 'guj': 'gu', 'hat': 'ht', 'hau': 'ha',
  'heb': 'he', 'hin': 'hi', 'hun': 'hu', 'ice': 'is', 'ind': 'id',
  'gle': 'ga', 'ita': 'it', 'jpn': 'ja', 'jav': 'jv', 'kan': 'kn',
  'kaz': 'kk', 'khm': 'km', 'kor': 'ko', 'kur': 'ku', 'kir': 'ky',
  'lao': 'lo', 'lat': 'la', 'lav': 'lv', 'lit': 'lt', 'mkd': 'mk',
  'may': 'ms', 'mal': 'ml', 'mlt': 'mt', 'mar': 'mr', 'mon': 'mn',
  'nep': 'ne', 'nor': 'no', 'oci': 'oc', 'ori': 'or', 'per': 'fa',
  'pol': 'pl', 'por': 'pt', 'pan': 'pa', 'rum': 'ro', 'rus': 'ru',
  'smo': 'sm', 'srp': 'sr', 'sna': 'sn', 'snd': 'sd', 'sin': 'si',
  'slk': 'sk', 'slv': 'sl', 'som': 'so', 'spa': 'es', 'swa': 'sw',
  'swe': 'sv', 'tgl': 'tl', 'tam': 'ta', 'tat': 'tt', 'tel': 'te',
  'tha': 'th', 'tur': 'tr', 'ukr': 'uk', 'urd': 'ur', 'uzb': 'uz',
  'vie': 'vi', 'wel': 'cy', 'fry': 'fy', 'wol': 'wo', 'yid': 'yi',
};

String _normalizeLangCode(String code) {
  final lower = code.toLowerCase();
  if (lower.length <= 3) return lower;
  final bcp47 = lower.split('-').first;
  if (bcp47.length == 2) return bcp47;
  return _iso6392To6391[bcp47] ?? bcp47;
}

final availableVoicesProvider = FutureProvider.autoDispose<List<Map<String, String>>>((ref) async {
  final tts = ref.watch(flutterTtsProvider);
  final language = ref.watch(settingsProvider).selectedLanguage;
  final raw = await tts.getVoices;
  if (raw is! List) return <Map<String, String>>[];
  final allVoices = raw.whereType<Map>().map((v) =>
      v.map((key, value) => MapEntry(key.toString(), value.toString()))).toList();
  final filtered = allVoices.where((v) {
    final voiceLang = _normalizeLangCode(v['language'] ?? '');
    return voiceLang == language.toLowerCase();
  }).toList();
  return filtered;
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _loginError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loginError = null);
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _loginError = 'Please enter both username and password');
      return;
    }
    final success = await ref.read(authProvider.notifier).login(username, password);
    if (!success && mounted) {
      setState(() => _loginError = 'Login failed. Check your credentials.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Readout Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- OpenSubtitles Account ---
          Text(
            'OpenSubtitles Account',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: auth.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Text('Error checking auth status'),
                data: (authState) {
                  if (authState.status == AuthStatus.authenticated) {
                    return Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Logged in as ${authState.username ?? "user"}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref.read(authProvider.notifier).logout(),
                          child: const Text('Logout', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                      ),
                      if (_loginError != null) ...[
                        const SizedBox(height: 8),
                        Text(_loginError!, style: const TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Speech Configuration ---
          Text(
            'Speech Configuration',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Speech Rate (Speed)'),
                      Text('${settings.speechRate.toStringAsFixed(2)}x'),
                    ],
                  ),
                  Slider(
                    value: settings.speechRate,
                    min: 0.1,
                    max: 2.0,
                    divisions: 19,
                    label: '${settings.speechRate.toStringAsFixed(2)}x',
                    onChanged: (value) => notifier.setSpeechRate(value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Voice Pitch'),
                      Text('${settings.pitch.toStringAsFixed(1)}x'),
                    ],
                  ),
                  Slider(
                    value: settings.pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: '${settings.pitch.toStringAsFixed(1)}x',
                    onChanged: (value) => notifier.setPitch(value),
                  ),
                  const SizedBox(height: 16),
                  _VoiceSelector(
                    selectedVoice: settings.selectedVoice,
                    language: settings.selectedLanguage,
                    onVoiceSelected: (voice) => notifier.setSelectedVoice(voice),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Test Voice ---
          Text(
            'Test Voice',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Hear a sample at your current speed (${settings.speechRate.toStringAsFixed(2)}x) and pitch (${settings.pitch.toStringAsFixed(1)}x).',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  _TestVoiceButton(
                    rate: settings.speechRate,
                    pitch: settings.pitch,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Test Translated Voice ---
          Text(
            'Test Translated Voice',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Translate the first 5 lines to ${settings.selectedLanguage.toUpperCase()} and hear them spoken.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  _TranslatedTestPreview(language: settings.selectedLanguage),
                  const SizedBox(height: 12),
                  _TranslatedTestButton(
                    rate: settings.speechRate,
                    pitch: settings.pitch,
                    language: settings.selectedLanguage,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Translation & Language ---
          Text(
            'Translation & Language',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Default Target Language'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: settings.selectedLanguage,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English (en)')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish (es)')),
                      DropdownMenuItem(value: 'da', child: Text('Danish (da)')),
                      DropdownMenuItem(value: 'fr', child: Text('French (fr)')),
                      DropdownMenuItem(value: 'de', child: Text('German (de)')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        notifier.setSelectedLanguage(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestVoiceButton extends ConsumerWidget {
  final double rate;
  final double pitch;

  const _TestVoiceButton({required this.rate, required this.pitch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(testVoicePlayingProvider);
    final voice = ref.watch(settingsProvider).selectedVoice;

    return isPlaying
        ? OutlinedButton.icon(
            onPressed: () => ref.read(testVoiceControllerProvider).stop(),
            icon: const Icon(Icons.stop),
            label: const Text('Stop Sample'),
          )
        : ElevatedButton.icon(
            onPressed: () => ref.read(testVoiceControllerProvider).playSample(rate, pitch, voice: voice),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play Sample'),
          );
  }
}

class _TranslatedTestPreview extends ConsumerWidget {
  final String language;

  const _TranslatedTestPreview({required this.language});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(translatedTestPreviewProvider(language));
    final theme = Theme.of(context);

    return preview.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(
        'Translation unavailable: $e',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
      ),
      data: (lines) {
        if (lines.isEmpty) {
          return Text(
            'No translations available.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          );
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            lines.join('\n'),
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      },
    );
  }
}

class _TranslatedTestButton extends ConsumerWidget {
  final double rate;
  final double pitch;
  final String language;

  const _TranslatedTestButton({
    required this.rate,
    required this.pitch,
    required this.language,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(translatedTestPlayingProvider);
    final voice = ref.watch(settingsProvider).selectedVoice;

    return isPlaying
        ? OutlinedButton.icon(
            onPressed: () => ref.read(testVoiceControllerProvider).stop(),
            icon: const Icon(Icons.stop),
            label: const Text('Stop Translated Sample'),
          )
        : ElevatedButton.icon(
            onPressed: () => ref.read(testVoiceControllerProvider).playTranslatedSample(rate, pitch, language, voice: voice),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play Translated Sample'),
          );
  }
}

class _VoiceSelector extends ConsumerWidget {
  final String? selectedVoice;
  final String language;
  final ValueChanged<String?> onVoiceSelected;

  const _VoiceSelector({
    required this.selectedVoice,
    required this.language,
    required this.onVoiceSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voicesAsync = ref.watch(availableVoicesProvider);

    return voicesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(
        'Could not load voices: $e',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange),
      ),
      data: (voices) {
        if (voices.isEmpty) {
          return Text(
            'No voices available for ${language.toUpperCase()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          );
        }
        final validValue = voices.any((v) => v['name'] == selectedVoice)
            ? selectedVoice
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Voice'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: validValue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: voices
                  .map((v) => DropdownMenuItem(
                        value: v['name'],
                        child: Text(v['name'] ?? 'Unknown'),
                      ))
                  .toList(),
              onChanged: onVoiceSelected,
            ),
          ],
        );
      },
    );
  }
}
