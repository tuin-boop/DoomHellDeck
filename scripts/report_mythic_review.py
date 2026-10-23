import json,collections,statistics,math
from pathlib import Path
root=Path(__file__).resolve().parents[1]
d=json.loads((root/'reports/balance-mythic-rare-review-100.json').read_text(encoding='utf-8'))
rows=d['matches'];cards=d['cards'];size=len(cards)//10
assert len(rows)==100
log=(root/'reports/balance-mythic-rare-review-100.log').read_text(encoding='utf-8-sig')
assert 'SCRIPT ERROR' not in log and 'Assertion failed' not in log
lines=['MYTHIC / RARE FOLLOW-UP - 14 October 2026','',
'100 fresh completed matches at CURRENT prices: Mythic surcharge +9, Rare +3. Ten Mythic decks (two Mythics each) and ten Rare-heavy decks (at least six Rares, no Mythics). Each plays five identical seeded CPU opponents. Real combat and current draw director, Energy, Souls, squads and retaliation. Normal saves untouched.','']
summary={}
for style in ['Mythic','Rare']:
 group=[r for r in rows if r['deck'].startswith(style+' ')];assert len(group)==50
 lists=[v for k,v in d['decks'].items() if k.startswith(style+' ')]
 for deck in lists:
  if style=='Mythic':assert sum(cards[i]['rarity']==5 for i in deck)==2
  else: assert sum(cards[i]['rarity']==1 for i in deck)>=6 and all(cards[i]['rarity']!=5 for i in deck)
 counts=collections.Counter(r['outcome'] for r in group)
 score=(counts['win']+.5*counts['draw'])/50
 per_deck=[]
 for name in sorted({r['deck'] for r in group}):
  rs=[r for r in group if r['deck']==name];per_deck.append(sum(1 if r['outcome']=='win' else .5 if r['outcome']=='draw' else 0 for r in rs)/5*100)
 summary[style]={'wins':counts['win'],'losses':counts['loss'],'draws':counts['draw'],'score_pct':score*100,'deck_scores':per_deck}
 lines += [f"{style}: {counts['win']} wins / {counts['loss']} losses / {counts['draw']} draws; {score*100:.1f}% score.",f"Individual deck scores (5 matches each): {per_deck}"]
 if style=='Mythic':
  played=sum(any(cards[int(i)]['rarity']==5 for i in r['plays']) for r in group)
  uses=sum(sum(n for i,n in r['plays'].items() if cards[int(i)]['rarity']==5) for r in group)
  seen=sum(any(cards[int(i)]['rarity']==5 for i in r['seen_in_hand']) for r in group)
  summary[style].update(seen_games=seen,used_games=played,actions=uses)
  lines += [f"Mythics seen in hand: {seen}/50 games; played or reinforced: {played}/50 games; {uses} total play actions."]
  for key in ['mythic_soul_blocked_turns','mythic_energy_blocked_turns','mythic_affordable_turns']:
   lines.append(f"{key}: {sum(r['actions'][key] for r in group)} (categories can overlap)")
# Every player deck faces the same five CPU lists/seeds.
reference={r['seed']:r['cpu_deck'] for r in rows[:5]}
assert len(reference)==5 and all(reference[r['seed']]==r['cpu_deck'] for r in rows)
lines += ['',f"Mean match length: {statistics.mean(r['turns'] for r in rows):.2f} rounds. Collapse endings: {sum(r['end_reason']=='collapse' for r in rows)}. Timeouts: {sum(r['end_reason']=='round_limit' for r in rows)}.",
'This compares whole decks, not isolated cards. Player bot has Soul Surge/event helpers unavailable to the CPU. Five opponents and ten decks per group limit generalization; repeated matches within decks are not independent card-strength measurements.',
'Decision: no price or combat changes. Mythic decks scored 49% and used Mythics in 48/50 games, so the earlier 3/10 sample does not justify a blanket buff. Rare-heavy decks scored 68%; retain their surcharge rather than making them cheaper. This sample does not establish parity between the two groups. If further tuning is desired, investigate individual weak Mythics and the stronger Rare deck packages with new opponents first.',
'Raw data: reports/balance-mythic-rare-review-100.json']
(root/'reports/mythic-rare-review-report.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')
(root/'reports/mythic-rare-review-summary.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print('\n'.join(lines))
