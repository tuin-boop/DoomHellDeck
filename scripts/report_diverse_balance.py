"""Validate the diverse-deck match artifact and write a compact human report."""
import collections
import json
import statistics
from pathlib import Path

root = Path(__file__).resolve().parents[1]
data = json.loads((root / 'reports/balance-100-distinct-decks.json').read_text(encoding='utf-8'))
matches, decks, cards = data['matches'], data['decks'], data['cards']
assert len(matches) == len(decks) == 100
assert len({m['seed'] for m in matches}) == 100
assert len({tuple(sorted(d)) for d in decks.values()}) == 100
assert len({tuple(sorted(m['cpu_deck'])) for m in matches}) == 100

def points(deck):
    return sum(2 + cards[i]['cost'] + [0, 1, 2, 3, 3, 4][cards[i]['rarity']] for i in deck)

def validate(deck):
    assert len(deck) == 20 and points(deck) <= 120
    assert all(isinstance(i, int) and 0 <= i < 145 for i in deck)
    for i, copies in collections.Counter(deck).items():
        rarity = cards[i]['rarity']
        assert copies <= (3 if rarity == 0 else 2 if rarity == 1 else 1)
    assert sum(cards[i]['rarity'] >= 2 for i in deck) <= 6
    assert sum(cards[i]['rarity'] == 5 for i in deck) <= 2

for deck in list(decks.values()) + [m['cpu_deck'] for m in matches]:
    validate(deck)
for deck in decks.values():
    assert sum(cards[i]['hp'] > 0 and cards[i]['cost'] <= 2 for i in deck) >= 5
styles = collections.defaultdict(list)
for match in matches:
    styles[match['deck'].rsplit(' ', 1)[0]].append(match)
assert len(styles) == 10 and all(len(group) == 10 for group in styles.values())
outcomes = collections.Counter(m['outcome'] for m in matches)
ends = collections.Counter(m['end_reason'] for m in matches)
turns = [m['turns'] for m in matches]
coverage = {i for deck in decks.values() for i in deck}
lines = [
    'DOOM: HELL DECK - 100 DISTINCT DECKS / 100 MATCHES',
    '13 October 2026', '',
    f"Player-side bot: {outcomes['win']} wins; CPU: {outcomes['loss']} wins; draws: {outcomes['draw']}.",
    f'Average length: {statistics.mean(turns):.2f} turns; median {statistics.median(turns):g}; range {min(turns)}-{max(turns)}.',
    f"Finishes: {ends['combat']} combat, {ends['collapse']} Hell Collapse, {ends['round_limit']} round-limit timeouts.",
    f'Card coverage: {len(coverage)} of 145 collection cards included in the player-side test decks.',
    f'Deck points: {min(map(points, decks.values()))}-{max(map(points, decks.values()))}; mean {statistics.mean(map(points, decks.values())):.1f} / 120.',
    '', 'STYLE RESULTS (ten DIFFERENT decks per row; one match per deck)',
    'Style                 Wins Losses Draws  Average turns',
]
for style, group in styles.items():
    count = collections.Counter(m['outcome'] for m in group)
    lines.append(f"{style:22}{count['win']:3}    {count['loss']:3}   {count['draw']:3}      {statistics.mean(m['turns'] for m in group):5.2f}")
ranked = sorted(styles, key=lambda s: sum(m['outcome'] == 'win' for m in styles[s]), reverse=True)
lines += [
    '', 'INTERPRETATION',
    f'The strongest sampled styles were {ranked[0]} and {ranked[1]}; the weakest were {ranked[-2]} and {ranked[-1]}. These are follow-up candidates, not proven rankings.',
    'One win or loss does not establish an individual deck\'s strength. Even each style has only ten trials, and styles have overlapping cards and abilities. Repeat promising and weak lists across multiple opponents and seeds before changing card values.',
    '', 'METHOD',
    '100 unique player-side card multisets; 100 unique CPU multisets. All 200 lists validated against the 20-card, 120-point, copy, premium and Mythic limits. Every player-side deck has at least five low-cost units. Styles bias generation toward their theme; squad decks contain a complete recipe and Mythic decks contain two Mythics.',
    'Fresh match seeds 2026101800-2026101899; generator seed 2026101700. Real combat code with current retaliation, shield/armor changes, 2-Soul Mythics, reduced Monster Mix costs, levels, reinforcement and turn-locked squad bonuses. Both bots use the shared placement planner. Player events, Soul Surge and resurrection use the existing heuristics; CPU retains its normal themed unit decks and no Soul economy. This tests the current asymmetric game, not a symmetric first-player-advantage experiment.',
    'No card values were changed for this run. Normal user saves were disabled. Full deck compositions, final health, per-turn history and card definitions are included in the raw JSON.',
    '', 'Raw data: balance-100-distinct-decks.json',
    'Run log: balance-100-distinct-decks.log',
]
report = root / 'reports/balance-100-distinct-decks-report.txt'
report.write_text('\n'.join(lines) + '\n', encoding='utf-8')
print('\n'.join(lines[:22]))
print(f'Validated 200 legal decks and saved {report.name}.')
