import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/domain/errors/failures.dart';
import 'package:subvocal/data/datasources/subdl_api.dart';

import '../helpers/subdl_test_helpers.dart';

void main() {
  const apiKey = 'test-api-key';

  group('SubdlApi.search', () {
    test('returns results on successful search', () async {
      final client = MockHttpClient(
        body: {
          'status': true,
          'subtitles': [
            {
              'release_name': 'Test.Movie.2020.1080p',
              'name': 'Test.Movie.2020.1080p.zip',
              'language': 'EN',
              'season': 0,
              'episode': null,
              'url': '/subtitle/12345-67890.zip',
              'unpack_files': [
                {'url': '/subtitle/abc123/file.srt', 'format': 'srt'},
              ],
            },
          ],
        },
      );
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data!.length, 1);
      expect(data[0].fileId, '/subtitle/abc123/file.srt');
      expect(data[0].providerSource, 'SubDL');
    });

    test('returns empty list when no subtitles found', () async {
      final client = MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('nonexistent');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data, isEmpty);
    });

    test('returns empty list when subtitles field is null', () async {
      final client = MockHttpClient(body: {'status': true, 'subtitles': null});
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data, isEmpty);
    });

    test('returns NetworkFailure on 429 rate limit', () async {
      final client = MockHttpClient(statusCode: 429);
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Rate limit exceeded'));
    });

    test('returns NetworkFailure on 500 server error', () async {
      final client = MockHttpClient(statusCode: 500);
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('500'));
    });

    test('returns NetworkFailure on socket exception', () async {
      final client = MockHttpClient(
        error: const SocketException('Connection refused'),
      );
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No internet connection'));
    });

    test('sends api_key as query parameter', () async {
      final client = MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['api_key'], apiKey);
    });

    test('sends film_name as query parameter', () async {
      final client = MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('matrix');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['film_name'], 'matrix');
    });

    test('sends language parameter uppercased when provided', () async {
      final client = MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test', language: 'en');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['languages'], 'EN');
    });

    test('sends type parameter when provided', () async {
      final client = MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test', type: 'movie');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['type'], 'movie');
    });

    test('does not send type when value is all', () async {
      final client = MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test', type: 'all');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters.containsKey('type'), isFalse);
    });
  });

  group('SubdlApi.download', () {
    test('returns download URL using fileId as path', () async {
      final client = MockHttpClient();
      final api = SubdlApi(client, apiKey);

      final (link, failure) = await api.download('/subtitle/abc123/file.srt');

      expect(failure, isNull);
      expect(link, 'https://dl.subdl.com/subtitle/abc123/file.srt');
    });

    test('returns NetworkFailure when fileId is empty', () async {
      final client = MockHttpClient();
      final api = SubdlApi(client, apiKey);

      final (link, failure) = await api.download('');

      expect(link, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No download URL'));
    });
  });

  group('SubdlApi.fetchContent', () {
    test('returns content on success', () async {
      final client = MockHttpClient(
        body: {'data': 'subtitle content'},
        statusCode: 200,
      );
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/file.srt',
      );

      expect(failure, isNull);
      expect(content, isNotNull);
    });

    test('passes through non-zip content unchanged', () async {
      const srt = '1\n00:00:01,000 --> 00:00:04,000\nPlain srt content';
      final client = MockHttpClient(bytes: utf8.encode(srt));
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/file.srt',
      );

      expect(failure, isNull);
      expect(content, srt);
    });

    test('extracts srt text from a zip payload', () async {
      const srt = '1\n00:00:01,000 --> 00:00:04,000\nHello from zip';
      final client = MockHttpClient(bytes: zipBytesWithSrt(srt));
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/subtitle/12345.zip',
      );

      expect(failure, isNull);
      expect(content, srt);
    });

    test('extracts a .sub file from a zip payload', () async {
      const sub = '1\n00:00:01,000 --> 00:00:04,000\nSub file content';
      final client = MockHttpClient(
        bytes: zipBytesWithSrt(sub, filename: 'movie.sub'),
      );
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/subtitle/12345.zip',
      );

      expect(failure, isNull);
      expect(content, sub);
    });

    test(
      'extracts the srt file even when it is not first in the zip',
      () async {
        const srt = '1\n00:00:01,000 --> 00:00:04,000\nSecond file wins';
        final client = MockHttpClient(
          bytes: zipBytesWithFiles({'movie.nfo': 'metadata', 'movie.srt': srt}),
        );
        final api = SubdlApi(client, apiKey);

        final (content, failure) = await api.fetchContent(
          'https://dl.subdl.com/subtitle/12345.zip',
        );

        expect(failure, isNull);
        expect(content, srt);
      },
    );

    test(
      'search result with only a zip url downloads and unzips successfully',
      () async {
        const srt = '1\n00:00:01,000 --> 00:00:04,000\nZipped fallback';
        final client = MockHttpClient(
          responses: [
            // 1st request: search returns a result with only a zip url.
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
            // 2nd request: the zip download itself.
            MockResponse(zipBytesWithSrt(srt)),
          ],
        );
        final api = SubdlApi(client, apiKey);

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
      },
    );

    test('returns NetworkFailure on 429 rate limit', () async {
      final client = MockHttpClient(statusCode: 429);
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/file.srt',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Rate limit exceeded'));
    });

    test('returns NetworkFailure on server error', () async {
      final client = MockHttpClient(statusCode: 500);
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/file.srt',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('500'));
    });

    test('returns NetworkFailure on socket exception', () async {
      final client = MockHttpClient(
        error: const SocketException('Connection refused'),
      );
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/file.srt',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No internet connection'));
    });

    test('rejects a download whose compressed body exceeds 10 MB', () async {
      // A ZIP-prefixed payload larger than the compressed cap (zip-bomb
      // defense, CWE-409). Starts with the PK\x03\x04 magic so only the size
      // guard can reject it.
      final bigBytes = List<int>.filled(10 * 1024 * 1024 + 1, 0)
        ..[0] = 0x50
        ..[1] = 0x4B
        ..[2] = 0x03
        ..[3] = 0x04;
      final client = MockHttpClient(bytes: bigBytes);
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/subtitle/bomb.zip',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Subtitle download too large'));
    });

    test('rejects an archive with more than 20 files', () async {
      final manyFiles = Map.fromEntries(
        List.generate(21, (i) => MapEntry('file$i.txt', 'content $i')),
      );
      final client = MockHttpClient(bytes: zipBytesWithFiles(manyFiles));
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/subtitle/many.zip',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Subtitle archive has too many files'));
    });

    test('rejects an archive containing a file larger than 5 MB', () async {
      // A single highly-compressible 5 MB+ file: well under the 10 MB
      // compressed cap, but its decompressed size must trip the per-file cap.
      final bigFile = zipBytesWithFiles({
        'movie.srt': 'a' * (5 * 1024 * 1024 + 1),
      });
      final client = MockHttpClient(bytes: bigFile);
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/subtitle/bigfile.zip',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Subtitle file too large'));
    });

    test('rejects a single highly-compressed entry whose declared '
        'uncompressed size exceeds the cap', () async {
      // A zip-bomb signature: a tiny compressed payload whose zip header
      // *declares* a huge uncompressed size. The guard must trip on the
      // declared size read from the central directory before the content
      // is ever decompressed into memory (CWE-409).
      final archive = Archive();
      archive.addFile(
        ArchiveFile(
          'movie.srt',
          5 * 1024 * 1024 + 1, // declared uncompressed size in header
          utf8.encode('tiny'),
        ),
      );
      final client = MockHttpClient(bytes: ZipEncoder().encode(archive));
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/subtitle/declared-bomb.zip',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Subtitle file too large'));
    });

    test(
      'rejects an archive whose total decompressed size exceeds 20 MB',
      () async {
        // Five 4.5 MB files: each under the per-file cap, but the total
        // decompressed size must trip the aggregate cap.
        final contents = <String, String>{};
        for (var i = 0; i < 5; i++) {
          contents['part$i.srt'] = 'a' * (4 * 1024 * 1024 + 512 * 1024);
        }
        final client = MockHttpClient(bytes: zipBytesWithFiles(contents));
        final api = SubdlApi(client, apiKey);

        final (content, failure) = await api.fetchContent(
          'https://dl.subdl.com/subtitle/bomb.zip',
        );

        expect(content, isNull);
        expect(failure, isA<NetworkFailure>());
        expect(failure!.message, contains('Subtitle archive too large'));
      },
    );

    test(
      'returns empty content when the zip has no .srt or .sub file',
      () async {
        final client = MockHttpClient(
          bytes: zipBytesWithFiles({'movie.nfo': 'metadata'}),
        );
        final api = SubdlApi(client, apiKey);

        final (content, failure) = await api.fetchContent(
          'https://dl.subdl.com/subtitle/nosub.zip',
        );

        expect(failure, isNull);
        expect(content, isEmpty);
      },
    );
  });

  group('SubdlSearchResultModel', () {
    test('parses JSON correctly with unpack_files', () {
      final json = {
        'release_name': 'Test.Movie.2020.1080p',
        'name': 'Test.Movie.2020.1080p.zip',
        'language': 'EN',
        'season': 1,
        'episode': 5,
        'url': '/subtitle/12345-67890.zip',
        'unpack_files': [
          {'url': '/subtitle/abc123/file.srt', 'format': 'srt'},
        ],
      };
      final model = SubdlSearchResultModel.fromJson(json);

      expect(model.fileId, '/subtitle/abc123/file.srt');
      expect(model.language, 'EN');
      expect(model.releaseName, 'Test.Movie.2020.1080p');
      expect(model.season, 1);
      expect(model.episode, 5);
    });

    test('prefers the srt unpack_file over the zip url', () {
      final json = {
        'release_name': 'Test.Movie.2020.1080p',
        'name': 'Test.Movie.2020.1080p.zip',
        'url': '/subtitle/12345-67890.zip',
        'unpack_files': [
          {'url': '/subtitle/abc123/file1.eng.srt', 'format': 'srt'},
          {'url': '/subtitle/abc123/file1.eng.sub', 'format': 'sub'},
          {'url': '/subtitle/abc123/file1.nfo', 'format': 'nfo'},
        ],
      };
      final model = SubdlSearchResultModel.fromJson(json);

      expect(model.fileId, '/subtitle/abc123/file1.eng.srt');
    });

    test('prefers an srt unpack_file even when it is not first', () {
      final json = {
        'name': 'Test.Movie.2020.1080p.zip',
        'url': '/subtitle/12345-67890.zip',
        'unpack_files': [
          {'url': '/subtitle/abc123/file.nfo', 'format': 'nfo'},
          {'url': '/subtitle/abc123/file.sub', 'format': 'sub'},
          {'url': '/subtitle/abc123/file.srt', 'format': 'srt'},
        ],
      };
      final model = SubdlSearchResultModel.fromJson(json);

      expect(model.fileId, '/subtitle/abc123/file.srt');
    });

    test(
      'prefers an unpack_file whose url ends in .srt when format is absent',
      () {
        final json = {
          'name': 'Test.Movie.2020.1080p.zip',
          'url': '/subtitle/12345-67890.zip',
          'unpack_files': [
            {'url': '/subtitle/abc123/movie.srt'},
          ],
        };
        final model = SubdlSearchResultModel.fromJson(json);

        expect(model.fileId, '/subtitle/abc123/movie.srt');
      },
    );

    test(
      'falls back to the zip url when unpack_files exist but none are srt',
      () {
        final json = {
          'name': 'Test.Movie.2020.1080p.zip',
          'url': '/subtitle/12345-67890.zip',
          'unpack_files': [
            {'url': '/subtitle/abc123/file.sub', 'format': 'sub'},
            {'url': '/subtitle/abc123/file.nfo', 'format': 'nfo'},
          ],
        };
        final model = SubdlSearchResultModel.fromJson(json);

        expect(model.fileId, '/subtitle/12345-67890.zip');
      },
    );

    test('parses JSON without unpack_files falls back to url', () {
      final json = {'name': 'Test Movie', 'url': '/subtitle/12345-67890.zip'};
      final model = SubdlSearchResultModel.fromJson(json);

      expect(model.fileId, '/subtitle/12345-67890.zip');
      expect(model.language, isNull);
      expect(model.releaseName, isNull);
      expect(model.season, isNull);
      expect(model.episode, isNull);
    });

    test('handles empty unpack_files', () {
      final json = {
        'name': 'Test Movie',
        'url': '/subtitle/12345-67890.zip',
        'unpack_files': [],
      };
      final model = SubdlSearchResultModel.fromJson(json);

      expect(model.fileId, '/subtitle/12345-67890.zip');
    });

    test('skips malformed unpack_files entries instead of failing the whole '
        'search', () {
      final json = {
        'name': 'Test.Movie.2020.1080p.zip',
        'url': '/subtitle/12345-67890.zip',
        'unpack_files': [
          'not-a-map',
          42,
          {'url': 12345, 'format': 'srt'},
          {'url': '/subtitle/abc123/file.nfo', 'format': 7},
          {'url': '/subtitle/abc123/file.srt', 'format': 'srt'},
        ],
      };
      final model = SubdlSearchResultModel.fromJson(json);

      expect(model.fileId, '/subtitle/abc123/file.srt');
    });

    test(
      'falls back to the zip url when all unpack_files entries are malformed',
      () {
        final json = {
          'name': 'Test.Movie.2020.1080p.zip',
          'url': '/subtitle/12345-67890.zip',
          'unpack_files': [
            'not-a-map',
            {'url': 12345, 'format': 'srt'},
          ],
        };
        final model = SubdlSearchResultModel.fromJson(json);

        expect(model.fileId, '/subtitle/12345-67890.zip');
      },
    );

    test('toEntity maps correctly', () {
      final model = SubdlSearchResultModel(
        fileId: '/subtitle/abc123/file.srt',
        name: 'Test Movie',
        language: 'EN',
        releaseName: 'Test.Movie.2020.1080p',
        season: 1,
        episode: 5,
      );

      final entity = model.toEntity();

      expect(entity.fileId, '/subtitle/abc123/file.srt');
      expect(entity.title, 'Test Movie');
      expect(entity.language, 'EN');
      expect(entity.releaseName, 'Test.Movie.2020.1080p');
      expect(entity.providerSource, 'SubDL');
      expect(entity.season, 1);
      expect(entity.episode, 5);
    });
  });
}
