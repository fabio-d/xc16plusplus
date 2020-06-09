import os
import re
import subprocess
import sys


def compare_bytes_to_text_file(output, reference_file_path):
    output_lines = output.splitlines()

    with open(reference_file_path, 'rb') as fp:
        reference_lines = fp.read().splitlines()

    return output_lines == reference_lines


def list_undefined_symbols(compiler_abspath, omf, object_file_path):
    cmd_line = [
        os.path.join(compiler_abspath, 'bin/xc16-nm'),
        '-omf=' + omf, '-u',
        object_file_path
    ]

    result = []
    print('+', *cmd_line, file=sys.stderr)
    with subprocess.Popen(
            cmd_line,
            universal_newlines=True,
            stdout=subprocess.PIPE) as proc:
        for line in proc.stdout:
            line = line.rstrip()
            print(line, file=sys.stderr)

            m = re.match(r' *U (.*)', line)
            assert m is not None
            result.append(m.group(1))

    return result
