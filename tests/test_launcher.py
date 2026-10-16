"""macOS integration checks. Only launch an isolated native test executable."""
import json
import os
import pathlib
import plistlib
import socket
import subprocess
import sys
import tempfile
import time
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
WORKER = ROOT / 'src/launch.zsh'
PROXY_KEYS = (
    'HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY', 'WS_PROXY', 'WSS_PROXY',
    'http_proxy', 'https_proxy', 'all_proxy', 'ws_proxy', 'wss_proxy',
)
NO_PROXY = 'localhost,127.0.0.1,::1,.local,.ts.net,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,100.64.0.0/10'


@unittest.skipUnless(sys.platform == 'darwin', 'macOS only')
class LauncherTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='clash-launcher-test-')
        self.folder = pathlib.Path(self.temp.name)
        self.app = self.folder / 'Proxy Fixture With Spaces.app'
        self.binary = self.app / 'Contents/MacOS/fixture'
        self.binary.parent.mkdir(parents=True)
        with (self.app / 'Contents/Info.plist').open('wb') as f:
            plistlib.dump({'CFBundleExecutable': 'fixture'}, f)
        self.dump = self.folder / 'env.txt'
        c_source = self.folder / 'fixture.c'
        keys = (*PROXY_KEYS, 'NO_PROXY', 'no_proxy', 'NODE_USE_ENV_PROXY')
        code = '#include <stdio.h>\n#include <stdlib.h>\n#include <unistd.h>\nint main(void) {\n'
        code += 'FILE *f=fopen(getenv("FIXTURE_DUMP"), "w"); if(!f) return 2;\n'
        for key in keys:
            code += f'fprintf(f,"{key}=%s\\n", getenv("{key}")?getenv("{key}"):"");\n'
        code += 'fclose(f); sleep(60); return 0; }\n'
        c_source.write_text(code)
        subprocess.run(['/usr/bin/xcrun', 'clang', str(c_source), '-o', str(self.binary)], check=True, capture_output=True)
        self.server = socket.socket()
        self.server.bind(('127.0.0.1', 0))
        self.server.listen(32)
        self.port = self.server.getsockname()[1]
        self.environment = dict(os.environ, FIXTURE_DUMP=str(self.dump))
        for key in (*PROXY_KEYS, 'NO_PROXY', 'no_proxy', 'NODE_USE_ENV_PROXY'):
            self.environment.pop(key, None)
        self.children = []

    def tearDown(self):
        for child in self.children:
            if child.poll() is None:
                child.terminate()
                child.wait(timeout=5)
        # --launch detaches its fixture; only terminate the PID matching our unique path.
        rows = subprocess.check_output(['/bin/ps', '-axo', 'pid=,comm='], text=True)
        for row in rows.splitlines():
            fields = row.strip().split(None, 1)
            if len(fields) == 2 and fields[1] == str(self.binary):
                try:
                    os.kill(int(fields[0]), 15)
                except ProcessLookupError:
                    pass
        self.server.close()
        self.temp.cleanup()

    def call(self, action='--check', port=None, app=None):
        return subprocess.run(['/bin/zsh', str(WORKER), action, str(self.port if port is None else port), str(self.app if app is None else app)], env=self.environment, text=True, capture_output=True, timeout=8)

    def test_port_validation_rejects_shell_text(self):
        for value in ('', '0', '65536', '-1', '1;touch pwn', 'abc', '127.0.0.1:7897'):
            result = self.call('--validate-port', port=value)
            self.assertNotEqual(result.returncode, 0, value)
        for value in ('1', '7897', '65535', '00080'):
            self.assertEqual(self.call('--validate-port', port=value).returncode, 0, value)

    def test_missing_app(self):
        self.assertEqual(self.call(app=self.folder/'Missing.app').stdout.strip(), 'missing-app')

    def test_port_unavailable(self):
        self.server.close()
        self.assertEqual(self.call().stdout.strip(), 'proxy-unavailable')

    def test_running_without_proxy_requires_restart(self):
        child = subprocess.Popen([str(self.binary)], env=self.environment)
        self.children.append(child)
        self.assertEqual(self.call().stdout.strip(), 'needs-restart')
        self.assertIsNone(child.poll(), 'launcher must never terminate the existing app')

    def test_cold_launch_inherits_all_proxy_variables(self):
        result = self.call('--launch')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), 'launched')
        values = dict(line.split('=', 1) for line in self.dump.read_text().splitlines())
        for key in PROXY_KEYS:
            self.assertEqual(values[key], f'http://127.0.0.1:{self.port}')
        self.assertEqual(values['NO_PROXY'], NO_PROXY)
        self.assertEqual(values['no_proxy'], NO_PROXY)
        self.assertEqual(values['NODE_USE_ENV_PROXY'], '1')
        self.assertEqual(self.call().stdout.strip(), 'already-ready')
        self.assertEqual(self.call(port='0').returncode, 64)
        self.assertNotIn('HTTP_PROXY=', result.stdout + result.stderr)

    def test_ready_to_launch(self):
        self.assertEqual(self.call().stdout.strip(), 'ready-to-launch')


if __name__ == '__main__':
    unittest.main(verbosity=2)
