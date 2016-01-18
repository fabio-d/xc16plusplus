/* Workaround for missing address space identifier support in g++.
 *
 * Two address space identifiers are used in libpic30.h (__pack_upper_byte and
 * __eds__), which are not recognized by the C++ parser. Therefore, this file
 * arranges macros so that they are temporarily ignored.
 *
 * Note that __pack_upper_byte and __eds__ are disabled only while parsing
 * libpic30.h. For any other usage, the C++ compiler will emit a compilation
 * error.
 *
 * Thanks to this we keep the error message enabled for user code and, if the
 * code being compiled attempts to use such keywords, the compiler will warn
 * that they are not available in C++ through a compilation error.
 */

#ifdef __cplusplus
# define __pack_upper_byte
# define __eds__
#  include <libpic30.h>
# undef __pack_upper_byte
# undef __eds__
#else
// if we are compiling plain C, there is no need for the workaround
# include <libpic30.h>
#endif
