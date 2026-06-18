#!/usr/bin/env python3
# Build a wide 1920x1080 looping hero montage (Ken Burns + crossfades), muted.
import subprocess, tempfile, os, sys
W,H,FPS,CLIP,XF = 1920,1080,30,2.8,0.7
A="assets"
imgs=["kuwait_city","macau","venice","prague","las_vegas","florence","dubai","rome","london_night","munich"]
imgs=[f"{A}/{n}.jpg" for n in imgs if os.path.exists(f"{A}/{n}.jpg")]
tmp=tempfile.mkdtemp(); clips=[]
for i,img in enumerate(imgs):
    d=int(CLIP*FPS); c=f"{tmp}/c{i}.mp4"
    z="min(zoom+0.0010,1.12)" if i%2==0 else "if(lte(zoom,1.0),1.12,max(1.001,zoom-0.0010))"
    vf=(f"scale={W}:{H}:force_original_aspect_ratio=increase,crop={W}:{H},"
        f"zoompan=z='{z}':d={d}:fps={FPS}:s={W}x{H}:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',setsar=1,format=yuv420p")
    subprocess.run(["ffmpeg","-y","-loop","1","-i",img,"-vf",vf,"-frames:v",str(d),"-r",str(FPS),"-an",c],check=True,capture_output=True)
    clips.append(c)
n=len(clips); fc=""; prev="[0:v]"; off=CLIP-XF
ins=[]
for c in clips: ins+=["-i",c]
for i in range(1,n):
    lbl=f"[x{i}]"; fc+=f"{prev}[{i}:v]xfade=transition=fade:duration={XF}:offset={off:.2f}{lbl};"; prev=lbl; off+=CLIP-XF
fc+=f"{prev}null[v]"
subprocess.run(["ffmpeg","-y"]+ins+["-filter_complex",fc,"-map","[v]","-r",str(FPS),
    "-c:v","libx264","-pix_fmt","yuv420p","-movflags","+faststart","-crf","26","assets/hero.mp4"],check=True,capture_output=True)
print("hero.mp4 built", os.path.getsize("assets/hero.mp4")//1024,"KB")
