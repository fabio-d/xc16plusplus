import os
import tempfile
from testrun import *

THIS_DIR = os.path.abspath(os.path.dirname(__file__))

EXPECTED_SYMBOLS = {
    'disabled_smartio.o': '_printf',
    'arg_none.o': '_puts',
    'arg_char.o': '__printf_cdnopuxX',
    'arg_string.o': '__printf_s',
    'arg_int.o': '__printf_cdnopuxX',
    'arg_float.o': '__printf_fF',
    'arg_float_and_string.o': '__printf_fFs',
    'arg_longlong.o': '__printf_cdnopuxXL'
}


@register_test(omf=['elf', 'coff'])
class MyTest(Test):
    def __init__(self, omf):
        self.omf = omf

    def _list_used_printf_symbols(self, compilation_env, object_file_name):
        imported_symbols = list_undefined_symbols(
            compilation_env.compiler_abspath,
            self.omf,
            object_file_name
        )

        # Filter only printf-related ones
        printf_symbols = []
        for s in imported_symbols:
            if s == '_puts' or 'printf' in s:
                printf_symbols.append(s)

        return printf_symbols

    def compile(self, compilation_env):
        prj = ProjectBuilder(
            compilation_env.compiler_abspath,
            compilation_env.compiler_version,
            self.omf,
            ('dsPIC30F', '30F5016')
        )

        source_files_default_opts = [
            os.path.join(THIS_DIR, '../../example-project/minilibstdc++.cpp'),
            os.path.join(THIS_DIR, 'arg_none.cpp'),
            os.path.join(THIS_DIR, 'arg_char.cpp'),
            os.path.join(THIS_DIR, 'arg_string.cpp'),
            os.path.join(THIS_DIR, 'arg_int.cpp'),
            os.path.join(THIS_DIR, 'arg_float.cpp'),
            os.path.join(THIS_DIR, 'arg_float_and_string.cpp'),
            os.path.join(THIS_DIR, 'main.cpp')
        ]

        # The L modifier is only supported since v1.30
        if compilation_env.compiler_version >= (1, 30):
            with_longlong = True
            source_files_default_opts.append(
                os.path.join(THIS_DIR, 'arg_longlong.cpp'))
        else:
            with_longlong = False

        # Compile all files with standard flags, except for disabled_smartio.cpp
        prj.source_files = {fn: [] for fn in source_files_default_opts}
        prj.source_files[os.path.join(THIS_DIR, 'disabled_smartio.cpp')] \
            = ['-msmart-io=0']  # disable smart I/O for this file

        compiler_output = prj.build()
        if compiler_output.success:
            files_to_be_checked = \
                set(EXPECTED_SYMBOLS) & set(compiler_output.output_files)

            # Extract object files
            with tempfile.TemporaryDirectory() as tmpdir:
                for file_name in files_to_be_checked:
                    with open(os.path.join(tmpdir, file_name), 'wb') as fp:
                        fp.write(compiler_output.output_files[file_name])

                printf_symbols = {
                    file_name: self._list_used_printf_symbols(
                        compilation_env, os.path.join(tmpdir, file_name))
                    for file_name in files_to_be_checked
                }

            as_expected = True
            for file_name in printf_symbols:
                if printf_symbols[file_name] != [EXPECTED_SYMBOLS[file_name]]:
                    print('Expected symbol mismatch!', file_name)
                    as_expected = False

            return CompilationOutput(
                Outcome.PASSED if as_expected else Outcome.FAILED,
                compiler_output.output_files,
                printf_symbols=printf_symbols,
                with_longlong=with_longlong
            )

        return CompilationOutput(
            Outcome.FAILED,
            compiler_output.output_files)

    def validate(self, validation_env, compilation_output):
        fwr = FirmwareRunner(validation_env.mplabx_abspath, 'dsPIC30F5016')
        out = fwr.run(compilation_output.files['firmware.hex'])

        if compilation_output.with_longlong:
            ref_file = 'expected_output-with-longlong.txt'
        else:
            ref_file = 'expected_output-without-longlong.txt'

        good = compare_bytes_to_text_file(
            out.uart_output,
            os.path.join(THIS_DIR, ref_file)
        )

        return ValidationOutput(
            final_outcome=Outcome.PASSED if good else Outcome.FAILED,
            files={'uart.txt': out.uart_output})

