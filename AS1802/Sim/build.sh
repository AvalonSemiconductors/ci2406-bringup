#!/bin/bash

set - e

TRACE_FLAGS="--trace-depth 6 --trace -DTRACE_ON -CFLAGS '-DTRACE_ON'"
verilator -DBENCH -Wno-fatal --timing --top-module tb -cc -exe ${TRACE_FLAGS} bench.cpp tb.v wrapped_as1802.v AS1802.v ../Quartus_Proj/cpld.v
cd obj_dir
make -f Vtb.mk
cd ..
