import 'dart:convert';

import 'package:bdd_framework/bdd_framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/data/datasources/subdl_api.dart';

import '../helpers/bdd_config.dart';
import '../helpers/subdl_test_helpers.dart';

void main() async {
  configureBdd(clearOutput: false);

  final feature = BddFeature(
    'SubDL ZIP subtitle extraction',
    description: '''
SubDL serves every subtitle download as a ZIP archive. The app must detect the
ZIP payload, extract the .srt/.sub file inside it, and return the decoded
subtitle text instead of decoding the binary bytes as text. Search results must
prefer a direct .srt unpack_file over the ZIP url.''',
  );

  Bdd(feature)
      .scenario('Fetching a ZIP download returns the SRT text inside it')
      .given('SubDL returns a ZIP archive containing an .srt file')
      .when('fetchContent is called on the ZIP download URL')
      .then('the SRT text is returned unchanged')
      .run((ctx) async {
        const srt = '1\n00:00:01,000 --> 00:00:04,000\nHello from zip';
        final client = MockHttpClient(bytes: zipBytesWithSrt(srt));
        final api = SubdlApi(client, 'test-api-key');

        final (content, failure) = await api.fetchContent(
          'https://dl.subdl.com/subtitle/12345.zip',
        );

        expect(failure, isNull);
        expect(content, srt);
      });

  Bdd(feature)
      .scenario('Fetching a ZIP download returns the SUB text inside it')
      .given('SubDL returns a ZIP archive containing a .sub file')
      .when('fetchContent is called on the ZIP download URL')
      .then('the SUB text is returned unchanged')
      .run((ctx) async {
        const sub = '1\n00:00:01,000 --> 00:00:04,000\nSub file content';
        final client = MockHttpClient(
          bytes: zipBytesWithSrt(sub, filename: 'movie.sub'),
        );
        final api = SubdlApi(client, 'test-api-key');

        final (content, failure) = await api.fetchContent(
          'https://dl.subdl.com/subtitle/12345.zip',
        );

        expect(failure, isNull);
        expect(content, sub);
      });

  Bdd(feature)
      .scenario('Search result with only a ZIP url downloads and unzips')
      .given('a search result whose unpack_files is absent and url is a .zip')
      .and('the ZIP download contains an .srt file')
      .when('the result is searched, downloaded, and fetched')
      .then('the SRT text inside the ZIP is returned')
      .run((ctx) async {
        const srt = '1\n00:00:01,000 --> 00:00:04,000\nZipped fallback';
        final client = MockHttpClient(
          responses: [
            MockResponse(
              utf8.encode(
                jsonEncode({
                  'status': true,
                  'subtitles': [
                    {
                      'name': 'Test.Movie.2020.1080p.zip',
                      'url': '/subtitle/12345-67890.zip',
                    },
                  ],
                }),
              ),
            ),
            MockResponse(zipBytesWithSrt(srt)),
          ],
        );
        final api = SubdlApi(client, 'test-api-key');

        final (results, searchFailure) = await api.search('test');
        expect(searchFailure, isNull);
        expect(results!.single.fileId, '/subtitle/12345-67890.zip');

        final (downloadUrl, downloadFailure) = await api.download(
          results.single.fileId,
        );
        expect(downloadFailure, isNull);

        final (content, fetchFailure) = await api.fetchContent(downloadUrl!);
        expect(fetchFailure, isNull);
        expect(content, srt);
      });

  Bdd(feature)
      .scenario('Search result prefers an srt unpack_file over the ZIP url')
      .given('a search result with several unpack_files and a .zip url')
      .and('an .srt unpack_file that is not the first entry')
      .when('the result JSON is parsed')
      .then('the .srt unpack_file url is used as the fileId')
      .run((ctx) async {
        final model = SubdlSearchResultModel.fromJson({
          'name': 'Test.Movie.2020.1080p.zip',
          'url': '/subtitle/12345-67890.zip',
          'unpack_files': [
            {'url': '/subtitle/abc123/file.nfo', 'format': 'nfo'},
            {'url': '/subtitle/abc123/file.sub', 'format': 'sub'},
            {'url': '/subtitle/abc123/file.srt', 'format': 'srt'},
          ],
        });

        expect(model.fileId, '/subtitle/abc123/file.srt');
      });

  Bdd(feature)
      .scenario('Fetching a plain SRT download passes through unchanged')
      .given('SubDL returns plain SRT text (not a ZIP)')
      .when('fetchContent is called')
      .then('the SRT text is returned unchanged')
      .run((ctx) async {
        const srt = '1\n00:00:01,000 --> 00:00:04,000\nPlain srt content';
        final client = MockHttpClient(bytes: utf8.encode(srt));
        final api = SubdlApi(client, 'test-api-key');

        final (content, failure) = await api.fetchContent(
          'https://dl.subdl.com/file.srt',
        );

        expect(failure, isNull);
        expect(content, srt);
      });

  await BddReporter.reportAll();
}
