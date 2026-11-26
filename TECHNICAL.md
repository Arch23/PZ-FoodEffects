# Technical research

Research began 2026-11-24 using the local Steam installation at `C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid`. Subsequent local logs identify Build 42.22.2 revision `3d39148846`. Milestone handoffs below are historical snapshots; the 2026-11-26 runtime findings at the end are the current test status.

## Food nutritional properties

## Finding: Food nutrition fields are data-driven and readable from Lua

### Status
Verified (calories, carbohydrates, lipids, proteins); Unverified (vitamins).

### Findings
Vanilla generated food definitions use `Calories`, `Carbohydrates`, `Lipids`, and `Proteins`. Vanilla Lua calls `item:getCalories()`, `getCarbohydrates()`, `getLipids()`, and `getProteins()`, and mutates them with matching setters. No `Vitamins` field or getter was found in the inspected vanilla Lua/item definitions.

### Evidence
- File: `media/scripts/generated/items/food.txt` (e.g. `PanFriedVegetablesForged`, `RedRadish`, `Tomato`, `Bacon`)
- API / method: `item:getCalories()`, `getLipids()`, `getCarbohydrates()`, `getProteins()` and matching `set...()`.
- Vanilla usage: `media/lua/shared/Fishing/Fish.lua:188-191` and `Fishing/fishing_properties.lua:729-732` scale all four fields.
- Context: shared Lua; field definitions are script data.

### Proposed implementation
Read the consumed item’s live values immediately before consumption, multiplied by the actually consumed fraction only after the consumption hook is verified.

### Limitations
Values may be altered at runtime (foraging/fishing/butchering scripts demonstrate this). Vitamins must not be assumed available.

### Design implications
The vitamin proposal needs an approved alternate source or must wait for API verification.

### Questions requiring approval
None yet; research first.

## Food consumption events

## Finding: The vanilla timed eat action delegates consumption to `IsoPlayer:Eat`

### Status
Partially verified.

### Findings
`ISEatFoodAction:complete()` and `:eat()` call `self.character:Eat(self.item, percentage, self.useUtensil)`. It also reports `EventEating` when the action starts. This is an implementation path, not evidence of a safe public mod event after nutrition application.

### Evidence
- File: `media/lua/shared/TimedActions/ISEatFoodAction.lua:98-101, 151-153, 174-182`.
- API / method: `IsoPlayer:Eat(item, percentage, useUtensil)`; `character:reportEvent("EventEating")`.
- Context: shared timed action; client inventory identity is refreshed in `start()` when `isClient()`.

### Proposed implementation
Do not hook `EventEating` or replace `Eat` until SP/MP coverage is tested. Find a supported post-consumption event or server-side interception point.

### Limitations
Drinking uses a separate `ISDrinkFluidAction.lua` path. Script inspection alone does not prove ordering, partial-consumption behavior, or server authority.

### Design implications
Duplicate prevention is a mandatory architecture item.

### Questions requiring approval
None.

## Evolved recipes

## Finding: Recipe eligibility and meal templates are script-defined

### Status
Verified for definitions; Unverified for final nutrient aggregation/provenance.

### Findings
`evolvedrecipe` entries declare `BaseItem`, `ResultItem`, `MaxItems`, cooking properties, and a `Template`. Food items declare `EvolvedRecipe` mappings with ingredient values and optional conditions such as `|Cooked`; some also use `Spice = true` and `EvolvedRecipeName`.

### Evidence
- File: `media/scripts/generated/evolvedrecipes.txt` (Soup, Pie, Sandwich, Salad entries).
- File: `media/scripts/generated/items/food.txt` (`RedRadish`, `Tomato`, `Potato`, `Bacon`, `BaconBits`).
- Properties: `EvolvedRecipe`, `EvolvedRecipeName`, `Spice`, `CanAddSpicesEmpty`, `AddIngredientIfCooked`.
- Context: parsed game script data; execution/aggregation code has not yet been located.

### Proposed implementation
Prefer final, live meal nutrition for base effects. Only add provenance/variety bonuses after testing whether ingredient data survives recipe construction.

### Limitations
No conclusion is recorded about how the engine sums nutrients or preserves constituents.

### Design implications
Ingredient-sensitive effects need a compatible fallback when provenance is unavailable.

### Questions requiring approval
None.

## Ingredient identification and item tags

## Finding: Item tags can be queried, but food-seasoning tag taxonomy is not established

### Status
Verified for querying registered tags; Partially verified for food classification; Unverified for runtime custom registration.

### Findings
Vanilla Lua uses `item:hasTag(ItemTag.CONSTANT)` and also resolves tag resources through `ItemTag.get(ResourceLocation.of(tag))`. Item definitions contain `Tags =` values (often namespaced, e.g. `base:herbaltea`), while spices are explicitly marked `Spice = true` in food definitions.

### Evidence
- File: `media/lua/server/Animal/ISScytheGrassCursor.lua:153` (`hasTag(ItemTag.HAND_SCYTHE)`).
- File: `media/lua/server/BuildingObjects/ISBuildIsoEntity.lua:724` (`ItemTag.get(ResourceLocation.of(tag))`).
- File: `media/scripts/generated/items/food.txt` (`TestHotDrink` tags `base:herbaltea`; `BaconBits` has `Spice = true`).
- Context: client/server/shared usages exist. `hasTag` is an item API.

### Proposed implementation
Classify compatible ingredients first by explicit food properties (`Spice`, `EvolvedRecipe`, nutrition) and recognized tags only when their semantics are verified. Provide a small opt-in compatibility definition layer for mods.

### Limitations
No evidence yet that arbitrary tags can be registered at runtime or that all herbs/seasonings share a stable tag.

### Design implications
Avoid assuming a universal `seasoning` tag or using a hard-coded vanilla-ID catalog.

### Questions requiring approval
None.

## Custom moodlets and notifications

## Finding: Native custom moodle extension is not yet evidenced

### Status
Unverified.

### Findings
The shared eating action reads vanilla `MoodleType.FOOD_EATEN`; no vanilla Lua moodle-registration script was located in the inspected media. Therefore custom moodle type registration, custom icons, and dynamic tooltip support are not claimed.

### Evidence
- File: `media/lua/shared/TimedActions/ISEatFoodAction.lua:14`.
- API / method: `character:getMoodles():getMoodleLevel(MoodleType.FOOD_EATEN)`.
- Context: shared Lua.

### Proposed implementation
Research/experiment with native extension first. If unsupported, use a narrowly scoped client presentation that consumes server-authoritative effect state.

### Limitations
Dynamic numbers and remaining duration in native moodle tooltips require an in-game test.

### Design implications
Discoverability presentation is a design gate, not an implementation assumption.

### Questions requiring approval
If custom moodles are unsupported, approve the allowed custom UI/notification level.

## Character stats, temporary effects, and expiration

## Finding: No safe temporary stat modifier selected

### Status
Unverified.

### Findings
No verified local Lua evidence yet identifies a reversible carrying-capacity, endurance-recovery, illness-resistance, or XP-rate modifier appropriate for this mod.

### Evidence
- File: `media/lua/shared/TimedActions/ISRestAction.lua` and player/stat Java APIs are candidates for targeted inspection; no API is asserted here.

### Proposed implementation
Store namespaced, versioned effect records with absolute world-time expiry, validate values on load, and derive effects at runtime rather than permanently altering character base stats.

### Limitations
Storage, replication, and the stat surface must be proven in-game before implementation.

### Design implications
Do not approve specific nutrient-to-stat promises yet.

### Questions requiring approval
Choose balance/stacking/stat targets only after an API feasibility report.

## Cooking proficiency and XP

## Finding: Cooking-related script data is present; effect hooks are not verified

### Status
Partially verified.

### Findings
Evolved recipes encode cooking constraints, but no verified vanilla Lua evidence yet shows a mod-safe hook to alter their quality or preserve custom ingredient metadata.

### Evidence
- File: `media/scripts/generated/evolvedrecipes.txt`.
- File: `media/lua/shared/Entity/TimedActions/ISHandcraftAction.lua:242` obtains `resItem:getModData()` in a craft path.
- Context: shared; this is not proof that it applies to evolved recipes.

### Proposed implementation
Treat cooking level as a calculation input only after consumption/recipe provenance is technically established.

### Limitations
XP award logic and evolved-recipe completion behavior need focused inspection/testing.

### Questions requiring approval
None.

## Multiplayer synchronization and persistence

## Finding: Vanilla demonstrates client-command/server-handler and mod-data patterns

### Status
Partially verified.

### Findings
Vanilla server scripts subscribe to `Events.OnClientCommand`; server code commonly uses `getModData()`, and world objects call `transmitModData()` after changes. This proves patterns, not automatic character-data replication nor food-effect authority.

### Evidence
- File: `media/lua/server/ClientCommands.lua:1346-1357` (`ClientCommands.OnClientCommand`; `Events.OnClientCommand.Add`).
- File: `media/lua/server/Camping/SCampfireGlobalObject.lua:263,286` (`isoObject:transmitModData()`).
- File: `media/lua/server/XpSystem/XpUpdate.lua:63,333` uses `owner:getModData()`/`playerObj:getModData()`.
- Context: server Lua.

### Proposed implementation
Make application/expiry server-authoritative in MP, persist only a namespaced/versioned effect record, and explicitly synchronize a display-safe projection to clients after proving the transport.

### Limitations
Player mod-data persistence and replication, clock consistency, reconnect behavior, and removal/reinstall behavior are untested.

### Design implications
Client-only buffs are unacceptable for MP.

### Questions requiring approval
None.

## Mod folder structure and loading behavior

## Finding: Static local templates establish the basic mod layout, not its runtime contract

### Status
Partially verified.

### Findings
The installation includes `mods/examplemod/mod.info` and `Workshop/ModTemplate/Contents/mods/ModTemplate/mod.info`. Both use a root `mod.info` containing at least `name` and `id`; the example mod places Lua below `media/lua`. The installation's vanilla Lua is separated into `media/lua/shared`, `client`, and `server`. This is static layout evidence only: it does not prove load order, every accepted `mod.info` key, or dedicated-server behavior for a new mod.

### Proposed implementation
Before gameplay implementation, create a no-gameplay diagnostic mod using the observed layout and validate loading in SP and a dedicated server.

### Limitations
The exact installed Build 42 revision remains unknown. `ProjectZomboid64.json` names `zombie/gameStates/MainScreenState` and `projectzomboid.jar`, but contains no revision number.

### Evidence
- File: `mods/examplemod/mod.info` (`name`, `id`, and optional descriptive fields); `mods/examplemod/media/lua/defines.lua`.
- File: `Workshop/ModTemplate/Contents/mods/ModTemplate/mod.info`.
- File: `media/lua/{shared,client,server}` directory layout.

## Follow-up consumption-path research

## Finding: Food, legacy bottle drinking, and fluid drinking have distinct application timing

### Status
Partially verified; no supported mod post-consumption event found.

### Findings
`ISEatFoodAction:complete()` calls `IsoPlayer:Eat(item, percentage, useUtensil)`. Its cancellation route calls the same method through `:serverStop()`/`:eat()` with progress-derived percentage. The action reports `EventEating` in `:start()`, before either path, so it cannot establish consumption. `ISDrinkFromBottle` calls its own `:drink()` in `:complete()` and cancellation; it changes thirst and fluid amount itself. `ISDrinkFluidAction` calls `IsoPlayer:DrinkFluid()` repeatedly from `:updateEat()`; on a server it is driven at the `drinkFluid` animation event, and it records a consumed ratio. Therefore a completed action is not a universal post-consumption boundary.

### Evidence
- File: `media/lua/shared/TimedActions/ISEatFoodAction.lua:98-101, 128-140, 151-153, 174-182, 246-259`.
- File: `media/lua/shared/TimedActions/ISDrinkFromBottle.lua:35-39, 52-89, 92-95`.
- File: `media/lua/shared/TimedActions/ISDrinkFluidAction.lua:22-37, 91-103, 113-123`.

### Design implications
Do not hook `EventEating`; it is an animation/reporting signal. Do not replace these vanilla actions or `IsoPlayer:Eat` on the basis of inspection alone. A future diagnostic must prove the authoritative engine-side observation point and measure actual deltas for each path.

## Temporary effect targets and time

## Finding: Read access to carrying capacity and direct endurance mutation are visible, but no safe temporary modifier contract is established

### Status
Partially verified.

### Findings
Vanilla reads `player:getMaxWeight()` in server XP code and exposes endurance through `player:getStats():get(CharacterStat.ENDURANCE)`; shared foraging code writes it with `:set(CharacterStat.ENDURANCE, value)`. These demonstrate availability, not a reversible modifier layer, an endurance-recovery-rate API, or multiplayer-safe synchronization for FoodEffects. `getGameTime():getWorldAgeHours()` is used by vanilla shared and server systems as world-relative time.

### Evidence
- File: `media/lua/server/XpSystem/XpUpdate.lua:16,33,72`.
- File: `media/lua/shared/Foraging/forageSystem.lua:1812,2202-2205`.
- File: `media/lua/shared/Farming/TimedActions/ISPlowAction.lua:160`; `media/lua/shared/Foraging/forageSystem.lua:874-875`.

### Recommendation
Use world-age hours for effect expiry if the diagnostic proves server consistency and player state persistence. Do not select carrying-capacity or endurance-recovery implementation until a reversible, server-authoritative surface is demonstrated. Directly topping up endurance is a transient state write, not evidence of a sustainable recovery-rate effect.

## Architecture proposal (conditional; no gameplay implementation approved)

### Preconditions
This architecture may proceed only after diagnostics prove (1) an authoritative observation adapter for each supported consumption path, (2) player-record persistence and explicit client transport, (3) a reversible stat target, and (4) a minimal presentation route. No single universal hook is required. If a path cannot be supported, present any proposed gameplay scope reduction for approval.

### Proposed modules
- `shared/FoodEffects_Definitions.lua`: effect definitions, numeric validation, configurable duration caps, nutrient-to-effect mapping, and opt-in third-party compatibility definitions. No vanilla item-ID catalog.
- `server/FoodEffects_Consumption.lua`: the later-verified authoritative hook, live nutrition snapshot/delta calculation, idempotency guard, and rejection logging.
- `server/FoodEffects_State.lua`: versioned player record migration, expiry, additive-duration stacking, bounded variety history, and stat-target application/removal.
- `server/FoodEffects_Network.lua`: explicit display projection sent only after authoritative state changes and on join/reconnect.
- `client/FoodEffects_Presentation.lua`: notifications and the smallest approved display; never calculates gameplay authority.
- `shared/FoodEffects_Validation.lua`: finite-number checks, schema migration, cap enforcement, malformed-data recovery, and safe no-op behavior.

### Authoritative data model
Store one namespaced record per player, conceptually:

`{ version = 1, effects = { protein = { expiresAt = worldHours, strength = fixedOrDefined } }, variety = { entries = { { at = worldHours, categories = { protein = true, carbohydrate = true } } } }, processed = { token = worldHours } }`.

`expiresAt` is absolute world time. On a new contribution, server logic calculates `remaining = max(0, expiresAt - now)`, then `expiresAt = now + min(capHours, remaining + contributionHours)`. Strength is either constant per effect definition or omitted; it never grows through stacking. `processed` must be bounded and keyed only by a proven stable consumption transaction/item-delta identity. It must not rely on an item ID after the item can be destroyed.

### Nutrients, quality, and variety
Read live calories, carbohydrates, lipids, and proteins from the consumed object immediately around the verified consumption point. Calculate contribution from an observed delta or an observed engine fraction, not the requested percentage. Treat absent, non-finite, negative, or incompatible values as zero and skip safely. Base effects use final food nutrition, so they can work without provenance. `Spice = true` and verified tag semantics are candidates for meal-quality signals, but not a universal taxonomy. Cooking level may be captured as an input only after the supported skill/read path and evolved-meal provenance are proven. No formula is proposed yet.

Earlier draft (superseded by architecture review): nutrition-derived categories alone are not a proposed final dietary-variety classification. Investigate ingredient identity, food properties, tags, and evolved-recipe provenance before proposing a model; the category scheme and window remain subject to approval.

### Multiplayer, persistence, and failure behavior
In SP, the authoritative path and state manager run locally. In MP, the server alone validates consumption, mutates persistent state, expires effects, and applies/removes verified modifiers. The client receives a display-safe projection (effect key, expiry, fixed tier if approved) and may request a resync on login; it never submits nutrition or duration claims. Absolute world-age expiry is a candidate; expiry while disconnected as server time advances requires approval (FE-009). Unknown versions, malformed records, missing definitions, and removal/reinstallation must result in validation, pruning, or safe no-op—not permanent base-stat edits. The exact player-data persistence and transport calls remain unverified.

### Presentation
Native custom moodles remain unverified. First test registration, icon, and dynamic tooltip capabilities. If unsupported, request approval for a minimal client panel or tooltip plus server-triggered notifications; it should show effect name, source/change, and remaining duration. Do not build a large UI.

### Testing gate
The diagnostic matrix must cover full/partial food, cancelled food, legacy bottle drinking, fluid drinking over time, evolved meals, SP, listen-server MP, dedicated MP, duplicate packets/actions, reconnect, save/load, offline expiry, malformed records, third-party nutrition-only foods, and removal/reinstallation. It must also verify that the selected modifier is applied and removed exactly once.

### Questions requiring approval
None.

## Milestone handoff

**Milestone:** Agreed design direction recorded; second local Build 42 source-inspection pass and conditional architecture proposal complete; no gameplay code written.

**Findings:** Live Lua-readable calories/carbs/lipids/proteins; data-driven evolved recipes and `Spice`/`EvolvedRecipe` properties; queryable item tags; and separate food, bottle-drink, and incremental-fluid consumption paths. World-age hours are used by vanilla as a world-relative time source. Static templates establish the basic mod layout. Custom moodles, a supported post-consumption hook, player persistence/replication, reversible stat modifiers, evolved-meal provenance, and exact Build revision remain unverified.

**Files changed:** `DESIGN.md`, `TECHNICAL.md`, `DECISIONS.md`, `TODO.md`, `CHANGELOG.md`.

**Verified functionality:** Static local-source inspection only, including the shipped Lua actions and templates. No in-game, SP, MP, save/load, or mod-loading test has run.

**Unverified assumptions:** Exact Build revision; vitamins; native moodle extension; authoritative consumption interception; effect stat APIs; player-data persistence/replication; evolved ingredient provenance; and mod removal behavior.

**Decisions required:** After diagnostics, approve a verified stat target, balance values/caps, variety window/categories/thresholds, any Cooking-quality formula, and the fallback presentation if custom moodles are unavailable. Duration stacking itself is approved.

**Next steps:** Validate a no-gameplay diagnostic mod's loader contract; identify and test the authoritative consumption surface in SP and dedicated MP; then verify persistence/transport and one reversible target before seeking approval to implement gameplay.

## Milestone 3: local environment and diagnostic candidate

### Development environment

### Finding: the installed client is Build 42.22.2, revision `3d39148846`

### Status
Verified from local installation metadata and the most recent local game log. Runtime execution of this diagnostic mod is not yet verified.

### Findings

- Game installation: `C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid`.
- Steam application manifest: `C:\Program Files (x86)\Steam\steamapps\appmanifest_108600.acf`; `buildid` is `26486631`, and both `UserConfig.BetaKey` and `MountedConfig.BetaKey` are `pre-release`.
- Game-reported version: `C:\Users\noda2\Zomboid\version.txt` contains `42.22.2 3d39148846`; `C:\Users\noda2\Zomboid\console.txt:58,155` reports the same version.
- Bundled runtime: `jre64\bin\java.exe -version` reports OpenJDK `25.0.5+8-LTS`, Zulu25.38+107-CA.
- Dedicated-server launcher: `ProjectZomboidServer.bat` invokes `zombie.network.GameServer` using the bundled runtime and `projectzomboid.jar`. This confirms that a server launcher is installed alongside the client; it does not prove that a dedicated server has been configured or started.
- User mod directory: `C:\Users\noda2\Zomboid\mods`. Its installed `examplemod` confirms the observed root `mod.info` plus `media/lua` layout. Vanilla/template evidence remains `mods\examplemod\mod.info` and `Workshop\ModTemplate\Contents\mods\ModTemplate\mod.info`.

### Current logs

The existing `C:\Users\noda2\Zomboid\console.txt` was inspected before this diagnostic candidate was installed. It contains normal startup/version material and logs for pre-existing mods, but no `FoodEffectsDiagnostics` prefix. It is therefore not runtime evidence for this work.

### Targeted Java class inspection

### Finding: key engine surfaces exist, but their mod-safe authority and timing are still unproven

### Status
Partially verified by local `projectzomboid.jar` class metadata inspection. No decompiled source is redistributed; class names and JVM signatures only are recorded.

### Consumption and nutrition

- `zombie.characters.IsoGameCharacter` contains `Eat(zombie.inventory.InventoryItem, float, boolean): boolean`. `IsoPlayer` inherits this surface rather than declaring `Eat` directly. This corrects the shorthand `IsoPlayer:Eat` used by the Lua action discussion.
- Shipped Lua calls it from `media/lua/shared/TimedActions/ISEatFoodAction.lua:174` and from `:eat()` at lines 193-200. The cancelled SP route is `:serverStop()` at lines 141-152. `EventEating` is reported earlier in `:start()` at line 123.
- Shipped Lua calls `character:DrinkFluid(item, deltaToConsume, useUtensil)` from `media/lua/shared/TimedActions/ISDrinkFluidAction.lua:109-120`. That action calls `updateEat()` during non-client updates (lines 26-30), server `drinkFluid` animation events (42-47), and completion (104-106). Its observed `consumedRatio` is set at line 119.
- Legacy bottles use distinct Lua mutation in `media/lua/shared/TimedActions/ISDrinkFromBottle.lua:70-109`, including `stop()` at lines 48-56 and `complete()` at 111-114. It is not a `DrinkFluid` adapter.
- `zombie.inventory.types.Food` declares `getCalories(): float`, `getCarbohydrates(): float`, `getLipids(): float`, `getProteins(): float`, `getSpices(): ArrayList`, `hasSpices(): boolean`, `isSpice(): boolean`, and paired macro setters. These support live-value observation, not a conclusion about consumed deltas or evolved-meal provenance.

### Temporary targets and moodles

- `zombie.characters.IsoPlayer` declares `getMaxWeight(): float`, `getMaxWeightDelta(): float`, and `setMaxWeightDelta(float): void`. This is an available candidate surface only; it does not establish a reversible, multiplayer-safe modifier contract.
- `zombie.characters.Stats` declares `get(CharacterStat): float`, `set(CharacterStat, float): boolean`, and `isEnduranceRecharging(): boolean`. This confirms that direct endurance mutation is a resource write, not an endurance recovery-rate modifier.
- `zombie.scripting.objects.MoodleType` declares `get(ResourceLocation): MoodleType`, `register(String): MoodleType`, `register(boolean, String): MoodleType`, and `registerBase(String): MoodleType`. `zombie.characters.Moodles.Moodles` provides level/display/description accessors. No local evidence yet proves that a mod-registered type is rendered, persists correctly, can supply an icon/tooltip, or is safely Lua-accessible; custom native moodles remain unverified.

### Evolved recipes

- `zombie.scripting.objects.EvolvedRecipe` declares `getItemRecipe(InventoryItem)`, `getItemsList()`, `getPossibleItems()`, `isSpiceAdded(InventoryItem, InventoryItem)`, and two `useSpice(...)` overloads, one accepting a `Food` result. `Food` exposes its spices collection.
- These signatures demonstrate engine-level recipe/spice structures, but no inspected call path proves that completed evolved meals retain an ingredient list accessible to Lua. Ingredient-based variety remains deferred.

### Lua accessibility limitation

Lua call syntax in the shipped scripts proves accessibility only for the specific methods used there. Class metadata alone does not prove a method is exposed to Lua on every execution side. The diagnostic uses only methods already seen in local Lua (`getID`, `getFullType`, macro getters, `getWorldAgeHours`, `getModData`) plus player identity methods whose signatures were locally inspected, and it guards failed calls.

## Diagnostic mod: `FoodEffectsDiagnostics`

### Purpose and scope

`FoodEffectsDiagnostics` is a separate mod ID and is not the future production `FoodEffects` mod. Its files are in this repository at `FoodEffectsDiagnostics/`. It provides no buffs, presentation, stat writes, inventory mutation, recipes, item definitions, or vanilla-file changes.

The module logs with the stable prefix `[FoodEffectsDiagnostics]`. Shared, client, and server scripts log their own load marker. The shared script then experimentally wraps source-evidenced timed-action methods:

- food: `ISEatFoodAction.complete`, `eat`, `serverStop`;
- legacy bottle: `ISDrinkFromBottle.complete`, `drink`, `stop`;
- fluid: `ISDrinkFluidAction.animEvent`, `complete`, `updateEat`.

The wrappers log side, hook, before/after ordering, invocation counter, world-age clock, player username/online ID when available, item type/ID, live nutrition before/after, requested fraction, and the action's `consumedRatio` when that action exposes one. Each wrapper delegates the original arguments unchanged and returns its observed single return value unchanged. They are diagnostic instrumentation only, not a post-consumption API recommendation.

On a non-client wrapper invocation, the module writes only `player:getModData().FoodEffectsDiagnostics_v1`, containing a schema, last hook, world age, and side. It logs the prior Lua type and replaces absent or malformed prior values with this fresh disposable record. It deliberately has no consumer and affects no base stats or inventory. Persistence, server ownership, replication, malformed-record recovery, and safe removal have not been runtime tested.

### Consumption architecture proposal after review

The production design must not require one hook for all paths. Subject to diagnostic evidence, it should have separate Food, LegacyBottle, and Fluid consumption adapters. Each adapter may emit only fields it actually observes into one internal record:

`{ playerIdentity?, itemType?, itemInstanceId?, nutritionDelta?, consumedFraction?, executionContext, transactionIdentity?, worldAgeHours?, ingredientMetadata?, qualityMetadata? }`.

Question-marked fields are optional because they have not all been proven. The shared domain layer validates finite values, rejects malformed records, computes nutrients/duration/variety, and deduplicates only with a stable identity proven by tests. Authority-specific code observes actions, stores state, synchronizes display data, and applies a later-approved reversible target. Shared code must make no client-authority assumption.

Nutrition-derived macro categories are insufficient for dietary variety: a repeatedly consumed balanced meal could satisfy them without actual variety. Ingredient identity, food properties, tags, `Food:getSpices()`, and evolved-recipe provenance are investigation inputs, not a finalized taxonomy. A classification model requires later evidence and approval.

Absolute world-age expiry remains technically plausible because `getGameTime():getWorldAgeHours()` is locally used by vanilla and exposed in class metadata. Whether a disconnected player's effects expire while a server world advances is explicitly proposed in FE-009 and requires human gameplay approval.

### Human runtime test workflow

Do not install this into a valued save. Use a disposable save and back it up before the test.

1. With the game closed, copy the repository's `FoodEffectsDiagnostics` directory to `C:\Users\noda2\Zomboid\mods\FoodEffectsDiagnostics`. Confirm that it contains both `mod.info` and `42\mod.info`, with scripts under `42\media\lua`. If replacing the earlier copied candidate, remove or rename that old copy first so stale files do not remain. A junction to the repository folder also exposes this layout.
2. Start Project Zomboid, enable **FoodEffects Diagnostics** in the Mods screen, create a new disposable single-player sandbox, and load it. Do not enable it alongside a future production FoodEffects mod.
3. Quit after reaching the world. In `C:\Users\noda2\Zomboid\console.txt`, find `[FoodEffectsDiagnostics]`. Expected loader evidence is `shared-load=true`, `client-load=true`, and wrapper `installed=true` records. A missing marker or Lua error stops the test; collect the complete log before changing the candidate.
4. In that same save, first eat one ordinary food completely. Record all diagnostic lines between the first `ISEatFoodAction` `before` and last matching `after` record. Verify whether the macro values or item state change, whether `complete` and/or `eat` runs, which side logs it, and whether the test record is written once or more.
5. Repeat separately for a quarter, half, and multiple actions on the same food; cancellation before any consumption; cancellation after partial consumption; and an item that disappears after consumption. Compare requested and observed values; do not equate them without matching deltas.
6. Only after ordinary food is understood, test one evolved meal, a legacy bottle, and incremental fluid drinking. For fluids, preserve the complete sequence of `animEvent`, `updateEat`, and `complete` records so duplicate observation can be assessed.
7. Save, quit, reload, and repeat one food observation. Inspect the player `modData` only through available debugging tools; do not hand-edit production saves. Then remove the diagnostic mod from the disposable save, load it once, reinstall it, and record warnings/errors. This is a test for safety, not proof of a production migration plan.
8. For dedicated MP, copy the same folder to the server's `Zomboid/mods` location, configure the server to load mod ID `FoodEffectsDiagnostics` through the normal server mod configuration, restart it, connect a client with the matching mod, and repeat steps 3-7. Collect both the server console/log and connecting client's `console.txt`; compare side, player identity, world age, and duplicate invocation ordering.

For the expanded diagnostic, save the `record-before` and `created-or-updated` lines after a food action. Disconnect/reconnect, or save and restart the server, then perform one food action and compare its first `record-before` fields to the last record written before the restart. The first action will replace that record after logging it. This tests an observed read on the side that invokes the wrapper; it does not by itself prove client synchronization. Use disposable saves. Do not inject malformed records without a separate controlled test.

The local standard client log is `C:\Users\noda2\Zomboid\console.txt`. Dedicated-server log locations depend on the configured server profile; use the server console output and its profile's `Zomboid\Server`/`Logs` files, then report the exact path used. `C:\Users\noda2\Zomboid\logs.zip` may be included with the raw `console.txt` when sharing evidence.

### Tests executed by Codex at the initial candidate handoff (historical)

- Static layout comparison against local template/example and user-mod directory: passed.
- Static scan that the candidate has one root `mod.info` and shared/client/server Lua files: passed.
- Local source/class metadata inspection: passed.
- Game loading, SP consumption, dedicated server, persistence, transport, mod removal, and runtime log generation: not executed. No diagnostic output exists yet.

## Milestone 3 handoff

**Milestone:** Technical proof-of-concept candidate prepared; runtime validation pending human execution.

**Findings:** Exact installed version, branch, runtime, game path, local mod layout, and server launcher are now evidenced. Food, bottle, and fluid paths have distinct source-evidenced observation points. Class metadata exposes food macro/spice accessors, a possible max-weight delta surface, direct stat resource writes, and moodle registration methods, but none alone establishes a production-safe effect target or custom moodle.

**Files changed:** `FoodEffectsDiagnostics/mod.info`; `FoodEffectsDiagnostics/media/lua/shared/FoodEffectsDiagnostics/{Diagnostics,Consumption}.lua`; `FoodEffectsDiagnostics/media/lua/client/FoodEffectsDiagnostics_Client.lua`; `FoodEffectsDiagnostics/media/lua/server/FoodEffectsDiagnostics_Server.lua`; `TECHNICAL.md`; `TODO.md`; `DECISIONS.md`; `CHANGELOG.md`.

**Verified functionality:** Static diagnostic layout and source references only. The candidate has not loaded in-game.

**Unverified assumptions:** Timed-action wrapping is loadable and preserves behavior in Build 42.22.2; wrappers execute in the authoritative context; records persist/replicate; player identity methods are Lua-accessible; item snapshots reflect actual nutritional contribution; ingredient provenance survives; native moodles render; a max-weight delta is a safe reversible modifier; and offline expiry semantics are acceptable.

**Failed experiments:** No runtime experiment was attempted. An external Java decompiler/JDK `javap` binary was not installed; class-file metadata inspection was used instead and only signatures are recorded.

**Remaining blockers:** Human SP/MP logs; authoritative post-consumption and deduplication proof; persistence/transport proof; evolved-provenance proof; reversible target proof; moodle/presentation proof; third-party/malformed-data tests; and approval of offline expiry behavior, variety classification, balance values, and any fallback UI.

**Decisions required:** Approve or reject FE-009 after server/offline-time evidence. Review FE-008 once adapter results exist. No new stat target, balance, variety categories, or presentation route is ready for approval.

**Historical decision correction:** FE-003 says stacking remains undecided, while FE-004 already approves duration stacking. FE-003 is preserved as the earlier broad effect-model record; FE-004 is the controlling approved decision for stacking. Only numeric values, caps, and target effects remain undecided.

**Next steps:** Run the smallest SP ordinary-food test, attach the raw diagnostic excerpts, and review their ordering before enabling any drink, persistence, or dedicated-MP test. Do not begin production gameplay implementation.

## Diagnostic layout correction handoff

**Milestone:** Repository candidate reorganized into the Build 42 versioned layout after the user reported the original root-only layout did not appear in the Mods menu, both as a junction and a copy.

**Findings:** Locally installed Workshop mod `steamapps\workshop\content\108600\2142622992\mods\RepairAnyClothes` has root `mod.info` and `42\mod.info` with versioned content. This is supporting evidence, not proof that the new candidate loads. The earlier template comparison was insufficient to establish the Build 42 loader contract.

**Changed files:** Diagnostic Lua files moved from `FoodEffectsDiagnostics\media` to `FoodEffectsDiagnostics\42\media`; identical `42\mod.info` added; installation instructions, TODO and changelog updated.

**Verified functionality:** Layout and metadata can be checked statically. Runtime discovery and script loading have not been verified.

**Unverified assumptions:** The versioned layout resolves discovery and all diagnostic scripts load correctly.

**Decisions required:** None; this is a diagnostic packaging correction.

**Next steps:** Restart the game with the corrected folder or junction, verify the mod appears, then conduct the smallest SP loading and consumption test and inspect the log.

## Diagnostic instrumentation follow-up (2026-11-26)

**Milestone:** Expanded diagnostic candidate prepared for the next test round.

**Findings:** The human-hosted multiplayer server log `C:\Users\noda2\Zomboid\Logs\2026-11-26_09-23_DebugLog-server.txt:1279` shows server loading. At lines 1951-1953 a requested quarter of minced meat reduced live calories 225 to 150; at 1974-1976 a removed sausage returned NaN food values; at 1986-1991 the user-confirmed interrupted bun action nested `eat` within `serverStop`, producing two observations of one partial change. The test record was observed within the same session; persistence is not established. Client `console.txt` shows connected client-side loading. Missing animation-directory exceptions were also logged and their significance is unverified.

**Changed files:** `FoodEffectsDiagnostics/42/media/lua/shared/FoodEffectsDiagnostics/Consumption.lua` and `Diagnostics.lua`, `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`.

**Verified functionality:** Local vanilla `ISEatFoodAction.lua:141-152,193-199` supports logging the `eat` argument and progress; `ISDrinkFromBottle.lua:70-105` and `ISDrinkFluidAction.lua:109-119` support fluid amount/ratio observation. Static checks only for the new changes; the prior version ran in hosted MP.

**Instrumentation:** Per-process weak-keyed action IDs and nested parent invocation IDs identify observations within an action object; they are not stable across client/server, reload, or suitable as production transaction IDs. `argumentFraction` is the value passed to `eat` or `drink`, not necessarily the engine-consumed fraction. Job/network progress and fluid amount/ratio are guarded best-effort snapshots. `record-before` prints the previous namespaced record before each replacement, including schema, hook, clock and side. No synchronization mechanism is added or assumed. Diagnostic snapshot and record failures are guarded; underlying vanilla methods are still called with unchanged arguments and their existing single return value.

**Unverified assumptions:** New logging loads and behaves as expected in the game; action identity spans relevant callbacks; fields survive reconnect/restart; fluid methods are available in all applicable cases. Calls absent from a path may log `nil`. No claim is made that item deltas equal player nutrition applied.

**Failed experiments / blockers:** No new runtime test executed. Client synchronization, dedicated standalone server, SP, cancellation at zero progress, portion/repeated-item coverage, drinks, evolved meals, and persistence remain unverified.

**Decisions required:** None for this diagnostic instrumentation; gameplay decisions remain gated.

**Next steps:** Install the updated candidate on client and server, restart, and run immediate cancellation, fresh quarter/half portions, repeated actions on one item, and complete removal. Capture both logs, then test the record before/after reconnect and server restart in a disposable save.

## Diagnostic progress lookup fix (2026-11-26)

**Milestone:** Corrected an instrumentation error found during hosted multiplayer testing.

**Findings:** `diagnostic-logs/2026-11-26-0937-multiplayer/server-debug.txt:1993` traces repeated errors to `actionSnapshot` calling vanilla `ISBaseTimedAction:getJobDelta()`. Installed `media/lua/shared/TimedActions/ISBaseTimedAction.lua:36-37` dereferences `self.action`, absent on the observed server path. `pcall` caught the failure but the engine still logged stack traces. The snapshot now checks `action.action` first; missing job progress logs as nil and network progress remains independently observed.

**Changed files:** `FoodEffectsDiagnostics/42/media/lua/shared/FoodEffectsDiagnostics/Diagnostics.lua`, `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`.

**Verified functionality:** Static inspection shows the new guard precedes the diagnostic `getJobDelta` call and leaves the original wrappers untouched. Previous hosted MP logs show network progress was available when job progress was nil.

**Tests and environments:** Local source/log inspection and static checks only; this fix has not been run in Project Zomboid.

**Unverified assumptions:** The guard removes the observed errors in-game and local job progress remains available in SP/client execution. Other diagnostic calls and unrelated missing animation-directory messages have not been proven error-free.

**Failed experiments:** The earlier `pcall` did not prevent engine error logging; it did not establish the getter was safe without `self.action`.

**Remaining blockers:** Runtime verification of the fix, subsequent SP and MP diagnostic tests, and the existing production gates remain outstanding.

**Decisions required:** None; no gameplay decision changed.

**Next steps:** Restart with the updated diagnostic on each participating installation, perform a small SP food action and an MP action, and inspect logs for progress and absence of the repeated `getJobDelta` error.

## SP and hosted multiplayer runtime findings (2026-11-26)

### Scope and evidence

The human developer ran a locally hosted multiplayer server and client on Build 42.22.2, followed by single-player tests with game debug mode enabled for spawning items. Debug-mode effects on the results have not been separately controlled. These are observations from the diagnostic mod, not proof of comprehensive consumption coverage or production safety. Saved evidence is in `diagnostic-logs/2026-11-26-0937-multiplayer/server-debug.txt`, `client-console.txt`, and `diagnostic-logs/2026-11-26-0952-singleplayer/client-console.txt` and `debug.txt`. These logs may include player names, server/network information, and other personal data; review before sharing.

### Food portions, removal, and cancellation

- In SP, the same beef jerky item went from 410 to 307.5 calories after requested `0.25`, then to approximately 102.5 after requested `0.5` (`client-console.txt:875-880`). The second item delta is approximately 205, or half its original 410, not half the 307.5 remaining. This is an observation for this item and sequence, not a universal formula or proof of nutrition applied to the player.
- In hosted MP, one `PanFriedVegetables` item went from approximately 121.02 to 90.765 to 60.51 calories across two `0.25` actions; the final requested `1` removed it (`server-debug.txt:8068-8355`). Each action had a separate process-local diagnostic action ID.
- Removed items returned `NaN` nutritional fields after the call: SP meat stick and fries (`client-console.txt:883-896`) and MP meal/hotdog (`server-debug.txt:8299-8471`). Presence and finite values must be checked; an invalid post-removal snapshot cannot independently prove the actual amount applied to the player.
- User-confirmed interrupted MP bun consumption nested `ISEatFoodAction.eat` inside `serverStop` in the earlier server log `C:\Users\noda2\Zomboid\Logs\2026-11-26_09-23_DebugLog-server.txt:1986-1991`. The SP interrupted jerky action similarly logged action 7 with nested invocation 8, progress and `eat` argument approximately 0.0724, and calories 102.5 to 72.81 (`client-console.txt:899-905`). These are paired observations of one interrupted action, not separate consumption transactions. No true zero-consumption cancellation is established.

### Fluids and test record

- SP soda used incremental `ISDrinkFluidAction.updateEat` observations: fill ratio went from 1 to 0.75 for a requested quarter, with the final nested completion update showing no additional delta (`client-console.txt:907-916,1579-1588`). Several calls showed no change. Hosted MP beer also generated nested `animEvent`/`updateEat` observations (`server-debug.txt:2041-2224`). Neither case establishes nutrient application or the legacy bottle path.
- The first record-before in the later hosted server session reports the earlier `ISEatFoodAction.serverStop` and world age `4.138049125671387` (`server-debug.txt:2166`), matching the previous server session's bun record (`C:\Users\noda2\Zomboid\Logs\2026-11-26_09-23_DebugLog-server.txt:1991`). This is evidence that this player's diagnostic record survived that intervening hosted-server restart. It does not prove explicit replication, independent reconnect behavior, other characters, malformed-data recovery, or removal/reinstallation safety.
- The expanded diagnostic generated repeated `getJobDelta` errors in the hosted MP run because its server action lacked `self.action`. After the guard was added, the subsequent SP log contains job progress and no matching `getJobDelta` exception. The guarded server path has not yet been rerun; the fix is not verified in MP. The SP fluid test also generated many log and record writes, including calls with no observed change; instrumentation volume needs review before larger tests.

### Milestone handoff

**Milestone:** Initial human-run SP and hosted MP diagnostics reviewed; milestone remains partial.

**Findings:** Corrected packaging loaded on the tested client and hosted server. Observed food portions, cancellation nesting, item removal, incremental fluids, and one server-restart record read are documented above. Earlier handoff claims of no runtime tests describe their original dates only.

**Changed files:** `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`. No gameplay or diagnostic code changed in this documentation update.

**Verified functionality:** The recorded diagnostic cases executed in SP and hosted MP; specific item snapshots and correlation fields appear in the referenced logs. SP job progress appears after the guard without the previously observed matching error.

**Tests executed and environments:** Human-run SP with debug mode enabled and locally hosted multiplayer on Build 42.22.2. Standalone dedicated-server, independent client synchronization, and controlled persistence tests were not executed.

**Unverified assumptions:** Item nutrition deltas equal the nutrition applied to the character; requested fractions generalize to all food; local action IDs identify network transactions; debug mode had no effect on action behavior; all consumption paths are observable and authoritative; and the progress fix prevents server errors.

**Failed experiments:** The prior diagnostic progress lookup caused repeated server error traces despite `pcall`; the guard is statically justified and SP-tested, but awaits an MP retest. Initial root-only packaging was not discovered. Missing diagnostic animation-directory exceptions remain unexplained.

**Remaining blockers:** Test zero-consumption cancellation, player nutrition application, evolved-meal provenance, legacy bottle path, standalone dedicated MP, reconnect and client transport, malformed/missing records, removal/reinstall, third-party foods, reversible stat targets, and presentation. Investigate high-volume fluid logging and record writes before scaling tests.

**Decisions required:** Gameplay and architecture gates remain as recorded: FE-008 is proposed; offline expiry FE-009 requires approval; no balance, target, variety taxonomy, or fallback UI has been approved.

**Next steps:** Retest the progress guard on hosted MP, then plan controlled player-nutrition, zero-progress cancellation, and persistence/transport experiments before expanding consumption coverage. Keep production gameplay implementation blocked.

## Milestone 4: separately enabled feasibility candidates (2026-11-26)

### Scope and evidence

All experiment switches in `FoodEffectsDiagnostics/42/media/lua/shared/FoodEffectsDiagnostics/Config.lua` default to `false`. Set only the desired switch to `true` on every applicable installation and restart the game/server. Restore all switches to `false` after testing. Use disposable saves and characters, and record whether debug mode, instant actions, or administrative powers are active. The candidate is untested in-game. Earlier SP and hosted MP tests used Build 42.22.2 revision `3d39148846`; the human reported SP debug mode, but MP debug/admin settings were not established. Previous tested diagnostic versions predate this change; the checkout prior to this work was commit `c806506`, but no exact per-test code hash was captured and the earlier logs cannot be definitively assigned that revision. This candidate is uncommitted; identify the actual tested revision with `git rev-parse HEAD` and record SHA-256 hashes of the diagnostic Lua files as well as any local edits.

### 1. Consumption and player nutrition

`consumption=true` enables the experimental food and bottle wrappers and the narrower fluid `updateEat` wrapper. Shared snapshots now include player nutrition getters from `player:getNutrition()`. Installed `media/lua/shared/TimedActions/ISEatFoodAction.lua:14` references `getCalories()` in a comment; `media/lua/client/XpSystem/ISUI/ISCharacterScreen.lua:117` actively calls `getNutrition():getWeight()`. Local JAR `zombie.characters.BodyDamage.Nutrition` class metadata contains names `getCalories`, `getCarbohydrates`, `getLipids`, `getProteins`; exact signatures, Lua exposure, and server behavior are not established by these names. Values may be nil; a player delta can be affected by vanilla mechanics, clamping, timing, or replication and must not automatically be considered authoritative contribution.

Food `complete` directly calls `Eat` and cancellation `serverStop` delegates to `eat` (`ISEatFoodAction.lua:141-152,173-175,193-199`). Their wrappers are candidate boundaries, not unique production transactions: `serverStop` and `eat` nest. Legacy bottle `drink` is the mutation candidate (`ISDrinkFromBottle.lua:70-109`). Fluid `updateEat` is the narrowest Lua boundary located in this pass (`ISDrinkFluidAction.lua:104-120`); underlying Java may perform other paths. Its unchanged snapshots are suppressed only when both amount and ratio were available and unchanged; missing measurements are logged. Fluid pre-state is captured before the call and printed as `phase=before-saved` after the original call; if the original throws, no saved pre-state is printed. No automatic zero substitution for NaN or normalized production contributions exists. Food wrapper result is the Lua method's return, not the inner Java `Eat` result.

**Procedure:** Enable only `consumption`, restart, use a disposable player and ordinary food with known starting values. Eat one quarter, then half of the same item, then the remainder; repeat with immediate and later cancellation. Compare paired item and player fields, requested fraction, invocation/action IDs, item presence and `result`; retain before and after lines and separately record your actions. Repeat on hosted MP with server and client logs, then standalone dedicated MP. Success means the candidate logs comparable fields and return/control behavior remains unchanged in the specific case; it does not prove authority. Stop if there are Lua errors, missing hooks, unexplained changes, or interference with vanilla behavior. Finish with `consumption=false` and restart. The previously observed server `getJobDelta` error needs an explicit hosted MP retest.

### 2. Carrying-capacity preflight — mutation blocked

Local class metadata inspection previously found `IsoPlayer.getMaxWeight(): float`, `getMaxWeightDelta(): float`, and `setMaxWeightDelta(float): void`; class signatures alone do not establish Lua exposure. `capacity=true` exposes `FoodEffectsDiagnostics.inspectCapacity(getPlayer())` for a Lua debug evaluator. It logs `[FoodEffectsDiagnostics] experiment=capacity` with player, effective max weight and delta, without a setter. Run only with a disposable character. If values are nil or errors occur, record failure; disable and restart afterward.

No mutation or restoration code has been supplied: safe restoration across save/load, unexpected termination, concurrent writers, and mod removal is not demonstrated. Therefore there is no safe test value, no setter-based runtime test or cleanup guarantee yet. Investigate the setter, persistence and ownership before proposing a controlled reversible mutation protocol; stop rather than leave a changed value on a save. MaxWeightDelta is not approved as a production effect.

### 3. Moodle preflight — registration blocked

Local JAR class metadata reports `zombie.scripting.objects.MoodleType.register(String): MoodleType`, `register(boolean,String): MoodleType`, `registerBase(String): MoodleType`, and `get(ResourceLocation): MoodleType`; visibility, Lua exposure and registration timing are not established. `moodle=true` exposes `FoodEffectsDiagnostics.inspectMoodle()` in a Lua debug evaluator, logging `[FoodEffectsDiagnostics] experiment=moodle phase=inspect`. A non-nil registration member alone is not proof it can safely be called. Disable and restart after the check. No native type, level, icon, tooltip or duration is registered or controlled; source and timing evidence is insufficient for a safe, meaningful synthetic native registration test. No external framework was added or evaluated. The exact availability and entry point of a Lua debug evaluator in this installation remain to be confirmed by the human; these preflights cannot be claimed executed until then.

### 4. Persistence and synthetic transport

Enable only `persistenceTransport` on server and client and restart. For SP, invoke `FoodEffectsDiagnostics.probeSinglePlayerRecord(getPlayer())` from a Lua debug evaluator, save and quit, reload the same character and invoke again. Compare `experiment=persistence` `previousCount` and `count`; a second consecutive value is evidence only for that character/save path. For MP invoke `FoodEffectsDiagnostics.requestTransportProbe()` from the connected client's evaluator. The server handles the named request using the player supplied by `OnClientCommand`, increments a bounded synthetic namespaced record on that player, and sends the server-created count and world age only to that player via `sendServerCommand`. The client logs `experiment=transport phase=client` with both clocks. Local vanilla examples: `media/lua/shared/Util/LuaNet.lua:123,260-263`, `media/lua/server/ClientCommands.lua:1357`, `media/lua/client/ServerCommands.lua:218`, and `media/lua/shared/BuildingObjects/TimedActions/ISMultiStageBuild.lua:169`.

Compare the server `previousCount` and client count with reconnect, server restart, and a second disposable character, each separately. Repeat on standalone dedicated MP. A received matching server payload establishes only transport of synthetic data, not client trust, gameplay authority, or automatic mod-data synchronization. Stop on Lua errors, missing/misrouted response, or unexpected character crossover. Restore configuration and restart; removal/reinstallation and malformed records need separate disposable-save tests. No client nutrient or duration claim is accepted. Because the evaluator entry point has not been verified, command availability and this entire transport procedure remain experimental.

### Privacy review

`git ls-files diagnostic-logs` shows the four previous raw logs are already tracked at `c806506`. Static pattern review found usernames, network-address-like strings, machine-specific paths and Steam-ID references across them; the hosted server log also contains credential-related words, but the presence of an actual secret has not been established. Subsequent privacy cleanup retained hash-verified raw copies in Git-ignored `diagnostic-logs-private/` and replaced the tracked working copies with diagnostic-only lines, redacted usernames, and placeholders preserving line numbers. Non-diagnostic evidence such as stack traces is available in the local private copies, not those extracts. This is a conservative filter, not a guarantee of anonymity; review before sharing. Commit `c806506` and any copies of its history still contain unsanitized logs. No history was rewritten and no additional logs were committed.

### Milestone 4 handoff

**Milestone:** Partial: consumption and transport candidate instrumentation plus capacity and moodle read-only preflights prepared. No in-game Milestone 4 experiment was run by Codex.

**Findings:** Existing SP/hosted MP item observations remain valid for their tested revisions. Candidate nutrition access is source/class-name supported but not verified at runtime. Capacity mutation is stopped pending safe restoration; native moodle registration remains blocked on exposure and lifecycle evidence. Transport uses a server-generated synthetic record and requires human runtime verification.

**Files changed:** `FoodEffectsDiagnostics/42/media/lua/shared/FoodEffectsDiagnostics/{Config,Consumption,Diagnostics,Feasibility}.lua`, client/server diagnostic Lua files, `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`.

**Tests executed:** Read-only local source, JAR-name metadata and Git log/privacy pattern inspection; static `git diff --check`. No Lua compiler was found and no game, dedicated server, stat mutation, moodle registration, persistence, or network probe was executed for this candidate.

**Tests requiring human execution:** Each independently enabled experiment as above, starting with SP food and then hosted MP; identify a functioning debug evaluator before manual probes. Repeat without debug/admin powers where practical and record revision and settings.

**Failed experiments and limitations:** Previous MP `getJobDelta` failure still awaits server retest. Capacity restoration and native registration are unproven, so their requested mutation/visible-moodle experiments are not implemented. Transport, elapsed world-age semantics, class Lua exposure, and contribution authority remain unverified. Debug probes depend on a not-yet-verified evaluator. No normalized contribution or production effect exists.

**Proposed architecture:** FE-008 remains proposed. Prefer observing the narrowest proven mutation boundary and structurally avoiding nested duplicates; local action IDs are diagnostic only. Validate any eventual contribution as finite and non-negative; do not treat NaN as zero or item disappearance as proof of consumption.

**Decisions required:** No new gameplay decision is approved. FE-009 offline expiration remains proposed; review capacity, presentation, nutrition scope and balance only after evidence exists.

**Recommendation:** The first production effect is not yet technically feasible to approve: reliable authoritative contribution, reversible modifier ownership, persistence/transport, and a presentation route remain unproven.

## Milestone 4 SP nutrition observation (2026-11-26)

**Milestone:** Human-run SP consumption probe captured player and item nutrition around repeated portions, removal, and two interruptions.

**Environment and revision:** Build 42.22.2 `3d39148846`; repository `82b6ffc` with local configuration changed to `consumption=true` and the other three flags false. The installed diagnostic directory is a junction to this repository. Debug mode, instant-action options, and administrator settings for this specific run were not established. Raw source evidence was copied to Git-ignored `diagnostic-logs-private/2026-11-26-1048-singleplayer/console.txt`; it contains player identity and should not be committed or shared unsanitized.

**Findings:** At log lines 834-839, the same `Base.BeefJerky` item was consumed as quarter, half, remainder. Immediately surrounding each `complete` wrapper, the player's calorie values increased by 102.5, 205, and 102.5 respectively; the first two correspond to the decreases in the item, and the final increase equals the finite pre-removal remainder, while post-removal item fields were NaN. Player carbohydrate/lipid/protein changes in these examples likewise match the corresponding finite item changes to floating-point precision. Between actions player nutrition values also changed, so compare each immediate before/after pair, not separate action timestamps.

At lines 840-847, the user attempted an immediate and a later cancellation. Both entered `serverStop` and nested `eat`, with observed progress/argument fractions approximately 0.07931 and 0.38966; both produced player and item changes. The early attempt therefore does not establish a zero-consumption cancellation. `serverStop` and `eat` bracket the same mutation, not two independent contributions. The Lua `complete` return was true; it is not the inner Java `Eat` return. These are observations for this SP sequence, not evidence that item deltas always equal player nutrition or that MP authority matches SP.

**Changed files:** `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`; private raw log copy created, no gameplay or diagnostic code changed. User's existing `Config.lua` edit remains intact.

**Verified functionality:** In this SP run player nutrition getters returned values, correlation and progress fields appeared, and no matching diagnostic `snapshot-error`, `record-error`, or prior `getJobDelta` error was found in the captured console log. The log copy was hash-checked against its source.

**Unverified assumptions / failed experiments:** Zero-progress cancellation was not achieved. Other food properties, clamping, removal for non-consumption, debug-mode effects, multiplayer nutrition authority and synchronization, and the guarded getter on the server remain unverified. No production transaction identity or normalization algorithm is established.

**Decisions required:** None; FE-007 continues to block production gameplay implementation.

**Next steps:** Run the same controlled actions on hosted MP and inspect both server and client logs, including the guarded progress lookup; then separately examine cancellation without a mutation and nutrition clamping. Record debug/admin settings and preserve raw logs privately.

## Milestone 4 hosted MP nutrition observation (2026-11-26)

**Milestone:** Human-run hosted MP consumption probe compared server player nutrition and item snapshots and retested the guarded progress lookup.

**Environment and revision:** Build 42.22.2 `3d39148846`, repository `82b6ffc` with local `Config.lua` modified to `consumption=true` and other switches false. Diagnostic installation is a junction to the repository. Debug and admin settings during this run were not established. Raw server and client logs were copied and hash-checked to Git-ignored `diagnostic-logs-private/2026-11-26-1050-multiplayer/`; they contain identifying information and must not be committed unsanitized.

**Findings:** Server lines 2532-2547 show one beef jerky item consumed as quarter, half, remainder: player calorie gains of 102.5, 205, and approximately 102.5001; corresponding finite item decreases were 102.5 and approximately 205, followed by NaN on removal from a finite pre-state of approximately 102.5. Additional quarter consumption used a second item. Carbohydrate, lipid, and protein changes likewise match observed item decreases in these recorded actions to floating-point precision. This is evidence for the observed hosted server actions, not universal proof of authority or of player-nutrition deltas as contribution under clamping or concurrent effects.

Server lines 2549-2557 show two interrupted actions with `eat` arguments approximately 0.09030 and 0.51401 and matching player/item calorie changes. Both consumed food; a zero-consumption cancellation was not established. Nested `serverStop`/`eat` snapshots are one observed action each. Server progress was `networkProgress` while `jobProgress` was nil. Server and client captures contain no matching diagnostic snapshot/record errors or prior `getJobDelta` exception. The client loaded wrappers but had no `ISEatFoodAction` phase records in this capture, so client-side food nutrition changes and explicit synchronization are not established.

**Changed files:** `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`; two raw logs copied privately. User's existing diagnostic config change remains intact.

**Verified functionality:** Specific SP and hosted MP tests returned player nutrition readings and the recorded values above; guarded progress logging did not produce the previous matching error in this hosted MP run. This does not establish standalone dedicated-server coverage or all invocation contexts.

**Unverified assumptions / failed experiments:** Zero-progress cancellation was not achieved; item removal unrelated to consumption, player nutrition clamping, other foods, debug/admin effects, replication, duplicates beyond these nested cases, and a production-safe observer remain unproven.

**Decisions required:** None; FE-007 still blocks production gameplay effects.

**Next steps:** Test controlled edge cases and nutrition limits; investigate verified access to a Lua evaluator for the independent persistence, transport, capacity and moodle preflights. Later run standalone dedicated MP and repeat without debug/admin powers as appropriate.

## Log privacy cleanup handoff

**Milestone:** Working copies of the four tracked logs filtered to diagnostic lines with usernames redacted; non-diagnostic lines replaced by placeholders to retain line numbers.

**Findings:** Previous commit `c806506` still contains raw logs. The raw local backups in `diagnostic-logs-private/` were copied and hash-checked before filtering and are excluded through `.gitignore`.

**Changed files:** Four tracked `diagnostic-logs/` files, `.gitignore`, `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`. Raw private copies were created locally; no history was rewritten.

**Verified functionality:** The private backup paths are ignored, the filtered files have no matches for the configured username, credential-keyword, network address, Steam-ID, or local-user-path patterns, and `git diff --check` passed.

**Unverified assumptions:** Pattern filtering cannot guarantee complete anonymization or identify every sensitive value. The exposure of prior history on any remote has not been determined.

**Decisions required:** Human review of the extracts and of any history-rewriting or remote cleanup plan; neither requires deleting this working repository by default.

**Next steps:** Avoid sharing raw logs or existing history until reviewed; decide whether historical cleanup is required based on remote visibility and exposure.

## Milestone 5: targeted feasibility closure (in progress, 2026-11-26)

**Milestone:** Prepared the isolated capacity and consumption-boundary diagnostics; Java-body inspection is presently blocked by local tooling availability. No production gameplay code was introduced.

**Local-source and tooling findings:** The installed Build 42 Lua reads carrying capacity through `character:getMaxWeight()` in `media/lua/client/Hotbar/ISHotbar.lua:573`, `media/lua/client/ISUI/ISInventoryPage.lua:637`, and `media/lua/server/XpSystem/XpUpdate.lua:33`. These are readers, not writers. A local class-file inventory still confirms `IsoPlayer` declares `getMaxWeight`, `getMaxWeightDelta`, and `setMaxWeightDelta`; it does not prove their bodies, field ownership, recalculation paths, serialization, or synchronization. The game-bundled `jre64\\bin` contains `java.exe` but no `javap.exe`, `jar.exe`, or compiler. No system JDK/decompiler was found. An attempt to retrieve CFR 0.152 for local, tooling-only use failed because `www.benf.org` could not be resolved. Therefore no Java method body, caller, field-ownership, serialization, or network claim is made from metadata alone.

**Diagnostic changes:** `FoodEffectsDiagnosticsConfig.capacityMutation` defaults to `false` and additionally requires `capacity=true`. When both flags are deliberately enabled, `FoodEffectsDiagnostics.probeCapacityMutation(player)` records the baseline delta and effective capacity, calls the source/class-evidenced setter with the separately configured test delta, logs the resulting values, then immediately attempts to restore the baseline and logs the restoration result. It is a disposable-character experiment only; it has no deferred state, automatic persistence test, production ownership claim, or safe-removal guarantee. The capacity preflight remains read-only unless that second flag is enabled. Food instrumentation now writes a `candidate=food-observation-boundary` marker only after a changed `ISEatFoodAction.complete` or `ISEatFoodAction.eat` invocation. It deliberately does not mark the enclosing `serverStop`, avoiding a diagnostic duplicate for its nested `eat` path.

**Moodle, persistence, and transport status:** No local vanilla Lua registration call for `MoodleType` was found by the targeted scan. Native Moodle registration, initialization, rendering, icons, tooltips, and Lua exposure remain unverified; no synthetic moodle is registered. The existing independently guarded SP record and server-originated transport probe remain unchanged and require runtime tests. They continue to reject client-provided nutrition/effect values because the client request has no contribution fields and the server creates the record/count/world-age payload.

**Verified functionality:** Static review of the changed Lua confirms the mutation flag defaults off, the setter is only reached with both capacity flags enabled, and the restoration call uses the captured baseline. The local vanilla scan verifies the cited `getMaxWeight` readers. `git diff --check` is required before handoff; no game runtime, capacity write, moodle registration, persistence, reconnect, dedicated-MP, or Java decompilation test has run in this milestone.

**Unverified assumptions / blockers:** `setMaxWeightDelta` Lua exposure and semantics; its effective-capacity formula; all writers; update/recalculation timing; serialization and MP replication/enforcement; interaction with vanilla/third-party modifiers; restoration after crash/save/reload; nutrition clamping; zero-progress cancellation; third-party foods; and every native moodle lifecycle surface. The diagnostic's immediate restoration is a safety measure for a disposable test, not evidence of production-safe restoration.

**Decisions required:** None yet. Protein-based carrying capacity is not ready to approve as the first production vertical slice because the modifier's implementation and multiplayer lifecycle have not been inspected or runtime-tested. FE-007 remains active.

**Next steps:** Install or make available a local JDK/decompiler and inspect the target bytecode before interpreting the capacity experiment. Then run one consolidated disposable-character procedure: (1) record revision, diagnostic hash, debug/admin settings, and all enabled flags; (2) run capacity inspection followed by one immediate-restore mutation; (3) cause an ordinary vanilla capacity-affecting update and re-inspect; (4) run the existing SP persistence probe, save/load, malformed-record, and removal/reinstall cases; (5) repeat server-owned transport, capacity inspection/mutation, reconnect, restart, and character-separation cases in hosted then standalone dedicated MP; (6) run moodle exposure only, stopping before registration unless Java/lifecycle evidence exists. Keep raw logs private and commit only redacted evidence.

## Java tooling follow-up (2026-11-26)

**Milestone:** Local decompiler available. CFR 0.152 was downloaded to `tools/cfr-0.152.jar` and its version command succeeded using the game's bundled Java. Its SHA-256 is `F686E8F3DED377D7BC87D216A90E9E9512DF4156E75B06C655A16648AE8765B2`. `tools/` is Git-ignored; this tool is not a mod dependency.

**Findings and verified functionality:** The version command ran successfully; no game method bodies have yet been inspected with it. The earlier DNS failure no longer blocks acquiring the tool.

**Changed files:** `.gitignore`, `TODO.md`, `CHANGELOG.md`, and `TECHNICAL.md`; the local untracked tool was downloaded separately.

**Unverified assumptions:** Capacity formula and lifecycle, nutrition clamping, and native moodle lifecycle remain open as listed in the preceding handoff. No runtime experiment was performed.

**Decisions required:** None; FE-007 remains active.

**Next steps:** Inspect capacity method bodies, writers, serialization and network paths first; then consumption/nutrition and moodle lifecycle. Finish diagnostic controls and validation before presenting a consolidated disposable-save test procedure.

## Milestone 5 bytecode inspection handoff (2026-11-26)

**Milestone:** Initial local method-body inspection completed with CFR 0.152 and bundled Java. Source is the installed `projectzomboid.jar`, SHA-256 `3C4A7C5F149D784758C6FB5F8FA85F3A21D572E38BC081400E89035F8120D287`; repository HEAD `f0258205f6f5522dbadc6b1a451ee5a4f2c08133` with existing uncommitted diagnostic changes. Generated inspection output is local and ignored under `tools/decompiled/`.

**Findings:** `zombie/characters/IsoPlayer.class`, field `maxWeightDelta`, starts at 1.0; two constructors assign 1.5, 0.75, 0.9 or 1.25 for STRONG, WEAK, FEEBLE or STOUT respectively. `getMaxWeightDelta` returns the field and `setMaxWeightDelta` directly assigns it. This is a shared trait-related scalar, not a dedicated FoodEffects modifier. `zombie/characters/IsoGameCharacter.class` declares separate integer `maxWeight` and `maxWeightBase` fields initialized to 8; `getMaxWeight` returns the former and `setMaxWeight` assigns it. Thus the delta setter itself does not immediately recalculate `getMaxWeight`. The calculation and other-class writers, save/load, networking and enforcement still require tracing. A setter-based diagnostic that immediately restores the scalar cannot establish its effect after a later recalculation.

`IsoGameCharacter.Eat(InventoryItem,float,boolean)` rejects non-Food items, clamps the requested percentage, adjusts it using base/current hunger where applicable, and can round the remainder to full consumption. It adds live nutrients times the adjusted fraction to player nutrition; burnt food contributes one fifth of those amounts. It invokes the food's `OnEat` callback before full removal or partial `multiplyFoodValues`, so third-party callbacks can complicate snapshots. The server path sends player-stat and food-related packets. This is not proof of complete coverage or synchronization correctness. `zombie/characters/BodyDamage/Nutrition.class` setters clamp calories to [-2200, 3700] and each of carbohydrate, protein and lipid to [-500, 1000]. Player accumulator deltas can therefore understate food contribution at a bound, independent of the burnt-food difference.

**Changed files:** `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`; generated local inspection output only. No gameplay or diagnostic code changed in this pass.

**Verified functionality:** Static decompilation of the named local classes and methods; no runtime experiment. `IsoPlayer` constructor assignments and direct delta accessor bodies were inspected. No assertion is made that the scanned classes contain all writers or network paths.

**Unverified assumptions / blockers:** Effective-capacity recalculation, external writers, serialization and client/server enforcement; mutation probe timing and Lua exposure; full consumption boundary coverage and callback interference; native moodle lifecycle; persistence and transport tests. Existing food observations remain valid for their tested cases but do not establish a universal normalization rule.

**Decisions required:** None. Protein-based carrying capacity remains unapproved and FE-007 remains active.

**Next steps:** Trace cross-class capacity writers and serialization/network paths, inspect moodle lifecycle, and improve diagnostic controls and record validation before requesting the consolidated runtime tests.

## Capacity calculation investigation (2026-11-26)

**Milestone:** Located the vanilla recalculation and one network packet carrying effective capacity. Investigation is incomplete; no runtime test was run.

**Findings:** In installed `projectzomboid.jar`, `zombie.characters.BodyDamage.BodyDamage.UpdateStrength` calculates `maxWeight = max(0, (int)(maxWeightBase * weightMod) - conditionReducers)` and, for an `IsoPlayer`, assigns `(int)(maxWeight * maxWeightDelta)`. Java integer conversion truncates each indicated stage. `IsoGameCharacter.getWeightMod` selects a multiplier from Strength perk level. The reducers depend on hunger, thirst, sickness, bleeding and injury moodle levels. `BodyDamage.Update` calls `UpdateStrength`, but returns early for living players on a multiplayer client and also returns early for god mode. `IsoGameCharacter`'s update calls `BodyDamage.Update` when character stats are enabled. This establishes execution guards, not complete multiplayer authority or timing.

`zombie.inventory.ItemContainer.getMaxWeight` delegates to its character parent's `getMaxWeight`; `getCapacityWeight` has unlimited-carry and debug ghost-mode exceptions. `zombie.network.packets.character.PlayerDamagePacket.write/parse` transmits and assigns the effective integer max weight alongside body damage. Its send frequency, recipients and complete direction/authority have not been established; `PlayerInventoryPacket` separately reports max weight for an administrative inventory inspection, which is not evidence of normal synchronization. No delta field serialization was found in the inspected `IsoPlayer`/`IsoGameCharacter` source, but a complete save/network audit remains open. Other mods can call the public setter or change related fields, so a saved baseline is not exclusive ownership.

**Changed files:** `TECHNICAL.md`, `TODO.md`, `CHANGELOG.md`; generated decompiler output remains Git-ignored. No game or diagnostic code changed.

**Verified functionality:** Static inspection of the named methods in the local installed jar. A broad CFR pass failed with an out-of-memory error after producing partial output, so searches of that output are not exhaustive. No runtime verification.

**Unverified assumptions / blockers:** Complete writers and serialization, packet trigger/direction and enforcement on all sides, third-party interactions, and behavior across reload/removal. The immediate-restore diagnostic does not hold the delta across an update and therefore cannot measure the recalculated capacity. Moodle lifecycle and diagnostic interface remain open.

**Decisions required:** None; FE-007 remains active. The shared scalar and execution-side differences prevent concluding production safety.

**Next steps:** Trace `PlayerDamagePacket` send/receive and character save/load with targeted decompilation; design a disposable, explicitly enabled delayed restoration experiment with conflict detection before runtime tests. Continue moodle and diagnostic usability investigation.

## Capacity packet and save follow-up (2026-11-26)

**Milestone:** Inspected the normal damage-sync caller and the player/character byte-buffer save methods. Static findings only; no experiment was run.

**Findings:** `zombie.network.NetworkPlayerManager.update` checks a 2,000 ms damage timer on the server and calls each player's `NetworkPlayerAI.syncDamage`. That method requires a fully connected, non-delayed-disconnect connection and sends `PlayerDamage` to the player; `PlayerDamagePacket.write/parse` writes and assigns the effective integer max weight. Other damage-triggered sends also exist. This supports periodic server-to-owning-client propagation of the calculated value, subject to runtime confirmation; it does not show scalar synchronization or prove every enforcement path. A living multiplayer client's `BodyDamage.Update` early return makes the server calculation particularly relevant.

The inspected `IsoPlayer.save/load(ByteBuffer,...)` and `IsoGameCharacter.save/load(ByteBuffer,...)` bodies do not directly serialize `maxWeightDelta`, `maxWeight`, or `maxWeightBase`; they delegate to superclass and component save/load methods, which have not been exhaustively audited. The constructors initialize the scalar based on traits available at their execution time. Do not infer exact values after reload until construction/load ordering and a runtime test are established.

**Changed files:** `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`. Existing diagnostic files were not changed in this pass.

**Verified functionality:** Local CFR method-body inspection and `git diff --check`; no SP/MP execution or persistence test. The earlier broad decompilation failed with out-of-memory and its output is incomplete.

**Unverified assumptions / blockers:** Complete superclass/component serialization and character creation/load ordering, packet behavior in a live hosted or dedicated session, other writers, and safe modifier ownership. The current immediate-restore setter experiment remains insufficient to observe an update. Moodle lifecycle and usable diagnostic controls are still pending.

**Decisions required:** None; FE-007 remains active.

**Next steps:** Finish targeted load/creation and enforcement tracing, then prepare a guarded delayed mutation/restoration probe and consolidated tests; investigate moodle lifecycle and validation in parallel only as independent work permits.

## Capacity delayed probe preparation (2026-11-26)

**Milestone:** Prepared an explicitly enabled, disposable-character delayed scalar experiment. It is not yet runtime-tested or ready as a consolidated test handoff.

**Findings:** Local `zombie.savefile.ServerPlayerDB.serverLoadNetworkCharacter` constructs `IsoPlayer(IsoCell)` before invoking `load`; that constructor delegates to the descriptor constructor. The full later trait/load initialization path remains unresolved. `ItemContainer.hasRoomFor`-related paths include `canAccept`/`getAvailableWeightCapacity` checks, and `getAvailableWeightCapacity` subtracts occupied weight from character-derived maximum; complete server transfer enforcement remains unverified.

**Changed files:** `Config.lua` changes the experimental scalar default from 5 to 1.25; `Feasibility.lua` holds the explicitly enabled mutation for 120 `OnTick` callbacks, logs effective capacity, and attempts baseline restoration only if the observed scalar has not changed. Client-side initiation is rejected. `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md` updated.

**Verified functionality:** Static inspection only. The `OnTick` event is used in installed `media/lua/server/Foraging/forageServer.lua:502` and `media/lua/client/Chat/ISChat.lua:943`; event timing and this probe are not runtime-verified. `git diff --check` is pending at this handoff.

**Unverified assumptions / blockers:** 120 ticks do not guarantee a body-damage update; actual client/server execution, setter Lua exposure, signal timing, load behavior and enforcement are untested. Equality-based conflict detection cannot detect another writer that writes the same value. Process exit, Lua errors, or removal before restoration can leave the disposable character altered; restoration of effective capacity requires a subsequent vanilla update. Do not use on valued saves. The probe has no GUI or server command and needs further usability work.

**Decisions required:** None; FE-007 remains active.

**Next steps:** Add a post-restoration observation and a source-verified interface, review error/cleanup behavior, finish persistence and moodle investigation, and only then supply consolidated runtime instructions.

## Diagnostic usability follow-up (2026-11-26)

**Milestone:** Added a post-restoration sample and a minimal world context menu for independently enabled probes. This is an untested diagnostic candidate, not a production interface.

**Findings:** Installed `media/lua/client/DebugUIs/AdminContextMenu.lua:20-40,88` demonstrates `OnFillWorldObjectContextMenu`, `getSpecificPlayer`, `context:addOption`, `ISContextMenu:getNew` and `addSubMenu`. The diagnostic menu exposes enabled local capacity and moodle inspections, SP persistence, client transport request, and SP-only capacity mutation. It does not expose server-side capacity mutation; a secured server control path still needs design and verification.

**Changed files:** `FoodEffectsDiagnostics/42/media/lua/shared/FoodEffectsDiagnostics/Feasibility.lua`, `FoodEffectsDiagnostics/42/media/lua/client/FoodEffectsDiagnostics_Client.lua`, `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`.

**Verified functionality:** Static source comparison only. The capacity experiment now records effective capacity after a second 120-tick interval following a successful restoration call. Neither tick count guarantees a vanilla recalculation. `git diff --check` will be run at handoff. No in-game menu, mutation, persistence, or multiplayer test has been executed.

**Unverified assumptions / blockers:** Menu load and callback behavior, event scheduling, Lua setter access, same-value concurrent writes, interruption and restoration, server-side mutation controls, schema validation, moodle lifecycle and dedicated MP. A crash or shutdown before restoration may leave the disposable character altered. Do not run on valued saves. Existing notes describing the original immediate-restore probe are historical; this entry and the preceding delayed-probe handoff supersede them.

**Decisions required:** None. FE-007 remains active.

**Next steps:** Review malformed-record validation and server-side diagnostic authorization; investigate moodle registration and rendering before assembling a consolidated human test procedure.

## Moodle and synthetic-record investigation (2026-11-26)

**Milestone:** Inspected native moodle method bodies and tightened synthetic counter validation. No runtime test or native registration was performed.

**Findings:** In the installed jar, `zombie.scripting.objects.MoodleType` is annotated `@UsedFromLua` and its public `register(String)` delegates to the registry with a non-default namespace; the boolean overload and `registerBase` are private, correcting the earlier metadata-only description. `zombie.characters.Moodles.Moodles` snapshots registry values into its per-character map in its constructor; a late-registered type is absent from existing maps, and accessors dereference the map result. `Moodle.Update` starts at level zero, uses explicit native-type branches, and its level setter is private. No general custom-level callback was found in that method. `MoodlesUI` similarly snapshots registry values at construction, renders positive levels, and requests translated display and description strings from `Moodles`; those keys are built from the type translation name and level. Icon resolution and registry freeze/timing still need inspection. Annotation and public Java methods alone do not prove a working Lua registration path or custom display. A viable native custom-level route is not yet established; a minimal client display consuming server-owned state is a possible fallback requiring human approval, not a decision.

The synthetic persistence/transport counter formerly accepted unknown schema versions, fractional values, and the upper-bound value that then incremented beyond its bound. Shared `nextProbeCount` now accepts schema 1 and integer counts from 0 through 999999; absent, malformed, unknown-schema or exhausted records restart at 1 and log their status. This is a disposable diagnostic record, not a production migration policy. The server continues to construct its own response and ignores client payload fields.

**Changed files:** shared `Diagnostics.lua` and `Feasibility.lua`, server `FoodEffectsDiagnostics_Server.lua`, `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`.

**Verified functionality:** Static method-body inspection and validation review only; no Lua runtime, malformed-record, moodle or transport test. `git diff --check` is required at handoff.

**Unverified assumptions / blockers:** Registry initialization and freeze timing, icon lookup, possible source-available extension approaches, dynamic tooltip support, menu and record runtime behavior, secured server capacity controls, and dedicated MP. No custom moodle or fallback UI is implemented.

**Decisions required:** None now. Any fallback presentation requires human approval; FE-007 remains active.

**Next steps:** Inspect moodle texture and registry lifecycle, review the guarded capacity experiment and server-control design, then prepare and verify the consolidated test procedure.

## Moodle texture and probe ownership follow-up (2026-11-26)

**Milestone:** Inspected native icon and registry implementation and strengthened the delayed probe's ownership check. The test suite is not yet ready for human execution.

**Findings:** `zombie.ui.MoodleTextureSet` constructs a private map containing explicit vanilla MoodleType-to-texture mappings; `getTexture` returns its map lookup. `MoodlesUI.render` dereferences the returned texture without a null check. An arbitrary registered type therefore has no evidenced vanilla icon mapping and could fail if rendered. `zombie.scripting.objects.Registry.register` has no freeze check in the inspected body, but inserts before detecting duplicates; `RegistryReset.resetAll` removes non-base entries, and `IngameState` calls it. Exact Lua load and reinitialization timing remains unverified. Together with the private level setter and constructor snapshots, this prevents recommending a standalone native registration experiment on current evidence. A small client display for server-projected state remains a proposal requiring approval.

**Changed files:** `Feasibility.lua` now starts delayed ownership only when the successful setter readback matches the requested target within tolerance; otherwise it logs unconfirmed ownership and does not overwrite an unexpected value. `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md` updated.

**Verified functionality:** Static local bytecode and Lua inspection only. `git diff --check` is required at handoff. No runtime testing was performed.

**Unverified assumptions / blockers:** A failed setter could have partially changed the scalar; process interruption and same-value external writes remain indistinguishable. The delayed probe cannot promise restoration. Server-side mutation control needs a verified admin authorization and disconnect/cleanup design; client-provided values must never be accepted. Moodle registration timing and third-party extension mechanisms remain open. No human test procedure is ready yet.

**Decisions required:** None now; approving any fallback UI remains a human decision, and FE-007 is active.

**Next steps:** Research source-available custom moodle approaches and verified server authorization/cleanup APIs; complete diagnostic safeguards and test instructions before requesting runtime tests.

## Server guard and custom moodle research (2026-11-26)

**Milestone:** Located a vanilla server capability check and reviewed two source-available custom moodle project descriptions. No new server mutation endpoint or presentation was added.

**Findings:** Installed `media/lua/server/ClientCommands.lua:794,1330,1339` checks `player:getRole():hasCapability(Capability.UseDebugContextMenu)` on server command handlers. This is a source-evidenced candidate guard for a diagnostic request, in addition to a server-side configuration switch and server-selected value; it does not by itself address disconnect or cleanup. The inspected `LuaEventManager`/`GameClient` shows `OnDisconnect` triggered on the client; no equivalent server player-disconnect event was established by this targeted search. Absence from a partial search is not proof that no hook exists.

The source-available [Moodles in Lua](https://github.com/molecule31/moodlesinlua) project describes disabling vanilla moodle rendering and drawing a replacement; [Moodle Customization Framework](https://github.com/dreamweavevisuals/MoodleCustomizationFramework) likewise describes custom rendering. Both repositories identify GPL-3.0 licensing. These descriptions support the custom-rendering direction but are not a code-level compatibility audit or proof of compatibility with installed 42.22.2. No code or dependency was copied. A possible minimal alternative is a separate small client indicator and tooltip fed by server-projected effect state, leaving the native moodle HUD intact; its visual design and use remain subject to human approval.

**Changed files:** `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md`; no diagnostic code changed.

**Verified functionality:** Static vanilla source and public repository descriptions only. No server authorization, disconnect, or presentation runtime test was performed. `git diff --check` is required at handoff.

**Unverified assumptions / blockers:** Server disconnect lifecycle, cleanup after process termination, capability behavior in hosted/dedicated MP, and compatibility of third-party renderers. A server mutation control must not accept client-provided values or target another character and needs explicit server enablement. The diagnostic experiment can be run only on disposable characters; this is not a production restoration guarantee.

**Decisions required:** Human approval is required before adopting a fallback presentation. FE-007 remains active.

**Next steps:** Trace server disconnect and player lifetime in Java, implement and statically review an independently guarded server probe if its cleanup behavior can be made explicit, and prepare one consolidated test procedure with exact revision, hashes and configuration.

## Guarded server capacity probe (2026-11-26)

**Milestone:** Added a separately enabled, capability-guarded server diagnostic request for the requesting disposable character. The human indicated dependency mods may be acceptable; no particular dependency or presentation is selected or approved.

**Findings:** Installed `zombie.network.GameServer.disconnect` calls `ServerPlayerDB.serverUpdateNetworkCharacter` before `disconnectPlayer`; `disconnectPlayer` removes the player from server maps and world. A later tick-based restoration is not guaranteed to precede this save/removal. The diagnostic therefore must not be used on valued characters or treated as evidence of a production lifecycle.

**Changed files:** `Config.lua` adds `capacityMutationServer=false`; server handler requires `capacity`, `capacityMutation`, and `capacityMutationServer`, plus the vanilla `Capability.UseDebugContextMenu` check. It takes the player from the server command event, ignores request data, and uses the server's configured scalar. The client menu sends an empty request when its matching switches are enabled. `TECHNICAL.md`, `TODO.md`, and `CHANGELOG.md` updated. No gameplay or dependency mod was added.

**Verified functionality:** Static inspection and `git diff --check` only. No server, client, authorization, disconnect or restoration runtime test. HEAD `f0258205f6f5522dbadc6b1a451ee5a4f2c08133`, with uncommitted diagnostic edits. Diagnostic SHA-256: client `9C7049246A8D5CEAB666FDA9AD56C05DDFF7242493E04A9B53690D9A5811AA0C`; server `B185495F3583938E4CBCF4453B8AA03C18743493E08A9F4AEC823E2C7A89DB15`; Config `B2038A0CFFC2E52859C5B099758A370E09639F21C8CD042012BCB9962978D532`; Consumption `EF556C235DD7FC0E69AB553056142F996D6C25501921FE67FE979BE6B9AC9BF4`; Diagnostics `44C2196F61D234C5B0A1B5C8342FDE5B39AE74A17F2761516AF1207946EC820F`; Feasibility `5C7B79C7386CBA3222472421AABD754159442A7D318C70954D189F0A961E11D9`; both mod.info files `E9976EFFEDF0EA4C9DAFFA687F100FA5A2674E1725209E64F13906E0A074EAB1`.

**Unverified assumptions / blockers:** Server `OnTick` scheduling, role/capability availability, UI callback, setter access, targeted packet timing, interruption, disconnect, restart, and same-value concurrent writes. Server saves can occur during the probe. One global active experiment per Lua process is permitted. This remains diagnostic-only and restoration is not guaranteed.

**Decisions required:** Evaluate prospective moodle dependencies for Build 42.22.2, SP/MP, lifecycle, license and maintenance before selecting one; the user's openness is not a choice of framework. FE-007 remains active.

**Next steps:** Review the entire candidate for fault handling and prepare a consolidated disposable-save procedure including disabled-by-default switches, admin/debug settings, server and client logs, persistence, malformed data, and removal/reinstallation.
