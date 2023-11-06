from abc import ABC, abstractmethod
from enum import Enum
from typing import Any, Dict

from .compiler_version import CompilerVersion


class Outcome(Enum):
    PASSED = "PASSED"
    FAILED = "FAILED"
    SKIPPED = "SKIPPED"
    UNSUPPORTED = "UNSUPPORTED"


class Test(ABC):
    """
    All tests inherit from this abstract base class.
    """

    # This method intercepts arguments to the subclass' constructor and saves a
    # copy of them for our __repr__ implementation
    def __new__(cls, **kwargs):
        instance = super(Test, cls).__new__(cls)
        instance.__kwargs = kwargs
        return instance

    def __repr__(self):
        formatted_kwargs = ['%s=%r' % (k, v) for k, v in self.__kwargs.items()]
        return '%s(%s)' % (type(self).__name__, ', '.join(formatted_kwargs))

    @abstractmethod
    def compile(self, compilation_env):
        """
        Execute the compilation phase of the present test.

        :param compilation_env: Data about the test compilation environment.
        :type compilation_env: CompilationEnvironment
        :return: Output file contents and variables, that can be consumed by the
                 subsequent validation phase and/or dumped for debugging.
        :rtype: CompilationOutput
        """
        pass

    @abstractmethod
    def validate(self, validation_env, compilation_output):
        """
        Execute the validation phase of the present test.

        :param validation_env: Data about the test validation environment.
        :type validation_env: ValidationEnvironment
        :param compilation_output: Output of the previous phase.
        :type compilation_output: CompilationOutput
        :return: Output files and variables, that can be dumped for debugging.
        :rtype: ValidationOutput
        """
        pass


class CompilationEnvironment:
    """
    Class describing the test compilation environment.

    :param compiler_version: The version number of the compiler under test.
    :type compiler_version: CompilerVersion
    :param compiler_abspath: Absolute path of the compiler installation
                             directory (i.e. the one that contains the 'bin',
                             'include' and 'lib' subdirectories).
    :type compiler_abspath: str
    """

    def __init__(self, compiler_version, compiler_abspath):
        self.compiler_version = compiler_version
        self.compiler_abspath = compiler_abspath


class CompilationOutput:
    """
    Structured container for the output of the compilation phase.

    :param provisional_outcome: Outcome of this phase. If set to PASSED, the
                                validation phase will be executed (and a new,
                                final, outcome will be produced by the
                                validation phase). If different than PASSED, the
                                validation phase will not be executed at all.
    :type provisional_outcome: Outcome
    :param files: A dictionary, with file names as keys and content as values.
    :type files: Dict[str, bytes]
    :param kwvars: Test-specific variables that will be included in the
                   report and/or propagated to the validation phase.
    :type kwvars: Any
    """

    def __init__(self, provisional_outcome, files, **kwvars):
        self.outcome = provisional_outcome
        self.files = files
        self.__kwvars = kwvars

    def __getstate__(self):
        return self.outcome, self.files, self.__kwvars

    def __setstate__(self, s):
        self.outcome, self.files, self.__kwvars = s

    def __getattr__(self, item):
        if item in self.__kwvars:
            return self.__kwvars[item]
        raise AttributeError('Keyword-variable %r not found' % item)


class ValidationEnvironment:
    """
    Class describing the test validation environment.

    :param mplabx_abspath: Absolute path of the MPLABX IDE installation
                             directory (i.e. the one that contains the
                             'mplab_platform' and 'sys' subdirectories).
    :type mplabx_abspath: str
    """

    def __init__(self, mplabx_abspath):
        self.mplabx_abspath = mplabx_abspath


class ValidationOutput:
    """
    Structured container for the output of the validation phase.

    :param provisional_outcome: Final test outcome.
    :type provisional_outcome: Outcome
    :param files: A dictionary, with file names as keys and content as values.
    :type files: Dict[str, bytes]
    :param kwvars: Test-specific variables that will be included in the
                   report.
    :type kwvars: Any
    """

    def __init__(self, final_outcome, files, **kwvars):
        self.outcome = final_outcome
        self.files = files
        self.__kwvars = kwvars
