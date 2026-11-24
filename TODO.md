# TODO

## Research

- [x] Establish local-install evidence for item nutrition, evolved recipes, tags, and eating action.
- [ ] Identify the server-authoritative post-consumption hook that covers all food paths; test it in SP and MP.
- [ ] Inspect/decompile Build 42 Java interfaces only as needed to verify vitamins, moodles, stats, item tags, and persistence APIs.
- [ ] Test whether custom moodle types can be registered; otherwise assess a minimal client UI/notification route.
- [ ] Verify evolved-recipe nutrient aggregation and preservation of ingredient provenance.

## Architecture

- [ ] Propose an authoritative effect record, expiry clock, replication plan, migration/removal behavior, and duplicate-application guard after research.
- [ ] Define third-party compatibility schema based on nutrition/properties/tags, with opt-in overrides only where necessary.

## Implementation

- [ ] Blocked pending approval of effect list, balance, stacking, and presentation.

## Testing

- [ ] Create SP and dedicated-server test matrix: partial eating, drinking, evolved meals, reconnect, save/load, expiry, and mod removal/reinstall.

## Compatibility

- [ ] Test nutrition-bearing third-party foods and malformed/missing custom data.

## Future features

- [ ] Do not start preferences, fatigue, freshness bonuses, overeating, or food poisoning without approval.
