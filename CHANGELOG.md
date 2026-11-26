# Changelog

## Unreleased

- Replaced tracked diagnostic log working copies with diagnostic-only, name-redacted extracts; original local copies are retained in the Git-ignored `diagnostic-logs-private/` directory. Earlier commits still contain the unsanitized files.
- Added separately disabled diagnostic experiment switches, player-nutrition snapshots, reduced unchanged fluid logging, synthetic persistence/transport probes, and read-only capacity/moodle preflight; runtime validation remains pending. Capacity mutation and moodle registration remain blocked pending safety and API evidence.
- Added project documentation and initial local Build 42 research records.
- Recorded approved temporary-effect scope, per-effect additive duration stacking with configurable caps, dietary-variety direction, Cooking-quality goal, and deferrals.
- Extended local Build 42 research and added a conditional, non-implementation architecture proposal.
- Recorded local Build 42.22.2 / `3d39148846` environment evidence, Steam `pre-release` branch, bundled Java 25.0.5, and dedicated-server launcher availability.
- Added the isolated `FoodEffectsDiagnostics` experimental mod. It logs shared/client/server loading and source-evidenced food, legacy-bottle, and fluid timed-action observation points, and writes only a namespaced diagnostic test record on non-client observation.
- Reorganized the diagnostic candidate into a Build 42 versioned folder after the original layout did not appear in the Mods menu; subsequent SP and hosted MP runs loaded it.
- Expanded diagnostic logs with process-local action correlation, nesting, cancellation arguments and progress, fluid amount/ratio, and previous test-record fields before replacement.
- Guarded the diagnostic job-progress lookup when the underlying local timed action is absent, avoiding the repeated server-side `getJobDelta` error seen in multiplayer logs.
- Documented human-run SP and hosted MP observations of partial and interrupted food consumption, removed-item NaN values, incremental fluids, and a prior diagnostic record observed after a server restart; comprehensive validation remains open.
- Updated the conditional architecture to use separate consumption adapters and a shared validation/deduplication/effect pipeline; absolute world-age offline expiry remains proposed, not approved.
- No production gameplay mechanics, production save data, multiplayer behavior, or vanilla files changed. The diagnostic candidate may write only its isolated test record when a human runs it.
