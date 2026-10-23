"""Install validated picker selections from archived full-length renders."""
import json, shutil
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
picks = json.loads(Path('C:/Users/pvand/Downloads/donkey-kong-picks.json').read_text())['selected']
catalogue = {t['id']:t for t in json.loads((ROOT/'reports/radio-archive/tracks.json').read_text())}
tracks = [t for t in json.loads((ROOT/'assets/radio/tracks.json').read_text()) if t['album'] in ['DOOM','DOOM II']]
for item in picks:
    track = dict(catalogue[item['id']])
    assert track['album'].startswith('Donkey Kong Country')
    filename = Path(track['file']).name
    shutil.copy2(ROOT/'reports/radio-archive/audio'/filename, ROOT/'assets/radio/audio'/filename)
    track['menu_only'] = track['id']==799
    tracks.append(track)
assert any(t.get('menu_only') for t in tracks)
(ROOT/'assets/radio/tracks.json').write_text(json.dumps(tracks,indent=2),encoding='utf-8')
print(f'Installed {len(picks)} selected tracks; {len(tracks)} total. Save Cave reserved for menus.')
