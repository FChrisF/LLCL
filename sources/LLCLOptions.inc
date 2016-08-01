{
  Main options: compilation directives

  This file is a part of the Light LCL (LLCL).
}

//------------------------------------------------------------------------------

{
  Section 1: options defined by default.

    Undefining them usually permits to shrink a little bit the size
    of the final executable, but with the penality of having not the
    concerned functionnality.
}

{   LLCL_OPT_TOPFORM   -   Forms.pas

    "Top invisible" form above all forms and enhanced multi-forms support

    Notes: this option is necessary for using the MainFormOnTaskBar property
    of the Application object, and also usually when TTrayicon is used.
    If not defined and if only one form is present in the program, the
    general behavior is pretty close to the case of the defined one,
    with the MainFormOnTaskBar option set (i.e. = true).
}
{$DEFINE LLCL_OPT_TOPFORM}

{   LLCL_OPT_USEMENUS   -   Forms.pas, ExtCtrls.pas

    Menus (MainMenu and/or PopupMenu) used in program

    Note: menus are also used for the TTrayIcon class.
}
{$DEFINE LLCL_OPT_USEMENUS}

{   LLCL_OPT_USEDIALOG   -   Dialogs.pas

    OpenDialog/SaveDialog(/SelectDirectoryDialog) classes used in program

    Notes: when undefined, this permits to use the ShowMessage and the
    SelectDirectory functions without a size penality due to the Dialog classes.
    This option has no effect if the Dialogs unit is not used.
}
{$DEFINE LLCL_OPT_USEDIALOG}

{   LLCL_OPT_USEIMAGE   -   ExtCtrls.pas

    Image class used in program

    Notes: when undefined, this permits to use the ExtCtrls unit (Timer and
    TrayIcon controls) without a size penality due to the Image class.
}
{$DEFINE LLCL_OPT_USEIMAGE}

{   LLCL_OPT_EXCEPTIONS   -   SysUtils.pas

    Support (limited) for Exceptions
}
{$DEFINE LLCL_OPT_EXCEPTIONS}

{   LLCL_OPT_STDLABEL   -   StdCtrls.pas

    Standard TLabel class (i.e. not a TWinControl)

    Note: if not defined, TLabel is identical to TStaticText.
}
{$DEFINE LLCL_OPT_STDLABEL}

//------------------------------------------------------------------------------

{
  Section 2: options not defined by default.

    Defining them permits to have the corresponding functionnality
    or fix, but with the penality of having an extra size in the
    final executable.
}

{   LLCL_OPT_USESELECTDIRECTORYDIALOG   -   Dialogs.pas

    SelectDirectoryDialog class used in program

    Notes: when defined, this permits to use the SelectDirectoryDialog
    class (use preferably the SelectDirectory function instead).
    This option has no effect if the Dialogs unit is not used,
    or if the LLCL_OPT_USEDIALOG option is not set.
}
{$IFDEF FPC}
//{$DEFINE LLCL_OPT_USESELECTDIRECTORYDIALOG}
{$ENDIF}

{   LLCL_OPT_NESTEDGROUPBOXWINXPFIX   -   Forms.pas, Controls.pas

    Fix for the nested groupboxes issue with Windows XP

    Notes: this concerns only Windows XP (not before and not after),
    and only if nested groupboxes are used (font display issue).
    When set, this option also implies that UI states (accelerators
    and focus rectangles) are visible when the application starts
    (which is not the standard for a Windows application).
}
//{$DEFINE LLCL_OPT_NESTEDGROUPBOXWINXPFIX}

{   LLCL_OPT_PNGSUPPORT   -   Graphics.pas
    LLCL_OPT_PNGSIMPLIFIED   -   LLCLPng.pas
    LLCL_OPT_IMGTRANSPARENT   -   Graphics.pas
    LLCL_OPT_DOUBLEBUFF   -   Control.pas

    Extended graphical options

    Notes:
    - when defined, LLCL_OPT_PNGSUPPORT permits the support of
      PNG files/resources in the TBitmap class,
    - LLCL_OPT_PNGSIMPLIFIED (requires LLCL_OPT_PNGSUPPORT) allows only the
      basic types of PNG files/resources: truecolour 8 bits (colour type = 2),
      truecolour + alpha 8 bits (colour type = 6) or indexed colour 1,4,8 bits
      (colour type = 3); with no interlaced data. Furthermore, the
      transparency chunk data are ignored in this case,
    - when defined, LLCL_OPT_IMGTRANSPARENT permits the support of
      transparent images/bitmaps (only for Windows 2000 or newer),
    - when defined, LLCL_OPT_DOUBLEBUFF permits the support of the double
      buffering painting method for Forms (if DoubleBuffered = true),
    - for simplification, with LLCL_OPT_EXTENDGRAPHICAL all these options
      are defined. However, these options are completely independent and
      may be defined individually,
    - except for the LLCL_OPT_DOUBLEBUFF option, these options have no
      effects if the LLCL_OPT_USEIMAGE option is not defined.
}
//{$DEFINE LLCL_OPT_EXTENDGRAPHICAL}
{$IF DEFINED(LLCL_OPT_EXTENDGRAPHICAL)}
  {$DEFINE LLCL_OPT_PNGSUPPORT}
  //{$DEFINE LLCL_OPT_PNGSIMPLIFIED}
  {$DEFINE LLCL_OPT_IMGTRANSPARENT}
  {$DEFINE LLCL_OPT_DOUBLEBUFF}
{$IFEND}

{   LLCL_OPT_USERADIOGROUP   -   ExtCtrls.pas

    RadioGroup class used in program

    Notes: when defined, this permits to use the RadioGroup class.
}
//{$DEFINE LLCL_OPT_USERADIOGROUP}

//------------------------------------------------------------------------------

{
  Section 3: options with various possible values
}

{   LLCL_OPT_UNICODE_API_A/W/W_ONLY   -   LLCLOSInt.pas

    Windows Ansi and/or Unicode/WideString APIs to use

    Notes:
    - LLCL_OPT_UNICODE_API_A: forces to use the Ansi APIs only (default for Delphi 7)
    - LLCL_OPT_UNICODE_API_W: forces to use both the Ansi and the Unicode APIs (default for FPC/Lazarus)
    - LLCL_OPT_UNICODE_API_W_ONLY: forces to use the Unicode APIs only

    By default, these options are not concerning the Windows API calls in
    SysUtils for Free Pascal/Lazarus (see LLCL_FPC_SYSRTL in LLCLFPCInc.inc).
}
//{$DEFINE LLCL_OPT_UNICODE_API_A}
//{$DEFINE LLCL_OPT_UNICODE_API_W}
//{$DEFINE LLCL_OPT_UNICODE_API_W_ONLY}

{   LLCL_OPT_GRIDSOPT_1/2/LV/ALL   -   Grids.pas

    TStringGrid options

    Notes:
    - LLCL_OPT_GRIDSOPT_1: TStringGrid compatibility Level 1 (proposed default)
        . support for "DefaultRowHeight" property
        . support for column sorting
    - LLCL_OPT_GRIDSOPT_2: TStringGrid compatibility Level 2
        . options for LLCL_OPT_GRIDSOPT_1
        . support for cells mouse button events
        . support for header (i.e. fixed row) mouse messages
        . support for first column editing
    - LLCL_OPT_GRIDSOPT_LV: ListView compatibility
        . right-click selects also a row (like left-click)
        . Ctrl+A selects all the rows
    - LLCL_OPT_GRIDSOPT_ALL: all options (LLCL_OPT_GRIDSOPT_2 + LLCL_OPT_GRIDSOPT_LV)
}
{$DEFINE LLCL_OPT_GRIDSOPT_1}
//{$DEFINE LLCL_OPT_GRIDSOPT_2}
//{$DEFINE LLCL_OPT_GRIDSOPT_LV}
//{$DEFINE LLCL_OPT_GRIDSOPT_ALL}

{   LLCL_OPT_USEZLIBDLL/USEZLIBDLLDYN/USEZLIBOBJ   -   LLCLZlib.pas

    Zlib options

    Notes:
    - LLCL_OPT_USEZLIBDLL: use static ZLib DLL (zlib1.dll)
    - LLCL_OPT_USEZLIBDLLDYN: use dynamic ZLib DLL (zlib1.dll) - requires LLCL_OPT_USEZLIBDLL
    - LLCL_OPT_USEZLIBOBJ: use external (C) object files

    If no such option is defined, pure Pascal functions are used (i.e. PasZlib).
}
//{$DEFINE LLCL_OPT_USEZLIBDLL}
//{$DEFINE LLCL_OPT_USEZLIBDLLDYN}
//{$DEFINE LLCL_OPT_USEZLIBOBJ}

