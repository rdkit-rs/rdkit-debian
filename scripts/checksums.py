import hashlib
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
lines = []
for path in sorted(root.iterdir()):
    if path.is_file() and path.name != 'SHA256SUMS':
        lines.append(f'{hashlib.file_digest(path.open("rb"), "sha256").hexdigest()}  {path.name}\n')
(root / 'SHA256SUMS').write_text(''.join(lines))
