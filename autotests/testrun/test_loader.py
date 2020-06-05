import importlib
import itertools
import os

from .call_in_subprocess import call_and_capture_output

# helper variable used during the loading phase by TestLoader
LOADED_TESTS = None


def register_test_with_matrix_generator(gen_func):
    def wrapper(cls):
        if LOADED_TESTS is not None:  # do not run it while unpickling
            for assignment in gen_func():
                LOADED_TESTS.append(cls(**assignment))
        return cls

    return wrapper


def register_test(**matrix):
    def matrix_generator():
        keys = []
        lists_of_values = []
        for key, list_of_values in matrix.items():
            keys.append(key)
            lists_of_values.append(list_of_values)

        for values in itertools.product(*lists_of_values):
            yield dict(zip(keys, values))

    return register_test_with_matrix_generator(matrix_generator)


def error_if_unexpected_working_directory():
    # The working directory must be the root of the test hierarchy, so that
    # relative paths can be trivially converted into package names by replacing
    # slashes with dots
    expected_working_directory = os.path.dirname(os.path.abspath(__file__))
    if os.path.join(os.getcwd(), __package__) != expected_working_directory:
        exit('Working directory must be %s' % expected_working_directory)


class TestLoader:
    def __init__(self, test_directory):
        self.test_directory = test_directory

        # Transform test_directory into a package name (sibling of this package)
        test_directory_rel = os.path.relpath(self.test_directory)
        if '.' in test_directory_rel:
            exit('Test directory %s cannot be converted to a package name'
                 % self.test_directory)

        self.package_name = test_directory_rel.replace(os.pathsep, '.')

        load_test_output = call_and_capture_output(self._load_tests)
        if load_test_output.exception is None:
            self.loaded_tests = load_test_output.result
        else:
            raise RuntimeError('Failed to load tests from test directory %s'
                               % test_directory) from load_test_output.exception

    def _load_tests(self):
        global LOADED_TESTS

        # Import the target module
        LOADED_TESTS = []
        importlib.import_module('%s.testdef' % self.package_name)

        # Since every TestLoader instance imports its test module is a dedicated
        # subprocess, we can safely assume that only the loaded module's tests
        # are listed in this global variable
        return LOADED_TESTS
