import copy
import os
import pickle
import urllib.parse
import zipfile

from .base_test import CompilationOutput, Test


class BundleRecord:
    """
    Store a Test and its outcome.

    :param test_instance: Test to be stored.
    :type test_instance: Test
    :param test_package_name: Name of the package that defined the test.
    :type test_package_name: str
    :param compilation_result: Result of the test's compilation phase.
    :type compilation_result: CompilationOutput
    :param output_log: Combined stdout+stderr output of the compilation
                       phase.
    :type output_log: bytes
    """

    def __init__(self, test_instance, test_package_name,
                 compilation_result, output_log):
        self.test_instance = test_instance
        self.test_package_name = test_package_name
        self.compilation_result = compilation_result
        self.output_log = output_log


class BundleWriter:
    """
    This class offers high-level methods to write a "bundle file" (i.e. a ZIP
    file containing to output of the compilation phase of a set of tests).

    :param path: Path of the output ZIP file
    :type path: str
    """

    def __init__(self, path):
        self.path = path
        self.zip_handle = None
        self.counter = 0

    def __enter__(self):
        self.zip_handle = zipfile.ZipFile(self.path, mode='w',
                                          compression=zipfile.ZIP_DEFLATED)
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.zip_handle.close()
        if exc_type is not None:  # unclean exit, delete output file
            os.unlink(self.path)

    def add_record(self, bundle_record):
        """
        Store a Test and its outcome.

        :param bundle_record: Data about the Test to be stored.
        :type bundle_record: BundleRecord
        """
        test_instance = bundle_record.test_instance
        test_package_name = bundle_record.test_package_name

        # Create a human-readable unique folder name
        self.counter += 1
        test_repr_encoded = urllib.parse.quote(repr(test_instance),
                                               safe="=()[]{}' ,")
        base_folder = '%08d,%s,%s' \
                      % (self.counter, test_package_name, test_repr_encoded)

        # Create a copy of compilation_result, but without the files' contents,
        # that will be stored as "native" ZIP files in the files/ subdirectory.
        # The 'files' field is overwritten with the list of the file names.
        compilation_result = copy.copy(bundle_record.compilation_result)
        compilation_result.files = list(bundle_record.compilation_result.files)

        # Store files in the files/ subdirectory
        for name, contents in bundle_record.compilation_result.files.items():
            self.zip_handle.writestr('%s/files/%s' % (base_folder, name),
                                     contents)

        # Store stdout/stderr log
        self.zip_handle.writestr('%s/output.txt' % base_folder,
                                 bundle_record.output_log)

        # Store metadata
        with self.zip_handle.open('%s/metadata.pickle' % base_folder, 'w') \
                as metadata_fp:
            metadata = test_instance, test_package_name, compilation_result
            pickle.dump(metadata, metadata_fp, protocol=3)  # python 3.0


class BundleReader:
    """
    This class offers an high-level method to read a "bundle file" (i.e. a ZIP
    file containing to output of the compilation phase of a set of tests).

    This class is an iterable. Each element is a tuple of the same

    :param path: Path of the input ZIP file
    :type path: str
    """

    def __init__(self, path):
        self.path = path
        self.zip_handle = None
        self._top_level_directories = None

    def __enter__(self):
        self.zip_handle = zipfile.ZipFile(self.path, mode='r')

        top_level_directories_set = set()
        for name in self.zip_handle.namelist():
            top_level_directories_set.add(name.partition('/')[0])
        self._top_level_directories = sorted(top_level_directories_set)

        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.zip_handle.close()

    def __getitem__(self, index):
        base_folder = self._top_level_directories[index]

        # Read metadata
        with self.zip_handle.open('%s/metadata.pickle' % base_folder, 'r') \
                as metadata_fp:
            metadata = pickle.load(metadata_fp)
        test_instance, test_package_name, compilation_result = metadata

        # Read stdout/stderr log
        output_log = self.zip_handle.read('%s/output.txt' % base_folder)

        # Load files from files/ directory
        real_files = dict()
        for name in compilation_result.files:
            real_files[name] = self.zip_handle.read('%s/files/%s'
                                                    % (base_folder, name))
        compilation_result.files = real_files

        return BundleRecord(
            test_instance, test_package_name,
            compilation_result, output_log)
