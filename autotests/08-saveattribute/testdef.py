import os
from testrun import *


@register_test(omf=['elf', 'coff'])
class MyTest(CompileAndRunTest):
    test_dir = os.path.abspath(os.path.dirname(__file__))

    def compile(self, compilation_env):
        # The tested attribute seems to be broken in the C compiler too
        return CompilationOutput(Outcome.SKIPPED, dict())
