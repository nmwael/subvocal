import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/bug_report_helper.dart';
import '../../generated/app_localizations.dart';
import '../utils/help_reader.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/test_voice_provider.dart';
import '../widgets/locale_picker.dart';

const _openSubtitlesSignupUrl = 'https://www.opensubtitles.com/en/signup';

const _iso6392To6391 = {
  'afr': 'af',
  'alb': 'sq',
  'amh': 'am',
  'ara': 'ar',
  'arm': 'hy',
  'aze': 'az',
  'baq': 'eu',
  'bel': 'be',
  'ben': 'bn',
  'bos': 'bs',
  'bul': 'bg',
  'bur': 'my',
  'cat': 'ca',
  'che': 'ce',
  'zho': 'zh',
  'hrv': 'hr',
  'cze': 'cs',
  'dan': 'da',
  'div': 'dv',
  'dut': 'nl',
  'dzo': 'dz',
  'eng': 'en',
  'est': 'et',
  'fao': 'fo',
  'fij': 'fj',
  'fin': 'fi',
  'fre': 'fr',
  'glg': 'gl',
  'geo': 'ka',
  'ger': 'de',
  'ell': 'el',
  'grn': 'gn',
  'guj': 'gu',
  'hat': 'ht',
  'hau': 'ha',
  'heb': 'he',
  'hin': 'hi',
  'hun': 'hu',
  'ice': 'is',
  'ind': 'id',
  'gle': 'ga',
  'ita': 'it',
  'jpn': 'ja',
  'jav': 'jv',
  'kan': 'kn',
  'kaz': 'kk',
  'khm': 'km',
  'kor': 'ko',
  'kur': 'ku',
  'kir': 'ky',
  'lao': 'lo',
  'lat': 'la',
  'lav': 'lv',
  'lit': 'lt',
  'mkd': 'mk',
  'may': 'ms',
  'mal': 'ml',
  'mlt': 'mt',
  'mar': 'mr',
  'mon': 'mn',
  'nep': 'ne',
  'nor': 'no',
  'oci': 'oc',
  'ori': 'or',
  'per': 'fa',
  'pol': 'pl',
  'por': 'pt',
  'pan': 'pa',
  'rum': 'ro',
  'rus': 'ru',
  'smo': 'sm',
  'srp': 'sr',
  'sna': 'sn',
  'snd': 'sd',
  'sin': 'si',
  'slk': 'sk',
  'slv': 'sl',
  'som': 'so',
  'spa': 'es',
  'swa': 'sw',
  'swe': 'sv',
  'tgl': 'tl',
  'tam': 'ta',
  'tat': 'tt',
  'tel': 'te',
  'tha': 'th',
  'tur': 'tr',
  'ukr': 'uk',
  'urd': 'ur',
  'uzb': 'uz',
  'vie': 'vi',
  'wel': 'cy',
  'fry': 'fy',
  'wol': 'wo',
  'yid': 'yi',
};

String _normalizeLangCode(String code) {
  final lower = code.toLowerCase();
  if (lower.length <= 3) return lower;
  final bcp47 = lower.split('-').first;
  if (bcp47.length == 2) return bcp47;
  return _iso6392To6391[bcp47] ?? bcp47;
}

final availableVoicesProvider =
    FutureProvider.autoDispose<List<Map<String, String>>>((ref) async {
      final tts = ref.watch(flutterTtsProvider);
      final language = ref.watch(settingsProvider).selectedLanguage;
      final raw = await tts.getVoices;
      if (raw is! List) return <Map<String, String>>[];
      final allVoices = raw
          .whereType<Map>()
          .map(
            (v) => v.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          )
          .toList();
      final filtered = allVoices.where((v) {
        final voiceLang = _normalizeLangCode(
          v['language'] ?? v['locale'] ?? '',
        );
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
  final _emailController = TextEditingController();
  bool _obscurePassword = true;
  String? _loginError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loginError = null);
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _loginError = AppLocalizations.of(context)!.pleaseEnterBoth);
      return;
    }
    final success = await ref
        .read(authProvider.notifier)
        .login(username, password);
    if (!success && mounted) {
      setState(() => _loginError = AppLocalizations.of(context)!.loginFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    if (_emailController.text != settings.myMemoryEmail) {
      _emailController.text = settings.myMemoryEmail;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- OpenSubtitles Account ---
          Text(
            l10n.openSubtitlesAccount,
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
                error: (_, _) => Text(l10n.errorCheckingAuth),
                data: (authState) {
                  if (authState.status == AuthStatus.authenticated) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.loggedInAs(authState.username ?? 'user'),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  ref.read(authProvider.notifier).logout(),
                              child: Text(
                                l10n.logout,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                        if (authState.accountInfo != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  authState.accountInfo!.summary,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: authState.accountInfo!.level == 'vip'
                                        ? Colors.amber
: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                              Semantics(
                                label: l10n.readAccountInfoAloud,
                                button: true,
                                child: IconButton(
                                  icon: const Icon(Icons.hearing, size: 18),
                                  tooltip: l10n.readAloud,
                                  onPressed: () => HelpReader.from(ref).read(
                                    '${l10n.loggedInAs(authState.username ?? 'user')}. '
                                    '${authState.accountInfo!.summary}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: l10n.username,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                      ),
                      if (_loginError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _loginError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _login,
                        child: Text(l10n.login),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          final url = Uri.parse(_openSubtitlesSignupUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(l10n.dontHaveAccount),
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
            l10n.speechConfiguration,
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
                      Text(l10n.speechRate),
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
                      Text(l10n.voicePitch),
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
                    onVoiceSelected: (voice) =>
                        notifier.setSelectedVoice(voice),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Test Voice ---
          Text(
            l10n.testVoice,
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
                    l10n.testVoiceDescription(
                      settings.speechRate.toStringAsFixed(2),
                      settings.pitch.toStringAsFixed(1),
                    ),
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
            l10n.testTranslatedVoice,
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
                    l10n.testTranslatedVoiceDescription(settings.selectedLanguage.toUpperCase()),
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

          // --- App Language ---
          Text(
            l10n.language,
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
                  Text(l10n.defaultLanguageLabel),
                  const SizedBox(height: 8),
                  LocalePicker(
                    value: settings.appLocale,
                    onChanged: (v) => notifier.setAppLocale(v),
                    locales: appLocales,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Translation & Language ---
          Text(
            l10n.translationAndLanguage,
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
                  Text(l10n.defaultTargetLanguage),
                  const SizedBox(height: 8),
                  LocalePicker(
                    value: settings.selectedLanguage,
                    onChanged: (v) => notifier.setSelectedLanguage(v),
                    locales: targetLanguageLocales,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.emailOptional,
                      hintText: l10n.emailHint,
                      border: const OutlineInputBorder(),
                      helperText: l10n.emailHelper,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => notifier.setMyMemoryEmail(value),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.translationProvider),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TranslationProviderType>(
                    initialValue: settings.selectedTranslationProvider,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: TranslationProviderType.auto,
                        child: Text(l10n.autoTryAll),
                      ),
                      DropdownMenuItem(
                        value: TranslationProviderType.azure,
                        child: Text(l10n.azure),
                      ),
                      DropdownMenuItem(
                        value: TranslationProviderType.myMemory,
                        child: Text(l10n.myMemory),
                      ),
                      DropdownMenuItem(
                        value: TranslationProviderType.apertium,
                        child: Text(l10n.apertium),
                      ),
                      DropdownMenuItem(
                        value: TranslationProviderType.libreTranslate,
                        child: Text(l10n.libreTranslate),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        notifier.setSelectedTranslationProvider(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Support ---
          Text(
            l10n.support,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(l10n.reportABug),
              subtitle: Text(l10n.reportABugSubtitle),
              trailing: const Icon(Icons.open_in_new),
              onTap: () async {
                final opened = await BugReportHelper().openBugReport();
                if (context.mounted && !opened) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.couldNotOpenBugReport)),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // --- Help ---
          Text(
            l10n.help,
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
                    children: [
                      Expanded(
                        child: Text(
                          l10n.subtitleProviders,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Semantics(
                        label: l10n.readSubtitleProvidersAloud,
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.hearing, size: 18),
                          tooltip: l10n.readAloud,
                          onPressed: () => HelpReader.from(ref).read(
                          l10n.helpProvidersAppDesc,
                        ),
                      ),
                    ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.helpProvidersDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.howDownloadsWork,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Semantics(
                        label: l10n.readHowDownloadsWorkAloud,
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.hearing, size: 18),
                          tooltip: l10n.readAloud,
                          onPressed: () => HelpReader.from(ref).read(
                            l10n.helpDownloadsFull,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.helpDownloadsDesc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.createOsAccount,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Semantics(
                        label: l10n.readAccountHelpAloud,
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.hearing, size: 18),
                          tooltip: l10n.readAloud,
                          onPressed: () => HelpReader.from(ref).read(
                            l10n.helpCreateAccountFull,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(_openSubtitlesSignupUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(l10n.openSignupPage),
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
    final l10n = AppLocalizations.of(context)!;
    final isPlaying = ref.watch(testVoicePlayingProvider);
    final voice = ref.watch(settingsProvider).selectedVoice;

    return isPlaying
        ? OutlinedButton.icon(
            onPressed: () => ref.read(testVoiceControllerProvider).stop(),
            icon: const Icon(Icons.stop),
            label: Text(l10n.stopSample),
          )
        : ElevatedButton.icon(
            onPressed: () => ref
                .read(testVoiceControllerProvider)
                .playSample(rate, pitch, voice: voice),
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.playSample),
          );
  }
}

class _TranslatedTestPreview extends ConsumerWidget {
  final String language;

  const _TranslatedTestPreview({required this.language});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final preview = ref.watch(translatedTestPreviewProvider(language));
    final theme = Theme.of(context);

    return preview.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l10n.translationError),
            content: SingleChildScrollView(child: Text(e.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.ok),
              ),
            ],
          ),
        ),
        child: Text(
          l10n.translationFailedTap,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
        ),
      ),
      data: (lines) {
        if (lines.isEmpty) {
          return Text(
            l10n.noTranslationsAvailable,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          );
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
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
    final l10n = AppLocalizations.of(context)!;
    final isPlaying = ref.watch(translatedTestPlayingProvider);
    final voice = ref.watch(settingsProvider).selectedVoice;

    return isPlaying
        ? OutlinedButton.icon(
            onPressed: () => ref.read(testVoiceControllerProvider).stop(),
            icon: const Icon(Icons.stop),
            label: Text(l10n.stopTranslatedSample),
          )
        : ElevatedButton.icon(
            onPressed: () => ref
                .read(testVoiceControllerProvider)
                .playTranslatedSample(rate, pitch, language, voice: voice),
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.playTranslatedSample),
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
    final l10n = AppLocalizations.of(context)!;
    final voicesAsync = ref.watch(availableVoicesProvider);

    return voicesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(
        l10n.couldNotLoadVoices(e.toString()),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.orange),
      ),
      data: (voices) {
        if (voices.isEmpty) {
          return Text(
            l10n.noVoicesAvailable(language.toUpperCase()),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          );
        }
        final validValue = voices.any((v) => v['name'] == selectedVoice)
            ? selectedVoice
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.voice),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: validValue,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: voices
                  .map(
                    (v) => DropdownMenuItem(
                      value: v['name'],
                      child: Text(v['name'] ?? l10n.unknownVoice),
                    ),
                  )
                  .toList(),
              onChanged: onVoiceSelected,
            ),
          ],
        );
      },
    );
  }
}
