# FoodEffects working agreement

Read the project documentation before making changes. Never silently change agreed gameplay mechanics or architectural decisions.

- Distinguish verified facts from assumptions and unverified possibilities.
- Prioritize local Project Zomboid Build 42 game files and vanilla Lua over online documentation.
- Never invent game APIs, events, methods, properties, or registry identifiers. Support technical claims with file paths and relevant code references.
- Keep documentation synchronized with implementation. Update `DECISIONS.md` for approved architectural/gameplay changes, `TODO.md` for added, completed, or blocked work, and `CHANGELOG.md` for implementation changes.
- Preserve earlier decisions; document the reason when a decision is superseded.
- Ask for human approval when a finding would change agreed gameplay design. Codex may propose, never approve, gameplay decisions.
- Treat multiplayer compatibility and existing-save compatibility as core requirements.
- Avoid vanilla-file changes, permanent character-stat changes, hard-coded food-ID lists, and unsafe handling of absent/malformed custom data.
- At each meaningful milestone, provide the handoff format in `TECHNICAL.md`/the task report: milestone, findings, changed files, verified functionality, unverified assumptions, decisions required, and next steps.
