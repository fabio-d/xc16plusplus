import os
from testrun import *


@register_test(omf=['elf', 'coff'])
class MyTest(CompileAndRunTest):
    target = ('dsPIC33E', '33EP512GP502', 'dsPIC33EP512GP502')
    test_dir = os.path.abspath(os.path.dirname(__file__))
