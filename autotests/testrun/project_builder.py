import os
import subprocess
import tempfile
import sys


class ProjectBuilder:
    """
    A "project" that can be compiled.
    """

    def __init__(self, compiler_abspath, compiler_version, omf, target):
        """
        Create a Project instance.

        :param compiler_abspath: Absolute path of the compiler installation
                                 directory (e.g. '/opt/microchip/xc16/v1.00').
        :param compiler_version: Compiler version as a CompilerVersion instance.
        :param omf: Either 'coff' or 'elf'.
        :param target: A (family, chip) tuple.
        """
        target_family, target_chip = target
        self.omf = omf
        self.c_exec = os.path.join(compiler_abspath, 'bin/xc16-gcc')
        self.cxx_exec = os.path.join(compiler_abspath, 'bin/xc16-g++')
        self.ld_exec = os.path.join(compiler_abspath, 'bin/xc16-ld')
        self.bin2hex_exec = os.path.join(compiler_abspath, 'bin/xc16-bin2hex')

        self.cflags = [
            '-omf=' + omf,
            '-mcpu=' + target_chip
        ]

        ldscript = os.path.join(
            compiler_abspath,
            'support',
            target_family,
            'gld',
            'p%s.gld' % target_chip)
        self.ldflags = [
            '-omf=' + omf,
            '-p' + target_chip,
            '--report-mem',
            '--script', ldscript,
            '--heap=512',
            '-L' + os.path.join(compiler_abspath, 'lib'),
            '-L' + os.path.join(compiler_abspath, 'lib', target_family)
        ]
        self.libs = [
            '-lc',
            '-lpic30',
            '-lm'
        ]

        if compiler_version >= (1, 20):
            self.cflags.append('-mno-eds-warn')
            self.ldflags.append('--local-stack')

        if compiler_version >= (1, 25):
            self.cflags.append('-no-legacy-libc')

        self.cxxflags = self.cflags + [
            '-fno-exceptions',
            '-fno-rtti',
            '-D__bool_true_and_false_are_defined',
            '-std=gnu++0x'
        ]

        self.source_files = []

    def build(self):
        with tempfile.TemporaryDirectory() as out_dir:
            object_files = []
            compilation_failed = False

            # Compile source files
            for source_path in self.source_files:
                if source_path.endswith('.c'):
                    compiler_exec = self.c_exec
                    compiler_flags = self.cflags
                    name_without_ext = os.path.basename(source_path[:-2])
                elif source_path.endswith('.cpp'):
                    compiler_exec = self.cxx_exec
                    compiler_flags = self.cxxflags
                    name_without_ext = os.path.basename(source_path[:-4])
                else:
                    raise ValueError('Invalid file extension')

                object_file_name = '%s.o' % name_without_ext
                log_file_name = '%s.log' % name_without_ext

                cmd_line = [
                               compiler_exec,
                               '-c', os.path.abspath(source_path),
                               '-o', object_file_name
                           ] + compiler_flags

                exit_code = ProjectBuilder._run_with_log(cmd_line, out_dir)

                if exit_code == 0 and \
                        os.path.exists(os.path.join(out_dir, object_file_name)):
                    object_files.append(object_file_name)
                else:
                    compilation_failed = True

            if not compilation_failed:
                firmware_gld = 'firmware.gld'
                firmware_obj = 'firmware.%s' % self.omf
                firmware_map = 'firmware.map'

                cmd_line = [self.ld_exec] + self.ldflags + object_files + [
                    '-o', firmware_obj,
                    '--save-gld=' + firmware_gld,
                    '-Map=' + firmware_map
                ] + self.libs

                exit_code = ProjectBuilder._run_with_log(cmd_line, out_dir)

                if exit_code == 0 and \
                        os.path.exists(os.path.join(out_dir, firmware_obj)):
                    object_files.append(object_file_name)
                else:
                    compilation_failed = True

            if not compilation_failed:
                firmware_hex = 'firmware.hex'
                cmd_line = [
                    self.bin2hex_exec,
                    '-omf=' + self.omf,
                    firmware_obj
                ]

                exit_code = ProjectBuilder._run_with_log(cmd_line, out_dir)

                if exit_code != 0 or \
                        not os.path.exists(os.path.join(out_dir, firmware_hex)):
                    compilation_failed = True

            return ProjectBuilderOutput(not compilation_failed, out_dir)

    @staticmethod
    def _run_with_log(cmd_line, working_dir):
        print('+', *cmd_line, file=sys.stderr)
        return subprocess.call(
            cmd_line,
            stdout=sys.stderr, stderr=sys.stderr,
            cwd=working_dir
        )


class ProjectBuilderOutput:
    def __init__(self, success: bool, load_from_dir: str):
        self.success = success

        self.output_files = dict()
        for name in os.listdir(load_from_dir):
            with open(os.path.join(load_from_dir, name), 'rb') as fp:
                self.output_files[name] = fp.read()

    def __str__(self):
        result = 'ProjectBuilderOutput:\n'

        result += '  success: %r\n' % self.success
        result += '  files:\n'
        for name, contents in self.output_files.items():
            result += '    - %s: %d bytes\n' % (name, len(contents))

        return result
