import 'package:bdd_framework/bdd_framework.dart';

/// Configures the BDD framework once for the entire test suite.
///
/// Call [configureBdd] at the top of a BDD test file's `main()` before any
/// BDD scenarios are defined. It is idempotent — safe to call from multiple
/// test files (each test file runs in its own isolate).
///
/// Registers a single [FeatureFileReporter] so every test run auto-exports
/// Gherkin `.feature` files to `test/features/generated/`.
///
/// IMPORTANT: Do NOT register a [ConsoleReporter] alongside the
/// [FeatureFileReporter]. bdd_framework 4.0.7 stores the same `BddFeature`
/// instance in every reporter, so multiple reporters cause each scenario to
/// be registered (and exported) twice. Console output is unaffected — the
/// framework already prints every scenario while tests run and prints the
/// results summary from `reportAll()`.
///
/// [clearOutput] deletes all previously generated feature files before the
/// current file exports its own. Defaults to `false` so multiple BDD files
/// accumulate their exports instead of clobbering each other.
void configureBdd({bool clearOutput = false}) {
  // Set the output directory for generated .feature files.
  FeatureFileReporter.dir = 'test/features/generated/';

  // Register reporters. Calling set() again replaces previous reporters,
  // so this is idempotent across test files.
  BddReporter.set(FeatureFileReporter(clearAllOutputBeforeRun: clearOutput));
}
