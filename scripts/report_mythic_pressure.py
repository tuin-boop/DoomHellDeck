"""Summarize focused, matched-opponent Mythic/pressure trials."""
import json, collections, statistics
from pathlib import Path
root=Path(__file__).resolve().parents[1]
d=json.loads((root/'reports/balance-mythic-pressure-focus-100.json').read_text(encoding='utf-8'))
ms=d['matches']; cards=d['cards']; assert len(ms)==100
by=collections.defaultdict(list)
for m in ms: by[m['deck'].rsplit(' ',1)[0]].append(m)
assert set(by)=={'Mythic','Cheap pressure'} and all(len(v)==50 for v in by.values())
for seed in {m['seed'] for m in ms}:
 group=[m for m in ms if m['seed']==seed]
 assert len(group)==20 and len({tuple(m['cpu_deck']) for m in group})==1
assert all(m['end_reason']!='round_limit' for m in ms)
def score(rows):
 c=collections.Counter(m['outcome'] for m in rows)
 return f"{c['win']} wins, {c['loss']} losses, {c['draw']} draws"
lines=['DOOM: HELL DECK - MYTHIC / CHEAP PRESSURE INVESTIGATION','13 October 2026','','100 additional matches; unchanged card balance. Ten existing decks per style, five matches per deck. Each deck faces the same five seeded CPU deck lists. Seeds 2026101900-2026101904. Normal saves disabled.','','RESULTS']
for style,rows in by.items():
 decks=[v for k,v in d['decks'].items() if k.startswith(style+' ')]
 mythic_games=sum(any(cards[int(i)]['rarity']==5 for i in m['plays']) for m in rows)
 lines += [f'{style}: {score(rows)}; {statistics.mean(m["turns"] for m in rows):.2f} average turns.',f'  At least one Mythic played (including reinforcement use): {mythic_games}/50 matches.',f'  Average cheap units (Energy <=2) per deck: {statistics.mean(sum(cards[i]["hp"]>0 and cards[i]["cost"]<=2 for i in deck) for deck in decks):.1f}.']
 for key in ['mythic_soul_blocked_turns','mythic_energy_blocked_turns','mythic_affordable_turns','surges','reinforcements']:
  lines.append(f'  {key}: {sum(m["actions"][key] for m in rows)} total, {statistics.mean(m["actions"][key] for m in rows):.2f}/match.')
 lines.append('  Per deck:')
 for name in dict.fromkeys(m['deck'] for m in rows): lines.append(f'    {name}: {score([m for m in rows if m["deck"]==name])}')
lines += ['','ASSESSMENT','The original 2/10 Mythic and 8/10 cheap-pressure results did not persist: the focused run is 31/50 versus 32/50 wins. No broad Mythic buff or cheap-unit nerf is justified by these results.','Mythic decks 03 and 06 each won only 1/5; decks 02 and 08 each won 5/5. Investigate individual deck composition and resource planning before changing the whole rarity.','Energy shortages were recorded more frequently than Soul shortages for Mythic hands, although the counters overlap. Mythics were used in 44/50 Mythic-deck matches. The earlier non-play concern was not universal.','','INTERPRETATION LIMITS','Each resource counter samples the start of a turn, before bot plays or Soul Surge. Categories overlap and do not prove why a card was withheld. Affordable ignores lane availability. Played counts include reinforcement consumption, not only deployment.','The bots use the actual shared planner. Its placement scoring charges Energy but does not explicitly value Souls saved for future hands; Soul Surge can compete with Mythics. This is a candidate for an AI economy improvement, not proof of a card-stat defect.','Retaliation happens after each strike, so Mythic multi-strike attackers can die before later strikes. Fire/Rocket Mythics also received the weakness nerf. Both are mechanical pressures; this run does not isolate their individual effects.','Five opponents and ten related deck lists per style do not provide independent population win rates. Themes overlap: cheap-pressure lists can contain Mythics. No individual card should be nerfed solely from win-when-played correlations.','Raw data: balance-mythic-pressure-focus-100.json']
out='\n'.join(lines)+'\n';(root/'reports/balance-mythic-pressure-focus-report.txt').write_text(out,encoding='utf-8');print(out)
