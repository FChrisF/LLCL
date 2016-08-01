unit LCLIntF;

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
    * File creation.

   Notes:
    - very basic unit specific to FPC/Lazarus (not used with Delphi).
}

{$IFDEF FPC}
  {$define LLCL_FPC_MODESECTION}
  {$I LLCLFPCInc.inc}             // For mode
  {$undef LLCL_FPC_MODESECTION}
{$ENDIF}

{$I LLCLOptions.inc}      // Options

//------------------------------------------------------------------------------

interface

uses
  LLCLOSInt,
  Windows;

const
  LM_USER           = Windows.WM_USER;

function  CallWindowProc(lpPrevWndFunc: TFarProc; Handle: HWND; Msg: UINT; WParam: WParam; LParam: LParam): integer;
function  PostMessage(Handle: HWND; Msg: Cardinal; WParam: WParam; LParam: LParam): boolean;
function  SendMessage(Handle: HWND; Msg: Cardinal; WParam: WParam; LParam: LParam): LRESULT;

function  MakeLong(A, B: word): DWORD; inline;
function  MakeWParam(l, h: word): WPARAM; inline;
function  MakeLParam(l, h: word): LPARAM; inline;
function  MakeLResult(l, h: word): LRESULT; inline;

//------------------------------------------------------------------------------

implementation

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

//------------------------------------------------------------------------------

function  CallWindowProc(lpPrevWndFunc: TFarProc; Handle: HWND; Msg: UINT; WParam: WParam; LParam: LParam): integer;
begin
  result := LLCL_CallWindowProc(lpPrevWndFunc, Handle, Msg, WParam, LParam);
end;

function  PostMessage(Handle: HWND; Msg: Cardinal; WParam: WParam; LParam: LParam): boolean;
begin
  result := LLCL_PostMessage(Handle, Msg, WParam, LParam);
end;

function  SendMessage(Handle: HWND; Msg: Cardinal; WParam: WParam; LParam: LParam): LRESULT;
begin
  result := LLCL_SendMessage(Handle, Msg, WParam, LParam);
end;

function  MakeLong(A, B: word): DWORD; inline;
begin
  result := A or (B shl 16);
end;

function  MakeWParam(l, h: word): WPARAM; inline;
begin
  result := MakeLong(l, h);
end;

function  MakeLParam(l, h: word): LPARAM; inline;
begin
  result := MakeLong(l, h);
end;

function  MakeLResult(l, h: word): LRESULT; inline;
begin
  result := MakeLong(l, h);
end;

//------------------------------------------------------------------------------

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
