import json
import os
import subprocess
import sys

def command(*args):
    return subprocess.check_output(args, text=True).strip()

result = {
    'packaging_repository': 'https://github.com/rdkit-rs/rdkit-debian',
    'packaging_commit': os.environ['packaging_commit'],
    'upstream_tag': os.environ['RDKIT_TAG'],
    'upstream_commit': os.environ['RDKIT_COMMIT'],
    'upstream_archive_sha256': os.environ['RDKIT_SHA256'],
    'source_version': os.environ['SOURCE_VERSION'],
    'repacked_archive_sha256': os.environ['SOURCE_SHA256'],
    'excluded_source_files': ['Data/Fonts/Amadeus.ttf'],
    'container_image': os.environ['UBUNTU_IMAGE'],
    'architecture': command('dpkg', '--print-architecture'),
    'version': command('dpkg-parsechangelog', '-SVersion'),
    'gcc': command('g++', '-dumpfullversion'),
    'cmake': command('cmake', '--version').splitlines()[0],
    'workflow_url': os.environ.get('WORKFLOW_URL'),
    'byte_reproducibility': 'Not measured; apt dependencies are recorded but not snapshot-pinned.',
}
with open(sys.argv[1], 'w') as handle:
    json.dump(result, handle, indent=2)
    handle.write('\n')
