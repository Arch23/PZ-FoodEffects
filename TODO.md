# TODO

## Research

- [x] Establish local-install evidence for item nutrition, evolved recipes, tags, and eating action.
- [x] Run the isolated `FoodEffectsDiagnostics` mod in SP and hosted MP and capture initial food and fluid observations. A standalone dedicated server and comprehensive coverage remain untested.
- [ ] Identify and prove a server-authoritative post-consumption hook that covers food, partial food consumption, fluid drinking, and evolved meals in SP and dedicated MP. Do not use `EventEating` or these diagnostic wrappers as a production interception point without that evidence.
- [ ] Inspect/decompile Build 42 Java interfaces only as needed to verify vitamins, moodles, stats, item tags, and persistence APIs.
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
- [x] Verify corrected diagnostic mod discovery and loading on the hosted server and client; the previous root-only candidate did not appear in the Mods menu.
- [ ] Extend validation of action correlation, cancellation arguments, fluid snapshots, and record-before logging beyond the observed SP and hosted MP cases. Correlation IDs are process-local, not proven transaction identities.
- [ ] Retest the guarded job-progress lookup on hosted MP; SP logged progress without the previously observed error, but the server path has not been retested after the fix.

## Future features

- [ ] Do not start preferences, fatigue, freshness bonuses, overeating, or food poisoning without approval.
