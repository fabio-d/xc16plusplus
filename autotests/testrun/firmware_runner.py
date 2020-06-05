import glob
import os
import subprocess
import sys
import tempfile


class FirmwareRunner:
    """
    Wrapper of MPLAB X's built-it simulator.
    """

    def __init__(self, mplabx_abspath, target):
        """
        Create a FirmwareRunner instance.

        :param mplabx_abspath: Absolute path of the compiler installation
                               directory (e.g. '/opt/microchip/mplabx/v5.30').
        :param target: The chip to be emulated.
        """
        self.device = target

        # Locate MPLAB X's built-in java executable
        self.java_exec, = glob.glob(os.path.join(mplabx_abspath,
                                                 'sys/java/**/bin/java'),
                                    recursive=True)

        # Locate the mdb jar file
        self.mdb_jar = os.path.join(mplabx_abspath,
                                    'mplab_platform/lib/mdb.jar')

    def run(self, hex_file_payload: bytes):
        with tempfile.TemporaryDirectory() as tmp_dir:
            script_file = os.path.join(tmp_dir, 'script.txt')
            hex_file = os.path.join(tmp_dir, 'firmware.hex')
            uart_file = os.path.join(tmp_dir, 'uart.txt')

            with open(hex_file, 'wb') as fp:
                fp.write(hex_file_payload)

            with open(script_file, 'wt') as fp:
                print('device', self.device, file=fp)
                print('set uart1io.uartioenabled true', file=fp)
                print('set uart1io.outputfile uart.txt', file=fp)
                print('set uart1io.output file', file=fp)
                print('hwtool sim -p', file=fp)
                print('program firmware.hex', file=fp)
                print('run', file=fp)
                print('wait 4000', file=fp)
                print('halt', file=fp)
                print('quit', file=fp)

            env = dict(os.environ)
            if 'DISPLAY' in env:
                del env['DISPLAY']

            cmd_line = [
                self.java_exec,
                '-Dpackslib.workonline=false',  # disable update checks
                '-Dfile.encoding=UTF-8',
                '-Djava.awt.headless=true',
                '-jar', self.mdb_jar,
                'script.txt'
            ]

            print('+', *cmd_line, file=sys.stderr)

            subprocess.call(cmd_line, env=env, cwd=tmp_dir,
                            stdout=sys.stderr, stderr=sys.stderr)

            with open(uart_file, 'rb') as fp:
                uart_output = fp.read()

        return FirmwareRunnerResult(uart_output)


class FirmwareRunnerResult:
    def __init__(self, uart_output: bytes):
        self.uart_output = uart_output
