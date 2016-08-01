unit ClipBrd;

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
    * TClipboard: SetAsText fix
   Version 1.01:
    * File creation.
    * TClipboard/Clipboard implemented (only for text)
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
  Classes;

type
  TClipboard = class(TPersistent)
  private
    fOwnerHandle: THandle;
    function  OpenClipBrd(): boolean;
    procedure CloseClipBrd;
    function  GetAsText(): string;
    procedure SetAsText(const Value: string);
    procedure SetBuffer(Format: cardinal; Buffer: pointer; Size: integer);
  public
    procedure Open;
    procedure Close;
    procedure Clear;
    function  HasFormat(Format: cardinal): boolean;
    function  GetAsHandle(Format: cardinal): THandle;
    procedure SetAsHandle(Format: cardinal; Value: THandle);
    property  AsText: string read GetAsText write SetAsText;
  end;

{$IFDEF FPC}
const
  CF_TEXT         = 1;
  CF_BITMAP       = 2;
  CF_UNICODETEXT  = 13;
{$ENDIF}

var
  Clipboard:      TClipboard;

//------------------------------------------------------------------------------

implementation

uses
  LLCLOSInt, Windows,
  Forms;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

type
  TPApplication = class(TApplication);  // To access to protected part

//------------------------------------------------------------------------------

{ TClipboard }

function  TClipboard.OpenClipBrd(): boolean;
begin
  if fOwnerHandle=0 then
    fOwnerHandle := TPApplication(Application).AppHandle;
  result := LLCL_OpenClipboard(fOwnerHandle);
end;

procedure TClipboard.CloseClipBrd;
begin
  LLCL_CloseClipboard();
end;

function  TClipboard.GetAsText(): string;
var hData: THandle;
begin
  result := '';
  if not OpenClipBrd() then exit;
  hData := LLCL_GetClipboardData(LLCLS_CLPB_GetTextFormat());
  if hData<>0 then
    begin
      result := LLCLS_CLPB_GetText(LLCL_GlobalLock(hData));
      LLCL_GlobalUnlock(hData);
    end;
  CloseClipBrd;
end;

procedure TClipboard.SetAsText(const Value: string);
var pText: pointer;
var len: cardinal;
begin
  pText := LLCLS_CLPB_SetTextPtr(Value, len);
  SetBuffer(LLCLS_CLPB_GetTextFormat(), pText, len);
  FreeMem(pText);
end;

procedure TClipboard.SetBuffer(Format: cardinal; Buffer: pointer; Size: integer);
var hMem: THandle;
var pMem: pointer;
begin
  if not OpenClipBrd() then exit;
  Clear;
  hMem := LLCL_GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, Size);
  if hMem<>0 then
    begin
      pMem := LLCL_GlobalLock(hMem);
      if Assigned(pMem) then
        Move(Buffer^, pMem^, Size);
      LLCL_GlobalUnlock(hMem);
      LLCL_SetClipboardData(Format, hMem);
      // Don't free the allocated memory
    end;
  CloseClipBrd;
end;

procedure TClipboard.Open;
begin
  OpenClipBrd();
end;

procedure TClipboard.Close;
begin
  CloseClipBrd;
end;

procedure TClipboard.Clear;
begin
  LLCL_EmptyClipboard();
end;

function  TClipboard.HasFormat(Format: cardinal): boolean;
begin
  result :=  LLCL_IsClipboardFormatAvailable(Format);
end;

function  TClipboard.GetAsHandle(Format: cardinal): THandle;
begin
  result := 0;
  if not OpenClipBrd() then exit;
  result := LLCL_GetClipboardData(Format);
  Close;
end;

procedure TClipboard.SetAsHandle(Format: cardinal; Value: THandle);
begin
  if not OpenClipBrd() then exit;
  Clear;
  LLCL_SetClipboardData(Format, Value);
  Close;
end;

//------------------------------------------------------------------------------

initialization
  Clipboard := TClipboard.Create();

finalization
  Clipboard.Free;

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
