import re
from functools import total_ordering


@total_ordering
class CompilerVersion:
    """
    Simple container class that represents an XC16 compiler version.
    """

    def __init__(self, version_text):
        """
        Create a CompilerVersion instance.

        :param version_text: A string in 'vX.Y' format (e.g. 'v1.00').
        """
        self._text = version_text

        # Extract major and minor version as numbers
        match = re.fullmatch(r'v([0-9]+)\.([0-9]+)', version_text)
        if match is None:
            raise ValueError('Invalid version_text: %s' % version_text)
        self.major = int(match.group(1))
        self.minor = int(match.group(2))

    def __str__(self):
        """
        Return version as a string (e.g. 'v1.00').
        """
        return self._text

    def __iter__(self):
        """
        Return major and minor versions, so that "casting" to tuple works.
        """
        yield self.major
        yield self.minor

    def __eq__(self, other):
        """
        Test equality with another instance or tuple.

        :param other: A CompilerVersion instance or a (major, minor) tuple.
        """
        other_major, other_minor = other

        return self.major == other_major and self.minor == other_minor

    def __lt__(self, other):
        """
        Test less-than ordering with another instance or tuple.

        :param other: A CompilerVersion instance or a (major, minor) tuple.
        """
        other_major, other_minor = other

        if self.major != other_major:
            return self.major < other_major
        else:
            return self.minor < other_minor
