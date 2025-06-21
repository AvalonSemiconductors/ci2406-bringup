#!/bin/bash

set - e

#TRACE_FLAGS="--trace-depth 6 --trace -DTRACE_ON -CFLAGS '-DTRACE_ON'"
verilator -DBENCH -Wno-fatal --timing --top-module tb -cc -exe ${TRACE_FLAGS} bench.cpp execution_unit.v icache.v spi.v top.v uart.v top_vliw.v tb.v mul.v
cd obj_dir
make -f Vtb.mk
cd ..
