unit LazUTF8;

{
         LLCL - FPC/Lazarus Light LCL
               based upon
         LVCL - Very LIGHT VCL
         ----------------------------

    This file is a part of the Light LCL (LLCL).

    This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

    This Source Code Form is “Incompatible With Secondary Licenses”,
  as defined by the Mozilla Public License, v. 2.0.

  Copyright (c) 2015 ChrisF

  Based upon the Very LIGHT VCL (LVCL):
  Copyright (c) 2008 Arnaud Bouchez - http://bouchez.info
  Portions Copyright (c) 2001 Paul Toth - http://tothpaul.free.fr

   Version 1.00:
    * File creation.
    * Some UTF8 functions (not present in LazFileUtils)

   Notes:
    - specific to FPC/Lazarus (not used with Delphi).
}

{$IFDEF FPC}
  {$define LLCL_FPC_MODESECTION}
  {$I LLCLFPCInc.inc}             // For mode
  {$undef LLCL_FPC_MODESECTION}
{$ENDIF}

{$I LLCLOptions.inc}      // Options

//------------------------------------------------------------------------------

interface

function  SysErrorMessageUTF8(ErrorCode: integer): string;

{$IFDEF UNICODE}
function  UTF8ToSys(const S: utf8string): ansistring;
function  SysToUTF8(const S: ansistring): utf8string;
function  UTF8ToWinCP(const S: utf8string): ansistring;
function  WinCPToUTF8(const S: ansistring): utf8string;
{$ELSE UNICODE}
function  UTF8ToSys(const S: string): string;
function  SysToUTF8(const S: string): string;
function  UTF8ToWinCP(const S: string): string;
function  WinCPToUTF8(const S: string): string;
{$ENDIF UNICODE}

//------------------------------------------------------------------------------

implementation

uses
  LLCLOSInt,
  SysUtils;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

//------------------------------------------------------------------------------

function  SysErrorMessageUTF8(ErrorCode: integer): string;
begin
  result := string(SysToUTF8(SysErrorMessage(ErrorCode)));
end;

{$IFDEF UNICODE}
function  UTF8ToSys(const S: utf8string): ansistring;
{$ELSE UNICODE}
function  UTF8ToSys(const S: string): string;
{$ENDIF UNICODE}
begin
  result := LLCLS_UTF8ToSys(S);
end;

{$IFDEF UNICODE}
function  SysToUTF8(const S: ansistring): utf8string;
{$ELSE UNICODE}
function  SysToUTF8(const S: string): string;
{$ENDIF UNICODE}
begin
  result := LLCLS_SysToUTF8(S);
end;

{$IFDEF UNICODE}
function  UTF8ToWinCP(const S: utf8string): ansistring;
{$ELSE UNICODE}
function  UTF8ToWinCP(const S: string): string;
{$ENDIF UNICODE}
begin
  result := LLCLS_UTF8ToWinCP(S);
end;

{$IFDEF UNICODE}
function  WinCPToUTF8(const S: ansistring): utf8string;
{$ELSE UNICODE}
function  WinCPToUTF8(const S: string): string;
{$ENDIF UNICODE}
begin
  result := LLCLS_WinCPToUTF8(S);
end;

//------------------------------------------------------------------------------

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
