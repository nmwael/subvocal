import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Opencode Configuration Validation', () {
    late Map<String, dynamic> config;

    setUp(() async {
      final file = File('opencode.json');
      expect(file.existsSync(), true, reason: 'opencode.json not found');
      final String contents = await file.readAsString();
      config = jsonDecode(contents);
    });

    test('provider.google.options.baseURL is correct', () {
      final baseUrl = config['provider']['google']['options']['baseURL'] as String;
      expect(baseUrl, equals('https://generativelanguage.googleapis.com/v1beta'));
    });

    test('subagent_depth allows one level of nested subagents', () {
      final depth = config['subagent_depth'] as int;
      expect(depth, greaterThanOrEqualTo(2),
          reason: 'architect (depth 1) must be able to spawn developer (depth 2)');
    });

    test('agent.architect.mode is all (invocable as subagent)', () {
      final mode = config['agent']['architect']['mode'] as String;
      expect(mode, equals('all'),
          reason: 'architect must be mode=all so it can be invoked via the Task tool');
    });

    test('agent.architect.model is google/gemini-3.5-flash-lite', () {
      final model = config['agent']['architect']['model'] as String;
      expect(model, equals('google/gemini-3.5-flash-lite'));
    });

    test('agent.developer.model is google/gemini-3.5-flash-lite', () {
      final model = config['agent']['developer']['model'] as String;
      expect(model, equals('google/gemini-3.5-flash-lite'));
    });

    test('agent.tester.model is google/gemini-3.5-flash-lite', () {
      final model = config['agent']['tester']['model'] as String;
      expect(model, equals('google/gemini-3.5-flash-lite'));
    });

    test('agent.security-auditor.model is google/gemini-3.5-flash-lite', () {
      final model = config['agent']['security-auditor']['model'] as String;
      expect(model, equals('google/gemini-3.5-flash-lite'));
    });

    test('agent.ux-ui.model is google/gemini-3.5-flash-lite', () {
      final model = config['agent']['ux-ui']['model'] as String;
      expect(model, equals('google/gemini-3.5-flash-lite'));
    });

    test('no agent.*.model contains groq/', () {
      final agents = config['agent'] as Map<String, dynamic>;
      agents.forEach((key, agent) {
        if (agent is Map && agent.containsKey('model')) {
          final model = agent['model'] as String;
          expect(model, equals('google/gemini-3.5-flash-lite'),
              reason: 'Agent $key model should be google/gemini-3.5-flash-lite, got $model');
          expect(model, isNot(contains('groq/')),
              reason: 'Agent $key model should not contain groq/');
        }
      });
    });

    test('agent.architect.description mentions orchestrator/delegation via Task tool', () {
      final description = config['agent']['architect']['prompt'] as String?;
      // The issue says: "agent config should describe it as delegating to subagents via the Task tool"
      // We'll check that the prompt contains either "Task" or "delegat" (case insensitive)
      expect(description, isNotNull, reason: 'architect prompt is missing');
      final lowerDesc = description!.toLowerCase();
      expect(lowerDesc, contains('task'), reason: 'architect prompt should mention Task tool for delegation');
      expect(lowerDesc, contains('delegat'), reason: 'architect prompt should mention delegation');
    });

    test('agent.architect has explicit task permission to invoke subagents', () {
      final permission = config['agent']['architect']['permission'] as Map<String, dynamic>;
      expect(permission['task'], equals('allow'),
          reason: 'architect must have explicit task:allow so the Task tool is not stripped from it');
    });
  });
}
