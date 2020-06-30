import os
import re
from testrun import *

THIS_DIR = os.path.abspath(os.path.dirname(__file__))
GLD_RE = re.compile('p(.*)\\.gld')

SKIPLIST = {
    (1, 10): [
        # CPU not recognized
        '24EP64GP203'
    ],
    (1, 20): [
        # CPU not recognized
        '24FJ64GB502'
    ],
    (1, 21): [
        # CPU not recognized
        '24FJ64GB502'
    ],
    (1, 22): [
        # CPU not recognized
        '33EP32GS202',

        # Undefined symbol `__reset'
        '33EP16GS502',
        '33EP16GS504',
        '33EP16GS506',
        '33EP32GS502',
        '33EP32GS504',
        '33EP32GS506',
    ]
}


def _matrix_generator_family(target_family, family_dir):
    for gld_file in os.listdir(os.path.join(family_dir, 'gld')):
        m = GLD_RE.fullmatch(gld_file)
        chip = m.group(1)

        yield {
            'target_family': target_family,
            'target_chip': chip,
            'omf': 'elf'
        }

        yield {
            'target_family': target_family,
            'target_chip': chip,
            'omf': 'coff'
        }


def _matrix_generator(compilation_env):
    support_dir = os.path.join(compilation_env.compiler_abspath, 'support')
    for target_family in os.listdir(support_dir):
        if target_family.startswith('PIC') or target_family.startswith('dsPIC'):
            family_dir = os.path.join(support_dir, target_family)
            yield from _matrix_generator_family(target_family, family_dir)


@register_test_with_matrix_generator(_matrix_generator)
class MyTest(CompileOnlyTest):
    test_dir = THIS_DIR

    def __init__(self, target_family, target_chip, omf):
        self.target = (target_family, target_chip)
        super().__init__(omf)

    def compile(self, compilation_env):
        ver_major, ver_minor = compilation_env.compiler_version
        if self.target[1] in SKIPLIST.get((ver_major, ver_minor), []):
            return CompilationOutput(Outcome.SKIPPED, dict())

        return super().compile(compilation_env)
