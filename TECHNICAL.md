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

## Finding: Not yet researched sufficiently

### Status
Unverified.

### Findings
The installed game includes `mods` and `Workshop` directories, but no mod skeleton/loading contract has been verified.

### Proposed implementation
Research a local vanilla/example mod or Build 42 loader documentation before creating any runtime files.

### Limitations
No `mod.info`, load-order, or script-placement claims are made.

### Questions requiring approval
None.

## Milestone handoff

**Milestone:** Documentation foundation and first local Build 42 source inspection complete; no gameplay code written.

**Findings:** Live Lua-readable calories/carbs/lipids/proteins; data-driven evolved recipes and `Spice`/`EvolvedRecipe` properties; queryable item tags; `IsoPlayer:Eat` call path; MP/persistence patterns only. Custom moodles, vitamins, post-eat hook, stat modifiers, and evolved-meal provenance remain unverified.

**Files created or modified:** `AGENTS.md`, `DESIGN.md`, `TECHNICAL.md`, `DECISIONS.md`, `TODO.md`, `CHANGELOG.md`.

**Verified functionality:** Static local-source inspection only. No in-game, SP, MP, save/load, or mod-loading test has run.

**Unverified assumptions:** Exact Build revision; vitamins; moodle extension; authoritative consumption interception; effect stat APIs; player-data replication; mod removal behavior.

**Design decisions required:** After feasibility research, approve effect targets/numbers/stacking, variety definition, cooking-quality formula, and fallback presentation if custom moodles are unavailable.

**Recommended next steps:** Locate the engine/mod loading contract and consumption event surface; run a minimal non-gameplay diagnostic mod in SP then dedicated MP; only then propose architecture.
