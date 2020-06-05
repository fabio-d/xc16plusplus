import io
import urllib.parse
import zipfile

from .base_test import CompilationOutput, ValidationOutput, Outcome, Test


class ReportWriter:
    def __init__(self, output_path):
        self._zip_handle = zipfile.ZipFile(output_path, 'w',
                                           zipfile.ZIP_DEFLATED)

        self._current_input_filename = None
        self._current_summary_contents = None
        self._current_test_counter = None

        self._passed_tests = []
        self._skipped_tests = []
        self._failed_tests = []

    def end_report(self):
        final_summary = [
            'Passed tests (%d):' % len(self._passed_tests),
            *(' - %s' % v for v in self._passed_tests),
            '',
            'Skipped tests (%d):' % len(self._skipped_tests),
            *(' - %s' % v for v in self._skipped_tests),
            '',
            'Failed tests (%d):' % len(self._failed_tests),
            *(' - %s' % v for v in self._failed_tests)
        ]

        print('TEST SUMMARY:')
        print()
        print('\n'.join(final_summary))

        with self._zip_handle.open('final-summary.txt', 'w') as fp:
            fp.write('\n'.join(final_summary).encode('utf-8'))

        self._zip_handle.close()

    def has_failed_tests(self):
        return len(self._failed_tests) != 0

    def start_input_file(self, input_filename):
        assert self._current_input_filename is None

        self._current_input_filename = input_filename
        self._current_summary_contents = []
        self._current_test_counter = 0

    def end_input_file(self):
        with self._zip_handle.open(
                self._current_input_filename + '/summary.txt', 'w') as fp:
            fp.write('\n'.join(self._current_summary_contents).encode('utf-8'))

        self._current_input_filename = None
        self._current_summary_contents = None
        self._current_test_counter = None

    def write_test_outcome(self, test_instance, test_package_name,
                           validation_output, output_log):
        # Create a human-readable unique test name (which corresponds to the one
        # generated by BundleWriter)
        self._current_test_counter += 1
        test_repr_encoded = urllib.parse.quote(repr(test_instance),
                                               safe="=()[]{}'")
        test_extended_name = \
            '%08d,%s,%s' % \
            (self._current_test_counter, test_package_name, test_repr_encoded)

        base_folder = self._current_input_filename + '/'
        base_folder += test_extended_name

        self._current_summary_contents.append(
            '%s : %s' % (validation_output.outcome.value, test_extended_name)
        )

        # Store files in the files/ subdirectory
        for name, contents in validation_output.files.items():
            self._zip_handle.writestr('%s/files/%s' % (base_folder, name),
                                      contents)

        with self._zip_handle.open(base_folder + '/output.txt', 'w') as fp:
            fp.write(output_log)

        # Prepend input filename in test summary
        test_extended_name = self._current_input_filename + \
            '/' + test_extended_name

        if validation_output.outcome == Outcome.PASSED:
            self._passed_tests.append(test_extended_name)
        elif validation_output.outcome == Outcome.SKIPPED:
            self._skipped_tests.append(test_extended_name)
        else:
            assert validation_output.outcome == Outcome.FAILED
            self._failed_tests.append(test_extended_name)
