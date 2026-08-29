%{
  title: "Tempering a Test Suite",
  description: "Flaky tests are defects, not background noise. What a week of evidence from a production Elixir umbrella surfaced, and the ExUnit formatter I built to collect it.",
  tags: ~w(elixir testing exunit)
}
---
Before steel becomes a spring, a blade, or a structural bolt, it goes through a strange ritual. Freshly quenched steel is extremely hard, but that hardness comes with a hidden cost: internal stresses locked into the metal make it brittle. A brittle part does not fail every time you load it. It works, and works, and then one day, under a load it has survived a hundred times before, it cracks.

The cure is called tempering: reheating the steel to a controlled temperature and letting the internal stresses relax. You trade a little hardness for something more valuable, predictability. A tempered part still fails if you abuse it, but it fails honestly, the same way every time.

Test suites accumulate the same kind of hidden stress. A test that passes and fails without the code changing is the brittle steel of your suite: it holds, and holds, and then cracks under a load it has survived a hundred times. We call these tests flaky, and I built [Temper](https://github.com/volcov/temper) to find them. This post is about why they matter more than their reputation suggests, and what we found when we pointed Temper at our own production CI.

### What a flaky test is actually telling you

The definition is narrow and worth being precise about: a flaky test is one that produces different outcomes on the same code. Same test, same commit, one run green, another run red.

That is not noise. Something in the test's world is not pinned down: a race between processes, state leaking from a previous test, an assumption about time or ordering that is usually true. The test is reporting a real nondeterminism, it is just reporting it intermittently and without an explanation.

The common response is to retry. Run it again, it goes green, merge. And this is where flaky tests do their real damage, because a flaky failure is a false alarm about your code, and a blind retry converts it into a false pass. Both directions erode the same thing: your trust in the suite.

### The cost is mostly invisible

The visible cost is CI time. A flaky failure means a rerun, and a rerun means the whole pipeline again: queue, compile, test. On a big suite that is easily twenty minutes per incident, multiplied by every developer who hits it.

The invisible cost is worse. A suite that cries wolf trains people to ignore red. Once "it's probably just that test again" enters the team vocabulary, a genuinely broken build can sail through on a rerun, and the suite has quietly stopped doing its one job. None of this happens overnight: trust erodes one shrugged-off red build at a time, until nobody quite believes the tests anymore.

The retry-and-forget culture treats all of this as an unavoidable cost of a large suite. It is not. A flaky test is a defect like any other, with a location, a cause, and a fix. What is usually missing is the evidence: which tests, how often, under what conditions.

### A week of evidence from a real codebase

Temper's approach to gathering that evidence is deliberately boring. It is a passive ExUnit formatter: every `mix test` run you were already doing appends each test's outcome to a local history file, tagged with the git SHA and the seed. No retries, no re-runs, zero added test time. When a test has both passed and failed on the same clean SHA, the code did not change but the outcome did, and the report flags it.

We dogfooded this on the production system I work on, an 18-app Elixir umbrella, by simply letting history accumulate while the team worked. In the first week it surfaced more than five flaky tests that had been hiding in the suite, passing and failing quietly without anyone tracking them.

One of them is a nice illustration of how subtle these defects are.

The report flagged a test for a financial-signals algorithm: four runs on the same SHA, two passed, two failed, a 50% flake rate, with the two failing seeds listed. The test asserted that a computed percentage goes up after new records arrive. The root cause took some digging: the algorithm's denominator came from the *latest* record's holdings field, and the test's data helper randomized that field, multiplying a base volume by a value drawn from `[3, 5, 10]`. Draw a 3 or a 5 and the updated percentage rises as expected. Draw a 10 and the denominator grows enough to sink the percentage below the baseline, flipping the assertion.

So the test was not wrong about the algorithm, and the algorithm was not broken. The test's own fixture was rolling dice, and one face of the die contradicted the assertion. That is exactly the kind of defect a stack trace will never explain: any single failure looks like a mystery, and only the pattern across runs (with seeds you can replay) makes it tractable.

The fix was two lines: the data helper gained an option to pin the multiplier, and the test pins it. Both previously failing seeds now pass, and Temper's own history shows the before-and-after on identical seeds, which is a satisfying way to close the loop: the same evidence that caught the flake proves the fix.

Then the same test flaked again. The new failing seeds pointed at a different mechanism: the scenario created two sale records sharing the same date, and the algorithm read its denominator from whichever of the tied rows the database returned first. Nothing ordered the tie, so the outcome depended on row order the database never promised. The fix was the same idea as before, making the fixture deterministic: pin the holdings on both tied rows so the assertion holds no matter which row wins. One test, two independent sources of nondeterminism, each invisible until the recorded seeds isolated it.

The other catches followed classic archetypes. A test for a cache-warming GenServer swapped in a fresh stub while the initial warm was still running in the background; the refresh it then triggered joined the in-flight warm and never hit the new stub, so the assertion raced the warmer. Another leaned on wall-clock time. Different causes, same signature in the history: divergent outcomes on an unchanged SHA.

### Detection you can trust

A few design choices matter here, because a flakiness report is only useful if you believe it.

Temper only flags divergence on the *same clean git SHA*. A test that fails on one commit and passes on the next is a fix or a break, not a flake, so it deliberately does not count. Divergence involving dirty-working-tree runs is reported separately as a "suspect" with lower confidence, because uncommitted changes could explain it. And a consistently failing test is never flagged at all: that is a broken test, a different problem with a different fix. The bias throughout is zero false positives over recall. A report that cries wolf would recreate the exact trust problem it is meant to solve.

### Trying it on your suite

Setup is two lines:

```elixir
# mix.exs
{:temper, "~> 0.2", only: [:dev, :test], runtime: false}
```

```elixir
# test/test_helper.exs
ExUnit.start(formatters: [ExUnit.CLIFormatter, Temper.Formatter])
```

Add `.temper/` to your `.gitignore`, run your tests as usual, and once a few runs accumulate:

```
$ mix temper.report
Flaky tests (divergent outcomes on same git SHA):

  MyApp.UserTest test creates user with valid attrs
    test/my_app/user_test.exs:42  async: true
    12 runs on a1b2c3d: 10 passed / 2 failed (16.7% flake rate)
    failing seeds: 493821, 110394
```

`mix temper.doctor` checks the setup problems that would otherwise fail silently, and the [README](https://github.com/volcov/temper) covers CI persistence, partitioned jobs, and umbrella projects.

Tempering steel does not make it unbreakable. It makes it honest: a tempered part fails predictably, under loads you can reason about. That is all I want from a test suite, and it turns out the first step is simply keeping the evidence. Your suite is already generating it on every run; Temper just writes it down.

If you try it, I would love to hear what it finds: the [forum thread](https://forum.elixirforum.com/t/temper-flaky-test-detection-for-exunit/76476) is the best place, and issues and PRs are very welcome.
