unit FileCtrl;

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
    * SelectDirectory added (for Delphi)
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
  LLCLOSInt;

type
  TSelectDirExtOpt = (sdNewFolder, sdShowEdit, sdShowShares, sdNewUI,
    sdShowFiles, sdValidateDir);
  TSelectDirExtOpts = set of TSelectDirExtOpt;

{$IFNDEF FPC}   // SelectDirectory is in Dialogs.pas for FPC/Lazarus
function  SelectDirectory(const Caption: string; const Root: string; var Directory: string): boolean; overload;
{$if CompilerVersion >= 18)}  // Delphi 2006 or after
function  SelectDirectory(const Caption: string; const Root: string; var Directory: string; Options: TSelectDirExtOpts = [sdNewUI]; Parent: TWinControl = nil): boolean; overload;
{$ifend}
{$ENDIF}

// (Not VCL/LCL standard - Called from Dialogs.pas for FPC)
function  FC_SelectDirectory(const Caption: string; const InitialDirectory: string; Options: TSelectDirExtOpts; var Directory: string): Boolean;

//------------------------------------------------------------------------------

implementation

uses
  {$IFNDEF FPC}ShlObj,{$ENDIF}
  Forms;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

//------------------------------------------------------------------------------

{$IFNDEF FPC}
function  SelectDirectory(const Caption: string; const Root: string; var Directory: string): Boolean;
begin
  result := FC_SelectDirectory(Caption, Root, [], Directory);
end;

{$if CompilerVersion >= 18)}  // Delphi 2006 or after
function  SelectDirectory(const Caption: string; const Root: string; var Directory: string; Options: TSelectDirExtOpts = [sdNewUI]; Parent: TWinControl = nil): boolean; overload;
begin
  result := FC_SelectDirectory(Caption, Root, Options, Directory);
end;
{$ifend}

{$ENDIF}

function  FC_SelectDirectory(const Caption: string; const InitialDirectory: string; Options: TSelectDirExtOpts; var Directory: string): Boolean;
var BrowseInfo: TBrowseInfo;
begin
	FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
	BrowseInfo.hwndOwner := Application.MainForm.Handle;
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
  if (sdNewUI in Options) or (sdShowShares in Options) then
    begin
      BrowseInfo.ulFlags := BrowseInfo.ulFlags or BIF_NEWDIALOGSTYLE;
      if not (sdNewFolder in Options) then
        BrowseInfo.ulFlags := BrowseInfo.ulFlags or BIF_NONEWFOLDERBUTTON;
      if (sdShowShares in Options) then
        BrowseInfo.ulFlags := BrowseInfo.ulFlags or BIF_SHAREABLE;
    end;
  if (sdShowEdit in Options) then
    BrowseInfo.ulFlags := BrowseInfo.ulFlags or BIF_EDITBOX;
  if (sdShowFiles in Options) then
    BrowseInfo.ulFlags := BrowseInfo.ulFlags or BIF_BROWSEINCLUDEFILES;
  if (sdValidateDir in Options) and (sdShowEdit in Options) then
    BrowseInfo.ulFlags := BrowseInfo.ulFlags or BIF_VALIDATE;
  result := LLCLS_SH_BrowseForFolder(BrowseInfo, Caption, InitialDirectory, Directory);
end;

//------------------------------------------------------------------------------

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
