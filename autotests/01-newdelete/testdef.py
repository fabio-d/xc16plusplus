import os
from testrun import *


@register_test(omf=['elf', 'coff'])
class MyTest(CompileAndRunTest):
    test_dir = os.path.abspath(os.path.dirname(__file__))

    def compile(self, compilation_env):
        # Heap allocation produces invalid memory accesses in the C library (see
        # XC16-1943)
        if (2, 0) <= compilation_env.compiler_version < (2, 10):
            return CompilationOutput(Outcome.SKIPPED, dict())

        return super().compile(compilation_env)
