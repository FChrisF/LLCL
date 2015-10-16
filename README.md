Light LCL (LLCL)
================


## Description

  The Light LCL (LLCL) is intended to provide a way to produce
small executable files with Free Pascal/Lazarus or Delphi 7,
while being compatible with - a part of - the LCL/VCL. It may
concern for instance: small installation or configuration
programs, simple tools, test programs, ... Typically, the size
is about 1/10th with Free Pascal/Lazarus and 1/5th with Delphi
for simple small programs.

  It's not a specific graphical library, or another widgetset.
It's an emulation of a small subset of the standard LCL/VCL,
for only the most basic controls and classes, with their most
common properties, methods and events. Of course, it implies
that only the controls and properties present in the Light LCL
can be used.

  It is based upon the Very Light VCL (LVCL) of Synopse for Delphi 7:
[LVCL](https://github.com/synopse/LVCL)


## Usage and configuration

  There is nothing to install in order to use it, nor any
configuration to modify: just indicate a valid path for the
Light LCL files into your project options, and that's it !

  It's available only for Windows (32 and 64 bits). It has
been tested with FPC 2.6.x/3.x + Lazarus 1.2.x/1.4.x/1.5 and
Delphi 7.

  See "README.txt" for more pieces of information.


## License

  The Light LCL is released under the Mozilla Public License
version 2.0. See "LICENSE.txt".


## LLCL ChangeLog

* [Version 1.00] (https://github.com/FChrisF/LLCL/releases/tag/v1.0.0):
  - Initial public release.


## Samples

  A small demonstration project (both for Free Pascal/Lazarus
and Delphi 7) is included.

[![Demonstration screenshot](https://FChrisF.github.io/LLCL/captures/demo-screen-th.png)](https://FChrisF.github.io/LLCL/captures/demo-screen.png)

  More sample projects are also available here:
[Sample projects for the LLCL](https://github.com/FChrisF/LLCL-samples)
