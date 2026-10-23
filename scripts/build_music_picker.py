import json,re,subprocess,concurrent.futures,shutil
from pathlib import Path
from zipfile import ZipFile
out=Path(__file__).resolve().parents[1]/'reports/music-picker'
(out/'audio').mkdir(parents=True,exist_ok=True)
(out/'spc').mkdir(exist_ok=True)
(out/'.gdignore').write_text('')
tracks=[]
with ZipFile(r'C:/Users/pvand/Downloads/SNES-Jukebox-Album-Edition-v1.1.pk3') as z:
    names={n.lower():n for n in z.namelist()}
    lang=z.read('LANGUAGE.txt').decode('utf-8',errors='replace')
    for match in re.finditer(r'^JUKEBOX_(\d+)\s*=\s*"(.*?)";',lang,re.M):
        num=int(match[1]); raw=re.sub(r'\\c.','',match[2]).replace(r'\n','\n')
        fields={k:v.strip() for k,v in re.findall(r'(Game|Song|Composer|Genre):\s*([^\n]+)',raw)}
        filename=f'SONG{num:03}.spc'
        (out/'spc'/filename).write_bytes(z.read(names[('music/'+filename).lower()]))
        tracks.append(dict(id=num,title=fields.get('Song',filename),album=fields.get('Game','Unknown'),composer=fields.get('Composer',''),file=f'audio/SONG{num:03}.ogg',source='music/'+filename))
tracks.sort(key=lambda t:(t['album'],t['id']))
(out/'tracks.json').write_text(json.dumps(tracks,indent=2),encoding='utf-8')
html=r"""<!doctype html><meta charset="utf-8"><title>SNES music picker</title><style>
body{background:#101918;color:#e8e6d6;font:16px system-ui;margin:0}header{position:sticky;top:0;background:#142523;padding:24px;z-index:2;border-bottom:2px solid #ed993e}h1{margin:0 0 8px;color:#ffc479}button,input,select{font:inherit;padding:10px;border:1px solid #6b8177;border-radius:5px;background:#263a35;color:#fff}button{cursor:pointer}#rows{padding:20px;display:grid;grid-template-columns:repeat(auto-fill,minmax(360px,1fr));gap:12px}.card{border:1px solid #526b60;padding:16px;border-radius:8px;background:#182824}.card.picked{border-color:#ffbf69;background:#304330}.name{font-size:19px;font-weight:bold;display:block;margin:8px 0}.meta{color:#b4c8bc;font-size:14px}audio{width:100%;margin-top:12px}#status{margin:10px 0}.tools{display:flex;gap:10px;flex-wrap:wrap}label{cursor:pointer}small{color:#c3c5b8}</style>
<header><h1>SNES background music picker</h1><p>974 songs · 60-second listening previews · original SPC files preserved</p><div class="tools"><input id="search" placeholder="Find a song, game or composer"><select id="album"><option value="">All games</option></select><label><input id="only" type="checkbox">My picks only</label><button id="export">Export my picks</button></div><div id="status"></div><small>Only one preview plays at a time. Selections save in this browser. Export your picks when finished.</small></header><main id="rows"></main><script>
const tracks=TRACKS;const key='doom-snes-music-picks-v1';let picked;try{picked=new Set(JSON.parse(localStorage.getItem(key)||'[]'))}catch{picked=new Set()}
const rows=document.querySelector('#rows'),status=document.querySelector('#status'),album=document.querySelector('#album'),search=document.querySelector('#search'),only=document.querySelector('#only');
for(const game of [...new Set(tracks.map(t=>t.album))].sort()){const o=document.createElement('option');o.value=game;o.textContent=game;album.append(o)}
function save(){try{localStorage.setItem(key,JSON.stringify([...picked]))}catch{} update()}
function update(){status.textContent=`${picked.size} selected · ${rows.children.length} shown`}
function render(){rows.replaceChildren();const q=search.value.toLowerCase();for(const t of tracks){if(album.value&&t.album!==album.value||only.checked&&!picked.has(t.id)||!`${t.title} ${t.album} ${t.composer}`.toLowerCase().includes(q))continue;const box=document.createElement('article');box.className='card'+(picked.has(t.id)?' picked':'');const label=document.createElement('label'),check=document.createElement('input');check.type='checkbox';check.checked=picked.has(t.id);label.append(check,document.createTextNode(` Keep #${t.id}`));check.onchange=()=>{check.checked?picked.add(t.id):picked.delete(t.id);box.classList.toggle('picked',check.checked);save()};const title=document.createElement('span');title.className='name';title.textContent=t.title;const meta=document.createElement('div');meta.className='meta';meta.textContent=t.album+' · '+t.composer;const audio=document.createElement('audio');audio.controls=true;audio.preload='none';audio.src=t.file;audio.onplay=()=>{document.querySelectorAll('audio').forEach(other=>{if(other!==audio)other.pause()})};box.append(label,title,meta,audio);rows.append(box)}update()}
search.oninput=render;album.onchange=render;only.onchange=render;document.querySelector('#export').onclick=()=>{const data={archive:'SNES-Jukebox-Album-Edition-v1.1.pk3',selected:tracks.filter(t=>picked.has(t.id))};const url=URL.createObjectURL(new Blob([JSON.stringify(data,null,2)],{type:'application/json'}));const a=document.createElement('a');a.href=url;a.download='doom-background-music-picks.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000)};render();</script>"""
(out/'index.html').write_text(html.replace('TRACKS',json.dumps(tracks).replace('</','<\/')),encoding='utf-8')
ffmpeg=shutil.which('ffmpeg')
def convert(t):
    target=out/t['file']
    if target.exists() and target.stat().st_size>1000:return
    result=subprocess.run([ffmpeg,'-hide_banner','-loglevel','error','-y','-i',str(out/t['source'].replace('music/','spc/')),'-t','60','-af','afade=t=out:st=58:d=2','-c:a','libvorbis','-q:a','3',str(target)],capture_output=True)
    if result.returncode:raise RuntimeError(result.stderr.decode(errors='replace'))
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
    for i,_ in enumerate(pool.map(convert,tracks),1):
        if i%100==0:print(f'{i}/{len(tracks)} rendered',flush=True)
assert len(tracks)==974
assert all((out/t['file']).stat().st_size>1000 for t in tracks)
print('DONE: '+str(out/'index.html'),flush=True)
