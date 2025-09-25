Vampire & Hunter System

How to become a Vampire:
- In the Entities menu under Vampire System, spawn and use "Vampire Blood" to become a Vampire.

How to become a Hunter:
- In the Entities menu under Hunter System, spawn and use "Garlic Serum" to become a Hunter.

Chat commands (players)
- Vampires
  - !vcoven — open the Coven menu
- Hunters
  - !hguild — open the Guild menu
- Werewolves
  - !wpack — open the Pack menu
  - !transform — transform (subject to cooldowns and rules)
- Hybrids
  - !vampireform — transform to Vampire form (if balance/tier allows)
  - !werewolfform — transform to Werewolf form (if balance/tier allows)
  - !eclipseform — transform to Eclipse form (requires perfect balance and high tier)
  - !bloodrage — convert some blood into rage
  - !dualessence — convert dual essence into blood and rage

Chat commands (admins)
- General
  - !vhadmin — open the Admin Menu (admins only)
- Werewolf admin
  - !makewerewolf <player> — turn a player into a werewolf
  - !removewerewolf <player> — remove werewolf status
  - !addrage <player> <amount> — add rage to a werewolf
  - !forcetransform <player> — force or end transformation
  - !setmoonphase <phase> — set moon phase; phases: new, waxingcrescent, firstquarter, waxinggibbous, full, waninggibbous, lastquarter, waningcrescent
  - !addmoonessence <player> <amount> — add moon essence
  - !listwerewolves — list all werewolves
  - !werewolfhelp — print werewolf admin help
- Hybrid admin
  - !makehybrid <player> — turn a player into a hybrid
  - !removehybrid <player> — remove hybrid status
  - !addbloodhybrid <player> <amount> — add blood to a hybrid
  - !addragehybrid <player> <amount> — add rage to a hybrid
  - !sethybridbalance <player> <balance> — set balance (-100..100)
  - !forcehybridtransform <player> <vampire|werewolf|eclipse> — force transformation
  - !triggereclipse — empower all hybrids for a duration
  - !listhybrids — list all hybrids
  - !hybridhelp — print hybrid admin help

Console commands (admins)
- make_vampire <steamid> — convert player to vampire (removes hunter if present)
- add_blood <steamid> <amount> — add vampire blood
- drain_blood <entityId> <amount> — drain blood from an entity (use with care; entityId is Entity:EntIndex())
- make_hunter <steamid> — convert player to hunter (removes vampire if present)
- add_experience <steamid> <amount> — add hunter experience

Notes
- <player> can be a partial name match; the system resolves by searching online players’ names.
- <steamid> must be a full SteamID for console commands.
- Admin-only commands require the player’s user group to be in GlobalConfig.AdminUserGroups.
- Some actions depend on per-role cooldowns, tiers, and balance values (see each role’s config).
