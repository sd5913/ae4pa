"""Export the original game PNGs and flattened preview from the editable ORA.

Requires Python 3 and Pillow. No AI service, original flattened reference, or
machine-specific file paths are needed to reproduce the delivered images.
"""
from pathlib import Path
from PIL import Image
import argparse, io, json, zipfile, xml.etree.ElementTree as ET

def flatten(node, archive, size):
    out=Image.new('RGBA',size)
    for child in reversed(list(node)):
        if child.get('visibility')=='hidden': continue
        if child.tag=='stack':
            im=flatten(child,archive,size); xy=(0,0)
        else:
            im=Image.open(io.BytesIO(archive.read(child.get('src')))).convert('RGBA')
            xy=(int(child.get('x','0')),int(child.get('y','0')))
        opacity=float(child.get('opacity','1'))
        if opacity!=1: im.putalpha(im.getchannel('A').point(lambda a:round(a*opacity)))
        out.alpha_composite(im,xy)
    return out

def export(ora, manifest, target):
    target=Path(target); target.mkdir(parents=True,exist_ok=True)
    manifest=json.loads(Path(manifest).read_text(encoding='utf-8'))
    with zipfile.ZipFile(ora) as archive:
        assert archive.read('mimetype')==b'image/openraster'
        root=ET.fromstring(archive.read('stack.xml'))
        layers={n.get('name'):n for n in root.iter('layer')}
        for asset in manifest['assets']:
            layer=layers[asset['id']]
            p=target/asset['file'];p.parent.mkdir(parents=True,exist_ok=True)
            p.write_bytes(archive.read(layer.get('src')))
        preview=flatten(root.find('stack'),archive,(int(root.get('w')),int(root.get('h'))))
        preview.save(target/'floor_1_reassembled.png')
    return len(manifest['assets'])

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ora',type=Path,default=Path(__file__).with_name('floor_1_layers.ora'))
    parser.add_argument('--manifest',type=Path,default=Path(__file__).parents[2]/'assets/final/floor_1_layers/manifest.json')
    parser.add_argument('--output',required=True,type=Path)
    args=parser.parse_args()
    print('Exported',export(args.ora,args.manifest,args.output),'RGBA PNGs from ORA')
