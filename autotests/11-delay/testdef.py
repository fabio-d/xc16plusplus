import os
from testrun import *


@register_test(omf=['elf', 'coff'])
class MyTest(CompileAndRunTest):
    test_dir = os.path.abspath(os.path.dirname(__file__))
