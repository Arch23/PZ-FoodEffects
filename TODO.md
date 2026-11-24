# TODO

## Research

- [x] Establish local-install evidence for item nutrition, evolved recipes, tags, and eating action.
- [ ] Identify and prove a server-authoritative post-consumption hook that covers food, partial food consumption, fluid drinking, and evolved meals in SP and dedicated MP. Do not use `EventEating`, action replacement, or `IsoPlayer:Eat` interception without that evidence.
- [ ] Inspect/decompile Build 42 Java interfaces only as needed to verify vitamins, moodles, stats, item tags, and persistence APIs.
- [ ] Test whether custom moodle types can be registered; otherwise assess a minimal client UI/notification route with dynamic remaining duration.
- [ ] Verify evolved-recipe nutrient aggregation and preservation of ingredient provenance.

## Architecture

- [x] Draft a conditional authoritative effect-record architecture, expiry clock, replication plan, migration/removal behavior, and duplicate-application guard. It remains blocked on consumption, player persistence/replication, and stat-surface verification.
- [ ] Define third-party compatibility schema based on nutrition/properties/tags, with opt-in overrides only where necessary.

## Implementation

- [ ] Blocked pending verification and human review of the consumption path, effect targets, persistence/replication, and presentation. Duration stacking is approved; balance numbers and stat targets are not.

## Testing

- [ ] Create SP and dedicated-server test matrix: partial eating, drinking, evolved meals, reconnect, save/load, expiry, and mod removal/reinstall.

## Compatibility

- [ ] Test nutrition-bearing third-party foods and malformed/missing custom data.
- [ ] Verify the loader contract in-game with a no-gameplay diagnostic mod before adding runtime modules; static local templates establish only the folder and `mod.info` shape.

## Future features

- [ ] Do not start preferences, fatigue, freshness bonuses, overeating, or food poisoning without approval.
