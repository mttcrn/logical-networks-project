# Logical Networks Project 2022/2023

The aim of the project is the implementation of a hardware component in VHDL which, given in input a selector and a memory address, shows the content on the selected output channel of memory, without erasing previously obtained results. 

Grade obtained: 30/30.

## Problem description
The module is initialized each time the `RESET` signal is equal to 1, asynchronously with respect to the clock.

Processing begins when `START` is equal to 1, and reading of input `W` occurs on the rising edge of the clock. The input component receives a sequence consisting of two header bits, that serve to identify the target output channel, followed by the memory address bit. As soon as `START` is qeual to 0, the module send a request to the memory and selects the output channel to which the result should be directed. 

When the memory produces a result, the oupout `DONE` is set to 1 and, simultaneously, the message is written to the selected output channel, while the other channels display the last transmitted value, all within a single clock cycle. 

## Implementation
The implementation is achieved through a finite state machine (FSM) that represents the algorithm used, from the reading of inputs to the output writing. The entire module's operation is encapsulated within a single process, ensuring that all signals are updated predictably and synchronously.

## Authors
* [Andrea Grassi](https://github.com/Fozyhh)
* [Caterina Motti](https://github.com/mttcrn)
