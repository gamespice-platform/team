# GameSpice Team

Sides that outlive the match: team definitions and presets, a session-long roster that drives GameSpice Match's, pure balance arithmetic, role rotation for asymmetric games, and team-aware spectating through GameSpice Spectate.

Read the family [CLAUDE.md](../../CLAUDE.md) first; this file is only what is specific to teams.

**The distributable is `addons/gs_team/`.** It requires [GameSpice Core](../gs-core) and nothing else. gs-match, gs-spectate and gs-player are optional and duck-typed; gs-spectate is linked only for the spectate suite (`addons/gs_spectate`, gitignored).

## Read before

| Read | Before |
| --- | --- |
| [docs/design.md](docs/design.md) | anything: why balance is pure, session scope, the four-entry set, `are_enemies`, attributes, `validate()`, the GameSpice Match and GameSpice Spectate bridges, rotation, what this does not do |
| [docs/history.md](docs/history.md) | the absorbed gs-team-spectate, the alphabetical draw |

## Layout

| Path | What |
| --- | --- |
| `core/gs_team_def.gd` | `GSTeamDef`: one side; colour, friendly fire, cap, `playing`, `attributes` |
| `core/gs_team_set.gd` | `GSTeamSet`: the sides a session has, presets (`standard_pair()`), `are_enemies`, the shared `palette_colour` / `palette_name` for numbered teams |
| `core/gs_team_policy.gd` | `GSTeamPolicy`: joining, switching, locking, balancing; a `GSConfig` with `validate()` |
| `core/gs_team_balance.gd` | `GSTeamBalance`: all the arithmetic, static and pure |
| `core/gs_team_rotation.gd` | `GSTeamRotation`: who takes a role this round (`RANDOM`, `QUEUE`, `SWAP`), and why |
| `core/gs_team_spectate_rules.gd` | `GSTeamSpectateRules`: who may watch whom |
| `runtime/gs_team_roster.gd` | `GSTeamRoster`: who is on which side, authoritative or mirrored; `bind_match`, `live_fn` |
| `runtime/gs_team_spectate.gd` | `GSTeamSpectate`: the duck-typed bridge to GameSpice Spectate |
| `core/gs_team_block_rules.gd`, `core/gs_team_block_config.gd` | `GSTeamBlockRules`: whether two players stop at each other, by relation (`mp_teamblock` 0, `mp_enemyblock` 1), per-player or per-team `!block`/`!noblock` requests, replicated as `mp_blockstate`; `GSTeamBlockConfig` is its layered config |
| `runtime/gs_team_block_commands.gd` | `GSTeamBlockCommands`: `!block` / `!noblock` on a duck-typed host (GSModule or GSConsole), chat-enabled, gated by `mp_blockcmd` |
| `runtime/gs_team_menu_server.gd` | `GSTeamMenuServer`: the server half of the team menu (period key). Answers the `teams` command with a `team_menu` notice and validates `teams <id\|auto\|spectate\|play>` against `mp_teamswitch_enabled`, `_cooldown`, `_imbalance`, `_maxplayers`, `_anytime`, `_kill`, `_spectate`. The game supplies `teams_fn`, `state_fn`, `join_fn`, `spectate_fn`, `play_fn`, `window_fn`; it never knows how the game keeps teams |
| `gs_team_api.gd` | the API level; bump `LEVEL` for anything new a game can call (rule on GameSpice Core's `GSAddonApi`) |
| `examples/team_selftest.tscn`, `team_spectate_selftest.tscn` | the two suites |

Paths except `examples/` are in `addons/gs_team/`.

## Running and testing

The family's two steps ([family CLAUDE.md](../../CLAUDE.md#validating-anything)), then **both** `godot --headless --path . res://examples/team_selftest.tscn` and `res://examples/team_spectate_selftest.tscn`. The second needs gs-spectate linked at `addons/gs_spectate`.

## Rules that bite

- Balance takes counts, not a roster, and stays static and pure. [design](docs/design.md#autobalance-is-only-defensible-if-the-server-can-say-why)
- The roster drives gs-match's team manager, one way; never let both decide. [design](docs/design.md#the-gs-match-bridge-is-duck-typed-and-one-directional)
- Push to GameSpice Match by its team **id** at the playing position, never GameSpice Team's index; never push a non-playing side. [design](docs/design.md#the-gs-match-bridge-is-duck-typed-and-one-directional)
- Every set has an unassigned and a spectator entry; check `playing` before treating a side as a team. Free-for-all is one playing team with friendly fire on. [design](docs/design.md#four-entries-in-a-two-sided-set)
- Ask `are_enemies` here; never write "their team is not mine" elsewhere. [design](docs/design.md#are_enemies-is-written-once)
- Add an `attributes` key, not a field, for another addon's need. [design](docs/design.md#attributes-is-open-on-purpose)
- `validate()` refuses `max_difference = 0` and no-choice-no-auto-assign; keep both. [design](docs/design.md#validate-refuses-two-configurations-and-both-have-a-symptom)
- Never write a `GSSpectator*` or GameSpice Match identifier in a statement; find classes by `get_global_class_list()` and call by name. [design](docs/design.md#the-spectate-bridge-an-index-not-a-cast)
- `team_index` is one-based over playing ids, cached at `setup()`; the filter runs after GameSpice Spectate's own rules. [design](docs/design.md#the-spectate-bridge-an-index-not-a-cast)
- A random draw is mixed, never a raw string hash. [design](docs/design.md#who-takes-a-role-dotteamrotation)

Not here: scoring, spawning, damage, drawing, rounds (`live_fn`), player records. [design](docs/design.md#what-this-does-not-do)
- Ask `GSTeamBlockRules.blocks(a, b)` whether two players stop at each other; never compare sides in a collision layer. Teammates pass by default, enemies stop, and a player with no side (a free-for-all, a solo game, a spectator) is an enemy, so those stay solid. [design](docs/design.md#players-stop-at-each-other-by-relation)

## Open

- mg-deathrun still draws its activators with its own `DrGame._draw_sides` rather than `GSTeamRotation`, which was extracted from it; mg-prop-hunt and game-hide-n-seek use `GSTeamRotation`. Not yet converted; reason unknown (mg-deathrun's design doc argues for a draw that excludes last round's activators, which `RANDOM` already does).
