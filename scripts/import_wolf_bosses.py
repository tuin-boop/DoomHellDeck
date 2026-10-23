"""Read Wolfenstein WAD assets as data only; never execute actor scripts."""
import io, json, struct, zipfile, zlib, wave
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/wolf_bosses'
OUT.mkdir(parents=True, exist_ok=True)

def wad(data):
    assert data[:4] in (b'PWAD', b'IWAD')
    count, directory = struct.unpack_from('<II', data, 4)
    result = {}
    for i in range(count):
        offset, size, name = struct.unpack_from('<II8s', data, directory + i*16)
        assert offset+size <= len(data)
        result[name.rstrip(b'\0').decode('ascii')] = data[offset:offset+size]
    return result

palette = wad(Path('C:/Program Files (x86)/Steam/steamapps/common/Ultimate Doom/base/doom2/DOOM2.WAD').read_bytes())['PLAYPAL'][:768]

def decode(data):
    if data.startswith(b'\x89PNG'):
        pos = 8
        fixed = data[:8]
        while pos+12 <= len(data):
            size = struct.unpack_from('>I', data, pos)[0]
            chunk = data[pos+4:pos+8+size]
            fixed += struct.pack('>I',size)+chunk+struct.pack('>I',zlib.crc32(chunk))
            pos += size+12
        return Image.open(io.BytesIO(fixed)).convert('RGBA')
    width, height = struct.unpack_from('<HH', data)
    assert 0 < width < 4096 and 0 < height < 4096
    image = Image.new('RGBA',(width,height))
    for x in range(width):
        pos = struct.unpack_from('<I',data,8+x*4)[0]
        previous = -1
        while data[pos] != 255:
            y, length = data[pos:pos+2]
            if y <= previous: y += previous
            previous = y
            for dy, index in enumerate(data[pos+3:pos+3+length]):
                if y+dy < height: image.putpixel((x,y+dy),(*palette[index*3:index*3+3],255))
            pos += length+4
    return image

def archive(name):
    z = zipfile.ZipFile(Path('C:/Users/pvand/Downloads')/name)
    lumps = wad(z.read(next(n for n in z.namelist() if n.lower().endswith('.wad'))))
    credits = OUT/'credits'
    credits.mkdir(exist_ok=True)
    for n in z.namelist():
        if n.lower().endswith('.txt'): (credits/Path(n).name).write_bytes(z.read(n))
    if 'CREDITS' in lumps: (credits/(Path(name).stem+'-credits.txt')).write_bytes(lumps['CREDITS'])
    return lumps

def frames(lumps, actor, prefix, poses, rotation, kind):
    result = []
    for frame in poses:
        found = None
        for rot in [rotation,'0']:
            for name, data in lumps.items():
                if name[:4] != prefix: continue
                for i in [4,6]:
                    if name[i:i+2] == frame+rot:
                        found = (data,i==6)
                        break
                if found: break
            if found: break
        assert found, (actor, frame, rotation)
        image = decode(found[0])
        if found[1]: image = image.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        folder = OUT/actor
        folder.mkdir(exist_ok=True)
        path = folder/f'{kind}-{len(result)}.png'
        image.save(path)
        result.append('res://'+path.relative_to(ROOT).as_posix())
    return result

manifest = {}
sources = [
    ('wolf3drotations.zip', [('MechaHitler','MHTL','EFGFGF'),('UnarmoredHitler','HTLR','EFGFGF')], {'summon':'HIT1_ACT','attack':'HIT1_ATT','death':'HIT1_DT2'}),
    ('Schabbs (1).zip', [('Schabbs','SCHB','EF')], {'summon':'SCHABSEE','attack':'SCHABATT','death':'SCHABDTH'}),
    ('Hans_Chrome_Guns.zip', [('Hans','HANS','EFGFG')], {'summon':'HANSSIT','attack':'HANSCHNG','death':'HANSDTH'})]
for name, actors, sounds in sources:
    lumps = archive(name)
    for actor, prefix, attack in actors:
        entry = {}
        for kind, poses, rotation in [('idle','ABCD','1'),('attack',attack,'1'),('side','ABCD','3'),('side_attack',attack,'3')]:
            entry[kind] = frames(lumps,actor,prefix,poses,rotation,kind)
        entry['sounds'] = {}
        for event, lump in sounds.items():
            assert lumps[lump][:4] == b'RIFF'
            path = OUT/actor/(event+'.wav')
            with wave.open(io.BytesIO(lumps[lump]),'rb') as original:
                params = original.getparams()
                samples = original.readframes(original.getnframes())
                if len(samples)%2: samples += samples[-params.sampwidth*params.nchannels:]
            with wave.open(str(path),'wb') as clean:
                clean.setparams(params)
                clean.writeframes(samples)
            entry['sounds'][event] = ['res://'+path.relative_to(ROOT).as_posix()]
        if actor == 'Schabbs':
            entry['projectile_effect'] = {
                'flight':frames(lumps,actor,'NEDL','ABCD','1','needle'),
                'flight_side':frames(lumps,actor,'NEDL','ABCD','3','needle-side'),
                'impact':[], 'impact_side':[]}
        manifest['MMM_'+actor] = entry
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
# Contact sheet for checking transparency, rotations, and attack frames.
sheet = Image.new('RGB',(800,480),'#142025')
draw = ImageDraw.Draw(sheet)
for row,(key,entry) in enumerate(manifest.items()):
    draw.text((8,row*120+6),key,fill='white')
    for col,kind in enumerate(['idle','attack','side','side_attack']):
        im = Image.open(ROOT/entry[kind][-1].removeprefix('res://'))
        im.thumbnail((140,88),Image.Resampling.NEAREST)
        sheet.paste(im,(col*200+30,row*120+26),im)
sheet.save(ROOT/'captures/wolf-bosses-assets.png')
print('Imported 3 cards / 4 forms, front and side animations, 12 sounds, and Schabbs needle projectile.')
