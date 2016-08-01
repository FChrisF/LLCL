Light LCL (LLCL)
================


## Description

  The Light LCL (LLCL) is intended to provide a way to produce
small executable files with Free Pascal/Lazarus or Delphi 7,
while being compatible with - a part of - the LCL/VCL. It may
concern for instance: small installation or configuration
programs, simple tools, test programs, ... Typically, the size
is about 1/10th with Free Pascal/Lazarus and 1/5th with Delphi
for small and simple programs.

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
been tested with FPC 2.6.x/3.x + Lazarus 1.4.x/1.6 and
Delphi 7.

  See "README.txt" for more pieces of information.


## License

  The Light LCL is released under the Mozilla Public License
version 2.0. See "LICENSE.txt".


## LLCL ChangeLog

* [Version 1.02] (https://github.com/FChrisF/LLCL/releases/tag/v1.0.2):

  Main changes and additions:
  - TRadioGroup control added (not enabled by default),
  - TRegistry class added (Registry.pas),
  - TClipboard: SetAsText bug fix,
  - TStringGrid: ColCount and RowCount bug fix,
  - bug fixes when application was starting and closing,
  - bug fixes and non standard ItemStrings property removed
    for internal TCustomBox class,
  - TForm: ShowModal bug fix (with several modal forms),
  - DeleteFile and RenameFile added (SysUtils), and also
    DeleteFileUTF8 and RenameFileUTF8 (FileUtil/LazFileUtils),
  - internal TMemoLines et TBoxStrings classes (for TMemo and
    TComboBox/TListBox controls) modified for a better LCL/VCL
    compatibility (data accessing).

* [Version 1.01] (https://github.com/FChrisF/LLCL/releases/tag/v1.0.1):

  Main changes and additions:
  - TStringGrid control added (Grids.pas),
  - TIniFile class added (IniFiles.pas),
  - TClipboard class added for text data (ClipBrd.pas),
  - PNG images support (not enabled by default),
  - transparent bitmaps support (not enabled by default),
  - forms double buffering support (not enabled by default),
  - TSelectDirectoryDialog control added (Dialog.pas) for
    FPC/Lazarus (not enabled by default) and SelectDirectory
    function (Dialog.pas or FileCtrl.pas),
  - ANSI LLCL option (i.e. no UTF8 at all) added for
    FPC/Lazarus (see in LLCLFPCInc.inc),
  - design time only properties for controls are now
    accessible for dynamic creation purposes. Run time
    modifications are still not supported for them, but they
    can now be set at run time before the corresponding
    control is dynamically created,
  - a few bug fixes and some minor additions/modifications.

  Note: controls and functionalities not enabled by default
  can be activated by defining the corresponding option(s) in
  the option files LLCLOptions.inc.

* [Version 1.00] (https://github.com/FChrisF/LLCL/releases/tag/v1.0.0):
  - Initial public release.


## Samples

  A small demonstration project (both for Free Pascal/Lazarus
and Delphi 7) is included.

[![Demonstration screenshot](https://FChrisF.github.io/LLCL/captures/demo-screen-th.png)](https://FChrisF.github.io/LLCL/captures/demo-screen.png)

  More sample projects are also available here:
[Sample projects for the LLCL](https://github.com/FChrisF/LLCL-samples)
