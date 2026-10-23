import json, collections, statistics
from pathlib import Path
root=Path(__file__).resolve().parents[1]
files=['balance-wolf-demolitron-100','balance-wolf-demolitron-tuned-100','balance-wolf-demolitron-final-100']
runs=[json.loads((root/'reports'/f'{name}.json').read_text()) for name in files]
for name,run in zip(files,runs):
 assert len(run['matches'])==100
 assert not any(m['end_reason']=='round_limit' for m in run['matches'])
 log=(root/'reports'/f'{name}.log').read_text()
 assert 'SCRIPT ERROR' not in log and 'Assertion failed' not in log
reference={(r['deck'],r['seed']):r for r in runs[0]['matches']}
for run in runs[1:]:
 assert run['decks']==runs[0]['decks']
 for row in run['matches']:assert row['cpu_deck']==reference[(row['deck'],row['seed'])]['cpu_deck']
lines=['WOLF / DEMOLITRON TUNING + GUIDED BUILDER — 14 October 2026','',
'Final card changes: Mecha-Hitler costs 7 Energy (was 6), with 7 starting Health (was 8). His suit still absorbs the breaking hit, discards overflow and leaves him at half starting Health rounded up. Demolitron costs 4 Energy (was 5); dual miniguns, Attack and Health are unchanged.',
'Validation: two additional 100-match replays against the original 100-match screening run. Same decks, paired sides and seeds; no new deck generation. First replay changed costs only; second added the small Mecha Health reduction.', '',
'Featured-deck score, draws worth half a win (20 games per group):',
'Deck | Original | Costs only | Final | Final W/L/D']
for name in ['Mecha-Hitler','Schabbs','Hans','Demolitron','Mixed Wolf guns']:
 scores=[]
 for run in runs:
  rows=[r for r in run['matches'] if r['deck'].startswith(name+' /')]
  c=collections.Counter(r['outcome'] if r['deck'].endswith('/ player') else {'win':'loss','loss':'win','draw':'draw'}[r['outcome']] for r in rows)
  scores.append((c['win']+.5*c['draw'])/len(rows)*100)
 lines.append(f"{name} | {scores[0]:g}% | {scores[1]:g}% | {scores[2]:g}% | {c['win']}/{c['loss']}/{c['draw']}")
last=runs[-1]['matches'];outcomes=collections.Counter(r['outcome'] for r in last)
lines += ['',f"Final player-bot totals: {outcomes['win']} wins / {outcomes['loss']} losses / {outcomes['draw']} draws. Mean {statistics.mean(r['turns'] for r in last):.2f} rounds; {sum(r['end_reason']=='collapse' for r in last)} Collapse endings; zero timeouts.",
'These are matchup/deck signals, not standalone card win rates. Each group has only 20 matches and one control deck; the same seeds were used for tuning, so this is not an independent holdout. Some featured cards are drawn but not played. A larger varied-deck holdout is needed before declaring global balance.', '',
'Guided builder: Armory > My Decks > Guided Deck Builder. Optional choice of up to three squads; rarity-filtered suggestions, editable picks and auto-fill; review then save/name as a separate draft. Existing decks and the active battle selection are preserved. Uses current ownership, points, copy and premium limits. All 18 squad seeds, fills, UI editing, naming and activation passed regression tests.',
'Raw final results: reports/balance-wolf-demolitron-final-100.json']
(root/'reports/wolf-tuning-and-builder-report.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('\n'.join(lines))
