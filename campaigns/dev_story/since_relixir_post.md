# Since the r/elixir Post: April 19 – May 5, 2026

On April 19, 2026 the prior r/elixir post landed: *"Show r/elixir: A Phoenix development harness that shipped its first product"* ([1stnklw](https://www.reddit.com/r/elixir/comments/1stnklw/show_relixir_a_phoenix_development_harness_that/)). The claim of that post was that CodeMySpec had been used to generate MetricFlow -- a separate marketing analytics product -- almost entirely from inside the harness. By the time the post went live, MetricFlow was passing QA against twenty-five-plus user stories.

Seventeen days and roughly two hundred commits later, the harness is shipping a second product (Market My Spec) and most of its assumptions about *how* a project plugs into the harness have been replaced with knobs. This is the story of that window. Three things are quoteable for the next post: the configurable per-component workflow, the BDD-spec boundary protection gate, and Three Amigos as a real agent task. All three landed inside this window. All three have criterion-level Spex coverage on them.

## The prior r/elixir post (April 19 morning)

The post was specific. It described a harness that modeled software as a graph of stories, components, and requirements; routed an agent through them in dependency order; validated the agent's output against a written specification; and refused to advance until it did. The proof attached was MetricFlow -- a Phoenix application with multi-tenant accounts, OAuth integrations with five data providers, a Vega-Lite dashboard with AI-generated visualizations, and BDD spex for every user story in its backlog. MetricFlow shipped from CodeMySpec the same way a downstream Phoenix app ships from Phoenix itself, except the implementation work was done by Claude Code through a structured prompt-and-evaluate loop.

The harness had a Files projection driving a requirement graph. It had agent tasks via MCP. It had a Wallaby-backed QA agent that filed real Issues. It did not, on April 19, have any of the following: per-project configuration, a Three Amigos workflow, criterion-level Spex against its own internal modules, a spex install-readiness gate, or a Files projection with content fingerprints. All of those landed in the seventeen days that followed.

## The first turn (April 19 evening)

Within nine hours of the post going live, thirteen commits landed on master that quietly reshaped what the harness *was*. The first one was `aca1327 Add ProjectConfiguration for local quality gates` -- a new schema and context giving each project its own row of quality knobs. The next commit split the stop hook into a thin `Validation` orchestrator and a separate `TaskEvaluator`. A commit later, an in-memory environment was added behind the `Environments` behaviour with a per-project registry override so the spex pipeline could drive failures end-to-end through recorded compile/exunit/spex outputs without a live workspace. Earmark was swapped for MDEx in markdown parsing. Remote-sync error paths for Stories and Issues were hardened. Files gained a `upsert_file_metadata/2` for mtime-preserving updates. And then, sitting on top of all of it, `5645774 Add BDD spec (Spex) infrastructure + 7 specs for story 553` -- the first time the harness's own BDD framework was pointed at the harness's own internal modules.

Story 553 is the inflection. It is titled "Project Configuration Local Quality Gate Settings" and its seven criterion files exercise the per-project configuration through cassette-backed pipeline fixtures. The framework's own quality gates were now BDD-tested against the framework's own pipeline. From this commit forward, every new feature in the harness ships with a folder of `criterion_NNNN_*_spex.exs` files instead of a single rule file. The harness started using its own BDD methodology on its own code at full strength.

## Plugin distribution: making it shippable (April 20 – 22)

The next two days were given over to making the harness actually distributable as a Claude Code plugin. The publisher learned to clone-and-merge instead of force-pushing the marketplace branch (preserving other plugins). The `cms` binary moved to `~/.codemyspec/bin/` so it survived plugin-version upgrades. A daemon with `cms status / start / stop / logs` subcommands landed. The hook that kicks off CMS at SessionStart was rewritten to `nohup` itself with a 30-second wait so it survived its own exit and tolerated cold Burrito boots. The CI matrix was narrowed to macos_m1 only for testing; release builds still run wider. Plugin versions ticked from v1.4.6 through v1.4.26. By April 22 evening the SQLite path was being resolved at runtime, the FileWatcher was gated on a Repo readiness probe instead of a bare query, and the prod_cli Logger handler had been re-enabled. The harness was now a single binary other Claude Code users could install and run.

## The configurability turn (April 23)

April 23 was the day the configuration knobs the schema had been quietly carrying became real. `340a149 Make spec_validation and qa_validation configurable` flipped both modes to per-project settings backed by `ProjectConfiguration`. A Spex Credo deny-list went into `priv/credo_checks/` to keep the harness's own BDD suite from rotting -- an explicit refusal to let the spex layer accumulate dead-code drift. `session.continuous` and a per-task `init_session` dispatcher landed alongside, materializing the session lifecycle that auto-task-chaining had been faking with closures. Marketing copy was reframed around the harness, leading with a methodology CTA. The IgnoredPaths setup learned to re-sync files and components after a config write so the projection stayed coherent through configuration changes.

This was also the first day a downstream user could materially change how the harness behaved on their project without touching the harness's source. `spec_validation` could be turned off entirely, set to `:warn`, or set to `:strict`. The same for QA. The toggle exists because Market My Spec, in its early shape, didn't want to require strict spec validation while the surface was still moving -- and the harness had to learn that lesson to host a second product.

## Persona Research and the architecture-of-content (April 24)

April 24 brought Persona Research as a full feature for story 560: a context, an MCP tool surface, a hosted LiveView, remote sync, and the `priv/knowledge/persona_research/` playbook. Story 80 (Architecture Decision Records) got its own rule-by-rule Spex coverage targeting `TechnicalStrategy`. Story 124 (Project Setup) got a small but consequential fix: the LiveView started rendering `ProjectSetup.command` directly, with errors propagating, instead of relying on the old hot-path filesystem walks. A schema-level default became the fallback when the DB-backed mode was nil, so projects without a `ProjectConfiguration` row got the right behaviour by default rather than crashing.

The shape of the work changed here. Previously, an agent task was a piece of internal harness machinery with a vague evaluator. Now it was a feature surface -- a context, an MCP tool, a LiveView, and a row of criterion-level spex against the evaluator's rule sheet.

## April 25: Three Amigos and Market My Spec

The biggest single day in the window. Eleven commits, three of which would each be a normal day's work elsewhere.

`fb4fd07 Product page: /products/code-my-spec` shipped the first marketing surface explicitly framed around CodeMySpec as a harness platform, with a signal-red brand zone built on a new zone-scoped CSS system. Six hours later `0019dee Product page: /products/market-my-spec` shipped the matching MMS surface. From April 25 forward there were two products with their own marketing pages, hosted by the same Phoenix app that runs the codemyspec.com blog.

Then `1340458 Three Amigos: full feature — backend, server UI, MCP tools, skill, spex` landed -- a single 5,500-line commit. Three Amigos is a structured story-refinement workflow: a story gets a linked persona, a set of rules describing how the persona behaves, scenarios under each rule that the system must support, and questions that block readiness until the team has answers. The whole thing is an agent task with a hosted LiveView for the human side and twelve criterion-level spex covering the readiness rules (≥1 persona linked, ≥1 rule, every rule has ≥1 scenario, scenarios > open questions). The agent-task evaluator enumerates MCP tools and knowledge in the prompt itself, so a fresh Claude Code session can drive a Three Amigos pass without any out-of-band context.

Three Amigos is the second of the three claims for the next r/elixir post. The phrasing matters: it's not "we wrote a structured story workflow." It's "the structured story workflow is an agent task with twelve BDD specs against its readiness rules, hosted in the harness, runnable from Claude Code through MCP." The pattern was applied retroactively to issue triage (story 599) and architecture design (story 70) over the next twenty-four hours.

Personas got full CRUD via MCP and a LiveView refactor in the same evening. The brand-zone CSS system was hardened against Space Mono leaks. Story 597 (QA Integration Plan) and story 598 (Code Generation) got their first criterion-level spex packs, splitting flat rule files into one criterion per file -- the same rule-by-rule pattern Three Amigos established.

## April 26: the Boundary marathon

April 26 was the day the harness's internal architecture got tightened until it could survive `--warnings-as-errors`. Top-level Boundaries were declared on the umbrella roots. Fifty-seven Credo warnings were ground down to three pre-existing ones. The last seven direct `Repo` calls living in `_web` were pushed out into context modules. `lib/` got a `PublicUrl` accessor so the marketing surfaces could compute correct URLs without reaching into runtime config. Real GitHub and Google OAuth response shapes were captured into Spex cassettes for story 602; OAuth signup learned to provision a personal account and self-heal legacy users; refresh-token success and failure paths got their own real-response cassettes.

The infrastructure work was paired with story-shaped work. Story 601 (the magic-link confirmation LiveView) was killed entirely in favour of provisioning on click. Story 603 (onboarding empty-state) asked for the first project name. Story 604 (post-signup redirect) derived the `module_name` and landed users on `/app`. Issue triage and architecture design got their Three Amigos rules implemented (stories 599 and 70). The mailer was switched from Mailgun to Resend in prod. Twenty-six commits, most of them small, all of them aimed at locking in a release CI build that fails on warnings. By 23:19 UTC the warnings-as-errors flag was on the release pipeline.

## April 27: less, but tighter

April 27 was a smaller day shaped by a single decision: fold the onboarding wizard into `/app` and drop signup auto-provisioning. The magic-link click no longer routes through an intermediate confirmation screen. Auth got a "preserve active-account on subsequent OAuth/magic-link logins" fix. The Spex case migrated to the current SexySpex DSL, declared `McpServers` and `Environments` as their own Boundaries, and inlined the sandbox setup so the bridge file no longer pulled `CodeMySpecTest` as a dep. Story 608 ("Fix accepted QA issues") landed. Issues remote sync moved from bang propagation to error tuples.

## April 28: the proof

If April 25 was the day of the named features, April 28 was the day the harness proved it could be specified by itself. Within twelve hours, every component-generation agent task in the harness had a folder of criterion-level spex against its evaluator rules:

- **Story 76 (Component Spec generation)** -- BDD coverage and gap fixes
- **Story 78 (Context Design Review)** -- BDD coverage
- **Story 460 (Three-criterion story → three spec files)** -- WriteBddSpecs validator + surface helpers
- **Story 669 (Component Test generation)** -- BDD coverage + diagnostics injection
- **Story 670 (Component Code generation)** -- BDD coverage

Each of those stories has between twelve and twenty `criterion_NNNN_*_spex.exs` files documenting exactly what the evaluator must accept and reject. The evaluator-as-graded-rule-set pattern that Three Amigos had introduced three days earlier was now uniform across the agent-task surface.

In the same window, architecture gained a *patch mode* (`b238e78`): a way to splice new components onto an existing architecture graph without redesigning the world around it. Story 70 got an `ArchitectureFixtures` module so spex could stop fixturing components directly. The `similar_components` feature was deleted (`3b398b5`) -- prompts no longer reach into the project for "similar examples" because the agent task surface gave the prompts everything they needed. Six dead agent task modules were removed (`a13a2c2`).

That same evening, the first of the three named claims for the next r/elixir post landed: `ec3771e ... 457fda7 Story 671: Project Configuration Filters the Graph Cleanly`. Seventeen criterion specs cover what `require_specs`, `require_reviews`, and `require_tests` do to the requirement graph at projection time. Disable `require_specs` and the spec nodes drop out cleanly. Disable `require_reviews` and implementation splices onto the spec-valid edge directly. Disable `require_tests` and the test/tests-passing nodes vanish while BDD coverage is preserved. Toggle them on and off and the graph round-trips. The configurable per-component workflow is no longer a slogan -- it is a graph projector with seventeen tests against it.

## April 29 – 30: the graph hardens

The last forty-eight hours of the month were spent making the requirement graph projector defensible. `cfa5d11 Story 562: transitive reduction in the requirement graph` -- the projector started collapsing redundant edges so the graph rendered as a clean DAG instead of a tangle. `8e1aec3 Story 562: kickoff edges span the surface's transitive dep closure` -- a story's "where do I start" calculation was made to walk through every dependency, not just the immediate one. `7afe7c7 Story 562: surface terminal rule for bdd_specs_passing` -- the `bdd_specs_passing` rule got promoted to a terminal that surfaces in the graph. Story 561 (Next Actionable Requirements) shipped a real queue. Stories 70/124/466/559 got priority-graph fixes. The story-chain serialization fix on April 30 confirmed that the new graph projector was producing coherent walks for both Code-My-Spec and the Market-My-Spec project being bootstrapped from it.

The blog post `ff0b853 Blog: Agentic Marketing with MCP — founder-direct post on the loop` went out April 29 with refreshed snapshot stats from real production data. April closed with `6cdf497 Validation: gate block_changed by file mtime, not DB updated_at` -- a fix that mattered because the new requirement-graph projection runs on every change.

## May 1: the BDD-spec boundary protection gate

The third of the three named claims. `43afaf2 Story 677: spex_boundary_ready gate before BDD chain` introduced a checker that confirms a project has the spex framework installed, framework Credo checks active (deny stdlib + direct `send`), a project-local Credo check denying internal namespaces, the curated fixtures bridge scaffolded, and the project BDD plan written. If the gate fails, the harness refuses to walk into any boundary-shaped work. The prior version of the harness had documentation about boundary protection; this version refuses to advance without it.

The accompanying spex knowledge base was split out of one 614-line monolith into seven focused files (boundaries, environment, philosophy, recording cassettes, shared givens, the writing process). The same day fixed a small but load-bearing bug: criteria `kind` and `rule_id` were finally synced through the stories API, and the Three Amigos readiness gate was relaxed to match. Container kickoff fan-out was extended so child nodes survived an all-filters-off pass.

## May 3: the graph becomes large-project-viable

May 3 was the longest day of the month. Story 561's orphan-context filter on `next_actionable` went in (`93b40b9`), was extended to the full subtree (`6e2afab`), was reverted when the fixture damage outweighed the win (`c7aff3e`), and then landed in a narrower form (`eaf112b`) that filtered untethered components without breaking the satisfaction fixtures. In parallel, `bf1879b Make requirements graph viable for large projects` cut the topology, projector, and LiveView until they could render large graphs without choking. The architecture flow received orphan detection and patch-mode tools (`072007b`) so an architecture pass could touch a single component without redesigning the world around it. The Stories MCP was routed through the local server with working-directory scope (`7a6c26f`), the first move in a larger refactor that would conclude on May 5.

Outside the harness itself, the same day shipped an S3 plus Cloudflare image CDN with WebP heroes (`4964ac9`), a legacy URL redirect plug for content migrations (`c2227ee`), markdown footnote rendering (`c8ffb70`), and a backfill of hero and OG images for 28 blog posts (`5073276`). The marketing surface was getting its house in order before the next r/elixir post.

## May 4: the speed pass

`84c47de Speed up execute_proposal: bulk story link + parallel spec writes`. The path that takes an architecture proposal and writes out the spec files for every story it covers got a rewrite: a single bulk insert for the story-component links, then `Task.async_stream` for the spec writes themselves. A new stories controller exposed the bulk link endpoint over HTTP for the remote client (`7a6c26f`'s descendant). Spex criterion IDs were renumbered to clean the gaps left by recent story cleanup.

## May 5: the architectural rename

The final day of the window was an architectural one. `2ed9a3d Refactor Stories MCP into Product Manager server` retired the Stories MCP server and moved its tools into a new Product Manager server. The rename captured what the surface had actually become: an agent-facing product manager with story interview, three amigos, and issue triage workflows. The story interview, triage, and amigos paths now share a server boundary that names them honestly.

`e454a2a Fix BadMapError in Stories ownership checks for local scopes` cleaned up an ownership bug that had been masked while the local and hosted server paths were still split. `2abab8f` added a `?preload=true` mode to the requirements graph view for synchronous test rendering, the kind of small affordance that lets the spex pipeline assert against rendered HTML without LiveView's async dance.

Then the marquee for the day. `554cbfd Add Files projection viewer (story 687); merge sync into it` deleted the old `/sync` LiveView and replaced it with a 442-line Files projection viewer at `/projects/:project_name/files` -- a paginated table exposing every projected column on every tracked file, with an invalid-only filter, the Sync action and Purge All inline, the file → component → parent-story trace, an unowned indicator, and Six criterion-level spex covering the per-row contract, the filter, pagination stability across reloads, navigation, the unowned indicator, and in-place re-sync.

`b6a5aee Add story 127 spex: Filesystem-to-DB projection` followed twenty minutes later -- seven acceptance specs against the projection covering deletion reaping, the classify → validate → upsert → derive chain, per-role validity (well-formed spec, malformed spec, mix.exs concerns, test/spec misalignment), and out-of-tree exclusion. Then `fa2e272 Add fingerprint field to Files projection (story 127)` added a SHA-256 content fingerprint to every File row, captured by FileSync at read time. Per Story 127 Rule 8, the fingerprint is the authoritative content-change signal for downstream out-of-band consumers (analyzers, embedders) -- they compare File.fingerprint to their own last-seen state. mtime stays the cheap pre-filter; the fingerprint gates real work. Two new criterion specs cover the fingerprint mechanics.

By the evening of May 5, the Files projection was visible, the harness could see what it had written to disk, story management had a name that fit, and the requirements graph behaved on real-sized projects. The next r/elixir post sits a few days out.

## What it adds up to

Three named claims for the next r/elixir post:

1. **Configurable per-component workflow.** `ProjectConfiguration` carries `require_specs`, `require_reviews`, `require_tests`, `spec_validation`, and `qa_validation` per project. Story 671 covers what each toggle does to the requirement graph at projection time with seventeen criterion specs. A project can ship with just BDD specs and code while a product is unstable, then turn on unit tests, module specs, and design reviews as the surface stabilizes. The harness rewires its own graph at projection time when the toggles change.

2. **BDD-spec boundary protection.** Story 677's `spex_boundary_ready` task installs framework Credo checks (deny stdlib + direct `send`), generates a project-local Credo check denying internal namespaces, scaffolds a curated fixtures bridge, and writes the project BDD plan. The harness refuses to walk into any boundary-shaped work until the gate is green. Specs run sealed.

3. **Three Amigos session as a real agent task.** Story 559's full feature -- backend, MCP tools, hosted LiveView, twelve criterion specs against the readiness rules. Persona linkage → Rules → Scenarios → Questions, all MCP-backed. The same pattern then applied retroactively to issue triage (story 599) and architecture design (story 70).

The implicit claim under all three is that *the harness now uses its own BDD methodology on its own code at full strength*. Story 553 on April 19 was the first pack of Spex against an internal harness module. By May 5 the harness was running roughly two hundred criterion-level Spex against its own modules, with cassette-backed pipeline fixtures for the validation paths, a memory environment for tests, and a release CI that fails on warnings. The framework that built MetricFlow now has the framework's own BDD coverage as a backstop for changes that would otherwise break the framework's customers.

And there are now two customers: MetricFlow (shipped) and Market My Spec (bootstrapped from CMS in this window, currently being built through the harness, scheduled for soft launch the same week as the next r/elixir post). The shape of the next post is not "look what we built" -- it's *here is what I had to fix in the harness to make it host a second product, and the experiments I'm asking the room to push back on*.

---

*Window covered: April 19, 2026 16:51 UTC through May 5, 2026 21:09 UTC. Approximately 200 commits across the harness, the marketing surface, the plugin distribution, and the second product the harness was being asked to build. Synthesized from the per-month chunks at `chunks/2026-04.md` and `chunks/2026-05.md`. The architectural decisions in this window were authored by John Davenport. The implementation, the specs, the migrations, and this narrative were authored by Claude.*
