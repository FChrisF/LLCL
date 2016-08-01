unit IniFiles;

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
    * TIniFile implemented
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
  Classes, SysUTils;

type
  // (No intermediate classes used)
  TIniFile = class(TObject)
  private
    fFileName: string;
  public
    constructor Create(const AFileName: string);
    function  ReadString(const Section, Ident, Default: string): string; virtual;
    procedure WriteString(const Section, Ident, Value: string); virtual;
    function  ReadInteger(const Section, Ident: string; Default: integer): integer; virtual;
    procedure WriteInteger(const Section, Ident: string; Value: integer); virtual;
    function  ReadInt64(const Section, Ident: string; Default: int64): int64; virtual;
    procedure WriteInt64(const Section, Ident: string; Value: int64); virtual;
    function  ReadBool(const Section, Ident: string; Default: boolean): boolean; virtual;
    procedure WriteBool(const Section, Ident: string; Value: boolean); virtual;
    // (Caution: string date formating with LLCL SysUtils is specific)
    function  ReadDate(const Section, Ident: string; Default: TDateTime): TDateTime; virtual;
    procedure WriteDate(const Section, Ident: string; Value: TDateTime); virtual;
    procedure DeleteKey(const Section, Ident: string); virtual;
    procedure EraseSection(const Section: string); virtual;
    property  FileName: string read fFileName;
  end;

//------------------------------------------------------------------------------

implementation

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

{ TIniFile }

constructor TIniFile.Create(const AFileName: string);
begin
  inherited Create();
  if ExtractFilePath(AFileName)='' then
    fFileName := '.\' + AFileName
  else
    fFileName := AFileName;
end;

function  TIniFile.ReadString(const Section, Ident, Default: string): string;
begin
  result := LLCLS_INI_ReadString(fFileName, Section, Ident, Default);
end;

procedure TIniFile.WriteString(const Section, Ident, Value: string);
begin
  LLCLS_INI_WriteString(fFileName, Section, Ident, Value);
end;

function  TIniFile.ReadInteger(const Section, Ident: string; Default: integer): integer;
begin
  result := StrToIntDef(ReadString(Section, Ident, ''), Default);
end;

procedure TIniFile.WriteInteger(const Section, Ident: string; Value: integer);
begin
  WriteString(Section, Ident, IntToStr(Value));
end;

function  TIniFile.ReadInt64(const Section, Ident: string; Default: int64): int64;
begin
  result := StrToInt64Def(ReadString(Section, Ident, ''), Default);
end;

procedure TIniFile.WriteInt64(const Section, Ident: string; Value: int64);
begin
  WriteString(Section, Ident, IntToStr(Value));
end;

function  TIniFile.ReadBool(const Section, Ident: string; Default: boolean): boolean;
begin
  result := (ReadInteger(Section, Ident, integer(Default))<>0);
end;

procedure TIniFile.WriteBool(const Section, Ident: string; Value: boolean);
const BoolString: array[boolean] of string = ('0', '1');
begin
  WriteString(Section, Ident, BoolString[Value]);
end;

function  TIniFile.ReadDate(const Section, Ident: string; Default: TDateTime): TDateTime;
begin
  if not TryStrToDate(ReadString(Section, Ident, ''), result) then
    result := Default;
end;

procedure TIniFile.WriteDate(const Section, Ident: string; Value: TDateTime);
begin
  WriteString(Section, Ident, DateToStr(Value));
end;

procedure TIniFile.DeleteKey(const Section, Ident: string);
begin
  LLCLS_INI_Delete(fFileName, @Section[1], @Ident[1]);
end;

procedure TIniFile.EraseSection(const Section: string);
begin
  LLCLS_INI_Delete(fFileName, @Section[1], nil);
end;

//------------------------------------------------------------------------------

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
