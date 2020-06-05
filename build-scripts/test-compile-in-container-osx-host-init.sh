#!/bin/bash
echo 4096 > /proc/sys/vm/mmap_min_addr
cd /proc/sys/fs/binfmt_misc
echo ":xc16plusplus-osx32:M::\\xce\\xfa\\xed\\xfe::/maloader-src/ld-mac32:" > register
echo ":xc16plusplus-osx64:M::\\xcf\\xfa\\xed\\xfe::/maloader-src/ld-mac:" > register
