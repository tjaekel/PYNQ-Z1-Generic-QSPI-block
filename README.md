# PYNQ-Z1 Generic QSPI block
 VHDL example for a Generic QSPI interface

## Generic QSPI block
The implementation of a Generic QSPI interface, plus testbench

## Approach
We need a Generic QSPI (not a memory chip specific QSPI, e.g. via the AMD/Xilinx
 axi_quad_spi block (which is hard-coded for specific chips).
We need a QSPI which supports:
* send any 8bit CMD via single lane (or even a 4-lane, as 1-4-4 or 4-4-4)
* send a 32bit ADDR (on all 4 lanes)
* send a 24bit ALT word (on all lanes - axi_quad_spi IP block does not support)
* send a 2 clock cycle turnaround (axi_quad_spi IP block does not support)
* sample 32bit words on Read with a delayed QCLKfb signal (the QCLKfb is an input,
delayed in the same way as the data lanes, e.g. due to external level shifters needed)

## Implementation
The Generic QSPI block has four 32bit registers:
* WR register - which holds the data to send out on QSPI data lanes (write)
* RD register - which provides the data sampled on the QSPI data lanes (read)
* CTL register - to specify which transaction part to do, e.g. send a 32bit word(ADDR),
send a 24bit word (ALT),
generate clock cycles for a turnaround (before read)
* STS register - indicate that the shift out or in has been finished

## Use the block
This project is a complete Vivado 2023.2 project, with a testbench script (all in VHDL).
It is used as a block for a PYNQ-Z1 overlay block diagram (import this RTL code in a complete PYNQ-Z12 overlay project, see the other related repository).

