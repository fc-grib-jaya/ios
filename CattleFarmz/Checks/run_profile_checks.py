from pathlib import Path
import subprocess, tempfile
root = Path(__file__).resolve().parents[1] / 'CattleFarmz/Modules/Scanning'
files = ['Model/LandmarkRevision.swift','Model/ScanGeometry.swift','Model/MeasurementResult.swift','Model/ChestDepthProfile.swift','Service/MeasurementEngine.swift','Service/ProfileAnalysis.swift']
with tempfile.TemporaryDirectory(prefix='sapi-checks-') as folder:
    source = Path(folder)/'main.swift'
    source.write_text('\n'.join((root/p).read_text() for p in files)+'\n'+Path(__file__).with_name('profile_checks.swift').read_text())
    subprocess.run(['swift','-module-cache-path','/tmp/sapimeasure-module-cache',str(source)],check=True)
