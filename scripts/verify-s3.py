import hashlib
import pathlib
import sys
import urllib.parse
import urllib.request

base = 'https://rdkit-rs-debian.s3.eu-central-1.amazonaws.com/'
assets = pathlib.Path(sys.argv[1])
for architecture in sys.argv[2:] or ('amd64', 'arm64'):
    url = f'{base}dists/resolute/main/binary-{architecture}/Packages'
    index = urllib.request.urlopen(url).read().decode()
    records = {}
    for paragraph in index.strip().split('\n\n'):
        fields = dict(line.split(': ', 1) for line in paragraph.splitlines() if ': ' in line and not line.startswith(' '))
        if fields.get('Version') == '2026.09.1+ds1-1~ubuntu26.04':
            records[fields['Package']] = fields
    for name in ('librdkit-rs202609', 'librdkit-rs-dev', 'rdkit-rs-data'):
        fields = records[name]
        expected_arch = 'all' if name == 'rdkit-rs-data' else architecture
        assert fields['Architecture'] == expected_arch
        filename = fields['Filename']
        assert filename.startswith('pool/') and '..' not in filename
        download_url = base + urllib.parse.quote(filename, safe='/')
        with urllib.request.urlopen(download_url) as response:
            digest = hashlib.file_digest(response, 'sha256').hexdigest()
        assert digest == fields['SHA256']
        with (assets / pathlib.PurePosixPath(filename).name).open('rb') as handle:
            assert digest == hashlib.file_digest(handle, 'sha256').hexdigest()
        print(name, fields['Version'], expected_arch, digest, download_url)
