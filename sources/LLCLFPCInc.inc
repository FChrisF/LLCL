{
  Optional compilation directives for FPC/Lazarus

  This file is a part of the Light LCL (LLCL).

  Notes:
   - specific to FPC/Lazarus (not used with Delphi),
   - external file because of Delphi (i.e. $if problem).
}

{$ifdef LLCL_FPC_MODESECTION}
//------------------------------------------------------------------------------

  {$mode objfpc}{$H+}
//  {$mode delphi}
//  {$mode objfpc}{$modeswitch unicodestrings}{$H+}   // Requires FPC 2.7.1+
//  {$mode delphiunicode}{$codepage UTF8}             // Requires FPC 2.7.1+

// Specific (i.e. not LCL standard) Ansi only option (no UTF8 at all)
//   Can't be used with any Unicode mode ({$modeswitch unicodestrings} or {$mode delphiunicode})
//  {$define LLCL_FPC_ANSI_ONLY}
{$IFDEF UNICODE} {$undef LLCL_FPC_ANSI_ONLY} {$ENDIF}

{$else LLCL_FPC_MODESECTION}
//------------------------------------------------------------------------------

// General
{$if defined(FPC_FULLVERSION) and (FPC_FULLVERSION >= 020701)}
  {$define LLCL_FPC_27PLUS}           // FPC 2.7.1+
{$ifend}

// SysUtils and LLCLOSInt
// Note: Some of the SysUtils functions are not using this option, like
//        GetCurrentDir, SetCurrentDir , ... (call to system functions)
{$define LLCL_FPC_SYSRTL}             // RTL SysUtils (Ansi or Wide APIs only)
{$if defined(LLCL_FPC_SYSRTL)}
  {$if defined(LLCL_FPC_27PLUS)}
    {$define LLCL_FPC_UNISYS}         // Unicode SysUtils version, Wide structures, Wide APIs
  {$else}                             //   (Must be coherent with LLCL_EXTWIN_WIDESTRUCT)
    {$define LLCL_FPC_ANSISYS}        // Ansi SysUtils version, Ansi structures, Ansi APIs
  {$ifend}
{$ifend}

// LMessages
{$define LLCL_REDEFINE_MESS}          // Messages redefind
{$if defined(FPC_FULLVERSION) and (FPC_FULLVERSION >= 020604)}
  {$undef LLCL_REDEFINE_MESS}
{$ifend}

// LLCLOSInt
{$define LLCL_MISSING_WINDOWS_DEC}    // Windows declarations missing
{$define LLCL_FPC_UTF8_EXTINC}        // Constant message strings: UTF8 type
{$if defined(FPC_FULLVERSION) and (FPC_FULLVERSION >= 999999)}
  {$undef LLCL_MISSING_WINDOWS_DEC}
{$ifend}
{$if defined(LLCL_FPC_27PLUS)}
  {$define LLCL_EXTWIN_WIDESTRUCT}    // External Windows wide structures
  {$define LLCL_FPC_CPSTRING}         // RawByteStrings have code page
  {$define LLCL_FPC_UTF8RTL}          // Has UTF8 RTL (LCL)
  {$ifdef DisableUTF8RTL}
    {$undef LLCL_FPC_UTF8RTL}         // Compliant with LCL
  {$endif}
  {$ifdef LLCL_FPC_ANSI_ONLY}         // Specific to LLCL
    {$undef LLCL_FPC_UTF8RTL}         //    "       "
    {$undef LLCL_FPC_UTF8_EXTINC}     //    "       "
  {$endif}
{$ifend}

//------------------------------------------------------------------------------
{$endif LLCL_FPC_MODESECTION}

