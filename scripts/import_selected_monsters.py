"""Extract the user's selected actors as Godot assets. Never execute pack scripts."""
import contextlib, csv, hashlib, io, json, re, runpy, struct, wave, subprocess
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
with contextlib.redirect_stdout(io.StringIO()):
    source=runpy.run_path(str(ROOT/'scripts/build_monster_catalogue.py'))
actors=source['actors']; pack=source['pack']; lumps=source['lumps']; decode=source['decode']; sprites=source['sprites']; inherited=source['inherited']
OUT=ROOT/'assets'/'monsters'; OUT.mkdir(parents=True,exist_ok=True)
rows=list(csv.DictReader((ROOT/'scripts/selected_roster.tsv').open(),delimiter='\t'))
assert len(rows)==63 and len({r['actor'] for r in rows})==63
family_ids={'Zombieman':1,'Sergeant':3,'Commando':15,'Imp':0,'Demon':2,'Lostsoul':4,'Cacodemon':5,'PainElemental':20,'Revenant':17,'Hellknight':16,'Mancubus':18,'Arachnotron':19,'Baron':6,'Mastermind':21,'Cyberdemon':8}
records={r['actor']:r for r in source['records']}

def states(actor):
    info=actors.get(actor.lower())
    if not info: return {}
    result=states(info['parent']) if info['parent'].lower() in actors else {}
    for m in re.finditer(r'^\s*([A-Za-z_][\w.]*)\s*:\s*([\s\S]*?)(?=^\s*[A-Za-z_][\w.]*\s*:|\Z)',info['body'],re.M):
        result[m[1].lower()]=m[2]
    return result

def state_frames(table,name,seen=None):
    seen=set() if seen is None else seen
    if name.lower() in seen: return []
    seen.add(name.lower()); body=table.get(name.lower(),'')
    result=[]
    for prefix,poses in re.findall(r'^\s*([A-Za-z0-9_]{4})\s+([A-Z]+)\s+-?\d+',body,re.M):
        if prefix.upper()!='TNT1':
            for pose in poses:
                pair=(prefix.upper(),pose)
                if not result or result[-1]!=pair: result.append(pair)
    if result: return result[:8]
    for target in re.findall(r'\bGoto\s+([\w.]+)|"([\w.]+)"',body,re.I):
        target=target[0] or target[1]
        if target.lower() in table and target.lower() not in ['see','spawn','death','pain']:
            result=state_frames(table,target,seen)
            if result:return result
    return []

sprite_index={}
for name,path in list(sprites.items())+[(n,'IWAD:'+n) for n in lumps if len(n) in [6,8]]:
    for i in [4,6]:
        if len(name)>=i+2 and name[i+1].isdigit():
            key=(name[:4],name[i],name[i+1])
            if key not in sprite_index: sprite_index[key]=(path,i==6)

def frame_image(pair,side):
    prefix,pose=pair
    for rotation in (['3','0','1'] if side else ['1','0']):
        entry=sprite_index.get((prefix,pose,rotation))
        if entry:
            path,flip=entry
            im=decode(lumps[path[5:]] if path.startswith('IWAD:') else pack.read(path))
            if flip: im=im.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            return im,path
    return None,''

palette=[tuple(source['palette'][i:i+3]) for i in range(0,768,3)]
def colour_table(actor):
    translation=inherited(actor,r'^\s*Translation\s+([^\n]+)')
    lut=palette.copy()
    if not translation: return None
    for rule in re.findall(r'"([^"\n]+)"',translation[1]):
        match=re.match(r'(\d+):(\d+)=(.*)',rule)
        if not match: continue
        lo,hi=int(match[1]),int(match[2]);spec=match[3]; count=max(1,hi-lo)
        nums=[float(n) for n in re.findall(r'-?\d+(?:\.\d+)?',spec)]
        for i in range(lo,min(255,hi)+1):
            if spec.startswith('%') and len(nums)==6:
                # Bake the pack's desaturated palette gradient into the sprite.
                grey=sum(a*b for a,b in zip(palette[i],[0.299,0.587,0.114]))/255
                lut[i]=tuple(max(0,min(255,round((nums[k]+(nums[k+3]-nums[k])*grey)*255))) for k in range(3))
            elif spec.startswith('@') and len(nums)==4:
                amount=max(0,min(1,nums[0]/100))
                lut[i]=tuple(round(palette[i][k]*(1-amount)+nums[k+1]*amount) for k in range(3))
            elif spec.startswith('[') and len(nums)==6:
                lut[i]=tuple(round(nums[k]+(nums[k+3]-nums[k])*(i-lo)/count) for k in range(3))
            elif len(nums)==2:
                lut[i]=palette[max(0,min(255,round(nums[0]+(nums[1]-nums[0])*(i-lo)/count)))]
    return lut

def tint(im,lut,actor):
    if lut:
        # Match the original Doom palette before applying actor translations.
        mapping={}
        for pixel in set(im.getdata()):
            rgb=pixel[:3]
            index=min(range(256),key=lambda i:sum((rgb[k]-palette[i][k])**2 for k in range(3)))
            mapping[pixel]=(*lut[index],pixel[3])
        im.putdata([mapping[p] for p in im.getdata()])
    alpha=inherited(actor,r'^\s*Alpha\s+([\d.]+)')
    if alpha:
        # Keep spectral units visible against the dark tabletop.
        opacity=max(0.55,float(alpha[1]));im.putalpha(im.getchannel('A').point(lambda a:round(a*opacity)))
    return im

sndtext=pack.read('SNDINFO.txt').decode('utf-8-sig',errors='replace').replace('\r','')
sndtext=re.sub(r'//[^\n]*','',sndtext)
sound_defs={}
for m in re.finditer(r'\$random\s+(\S+)\s*\{([^}]+)\}',sndtext,re.I): sound_defs[m[1].lower()]=m[2].split()
for m in re.finditer(r'\$alias\s+(\S+)\s+(\S+)',sndtext,re.I): sound_defs[m[1].lower()]=[m[2]]
for m in re.finditer(r'^\s*([^\s${}]+)\s+([^\s{}]+)\s*$',sndtext,re.M): sound_defs[m[1].lower()]=[m[2]]
sound_files={Path(n).stem.lower():n for n in pack.namelist() if n.lower().startswith('sounds/') and not n.endswith('/')}
sound_files.update({n.lower()[7:]:n for n in pack.namelist() if n.lower().startswith('sounds/') and not n.endswith('/')})
sound_assets={};unsupported=[]

def sound_paths(name,seen=None):
    seen=set() if seen is None else seen
    key=name.lower().strip('"')
    if key in seen:return []
    seen.add(key)
    if key in sound_defs and sound_defs[key]!=[name]:
        paths=[]
        for child in sound_defs[key]: paths+=sound_paths(child,seen.copy())
        if paths:return list(dict.fromkeys(paths))[:3]
    file=sound_files.get(key)
    if not file:return []
    if file in sound_assets:return [sound_assets[file]]
    data=pack.read(file);digest=hashlib.sha1(file.encode()).hexdigest()[:12]
    if data.startswith(b'RIFF'):ext='wav'
    elif data.startswith(b'OggS') and b'Sony Ogg Vorbis 1.0 Final' not in data:ext='ogg'
    elif data.startswith(b'fLaC') or data.startswith(b'OggS'):
        pcm=subprocess.run(['ffmpeg','-v','error','-i','pipe:0','-f','s16le','-ar','22050','-ac','1','pipe:1'],input=data,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=True).stdout
        buffer=io.BytesIO()
        with wave.open(buffer,'wb') as w:
            w.setnchannels(1);w.setsampwidth(2);w.setframerate(22050);w.writeframes(pcm)
        data=buffer.getvalue()
        ext='wav'
    elif data[:2]==b'\x03\x00':
        rate=struct.unpack_from('<H',data,2)[0];length=struct.unpack_from('<I',data,4)[0]
        buffer=io.BytesIO()
        with wave.open(buffer,'wb') as w:
            w.setnchannels(1);w.setsampwidth(1);w.setframerate(rate);w.writeframes(data[24:8+length-16])
        data=buffer.getvalue();ext='wav'
    else:
        unsupported.append(file);return []
    dest=OUT/'sounds'/f'{digest}.{ext}';dest.parent.mkdir(exist_ok=True);dest.write_bytes(data)
    path='res://'+dest.relative_to(ROOT).as_posix();sound_assets[file]=path
    return [path]

def source_sound(actor,kind,table):
    prop={'summon':'SeeSound','pain':'PainSound','death':'DeathSound','attack':'AttackSound'}[kind]
    match=inherited(actor,r'\b'+prop+r'\s+"([^"\n]+)"')
    names=[match[1]] if match else []
    if kind=='attack':
        blocks=[table.get(k,'') for k in ['missile','missileloop','melee','shoot','fire','attack']]
        for block in blocks:
            names+=re.findall(r'A_PlaySound(?:Ex)?\s*\(\s*"([^"]+)"',block,re.I)
            names+=re.findall(r'A_CustomMeleeAttack\s*\([^\n]*?,\s*"([^"]+)"',block,re.I)
        names.sort(key=lambda n:0 if any(s in n.lower() for s in ['fire','attack','shoot','melee']) else 1)
    for name in names:
        paths=sound_paths(name)
        if paths:return paths
    return []

# Projectile classes also live outside the monster definition files.
for path in pack.namelist():
    if not path.lower().startswith('decorate/') or not path.lower().endswith('.txt'): continue
    raw=pack.read(path).decode('utf-8-sig',errors='replace').replace('\r','')
    clean=re.sub(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*[\s\S]*?\*/',lambda m:m[0] if m[0].startswith('"') else ' ',raw)
    for match in re.finditer(r'\bActor\s+(\w+)\s*(?::\s*(\w+))?[^{}]*\{',clean,re.I):
        if match[1].lower() in actors: continue
        start=match.end();depth=1;end=start
        for token in re.finditer(r'"(?:\\.|[^"\\])*"|[{}]',clean[start:]):
            if token[0]=='{':depth+=1
            elif token[0]=='}':depth-=1
            if depth==0:end=start+token.start();break
        actors[match[1].lower()]={'actor':match[1],'parent':match[2] or '', 'body':clean[start:end],'source':path}

def export_projectile(actor,table):
    blocks='\n'.join(body for name,body in table.items() if name.startswith(('missile','shoot','fire','attack')))
    candidates=re.findall(r'A_(?:CustomMissile|SpawnProjectile|FireCustomMissile)\s*\(\s*"([^"\n]+)"',blocks,re.I)
    for projectile in dict.fromkeys(candidates):
        ptable=states(projectile)
        flight=state_frames(ptable,'spawn')
        # Some projectile Spawn states only start a sound, then fall into Go/Fly.
        if not flight:
            flight=next((frames for name in ptable if name.startswith(('go','fly','flight','move')) and (frames:=state_frames(ptable,name))),[])
        if not flight: continue
        result={}
        for label,pairs,side in [('flight',flight,False),('flight_side',flight,True),('impact',state_frames(ptable,'death'),False),('impact_side',state_frames(ptable,'death'),True)]:
            result[label]=[]
            for i,pair in enumerate(pairs):
                im,_=frame_image(pair,side)
                if im is None:continue
                im=tint(im,colour_table(projectile),projectile)
                dest=OUT/actor/f'projectile-{label}-{i}.png';dest.parent.mkdir(exist_ok=True);im.save(dest)
                result[label].append('res://'+dest.relative_to(ROOT).as_posix())
        if result['flight'] and result['flight_side']:
            result['actor']=projectile
            return result
    return {}

manifest={};catalog=[];audit=[]
for index,row in enumerate(rows):
    actor=row['actor'];record=records[actor]; family=family_ids[record['family']]
    features={}
    for feature in filter(None,row['features'].split(',')):
        key,value=feature.split('=');features[key]=True if value=='true' else int(value)
    kind=row['type']; table=states(actor);lut=colour_table(actor)
    card={'name':record['name'].upper(),'art':'MMM_'+actor,'base_id':family,'actor':actor,'cost':int(row['cost']),'atk':int(row['atk']),'hp':int(row['hp']),'type':kind,'rarity':int(row['rarity']),'splash':0}
    card.update(features)
    card['weak']='FIRE' if family in [1,3,15,2] else ('ENERGY' if family in [8,18,4,20] else 'ROCKET')
    card['resist']='ICE' if kind=='ICE' else ('FIRE' if family in [0,5,6,16,18,20] else ('BULLET' if family in [2,8,19,21] else ''))
    descriptions=[]
    if family==5:card['starting_shield']=True
    for key,value in card.items():
        if key=='strikes':descriptions.append(f'{value} attacks per phase.')
        if key=='splash' and value:descriptions.append(f'{value} splash to adjacent enemy lanes.')
        if key=='armor':descriptions.append('Armor: non-counter hits deal 1 less (minimum 1).')
        if key=='starting_shield':descriptions.append('Shield: blocks first hit; against a counter, absorbs 1 damage.')
        if key=='seeking':descriptions.append('Homing: seeks nearest enemy when unblocked.')
        if key=='chill':descriptions.append('Chill: damaged target has -1 ATK for its next attack phase.')
        if key=='lifesteal':descriptions.append('Drain: heal your Health by 1 per damaging main hit.')
        if key=='kill_souls':descriptions.append('Player kills grant 1 extra Soul.')
        if key=='death_spawn':descriptions.append('On death: leaves a Lost Soul; it waits a turn.')
    card['ability']=' '.join(descriptions) or 'Frontline fighter. Reinforces its monster family.'
    if kind=='ICE':card['projectile']='PLSS';card['projectile_tint']='#9deaff'
    elif kind=='ENERGY':card['projectile']='PLSS'
    elif kind=='ROCKET':card['projectile']='MISL'
    elif kind=='FIRE':card['projectile']='BAL1'
    entry={}; paths_used=[]
    # Spawn is often a single lookout pose, even when See has a full walk cycle.
    # Preserve animated idle states; otherwise use the monster's locomotion loop.
    idle_candidates=[(name,state_frames(table,name)) for name in ['spawn','idle','see']]
    idle_state,idle=next(((name,frames) for name,frames in idle_candidates if len(set(frames))>1),
                         next((item for item in idle_candidates if item[1]),('spawn',[])))
    if actor=='Demolitron':
        table = {k:v for k,v in table.items() if not k.startswith('missile') or k=='missile2'}
        table['missile'] = table.pop('missile2')
        card['ability'] = 'Dual miniguns: two bullet barrages per combat phase.'
    attack=state_frames(table,'missile') or state_frames(table,'melee')
    if actor=='Minigunner': attack += state_frames(table,'missileloop')
    if not attack:raise ValueError('Missing attack state: '+actor)
    for label,pairs,side in [('idle',idle,False),('attack',attack,False),('side',idle,True),('side_attack',attack,True)]:
        entry[label]=[]
        for frame,pair in enumerate(pairs):
            im,source_path=frame_image(pair,side)
            if im is None:continue
            im=tint(im,lut,actor)
            dest=OUT/actor/f'{label}-{frame}.png';dest.parent.mkdir(exist_ok=True);im.save(dest)
            entry[label].append('res://'+dest.relative_to(ROOT).as_posix());paths_used.append(source_path)
        if not entry[label]:raise ValueError('No sprites: '+actor+' '+label)
    projectile=export_projectile(actor,table) if kind!='MELEE' else {}
    if projectile:
        entry['projectile_effect']=projectile
        card['projectile']='MMM_SHOT_'+actor
        if projectile['impact'] and projectile['impact_side']:card['impact']='MMM_HIT_'+actor
    entry['sounds']={k:source_sound(actor,k,table) for k in ['summon','attack','pain','death']}
    manifest[card['art']]=entry;catalog.append(card)
    audit.append({'id':82+index,'actor':actor,'name':card['name'],'family_id':family,'idle_state':idle_state,'frames':{k:len(v) for k,v in entry.items() if k not in ['sounds','projectile_effect']},'pack_sounds':{k:len(v) for k,v in entry['sounds'].items()},'palette_baked':lut is not None,'sources':list(dict.fromkeys(paths_used))})

(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
(ROOT/'scripts/monster_roster.gd').write_text('extends RefCounted\n## Selected pack cards; appended after legacy IDs 0-81.\nconst DATA := '+json.dumps(catalog,indent=2)+'\n',encoding='utf-8')
(ROOT/'reports/selected-monsters-import.json').write_text(json.dumps({'cards':audit,'unique_pack_sounds':len(sound_assets),'unsupported_sounds':sorted(set(unsupported)),'source_archive':str(source['ARCHIVE']),'translation_note':'Palette gradients and tints baked for Godot; spectral opacity lifted to 55% for tabletop readability.'},indent=2),encoding='utf-8')
print(f'Imported {len(catalog)} cards, {sum(sum(v["frames"].values()) for v in audit)} sprite frames, {len(sound_assets)} sounds.')
print('Pack sound coverage:',{k:sum(bool(a['pack_sounds'][k]) for a in audit) for k in ['summon','attack','pain','death']})
print('Unsupported sound files:',sorted(set(unsupported)))
