#pragma once

#ifdef __cplusplus
extern "C" {

typedef long eds_ptr_t; // sizeof(long) == sizeof(__eds__ int *)
#else
typedef __eds__ int *eds_ptr_t;
#endif

eds_ptr_t get_eds_buffer_addr();

void write_eds(eds_ptr_t addr, int val);
int read_eds(eds_ptr_t addr);

#ifdef __cplusplus
}
#endif
