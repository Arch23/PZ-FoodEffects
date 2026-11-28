# FoodEffects working agreement

Read the project documentation before making changes. Never silently change agreed gameplay mechanics or architectural decisions.

- Distinguish verified facts from assumptions and unverified possibilities.
- Prioritize local Project Zomboid Build 42 game files and vanilla Lua over online documentation.
- Never invent game APIs, events, methods, properties, or registry identifiers. Support technical claims with file paths and relevant code references.
- Keep documentation synchronized with implementation. Update `DECISIONS.md` for approved architectural/gameplay changes, `TODO.md` for added, completed, or blocked work, and `CHANGELOG.md` for implementation changes.
- Treat the repository Markdown documentation as the durable project context. Record new findings and their evidence in the relevant files, including what is verified, what still needs validation, and concrete next steps.
- At the start of each task, consult the relevant repository documentation instead of relying on chat history or an agent's memory. After each meaningful research or test finding, record the result, evidence references, test conditions, limitations, open questions, and next steps in the appropriate repository Markdown files before the handoff. Create a focused, linked documentation file when the existing documents are not suitable. Do not put private raw logs in Git.
- Before writing or updating repository Markdown, make it suitable for a public repository: use neutral, portable paths and references; omit personal account names, credentials, private identifiers, network addresses, and raw private logs. Retain useful source and evidence references without exposing private data, and review changes for sensitive information before handoff.
- Keep diagnostic log files out of the tracked repository and retain relevant findings in Markdown. Removing files from the current tree does not remove earlier Git history, which needs separate review before any history rewrite.
- After changes, review the relevant repository Markdown files and the current open work against the project goals and approved decisions; correct stale or inconsistent status and keep follow-up work focused on those goals.
- Preserve earlier decisions; document the reason when a decision is superseded.
- Ask for human approval when a finding would change agreed gameplay design. Codex may propose, never approve, gameplay decisions.
- Treat multiplayer compatibility and existing-save compatibility as core requirements.
- Avoid vanilla-file changes, permanent character-stat changes, hard-coded food-ID lists, and unsafe handling of absent/malformed custom data.
- At each meaningful milestone, provide the handoff format in `TECHNICAL.md`/the task report: milestone, findings, changed files, verified functionality, unverified assumptions, decisions required, and next steps.
- Tell the human which `TODO.md` item is being worked on and report whether it was completed, including any remaining work when it was not.
- Before asking the human to run a diagnostic test, set and verify the required `FoodEffectsDiagnostics/42/media/lua/shared/FoodEffectsDiagnostics/Config.lua` values yourself, including disabling unrelated probes. Tell the human which processes must be restarted, and reset the switches after the test when appropriate.
- Ask for a human test only when it addresses a concrete unresolved question relevant to the mod's goals or an approved implementation gate. First use available source evidence and existing results, identify what the test can and cannot establish, and explain why its result matters to the next project decision. Avoid testing diagnostic controls or workarounds as ends in themselves; do not treat diagnostic-only requirements as production requirements. Keep test setup and steps focused and minimize unnecessary repeated human effort.

## Multi-agent collaboration protocol

The human developer is the final authority for gameplay, architecture,
compatibility trade-offs, and scope. The repository documentation is the
durable source of truth; do not rely on an individual agent conversation for
project memory.

- The primary agent orchestrates: it identifies applicable decisions and
  constraints, delegates only independent bounded work, consolidates evidence,
  maintains the shared documentation, and asks the human to approve unresolved
  gameplay or architectural choices.
- Every agent must consult applicable repository documentation and report new
  evidence and uncertainty for durable recording. Read-only specialists return
  findings to the primary agent; the primary agent records and reviews them in
  the repository before closing the milestone. Assign documentation ownership
  explicitly when another agent is permitted to edit, and avoid concurrent edits
  to the same files. A chat report alone is not the project knowledge base.
- Researchers investigate local Build 42 Lua, Java, diagnostics, and runtime
  evidence. Planners propose options, acceptance criteria, and trade-offs.
  Developers implement only approved work. Reviewers independently challenge
  evidence and changes. Specialist roles do not approve decisions for the
  human.
- Use read-only parallel research or review when it materially reduces risk or
  time. Do not make concurrent edits to the same files. Developers return work
  for independent review when the task warrants it.
- Follow the default lifecycle as applicable: identify constraints; research and
  plan; review uncertain or consequential conclusions; obtain human approval;
  implement; independently review; conduct required human in-game tests; close
  the milestone. Do not require every role for small, low-risk work.
- Each specialist report must state: assigned task, findings with supporting
  evidence, files changed, tests actually executed, unverified assumptions,
  blockers, recommendations, and decisions requiring human approval.
- Project roles live in `.codex/agents/`. They inherit the initiating session's
  permissions and must not delegate further work. The project caps direct
  concurrent subagents at three. When the session's subagent tool permits model
  overrides, explicitly select an available lighter, lower-cost model and an
  appropriate reasoning effort for bounded tasks that do not require heavy
  reasoning. Select a more capable model or higher effort when complexity or
  review risk warrants it. If choosing a model requires a fresh context, include
  the task, relevant repository instructions, evidence and constraints in the
  delegation. If an override is unavailable or prohibited, inherit the parent
  configuration and explain that limitation to the human. Respect the initiating
  session's available models and higher-priority instructions.
- Experimental instrumentation stays in `FoodEffectsDiagnostics`; production
  gameplay remains behind the existing approval gates. Keep raw private logs
  out of Git and review redacted diagnostic extracts before committing them.
