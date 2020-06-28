#pragma once

void do_arg_none();
void do_arg_char();
void do_arg_string();
void do_arg_int();
void do_arg_float();
void do_arg_float_and_string();

#if WITH_LONGLONG
void do_arg_longlong();
#endif
