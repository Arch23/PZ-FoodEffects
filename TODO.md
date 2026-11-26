# TODO

## Research

- [ ] Milestone 4: run separately enabled consumption/nutrition, capacity read-only, moodle exposure, and synthetic persistence/transport probes in disposable SP and hosted/standalone MP; capture environment, debug/admin settings, and exact diagnostic revision.
- [x] Compare player and food nutrient snapshots for quarter/half/remainder and interrupted food actions in one SP test; standalone dedicated MP, zero-progress cancellation, and broader food coverage remain open.
- [x] Compare player and food nutrient snapshots in one hosted MP test and retest the guarded server job-progress lookup; standalone dedicated MP, zero-progress cancellation, and broader coverage remain open.
- [ ] Run the explicitly enabled, immediate-restore carrying-capacity setter probe on a disposable character; inspect later vanilla updates, save/load, reconnect, restart, removal, and third-party-mod interaction before judging any production lifecycle safe.
- [ ] Investigate native moodle registration exposure, timing, level, rendering, icons, and dynamic tooltips; do not register an unverified type in the candidate.
- [x] Inspect native MoodleType, per-character map, level computation and tooltip-key bodies; registry timing, icon resolution and extension viability remain open.
- [x] Inspect native MoodleTextureSet and registry method bodies; exact initialization timing and third-party extension viability remain open.
- [ ] Review the redacted `diagnostic-logs/` working copies before sharing and decide how to handle unsanitized logs already present in Git history. Raw copies remain locally in ignored `diagnostic-logs-private/`; do not commit them or additional unsanitized logs.
- [x] Establish local-install evidence for item nutrition, evolved recipes, tags, and eating action.
- [x] Run the isolated `FoodEffectsDiagnostics` mod in SP and hosted MP and capture initial food and fluid observations. A standalone dedicated server and comprehensive coverage remain untested.
- [ ] Identify and prove a server-authoritative post-consumption hook that covers food, partial food consumption, fluid drinking, and evolved meals in SP and dedicated MP. Do not use `EventEating` or these diagnostic wrappers as a production interception point without that evidence.
- [x] Establish a local bytecode inspection tool: CFR 0.152 runs on the bundled Java 25 runtime. Inspect capacity, consumption/nutrition and moodle method bodies next.
- [x] Inspect initial `IsoPlayer` capacity accessors, `IsoGameCharacter.Eat`, and `Nutrition` setters; cross-class capacity calculation, serialization/network paths and moodle lifecycle remain open.
- [x] Locate `BodyDamage.UpdateStrength` capacity calculation and `PlayerDamagePacket` effective-weight field; complete packet direction/timing, save/load, execution-side and mod-interaction investigation remains open.
- [x] Trace the server's periodic damage-sync caller and inspect player/character byte-buffer save methods; superclass/component serialization and live behavior remain open.
- [ ] Complete and runtime-test the guarded delayed capacity probe, including post-restoration observation, interruption/conflict handling and accessible controls; the current draft is unverified.
- [ ] Runtime-verify the diagnostic world context menu and design an independently guarded server-side capacity test control; currently mutation is exposed only in SP.
- [x] Trace server disconnect save/removal ordering and prepare a separately enabled capability-guarded server probe; runtime authorization and cleanup behavior remain unverified.
- [ ] Evaluate optional custom-moodle dependencies for installed build, compatibility, maintenance and license; human is open to a dependency but has not selected one.
- [x] Review source-available Build 42 custom-moodle project descriptions; both identified projects describe replacement rendering, while compatibility and code-level details remain unverified.
- [ ] Test whether custom moodle types can be registered; otherwise assess a minimal client UI/notification route with dynamic remaining duration.
- [ ] Verify evolved-recipe nutrient aggregation and preservation of ingredient provenance.

## Architecture

- [x] Draft a conditional authoritative effect-record architecture, expiry clock, replication plan, migration/removal behavior, and duplicate-application guard. It remains blocked on consumption, player persistence/replication, and stat-surface verification.
- [ ] Define third-party compatibility schema based on nutrition/properties/tags, with opt-in overrides only where necessary.

## Implementation

- [ ] Blocked pending verification and human review of the consumption path, effect targets, persistence/replication, and presentation. Duration stacking is approved; balance numbers and stat targets are not.

## Testing

- [x] Document SP and dedicated-server test matrix: partial eating, drinking, evolved meals, reconnect, save/load, expiry, and mod removal/reinstall.
- [ ] Complete the test matrix: immediate cancellation without consumption, evolved meals, legacy bottles, standalone dedicated MP, third-party foods, and nutrition actually applied to the player.

## Compatibility

- [ ] Test nutrition-bearing third-party foods and malformed/missing custom data.
- [ ] Verify the diagnostic namespaced record through save/load, reconnect, server restart, client synchronization, malformed-data recovery, and mod removal/reinstallation using disposable saves.
- [x] Add shared schema and bounded integer validation for synthetic diagnostic counters; malformed-record runtime verification remains open.
- [x] Verify corrected diagnostic mod discovery and loading on the hosted server and client; the previous root-only candidate did not appear in the Mods menu.
- [ ] Extend validation of action correlation, cancellation arguments, fluid snapshots, and record-before logging beyond the observed SP and hosted MP cases. Correlation IDs are process-local, not proven transaction identities.
- [x] Retest the guarded job-progress lookup in SP and hosted MP; available progress was logged and the previously observed error pattern was absent in those captures.

## Future features

- [ ] Do not start preferences, fatigue, freshness bonuses, overeating, or food poisoning without approval.
