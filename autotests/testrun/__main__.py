import argparse
import os
import re
import shutil
import sys
from functools import partial
from typing import Generator, List, Tuple

from .base_test import CompilationEnvironment, CompilationOutput, \
    ValidationEnvironment, ValidationOutput, Outcome, Test
from .bundle_io import BundleReader, BundleRecord, BundleWriter
from .call_in_subprocess import call_and_capture_output
from .compiler_version import CompilerVersion
from .firmware_runner import FirmwareRunner
from .project_builder import ProjectBuilder
from .report_writer import ReportWriter
from .test_loader import TestLoader, error_if_unexpected_working_directory


def load_test_directories(test_directories):
    """
    Load test definitions from a list of directories.

    :param test_directories: List of directory paths (both relative and absolute
                             paths are accepted, provided they lead to a
                             subdirectory of the root of the test hierarchy
                             (i.e. the 'autotests' directory).
    :type test_directories: List[str]
    :return: (test_instance, test_package_name) tuples
    :rtype: Generator[Tuple[Test, str]]
    """
    if len(test_directories) == 0:
        # If no directories are specified, automatically add all tests
        test_directories = sorted([root for root, dirs, files in os.walk('.')
                                   if 'testdef.py' in files])

    seen_package_names = set()
    for test_directory in test_directories:
        # Load tests from current test_directory
        test_loader = TestLoader(test_directory)

        if test_loader.package_name in seen_package_names:
            print('Warning!', test_loader.package_name,
                  'listed more than once. Skipping repeated occurrence',
                  file=sys.stderr)
            continue
        else:
            seen_package_names.add(test_loader.package_name)

        print('Loaded', len(test_loader.loaded_tests), 'test(s) from',
              test_loader.package_name, file=sys.stderr)

        for test_instance in test_loader.loaded_tests:
            yield test_instance, test_loader.package_name


def make_compilation_env(compiler_path):
    # Extract compiler version for its path
    compiler_version_match = re.search(r'^(|.*[\\/])(v[0-9]+\.[0-9]+)[\\/]*',
                                       compiler_path)
    if compiler_version_match is None:
        exit('Failed to infer compiler version for compiler_path')

    # Create CompilationEnvironment object
    return CompilationEnvironment(
        compiler_version=CompilerVersion(compiler_version_match.group(2)),
        compiler_abspath=os.path.abspath(compiler_path)
    )


def do_compile(args):
    # Create CompilationEnvironment object
    compilation_env = make_compilation_env(args.compiler_path)

    # Execute each Test's compilation step and store the outcome in the output
    # bundle
    with BundleWriter(args.output) as bw:
        for test_instance, test_package_name \
                in load_test_directories(args.test_directory):
            print('Compiling test', test_instance, 'defined in',
                  test_package_name, file=sys.stderr)

            # Run test's compilation phase
            compile_result = call_and_capture_output(
                partial(test_instance.compile, compilation_env))

            if compile_result.exception is None:
                compilation_output = compile_result.result
            else:
                compilation_output = CompilationOutput(Outcome.FAILED, dict())

            outcome_text = 'COMPILED' \
                if compilation_output.outcome == Outcome.PASSED \
                else compilation_output.outcome.value

            print('Compiling test', test_instance, 'defined in',
                  test_package_name, '->', outcome_text, file=sys.stderr)

            # Store the test and its outcome in the output bundle
            bw.add_record(BundleRecord(
                test_instance, test_package_name,
                compilation_output, compile_result.output))


def do_validate(args):
    mplabx_abspath = os.path.abspath(args.mplabx_path)

    # Create ValidationEnvironment object
    validation_env = ValidationEnvironment(
        mplabx_abspath=mplabx_abspath
    )

    report = ReportWriter(args.output)

    all_loaded_tests = []
    for input_bundle_path in args.input:
        with BundleReader(input_bundle_path) as br:
            report.start_input_file(os.path.basename(input_bundle_path))

            for x in br:
                print('Validating test', x.test_instance, 'defined in',
                      x.test_package_name, 'and loaded from', input_bundle_path,
                      file=sys.stderr)

                if x.compilation_result.outcome == Outcome.PASSED:
                    test_instance = x.test_instance

                    # Run test's validation phase
                    validate_result = call_and_capture_output(
                        partial(test_instance.validate,
                                validation_env, x.compilation_result))

                    if validate_result.exception is None:
                        validation_output = validate_result.result
                    else:
                        validation_output = ValidationOutput(
                            Outcome.FAILED, dict())

                    validation_log = validate_result.output
                else:
                    validation_output = ValidationOutput(
                        x.compilation_result.outcome, dict())
                    validation_log = b''

                print('Validating test', x.test_instance, 'defined in',
                      x.test_package_name, 'and loaded from', input_bundle_path,
                      '->', validation_output.outcome.value,
                      file=sys.stderr)

                report.write_test_outcome(x.test_instance, x.test_package_name,
                                          validation_output, validation_log)

            report.end_input_file()

    report.end_report()

    if report.has_failed_tests():
        sys.exit('One or more tests FAILED')


def do_compilefw(args):
    # Create CompilationEnvironment object
    compilation_env = make_compilation_env(args.compiler_path)

    # Create ProjectBuilder object
    project = ProjectBuilder(
        compilation_env.compiler_abspath,
        compilation_env.compiler_version,
        args.omf,
        (args.target_family, args.target_chip)
    )

    project.source_files = {
        os.path.abspath(
            os.path.join(os.path.dirname(__file__),
                         '../../example-project/minilibstdc++.cpp')): []
    }

    for fn in os.listdir(args.srcdir):
        if fn.endswith('.c') or fn.endswith('.cpp'):
            full_path = os.path.abspath(os.path.join(args.srcdir, fn))
            project.source_files[full_path] = []

    output = project.build()
    target_dir = os.path.join(args.srcdir, 'compilefw-output')
    if os.path.isdir(target_dir):
        shutil.rmtree(target_dir)
    os.mkdir(target_dir)
    for fn, contents in output.output_files.items():
        with open(os.path.join(target_dir, fn), 'wb') as fp:
            fp.write(contents)

    if not output.success:
        sys.exit('Compilation failed')


def do_runfw(args):
    mplabx_abspath = os.path.abspath(args.mplabx_path)
    with open(args.firmware, 'rb') as fp:
        hex_file_payload = fp.read()

    fwr = FirmwareRunner(mplabx_abspath, args.target)
    result = fwr.run(hex_file_payload)

    print('UART output:')
    sys.stdout.buffer.write(result.uart_output)


def main():
    parser = argparse.ArgumentParser(description='XC16++ test runner')
    subparsers = parser.add_subparsers(metavar='COMMAND',
                                       help='select sub-command')

    # parser for 'compile' command
    parser_compile = subparsers.add_parser('compile',
                                           help='run compilation step (1st '
                                                'phase)')
    parser_compile.add_argument('compiler_path',
                                help='path to compiler installation directory, '
                                     'such as /opt/microchip/v1.00')
    parser_compile.add_argument('test_directory', nargs='*',
                                help='path to directories containing the test '
                                     'to be executed')
    parser_compile.add_argument('-o', '--output', metavar='OUTPUT_BUNDLE.zip',
                                help='output file, which can then be fed to '
                                     'the validation phase', required=True)
    parser_compile.set_defaults(func=do_compile)

    # parser for 'validate' command
    parser_validate = subparsers.add_parser('validate',
                                            help='run validation step (2nd '
                                                 'phase)')
    parser_validate.add_argument('mplabx_path',
                                 help='path to MPLAB X installation directory, '
                                      'such as /opt/microchip/mplabx/v5.30')
    parser_validate.add_argument('input', nargs='+', metavar='INPUT_BUNDLE.zip',
                                 help='one or more output files produced by '
                                      'the compile sub-command')
    parser_validate.add_argument('-o', '--output', metavar='OUTPUT_REPORT.zip',
                                 help='output report file', required=True)
    parser_validate.set_defaults(func=do_validate)

    # parser for 'compilefw' command
    parser_compilefw = subparsers.add_parser('compilefw',
                                             help='compile firmware')
    parser_compilefw.add_argument('compiler_path',
                                  help='path to compiler installation '
                                       'directory, such as '
                                       '/opt/microchip/v1.00')
    parser_compilefw.add_argument('target_family',
                                  help='name of the target family')
    parser_compilefw.add_argument('target_chip',
                                  help='name of the target chip')
    parser_compilefw.add_argument('omf', choices=('coff', 'elf'),
                                  help='Objetc file format')
    parser_compilefw.add_argument('srcdir',
                                  help='Source and output directory')
    parser_compilefw.set_defaults(func=do_compilefw)

    # parser for 'runfw' command
    parser_runfw = subparsers.add_parser('runfw',
                                         help='run firmware with UART output')
    parser_runfw.add_argument('mplabx_path',
                              help='path to MPLAB X installation directory, '
                                   'such as /opt/microchip/mplabx/v5.30')
    parser_runfw.add_argument('target',
                              help='name of chip to be emulated')
    parser_runfw.add_argument('firmware', metavar='FIRMWARE.hex',
                              help='HEX image of firmware')
    parser_runfw.set_defaults(func=do_runfw)

    args = parser.parse_args()

    error_if_unexpected_working_directory()
    if 'func' not in args:
        parser.error('COMMAND required')
    else:
        args.func(args)


main()
