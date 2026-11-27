# Development handoff

## Current status

FoodEffects is in feasibility research. `FoodEffectsDiagnostics` is an experimental mod; no production gameplay effect has been implemented. Read `AGENTS.md`, `DESIGN.md`, `DECISIONS.md`, and the current priorities in `TODO.md` before continuing. The detailed evidence and historical handoffs are in `TECHNICAL.md`.

FE-007 blocks gameplay implementation until a server-authoritative post-consumption path, a reversible stat surface, and a presentation route have been verified and reviewed. The human must approve the first effect, balance, presentation, and relevant gameplay or compatibility trade-offs.

## What has been established

- One uninterrupted single-player test and one uninterrupted dedicated-server test observed capacity rising from 12 to 15 after changing the scalar from 1 to 1.25, then returning to 12 after restoration. In the dedicated test the client observed effective capacity changes while its scalar remained 1. These tests do not prove safe saves, removal, disconnects, restart, enforcement, or crash recovery.
- Dedicated-server observations covered one salad preparation and partial consumption, plus a separate paired client/server snapshot and reconnect. They do not establish a trusted universal consumption hook or general third-party food support.
- Synthetic diagnostic records survived selected single-player and dedicated-server save/reconnect/restart cases; a synthetic deadline expired while server world time advanced during a disconnect. Production effect persistence is unverified.
- A bounded review of local save/load paths found no direct serialization of the capacity fields in the main inspected method bodies. A game-archive string scan narrowed direct references to the scalar field or setter, but does not exclude indirect persistence, reconstruction, native code or Lua. Final scalar initialization after reload is unverified.

## Next work

1. Design and review a narrowly focused, disposable capacity lifecycle comparison. Determine how to confirm a save while a scalar differs from its baseline, observe server traits, scalar and effective capacity before and after reload, and prevent the diagnostic from rearming. Do not assume a save occurred or that a changed/reset value alone identifies serialization versus reconstruction. Only request a human test if it resolves a meaningful question and its safety and limits are clear.
2. Continue server-authoritative consumption and nutrition-provenance research. Client-supplied item-state paths are a trust concern, not a demonstrated exploit; avoid unsupported claims or validation rules that silently exclude legitimate dynamic or third-party foods.
3. Investigate reversible capacity lifecycle and presentation, then propose a concrete first slice for human approval. See `TODO.md` for the full testing, compatibility, expiry and documentation work.

## Operational notes

- All diagnostic switches are false and the automatic capacity probe's account is unset on disk. Restart any already-running server or client before relying on changed settings. Before asking for a test, set and verify its configuration, explain which processes to restart, and reset it afterward.
- The automatic server probe is diagnostic-only, targets a configured account, and rearms on restart while enabled. It cannot guarantee cleanup after interruption, save or failure; use only a disposable server and character. Its last observed uninterrupted test is documented in `TECHNICAL.md`.
- Local game logs and decompiled inspection tools are ignored and are not available merely by cloning the repository. Findings are recorded in Markdown; reacquire local Build 42 game files and tools on another computer as needed. Never commit raw logs or private identifiers.
- Tracked log extracts were removed from the current tree; earlier Git history is unchanged. Whether older unsanitized logs were exposed on any remote remains unverified. Do not rewrite history or perform remote cleanup without the human's approval.
- Report the active `TODO.md` item and whether it is complete. Prefer lighter available models for bounded subagent tasks when session instructions permit, and document evidence and uncertainties in the repository rather than relying on chat memory.
