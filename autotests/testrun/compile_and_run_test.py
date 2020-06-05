import glob
import os
from .base_test import CompilationOutput, Outcome, Test, ValidationOutput
from .firmware_runner import FirmwareRunner
from .project_builder import ProjectBuilder

THIS_DIR = os.path.abspath(os.path.dirname(__file__))


def _compare_output_to_file(output, reference_file_path):
    output_lines = output.splitlines()

    with open(reference_file_path, 'rb') as fp:
        reference_lines = fp.read().splitlines()

    return output_lines == reference_lines


class CompileAndRunTest(Test):
    target = ('dsPIC30F', '30F5016', 'dsPIC30F5016')
    test_dir = None  # subclasses MUST set this to the actual test's directory

    def __init__(self, omf):
        assert self.test_dir is not None
        self.omf = omf

    def compile(self, compilation_env):
        prj = ProjectBuilder(
            compilation_env.compiler_abspath,
            compilation_env.compiler_version,
            self.omf,
            self.target[:2]
        )

        prj.source_files = [
            os.path.join(THIS_DIR, '../../example-project/minilibstdc++.cpp')
        ]

        for c_file in glob.glob1(self.test_dir, '*.c'):
            prj.source_files.append(os.path.join(self.test_dir, c_file))

        for cpp_file in glob.glob1(self.test_dir, '*.cpp'):
            prj.source_files.append(os.path.join(self.test_dir, cpp_file))

        compiler_output = prj.build()
        outcome = Outcome.PASSED if compiler_output.success else Outcome.FAILED
        return CompilationOutput(
            provisional_outcome=outcome,
            files=compiler_output.output_files)

    def validate(self, validation_env, compilation_output):
        fwr = FirmwareRunner(validation_env.mplabx_abspath, self.target[2])
        out = fwr.run(compilation_output.files['firmware.hex'])

        good = _compare_output_to_file(
            out.uart_output,
            os.path.join(self.test_dir, 'expected_output.txt')
        )

        return ValidationOutput(
            final_outcome=Outcome.PASSED if good else Outcome.FAILED,
            files={'uart.txt': out.uart_output})
