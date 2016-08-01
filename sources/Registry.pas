unit Registry;

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
    * File creation.
    * TRegistry implemented
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
  LLCLOSInt, Windows,
  Classes;

type	
  TRegKeyInfo = record
    NumSubKeys: integer;
    MaxSubKeyLen: integer;
    NumValues: integer;
    MaxValueLen: integer;
    MaxDataLen: integer;
    {$IFDEF FPC}
    FileTime: TDateTime;
    {$ELSE FPC}
    FileTime: TFileTime;
    {$ENDIF FPC}
  end;

  TRegDataType = (rdUnknown, rdString, rdExpandString, rdBinary, rdInteger);  // (Keep order)

  TRegDataInfo = record
    RegData: TRegDataType;
    DataSize: integer;
  end;
	
type
  TRegistry = class(TObject)
  private
    fRootKey: HKEY;
    fAccess: longword;
    fCurrentKey: HKEY;
    procedure SetRootKey(Value: HKEY);
    procedure NormKey(const Key: string; var BaseKey: HKEY; var SubKey: string);
    function  OpenCreateKey(const Key: string; CanCreate: boolean; WithAccess: longword; var ResultKey: HKey): boolean;
    function  GetInfosKey(var Value: TRegKeyInfo): boolean;
    procedure GetKeyValueNames(Strings: TStrings; IsForKeys: boolean);
    function  ReadData(const ValueName: string; var DataType: TRegDataType; Data: pointer; var DataSize: integer): boolean;
    procedure WriteData(const ValueName: string; DataType: TRegDataType; Data: pointer; DataSize: integer);
  public
    constructor Create; overload;
    destructor Destroy; override;
    function  OpenKey(const Key: string; CanCreate: boolean): boolean;
    function  OpenKeyReadOnly(const Key: String): boolean;
    function  CreateKey(const Key: string): boolean;
    function  DeleteKey(const Key: string): boolean;
    procedure CloseKey;
    function  KeyExists(const Key: string): boolean;
    function  GetKeyInfo(var Value: TRegKeyInfo): boolean;
    procedure GetKeyNames(Strings: TStrings);
    function  ValueExists(const Name: string): boolean;
    function  GetDataInfo(const ValueName: string; var Value: TRegDataInfo): boolean;
    procedure GetValueNames(Strings: TStrings);
    function  DeleteValue(const Name: string): boolean;
    function  ReadString(const Name: string): string;
    procedure WriteString(const Name, Value: string);
    function  ReadInteger(const Name: string): integer;
    procedure WriteInteger(const Name: string; Value: integer);
    function  ReadBool(const Name: string): boolean;
    procedure WriteBool(const Name: string; Value: boolean);
    function  ReadDate(const Name: string): TDateTime;
    procedure WriteDate(const Name: string; Value: TDateTime);
    function  ReadBinaryData(const Name: string; var Buffer; BufSize: integer): integer;
    procedure WriteBinaryData(const Name: string; var Buffer; BufSize: integer);
    property  Access: longword read fAccess write fAccess;
    property  CurrentKey: HKEY read fCurrentKey;
    property  RootKey: HKEY read fRootKey write SetRootKey;
  end;

//------------------------------------------------------------------------------

implementation

uses
  SysUtils;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

{$IFNDEF FPC}
const
  KEY_WOW64_64KEY       = $0100;        // Absent in old versions of Delphi
  KEY_WOW64_32KEY       = $0200;        //
{$ENDIF}

//------------------------------------------------------------------------------

{ TRegistry }

constructor TRegistry.Create;
begin
  inherited;
  fRootKey := HKEY_CURRENT_USER;
  fAccess := KEY_ALL_ACCESS;
  fCurrentKey := 0;
end;

destructor TRegistry.Destroy;
begin
  CloseKey;
  inherited;
end;

procedure TRegistry.SetRootKey(Value: HKEY);
begin
  if fRootKey<>Value then
    begin
      CloseKey;
      fRootKey := Value;
    end;
end;

procedure TRegistry.NormKey(const Key: string; var BaseKey: HKEY; var SubKey: string);
begin
  if Pos('\', Key)=1 then
    begin
      SubKey := Copy(Key, 2, length(Key) - 1);
      BaseKey := fRootKey;
    end
  else
    begin
      SubKey := Key;
      if fCurrentKey=0 then
        BaseKey := fRootKey
      else
        BaseKey := fCurrentKey;
    end;
end;

function  TRegistry.OpenCreateKey(const Key: string; CanCreate: boolean; WithAccess: longword; var ResultKey: HKey): boolean;
var BaseKey: HKEY;
var SubKey: string;
var Disposition: longword;
begin
  NormKey(Key, BaseKey, SubKey);
  if CanCreate then
    result := (LLCLS_REG_RegCreateKeyEx(BaseKey, SubKey, 0, nil, REG_OPTION_NON_VOLATILE,
                KEY_ALL_ACCESS, nil, ResultKey, @Disposition) = 0)
  else
    result := (LLCLS_REG_RegOpenKeyEx(BaseKey, SubKey, 0, WithAccess, ResultKey) = 0);
end;

function  TRegistry.GetInfosKey(var Value: TRegKeyInfo): boolean;
{$IFDEF FPC}
var TmpFileTime: TFileTime;
var TmpSystemTime: TSystemTime;
  {$ENDIF}
begin
	FillChar(Value, SizeOf(Value), 0);
{$IFDEF FPC}
  result := (LLCLS_REG_RegQueryInfoKey(fCurrentKey, nil, nil, nil, @Value.NumSubKeys, @Value.MaxSubKeyLen,
						  nil, @Value.NumValues, @Value.MaxValueLen, @Value.MaxDataLen, nil, @TmpFileTime) = 0);
	if result then
		if LLCL_FileTimeToSystemTime(TmpFileTime, TmpSystemTime) then
			Value.FileTime := SystemTimeToDateTime(TmpSystemTime);
{$ELSE FPC}
  result := (LLCLS_REG_RegQueryInfoKey(fCurrentKey, nil, nil, nil, @Value.NumSubKeys, @Value.MaxSubKeyLen,
					    nil, @Value.NumValues, @Value.MaxValueLen, @Value.MaxDataLen, nil, @Value.FileTime) = 0);
{$ENDIF}
end;

procedure TRegistry.GetKeyValueNames(Strings: TStrings; IsForKeys: boolean);
var InfosKey: TRegKeyInfo;
var Len: integer;
var s: string;
var i, j, k, l: integer;
begin
	Strings.Clear;
	if GetInfosKey(InfosKey) then
		begin
			if IsForKeys then
				begin
					k := InfosKey.MaxSubKeyLen;
					j := InfosKey.NumSubKeys;
				end
			else
				begin
					k := InfosKey.MaxValueLen;
					j := InfosKey.NumValues;
				end;
			Inc(k);
			SetLength(S, k);
			for i := 0 to (j - 1) do
				begin
					Len := k;
					if IsForKeys then
						l := LLCLS_REG_RegEnumKeyEx(fCurrentKey, i, s, @Len, nil, nil, nil, nil)
					else
						l := LLCLS_REG_RegEnumValue(fCurrentKey, i, s, @Len, nil, nil, nil, nil);
          if l=0 then
					  Strings.Add(s);
				end;
		end;
end;

function  TRegistry.ReadData(const ValueName: string; var DataType: TRegDataType; Data: pointer; var DataSize: integer): boolean;
begin
  DataType := rdUnknown;
  result := (LLCLS_REG_RegQueryValueEx(fCurrentKey, ValueName, nil, @DataType, Data, @DataSize) = 0);
end;

procedure TRegistry.WriteData(const ValueName: string; DataType: TRegDataType; Data: pointer; DataSize: integer);
begin
  if LLCLS_REG_RegSetValueEx(fCurrentKey, ValueName, 0, longword(DataType), Data, DataSize)<>0 then
    raise Exception.CreateFmt(LLCL_STR_REGI_WRITEDATAERR, [ValueName]);
end;

procedure TRegistry.CloseKey;
begin
  if fCurrentKey<>0 then
    LLCL_RegCloseKey(fCurrentKey);
  fCurrentKey := 0;
end;

function  TRegistry.OpenKey(const Key: string; CanCreate: boolean): boolean;
var RKey: HKEY;
begin
  result := OpenCreateKey(Key, CanCreate, fAccess, RKey);
  if result and (RKey<>fCurrentKey) then
    begin
      CloseKey;
      fCurrentKey := RKey;
    end;
end;

function  TRegistry.OpenKeyReadOnly(const Key: String): boolean;
var SaveAccess: longword;
begin
  SaveAccess := fAccess;
  fAccess := KEY_READ or (SaveAccess and (KEY_WOW64_64KEY or KEY_WOW64_32KEY));	// Old versions of Delphi don't have KEY_WOW64_xxxx
  result := OpenKey(Key, false);
  fAccess := SaveAccess;
end;

function  TRegistry.CreateKey(const Key: string): boolean;
var RKey: HKEY;
begin
  result := OpenCreateKey(Key, true, 0, RKey);    // Access not used for creation
  if result then
    LLCL_RegCloseKey(RKey)
  else
    raise Exception.CreateFmt(LLCL_STR_REGI_CREATEKEYERR, [Key]);
end;

function  TRegistry.DeleteKey(const Key: string): boolean;
var BaseKey: HKEY;
var SubKey: string;
begin
  NormKey(Key, BaseKey, SubKey);
  result := (LLCLS_REG_RegDeleteKey(BaseKey, SubKey) = 0);
end;

function  TRegistry.KeyExists(const Key: string): boolean;
var RKey: HKEY;
begin
  result := OpenCreateKey(Key, false, STANDARD_RIGHTS_READ or KEY_QUERY_VALUE or KEY_ENUMERATE_SUB_KEYS
             or (fAccess and (KEY_WOW64_64KEY or KEY_WOW64_32KEY)), RKey);			// Old versions of Delphi don't have KEY_WOW64_xxxx
  if result then
    LLCL_RegCloseKey(RKey);
end;

function  TRegistry.GetKeyInfo(var Value: TRegKeyInfo): boolean;
begin
	result := GetInfosKey(Value);
end;

procedure TRegistry.GetKeyNames(Strings: TStrings);
begin
	GetKeyValueNames(Strings, true);
end;

function  TRegistry.ValueExists(const Name: string): boolean;
var DummyRDI: TRegDataInfo;
begin
	result := GetDataInfo(Name, DummyRDI);
end;

function  TRegistry.GetDataInfo(const ValueName: string; var Value: TRegDataInfo): boolean;
begin
	FillChar(Value, SizeOf(Value), 0);
	result := (LLCLS_REG_RegQueryValueEx(fCurrentKey, ValueName, nil, @Value.RegData, nil, @Value.DataSize) = 0);
end;

procedure TRegistry.GetValueNames(Strings: TStrings);
begin
	GetKeyValueNames(Strings, false);
end;

function  TRegistry.DeleteValue(const Name: string): boolean;
begin
  result := (LLCLS_REG_RegDeleteValue(fCurrentKey, Name) = 0);
end;

function  TRegistry.ReadString(const Name: string): string;
var DataType: TRegDataType;
begin
  DataType := rdUnknown;
  if not ((LLCLS_REG_RegQueryStringValue(fCurrentKey, Name, @DataType, result) = 0) and (DataType in [rdString,rdExpandString])) then
    raise Exception.CreateFmt(LLCL_STR_REGI_READDATAERR, [Name]);
end;

procedure TRegistry.WriteString(const Name, Value: string);
var pData: pointer;
var Len: cardinal;
begin
  pData := LLCLS_REG_SetTextPtr(Value, Len);
  WriteData(Name, rdString, pData, Len);
  FreeMem(pData);
end;

function  TRegistry.ReadInteger(const Name: string): integer;
var InfosData: TRegDataInfo;
begin
  InfosData.DataSize := SizeOf(integer);
  if not (ReadData(Name, InfosData.RegData, @result, InfosData.DataSize) and (InfosData.RegData=rdInteger)) then
    raise Exception.CreateFmt(LLCL_STR_REGI_READDATAERR, [Name]);
end;

procedure TRegistry.WriteInteger(const Name: string; Value: integer);
begin
  WriteData(Name, rdInteger, @Value, SizeOf(integer));
end;

function  TRegistry.ReadBool(const Name: string): boolean;
begin
  result := (ReadInteger(Name)<>0);
end;

procedure TRegistry.WriteBool(const Name: string; Value: boolean);
begin
  WriteInteger(Name, ord(Value));
end;

function  TRegistry.ReadDate(const Name: string): TDateTime;
begin
  ReadBinaryData(Name, result, SizeOf(TDateTime));
end;

procedure TRegistry.WriteDate(const Name: string; Value: TDateTime);
begin
  WriteBinaryData(Name, Value, SizeOf(TDateTime));
end;

function  TRegistry.ReadBinaryData(const Name: string; var Buffer; BufSize: integer): integer;
var DataType: TRegDataType;
begin
  result := BufSize;
  if not (ReadData(Name, DataType, @Buffer, result) and (DataType=rdBinary)) then
    raise Exception.CreateFmt(LLCL_STR_REGI_READDATAERR, [Name]);
end;

procedure TRegistry.WriteBinaryData(const Name: string; var Buffer; BufSize: integer);
begin
  WriteData(Name, rdBinary, @Buffer, BufSize);
end;

//------------------------------------------------------------------------------

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
