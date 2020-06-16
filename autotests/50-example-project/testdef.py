import os
import shutil
import subprocess
import sys
import tempfile
from testrun import *

THIS_DIR = os.path.abspath(os.path.dirname(__file__))


@register_test()
class MyTest(Test):
    def compile(self, compilation_env):
        # Run this test only in Linux test-compile container (because it's the
        # only one with a native make available)
        if compilation_env.compiler_abspath != \
                '/opt/microchip/xc16/%s' % compilation_env.compiler_version:
            return CompilationOutput(
                Outcome.SKIPPED,
                dict())

        with tempfile.TemporaryDirectory() as tmpdir:
            # Copy example project to temporary directory
            build_dir = shutil.copytree(
                os.path.join(THIS_DIR, '../../example-project'),
                os.path.join(tmpdir, 'build-dir'))

            # Generate Makefile
            cmd_line = \
                [
                    './Makefile-generator.sh',
                    str(compilation_env.compiler_version),
                    'linux'
                ]

            print('+', *cmd_line, file=sys.stderr)
            with open(os.path.join(build_dir, 'Makefile'), 'wb') as fp:
                subprocess.check_call(cmd_line, cwd=build_dir, stdout=fp)

            print('+ make', file=sys.stderr)
            subprocess.check_call(['make'], cwd=build_dir)

            files = dict()
            for name in os.listdir(build_dir):
                with open(os.path.join(build_dir, name), 'rb') as fp:
                    files[name] = fp.read()

            return CompilationOutput(
                Outcome.PASSED if 'result.hex' in files else Outcome.FAILED,
                files)

    def validate(self, validation_env, compilation_output):
        return ValidationOutput(
            final_outcome=compilation_output.outcome,
            files=dict())
