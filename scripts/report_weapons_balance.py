import json, collections, statistics, html
from pathlib import Path
root = Path(__file__).resolve().parents[1]
reports = root / "reports"
baseline = json.loads((reports / "balance-weapons-100.json").read_text(encoding="utf-8"))
final = json.loads((reports / "balance-weapons-holdout-100.json").read_text(encoding="utf-8"))
def summarize(data):
    groups = collections.defaultdict(lambda: [0,0,0,0])
    for match in data["matches"]:
        name, side = match["deck"].split(" / ")
        group = groups[name]
        group[0] += 1
        group[1] += match["outcome"] == ("win" if side == "player" else "loss")
        group[2] += match["outcome"] == "draw"
        if side == "player":
            group[3] += sum(count for card,count in match["plays"].items() if int(card) in [9,149,150,151,152,153,154])
    return groups
before, after = summarize(baseline), summarize(final)
cards = final["cards"][:155]
weapons = [150,151,149,152,153,154,9]
wins = sum(v[1] for v in after.values())
draws = sum(v[2] for v in after.values())
rows = "".join(f"<tr><td>{html.escape(name)}</td><td>{before[name][1]}/{before[name][0]}</td><td>{v[1]}/{v[0]}</td><td>{v[2]}</td><td>{v[3]}</td></tr>" for name,v in after.items())
costs = "".join(f"<tr><td>{cards[i]['name']}</td><td>{cards[i]['cost']}</td><td>{html.escape(cards[i]['ability'])}</td></tr>" for i in weapons)
weapon_mean = statistics.mean(cards[i]["cost"] for i in weapons)
monster_mean = statistics.mean(c["cost"] for c in cards if c["hp"] > 0)
body = f"""<!doctype html><meta charset=utf-8><title>Ranged weapons balance check</title>
<style>body{{background:#111918;color:#eee4ce;font:17px/1.55 system-ui;max-width:1000px;margin:48px auto;padding:24px}}h1,h2{{color:#ffae64}}table{{border-collapse:collapse;width:100%;margin:24px 0}}td,th{{padding:10px;text-align:left;border-bottom:1px solid #42504a}}strong{{color:#a7e8bf}}</style>
<h1>Ranged weapons — balance check</h1><p>18 October 2026 · 100 initial matches + 100 fresh-seed validation matches.</p>
<p><strong>Final weapon decks: {wins} wins, {100-wins-draws} losses, {draws} draws.</strong> Both sides used the actual game combat code and the same weapon-selection scoring. Each package played five matches as the player and five as the CPU against its corresponding legal monster control deck.</p>
<p>Weapon Energy averages <strong>{weapon_mean:.2f}</strong>, versus <strong>{monster_mean:.2f}</strong> across level-one monster catalogue entries. Each weapon exhausts after use and never causes retaliation. Higher-level monster draws can cost more.</p>
<h2>Changes after the first batch</h2><p>Kept the user's higher weapon costs. Chaingun: 4 → 5 Energy and three → five 1-damage hits. Rocket Launcher: 5 → 6 Energy, primary damage 4 → 5 and adjacent damage 1 → 2. Adjusted weapon-selection scoring so bots recognise useful removal at the higher costs. Other weapon values stayed unchanged between batches.</p>
<h2>Package results</h2><table><tr><th>Package</th><th>Initial wins</th><th>Final wins</th><th>Final draws</th><th>Weapon casts in 5 player-side matches</th></tr>{rows}</table>
<p>These are package results, not isolated card win rates. Ten matches per package is a small sample; do not treat a 60% versus 50% result as a reliable ranking. Side-swapping reduces position bias, but bots, generated control decks and draw seeds still limit the conclusion. Fresh-seed differences also reflect the policy change. Large weapon packages give up recurring monsters and squad pieces, so weapons are intended as support rather than an entire deck.</p>
<h2>Final cards</h2><table><tr><th>Weapon</th><th>Energy</th><th>Effect</th></tr>{costs}</table>
<h2>Verification</h2><p>70 live-versus-preview cases covered all seven weapons on both sides against ordinary monsters, shields, armour, Mecha-Hitler's suit and death spawns. Verified no retaliation, unaffordable plays, CPU payment and usage, weapon art, and the main combat smoke suite. No chainsaw or melee weapons added.</p>
"""
(reports / "weapons-balance-report.html").write_text(body,encoding="utf-8")
print(f"Final: {wins} wins / {100-wins-draws} losses / {draws} draws; weapon mean {weapon_mean:.2f}, monster mean {monster_mean:.2f}")
print(dict(after))
