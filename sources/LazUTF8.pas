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

    This Source Code Form is "Incompatible With Secondary Licenses",
  as defined by the Mozilla Public License, v. 2.0.

  Copyright (c) 2015-2016 ChrisF

  Based upon the Very LIGHT VCL (LVCL):
  Copyright (c) 2008 Arnaud Bouchez - http://bouchez.info
  Portions Copyright (c) 2001 Paul Toth - http://tothpaul.free.fr

   Version 1.02:
   Version 1.01:
    * UTF8CompareStr, UTF8CompareText, UTF8LowerCase and UTF8UpperCase added
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
function  UTF8CompareStr(const S1, S2: utf8string): integer;
function  UTF8CompareText(const S1, S2: utf8string): integer;
// Note: ALanguage is ignored in UTF8LowerCase and UTF8UpperCase
function  UTF8LowerCase(const AInStr: utf8string; ALanguage: utf8string=''): utf8string;
function  UTF8UpperCase(const AInStr: utf8string; ALanguage: utf8string=''): utf8string;
{$ELSE UNICODE}
function  UTF8ToSys(const S: string): string;
function  SysToUTF8(const S: string): string;
function  UTF8ToWinCP(const S: string): string;
function  WinCPToUTF8(const S: string): string;
function  UTF8CompareStr(const S1, S2: string): integer;
function  UTF8CompareText(const S1, S2: string): integer;
// Note: ALanguage is ignored in UTF8LowerCase and UTF8UpperCase
function  UTF8LowerCase(const AInStr: string; ALanguage: string=''): string;
function  UTF8UpperCase(const AInStr: string; ALanguage: string=''): string;
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

{$IFDEF UNICODE}
function  UTF8CompareStr(const S1, S2: utf8string): integer;
{$ELSE UNICODE}
function  UTF8CompareStr(const S1, S2: string): integer;
{$ENDIF UNICODE}
var count, count1, count2: integer;
begin
  count1 := length(S1);
  count2 := length(S2);
  if count1 > count2 then
    count := count2
  else
    count := count1;
  result := CompareByte(pointer(@s1[1])^, pointer(@s2[1])^, count);
  if result=0 then
    if count1 > count2 then
      result := 1                 // Doesn't return count1 - count 2
    else
      if count1 < count2 then
        result := -1;             //    Like CompareStr in SysUTils
end;

{$IFDEF UNICODE}
function  UTF8CompareText(const S1, S2: utf8string): integer;
{$ELSE UNICODE}
function  UTF8CompareText(const S1, S2: string): integer;
{$ENDIF UNICODE}
begin
  result := UTF8CompareStr(UTF8UpperCase(S1), UTF8UpperCase(S2));
end;

{$IFDEF UNICODE}
function  UTF8LowerCase(const AInStr: utf8string; ALanguage: utf8string=''): utf8string;
{$ELSE UNICODE}
function  UTF8LowerCase(const AInStr: string; ALanguage: string=''): string;
{$ENDIF UNICODE}
begin
  // (Language ignored)
  result := LLCLS_UTF8LowerCase(AInStr);
end;

{$IFDEF UNICODE}
function  UTF8UpperCase(const AInStr: utf8string; ALanguage: utf8string=''): utf8string;
{$ELSE UNICODE}
function  UTF8UpperCase(const AInStr: string; ALanguage: string=''): string;
{$ENDIF UNICODE}
begin
  // (Language ignored)
  result := LLCLS_UTF8UpperCase(AInStr);
end;

//------------------------------------------------------------------------------

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
