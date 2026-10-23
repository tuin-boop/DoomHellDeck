"""Summarize the 100-match paired Wolf/Demolitron audit without altering balance."""
import json, statistics
from collections import Counter
from pathlib import Path
root=Path(__file__).resolve().parents[1]
data=json.loads((root/'reports/balance-wolf-demolitron-100.json').read_text())
rows=data['matches']
assert len(rows)==100
assert not any(r['end_reason']=='round_limit' for r in rows)
log=(root/'reports/balance-wolf-demolitron-100.log').read_text()
assert 'SCRIPT ERROR' not in log and 'Assertion failed' not in log
cards=data['cards']; size=len(cards)//10
profiles=['Mecha-Hitler','Schabbs','Hans','Demolitron','Mixed Wolf guns']
lines=['WOLFENSTEIN + DEMOLITRON BALANCE CHECK â€” 14 October 2026', '',
'100 completed AI-vs-AI matches using real combat, current retaliation, squads, draw director and suit protection. No stats changed during testing.',
'Five featured deck groups; each played 10 games on each side against its paired control deck. Seeds 2026105200â€“2026105209 were reused after swapping decks. All decks obey the 20-card, 120-point and rarity/copy limits.', '',
'Featured deck results (wins / losses / draws; score counts draws as half a win):']
summary={}
for name in profiles:
 group=[r for r in rows if r['deck'].startswith(name+' /')]
 assert len(group)==20
 p=[r for r in group if r['deck'].endswith('/ player')]
 c=[r for r in group if r['deck'].endswith('/ cpu')]
 assert len(p)==len(c)==10
 for a,b in zip(p,c):
  assert a['seed']==b['seed']
  assert sorted(data['decks'][a['deck']])==sorted(b['cpu_deck'])
  assert sorted(data['decks'][b['deck']])==sorted(a['cpu_deck'])
 outcomes=Counter(r['outcome'] if r in p else {'win':'loss','loss':'win','draw':'draw'}[r['outcome']] for r in group)
 score=(outcomes['win']+0.5*outcomes['draw'])/20*100
 summary[name]={'wins':outcomes['win'],'losses':outcomes['loss'],'draws':outcomes['draw'],'score_pct':score,'player_side_wins':sum(r['outcome']=='win' for r in p),'cpu_side_wins':sum(r['outcome']=='loss' for r in c)}
 lines.append(f"{name}: {outcomes['win']}/{outcomes['loss']}/{outcomes['draw']} â€” {score:.1f}% score (featured wins: player side {summary[name]['player_side_wins']}/10; CPU side {summary[name]['cpu_side_wins']}/10)")
turns=[r['turns'] for r in rows]; overall=Counter(r['outcome'] for r in rows)
lines += ['',f"Overall player bot: {overall['win']} wins, {overall['loss']} losses, {overall['draw']} draws.",f"Match length: mean {statistics.mean(turns):.2f}, median {statistics.median(turns):g}, range {min(turns)}â€“{max(turns)} rounds.",f"Hell Collapse endings: {sum(r['end_reason']=='collapse' for r in rows)}/100. Round-limit timeouts: 0.", '', 'Featured-card use (player-side records only; CPU per-card deployments are not logged):']
for actor in ['MechaHitler','Schabbs','Hans','Demolitron']:
 id=next(i for i,c in enumerate(cards[:size]) if c.get('actor')==actor)
 eligible=[r for r in rows if id in data['decks'][r['deck']]]
 seen=sum(any(int(x)%size==id for x in r['seen_in_hand']) for r in eligible)
 played=sum(any(int(x)%size==id for x in r['plays']) for r in eligible)
 uses=sum(sum(n for x,n in r['plays'].items() if int(x)%size==id) for r in eligible)
 lines.append(f"{actor}: included in {len(eligible)} games, seen in hand in {seen}, played/reinforced in {played}; {uses} total play actions.")
lines += ['', 'Balance verdict and next steps:',
'Broadly playable, but this sample flags the Mecha-Hitler deck as strong (80% score) and Demolitron deck as weak (27.5%). Schabbs (50%), Hans (45%) and the mixed deck (60%) do not show a clear problem here.',
'Mecha-Hitler: keep the promised suit survival mechanic. If a larger matched follow-up confirms the advantage, test 7 Energy instead of 6 before changing the suit rule.',
'Demolitron: test 4 Energy instead of 5 in a follow-up. It has the same level-1 Attack/Health and two-strike pattern as 4-Energy Hans, while losing its former splash role. Only 7 of 20 player-side inclusion games actually used it, so the current evidence also reflects affordability and deck fit.',
'Important deck-fit caveat: the individual Mecha-Hitler and Demolitron decks each replaced one Shotgun Guy; Hans replaced an Imp, and Schabbs replaced an Imp plus Shotgun Guy. These swaps can alter squads and the energy curve, not just card power. The five profiles also use different control decks.',
'No balance changes applied. Recommended next test: repeat these two outliers against several control decks, preserving squad pieces and matching the replaced card costs.', '', 'Interpretation:',
'This is a focused screening run, not proof of global balance or a before/after comparison. Each group has only 20 games and a single control-deck pairing; a single result changes its score by 5 percentage points. Deck composition, draws and matchups can explain differences.',
'Both bots share placement search, but the player bot has Soul Surge and revival helpers while the CPU does not. Side swapping reduces the resulting bias; it does not make the underlying rules symmetric.',
'The roster and suit mechanics passed separate regression tests. Use these match results to choose follow-up tests, not to attribute deck wins directly to one card.', '',
'Raw results: reports/balance-wolf-demolitron-100.json', 'Run log: reports/balance-wolf-demolitron-100.log']
(root/'reports/balance-wolf-demolitron-report.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')
(root/'reports/balance-wolf-demolitron-summary.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print('\n'.join(lines))
