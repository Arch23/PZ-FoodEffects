# FoodEffects design

## Objective

Make cooking immediately useful for survival instead of relying exclusively on opaque, long-term nutritional mechanics.

## Agreed initial direction

- Derive temporary gameplay effects from existing nutritional values. The initial research scope is protein, carbohydrates, calories, seasonings/happiness or meal quality, dietary variety, and Cooking proficiency. Lipids are experimental. Vitamins and illness-resistance effects are postponed until a reliable data source and implementation path are verified.
- Effects use duration stacking: a later qualifying consumption adds its nutrition-derived duration to that effect's remaining duration, clamped to that effect's configurable cap. It does not increase effect strength. Illustrative one-hour contributions and a 12-hour cap are examples only, not approved balance values.
- Recognize seasonings, herbs, and special ingredients. Prefer existing item tags/properties to item-ID lists, with compatibility definitions for third-party food mods.
- Reward dietary variety over time rather than by simply counting similar items or ingredients in one meal. Meal-level ingredient variety is a possible later complement only if provenance survives recipe construction.
- Let Cooking proficiency influence meal quality, which may later influence duration or effectiveness if the consuming and recipe paths prove safe. It must not create an unrelated permanent character bonus.
- Effects expire. Players must be able to discover effects in-game, preferably with native moodlets, tooltips, consumption notifications, numeric descriptions, and remaining duration.

## Explicitly postponed

Food preferences, food fatigue, freshness bonuses, overeating, and food poisoning require explicit approval before work begins.

## Future proposal: cook's satisfaction

The human proposes a happiness benefit for the cook when they finish preparing an elaborate, good meal, potentially recognized through multiple meaningful ingredients and spices. The recipient is the cook at completion, independently of any later effects on the eater. Qualification, effect magnitude and duration, repeat-prevention, technical feasibility, and implementation remain undecided; this is not authorization to implement the mechanic.

## Principles

1. Benefits should matter without making cooking mandatory.
2. Prevent excessive buff stacking through per-effect additive-duration caps, not unlimited strength stacking.
3. Encourage dietary diversity and elaborate cooking.
4. Keep behavior intuitive and discoverable.
5. Prefer native interfaces to intrusive custom UI.

## Compatibility baseline

Build 42; single-player and multiplayer; installation into existing saves; safe removal/reinstallation; compatible third-party foods with usable nutrition; no vanilla edits; no permanent stat changes; defensive custom-data handling.

Interoperability with other mods that alter carrying capacity is not required; disclose the limitation. Food mods that provide usable nutrition remain in scope, including the human's example of Vanilla Foods Expanded (not yet verified or tested).
