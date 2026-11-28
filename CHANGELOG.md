# Changelog

- Removed diagnostic log extracts from the tracked repository and ignored future log files; existing Git history is unchanged.

- Recorded an uninterrupted dedicated-server capacity diagnostic: server effective capacity and the client's observed effective capacity rose from 12 to 15 and returned to 12 after the server restored the scalar. Save and interruption behavior remain unverified.

- Added an explicitly enabled, disposable-only server-owned capacity diagnostic with client sampling before and after a temporary scalar change. Runtime behavior and restoration across interruptions remain unverified.

- Added a reason to denied diagnostic server-capacity requests so capability-check errors, absent capability, and an unavailable probe can be distinguished; runtime verification remains pending.

- Recorded an uninterrupted disposable SP capacity probe: the scalar changed from 1 to 1.25, effective capacity subsequently changed from 12 to 15, and both returned to their baseline after restoration. Lifecycle and multiplayer safety remain unverified.

## Unreleased

- Added a disabled-by-default diagnostic-only synthetic countdown panel with SP and targeted MP paths; mock checks and static review passed, while in-game display and lifecycle remain unverified.
- Recorded one combined dedicated-server diagnostic: quarter-cola fluid and nutrient observations, a synthetic deadline across restart, positive-progress food cancellations, and read-only capacity samples. The non-default capacity comparison and zero-progress cancellation remain open.
- Added a disabled-by-default dedicated-server read-only capacity and Strength observer. It refuses to run alongside enabled server mutation probes and sampled successfully in one disposable dedicated-server session.
- Recorded a dedicated-server duration diagnostic: recipe and washing adjustment calls appeared on both sides, with three calls for the same locally tracked washing action per side.
- Added a diagnostic-only duration adjustment observer for selected recipe and washing actions; no modifier is applied and runtime verification is pending.
- Recorded matching independent server/client salad snapshots after two ingredient additions and reconnect in one dedicated-server test.
- Added a diagnostic-only paired meal snapshot request: server and client independently inspect their inventories, with no client nutrition sent to the server; runtime validation remains pending.
- Recorded a dedicated-server salad test: the kit was supplied, two ingredient additions and quarter consumption were observed, and the first addition replaced the bowl with a salad item.
- Added an experimental evolved-recipe completion observer and configurable diagnostic test kits; prepared a bowl/tomato/lettuce test. Runtime verification remains pending.
- Added a disabled-by-default configurable dedicated-server diagnostic test-item request for the requesting player; server chooses item and quantity. Runtime verification remains pending.
- Recorded dedicated-server food observations for quarter consumption, shove interruption, and full removal; interruption consumed a small amount and removal classified as unknown.
- Replaced the misleading diagnostic food-boundary marker with finite sampled-field classifications; this is experimental observation only and has not been runtime-tested.
- Recorded a dedicated-server synthetic transport counter surviving server restart and a read-only client moodle registration-member exposure observation; native registration and rendering remain unverified.
- Recorded a dedicated-server synthetic deadline expiring across a five-minute disconnect while server world time advanced; production effect behavior remains untested.
- Recorded a human-run SP full-process restart test in which the synthetic persistence counter survived and incremented from 2 to 3.
- Recorded a human-run SP menu/reload preflight: capacity reads were available and the synthetic counter survived returning to the main menu and reloading the character. Full process restart remains untested.
- Added a disabled-by-default synthetic server world-time expiry probe for reconnect experiments; it changes no gameplay effects and remains untested in-game.
- Recorded the approved world-time offline expiry default and the requested, feasibility-dependent configuration toggle; no gameplay implementation changed.
- Added documented project-scoped Codex researcher, planner, developer, and reviewer roles with inherited model/permission settings and a modest direct-subagent concurrency cap. Updated the collaboration protocol; no gameplay implementation or decision changed.
- Added an independently enabled server capacity diagnostic request guarded by the vanilla debug capability and bound to the requesting player; disconnect cleanup and runtime behavior remain unverified.
- Recorded vanilla server debug-capability evidence and source-available custom-moodle rendering approaches; server disconnect cleanup and fallback presentation remain unresolved.
- Documented native moodle icon mapping and registry reset behavior; strengthened the capacity probe to require target readback before claiming scalar ownership.
- Tightened synthetic counter schema and integer bounds, and recorded native moodle registry, level and tooltip method findings; runtime validation remains pending.
- Added a post-restoration capacity sample and a diagnostic world context menu for enabled local/SP probes and client transport requests; menu and probes are not yet runtime-tested.
- Changed the separately enabled capacity diagnostic to hold a bounded test scalar for 120 ticks and attempt restoration only if it has not changed; runtime and cleanup behavior remain unverified.
- Traced periodic server damage synchronization of effective carrying capacity and inspected player/character save methods; complete load ordering and live multiplayer behavior remain unverified.
- Documented the vanilla capacity recalculation, its client/god-mode guards, inventory capacity readers and a packet carrying effective max weight; a broad decompilation ran out of memory, leaving the cross-class audit incomplete.
- Recorded initial Java method-body findings: capacity delta is a trait-related scalar distinct from the max-weight field; food percentage can be adjusted, burnt food contributes one fifth nutrition, and player nutrition setters clamp values. Cross-class capacity lifecycle remains unverified.
- Downloaded CFR 0.152 as a Git-ignored local research tool and verified that it runs with the game's bundled Java; Java method-body inspection remains to be performed.
- Added a separately guarded, immediate-restore max-weight-delta diagnostic probe and explicit food-boundary markers for `complete`/`eat`; no gameplay effect or persistent stat change was added.
- Recorded the Milestone 5 tooling limitation: the bundled runtime has no `javap`/JDK tools and a CFR download could not resolve, so Java method-body findings remain blocked rather than inferred from metadata.
- Recorded an SP diagnostic test in which observed player macronutrient increases matched item decreases for repeated portions and interruptions; multiplayer authority and broader behavior remain unverified.
- Recorded matching player/item nutrition changes and a successful guarded-progress retest in a hosted multiplayer session; broader authority and standalone dedicated-server coverage remain unverified.
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
