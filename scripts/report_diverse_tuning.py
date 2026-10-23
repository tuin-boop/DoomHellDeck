"""Check the frozen 100-match replay and report paired balance changes."""
import collections
import json
import statistics
from pathlib import Path

root = Path(__file__).resolve().parents[1]
reports = root / 'reports'
before = json.loads((reports / 'balance-100-distinct-decks.json').read_text(encoding='utf-8'))
after = json.loads((reports / 'balance-100-distinct-decks-tuned.json').read_text(encoding='utf-8'))
assert len(before['matches']) == len(after['matches']) == 100
assert before['decks'] == after['decks'], 'Player lists changed'
assert len({tuple(sorted(d)) for d in after['decks'].values()}) == 100
assert len({tuple(sorted(m['cpu_deck'])) for m in after['matches']}) == 100
for old, new in zip(before['matches'], after['matches']):
    assert (old['deck'], old['seed'], old['cpu_deck']) == (new['deck'], new['seed'], new['cpu_deck'])
cards = after['cards']
for deck in list(after['decks'].values()) + [m['cpu_deck'] for m in after['matches']]:
    assert len(deck) == 20
    assert sum(2 + cards[i]['cost'] + [0,1,2,3,3,4][cards[i]['rarity']] for i in deck) <= 120
    assert sum(cards[i]['rarity'] >= 2 for i in deck) <= 6
    assert sum(cards[i]['rarity'] == 5 for i in deck) <= 2
    for i, count in collections.Counter(deck).items():
        assert 0 <= i < 145
        assert count <= (3 if cards[i]['rarity'] == 0 else 2 if cards[i]['rarity'] == 1 else 1)

def score(matches):
    c = collections.Counter(m['outcome'] for m in matches)
    return f"{c['win']}W / {c['loss']}L / {c['draw']}D"

def groups(data):
    result = collections.defaultdict(list)
    for m in data['matches']:
        result[m['deck'].rsplit(' ', 1)[0]].append(m)
    return result

old_groups, new_groups = groups(before), groups(after)
lines = ['DOOM: HELL DECK - DIVERSE DECK TUNING REPLAY', '13 October 2026', '',
    'CHANGES',
    'Monster Mix units and armored units gain 1 base HP. A card in both categories gains only 1 HP total. Applies before level scaling, on both sides.',
    'Fire and Rocket weakness bonuses reduced from +2 to +1. Base Attack, direct Health hits, splash and retaliation formulas unchanged. Other weakness bonuses remain +2.',
    'Inspector and Imp description updated to match. Energy, Souls, deck points and copy limits unchanged.', '',
    'RESULTS (player-side bot; ten distinct decks per style, one match per deck)',
    f"Overall: {score(before['matches'])} -> {score(after['matches'])}",
    f"Average turns: {statistics.mean(m['turns'] for m in before['matches']):.2f} -> {statistics.mean(m['turns'] for m in after['matches']):.2f}", '',
    'Style                   Before                After']
for style in old_groups:
    lines.append(f'{style:24}{score(old_groups[style]):22}{score(new_groups[style])}')
ends = collections.Counter(m['end_reason'] for m in after['matches'])
changes = sum(a['outcome'] != b['outcome'] for a,b in zip(before['matches'],after['matches']))
lines += ['', f"Finishes: {ends['combat']} combat; {ends['collapse']} Hell Collapse; {ends['round_limit']} timeouts.",
    f'{changes} paired matches changed outcome.', '', 'ASSESSMENT',
    'The four targeted styles moved in the intended direction: Monster Mix 2 to 7 wins, Armor 3 to 7, Fire and Rockets each 8 to 6.',
    'Overall balance is not established: Cheap pressure rose to 8 wins, Mythic fell to 2 wins, and Squad combos fell to 4. Mythic performance and cheap pressure are the next priorities for repeated testing across more seeds, before further stat changes.',
    '', 'METHOD AND LIMITS',
    'Verified identical 100 player lists, 100 CPU lists, match order and seeds against the previous run. All 200 decks remain legal. Real game combat, draw director, level scaling, turn-locked squads and retaliation; no user saves modified.',
    'Both sides receive the balance changes. Bots can make different decisions after tuning, so a weaker damage type can still win more matches. Ten trials per style are noisy and cannot establish reliable win rates or isolate individual card effects.',
    'Player bot has event/Soul/revival heuristics; CPU retains its themed unit decks and normal economy. This measures the actual asymmetric game, not a symmetric first-player test.',
    'Regression checks: smoke suite, retaliation/AI parity, selected roster, deck rules, levels and squads. Full logs retained.', '',
    'Raw replay: balance-100-distinct-decks-tuned.json',
    'Baseline: balance-100-distinct-decks.json']
path = reports / 'balance-100-distinct-decks-tuned-report.txt'
path.write_text('\n'.join(lines)+'\n', encoding='utf-8')
print('\n'.join(lines))
