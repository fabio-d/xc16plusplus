#pragma once

void do_disabled_smartio();

void do_arg_none();
void do_arg_char();
void do_arg_string();
void do_arg_int();
void do_arg_float();
void do_arg_float_and_string();

#if __XC16_VERSION__ >= 1030 // v1.30+ only
void do_arg_longlong();
#endif
