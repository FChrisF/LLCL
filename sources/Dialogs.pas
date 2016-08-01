unit Dialogs;

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
    * SelectDirectory added (for FPC/Lazarus)
    * TSelectDirectoryDialog added for FPC/Lazarus (not enabled by default - see LLCL_OPT_USESELECTDIRECTORYDIALOG in LLCLOptions.inc)
   Version 1.00:
    * Application.BiDiMode used for ShowMessage (through Application.MessageBox)
    * TOpenDialog and TSaveDialog implemented
}

// Original notes from LVCL

{
         LVCL - Very LIGHT VCL
         ----------------------------

   Tiny replacement for the standard VCL Dialogs.pas
   Just put the LVCL directory in your Project/Options/Path/SearchPath
   and your .EXE will shrink from 300KB to 30KB

   Notes:
   - dummy unit code to shrink exe size -> use Windows.MessageBox() instead

  The contents of this file are subject to the Mozilla Public License
  Version 1.1 (the "License"); you may not use this file except in
  compliance with the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL

  Software distributed under the License is distributed on an "AS IS"
  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
  License for the specific language governing rights and limitations
  under the License.

  The Initial Developer of the Original Code is Arnaud Bouchez.
  This work is Copyright (C) 2008 Arnaud Bouchez - http://bouchez.info
  Emulates the original Delphi/Kylix Cross-Platform Runtime Library
  (c)2000,2001 Borland Software Corporation
  Portions created by Paul Toth are Copyright (C) 2001 Paul Toth. http://tothpaul.free.fr
  All Rights Reserved.
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
{$ifdef LLCL_OPT_USEDIALOG}
  LLCLOSInt, Windows, {$IFDEF FPC}LMessages{$ELSE}Messages{$ENDIF},
  Classes, Controls;
{$else}
  LLCLOSInt, Windows;
{$endif}

{$ifdef LLCL_OPT_USEDIALOG}
type
  TOpenOption = (ofReadOnly, ofOverwritePrompt, ofHideReadOnly, ofNoChangeDir,
    ofShowHelp, ofNoValidate, ofAllowMultiSelect, ofExtensionDifferent, ofPathMustExist,
    ofFileMustExist, ofCreatePrompt, ofShareAware, ofNoReadOnlyReturn, ofNoTestFileCreate,
    ofNoNetworkButton, ofNoLongNames, ofOldStyleDialog, ofNoDereferenceLinks, ofEnableIncludeNotify,
    ofEnableSizing, ofDontAddToRecent, ofForceShowHidden,
    ofViewDetail, ofAutoPreview);
  TOpenOptions = set of TOpenOption;

  TOpenDialog = class(TNonVisualControl)
  private
    fDefaultExt: string;
    fFileName: string;
    fFilter: string;
    fFilterIndex: integer;
    fInitialDir: string;
    fOptions: TOpenOptions;
    fTitle: string;
    fFiles: TStringList;
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    procedure ControlInit(RuntimeCreate: boolean); override;
    procedure ControlCall(var Msg: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function Execute: boolean; virtual;
    property DefaultExt: string read fDefaultExt write fDefaultExt;
    property FileName: string read fFileName write fFileName;
    property Filter: string read fFilter write fFilter;
    property FilterIndex: integer read fFilterIndex write fFilterIndex;
    property InitialDir: string read fInitialDir write fInitialDir;
    property Options: TOpenOptions read fOptions write fOptions;
    property Title: string read fTitle write fTitle;
    property Files: TStringList read fFiles write fFiles;
  end;

  TSaveDialog = class(TOpenDialog)
  public
    constructor Create(AOwner: TComponent); override;
  end;

{$ifdef LLCL_OPT_USESELECTDIRECTORYDIALOG}
  TSelectDirectoryDialog = class(TOpenDialog)
  public
    constructor Create(AOwner: TComponent); override;
    function Execute: boolean; override;
  end;
{$endif LLCL_OPT_USESELECTDIRECTORYDIALOG}
{$endif LLCL_OPT_USEDIALOG}

procedure ShowMessage(const Msg: string);
{$IFDEF FPC}    // SelectDirectory is in FileCtrl.pas for Delphi
function  SelectDirectory(const Caption: string; const InitialDirectory: string; out Directory: string): Boolean; overload;
{$ENDIF FPC}

//------------------------------------------------------------------------------

implementation

uses
{$ifdef LLCL_OPT_USEDIALOG}
  {$IFDEF FPC}FileCtrl,{$ELSE}CommDlg,{$ENDIF}
  Forms, SysUtils;
{$else}
  {$IFDEF FPC}FileCtrl,{$ENDIF}
  Forms;
{$endif}

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

function CharReplace(const Str: string; OldChar, NewChar: Char): string; forward;

const
  MB_ICONMASK           = $000000F0;

//------------------------------------------------------------------------------

{$IFDEF FPC}
// Dummy function to avoid compilation hint (LMessages or LLCLOSInt not used)
function LMessages_Dummy({$ifdef LLCL_OPT_USEDIALOG}const Msg: TLMCommand{$endif}): boolean;
begin
  result := (LLCL_GetLastError()=0);
end;
{$ENDIF FPC}

// case sensitive - all occurences
function CharReplace(const Str: string; OldChar, NewChar: Char): string;
var i: integer;
begin
  result := Str;
  for i := 1 to length(Str) do
    if result[i]=OldChar then
      result[i] := NewChar;
end;

//------------------------------------------------------------------------------

procedure ShowMessage(const Msg: string);
begin
  Application.MessageBox(@Msg[1], @Application.Title[1], MB_OK or MB_ICONMASK);
end;

{$IFDEF FPC}
function  SelectDirectory(const Caption: string; const InitialDirectory: string; out Directory: string): Boolean;
begin
  result := FC_SelectDirectory(Caption, InitialDirectory, [sdNewFolder, sdShowEdit, sdNewUI], Directory);
end;
{$ENDIF FPC}

{$ifdef LLCL_OPT_USEDIALOG}
//------------------------------------------------------------------------------

{ TOpenDialog }

constructor TOpenDialog.Create(AOwner: TComponent);
begin
  ATType := ATTOpenDialog;
  fFilterIndex := 1;
{$IFDEF FPC}
  fOptions := [ofEnableSizing, ofViewDetail];
{$ELSE FPC}
  fOptions := [ofHideReadOnly, ofEnableSizing];
{$ENDIF FPC}
  fFiles := TStringList.Create;
  inherited;    // After (ControlInit called after create at runtime)
end;

destructor TOpenDialog.Destroy;
begin
  fFiles.Free;
  inherited;
end;

procedure TOpenDialog.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..6] of PChar = (
    'DefaultExt', 'FileName', 'Filter', 'FilterIndex', 'InitialDir',
    'Options', 'Title');
begin
  case StringIndex(PropName, Properties) of
    0 : fDefaultExt := Reader.StringProperty;
    1 : fFileName := Reader.StringProperty;
    2 : fFilter := Reader.StringProperty;
    3 : fFilterIndex := Reader.IntegerProperty;
    4 : fInitialDir := Reader.StringProperty;
    5 : Reader.SetProperty(fOptions, TypeInfo(TOpenOption));
    6 : fTitle := Reader.StringProperty;
    else inherited;
  end;
end;

procedure TOpenDialog.ControlInit(RuntimeCreate: boolean);
begin
end;

procedure TOpenDialog.ControlCall(var Msg: TMessage); // (Never called)
begin
end;

function TOpenDialog.Execute: boolean;
const   // ofOldStyleDialog, ofViewDetail, ofAutoPreview have no direct equivalence
  SYSTEM_OPTIONS: array[Low(TOpenOption)..High(TOpenOption)] of cardinal = (
    OFN_READONLY, OFN_OVERWRITEPROMPT, OFN_HIDEREADONLY, OFN_NOCHANGEDIR,
    OFN_SHOWHELP, OFN_NOVALIDATE, OFN_ALLOWMULTISELECT, OFN_EXTENSIONDIFFERENT, OFN_PATHMUSTEXIST,
    OFN_FILEMUSTEXIST, OFN_CREATEPROMPT, OFN_SHAREAWARE, OFN_NOREADONLYRETURN, OFN_NOTESTFILECREATE,
    OFN_NONETWORKBUTTON, OFN_NOLONGNAMES, 0, OFN_NODEREFERENCELINKS, OFN_ENABLEINCLUDENOTIFY,
    OFN_ENABLESIZING, OFN_DONTADDTORECENT, OFN_FORCESHOWHIDDEN,
    0, 0 );
var OpenFileName: TOpenFileName;
var OpenStrParam: TOpenStrParam;
var OneOpenOption: TOpenOption;
var MultiPath: string;
var i1, i2: integer;
var s1, s2: string;
begin
  FillChar(OpenFileName, SizeOf(OpenFileName), 0);
  with OpenFileName do
    begin
      lStructSize := SizeOf(OpenFileName);
      if not CheckWin32Version(LLCL_WIN2000_MAJ, LLCL_WIN2000_MIN) then // Or WINVERS_98ME ?
        lStructSize := lStructSize - 8 - SizeOf(Pointer);
      hWndOwner := Parent.Handle;
      hInstance := hInstance;
      if fFilterIndex=0 then fFilterIndex := 1;
      nFilterIndex := fFilterIndex;
      for OneOpenOption := Low(TOpenOption) to High(TOpenOption) do
        if OneOpenOption in fOptions then
          Flags := Flags or SYSTEM_OPTIONS[OneOpenOption];
      Flags := Flags or OFN_EXPLORER;
    end;
  with OpenStrParam do
    begin
      sFilter := CharReplace(fFilter, '|', Chr(0));
      sFileName := fFileName;
      if fInitialDir='' then
        sInitialDir := string(GetCurrentDir())
      else
        sInitialDir := fInitialDir;
      sTitle := fTitle;
      sDefExt := fDefaultExt;
    end;
  result := LLCLS_GetOpenSaveFileName(OpenFileName, integer(ATType=ATTSaveDialog), OpenStrParam);
  if result then
    begin
      fFiles.Clear;
      MultiPath := '';
      s1 := OpenStrParam.sFileName;
      for i1 := 1 to OpenStrParam.NbrFileNames do
        begin
          i2 := Pos('|', s1);
          s2 := Copy(s1, 1, i2-1);
          if (OpenStrParam.NbrFileNames>1) and (i1=1) then
            MultiPath := s2+PathDelim
          else
            begin
              s2 := MultiPath+s2;
              if i1<3 then fFileName := s2;   // if i1=1 (1 file only), or i1=2 (multi select)
              fFiles.Add(s2);
            end;
          s1 := Copy(s1, i2+1, length(s1)-i2);
        end;
    end;
end;

{ TSaveDialog }

constructor TSaveDialog.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTSaveDialog;
end;

{$ifdef LLCL_OPT_USESELECTDIRECTORYDIALOG}
{ TSelectDirectoryDialog }

constructor TSelectDirectoryDialog.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTSelectDirectoryDialog;
end;

function TSelectDirectoryDialog.Execute: boolean;
var sdOptions: TSelectDirExtOpts;
begin
  if ofOldStyleDialog in Options then
    sdOptions := []
  else
    sdOptions := [sdNewFolder, sdShowEdit, sdNewUI];
  result := FC_SelectDirectory(fTitle, fInitialDir, sdOptions, fFileName);
end;
{$endif LLCL_OPT_USESELECTDIRECTORYDIALOG}

//------------------------------------------------------------------------------
{$endif}

{$ifdef LLCL_OPT_USEDIALOG}
initialization
  RegisterClasses([TOpenDialog, TSaveDialog {$ifdef LLCL_OPT_USESELECTDIRECTORYDIALOG}, TSelectDirectoryDialog{$endif}]);
{$endif}

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
