# TODO

## Current priorities

1. Investigate capacity lifecycle and production suitability after the successful uninterrupted dedicated-server diagnostic. Save/load, disconnect, restart, removal, and safe ownership remain unverified; one successful test cannot prove them.
2. Establish and review server-authoritative post-consumption candidates for food and partial consumption, including zero-progress cancellation and removal; separately assess fluid and legacy-bottle paths. Trace nutrition provenance and validation trade-offs without assuming server-observed values are intrinsically trustworthy.
3. Evaluate capacity lifecycle and alternatives, effect persistence/expiry, and an effect presentation route against FE-007. Identify the smallest feasible first effect and present its mechanics, scope, validation and compatibility trade-offs for human approval.
4. After the gate is met and the human approves a concrete slice, implement and review it, then test SP, dedicated MP, existing saves, expiry, reconnection, restart, malformed data, removal and representative nutrition-bearing third-party foods. Expand toward dietary variety, Cooking and additional effects only through approved designs.

## Research

- [x] Trace the inspected dedicated-server disconnect save ordering, player reload construction, and vanilla Strength-trait changes relevant to capacity. Full serialization, trait initialization and runtime lifecycle remain open.
- [ ] Trace remaining capacity serialization and trait initialization paths; assess whether a disposable lifecycle test can distinguish saved scalar, reconstructed baseline, effective capacity and removal without assuming cleanup succeeded.
- [x] Inspect the main player/character/moving-object save chain and scan installed class entries for direct scalar-field/setter name references; indirect persistence and post-load initialization remain unverified.
- [x] Research a possible server-owned capacity diagnostic trigger and identify its measurement and cleanup limits; implementation, review and runtime testing remain open.
- [x] Implement and independently review the bounded disposable-server capacity experiment and paired client observations; one uninterrupted runtime test succeeded.
- [x] Run the controlled dedicated-server capacity experiment on a disposable server and character; compare server mutation/restoration attempts with client capacity samples and reset the diagnostic configuration afterward. Interruption, saves, restart and removal remain untested.
- [x] Correct and independently review the diagnostic food-boundary marker: classify sampled finite changes, unchanged samples, and unknown states without claiming consumption. Runtime validation remains open.
- [x] Run a dedicated-server diagnostic comparison of ordinary partial food, shove interruption, and full removal; zero-progress cancellation remains unverified.
- [ ] Extend runtime testing of the diagnostic item menu beyond the successful salad kit: reconnect, invalid configuration, and partial send failure remain unverified.
- [x] Run the SP read-only capacity and synthetic persistence preflight across a return to the main menu and reload, and verify the synthetic record after a full process restart.
- [x] Run the synthetic world-time expiry probe across disconnect and reconnect on a standalone dedicated server with `PauseEmpty=false`. Server restart, additional characters, and production effect behavior remain untested.
- [x] Verify one dedicated-server synthetic transport response and player record across a server restart; inspect native moodle registration member exposure from the client. Additional players, malformed records and actual moodle registration remain untested.
- [ ] Milestone 4: run separately enabled consumption/nutrition, capacity read-only, moodle exposure, and synthetic persistence/transport probes in disposable SP and hosted/standalone MP; capture environment, debug/admin settings, and exact diagnostic revision.
- [x] Compare player and food nutrient snapshots for quarter/half/remainder and interrupted food actions in one SP test; standalone dedicated MP, zero-progress cancellation, and broader food coverage remain open.
- [x] Compare player and food nutrient snapshots in one hosted MP test and retest the guarded server job-progress lookup; standalone dedicated MP, zero-progress cancellation, and broader coverage remain open.
- [ ] Run the explicitly enabled, guarded delayed carrying-capacity setter probe on a disposable character; inspect later vanilla updates, save/load, reconnect, restart, and removal before judging any production lifecycle safe. Interoperability with other capacity-altering mods is not required (FE-010).
- [x] Run the bounded SP capacity probe on a disposable character whose scalar differs from 1.25; compare before, delayed, restoration and post-restoration samples. Save/load, interruption, removal and MP remain untested.
- [ ] Investigate native moodle registration exposure, timing, level, rendering, icons, and dynamic tooltips; do not register an unverified type in the candidate.
- [x] Inspect native MoodleType, per-character map, level computation and tooltip-key bodies; registry timing, icon resolution and extension viability remain open.
- [x] Inspect native MoodleTextureSet and registry method bodies; exact initialization timing and third-party extension viability remain open.
- [ ] Investigate whether historical unsanitized logs were exposed on any remote and propose any cleanup for human approval. Raw and redacted logs remain local and ignored; removal from the current tree does not rewrite history.
- [x] Establish local-install evidence for item nutrition, evolved recipes, tags, and eating action.
- [x] Run the isolated `FoodEffectsDiagnostics` mod in SP and hosted MP and capture initial food and fluid observations. A standalone dedicated server and comprehensive coverage remain untested.
- [ ] Identify and prove a server-authoritative post-consumption hook that covers food, partial food consumption, fluid drinking, and evolved meals in SP and dedicated MP. Do not use `EventEating` or these diagnostic wrappers as a production interception point without that evidence.
- [ ] Trace legitimate evolved-meal item-state synchronization and server-side nutrition provenance; design a focused disposable-server diagnostic. `ItemStatsPacket` can apply client-supplied nutrient fields to resolved items in the inspected path, but exploitability and all validation remain unverified.
- [x] Design and review read-only server/client snapshots for the same meal IDs after additions and reconnect; test convergence without treating client nutrition as authority or claiming packet ordering/security. Broader foods and provenance remain unverified.
- [x] Run the paired-salad snapshot test after each ingredient and reconnect; independent server/client IDs and sampled fields matched in this case. Packet ordering and authority remain unverified.
- [x] Run the dedicated-server salad diagnostic: request the kit, add tomato and lettuce, and eat a portion. Packet provenance and broader recipes remain unverified.
- [ ] Search for a source-owned, reversible temporary-effect facility. Direct XP multiplier use shares a saved per-perk entry with vanilla books and is not an independently owned modifier.
- [ ] Investigate whether a source-owned per-character calculation hook exists for capacity or endurance; direct effective/base capacity and endurance writes lack demonstrated ownership and safe cleanup. Do not assume `OnPlayerUpdate` runs for remote dedicated-server players.
- [ ] Resume timed-action duration interposition research only if the human prioritizes that unapproved gameplay candidate; it is not a source-owned modifier API.
- [x] Design and independently review a diagnostic duration-call observer for selected actions; runtime behavior and mod load-order effects remain unverified.
- [x] Run duration observation for salad additions and a washing action on a disposable dedicated server and client. Call purpose, elapsed duration and cross-side identity were not logged; further work depends on gameplay direction.
- [ ] Compare server-side nutrition validation approaches, explicitly documenting dynamic vanilla/third-party values and any proposed caps or scope trade-offs for human approval.
- [x] Establish a local bytecode inspection tool: CFR 0.152 runs on the bundled Java 25 runtime. Inspect capacity, consumption/nutrition and moodle method bodies next.
- [x] Inspect initial `IsoPlayer` capacity accessors, `IsoGameCharacter.Eat`, and `Nutrition` setters; cross-class capacity calculation, serialization/network paths and moodle lifecycle remain open.
- [x] Locate `BodyDamage.UpdateStrength` capacity calculation and `PlayerDamagePacket` effective-weight field; complete packet direction/timing, save/load, execution-side and mod-interaction investigation remains open.
- [x] Trace the server's periodic damage-sync caller and inspect player/character byte-buffer save methods; superclass/component serialization and live behavior remain open.
- [ ] Assess and runtime-test capacity probe interruption, conflict handling and lifecycle; the delayed restoration and post-restoration observation succeeded once in SP but remain unverified in MP.
- [ ] Runtime-verify the independently guarded server-side capacity test control and mutation in MP; the world menu and an uninterrupted mutation were observed in SP.
- [x] Identify the dedicated-server capacity request denial: the improved diagnostic reported `capability-not-granted` for the tested account. An authorized request and MP mutation remain untested.
- [x] Trace server disconnect save/removal ordering and prepare a separately enabled capability-guarded server probe; runtime authorization and cleanup behavior remain unverified.
- [ ] Evaluate optional custom-moodle dependencies for installed build, compatibility, maintenance and license; human is open to a dependency but has not selected one.
- [x] Review source-available Build 42 custom-moodle project descriptions; both identified projects describe replacement rendering, while compatibility and code-level details remain unverified.
- [ ] Test whether custom moodle types can be registered; otherwise assess a minimal client UI/notification route with dynamic remaining duration.
- [ ] Verify evolved-recipe nutrient aggregation and preservation of ingredient provenance.

## Architecture

- [ ] Investigate a configurable offline-expiry mode without compromising server authority, persistence, or existing saves; propose the alternative behavior for human approval before implementation. World-time expiry while disconnected is the approved default (FE-009).
- [x] Establish project-scoped Codex multi-agent roles and a three-subagent concurrency cap; permissions inherit from the parent, model selection follows the working agreement, and nested delegation is prohibited by role instructions.
- [x] Draft a conditional authoritative effect-record architecture, expiry clock, replication plan, migration/removal behavior, and duplicate-application guard. It remains blocked on consumption, player persistence/replication, and stat-surface verification.
- [ ] Define third-party compatibility schema based on nutrition/properties/tags, with opt-in overrides only where necessary.

## Implementation

- [ ] Blocked pending verification and human review of the consumption path, effect targets, persistence/replication, and presentation. Duration stacking is approved; balance numbers and stat targets are not.

## Testing

- [x] Document SP and dedicated-server test matrix: partial eating, drinking, evolved meals, reconnect, save/load, expiry, and mod removal/reinstall.
- [ ] Complete the test matrix: immediate cancellation without consumption, evolved meals, legacy bottles, standalone dedicated MP, third-party foods, and nutrition actually applied to the player.

## Compatibility

- [x] Remove tracked diagnostic log extracts from the current repository tree and ignore future diagnostic logs; documented findings remain. Historical/remote exposure remains a separate open question.
- [ ] Test nutrition-bearing third-party foods and malformed/missing custom data.
- [ ] Check availability and test a representative nutrition-bearing food mod, including the human's example Vanilla Foods Expanded if available; no compatibility is claimed before verification.
- [ ] Document that mods altering carrying capacity may conflict if a capacity effect is adopted (FE-010).
- [ ] Verify the diagnostic namespaced record through save/load, reconnect, server restart, client synchronization, malformed-data recovery, and mod removal/reinstallation using disposable saves.
- [x] Add shared schema and bounded integer validation for synthetic diagnostic counters; malformed-record runtime verification remains open.
- [x] Verify corrected diagnostic mod discovery and loading on the hosted server and client; the previous root-only candidate did not appear in the Mods menu.
- [ ] Extend validation of action correlation, cancellation arguments, fluid snapshots, and record-before logging beyond the observed SP and hosted MP cases. Correlation IDs are process-local, not proven transaction identities.
- [x] Retest the guarded job-progress lookup in SP and hosted MP; available progress was logged and the previously observed error pattern was absent in those captures.

## Future features

- [ ] Research a proposed cook happiness benefit on completing an elaborate meal: verify recipe completion, ingredient/spice provenance, server authority, duplicate prevention, and a safe temporary happiness surface; propose criteria and balance for human approval before implementation.
- [ ] Do not start preferences, fatigue, freshness bonuses, overeating, or food poisoning without approval.
