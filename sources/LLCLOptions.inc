{
   Main options: compilation directives

   This file is a part of the Light LCL (LLCL).

   Notes: Except for the Ansi/Unicode APIs options,
   - all the following options are defined by default,
   - undefining them usually permits to shrink a little bit
     the size of the final executable, but with the penality
     of having not the concerned functionnality.
}

//------------------------------------------------------------------------------

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

    OpenDialog/SaveDialog used in program

    Notes: when undefined, this permits to use the ShowMessage function
    without a size penality due to the TOpenDialog/TSaveDialog classes.
    This option has no effect if the Dialogs units is not used.
}
{$DEFINE LLCL_OPT_USEDIALOG}

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

{   LLCL_OPT_UNICODE_API_A/W/W_ONLY   -   LLCLOSInt.pas

    Windows Ansi and/or Unicode/WideString APIs to use

    Notes:
    - LLCL_OPT_UNICODE_API_A: forces to use the Ansi APIs only
    - LLCL_OPT_UNICODE_API_W: forces to use both the Ansi and the Unicode APIs
    - LLCL_OPT_UNICODE_API_W_ONLY: forces to use the Unicode APIs only
    By default, these options are not concerning the Windows API calls in
    SysUtils for Free Pascal/Lazarus (see LLCL_FPC_SYSRTL in LLCLFPCInc.inc).
}
//{$DEFINE LLCL_OPT_UNICODE_API_A}
//{$DEFINE LLCL_OPT_UNICODE_API_W}
//{$DEFINE LLCL_OPT_UNICODE_API_W_ONLY}

