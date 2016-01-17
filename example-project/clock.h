#ifndef CLOCK_H
#define CLOCK_H

/* This header file is consumed by both C and C++ code. Symbols defined in C
 * files must be enclosed within extern "C" blocks. However, the C compiler does
 * not understand extern "C", and that is the reason why #ifdef __cplusplus
 * is needed */

#define FCY	(77385000 / 2)

#ifdef __cplusplus
extern "C" {
#endif

void clock_init(void);

#ifdef __cplusplus
}
#endif

#endif
