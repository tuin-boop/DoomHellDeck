import json,collections,statistics
from pathlib import Path
root=Path(__file__).resolve().parents[1]
data=json.loads((root/'reports/balance-deck-budget-100.json').read_text(encoding='utf-8'))
rows=data['matches'];cards=data['cards']; extra=[0,3,5,6,6,9]
assert len(rows)==100
log=(root/'reports/balance-deck-budget-100.log').read_text(encoding='utf-8-sig')
assert 'SCRIPT ERROR' not in log and 'Assertion failed' not in log
assert all(cards[i]['hp']>0 for r in rows for i in r['cpu_deck'])
assert len(data['decks'])==100 and len({tuple(sorted(r['cpu_deck'])) for r in rows})==100
for deck in list(data['decks'].values())+[r['cpu_deck'] for r in rows]:
 assert len(deck)==20
 assert sum(2+cards[i]['cost']+extra[cards[i]['rarity']] for i in deck)<=120
 assert sum(cards[i]['rarity']>=2 for i in deck)<=6
 assert sum(cards[i]['rarity']==5 for i in deck)<=2
 for i,n in collections.Counter(deck).items():assert n<=[3,2,1,1,1,1][cards[i]['rarity']]
c=collections.Counter(r['outcome'] for r in rows)
lines=['RARITY BUDGET AND BUILDER CHECK - 14 October 2026','',
'Points = 2 + battle Energy + rarity surcharge: Common 0, Rare 3, Epic 5, Legendary/Elite 6, Mythic 9. Combat stats and Energy are unchanged. A 3-Energy Mythic costs 14 deck points, previously 9.',
'Playable decks still need 20 cards within 120 points, max 6 premium cards including 2 Mythics. A tested selection of 2 Mythics, 4 Elites and 6 Rares spends 120 points at only 12 cards: it must free at least 24 points to finish. It stays an unplayable draft. Auto-fill does not silently delete expensive player choices.',
'Builder now separates points from Energy, shows remaining budget, cheapest completion warning and rarity caps. Existing over-budget decks remain saved drafts. New UAC starter: 95 points.', '',
'100 matches: 100 distinct player-bot decks across ten styles versus 100 distinct CPU decks. All 200 lists passed size, point, rarity and copy validation.',
f"Results: {c['win']} player-bot wins / {c['loss']} losses / {c['draw']} draws. Mean {statistics.mean(r['turns'] for r in rows):.2f} rounds; {sum(r['end_reason']=='collapse' for r in rows)} Collapse endings; {sum(r['end_reason']=='round_limit' for r in rows)} timeouts.", '', 'By style (ten matches each):']
for style in dict.fromkeys(r['deck'].rsplit(' ',1)[0] for r in rows):
 group=[r for r in rows if r['deck'].rsplit(' ',1)[0]==style];c=collections.Counter(r['outcome'] for r in group)
 lines.append(f"{style}: {c['win']}W / {c['loss']}L / {c['draw']}D")
lines += ['', 'Checks passed: premium-heavy unfinished draft rejection, ownership, cheapest completion, no deletion of player picks, all 18 squad seeds/fills, old-save preservation, 100 generated CPU deck tests and combat smoke tests.',
'This checks the construction restrictions and screens for gross combat problems. Ten games per style cannot establish precise balance. Player and CPU abilities differ; the new decks/seeds are not a matched before/after comparison. A varied repeated holdout would be needed for stronger claims.',
'One CPU event-card filler bug was found in the initial run. The affected match was replayed after fixing generation; unchanged deck/seed matches were retained. Initial results remain in balance-deck-budget-initial-100.json.',
'Raw deck/match data: reports/balance-deck-budget-100.json']
(root/'reports/deck-budget-report.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('\n'.join(lines))
