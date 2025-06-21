# Bugs
This README serves as a central point to document all hardware bugs of this design.

## QSPI entry missing critical delay
### Description
The design is meant to put the 25Qxx chip into quad mode by setting the Q bit in one of the status registers. Unfortunately, writing the status registers requires a 1 - 2ms long processing time, which is not met. The 25Qxx becomes unresponsive after issuing the write status register command.

![](S8x305/Bugs/fix.png)

Severity: Low
### Workarounds
A carefully crafted management controller firmware generates a cycle-perfect inhibit to the CS signal going to the 25Qxx, preventing the write status register command from being recognized. Since the Q bit is non-volatile, it can be programmed together with the memory contents ahead of time.
