# Technical research

Research date: 2026-11-24. Evidence below comes from the local Steam installation at `C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid`. Its exact Build 42 revision was not established from the inspected files; validate it in the game launcher before implementation.

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
This architecture may proceed only after a diagnostic proves (1) one authoritative consumption observation point for every supported path, (2) player-record persistence and explicit client transport, (3) a reversible stat target, and (4) a minimal presentation route. If any precondition fails, retain nutrition-only diagnostics and revise the design for review.

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

For variety, record a compact, time-stamped set of nutrition-derived categories only after a successful authoritative consumption. Prune entries outside an undecided window on each mutation/load. This is third-party friendly but cannot distinguish foods with identical macro profiles; ingredient-category variety remains deferred until provenance is proven.

### Multiplayer, persistence, and failure behavior
In SP, the authoritative path and state manager run locally. In MP, the server alone validates consumption, mutates persistent state, expires effects, and applies/removes verified modifiers. The client receives a display-safe projection (effect key, expiry, fixed tier if approved) and may request a resync on login; it never submits nutrition or duration claims. Save/load and reconnect recompute remaining duration from `expiresAt`; offline world-time passage therefore expires effects naturally. Unknown versions, malformed records, missing definitions, and removal/reinstallation must result in validation, pruning, or safe no-op—not permanent base-stat edits. The exact player-data persistence and transport calls are still unverified and must be selected only after diagnostics.

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
