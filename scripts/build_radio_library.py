from pathlib import Path
import json,shutil,subprocess,concurrent.futures
root=Path(__file__).resolve().parents[1]
source=root/'reports/music-picker'
out=root/'assets/radio'
(out/'audio').mkdir(parents=True,exist_ok=True)
tracks=json.loads((source/'tracks.json').read_text())
for t in tracks:t['file']='res://assets/radio/'+t['file']
(out/'tracks.json').write_text(json.dumps(tracks,indent=2),encoding='utf-8')
ffmpeg=shutil.which('ffmpeg')
def convert(t):
 target=root/t['file'].replace('res://','')
 if target.exists() and target.stat().st_size>1000:return
 inp=source/'spc'/Path(t['source']).name
 subprocess.run([ffmpeg,'-hide_banner','-loglevel','error','-y','-i',str(inp),'-t','180','-af','afade=t=out:st=177:d=3','-ar','32000','-c:a','libvorbis','-q:a','1',str(target)],check=True,capture_output=True)
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
 for i,_ in enumerate(pool.map(convert,tracks),1):
  if i%100==0:print(f'{i}/974 full radio tracks rendered',flush=True)
print('DONE',flush=True)
