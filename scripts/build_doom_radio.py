"""Render local WAD MUS scores and prepare a separate Donkey Kong picker.

Requires tinysoundfont and ffmpeg. MUS event reference:
https://github.com/chocolate-doom/chocolate-doom/blob/master/src/mus2mid.c
Original archives are preserved outside exported assets.
"""
import ast, concurrent.futures, hashlib, json, shutil, struct, subprocess
from pathlib import Path
import tinysoundfont

ROOT = Path(__file__).resolve().parents[1]
RADIO = ROOT / 'assets/radio'
ARCHIVE = ROOT / 'reports/radio-archive'
PICKER = ROOT / 'reports/donkey-kong-picker'
SF = Path('C:/DoomMods/NuggetDoom/Nugget-Doom-5.1.0-win64/soundfonts/TimGM6mb.sf2')
BASE = Path('C:/Program Files (x86)/Steam/steamapps/common/Ultimate Doom/base')
RATE = 32000
CONTROLS = [0,32,1,7,10,11,91,93,64,67,120,123,126,127,121]

def prepare_picker():
    PICKER.mkdir(parents=True, exist_ok=True)
    (PICKER/'.gdignore').touch()
    (PICKER/'audio').mkdir(exist_ok=True)
    source = json.loads((ROOT/'reports/music-picker/tracks.json').read_text())
    tracks = [t for t in source if 'Donkey Kong' in t['album']]
    for t in tracks:
        shutil.copy2(ROOT/'reports/music-picker'/t['file'], PICKER/t['file'])
    tree = ast.parse((ROOT/'scripts/build_music_picker.py').read_text(encoding='utf-8'))
    template = next(ast.literal_eval(n.value) for n in tree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='html' for t in n.targets))
    template = template.replace('SNES music picker','Donkey Kong music picker').replace('SNES background music picker','Choose your Donkey Kong music')
    template = template.replace('974 songs · 60-second listening previews · original SPC files preserved',f'{len(tracks)} tracks from Donkey Kong Country 2 and 3 · 60-second previews · choose tracks, then export your picks')
    template = template.replace('doom-snes-music-picks-v1','doom-donkey-kong-picks-v1').replace('doom-background-music-picks.json','donkey-kong-picks.json')
    (PICKER/'index.html').write_text(template.replace('TRACKS',json.dumps(tracks).replace('</','<\\/')),encoding='utf-8')
    (PICKER/'tracks.json').write_text(json.dumps(tracks,indent=2))
    return len(tracks)

def render(job):
    album,name,data = job
    filename = album.replace(' ','_')+'_'+name+'.ogg'
    output = RADIO/'audio'/filename
    synth = tinysoundfont.Synth(gain=-9,samplerate=RATE)
    sfid = synth.sfload(str(SF))
    for ch in range(16): synth.program_select(ch,sfid,0,0,is_drums=ch==15)
    pos = struct.unpack_from('<H',data,6)[0]
    velocity = [127]*16
    ticks = frames = 0
    proc = subprocess.Popen(['ffmpeg','-hide_banner','-loglevel','error','-y','-f','f32le','-ar',str(RATE),'-ac','2','-i','pipe:0','-c:a','libvorbis','-q:a','2',str(output)],stdin=subprocess.PIPE)
    try:
        while pos<len(data):
            event=data[pos]; pos+=1
            ch=event&15; kind=(event>>4)&7
            if kind==6: break
            value=data[pos]; pos+=1
            if kind==0: synth.noteoff(ch,value&127)
            elif kind==1:
                if value&128: velocity[ch]=data[pos]&127; pos+=1
                synth.noteon(ch,value&127,velocity[ch])
            elif kind==2: synth.pitchbend(ch,value*64)
            elif kind==3: synth.control_change(ch,CONTROLS[value],0)
            elif kind==4:
                amount=min(127,data[pos]); pos+=1
                if value==0: synth.program_select(ch,sfid,0,amount,is_drums=ch==15)
                else: synth.control_change(ch,CONTROLS[value],amount)
            else: raise ValueError(f'Unknown MUS event {kind}')
            if event&128:
                delta=0
                while True:
                    b=data[pos]; pos+=1; delta=(delta<<7)+(b&127)
                    if not b&128: break
                ticks+=delta
                target=round(ticks*RATE/140)
                remaining=target-frames
                while remaining:
                    count=min(remaining,8192)
                    proc.stdin.write(synth.generate_simple(count)); remaining-=count
                frames=target
        for ch in range(16): synth.notes_off(ch)
        proc.stdin.write(synth.generate_simple(RATE*2))
    finally:
        proc.stdin.close()
    assert proc.wait()==0
    assert frames>0 and output.stat().st_size>1000
    return dict(id=filename[:-4],album=album,title=name.removeprefix('D_').replace('_',' '),composer='Original WAD soundtrack',file='res://assets/radio/audio/'+filename,source=album+'/'+name,seconds=frames/RATE+2)

def main():
    print(f'Picker: {prepare_picker()} Donkey Kong tracks',flush=True)
    ARCHIVE.mkdir(parents=True,exist_ok=True)
    (ARCHIVE/'.gdignore').touch()
    # Verify both paths are inside this workspace before moving the old library.
    src=(RADIO/'audio').resolve(); dst=(ARCHIVE/'audio').resolve()
    assert src.is_relative_to(ROOT) and dst.is_relative_to(ROOT)
    if not dst.exists():
        shutil.copy2(RADIO/'tracks.json',ARCHIVE/'tracks.json')
        shutil.move(str(src),str(dst))
    (RADIO/'audio').mkdir(exist_ok=True)
    jobs=[]
    for album,path in [('DOOM',BASE/'DOOM.WAD'),('DOOM II',BASE/'doom2/DOOM2.WAD')]:
        data=path.read_bytes(); n,offset=struct.unpack_from('<II',data,4)
        lumps={}
        for i in range(n):
            start,size,name=struct.unpack_from('<II8s',data,offset+i*16)
            name=name.rstrip(b'\0').decode('ascii')
            if name.startswith('D_') and data[start:start+4]==b'MUS\x1a': lumps[name]=data[start:start+size]
        seen=set()
        for name,score in lumps.items():
            digest=hashlib.sha256(score).digest()
            if digest in seen: continue
            seen.add(digest); jobs.append((album,name,score))
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        tracks=[]
        for t in pool.map(render,jobs):
            tracks.append(t); print(f'{len(tracks)}/{len(jobs)} {t["id"]}',flush=True)
    (RADIO/'tracks.json').write_text(json.dumps(tracks,indent=2),encoding='utf-8')
    print(f'DONE: {len(tracks)} DOOM tracks, {sum(p.stat().st_size for p in (RADIO/"audio").glob("*.ogg"))/1024**2:.1f} MiB',flush=True)

if __name__=='__main__': main()
