import collections
import html
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPORTS = ROOT / 'reports'

def read(name):
    return json.loads((REPORTS / name).read_text(encoding='utf-8'))

def summary(data):
    groups = collections.defaultdict(lambda: [0, 0, 0])
    for match in data['matches']:
        label, side = match['deck'].split(' / ')
        group = label.split(' v')[0]
        outcome = match['outcome']
        result = 2 if outcome == 'draw' else (0 if outcome == ('win' if side == 'player' else 'loss') else 1)
        groups[group][result] += 1
    return groups

def interval(w, n):
    z = 1.96
    p = w/n
    center = (p+z*z/(2*n))/(1+z*z/n)
    half = z*math.sqrt(p*(1-p)/n+z*z/(4*n*n))/(1+z*z/n)
    return f'{100*(center-half):.0f}–{100*(center+half):.0f}%'

baseline = read('balance-cheese-100.json')
trial = read('balance-cheese-cost-trial-100.json')
before, after = summary(baseline), summary(trial)
rows = ''.join(f'<tr><td>{name}</td><td>{b[0]}–{b[1]}–{b[2]}</td><td>{interval(b[0],sum(b))}</td><td>{after[name][0]}–{after[name][1]}–{after[name][2]}</td></tr>' for name,b in before.items())
decks = []
for name, deck in trial['decks'].items():
    if not name.endswith('/ player'): continue
    counts = collections.Counter(deck)
    pts = sum(2+trial['cards'][i]['cost']+[0,3,5,6,6,9][trial['cards'][i]['rarity']] for i in deck)
    entries = []
    for i, copies in counts.items():
        c = trial['cards'][i]
        entries.append(f"{copies}× {html.escape(c['name'])} ({c['cost']} Energy" + (f", {c['soul_cost']} Souls" if c.get('soul_cost') else '') + ')')
    decks.append(f'<details><summary>{html.escape(name.removesuffix(" / player"))} — {pts}/120 points</summary><p>'+ '<br>'.join(entries)+'</p></details>')
page = '''<!doctype html><meta charset="utf-8"><title>Hell Deck — cheese build audit</title>
<style>body{max-width:1100px;margin:40px auto;padding:24px;background:#131b1b;color:#ede4d4;font:17px/1.6 system-ui}h1,h2{color:#ffb46b}table{width:100%;border-collapse:collapse}td,th{padding:12px;border-bottom:1px solid #445;text-align:left}summary{cursor:pointer;color:#aee2c5}details{margin:12px 0}</style>
<h1>Cheese build audit</h1><p>19 October 2026 · 100 baseline games + 100 cost-trial games.</p>
<p>Five exploit-focused archetypes, two builds each. Each build plays five matches on each side against its paired generated CPU deck. All decks obey 20 cards, 120 points, rarity and copy limits. Both sides use level-one cards and actual game combat. Hero powers are disabled on both sides to isolate card costs.</p>
<h2>Results</h2><p>Numbers are wins–losses–draws for the featured build, regardless of side.</p>
<table><tr><th>Build</th><th>Baseline / 20</th><th>Baseline 95% interval</th><th>Cost trial / 20</th></tr>'''+rows+'''</table>
<h2>What to watch</h2><p><strong>Shield plus splash is the clearest warning.</strong> Its baseline 17/20 result is a build-level finding, not proof that every shield card is overpowered. Infernal Cacodemon, Warded Mancubus, Lesser Cardinal and Pyro Imp are priority candidates for targeted replacement tests.</p>
<p><strong>ZSec Handgun Zombie has a particularly cheap package:</strong> baseline 2 Energy, 3 ATK, 4 HP and a shield, with three copies allowed. The trial raises only its Energy from 2 to 3 (and consequently deck points from 4 to 5); attack, HP, shield and rarity remain intact.</p>
<p><strong>Applied:</strong> ZSec Handgun Zombie now costs 3 Energy and 5 deck points. The cost trial brought shield/splash down to 13 wins, 6 losses and 1 draw, but pure shields still won 14/20 with one draw. This is a targeted price correction, not a claim that shields are fully balanced. No other stats or costs were changed.</p>
<p>Pure armour and multi-strike were less alarming. Weapon-heavy builds lost heavily; this does not establish that individual weapons need buffs, because these decks sacrifice too many recurring monsters.</p>
<h2>Limits</h2><p>These are small, correlated samples: repeated seeds and decks, ten generated control lists, and bot decisions rather than human play. Side-swapping reduces but does not eliminate policy/turn-order bias. The player-side bot supports additional actions such as resurrection and Soul Surge. The cost trial uses the same seed schedule but rebuilds legal decks under the new price, so it measures the resulting builds, not an isolated causal card effect. No hero synergies or upgraded-card balance are claimed. The armour optimiser did not select Mecha-Hitler, so this run does not evaluate its suit protection.</p>
<p>Shields block one normal hit, or absorb one point of counter damage. They do not stack; reinforcement preserves shield state rather than renewing it. Armour reduces normal hits by one, with at least one damage, and is ignored by counters.</p>
<h2>Cost-trial deck lists</h2>'''+''.join(decks)
(REPORTS / 'cheese-balance-report.html').write_text(page,encoding='utf-8')
print('Baseline:',dict(before))
print('Cost trial:',dict(after))
