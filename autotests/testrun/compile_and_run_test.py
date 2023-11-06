import glob
import os
from .base_test import CompilationOutput, Outcome, Test, ValidationOutput
from .firmware_runner import FirmwareRunner
from .project_builder import ProjectBuilder
from .utils import compare_bytes_to_text_file

THIS_DIR = os.path.abspath(os.path.dirname(__file__))

# Look-up table: (target_family, target_chip) -> name_used_by_mdb
# Note: Entries can be added here as needed by new tests
_FAMILY_AND_CHIP_TO_MDB_NAME = {
    ('dsPIC30F', '30F5016'): 'dsPIC30F5016',
    ('dsPIC33E', '33EP512GP502'): 'dsPIC33EP512GP502'
}


class _CompileTestMixin:
    target = ('dsPIC30F', '30F5016')
    extra_compiler_options = []
    test_dir = None  # subclasses MUST set this to the actual test's directory

    def __init__(self, omf):
        assert self.test_dir is not None
        assert omf in ('coff', 'elf')
        self.omf = omf

    def compile(self, compilation_env):
        if compilation_env.compiler_version >= (2, 0) and self.omf == 'coff':
            return CompilationOutput(Outcome.UNSUPPORTED, dict())

        prj = ProjectBuilder(
            compilation_env.compiler_abspath,
            compilation_env.compiler_version,
            self.omf,
            self.target
        )

        source_files = [
            os.path.join(THIS_DIR, '../../example-project/minilibstdc++.cpp')
        ]

        for c_file in glob.glob1(self.test_dir, '*.c'):
            source_files.append(os.path.join(self.test_dir, c_file))

        for cpp_file in glob.glob1(self.test_dir, '*.cpp'):
            source_files.append(os.path.join(self.test_dir, cpp_file))

        prj.source_files = {file_name: [] for file_name in source_files}
        prj.cflags += self.extra_compiler_options
        prj.cxxflags += self.extra_compiler_options

        compiler_output = prj.build()
        outcome = Outcome.PASSED if compiler_output.success else Outcome.FAILED
        return CompilationOutput(
            provisional_outcome=outcome,
            files=compiler_output.output_files)


class CompileOnlyTest(_CompileTestMixin, Test):
    def validate(self, validation_env, compilation_output):
        return ValidationOutput(
            final_outcome=compilation_output.outcome,
            files=dict()
        )


class CompileAndRunTest(_CompileTestMixin, Test):
    def validate(self, validation_env, compilation_output):
        target_mdb = _FAMILY_AND_CHIP_TO_MDB_NAME[self.target]
        fwr = FirmwareRunner(validation_env.mplabx_abspath, target_mdb)
        out = fwr.run(compilation_output.files['firmware.hex'])

        good = compare_bytes_to_text_file(
            out.uart_output,
            os.path.join(self.test_dir, 'expected_output.txt')
        )

        return ValidationOutput(
            final_outcome=Outcome.PASSED if good else Outcome.FAILED,
            files={'uart.txt': out.uart_output})
