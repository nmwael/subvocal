# OBEY Test-Driven Development by Example (Kent Beck) + BDD

## When to use

Use for any behavior change, new feature, bug fix, or refactor. TDD shapes the
design as much as it validates it; BDD keeps the "what and why" of each behavior
readable by humans who are not reading code.

## Primary bias to correct

A feature is not "implemented, then tested". The test comes first, drives the
design, and fails until the behavior exists. Green-on-first-run means the test
was not really testing anything.

## Decision rules

- Cycle in small steps: RED (write a failing test) -> GREEN (minimal code to pass)
  -> REFACTOR (clean up with the suite green). Never skip the refactor stage.
- Write one failing test at a time. Fix one failure before adding the next test.
- Run the failing test before writing the implementation. A test that passes
  before the code exists is a test that tests nothing.
- Implement the minimal code that makes the test pass, even if it looks naive.
  Duplicated behavior is fine until a second test forces real generalization.
- Express behavior as Given/When/Then scenarios (BDD) for anything a stakeholder
  could describe: Given a precondition, When an action happens, Then an observable
  outcome. Keep scenarios at the business level, not the implementation level.
- Use unit tests for domain and data logic, widget tests for UI components, and
  integration tests for critical user flows. Match the test to the layer.
- Keep tests independent and deterministic: no shared mutable state, no reliance
  on timing, network, or order of execution. A test that fails randomly is worse
  than no test.
- Test one behavior per test with a descriptive name that states the expected
  outcome, not the mechanism. A name is a sentence: "parses a single subtitle entry".
- Assert on behavior, not implementation details. Prefer public outcomes
  (return values, observable state) over calls made or internal fields.
- When a bug is found, first write a failing test that reproduces it, then fix.
  The fix is complete only when that test (and the suite) passes.
- Refactor only with a green suite; the tests are the safety net that lets you
  restructure freely. After refactoring, re-run everything.
- Keep the test suite fast. Slow tests get skipped, then never run, then rot.
- Treat test code as production code: readable, small, expressive, free of
  duplication and copy-paste noise.

## Trigger rules

- When starting a new behavior, write the BDD scenario or unit test first and
  watch it fail (RED) before writing any implementation.
- When the implementation grows beyond the simplest expression of the passing
  test, refactor to remove duplication and reveal the real structure.
- When a scenario reads like implementation detail (variable names, method calls),
  rewrite it so a non-programmer could follow the story.
- When you find yourself writing a test that cannot fail, delete it or rewrite it.
- When a test requires setting up many unrelated objects, that is a design smell —
  consider a simpler seam, a builder, or a smaller unit.

## Final checklist

- Did every behavior ship with a failing test first (RED -> GREEN)?
- Are behaviors specified in plain-language Given/When/Then scenarios and exported
  to `test/features/generated/` for stakeholder review?
- Is the suite deterministic and independent of order, timing, and environment?
- Did `dart analyze`, `dart format`, and `./scripts/run-tests.sh --all` all pass?
- Does the last RED->GREEN->REFACTOR cycle end with the suite green and code clean?
