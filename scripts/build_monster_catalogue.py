"""Read archive data only; never load or execute DECORATE/ZScript code."""
import base64, csv, html, io, json, re, struct, zipfile, zlib
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'reports' / 'monster-catalogue'
OUT.mkdir(parents=True, exist_ok=True)
(OUT / '.gdignore').write_text('')
ARCHIVE = Path(r'C:/Users/pvand/Downloads/MegaMonsterMix-V1.2.zip')
outer = zipfile.ZipFile(ARCHIVE)
pack = zipfile.ZipFile(io.BytesIO(outer.read('MegaMonsterMix-V1.2.pk3')))
actors = {}
roster = []
files = [n for n in pack.namelist() if n.lower().startswith('decorate/monsters/') and n.lower().endswith('.txt')]
for source in files:
    raw = pack.read(source).decode('utf-8-sig', errors='replace').replace('\r', '')
    # Remove comments without treating text inside quoted strings as comments.
    clean = re.sub(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*[\s\S]*?\*/', lambda m: m[0] if m[0].startswith('"') else ' ', raw)
    for match in re.finditer(r'\bActor\s+(\w+)\s*(?::\s*(\w+))?[^{}]*\{', clean, re.I):
        start = match.end(); depth = 1; end = start
        for token in re.finditer(r'"(?:\\.|[^"\\])*"|[{}]', clean[start:]):
            if token[0] == '{': depth += 1
            elif token[0] == '}': depth -= 1
            if depth == 0:
                end = start + token.start(); break
        name, parent = match.group(1), match.group(2) or ''
        body = clean[start:end]
        actors[name.lower()] = dict(actor=name, parent=parent, body=body, source=source, family=Path(source).stem)
        if parent.lower() == 'randomspawner':
            for item in re.finditer(r'\bDropItem\s+"([^"]+)"\s*,\s*\d+\s*,\s*(\d+)', body, re.I):
                roster.append(dict(actor=item[1], family=Path(source).stem, weight=int(item[2]), origin='Replacement roster'))

def inherited(actor, pattern, visited=None):
    visited = set() if visited is None else visited
    if actor.lower() in visited: return None
    visited.add(actor.lower())
    info = actors.get(actor.lower())
    if not info: return None
    found = re.search(pattern, info['body'], re.I | re.M)
    return found if found else inherited(info['parent'], pattern, visited)

def monster_parent(actor, visited=None):
    visited = set() if visited is None else visited
    if actor.lower() in visited: return False
    visited.add(actor.lower())
    info = actors.get(actor.lower())
    if not info: return actor.lower().startswith('mmm_monsterbase')
    return monster_parent(info['parent'], visited)

primary = {r['actor'].lower() for r in roster}
for info in actors.values():
    if info['actor'].lower() not in primary and monster_parent(info['actor']) and re.search(r'\b(?:SpawnID|Health)\s+\d+', info['body'], re.I) and not info['actor'].startswith('MMM_'):
        roster.append(dict(actor=info['actor'],family=info['family'],weight=None,origin='Additional monster / summoned form'))

wad_path = Path(r'C:/Program Files (x86)/Steam/steamapps/common/Ultimate Doom/base/doom2/DOOM2.WAD')
wad = wad_path.read_bytes()
count, directory = struct.unpack_from('<II', wad, 4)
lumps = {}
for i in range(count):
    offset, size, name = struct.unpack_from('<II8s', wad, directory+i*16)
    lumps[name.rstrip(b'\0').decode('ascii', errors='replace').upper()] = wad[offset:offset+size]
palette = lumps['PLAYPAL'][:768]
sprites = {}
for path in pack.namelist():
    if path.lower().startswith('sprites/') and not path.endswith('/'):
        sprites[Path(path).stem.upper()] = path

def decode(data):
    if data.startswith(b'\x89PNG'):
        # Several source PNGs contain incorrect ancillary grAb CRCs. Rebuild checksums, preserving pixels.
        pos=8; repaired=data[:8]
        while pos+12<=len(data):
            size=struct.unpack_from('>I',data,pos)[0]; chunk=data[pos+4:pos+8+size]
            repaired+=struct.pack('>I',size)+chunk+struct.pack('>I',zlib.crc32(chunk))
            pos+=size+12
        return Image.open(io.BytesIO(repaired)).convert('RGBA')
    width, height, left, top = struct.unpack_from('<HHhh', data)
    if not (0 < width < 4096 and 0 < height < 4096): raise ValueError('Invalid patch dimensions')
    image = Image.new('RGBA', (width,height))
    pixels = image.load()
    for x in range(width):
        pos = struct.unpack_from('<I',data,8+x*4)[0]; previous = -1
        while pos < len(data) and data[pos]!=255:
            y, length = data[pos:pos+2]
            if y <= previous: y += previous
            previous = y
            for dy, index in enumerate(data[pos+3:pos+3+length]):
                if y+dy < height:
                    pixels[x,y+dy] = (*palette[index*3:index*3+3],255)
            pos += length+4
    return image

def frames_for(actor):
    info = actors.get(actor.lower())
    if not info:
        native={'zombieman':'POSS','shotgunguy':'SPOS','chaingunguy':'CPOS','doomimp':'TROO','demon':'SARG','spectre':'SARG','lostsoul':'SKUL','cacodemon':'HEAD','painelemental':'PAIN','revenant':'SKEL','hellknight':'BOS2','baronofhell':'BOSS','fatso':'FATT','arachnotron':'BSPI','archvile':'VILE','spidermastermind':'SPID','cyberdemon':'CYBR','wolfensteinss':'SSWV'}
        return [(native[actor.lower()],'A')] if actor.lower() in native else []
    body = info['body']
    for state in ['Spawn','See','Idle']:
        state_match = re.search(r'\b'+state+r'\s*:\s*([\s\S]*?)(?=^\s*\w+\s*:|\Z)',body,re.I|re.M)
        if state_match:
            frames = re.findall(r'^\s*([A-Za-z0-9_]{4})\s+([A-Z]+)\s+[-\d]+',state_match[1],re.M)
            frames = [(a.upper(),b[0]) for a,b in frames if a.upper() not in ['TNT1','----']]
            if frames: return frames
    return frames_for(info['parent']) if info['parent'] else []

def sprite_for(actor):
    for prefix,frame in frames_for(actor):
        for rotation in ['1','0','2','8','3','7','4','6','5']:
            key = prefix+frame+rotation
            candidates = [n for n in sprites if n.startswith(key)]
            if candidates:
                source = sprites[candidates[-1]]
                try:
                    return decode(pack.read(source)),source
                except Exception as error:
                    print('DECODE FAILURE', actor, source, type(error).__name__)
                    continue
            native_keys=[n for n in lumps if n.startswith(key)]
            if native_keys:
                return decode(lumps[native_keys[-1]]),'DOOM2.WAD:'+native_keys[-1]
    return None,''

# A monster can appear in several spawner tables; list its identity only once.
roster=list({r['actor'].lower():r for r in reversed(roster)}.values())[::-1]
records=[]; failures=[]; excluded=[]
for index, entry in enumerate(roster,1):
    info = actors.get(entry['actor'].lower())
    if not info:
        failures.append(entry['actor']); continue
    direct_name = re.search(r'\bTag\s+"([^"]+)"',info['body'],re.I)
    name = direct_name[1] if direct_name else re.sub(r'(?<=[a-z])(?=[A-Z])',' ',entry['actor'])
    hp = inherited(entry['actor'],r'\bHealth\s+(\d+)')
    translation = inherited(entry['actor'],r'^\s*Translation\s+([^\n]+)')
    tier = re.search(r'MMM_\w*Base([2-5])?$',info['parent'],re.I)
    image, source = sprite_for(entry['actor'])
    if image is None:
        if not frames_for(entry['actor']):
            excluded.append(entry['actor'])
        else:
            failures.append(entry['actor'])
        continue
    box = image.getbbox()
    if box: image=image.crop(box)
    # Preserve extracted colours; runtime recolouring is explicitly identified.
    filename=f'{index:03d}-{entry["actor"]}.png'
    image.save(OUT/filename)
    buffer=io.BytesIO();image.save(buffer,format='PNG')
    records.append(dict(number=index,name=name,actor=entry['actor'],family=entry['family'],tier=(tier[1] or '1') if tier else '?',health=int(hp[1]) if hp else None,origin=entry['origin'],weight=entry['weight'],image=filename,sprite_source=source,definition=info['source'],note='Base sprite: runtime palette/effects may change its appearance.' if translation else '',data_uri='data:image/png;base64,'+base64.b64encode(buffer.getvalue()).decode()))

(OUT/'monsters.json').write_text(json.dumps([{k:v for k,v in r.items() if k!='data_uri'} for r in records],indent=2),encoding='utf-8')
with (OUT/'monsters.csv').open('w',newline='',encoding='utf-8-sig') as f:
    fields=['number','name','actor','family','tier','health','origin','image','note','sprite_source','definition']
    writer=csv.DictWriter(f,fieldnames=fields,extrasaction='ignore');writer.writeheader();writer.writerows(records)

cards=[]
for r in records:
    e=lambda k:html.escape(str(r[k]))
    cards.append(f'''<article data-family="{e('family')}" data-search="{html.escape((r['name']+' '+r['actor']+' '+r['family']).lower())}" data-id="{e('actor')}"><label><input type="checkbox" value="{e('actor')}"><span>#{r['number']:03d} · {e('family')}</span><div class="picture"><img loading="lazy" src="{r['data_uri']}" alt="{e('name')}"></div><h2>{e('name')}</h2><code>{e('actor')}</code><p>Tier {e('tier')} · Doom HP {e('health')}</p><small>{e('origin')}</small><small class="note">{e('note')}</small></label></article>''')
options=''.join(f'<option>{html.escape(f)}</option>' for f in dict.fromkeys(r['family'] for r in records))
page='''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Mega Monster Mix — roster picker</title><style>
:root{color-scheme:dark}*{box-sizing:border-box}body{margin:0;background:#101314;color:#f1ecdd;font:16px/1.45 system-ui,sans-serif}header,main{padding:26px 4vw}h1{font-size:32px;margin:0;color:#ffaf68}header p{max-width:1050px;color:#b8c3c0}.toolbar{position:sticky;top:0;z-index:2;display:flex;gap:12px;flex-wrap:wrap;padding:16px 4vw;background:#192122f5;border-block:1px solid #3b4946}input,select,button{font:inherit;padding:10px;border:1px solid #55665f;border-radius:6px;background:#111b1c;color:#f1ecdd}button{cursor:pointer}button:hover{border-color:#ffa45c}#search{flex:1;min-width:180px}.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:18px}article{border:1px solid #39443e;border-radius:10px;background:#192020;overflow:hidden}article:has(input:checked){border:2px solid #ffa45c;box-shadow:0 0 18px #fa63252a}label{display:block;padding:14px;cursor:pointer}input[type=checkbox]{accent-color:#ffaa55}label span{font-size:12px;color:#a6b6ad}.picture{height:190px;display:flex;align-items:center;justify-content:center;background:radial-gradient(ellipse,#38403a00,#090d0da0);margin-block:12px}.picture img{width:100%;height:180px;object-fit:contain;image-rendering:pixelated}h2{font-size:19px;line-height:1.2;margin:6px 0}code{font-size:12px;color:#9ddcca;overflow-wrap:anywhere}small{display:block;color:#a6b6ad;font-size:11px}p{margin:10px 0}.note{color:#d2b27b;min-height:32px;margin-top:6px}#status{padding:12px 4vw;color:#c5d6cf}#selection{white-space:pre-wrap;background:#172221;border:1px solid #4f6b61;padding:20px;border-radius:8px;margin-bottom:24px}.hidden{display:none!important}.hint{font-size:13px}footer{padding:30px 4vw;color:#9eaaa5}</style>
<header><h1>MEGA MONSTER MIX / ROSTER PICKER</h1><p>Choose monsters for DOOM: Hell Deck. Every picture is extracted from your pack (or its Doom II base sprite), not generated artwork. Names come from monster definitions. Doom HP and source tiers are reference values, not proposed card stats.</p><p class="hint">Palette-translated monsters are labelled: these show their base sprite; in-game recolouring, transparency, lighting and attached effects may differ. Selecting monsters only makes a shortlist.</p></header>
<div class="toolbar"><input id="search" placeholder="Search monster name or actor…" aria-label="Search monsters"><select id="family" aria-label="Monster family"><option value="">All families</option>'''+options+'''</select><button id="only">Show selected</button><button id="copy">Copy shortlist</button><button id="download">Save shortlist</button></div><div id="status" aria-live="polite"></div><main><div id="selection" class="hidden"></div><div class="grid">'''+''.join(cards)+'''</div></main><footer>Source: MegaMonsterMix-V1.2.zip → MegaMonsterMix-V1.2.pk3. Includes replacement roster and additional concrete monster forms. Effects, projectiles, spawners and abstract base classes are excluded.</footer><script>
const articles=[...document.querySelectorAll('article')], search=document.querySelector('#search'), family=document.querySelector('#family');let only=false,chosen=new Set();try{chosen=new Set(JSON.parse(localStorage.getItem('hell-deck-monster-shortlist')||'[]'))}catch{}
for(const a of articles){a.querySelector('input').checked=chosen.has(a.dataset.id);a.querySelector('input').addEventListener('change',e=>{e.target.checked?chosen.add(a.dataset.id):chosen.delete(a.dataset.id);try{localStorage.setItem('hell-deck-monster-shortlist',JSON.stringify([...chosen]))}catch{}render()})}
function shortlist(){return articles.filter(a=>chosen.has(a.dataset.id)).map(a=>a.querySelector('span').textContent+' — '+a.querySelector('h2').textContent+' ['+a.dataset.id+']').join(String.fromCharCode(10))}
function render(){let visible=0;for(const a of articles){const show=(!family.value||a.dataset.family===family.value)&&a.dataset.search.includes(search.value.toLowerCase())&&(!only||chosen.has(a.dataset.id));a.classList.toggle('hidden',!show);visible+=show}document.querySelector('#status').textContent=visible+' of '+articles.length+' monsters shown · '+chosen.size+' selected';document.querySelector('#only').textContent=only?'Show all':'Show selected'}
search.addEventListener('input',render);family.addEventListener('change',render);document.querySelector('#only').onclick=()=>{only=!only;render()};document.querySelector('#copy').onclick=async()=>{const text=shortlist()||'No monsters selected.';const box=document.querySelector('#selection');box.textContent=text;box.classList.remove('hidden');try{await navigator.clipboard.writeText(text);document.querySelector('#copy').textContent='Copied!'}catch{document.querySelector('#copy').textContent='Select text above to copy'}};document.querySelector('#download').onclick=()=>{const url=URL.createObjectURL(new Blob([shortlist()||'No monsters selected.'],{type:'text/plain'}));const a=document.createElement('a');a.href=url;a.download='hell-deck-monster-shortlist.txt';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000)};render();
</script></html>'''
(OUT/'index.html').write_text(page,encoding='utf-8')
# Compact first-page contact sheet to check extraction and provide an inline preview.
sample=records[:24];sheet=Image.new('RGB',(1200,1000),'#111919');draw=ImageDraw.Draw(sheet)
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',16)
for i,r in enumerate(sample):
    x=(i%6)*200;y=(i//6)*250
    im=Image.open(OUT/r['image']);scale=min(174/im.width,190/im.height)
    im=im.resize((max(1,int(im.width*scale)),max(1,int(im.height*scale))),Image.Resampling.NEAREST)
    sheet.paste(im,(x+(200-im.width)//2,y+12+(190-im.height)//2),im)
    draw.text((x+10,y+211),f"#{r['number']:03d} {r['name'][:18]}",font=font,fill='#f2d8b5')
sheet.save(OUT/'preview.jpg',quality=94)
print(json.dumps({'monsters':len(records),'replacement_roster':sum(r['origin']=='Replacement roster' for r in records),'additional':sum(r['origin']!='Replacement roster' for r in records),'families':len(set(r['family'] for r in records)),'missing_previews':failures,'excluded_invisible_helpers':excluded,'palette_notes':sum(bool(r['note']) for r in records),'output':str(OUT/'index.html')},indent=2))
