# DOOM: Hell Deck

A fan-made Godot 4 card game with two modes: **Hell Deck**, a four-lane tactical battler, and **Hell Meld**, a competitive monster-combination game.

## Download

Get the Windows ZIP from [Releases](https://github.com/tuin-boop/DoomHellDeck/releases/latest), extract it, and run **DOOM-Hell-Deck.exe**. No Godot or .NET installation is required.

Provide your own **DOOM2.WAD** beside the EXE, or set `DOOM_WAD` to its location. The commercial IWAD is not included. The game also checks supported Steam installation paths.

## Hell Meld

- Five rounds, ten turns each per round. Score more points to win rounds.
- Play matching sets, armies, damage-type groups, Marches, Apocalypse combos, and named teams.
- Extend the shared centre combination or draw/pass to clear it.
- Draft from **41 support Jokers**. Start with one and choose one more from three offers each round, reaching five in the final round. Both sides follow the same progression. Opening offers use a pool of standalone Jokers. Hover cards for effects and progress.
- Each scoring Joker appears in sequence with the points it contributes.
- Each round opens with a staged reveal of the shared bonus, Gilded monster, and Charged monster. Enter skips the reveal.
- Choose combo-family upgrades between rounds; inspect shared bonuses and enhanced monsters in Match Powers.
- Animated combo lettering, illustrated guide, clickable Named Teams links, final-turn alerts, and animated result artwork.

![Hell Meld table](docs/screenshots/hell-meld.png)

![Round power reveal](docs/screenshots/round-reveal.png)

![Five-Joker trays](docs/screenshots/five-joker-trays.png)

![Joker collection](docs/screenshots/joker-collection.png)

![Glitch Jester Imp](docs/screenshots/glitch-jester.png)

| Field Guide | Match Powers |
| --- | --- |
| ![Guide](docs/screenshots/field-guide.png) | ![Powers](docs/screenshots/match-powers.png) |

| Final-turn alert | Match result |
| --- | --- |
| ![Final turn](docs/screenshots/final-turn.png) | ![Result](docs/screenshots/match-result.png) |

Screenshots show staged in-game examples. Result artwork includes stylized swimsuit illustrations.

## Hell Deck

Build decks, choose a commander, and fight across four lanes. Monsters have damage types, resistances, abilities, and squad synergies. Includes opening-hand redraws, guided deck building, optional side-view battles, and Daisy's Bunny Guard pairing with Doomguy.

| Deck building | Side-view combat |
| --- | --- |
| ![Deck builder](docs/screenshots/deck-help.png) | ![Battle](docs/screenshots/side-view-battle.png) |

## Controls

- **Hell Meld:** select and drag cards to the centre, or use Play Selection. Draw / Pass ends your action and clears the centre.
- **Space:** show/hide your Joker tray, sliding up from below. Hover the CPU tab to inspect its Jokers. Click two owned Joker slots to rearrange them.
- **Hell Deck:** drag cards into lanes, right-click a hand card for a squad, Space ends your turn.
- **F8:** Hell Radio. **Escape:** close a panel or open the menu.
- Optional Hell Meld hints: type `johnromerogod`, then hover highlighted cards to see legal combinations.

## Run from source

Open `project.godot` in **Godot 4.7.2** and press **F5**. This is a GDScript project; no C# SDK is required. Supply your own WAD as above. For Windows exports, install matching Godot export templates and use **Windows Share**.

## Tests and balance

Create `captures` and `reports` directories before running tests from a clean clone:

```powershell
godot --path . --script scripts/support_jokers_test.gd -- --balance-test
```

The tests cover Joker scoring, preview purity, growth, resets, one-to-five drafting, and presentation. The latest simulation ran **500 full matches / 2,500 rounds / 50,000 turns**, using actual three-choice drafts with one additional Joker each round. Both sides used the same hand-aware draft policy and greedy scoring AI. All card-conservation and turn-limit checks passed.

- Simulated side wins: **228–272**.
- Average score per side by round: **120.7, 131.7, 144.7, 159.3, 173.6**.
- Glitch Jester Imp appeared in winning teams in 65.9% of its 85 appearances. This is observational and does not isolate the Joker's strength from teammates or draft timing; no balance changes were made from that statistic alone.

Run `godot --headless --path . --script scripts/joker_progression_balance_test.gd` to reproduce. See the [full report](reports/joker-progression-500.json). The older fixed-three-Joker simulator and reports remain for comparison. Simulation is not a guarantee of balance in human play.

## Credits

This is an unofficial fan project, not affiliated with id Software, Bethesda, Nintendo, or people depicted on cards. Third-party names, characters, sprites, music, and illustrations belong to their respective owners. No blanket open-source license is asserted for those assets.

Asset-specific source notes are retained under `assets/`. Joker and result illustrations were supplied for this project. Hell Radio includes synthesized Doom scores and selected Donkey Kong Country music. Commercial WAD files, local caches, and build tools are not included.
