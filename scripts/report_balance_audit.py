"""Validate and compare repeated all-style game audits (standard library only)."""
import collections, json, math, statistics, sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
reports=root/'reports'
tags=sys.argv[1:] or ['baseline']
lines=['DOOM: HELL DECK - REPEATED BALANCE AUDIT','13 October 2026','','Acceptance screen, set before reading the repeated results: each style 40-70% score (win=1, draw=0.5), at most 10% draws, at most 20% collapse finishes, and no round-limit timeouts. This is a practical automated playtest target, not proof of perfect balance. Styles get 50 matches each, from ten lists against five shared seeded CPU opponents.']
all_data={}
for tag in tags:
 for shard in [0,1]:
  raw=(reports/f'balance-audit-{tag}-{shard}.log').read_bytes()
  log=raw.decode('utf-16' if raw[:2]==b'\xff\xfe' else 'utf-8')
  assert 'SCRIPT ERROR' not in log and 'Assertion failed' not in log and 'Saved res://' in log
 shards=[json.loads((reports/f'balance-audit-{tag}-{i}.json').read_text(encoding='utf-8')) for i in [0,1]]
 matches=sum((s['matches'] for s in shards),[])
 decks={k:v for s in shards for k,v in s['decks'].items()}
 cards=shards[0]['cards']
 assert cards==shards[1]['cards'] and len(matches)==500 and len(decks)==100
 assert len({tuple(sorted(d)) for d in decks.values()})==100
 for d in list(decks.values())+[m['cpu_deck'] for m in matches]:
  assert len(d)==20 and all(0<=i<145 for i in d)
  assert sum(2+cards[i]['cost']+[0,1,2,3,3,4][cards[i]['rarity']] for i in d)<=120
  assert sum(cards[i]['rarity']>=2 for i in d)<=6 and sum(cards[i]['rarity']==5 for i in d)<=2
  assert all(n <= (3 if cards[i]['rarity']==0 else 2 if cards[i]['rarity']==1 else 1) for i,n in collections.Counter(d).items())
 for seed in {m['seed'] for m in matches}:
  group=[m for m in matches if m['seed']==seed]
  assert len(group)==100 and len({tuple(m['cpu_deck']) for m in group})==1
 styles=collections.defaultdict(list)
 for m in matches: styles[m['deck'].rsplit(' ',1)[0]].append(m)
 assert len(styles)==10 and all(len(v)==50 for v in styles.values())
 outcomes=collections.Counter(m['outcome'] for m in matches)
 ends=collections.Counter(m['end_reason'] for m in matches)
 total_score=(outcomes['win']+0.5*outcomes['draw'])/len(matches)
 lines += ['',tag.upper(),f"Overall: {outcomes['win']}W / {outcomes['loss']}L / {outcomes['draw']}D; score {100*total_score:.1f}%.",f"Average turns {statistics.mean(m['turns'] for m in matches):.2f}; combat {ends['combat']}, collapse {ends['collapse']}, timeouts {ends['round_limit']}.",'Style                   W   L   D   Score    Status']
 failures=[]
 metrics={}
 for style,group in sorted(styles.items()):
  count=collections.Counter(m['outcome'] for m in group)
  score=(count['win']+count['draw']*0.5)/len(group)
  ok=0.4<=score<=0.7
  if not ok: failures.append(style)
  lines.append(f"{style:23}{count['win']:3} {count['loss']:3} {count['draw']:3}   {score*100:5.1f}%   {'PASS' if ok else 'REVIEW'}")
  metrics[style]={'score':score,'wins':count['win'],'losses':count['loss'],'draws':count['draw']}
 passed=not failures and outcomes['draw']<=50 and ends['collapse']<=100 and ends['round_limit']==0
 lines.append('Acceptance screen: '+('PASS' if passed else 'REVIEW REQUIRED'))
 all_data[tag]={'metrics':metrics,'matches':matches,'decks':decks,'cards':cards,'passed':passed}
if len(tags)>1:
 assert set(all_data[tags[0]]['decks'])==set(all_data[tags[-1]]['decks'])
 if tags[-1]=='fresh':
  assert not ({tuple(sorted(v)) for v in all_data[tags[0]]['decks'].values()} & {tuple(sorted(v)) for v in all_data[tags[-1]]['decks'].values()})
 lines += ['','STYLE STABILITY (percentage-point score changes)']
 for style in all_data[tags[0]]['metrics']:
  a=all_data[tags[0]]['metrics'][style]['score'];b=all_data[tags[-1]]['metrics'][style]['score']
  lines.append(f'{style}: {a*100:.1f}% -> {b*100:.1f}% ({(b-a)*100:+.1f} points)')
if len(tags)>1:
 pooled=sum((v['matches'] for v in all_data.values()),[])
 assert len({(tag,m['deck'],m['seed']) for tag,v in all_data.items() for m in v['matches']})==len(pooled)
 assert all(v['cards']==all_data[tags[0]]['cards'] for v in all_data.values()), 'Do not pool different balance versions'
 groups=collections.defaultdict(list)
 for m in pooled: groups[m['deck'].rsplit(' ',1)[0]].append(m)
 lines += ['', 'POOLED CURRENT-BUILD RESULTS', f'{len(pooled)} matches; all use identical runtime card definitions.', 'Style                   W   L   D   Score    Status']
 pooled_metrics={}
 for style,group in sorted(groups.items()):
  c=collections.Counter(m['outcome'] for m in group)
  score=(c['win']+0.5*c['draw'])/len(group)
  ok=0.4<=score<=0.7
  pooled_metrics[style]={'score':score,'passed':ok,'matches':len(group)}
  lines.append(f"{style:23}{c['win']:3} {c['loss']:3} {c['draw']:3}   {score*100:5.1f}%   {'PASS' if ok else 'REVIEW'}")
 c=collections.Counter(m['outcome'] for m in pooled)
 ends=collections.Counter(m['end_reason'] for m in pooled)
 passed=all(m['passed'] for m in pooled_metrics.values()) and c['draw']/len(pooled)<=0.1 and ends['collapse']/len(pooled)<=0.2 and ends['round_limit']==0
 themes={tuple(m['cpu_deck'][:3]) for m in pooled}
 lines.append(f'CPU core formations covered: {len(themes)}; distinct seeded CPU lists: {len({tuple(m["cpu_deck"]) for m in pooled})}.')
 lines += [f"Pooled screen: {'PASS' if passed else 'REVIEW REQUIRED'}.", f"Overall {c['win']}W / {c['loss']}L / {c['draw']}D; average {statistics.mean(m['turns'] for m in pooled):.2f} turns; {ends['collapse']} Collapse endings; {ends['round_limit']} timeouts."]
 (reports/'balance-audit-pooled.json').write_text(json.dumps({'matches':len(pooled),'passed':passed,'metrics':pooled_metrics},indent=2),encoding='utf-8')
lines += ['','METHOD / LIMITS','All runs use actual game combat, levels, director, retaliation, and turn-locked squads. The player bot uses event, revival and Soul Surge heuristics; CPU uses normal themed unit decks. Results describe this asymmetric game, not a symmetric tournament.','Each style contains ten lists sharing five opponents, so trials are correlated. Theme overlap and short samples prevent causal conclusions about individual cards. Repeat checks and human playtesting remain important.','No timeout is accepted as a completed competitive match. All lists checked for legality, copy limits, unique deck composition and equal opponent coverage.','Baseline uses existing 100 lists and seeds 2026102000-2026102004. Fresh audit regenerates 100 lists with seed 2026102300 and uses unseen match seeds 2026102400-2026102404. Round 2 adds 1000 to match seeds and preserves deck lists.']
if len(tags)>1:
 scores=[v['score'] for v in pooled_metrics.values()]
 lines[3:3]=[f"CURRENT BUILD: {'passes' if passed else 'does not yet pass'} the pooled automated screen across {len(pooled)} matches. Style scores range {min(scores)*100:.1f}-{max(scores)*100:.1f}%.", 'Card values were held unchanged throughout these audits. Single-batch outliers are retained below; the pooled estimate includes all batches, not selected favorable results.', '']
output='\n'.join(lines)+'\n'
(reports/'balance-audit-report.txt').write_text(output,encoding='utf-8')
(reports/'balance-audit-summary.json').write_text(json.dumps({k:{'metrics':v['metrics'],'passed':v['passed']} for k,v in all_data.items()},indent=2),encoding='utf-8')
print(output)
