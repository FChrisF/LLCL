unit SysUtils;

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
    * DeleteFile and RenameFile added
   Version 1.01:
    * Some (irrelevant) Kylix code removed
    * StrToInt64/StrToInt64Def/TryStrToInt64 added
    * TryStrToDate/TryStrToTime added
   Version 1.00:
    * FPC/Lazarus part doesn't use any asm code
    * CheckWin32Version added
    * Warning: Kylix compatibility broken
}

// Original notes from LVCL

{
         LVCL - Very LIGHT VCL
         ----------------------------

   Tiny replacement for the standard VCL SysUtils.pas
   Just put the LVCL directory in your Project/Options/Directories/SearchPath
   and your .EXE will shrink from 300KB to 30KB

   Notes:
   - Some routines are improved/faster: EncodeDate, DecodeDate, DecodeTime,
      IntToStr, HexToStr, UpperCase, CompareText, StrCopy, StrLen, StrComp,
      FileExists, CompareMem...
   - Date strings have a fixed format: 'YYYY/MM/DD hh:mm:ss'
   - format() supports quite all usual format (%% %s %d %x %.prec? %index:?),
      but without floating point args (saves 3KB on EXE size -> use str() + %s)
   - slow MBCS Ansi*() function mostly removed
   - support Win NT 4.0 and Win95 OSR2 minimum
   - Cross-Platform: this SysUtils unit can be used on (Cross)Kylix under Linux

  The contents of this file are subject to the Mozilla Public License
  Version 1.1 (the "License"); you may not use this file except in
  compliance with the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL

  Software distributed under the License is distributed on an "AS IS"
  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
  License for the specific language governing rights and limitations
  under the License.

  The Initial Developer of the Original Code is Arnaud Bouchez.
  This work is Copyright (c)2008 Arnaud Bouchez - http://bouchez.info
  Emulates the original Delphi/Kylix Cross-Platform Runtime Library
  (c)2000,2001 Borland Software Corporation
  Portions created by Paul Toth are (c)2001 Paul Toth - http://tothpaul.free.fr
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
  LLCLOSInt,
{$ifdef MSWindows}
  Windows;
{$else}
  Types, LibC;
{$endif}

{$IFDEF FPC}
  {$I LLCLFPCInc.inc}   // (for LLCL_FPC_SYSRTL, LLCL_FPC_UNISYS)
{$ENDIF FPC}

type
  Exception = class(TObject)
  private
    FMessage: string;
  public
    constructor Create(const Msg: string);
    constructor CreateFmt(const Msg: string; const Args: array of const);
    property Message: string read FMessage write FMessage;
  end;
  EAssertionFailed = class(Exception);
  EStreamError = class(Exception);
  EExternal  = class(Exception);
  EExternalException = class(EExternal);
  EIntError = class(EExternal);
  EDivByZero = class(EIntError);
  ERangeError = class(EIntError);
  EIntOverflow = class(EIntError);
  EMathError = class(EExternal);
  EInvalidOp = class(EMathError);
  EZeroDivide = class(EMathError);
  EOverflow = class(EMathError);
  EUnderflow = class(EMathError);
  EAccessViolation = class(EExternal);
  ExceptClass = class of Exception;
  EAbort = class(Exception);
  EOSError = class(EExternal)
  public
    ErrorCode: cardinal;
  end;
  EInOutError = class(Exception)
  public
    ErrorCode: integer;
  end;
  EConvertError = class(Exception);

  LongRec = packed record
    case integer of
      0: (Lo, Hi: word);
      1: (Words: array [0..1] of word);
      2: (Bytes: array [0..3] of byte);
  end;
  Int64Rec = packed record
    case integer of
      0: (Lo, Hi: cardinal);
      1: (Cardinals: array [0..1] of cardinal);
      2: (Words: array [0..3] of word);
      3: (Bytes: array [0..7] of byte);
  end;

  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of byte;
  PWordArray = ^TWordArray;
  TWordArray = array[0..32767] of word;

  TSysCharSet = set of AnsiChar;
{$if Defined(UNICODE) and not Defined(FPC)} // Delphi Unicode only
  TBytes = TArray<byte>;
{$else}
  TBytes = array of byte;
{$ifend}

  TFileName = type string;

type
  PDayTable = ^TDayTable;
  TDayTable = array[1..12] of word;
  TTimeStamp = record
    Time: integer;      { Number of milliseconds since midnight }
    Date: integer;      { One plus number of days since 1/1/0001 }
  end;

{$IFDEF LLCL_FPC_UNISYS}
type
  TUnicodeSearchRec = record
    Time: integer;
    Size: int64;
    Attr: integer;
    Name: unicodestring;
    ExcludeAttr: integer;
    FindHandle: THandle;
    FindData: TCustomWin32FindData;
  end;
type
  TRawByteSearchRec = record
    Time: integer;
    Size: int64;
    Attr: integer;
    Name: rawbytestring;
    ExcludeAttr: integer;
    FindHandle: THandle;
    FindData: TCustomWin32FindData;
  end;
{$IFDEF FPC_UNICODE_RTL}
type
  TSearchRec = TUnicodeSearchRec;
{$ELSE}
type
  TSearchRec = TRawByteSearchRec;
{$ENDIF}
{$ELSE LLCL_FPC_UNISYS}
type
  TSearchRec = record
    Time: integer;
{$IFDEF FPC}
    Size: int64;
{$ELSE}
    {$if (CompilerVersion < 18)}   // Before Delphi 2006
    Size: integer;
    {$else}
    Size: int64;
    {$ifend}
{$ENDIF}
    Attr: integer;
    Name: TFileName;
    ExcludeAttr: integer;
{$ifdef MSWindows}
    FindHandle: THandle;
    FindData: TCustomWin32FindData;
{$else}
    Mode: mode_t;
    FindHandle: pointer;
    PathOnly: string;
    Pattern: string;
{$endif}
  end;
{$ENDIF LLCL_FPC_UNISYS}

const
  MonthDays: array[boolean] of TDayTable =
    ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
     (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));

  HoursPerDay       = 24;
  MinsPerHour       = 60;
  SecsPerMin        = 60;
  MSecsPerSec       = 1000;
  MinsPerDay        = HoursPerDay * MinsPerHour;
  SecsPerDay        = MinsPerDay * SecsPerMin;
  MSecsPerDay       = SecsPerDay * MSecsPerSec;

  DateDelta         = 693594;
  UnixDateDelta     = 25569;

const
  faReadOnly        = $00000001;
  faHidden          = $00000002;
  faSysFile         = $00000004;
  faVolumeID        = $00000008;
  faDirectory       = $00000010;
  faArchive         = $00000020;
  faSymLink         = $00000040;
  faAnyFile         = $0000003F;
  { File open modes }
{$ifdef MSWindows}
  fmOpenRead        = $0000;
  fmOpenWrite       = $0001;
  fmOpenReadWrite   = $0002;
  fmShareCompat     = $0000;
  fmShareExclusive  = $0010;
  fmShareDenyWrite  = $0020;
  fmShareDenyRead   = $0030;
  fmShareDenyNone   = $0040;

const
  PathDelim  = '\';
  DriveDelim = ':';
  PathSep    = ';';
{$else}   // Linux
  fmOpenRead        = O_RDONLY;
  fmOpenWrite       = O_WRONLY;
  fmOpenReadWrite   = O_RDWR;
//  fmShareCompat not supported
  fmShareExclusive  = $0010;
  fmShareDenyWrite  = $0020;
//  fmShareDenyRead not supported
  fmShareDenyNone   = $0030;

const
  PathDelim  = '/';
  DriveDelim = '';
  PathSep    = ':';
{$endif}  // End of Linux

function  Format(const sFormat: string; const Args: array of const): string;
// supported: %% %s %d %x %.prec? %index:?

function  IntToStr(Value: integer): string; overload;
function  IntToStr(Value: int64): string; overload;
function  IntToHex(Value: integer; Digits: integer): string; overload;
function  IntToHex(Value: int64; Digits: integer): string; overload;
function  StrToInt(const S: string): integer;
function  StrToIntDef(const S: string; Default: integer): integer;
function  TryStrToInt(const S: string; out Value: integer): boolean;
function  StrToInt64(const S: string): int64;
function  StrToInt64Def(const S: string; Default: int64): int64;
function  TryStrToInt64(const S: string; out Value: int64): boolean;
function  GUIDToString(const GUID: TGUID): string;

{$if (not Defined(FPC)) or (not Defined(UNICODE))}  // Delphi, or FPC/Lazarus non Unicode
function  StrLCopy(Dest: PChar; const Source: PChar; MaxLen: cardinal): PChar;
{$if Defined(UNICODE) and not Defined(FPC)} // Delphi Unicode only
function  StrLen(const Str: PAnsiChar): integer; overload;
{$ifend}
function  StrEnd(const Str: PChar): PChar;
function  StrCopy(Dest: PChar; const Source: PChar): PChar;
function  StrCat(Dest: PChar; const Source: PChar): PChar;
function  StrPCopy(Dest: PChar; const Source: string): PChar;
function  StrScan(const Str: PChar; Chr: Char): PChar;
{$ifend}
function  StrComp(const Str1, Str2: PChar): integer;
function  StrIComp(const Str1, Str2: PChar): integer;
function  StrLen(const Str: PChar): integer; overload;

type
  TReplaceFlags = set of (rfReplaceAll, rfIgnoreCase);

function  StringReplace(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;

function  CompareText(const S1, S2: string): integer;
function  SameText(const S1, S2: string): boolean;
function  CompareStr(const S1, S2: string): integer;
function  UpperCase(const S: string): string;
function  LowerCase(const S: string): string;
function  Trim(const S: string): string; overload;
function  TrimLeft(const S: string): string; overload;
function  TrimRight(const S: string): string; overload;
{$if Defined(UNICODE) and not Defined(FPC)} // Delphi Unicode only
function  Trim(const S: ansistring): ansistring; overload;
function  TrimLeft(const S: ansistring): ansistring; overload;
function  TrimRight(const S: ansistring): ansistring; overload;
{$ifend}
function  QuotedStr(const S: string): string;

{$if (not Defined(FPC)) or (not Defined(UNICODE))}  // Delphi, or FPC/Lazarus non Unicode
function  AnsiStrScan(Str: PChar; Chr: Char): PChar;
function  AnsiQuotedStr(const S: string; Quote: Char): string;
function  AnsiExtractQuotedStr(var Src: PChar; Quote: Char): string;
function  AnsiDequotedStr(const S: string; AQuote: Char): string;
{$ifend}

// (Ansi versions deal with string, not ansistring)
function  AnsiCompareText(const S1, S2: string): integer;
function  AnsiSameText(const S1, S2: string): boolean;
function  AnsiCompareStr(const S1, S2: string): integer;
function  AnsiSameStr(const S1, S2: string): boolean;
function  AnsiUpperCase(const S: string): string;
function  AnsiLowerCase(const S: string): string;
// (Wide versions don't work with non Unicode versions of Windows)
function  WideCompareText(const S1, S2: widestring): integer;
function  WideSameText(const S1, S2: widestring): boolean;
function  WideCompareStr(const S1, S2: widestring): integer;
function  WideSameStr(const S1, S2: widestring): boolean;
function  WideUpperCase(const S: widestring): widestring;
function  WideLowerCase(const S: widestring): widestring;

procedure DecodeDate({$IFDEF FPC}{$ELSE}const {$ENDIF}DateTime: TDateTime; var Year, Month, Day: word);
function  EncodeDate(Year, Month, Day: word): TDateTime;
function  IsLeapYear(Year: word): boolean;
procedure DecodeTime({$IFDEF FPC}{$ELSE}const {$ENDIF}DateTime: TDateTime; var Hour, Min, Sec, MSec: word);
function  EncodeTime(Hour, Min, Sec, MSec: word): TDateTime;
function  TryEncodeDate(Year, Month, Day: word; out Date: TDateTime): boolean;
function  TryEncodeTime(Hour, Min, Sec, MSec: word; out Time: TDateTime): boolean;
function  FileDateToDateTime(FileDate: integer): TDateTime;
function  DateTimeToFileDate({$IFDEF FPC}{$ELSE}const {$ENDIF}DateTime: TDateTime): integer;
function  DateTimeToTimeStamp(DateTime: TDateTime): TTimeStamp;
function  TimeStampToDateTime(const TimeStamp: TTimeStamp): TDateTime;
function  DayOfWeek(const DateTime: TDateTime): {$IFDEF FPC}integer{$ELSE}word{$ENDIF};
function  Now: TDateTime;
function  Date: TDateTime;
function  Time: TDateTime;
{$ifdef MSWindows}
procedure DateTimeToSystemTime({$IFDEF FPC}{$ELSE}const {$ENDIF}DateTime: TDateTime; var SystemTime: TSystemTime);
function  SystemTimeToDateTime(const SystemTime: TSystemTime): TDateTime;
function  TrySystemTimeToDateTime(const SystemTime: TSystemTime; out DateTime: TDateTime): boolean;
{$endif}
function  DateTimeToStr(const DateTime: TDateTime): string;
function  DateToStr(const DateTime: TDateTime): string;
function  TimeToStr(const DateTime: TDateTime): string;
function  TryStrToDate(const S: string; out Value: TDateTime): boolean;
function  TryStrToTime(const S: string; out Value: TDateTime): boolean;
function  TryStrToDateTime(const S: string; out Value: TDateTime): boolean;

function  FileCreate(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): THandle; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  FileOpen(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; Mode: cardinal): THandle; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
procedure FileClose(Handle: THandle);
function  FileSeek(Handle: THandle; Offset, Origin: integer): integer; overload;
function  FileSeek(Handle: THandle; Offset: int64; Origin: integer): int64; overload;
function  FileRead(Handle: THandle; var Buffer; Count: cardinal): integer;
function  FileWrite(Handle: THandle; const Buffer; Count: cardinal): integer;
function  FileExists(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  FileGetDate(Handle: THandle): integer;
function  FileSetDate(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; Age: integer): integer; overload;
function  FileAge(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): integer; overload;
{$ifdef MSWindows}
function  FileSetDate(Handle: THandle; Age: integer): integer; overload;
function  FileAge(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; out FileDateTime: TDateTime): boolean; overload;
function  GetFileVersion(const aFileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): cardinal; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}  // (Only a string version in LCL)
function  DeleteFile(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  RenameFile(const OldName, NewName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
{$endif}

function  FindFirst(const Path: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; Attr: integer; var F: {$IFDEF LLCL_FPC_UNISYS}TUnicodeSearchRec{$ELSE}TSearchRec{$ENDIF}): integer; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  FindNext(var F: {$IFDEF LLCL_FPC_UNISYS}TUnicodeSearchRec{$ELSE}TSearchRec{$ENDIF}): integer; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
procedure FindClose(var F: {$IFDEF LLCL_FPC_UNISYS}TUnicodeSearchRec{$ELSE}TSearchRec{$ENDIF}); {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}

function  GetCurrentDir: {$IFDEF FPC_UNICODE_RTL}unicodestring{$ELSE}{$IFDEF LLCL_FPC_CPSTRING}rawbytestring{$ELSE}string{$ENDIF}{$ENDIF};
function  SetCurrentDir(const NewDir: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  DirectoryExists(const Directory: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  ForceDirectories({$IFDEF FPC}const {$ENDIF}Dir: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  CreateDir(const Dir: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  RemoveDir(const Dir: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}

function  ExtractFilePath(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  ExtractFileDir(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  ExtractFileName(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  ExtractFileExt(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  ExtractFileDrive(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  ChangeFileExt(const FileName, Extension: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  LastDelimiter(const Delimiters, S: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): integer; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}  // (Only a string version in LCL)
function  IsPathDelimiter(const S: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; Index: integer): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  IncludeTrailingPathDelimiter(const S: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  ExcludeTrailingPathDelimiter(const S: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}

{$ifdef MSWindows}
function  ExpandFileName(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
function  GetModuleName(Module: HMODULE): {$IFDEF FPC_UNICODE_RTL}unicodestring{$ELSE}{$IFDEF LLCL_FPC_CPSTRING}rawbytestring{$ELSE}string{$ENDIF}{$ENDIF}; // (String version and Ansi API in LCL)
function  DiskFree(Drive: byte): int64;
function  DiskSize(Drive: byte): int64;
{$endif}

procedure OutOfMemoryError;
function  SysErrorMessage(ErrorCode: integer): {$IFDEF FPC_UNICODE_RTL}unicodestring{$ELSE}{$IFDEF LLCL_FPC_CPSTRING}rawbytestring{$ELSE}string{$ENDIF}{$ENDIF};  // (String version and Ansi API in LCL)
procedure RaiseLastOSError;
procedure Abort;

procedure Sleep(milliseconds: cardinal);
procedure Beep;

procedure FreeAndNil(var obj);
function  AllocMem(Size: nativeuint): pointer;
function  CompareMem(P1, P2: pointer; Length: integer): boolean;

{$ifdef MSWindows}
function  SafeLoadLibrary(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; ErrorMode: UINT = SEM_NOOPENFILEERRORBOX): HMODULE; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF} // (Only a string version in LCL)

function  CheckWin32Version(aMajor: integer; aMinor: integer = 0): boolean;

var
  Win32Platform:      integer = 0;
  Win32MajorVersion:  integer = 0;
  Win32MinorVersion:  integer = 0;
  Win32BuildNumber:   integer = 0;
  Win32CSDVersion:    string = '';
{$else}
function  GetLastError: integer;
{$endif}

{$IFDEF LLCL_FPC_UNISYS}
// RawByteString version
function  FileCreate(const FileName: rawbytestring): THandle; overload;
function  FileOpen(const FileName: rawbytestring; Mode: cardinal): THandle; overload;
function  FileExists(const FileName: rawbytestring): boolean; overload;
function  FileSetDate(const FileName: rawbytestring; Age: integer): integer; overload;
function  FileAge(const FileName: rawbytestring): integer; overload;
function  FileAge(const FileName: rawbytestring; out FileDateTime: TDateTime): boolean; overload;
function  GetFileVersion(const aFileName: rawbytestring): cardinal; overload; // (Only a string version in LCL)
function  DeleteFile(const FileName: rawbytestring): boolean; overload;
function  RenameFile(const OldName, NewName: rawbytestring): boolean; overload;

function  FindFirst(const Path: rawbytestring; Attr: integer; var F: TRawByteSearchRec): integer; overload;
function  FindNext(var F: TRawByteSearchRec): integer; overload;
procedure FindClose(var F: TRawByteSearchRec); overload;

function  SetCurrentDir(const NewDir: rawbytestring): boolean; overload;
function  DirectoryExists(const Directory: rawbytestring): boolean; overload;
function  ForceDirectories(const Dir: rawbytestring): boolean; overload;
function  CreateDir(const Dir: rawbytestring): boolean; overload;
function  RemoveDir(const Dir: rawbytestring): boolean; overload;

function  ExtractFilePath(const FileName: rawbytestring): rawbytestring; overload;
function  ExtractFileDir(const FileName: rawbytestring): rawbytestring; overload;
function  ExtractFileName(const FileName: rawbytestring): rawbytestring; overload;
function  ExtractFileExt(const FileName: rawbytestring): rawbytestring; overload;
function  ExtractFileDrive(const FileName: rawbytestring): rawbytestring; overload;
function  ChangeFileExt(const FileName, Extension: rawbytestring): rawbytestring; overload;
function  LastDelimiter(const Delimiters, S: rawbytestring): integer; overload; // (Only a string version in LCL)
function  IsPathDelimiter(const S: rawbytestring; Index: integer): boolean; overload;
function  IncludeTrailingPathDelimiter(const S: rawbytestring): rawbytestring; overload;
function  ExcludeTrailingPathDelimiter(const S: rawbytestring): rawbytestring; overload;
{$ifdef MSWindows}
function  ExpandFileName(const FileName: rawbytestring): rawbytestring; overload;
function  SafeLoadLibrary(const FileName: rawbytestring; ErrorMode: UINT = SEM_NOOPENFILEERRORBOX): HMODULE; overload;  // (Only a string version in LCL)
{$endif}
{$ENDIF LLCL_FPC_UNISYS}

//------------------------------------------------------------------------------

implementation

{$if Defined(FPC) and not Defined(UNICODE)} // FPC/Lazarus non Unicode only
uses
  Strings;
{$ifend}

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

const
  HexChars: array[0..15] of Char = '0123456789ABCDEF';
  SYSLLCL_TIME_SEP      = ':';
  SYSLLCL_DATE_SEP      = '/';
  SYSLLCL_DATETIME_SEP  = ' ';

{$IFNDEF FPC}
  // our customs SysUtils.pas (normal and LVCL) contains the same array
  TwoDigitLookup: packed array[0..99] of array[1..2] of AnsiChar =
    ('00','01','02','03','04','05','06','07','08','09',
     '10','11','12','13','14','15','16','17','18','19',
     '20','21','22','23','24','25','26','27','28','29',
     '30','31','32','33','34','35','36','37','38','39',
     '40','41','42','43','44','45','46','47','48','49',
     '50','51','52','53','54','55','56','57','58','59',
     '60','61','62','63','64','65','66','67','68','69',
     '70','71','72','73','74','75','76','77','78','79',
     '80','81','82','83','84','85','86','87','88','89',
     '90','91','92','93','94','95','96','97','98','99');

  FMSecsPerDay: single = MSecsPerDay;
  IMSecsPerDay: integer = MSecsPerDay;
{$ENDIF NFPC}

procedure UpperLower(Source, Dest: PChar; L: cardinal; Upper: boolean); forward;
function  SysAddDatePlusTime(const BaseDate: TDateTime; const PlusTime: TDateTime): TDateTime; forward;
function  SysCurrDT(WithDate, WithTime: boolean): TDateTime; forward;
function  SysDTToStr(const DateTime: TDateTime; WithDate, WithTime: boolean): string; forward;
function  SysFileAttributes(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; var LastWriteTime: TFileTime): boolean; forward;

function  FindMatchingFile(var F: {$IFDEF LLCL_FPC_UNISYS}TUnicodeSearchRec{$ELSE}TSearchRec{$ENDIF}): integer; forward;
function  InternalFileOpen(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; Mode: cardinal; var LastOSError: cardinal): THandle; forward;
function  InternalFileAge(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; var LastWriteTime: TFileTime): boolean; forward;
function  InternalGetDiskSpace(Drive: byte; var TotalSpace, FreeSpaceAvailable: int64): bool; forward;

{$IFDEF LLCL_FPC_UNISYS}
procedure FindSearchRecRawToUni(const F: TRawByteSearchRec; var FF: TUnicodeSearchRec); forward;
procedure FindSearchRecUniToRaw(const F: TUnicodeSearchRec; var FF: TRawByteSearchRec); forward;
{$ENDIF LLCL_FPC_UNISYS}

{$ifdef LLCL_OPT_EXCEPTIONS}
{$IFDEF FPC}
procedure ExceptHandler(ExceptObject: TObject; ExceptAddr: pointer; FrameCount: longint; Frames: PPointer); forward;
procedure ErrorHandler(ErrorCode: integer; ErrorAddr, Frame: pointer); forward;
procedure AssertErrorHandler(const aMessage, aFilename: shortstring; aLineNumber: longint; aErrorAddr: pointer); forward;
{$ELSE FPC}
procedure ExceptHandler(ExceptObject: TObject; ExceptAddr: pointer); far; forward;
procedure ErrorHandler(ErrorCode: integer; ErrorAddr: pointer); forward;
procedure AssertErrorHandler(const aMessage, aFilename: string; aLineNumber: integer; aErrorAddr: pointer); forward;

var OldErrorMode: cardinal;
{$ENDIF FPC}
{$endif}

//------------------------------------------------------------------------------

function  Format(const sFormat: string; const Args: array of const): string;
// supported: %% %s %d %x %.prec? %index:?
var i, j, c, L: integer;
    decim: string;
begin
  if high(Args)<0 then begin
    result := sFormat;
    exit;
  end;
  result := '';
  L := length(sFormat);
  if L=0 then exit;
  i := 1;
  c := 0;
  while (i<=L) do begin
    j := i;
    while (i<=L) and (sFormat[i]<>'%') do Inc(i);
    case i-j of
      0: ;
      1: result := result+sFormat[j];
      else result := result+copy(sFormat, j, i-j);
    end;
    Inc(i);
    if i>L then break;
    if (ord(sFormat[i]) in [ord('0')..ord('9')]) and (i<L) and
       (sFormat[i+1]=':') then begin
      c := ord(sFormat[i])-48;  // Format('%d %d %d %0:d %d',[1,2,3,4]) = '1 2 3 1 2'
      Inc(i, 2);
      if i>L then break;
    end;
    if sFormat[i]='%' then        // Format('%%') = '%'
      result := result+'%' else   // Format('%.3d',[4]) = '004':
    if (sFormat[i]='.') and (i+2<=L) and (c<=high(Args)) and
       (ord(sFormat[i+1]) in [ord('1')..ord('9')]) and
       (ord(sFormat[i+2]) in [ord('d'),ord('x'),ord('p')]) and
       (Args[c].VType=vtInteger) then begin
      j := Args[c].VInteger;
      if sFormat[i+2]='d' then
        decim := IntToStr(j) else
        decim := IntToHex(j, ord(sFormat[i+1])-49);
      for j := length(decim) to ord(sFormat[i+1])-49 do
        decim := '0'+decim;
      result := result+decim;
      Inc(c);
      Inc(i, 2);
    end else
    if c<=high(Args) then begin
      with Args[c] do
      case sFormat[i] of
      's': case VType of
        vtString:     result := result+string(VString^);
        vtAnsiString: result := result+string(VAnsiString);
        vtPChar:     result := result+string(VPChar);
        vtChar:      result := result+string(VChar);
        vtPWideChar: result := result+string(VPWideChar);
        vtWideChar:  result := result+string(VWideChar);
{$ifdef UNICODE}
        vtUnicodeString: result := result+string(VUnicodeString);
{$endif}
      end;
{      'g','f','n','m': case VType of
      vtExtended: begin
         str(VExtended^,decim);
         result := result+decim;
       end;
       vtCurrency: begin
         str(VCurrency^,decim);
         result := result+decim;
       end;
       end;  // add 3kb to the .exe -> use str() and %s parameter }
      'd': if VType=vtInteger then
             result := result+IntToStr(VInteger) else
           if VType=vtInt64 then
             result := result+IntToStr(VInt64^);
      'x','p': if VType in [vtInteger,vtPointer] then
        result := result+IntToHex(VInteger,8);
      end;
      Inc(c);
    end;
    Inc(i);
  end;
end;

function  IntToStr(Value: integer): string;
{$if Defined(UNICODE) or Defined(FPC)}
begin
  Str(Value, result);
end;
{$else}
// 3x faster than SysUtils.IntToStr
// from IntToStr32_JOH_IA32_6_a
asm
  push   ebx
  push   edi
  push   esi
  mov    ebx,eax                {Value}
  sar    ebx,31                 {0 for +ve Value or -1 for -ve Value}
  xor    eax,ebx
  sub    eax,ebx                {ABS(Value)}
  mov    esi,10                 {Max Digits in result}
  mov    edi,edx                {@result}
  cmp    eax,10;         sbb    esi, 0
  cmp    eax,100;        sbb    esi, 0
  cmp    eax,1000;       sbb    esi, 0
  cmp    eax,10000;      sbb    esi, 0
  cmp    eax,100000;     sbb    esi, 0
  cmp    eax,1000000;    sbb    esi, 0
  cmp    eax,10000000;   sbb    esi, 0
  cmp    eax,100000000;  sbb    esi, 0
  cmp    eax,1000000000; sbb    esi, ebx    {Digits (Including Sign Character)}
  mov    ecx,[edx]              {result}
  test   ecx,ecx
  je     @@NewStr               {Create New string for result}
  cmp    dword ptr [ecx-8], 1
  jne    @@ChangeStr            {Reference Count<>1}
  cmp    esi,[ecx-4]
  je     @@LengthOk             {Existing Length = Required Length}
  sub    ecx,8                  {Allocation Address}
  push   eax                    {ABS(Value)}
  push   ecx
  mov    eax,esp
  lea    edx,[esi+9]            {New Allocation Size}
  call   system.@ReallocMem     {Reallocate result string}
  pop    ecx
  pop    eax                    {ABS(Value)}
  add    ecx,8                  {result}
  mov    [ecx-4],esi            {Set New Length}
  mov    byte ptr [ecx+esi],0   {Add Null Terminator}
  mov    [edi],ecx              {Set result Address}
  jmp    @@LengthOk
@@ChangeStr:
  mov     edx,dword ptr [ecx-8]  {Reference Count}
  add     edx,1
  jz      @@NewStr               {RefCount = -1 (string Constant)}
  lock    dec dword ptr [ecx-8]  {Decrement Existing Reference Count}
@@NewStr:
  push   eax                     {ABS(Value)}
  mov    eax,esi                 {Length}
  call   system.@NewAnsiString
  mov    [edi],eax               {Set result Address}
  mov    ecx,eax                 {result}
  pop    eax                     {ABS(Value)}
@@LengthOk:
  mov    byte ptr [ecx],'-'      {Store '-' Character (May be Overwritten)}
  add    esi,ebx                 {Digits (Excluding Sign Character)}
  sub    ecx,ebx                 {Destination of 1st Digit}
  sub    esi,2                   {Digits (Excluding Sign Character) - 2}
  jle    @@FinalDigits           {1 or 2 Digit Value}
  cmp    esi,8                   {10 Digit Value?}
  jne    @@SetResult             {Not a 10 Digit Value}
  sub    eax,2000000000          {Digit 10 must be either '1' or '2'}
  mov    dl,'2'
  jnc    @@SetDigit10            {Digit 10 = '2'}
  mov    dl,'1'                  {Digit 10 = '1'}
  add    eax,1000000000
@@SetDigit10:
  mov    [ecx],dl                {Save Digit 10}
  mov    esi,7                   {9 Digits Remaining}
  add    ecx,1                   {Destination of 2nd Digit}
@@SetResult:
  mov    edi,$28F5C29            {((2^32)+100-1)/100}
@@Loop:
  mov    ebx,eax                 {Dividend}
  mul    edi                     {EDX = Dividend DIV 100}
  mov    eax,edx                 {Set Next Dividend}
  imul   edx,-200                {-2 * (100 * Dividend DIV  100)}
  movzx  edx,word ptr [TwoDigitLookup+ebx*2+edx] {Dividend MOD 100 in ASCII}
  mov    [ecx+esi],dx
  sub    esi,2
  jg     @@Loop                  {Loop until 1 or 2 Digits Remaining}
@@FinalDigits:
  pop    esi
  pop    edi
  pop    ebx
  jnz    @@LastDigit
  movzx  eax,word ptr [TwoDigitLookup+eax*2]
  mov    [ecx],ax                {Save Final 2 Digits}
  ret
@@LastDigit:
  or     al,'0'                  {Ascii Adjustment}
  mov    [ecx],al                {Save Final Digit}
end;
{$ifend}

function  IntToStr(Value: int64): string;
{$if Defined(UNICODE) or Defined(FPC)}
begin
  Str(Value, result);
end;
{$else}
// from IntToStr64_JOH_IA32_6_b
asm
  push   ebx
  mov    ecx, [ebp+8]            {Low Integer of Value}
  mov    edx, [ebp+12]           {High Integer of Value}
  xor    ebp, ebp                {Clear Sign Flag (EBP Already Pushed)}
  mov    ebx, ecx                {Low Integer of Value}
  test   edx, edx
  jnl    @@AbsValue
  mov    ebp, 1                  {EBP = 1 for -ve Value or 0 for +ve Value}
  neg    ecx
  adc    edx, 0
  neg    edx
@@AbsValue:                      {EDX:ECX = Abs(Value)}
  jnz    @@Large
  test   ecx, ecx
  js     @@Large
  mov    edx, eax                {@Result}
  mov    eax, ebx                {Low Integer of Value}
  call   IntToStr                {Call Fastest Integer IntToStr Function}
  pop    ebx
@@Exit:
  pop    ebp                     {Restore Stack and Exit}
  ret    8
@@Large:
  push   edi
  push   esi
  mov    edi, eax
  xor    ebx, ebx
  xor    eax, eax
@@Test15:                        {Test for 15 or More Digits}
  cmp    edx, $00005af3          {100000000000000 div $100000000}
  jne    @@Check15
  cmp    ecx, $107a4000          {100000000000000 mod $100000000}
@@Check15:
  jb     @@Test13
@@Test17:                        {Test for 17 or More Digits}
  cmp    edx, $002386f2          {10000000000000000 div $100000000}
  jne    @@Check17
  cmp    ecx, $6fc10000          {10000000000000000 mod $100000000}
@@Check17:
  jb     @@Test15or16
@@Test19:                        {Test for 19 Digits}
  cmp    edx, $0de0b6b3          {1000000000000000000 div $100000000}
  jne    @@Check19
  cmp    ecx, $a7640000          {1000000000000000000 mod $100000000}
@@Check19:
  jb     @@Test17or18
  mov    al, 19
  jmp    @@SetLength
@@Test17or18:                    {17 or 18 Digits}
  mov    bl, 18
  cmp    edx, $01634578          {100000000000000000 div $100000000}
  jne    @@SetLen
  cmp    ecx, $5d8a0000          {100000000000000000 mod $100000000}
  jmp    @@SetLen
@@Test15or16:                    {15 or 16 Digits}
  mov    bl, 16
  cmp    edx, $00038d7e          {1000000000000000 div $100000000}
  jne    @@SetLen
  cmp    ecx, $a4c68000          {1000000000000000 mod $100000000}
  jmp    @@SetLen
@@Test13:                        {Test for 13 or More Digits}
  cmp    edx, $000000e8          {1000000000000 div $100000000}
  jne    @@Check13
  cmp    ecx, $d4a51000          {1000000000000 mod $100000000}
@@Check13:
  jb     @@Test11
@@Test13or14:                    {13 or 14 Digits}
  mov    bl, 14
  cmp    edx, $00000918          {10000000000000 div $100000000}
  jne    @@SetLen
  cmp    ecx, $4e72a000          {10000000000000 mod $100000000}
  jmp    @@SetLen
@@Test11:                        {10, 11 or 12 Digits}
  cmp    edx, $02                {10000000000 div $100000000}
  jne    @@Check11
  cmp    ecx, $540be400          {10000000000 mod $100000000}
@@Check11:
  mov    bl, 11
  jb     @@SetLen                {10 Digits}
@@Test11or12:                    {11 or 12 Digits}
  mov    bl, 12
  cmp    edx, $17                {100000000000 div $100000000}
  jne    @@SetLen
  cmp    ecx, $4876e800          {100000000000 mod $100000000}
@@SetLen:
  sbb    eax, 0                  {Adjust for Odd/Evem Digit Count}
  add    eax, ebx
@@SetLength:                     {Abs(Value) in EDX:ECX, Digits in EAX}
  push   ecx                     {Save Abs(Value)}
  push   edx
  lea    edx, [eax+ebp]          {Digits Needed (Including Sign Character)}
  mov    ecx, [edi]              {@Result}
  mov    esi, edx                {Digits Needed (Including Sign Character)}
  test   ecx, ecx
  je     @@NewStr                {Create New AnsiString for Result}
  cmp    dword ptr [ecx-8], 1
  jne    @@ChangeStr             {Reference Count<>1}
  cmp    esi, [ecx-4]
  je     @@LengthOk              {Existing Length = Required Length}
  sub    ecx, 8                  {Allocation Address}
  push   eax                     {ABS(Value)}
  push   ecx
  mov    eax, esp
  lea    edx, [esi+9]            {New Allocation Size}
  call   system.@ReallocMem      {Reallocate Result AnsiString}
  pop    ecx
  pop    eax                     {ABS(Value)}
  add    ecx, 8                  {@Result}
  mov    [ecx-4], esi            {Set New Length}
  mov    byte ptr [ecx+esi], 0   {Add Null Terminator}
  mov    [edi], ecx              {Set Result Address}
  jmp    @@LengthOk
@@ChangeStr:
  mov     edx, dword ptr [ecx-8]  {Reference Count}
  add     edx, 1
  jz      @@NewStr                {RefCount = -1 (AnsiString Constant)}
  lock    dec dword ptr [ecx-8]   {Decrement Existing Reference Count}
@@NewStr:
  push   eax                     {ABS(Value)}
  mov    eax, esi                {Length}
  call   system.@NewAnsiString
  mov    [edi], eax              {Set Result Address}
  mov    ecx, eax                {@Result}
  pop    eax                     {ABS(Value)}
@@LengthOk:
  mov    edi, [edi]              {@Result}
  sub    esi, ebp                {Digits Needed (Excluding Sign Character)}
  mov    byte ptr [edi], '-'     {Store '-' Character (May be Overwritten)}
  add    edi, ebp                {Destination of 1st Digit}
  pop    edx                     {Restore Abs(Value)}
  pop    eax
  cmp    esi, 17
  jl     @@LessThan17Digits      {Digits < 17}
  je     @@SetDigit17            {Digits = 17}
  cmp    esi, 18
  je     @@SetDigit18            {Digits = 18}
  mov    cl, '0' - 1
  mov    ebx, $a7640000          {1000000000000000000 mod $100000000}
  mov    ebp, $0de0b6b3          {1000000000000000000 div $100000000}
@@CalcDigit19:
  add    ecx, 1
  sub    eax, ebx
  sbb    edx, ebp
  jnc    @@CalcDigit19
  add    eax, ebx
  adc    edx, ebp
  mov    [edi], cl
  add    edi, 1
@@SetDigit18:
  mov    cl, '0' - 1
  mov    ebx, $5d8a0000          {100000000000000000 mod $100000000}
  mov    ebp, $01634578          {100000000000000000 div $100000000}
@@CalcDigit18:
  add    ecx, 1
  sub    eax, ebx
  sbb    edx, ebp
  jnc    @@CalcDigit18
  add    eax, ebx
  adc    edx, ebp
  mov    [edi], cl
  add    edi, 1
@@SetDigit17:
  mov    cl, '0' - 1
  mov    ebx, $6fc10000          {10000000000000000 mod $100000000}
  mov    ebp, $002386f2          {10000000000000000 div $100000000}
@@CalcDigit17:
  add    ecx, 1
  sub    eax, ebx
  sbb    edx, ebp
  jnc    @@CalcDigit17
  add    eax, ebx
  adc    edx, ebp
  mov    [edi], cl
  add    edi, 1                  {Update Destination}
  mov    esi, 16                 {Set 16 Digits Left}
@@LessThan17Digits:              {Process Next 8 Digits}
  mov    ecx, 100000000          {EDX:EAX = Abs(Value) = Dividend}
  div    ecx
  mov    ebp, eax                {Dividend DIV 100000000}
  mov    ebx, edx
  mov    eax, edx                {Dividend MOD 100000000}
  mov    edx, $51EB851F
  mul    edx
  shr    edx, 5                  {Dividend DIV 100}
  mov    eax, edx                {Set Next Dividend}
  lea    edx, [edx*4+edx]
  lea    edx, [edx*4+edx]
  shl    edx, 2                  {Dividend DIV 100 * 100}
  sub    ebx, edx                {Remainder (0..99)}
  movzx  ebx, word ptr [TwoDigitLookup+ebx*2]
  shl    ebx, 16
  mov    edx, $51EB851F
  mov    ecx, eax                {Dividend}
  mul    edx
  shr    edx, 5                  {Dividend DIV 100}
  mov    eax, edx
  lea    edx, [edx*4+edx]
  lea    edx, [edx*4+edx]
  shl    edx, 2                  {Dividend DIV 100 * 100}
  sub    ecx, edx                {Remainder (0..99)}
  or     bx, word ptr [TwoDigitLookup+ecx*2]
  mov    [edi+esi-4], ebx        {Store 4 Digits}
  mov    ebx, eax
  mov    edx, $51EB851F
  mul    edx
  shr    edx, 5                  {EDX = Dividend DIV 100}
  lea    eax, [edx*4+edx]
  lea    eax, [eax*4+eax]
  shl    eax, 2                  {EAX = Dividend DIV 100 * 100}
  sub    ebx, eax                {Remainder (0..99)}
  movzx  ebx, word ptr [TwoDigitLookup+ebx*2]
  movzx  ecx, word ptr [TwoDigitLookup+edx*2]
  shl    ebx, 16
  or     ebx, ecx
  mov    [edi+esi-8], ebx        {Store 4 Digits}
  mov    eax, ebp                {Remainder}
  sub    esi, 10                 {Digits Left - 2}
  jz     @@Last2Digits
@@SmallLoop:                     {Process Remaining Digits}
  mov    edx, $28F5C29           {((2^32)+100-1)/100}
  mov    ebx, eax                {Dividend}
  mul    edx
  mov    eax, edx                {Set Next Dividend}
  imul   edx, -200
  movzx  edx, word ptr [TwoDigitLookup+ebx*2+edx] {Dividend MOD 100 in ASCII}
  mov    [edi+esi], dx
  sub    esi, 2
  jg     @@SmallLoop             {Repeat Until Less than 2 Digits Remaining}
  jz     @@Last2Digits
  or     al , '0'                {Ascii Adjustment}
  mov    [edi], al               {Save Final Digit}
  jmp    @@Done
@@Last2Digits:
  movzx  eax, word ptr [TwoDigitLookup+eax*2]
  mov    [edi], ax               {Save Final 2 Digits}
@@Done:
  pop    esi
  pop    edi
  pop    ebx
end;
{$ifend}

function  IntToHex(Value: integer; Digits: integer): string;
begin
  result := '';
  while (Digits>0) or (Value>0) do begin
    result := HexChars[(Value shr 4) and $F]+HexChars[Value and $F]+result;
    Dec(Digits, 2);
    Value := Value shr 8;
  end;
end;

function  IntToHex(Value: int64; Digits: integer): string;
begin
  result := '';
  while (Digits>0) or (Value>0) do begin
    result := HexChars[(Value shr 4) and $F]+HexChars[Value and $F]+result;
    Dec(Digits, 2);
    Value := Value shr 8;
  end;
end;

function  StrToInt(const S: string): integer;
begin
  result := StrToIntDef(S, 0);
end;

function  StrToIntDef(const S: string; Default: integer): integer;
begin
  if not TryStrToInt(S, result) then
    result := Default;
end;

function  TryStrToInt(const S: string; out Value: integer): boolean;
var E: integer;
begin
  Val(S, Value, E);
  result := (E=0);
end;

function  StrToInt64(const S: string): int64;
begin
  result := StrToInt64Def(S, 0);
end;

function  StrToInt64Def(const S: string; Default: int64): int64;
begin
  if not TryStrToInt64(S, result) then
    result := Default;
end;

function  TryStrToInt64(const S: string; out Value: int64): boolean;
var E: integer;
begin
  Val(S, Value, E);
  result := (E=0);
end;

function  GUIDToString(const GUID: TGUID): string;
  procedure Write(P: PChar; B: PByteArray);
  var i: integer;
  begin // encode as '{3F2504E0-4F89-11D3-9A0C-0305E82C3301}'
    P^ := '{'; Inc(P);
    for i := 3 downto 0 do begin
      P^ := HexChars[(B^[i] shr 4) and $F]; Inc(P);
      P^ := HexChars[B^[i] and $F]; Inc(P);
    end;
    Inc(nativeuint(B), 4);
    for i := 1 to 2 do begin
      P^ := '-'; Inc(P);
      P^ := HexChars[(B^[1] shr 4) and $F]; Inc(P);
      P^ := HexChars[B^[1] and $F]; Inc(P);
      P^ := HexChars[(B^[0] shr 4) and $F]; Inc(P);
      P^ := HexChars[B^[0] and $F]; Inc(P);
      Inc(nativeuint(B), 2);
    end;
    P^ := '-'; Inc(P);
    P^ := HexChars[(B^[0] shr 4) and $F]; Inc(P);
    P^ := HexChars[B^[0] and $F]; Inc(P);
    P^ := HexChars[(B^[1] shr 4) and $F]; Inc(P);
    P^ := HexChars[B^[1] and $F]; Inc(P);
    Inc(nativeuint(B), 2);
    P^ := '-'; Inc(P);
    for i := 1 to 6 do begin
      P^ := HexChars[(B^[0] shr 4) and $F]; Inc(P);
      P^ := HexChars[B^[0] and $F]; Inc(nativeuint(B)); Inc(P);
    end;
    P^ := '}';
  end;
begin
  SetString(result, nil, 38);
  Write(pointer(result), @GUID);
end;

{$IFDEF FPC}
{$ifdef UNICODE}
// (Unicode version in common part for Delphi and FPC/Lazarus)
//    (Only for StrComp, StrIComp and StrLen)
{$else UNICODE}

// Point to Strings functions
function  StrLCopy(Dest: PChar; const Source: PChar; MaxLen: cardinal): PChar;
begin result := Strings.StrLCopy(Dest, Source, MaxLen); end;

function  StrComp(const Str1, Str2: PChar): integer;
begin result := Strings.StrComp(Str1, Str2); end;

function  StrIComp(const Str1, Str2: PChar): integer;
begin result := Strings.StrIComp(Str1, Str2); end;

function  StrLen(const Str: PChar): integer;
begin result := Strings.StrLen(Str); end;

function  StrEnd(const Str: PChar): PChar;
begin result := Strings.StrEnd(Str); end;

function  StrCopy(Dest: PChar; const Source: PChar): PChar;
begin result := Strings.StrCopy(Dest, Source); end;

function  StrCat(Dest: PChar; const Source: PChar): PChar;
begin result := Strings.StrCat(Dest, Source); end;

function  StrPCopy(Dest: PChar; const Source: string): PChar;
begin result := Strings.StrPCopy(Dest, Source); end;

function  StrScan(const Str: PChar; Chr: Char): PChar;
begin result := Strings.StrScan(Str, Chr); end;

{$endif Unicode}
{$ELSE FPC}

function  StrLCopy(Dest: PChar; const Source: PChar; MaxLen: cardinal): PChar;
asm // faster version by AB
    or edx,edx
    jz @z
    push eax
    push ebx
    xchg eax,edx
{$ifdef UNICODE}
    lea ebx,ecx*2
{$else}
    mov ebx,ecx
{$endif}
    xor ecx,ecx
@1:
{$ifdef UNICODE}
    cmp word ptr [eax+ecx],0
    lea ecx,ecx+2
{$else}
    cmp byte ptr [eax+ecx],0
    lea ecx,ecx+1 // copy last #0
{$endif}
    je @s
    cmp ecx,ebx
    jb @1
@s: pop ebx
    call Move
    pop eax
@z:
end;

{$ifdef UNICODE}
// (Unicode version in common part for Delphi and FPC/Lazarus)
{$else}
function  StrComp(const Str1, Str2: PChar): integer;
asm // faster version by AB
        MOV     ECX,EAX
        XOR     EAX,EAX
        CMP     ECX,EDX
        JE      @Exit2  //same string or both nil
        OR      ECX,ECX
        MOV     AL,1
        JZ      @Exit2  //Str1=''
        OR      EDX,EDX
        JE      @min
@1:     MOV     AL,[ECX]
        INC     ECX
        MOV     AH,[EDX]
        INC     EDX
        TEST    AL,AL
        JE      @Exit
        CMP     AL,AH
        JE      @1
@Exit:  XOR     EDX,EDX
        XCHG    AH,DL
        SUB     EAX,EDX
@Exit2: RET
@min:   OR      EAX,-1
end;
{$endif}

{$ifdef UNICODE}
// (Unicode version in common part for Delphi and FPC/Lazarus)
{$else}
function  StrIComp(const Str1, Str2: PChar): integer;
asm // faster version by AB
        MOV     ECX,EAX
        XOR     EAX,EAX
        CMP     ECX,EDX
        JE      @Exit2  //same string or both nil
        OR      ECX,ECX
        MOV     AL,1
        JZ      @Exit2  //Str1=''
        OR      EDX,EDX
        JE      @min
@1:     MOV     AL,[ECX]
        INC     ECX
        TEST    AL,AL
        MOV     AH,[EDX]
        LEA     EDX,EDX+1
        JE      @Exit
        CMP     AL,AH
        JE      @1
        SUB     AL,'a'
        SUB     AH,'a'
        CMP     AL,'z'-'a'
        JA      @@2
        SUB     AL,20H
@@2:    CMP     AH,'z'-'a'
        JA      @@3
        SUB     AH,20H
@@3:    CMP     AL,AH
        JE      @1
@Exit:  XOR     EDX,EDX
        XCHG    AH,DL
        SUB     EAX,EDX
@Exit2: RET
@min:   OR      EAX,-1
end;
{$endif}

{$ifdef UNICODE}
// (Unicode version in common part for Delphi and FPC/Lazarus)
function  StrLen(const Str: PAnsiChar): integer;
{$else}
function  StrLen(const Str: PChar): integer;
{$endif}
asm // faster than default SysUtils version
     test eax,eax
     jz @@z
     cmp   byte ptr [eax  ],0; je @@0
     cmp   byte ptr [eax+1],0; je @@1
     cmp   byte ptr [eax+2],0; je @@2
     cmp   byte ptr [eax+3],0; je @@3
     push  eax
     and   eax,-4              {DWORD Align Reads}
@@Loop:
     add   eax,4
     mov   edx,[eax]           {4 Chars per Loop}
     lea   ecx,[edx-$01010101]
     not   edx
     and   edx,ecx
     and   edx,$80808080       {Set Byte to $80 at each #0 Position}
     jz    @@Loop              {Loop until any #0 Found}
@@SetResult:
     pop   ecx
     bsf   edx,edx             {Find First #0 Position}
     shr   edx,3               {Byte Offset of First #0}
     add   eax,edx             {Address of First #0}
     sub   eax,ecx
@@z: ret
@@0: xor eax,eax; ret
@@1: mov eax,1;   ret
@@2: mov eax,2;   ret
@@3: mov eax,3
end;

function StrEnd(const Str: PChar): PChar;
asm // faster version by AB
  push eax
  call StrLen
  pop edx
{$ifdef UNICODE}
  lea eax,eax+edx*2
{$else}
  add eax,edx
{$endif}
end;

function StrCopy(Dest: PChar; const Source: PChar): PChar;
asm // faster version by AB
  push eax
  push eax
  push edx
  mov eax,edx
  call StrLen
{$ifdef UNICODE}
  lea ecx,eax*2+2 // also copy last #0
{$else}
  lea ecx,eax+1
{$endif}
  pop eax
  pop edx // xchg eax,edx
  call move
  pop eax
end;

function StrCat(Dest: PChar; const Source: PChar): PChar;
begin
  StrCopy(Dest + StrLen(Dest), Source);
  result := Dest;
end;

function StrPCopy(Dest: PChar; const Source: string): PChar;
asm // faster version by AB
    or edx,edx
    push eax
    xchg eax,edx
    jz @z
    mov ecx,[eax-4]
{$ifdef UNICODE}
    lea ecx,ecx*2+2
{$else}
    lea ecx,ecx+1 // copy last #0
{$endif}
    call move
@z: pop eax
end;

function StrScan(const Str: PChar; Chr: Char): PChar;
asm // faster version by AB - eax=Str dl=Chr
    or eax,eax
    jz @z
{$ifdef UNICODE}
@1: mov cx,[eax]
    cmp cx,dx
    jz @z
    lea eax,eax+2
    or cx,cx
{$else}
@1: mov cl,[eax]
    cmp cl,dl
    jz @z
    inc eax
    or cl,cl
{$endif}
    jnz @1
    xor eax,eax
@z:
end;

{$ENDIF FPC}

{$IFDEF UNICODE}

// Common to both Delphi and FPC/Lazarus

function  StrComp(const Str1, Str2: PChar): integer;
var AStr1, AStr2: PChar;
begin
  AStr1:= Str1; AStr2:=Str2;
  result := 0;      // Str1=Str2
  if AStr1<>AStr2 then
  if AStr1<>nil then
  if AStr2<>nil then begin
    if AStr1^=AStr2^ then
    repeat
      if (AStr1^=#0) or (AStr2^=#0) then break;
      Inc(AStr1);
      Inc(AStr2);
    until AStr1^<>AStr2^;
    result := pWord(AStr1)^-pWord(AStr2)^;
  end else
  result := 1 else  // Str2=''
  result := -1;     // Str1=''
end;

function  StrIComp(const Str1, Str2: PChar): integer;
var AStr1, AStr2: PChar;
var C1, C2: Char;
begin
  AStr1:= Str1; AStr2:=Str2;
  result := 0;      // Str1=Str2
  if AStr1<>AStr2 then
  if AStr1<>nil then
  if AStr2<>nil then begin
    repeat
      C1 := AStr1^;
      C2 := AStr2^;
      if ord(C1) in [ord('a')..ord('z')] then Dec(C1, 32);
      if ord(C2) in [ord('a')..ord('z')] then Dec(C2, 32);
      if (C1<>C2) or (C1=#0) then break;
      Inc(AStr1);
      Inc(AStr2);
    until false;
    result := ord(C1) - ord(C2);
  end else
  result := 1 else  // Str2=''
  result := -1;     // Str1=''
end;

function  StrLen(const Str: PChar): integer;
var AStr: PChar;
begin
  result := 0;
  AStr := Str;
  if AStr<>nil then
  while true do
    if AStr[0]<>#0 then
    if AStr[1]<>#0 then
    if AStr[2]<>#0 then
    if AStr[3]<>#0 then begin
      Inc(AStr, 4);
      Inc(result, 4);
    end else begin
      Inc(result, 3);
      exit;
    end else begin
      Inc(result, 2);
      exit;
    end else begin
      Inc(result);
      exit;
    end else
      exit;
end;

{$ENDIF UNICODE}

function  StringReplace(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
var
  SearchStr, Patt, NewStr: string;
  Offset: integer;
begin
  if rfIgnoreCase in Flags then begin
    SearchStr := UpperCase(S);
    Patt := UpperCase(OldPattern);
  end else begin
    SearchStr := S;
    Patt := OldPattern;
  end;
  NewStr := S;
  result := '';
  while SearchStr<>'' do begin
    Offset := Pos(Patt, SearchStr);
    if Offset = 0 then begin
      result := result + NewStr;
      break;
    end;
    result := result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + length(OldPattern), MaxInt);
    if not (rfReplaceAll in Flags) then begin
      result := result + NewStr;
      break;
    end;
    SearchStr := Copy(SearchStr, Offset + length(Patt), MaxInt);
  end;
end;

procedure UpperLower(Source, Dest: PChar; L: cardinal; Upper: boolean);
var Ch: Char;
begin
  repeat
    Ch := Source^;
    if Upper then   // (Non optimal)
      begin if ord(Ch) in [ord('a')..ord('z')] then Dec(Ch, 32); end
    else
      begin if ord(Ch) in [ord('A')..ord('Z')] then Inc(Ch, 32); end;
    Dest^ := Ch;
    Dec(L);
    Inc(Source);
    Inc(Dest);
  until L=0;
end;

{$IFDEF FPC}

function  CompareText(const S1, S2: string): integer;
var i, count, count1, count2: integer;
var ch1, ch2: integer;
begin
  count1 := length(S1);
  count2 := length(S2);
  if count1 > count2 then
    count := count2
  else
    count := count1;
  for i:=1 to count do
    begin
      ch1 := ord(S1[i]);
      ch2 := ord(S2[i]);
      if ch1 <> ch2 then
        begin
          if ch1 in [ord('a')..ord('z')] then Dec(ch1, 32);
          if ch2 in [ord('a')..ord('z')] then Dec(ch2, 32);
          if ch1 <> ch2 then
            begin
              result := ch1 - ch2;
              exit;
            end;
        end;
    end;
  result := count1 - count2;
end;

function  SameText(const S1, S2: string): boolean;
begin
 result := (CompareText(S1, S2)=0);
end;

function  CompareStr(const S1, S2: string): integer;
var i, count, count1, count2: integer;
begin
  count1 := length(S1);
  count2 := length(S2);
  if count1 > count2 then
    count := count2
  else
    count := count1;
  for i:=1 to count do
    if ord(S1[i]) <> ord(S2[i]) then
      begin
        result := ord(S1[i]) - ord(S2[i]);
        exit;
      end;
  result := count1 - count2;
end;

function  UpperCase(const S: string): string;
var L: cardinal;
begin
  L := length(S);
  SetLength(result, L);
  if L<>0 then
    UpperLower(pointer(S), pointer(result), L, true);
end;

function  Trim(const S: string): string;
var StartS, EndS: integer;
begin
  EndS := length(S);
  StartS := 1;
  while (StartS<=EndS) and (S[StartS] in [#0,' ']) do
    Inc(StartS);
  if StartS>Ends then
    result := ''
  else
    begin
      while S[EndS] in [#0,' '] do    // (Cant' have Ends<StartS = all ' ' here)
        Dec(EndS);
      result := Copy(S, StartS, EndS-StartS+1);
    end;
end;

{$ELSE FPC}

function  CompareText(const S1, S2: string): integer;
{$ifdef UNICODE}
asm // John O'Harrow version
        TEST   EAX, EAX
        JNZ    @@CheckS2
        TEST   EDX, EDX
        JZ     @@Ret
        MOV    EAX, [EDX-4]
        NEG    EAX
@@Ret:  RET
@@CheckS2:
        TEST   EDX, EDX
        JNZ    @@Compare
        MOV    EAX, [EAX-4]
        RET
@@Compare:
        PUSH   EBX
        PUSH   EBP
        PUSH   ESI
        PUSH   0
        PUSH   0
        CMP    WORD PTR [EAX-10],2
        JE     @@S1IsUnicode
        PUSH   EDX
        MOV    EDX,EAX
        LEA    EAX,[ESP+4]
        CALL   System.@UStrFromLStr
        POP    EDX
        MOV    EAX,[ESP]
@@S1IsUnicode:
        CMP    WORD PTR [EDX-10],2
        JE     @@S2IsUnicode
        PUSH   EAX
        LEA    EAX,[ESP+8]
        CALL   System.@UStrFromLStr
        POP    EAX
        MOV    EDX,[ESP+4]
@@S2IsUnicode:
        MOV    EBP, [EAX-4]     // length(S1)
        MOV    EBX, [EDX-4]     // length(S2)
        SUB    EBP, EBX         // Result if All Compared Characters Match
        SBB    ECX, ECX
        AND    ECX, EBP
        ADD    ECX, EBX         // min(length(S1),length(S2)) = Compare Length
        LEA    ESI, [EAX+ECX*2] // Last Compare Position in S1
        ADD    EDX, ECX         // Last Compare Position in S2
        ADD    EDX, ECX         // Last Compare Position in S2
        NEG    ECX
        JZ     @@SetResult      // Exit if Smallest Length = 0
@@Loop:                         // Load Next 2 Chars from S1 and S2
                                // May Include Null Terminator}
        MOV    EAX, [ESI+ECX*2]
        MOV    EBX, [EDX+ECX*2]
        CMP    EAX,EBX
        JE     @@Next           // Next 2 Chars Match
        CMP    AX,BX
        JE     @@SecondPair     // First Char Matches
        AND    EAX,$0000FFFF
        AND    EBX,$0000FFFF
        CMP    EAX, 'a'
        JL     @@UC1
        CMP    EAX, 'z'
        JG     @@UC1
        SUB    EAX, 'a'-'A'
@@UC1:  CMP    EBX, 'a'
        JL     @@UC2
        CMP    EBX, 'z'
        JG     @@UC2
        SUB    EBX, 'a'-'A'
@@UC2:  SUB    EAX,EBX          // Compare Both Uppercase Chars
        JNE    @@Done           // Exit with Result in EAX if Not Equal
        MOV    EAX, [ESI+ECX*2] // Reload Same 2 Chars from S1
        MOV    EBX, [EDX+ECX*2] // Reload Same 2 Chars from S2
        AND    EAX,$FFFF0000
        AND    EBX,$FFFF0000
        CMP    EAX,EBX
        JE     @@Next           // Second Char Matches
@@SecondPair:
        SHR    EAX, 16
        SHR    EBX, 16
        CMP    EAX, 'a'
        JL     @@UC3
        CMP    EAX, 'z'
        JG     @@UC3
        SUB    EAX, 'a'-'A'
@@UC3:  CMP    EBX, 'a'
        JL     @@UC4
        CMP    EBX, 'z'
        JG     @@UC4
        SUB    EBX, 'a'-'A'
@@UC4:  SUB    EAX,EBX           // Compare Both Uppercase Chars
        JNE    @@Done           // Exit with Result in EAX if Not Equal
@@Next: ADD    ECX, 2
        JL     @@Loop           // Loop until All required Chars Compared
@@SetResult:
        MOV    EAX,EBP          // All Matched, Set Result from Lengths
@@Done: MOV    ECX,ESP
        MOV    EDX,[ECX]
        OR     EDX,[ECX + 4]
        JZ     @@NoClear
        PUSH   EAX
        MOV    EAX,ECX
        MOV    EDX,2
        CALL   System.@LStrArrayClr
        POP    EAX
@@NoClear:
        ADD    ESP,8
        POP    ESI
        POP    EBP
        POP    EBX
end;
{$else}
asm // fast version, optimized for 7 bits Ansi uppercase
         test  eax,eax
         jz    @nil1
         test  edx,edx
         jz   @nil2
         push  edi
         push  ebx
         xor   edi,edi
         mov   ebx,[eax-4]
         mov   ecx,ebx
         sub   ebx,[edx-4]
         adc   edi,-1
         push  ebx    // save length(S1)-length(S2)
         and   ebx,edi
         mov   edi,eax
         sub   ebx,ecx  //ebx := -min(Length(s1),Length(s2))
         jge   @len
@lenok:  sub   edi,ebx
         sub   edx,ebx
@loop:   mov   eax,[ebx+edi]
         mov   ecx,[ebx+edx]
         xor   eax,ecx
         jne   @differ
@same:   add   ebx,4
         jl    @loop
@len:    pop   eax
         pop   ebx
         pop   edi
         ret
@loop2:  mov   eax,[ebx+edi]
         mov   ecx,[ebx+edx]
         xor   eax,ecx
         je    @same
@differ: test  eax,$DFDFDFDF  // $00 or $20
         jnz   @find
         add   eax,eax        // $00 or $40
         add   eax,eax        // $00 or $80
         test  eax,ecx
         jnz   @find
         and   ecx,$5F5F5F5F  // $41..$5A
         add   ecx,$3F3F3F3F  // $80..$99
         and   ecx,$7F7F7F7F  // $00..$19
         add   ecx,$66666666  // $66..$7F
         test  ecx,eax
         jnz   @find
         add   ebx,4
         jl    @loop2
@len2:   pop   eax
         pop   ebx
         pop   edi
         ret
@nil2:   mov   eax,[eax-4]
         ret
@nil1:   test  edx,edx
         jz    @nil0
         sub   eax,[edx-4]
@nil0:   ret
@loop3:  add   ebx, 1
         jge   @len2
@find:   movzx eax,byte ptr [ebx+edi]
         movzx ecx,byte ptr [ebx+edx]
         sub   eax,'a'
         sub   ecx,'a'
         cmp   al,'z'-'a'
         ja    @upa
         sub   eax,'a'-'A'
@upa:    cmp   cl,'z'-'a'
         ja    @upc
         sub   ecx,'a'-'A'
@upc:    sub   eax,ecx
         jz    @loop3
@found:  pop   ecx
         pop   ebx
         pop   edi
end;
{$endif}

function  SameText(const S1, S2: string): boolean;
asm
    cmp  eax,edx
    jz   @1
    or   eax,eax
    jz   @2
    or   edx,edx
    jz   @3
    mov  ecx,[eax-4]
    cmp  ecx,[edx-4]
    jne  @3 // length must be the same
    call CompareText // compare chars inside
    test eax,eax
    jnz  @3
@1: mov  al,1
@2: ret
@3: xor  eax,eax
end;

function  CompareStr(const S1, S2: string): integer;
asm
     push  esi
     push  edi
     mov   esi,eax
     mov   edi,edx
     or    eax,eax
     je    @@1
     mov   eax,[eax-4]
@@1: or    edx,edx
     je    @@2
     mov   edx,[edx-4]
@@2: mov   ecx,eax
     cmp   ecx,edx
     jbe   @@3
     mov   ecx,edx
@@3: // eax=length(s1), edx=length(s2), ecx=min(eax,edx)
     cmp   ecx,ecx
{$ifdef UNICODE}
     repe  cmpsw
     je    @@4
     movzx eax,word ptr [esi-2]
     movzx edx,word ptr [edi-2]
{$else}
     repe  cmpsb
     je    @@4
     movzx eax,byte ptr [esi-1]
     movzx edx,byte ptr [edi-1]
{$endif}
@@4: sub   eax,edx
     pop   edi
     pop   esi
end;

function  UpperCase(const S: string): string;
{$ifdef UNICODE}
var L: cardinal;
begin
  L := length(S);
  SetLength(result, L);
  if L<>0 then
    UpperLower(pointer(S), pointer(result), L, true);
end;
{$else}
asm
  push    edi
  push    esi
  push    ebx
  mov     esi,eax               {@S}
  mov     edi,edx               {@Result}
  mov     eax,edx               {@Result}
  xor     edx,edx
  test    esi,esi               {Test for S = NIL}
  jz      @@Setlen              {S = NIL}
  mov     edx,[esi-4]           {Length(S)}
@@SetLen:
  lea     ebx,[edx-4]           {Length(S) - 4}
  call    system.@LStrSetLength {Create Result String}
  mov     edi,[edi]             {@Result}
  add     esi,ebx
  add     edi,ebx
  neg     ebx
  jg      @@Remainder           {Length(S) < 4}
@@Loop:                         {Loop converting 4 Characters per Loop}
  mov     eax,[esi+ebx]
  mov     ecx,eax               {4 Original Bytes}
  or      eax,$80808080         {Set High Bit of each Byte}
  mov     edx,eax               {Comments Below apply to each Byte...}
  sub     eax,$7B7B7B7B         {Set High Bit if Original <= Ord('z')}
  xor     edx,ecx               {80h if Original < 128 else 00h}
  or      eax,$80808080         {Set High Bit}
  sub     eax,$66666666         {Set High Bit if Original >= Ord('a')}
  and     eax,edx               {80h if Orig in 'a'..'z' else 00h}
  shr     eax,2                 {80h > 20h ('a'-'A')}
  sub     ecx,eax               {Clear Bit 5 if Original in 'a'..'z'}
  mov     [edi+ebx], ecx
  add     ebx,4
  jle     @@Loop
@@Remainder:
  sub     ebx,4
  jz      @@Done
@@SmallLoop:                    {Loop converting 1 Character per Loop}
  movzx   eax,byte ptr [esi+ebx+4]
  lea     edx,[eax-'a']
  cmp     edx,'z'-'a'+1
  sbb     ecx,ecx
  and     ecx,$20
  sub     eax,ecx
  mov     [edi+ebx+4],al
  inc     ebx
  jnz     @@SmallLoop
@@Done:
  pop     ebx
  pop     esi
  pop     edi
end;
{$endif}

function  Trim(const S: string): string;
{$ifdef UNICODE}
asm  // fast implementation by John O'Harrow
  test eax,eax                   {S = nil?}
  xchg eax,edx
  jz   System.@UStrClr           {Yes, Return Empty String}
  mov  ecx,[edx-4]               {Length(S)}
  cmp  byte ptr [edx],' '        {S[1] <= ' '?}
  jbe  @@TrimLeft                {Yes, Trim Leading Spaces}
  cmp  byte ptr [edx+ecx-1],' '  {S[Length(S)] <= ' '?}
  jbe  @@TrimRight               {Yes, Trim Trailing Spaces}
  jmp  System.@UStrLAsg          {No, Result := S (which occurs most time)}
@@TrimLeft:                      {Strip Leading Whitespace}
  dec  ecx
  jle  System.@UStrClr           {All Whitespace}
  inc  edx
  cmp  byte ptr [edx],' '
  jbe  @@TrimLeft
@@CheckDone:
  cmp  byte ptr [edx+ecx-1],' '
  ja   System.@UStrFromPCharLen
@@TrimRight:                     {Strip Trailing Whitespace}
  dec  ecx
  jmp  @@CheckDone
end;

function  Trim(const S: ansistring): ansistring;
{$endif}
asm  // fast implementation by John O'Harrow
  test eax,eax                   {S = nil?}
  xchg eax,edx
  jz   System.@LStrClr           {Yes, Return Empty String}
  mov  ecx,[edx-4]               {Length(S)}
  cmp  byte ptr [edx],' '        {S[1] <= ' '?}
  jbe  @@TrimLeft                {Yes, Trim Leading Spaces}
  cmp  byte ptr [edx+ecx-1],' '  {S[Length(S)] <= ' '?}
  jbe  @@TrimRight               {Yes, Trim Trailing Spaces}
  jmp  System.@LStrLAsg          {No, Result := S (which occurs most time)}
@@TrimLeft:                      {Strip Leading Whitespace}
  dec  ecx
  jle  System.@LStrClr           {All Whitespace}
  inc  edx
  cmp  byte ptr [edx],' '
  jbe  @@TrimLeft
@@CheckDone:
  cmp  byte ptr [edx+ecx-1],' '
  ja   System.@LStrFromPCharLen
@@TrimRight:                     {Strip Trailing Whitespace}
  dec  ecx
  jmp  @@CheckDone
end;

{$ENDIF FPC}

function  LowerCase(const S: string): string;
var L: cardinal;
begin
  L := length(S);
  SetLength(result, L);
  if L<>0 then
    UpperLower(pointer(S), pointer(result), L, false);
end;

function  TrimLeft(const S: string): string;
var StartS, EndS: integer;
begin
  EndS := length(S);
  StartS := 1;
  while (StartS<=EndS) and (S[StartS] in [#0,' ']) do
    Inc(StartS);
  if StartS>Ends then
    result := ''
  else
    result := Copy(S, StartS, EndS-StartS+1);
end;

function  TrimRight(const S: string): string;
var EndS: integer;
begin
  EndS := length(S);
  while S[EndS] in [#0,' '] do
    Dec(EndS);
  if EndS<1 then
    result := ''
  else
    result := Copy(S, 1, EndS);
end;

{$if Defined(UNICODE) and not Defined(FPC)} // Delphi Unicode only
function  TrimLeft(const S: ansistring): ansistring;
var StartS, EndS: integer;
begin
  EndS := length(S);
  StartS := 1;
  while (StartS<=EndS) and (S[StartS] in [#0,' ']) do
    Inc(StartS);
  if StartS>Ends then
    result := ''
  else
    result := Copy(S, StartS, EndS-StartS+1);
end;

function  TrimRight(const S: ansistring): ansistring;
var EndS: integer;
begin
  EndS := length(S);
  while S[EndS] in [#0,' '] do
    Dec(EndS);
  if EndS<1 then
    result := ''
  else
    result := Copy(S, 1, EndS);
end;
{$ifend}

function  QuotedStr(const S: string): string;
var L: integer;
begin
  result := S;
  for L := Length(result) downto 1 do
    if result[L] = '''' then
      Insert('''', result, L);
  result := '''' + result + '''';
end;

{$if (not Defined(FPC)) or (not Defined(UNICODE))}  // Delphi, or FPC/Lazarus non Unicode

function  AnsiStrScan(Str: PChar; Chr: Char): PChar;
begin
  result := StrScan(Str, Chr);  // (simplified)
end;

function AnsiQuotedStr(const S: string; Quote: Char): string;
var P, Src, Dest: PChar;
var AddCount: integer;
begin
  AddCount := 0;
  P := AnsiStrScan(PChar(S),Quote);
  while P <> nil do begin
    Inc(P);
    Inc(AddCount);
    P := AnsiStrScan(P, Quote);
  end;
  if AddCount = 0 then begin
    result := Quote + S + Quote;
    exit;
  end;
  SetLength(result, Length(S) + AddCount + 2);
  Dest := PChar(result);
  Dest^ := Quote;
  Inc(Dest);
  Src := PChar(S);
  P := AnsiStrScan(Src, Quote);
  repeat
    Inc(P);
    Move(Src^, Dest^, (P-Src) * SizeOf(Char));
    Inc(Dest, P-Src);
    Dest^ := Quote;
    Inc(Dest);
    Src := P;
    P := AnsiStrScan(Src, Quote);
  until P = nil;
  P := StrEnd(Src);
  Move(Src^, Dest^, (P-Src) * SizeOf(Char));
  Inc(Dest, P-Src);
  Dest^ := Quote;
end;

function AnsiExtractQuotedStr(var Src: PChar; Quote: Char): string;
var P, Dest: PChar;
var DropCount: integer;
var EndSuffix: integer;
begin
  result := '';
  if (Src = nil) or (Src^ <> Quote) then exit;
  Inc(Src);
  DropCount := 1;
  P := Src;
  Src := AnsiStrScan(Src, Quote);
  while Src <> nil do  begin    // count adjacent pairs of quote chars
    Inc(Src);
    if Src^ <> Quote then
      break;
    Inc(Src);
    Inc(DropCount);
    Src := AnsiStrScan(Src, Quote);
  end;
  EndSuffix := Ord(Src = nil);  // Has an ending quotation mark?
  if Src = nil then
    Src := StrEnd(P);
  if ((Src - P) <= 1 - EndSuffix) or ((Src - P - DropCount) = EndSuffix) then
    exit;
  if DropCount = 1 then
    SetString(result, P, Src - P - 1 + EndSuffix)
  else begin
    SetLength(result, Src - P - DropCount + EndSuffix);
    Dest := PChar(result);
    Src := AnsiStrScan(P, Quote);
    while Src <> nil do begin
      Inc(Src);
      if Src^ <> Quote then
        break;
      Move(P^, Dest^, (Src - P) * SizeOf(Char));
      Inc(Dest, Src - P);
      Inc(Src);
      P := Src;
      Src := AnsiStrScan(Src, Quote);
    end;
    if Src = nil then
      Src := StrEnd(P);
    Move(P^, Dest^, (Src - P - 1 + EndSuffix) * SizeOf(Char));
  end;
end;

function AnsiDequotedStr(const S: string; AQuote: Char): string;
var LText: PChar;
begin
  LText := PChar(S);
  result := AnsiExtractQuotedStr(LText, AQuote);
  if ((result = '') or (LText^ = #0)) and
     (Length(S) > 0) and ((S[1] <> AQuote) or (S[Length(S)] <> AQuote)) then
    result := S;
end;

{$ifend}

function  AnsiCompareText(const S1, S2: string): integer;
begin   // (LVCL uses also SORT_STRINGSORT)
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_CompareString{$ELSE}LLCLS_CompareString{$ENDIF}
      (LOCALE_USER_DEFAULT, NORM_IGNORECASE, S1, S2) - 2;
end;

function  AnsiSameText(const S1, S2: string): boolean;
begin
  result := (AnsiCompareText(S1, S2)=0);
end;

function  AnsiCompareStr(const S1, S2: string): integer;
begin   // (LVCL uses also SORT_STRINGSORT)
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_CompareString{$ELSE}LLCLS_CompareString{$ENDIF}
      (LOCALE_USER_DEFAULT, 0, S1, S2) - 2;
end;

function  AnsiSameStr(const S1, S2: string): boolean;
begin
  result := (AnsiCompareStr(S1, S2)=0);
end;

function  AnsiUpperCase(const S: string): string;
begin
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_CharUpperBuff{$ELSE}LLCLS_CharUpperBuff{$ENDIF}(S);
end;

function  AnsiLowerCase(const S: string): string;
begin
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_CharLowerBuff{$ELSE}LLCLS_CharLowerBuff{$ENDIF}(S);
end;

function  WideCompareText(const S1, S2: widestring): integer;
begin   // (LVCL uses also SORT_STRINGSORT)
  result := LLCL_CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PWideChar(S1), length(S1), PWideChar(S2), length(S2)) - 2;
end;

function  WideSameText(const S1, S2: widestring): boolean;
begin   // (LVCL uses also SORT_STRINGSORT)
  result := (WideCompareText(S1, S2)=0);
end;

function  WideCompareStr(const S1, S2: widestring): integer;
begin
  result := LLCL_CompareStringW(LOCALE_USER_DEFAULT, 0, PWideChar(S1), length(S1), PWideChar(S2), length(S2)) - 2;
end;

function  WideSameStr(const S1, S2: widestring): boolean;
begin
  result := (WideCompareStr(S1, S2)=0);
end;

function  WideUpperCase(const S: widestring): widestring;
var Len: cardinal;
begin
  Len := length(S);
  SetString(result, PWideChar(S), Len);
  if Len > 0 then LLCL_CharUpperBuffW(pointer(result), Len);
end;

function  WideLowerCase(const S: widestring): widestring;
var Len: cardinal;
begin
  Len := length(S);
  SetString(result, PWideChar(S), Len);
  if Len > 0 then LLCL_CharLowerBuffW(pointer(result), Len);
end;

procedure DecodeDate({$IFDEF FPC}{$ELSE}const {$ENDIF}DateTime: TDateTime; var Year, Month, Day: word);
var J: integer;
begin
  J := pred((Trunc(DateTime) + 693900) shl 2);
  Year := J div 146097;
  Day := (J - 146097 * Year) shr 2;
  J := (Day shl 2 + 3) div 1461;
  Day := (Day shl 2 + 7 - 1461 * J) shr 2;
  Month := (5 * Day - 3) div 153;
  Day := (5 * Day + 2 - 153 * Month) div 5;
  Year := 100 * Year + J;
  if Month < 10 then
    Inc(Month, 3)
  else begin
    Dec(Month, 9);
    Inc(Year);
  end;
end;

function  EncodeDate(Year, Month, Day: word): TDateTime;
begin
  result := 0;
  if (Month < 1) or (Month > 12) then exit;
  if (Day <= MonthDays[true][Month]) and // test worse case = leap year
    (Year >= 1) and (Year < 10000) and
    (Month < 13) and (Day > 0) then begin
    if Month > 2 then
      Dec(Month, 3) else
    if Month > 0 then begin
      Inc(Month, 9);
      Dec(Year);
    end
    else // Month <= 0
      exit;
    result := (146097 * (Year div 100)) shr 2 + (1461 * (Year mod 100)) shr 2 +
          (153 * Month + 2) div 5 + Day - 693900;
  end;
end;

function  IsLeapYear(Year: word): boolean;
begin
  result := false;
  if (Year and 3)=0 then
    if (Year mod 100)<>0 then
      result := true
    else
      if ((Year div 100) and 3)=0 then
        result := true;
end;

procedure DecodeTime({$IFDEF FPC}{$ELSE}const {$ENDIF}DateTime: TDateTime; var Hour, Min, Sec, MSec: word);
{$IFDEF FPC}
const cMSecsPerHour = MinsPerHour * SecsPerMin * MSecsPerSec;
const cMSecsPerMin  = SecsPerMin * MSecsPerSec;
var i: cardinal;
begin
 i := Round(Abs(Frac(DateTime)) * MSecsPerDay);
 Hour := i div cMSecsPerHour;
 i := i mod cMSecsPerHour;
 Min := i div cMSecsPerMin;
 i := i mod cMSecsPerMin;
 Sec := i div MSecsPerSec;
 MSec := i mod MSecsPerSec;
end;
{$ELSE FPC}
begin // faster asm version by AB
  asm // inside a begin...end block -> copy all parameters to the stack
     fld   datetime
     fmul  fmsecsperday
     sub   esp,8
     fistp qword ptr [esp]
     pop eax
     pop edx
     or    edx,edx
     mov   ecx,MSecsPerDay
     jns   @@1
     neg   edx
     neg   eax
     sbb   edx,0
@@1: div   ecx
     mov ecx,SecsPerMin*MSecsPerSec
     mov eax,edx
     shr edx,16           // dx:ax = time
     div cx               // (dx:ax) div cx -> dx=remainder=MSecCount, ax=quotient=MinCount
     mov cl,MinsPerHour   // =60 -> byte division
     div cl               // ax div cl -> ah=remainder=Min, al=quotient=Hour
     mov ecx,Min
     mov [ecx],ah
     inc ecx
     xor ah,ah
     mov [ecx],ah         // make word value
     mov ecx,Hour
     mov [ecx],ax
     mov eax,edx
     xor edx,edx
     mov ecx,MSecsPerSec
     div cx               // (dx:ax) div cx -> dx=remainder=MSec ax=quotient=Sec
     mov ecx,Sec
     mov [ecx],ax
     mov ecx,MSec
     mov [ecx],dx
  end;
end;
{$ENDIF FPC}

function  EncodeTime(Hour, Min, Sec, MSec: word): TDateTime;
begin
  if (Hour < HoursPerDay) and (Min < MinsPerHour) and (Sec < SecsPerMin) and
     (MSec < MSecsPerSec) then
    result := (Hour * (MinsPerHour * SecsPerMin * MSecsPerSec) +
              Min * (SecsPerMin * MSecsPerSec) + (Sec * MSecsPerSec) + MSec)
              / MSecsPerDay else
    result := 0;
end;

function  TryEncodeDate(Year, Month, Day: word; out Date: TDateTime): boolean;
var i: integer;
var DayTable: PDayTable;
begin
  result := false;
  DayTable := @MonthDays[IsLeapYear(Year)];
  if (Year >= 1) and (Year <= 9999) and (Month >= 1) and (Month <= 12) and
    (Day >= 1) and (Day <= DayTable^[Month]) then
    begin
      for i := 1 to Month - 1 do Inc(Day, DayTable^[i]);
      i := Year - 1;
      Date := i * 365 + i div 4 - i div 100 + i div 400 + Day - DateDelta;
      result := true;
    end;
end;

function  TryEncodeTime(Hour, Min, Sec, MSec: word; out Time: TDateTime): boolean;
begin
  result := false;
  if (Hour < HoursPerDay) and (Min < MinsPerHour) and (Sec < SecsPerMin) and (MSec < MSecsPerSec) then
    begin
      Time :=  ((Hour * (MinsPerHour * SecsPerMin * MSecsPerSec))
                + (Min * SecsPerMin * MSecsPerSec)
                + (Sec * MSecsPerSec)
                +  MSec) / MSecsPerDay;
      result := true;
    end;
end;

{$ifdef MSWindows}
function  DateTimeToFileDate({$IFDEF FPC}{$ELSE}const {$ENDIF}DateTime: TDateTime): integer;
var Year, Month, Day: word;
    Hour, Min, Sec, MSec: Word;
begin
  DecodeDate(DateTime, Year, Month, Day);
  if (Year < 1980) or (Year > 2107) then result := 0 else begin
    DecodeTime(DateTime, Hour, Min, Sec, MSec);
    LongRec(result).Lo := (Sec shr 1) or (Min shl 5) or (Hour shl 11);
    LongRec(result).Hi := Day or (Month shl 5) or ((Year - 1980) shl 9);
  end;
end;

function  FileDateToDateTime(FileDate: integer): TDateTime;
begin
  result := EncodeDate(LongRec(FileDate).Hi shr 9 + 1980, LongRec(FileDate).Hi shr 5 and 15, LongRec(FileDate).Hi and 31);
  result := SysAddDatePlusTime(result, EncodeTime(LongRec(FileDate).Lo shr 11, LongRec(FileDate).Lo shr 5 and 63, LongRec(FileDate).Lo and 31 shl 1, 0));
end;
{$else}
function  DateTimeToFileDate(DateTime: TDateTime): integer;
var Year, Month, Day: integer;
    Hour, Min, Sec, MSec: Word;
var tm: TUnixTime;
begin
  DecodeDate(DateTime, Year, Month, Day);
  { Valid range for 32 bit Unix time_t:  1970 through 2038  }
  if (Year < 1970) or (Year > 2038) then
    result := 0 else begin
    DecodeTime(DateTime, Hour, Min, Sec, MSec);
    FillChar(tm, sizeof(tm), 0);
    with tm do begin
      tm_sec := Sec;
      tm_min := Min;
      tm_hour := Hour;
      tm_mday := Day;
      tm_mon  := Month - 1;
      tm_year := Year - 1900;
      tm_isdst := -1;
    end;
    result := mktime(tm);
  end;
end;

function  FileDateToDateTime(FileDate: integer): TDateTime;
var UT: TUnixTime;
begin
  localtime_r(@FileDate, UT);
  result := EncodeDate(UT.tm_year + 1900, UT.tm_mon + 1, UT.tm_mday)
  result := SysAddDatePlusTime(result, EncodeTime(UT.tm_hour, UT.tm_min, UT.tm_sec, 0));
end;
{$endif}

function  DateTimeToTimeStamp(DateTime: TDateTime): TTimeStamp;
{$IFDEF FPC}
begin
  result.Time := Round(Abs(Frac(DateTime)) * MSecsPerDay);
  result.Date := DateDelta + Trunc(DateTime);
end;
{$ELSE FPC}
asm // faster version by AB
     push  eax
     mov   ecx,MSecsPerDay
     fld   datetime
     fmul  fmsecsperday
     sub   esp,8
     fistp qword ptr [esp]
     pop   eax
     pop   edx
     or    edx,edx
     jns   @@1
     neg   edx
     neg   eax
     sbb   edx,0
     div   ecx
     neg   eax
     jmp   @@2
@@1: div   ecx
@@2: add   eax,datedelta
     pop   ecx
     mov   [ecx].ttimestamp.time,edx
     mov   [ecx].ttimestamp.date,eax
end;
{$ENDIF FPC}

function  TimeStampToDateTime(const TimeStamp: TTimeStamp): TDateTime;
begin
  result := TimeStamp.Date - DateDelta;
  SysAddDatePlusTime(result, TimeStamp.Time / MSecsPerDay);
end;

function  DayOfWeek(const DateTime: TDateTime): {$IFDEF FPC}integer{$ELSE}word{$ENDIF};
begin
  result := ((DateDelta + Trunc(DateTime)) mod 7) + 1;
end;

function  SysAddDatePlusTime(const BaseDate: TDateTime; const PlusTime: TDateTime): TDateTime;
begin
  if BaseDate>=0 then
    result := BaseDate + PlusTime
  else
    result := BaseDate - PlusTime;
end;

function  SysCurrDT(WithDate, WithTime: boolean): TDateTime;
{$ifdef MSWindows}
var SystemTime: TSystemTime;
begin
  result := 0;
  LLCL_GetLocalTime(SystemTime);
  with SystemTime do
    begin
      if WithDate then result := EncodeDate(wYear, wMonth, wDay);
      if WithTime then result := SysAddDatePlusTime(result, EncodeTime(wHour, wMinute, wSecond, wMilliSeconds));
    end;
end;
{$else}
var T: TTime_T;
    TV: TTimeVal;
    UT: TUnixTime;
begin
  result := 0;
  gettimeofday(TV, nil);
  T := TV.tv_sec;
  localtime_r(@T, UT);
  if WithDate then result := EncodeDate(UT.tm_year + 1900, UT.tm_mon + 1, UT.tm_mday);
  if WithTime then result := SysAddDatePlusTime(result, EncodeTime(UT.tm_hour, UT.tm_min, UT.tm_sec, TV.tv_usec div 1000));
end;
{$endif}

function  Now: TDateTime;
begin
  result := SysCurrDT(true, true);
end;

function  Date: TDateTime;
begin
  result := SysCurrDT(true, false);
end;

function  Time: TDateTime;
begin
  result := SysCurrDT(false, true);
end;

function  SysDTToStr(const DateTime: TDateTime; WithDate, WithTime: boolean): string;
var Y,M,D: word;  // 'YYYY/MM/DD hh:mm:ss'
    H,MI,S,MS: word;
begin
  result := '';
  if WithDate then
    begin
      DecodeDate(DateTime, Y, M, D);
      result := result + Format('%.4d', [Y]) + SYSLLCL_DATE_SEP + Format('%.2d', [M]) + SYSLLCL_DATE_SEP + Format('%.2d', [D]);
    end;
  if WithDate and WithTime then
    result := result + SYSLLCL_DATETIME_SEP;
  if WithTime then
    begin
      DecodeTime(DateTime, H, MI, S, MS);
      result := result + Format('%.2d', [H]) + SYSLLCL_TIME_SEP + Format('%.2d', [MI]) + SYSLLCL_TIME_SEP + Format('%.2d', [S]);
    end;
end;

{$ifdef MSWindows}
procedure DateTimeToSystemTime({$IFDEF FPC}{$ELSE}const {$ENDIF}DateTime: TDateTime; var SystemTime: TSystemTime);
begin
  with SystemTime do
    begin
      DecodeDate(DateTime, wYear, wMonth, wDay);
      wDayOfWeek := {$IFDEF FPC}SysUtils.{$ENDIF}DayOfWeek(DateTime) - 1;   // DayOfWeek = wDayOfWeek for FPC
      DecodeTime(DateTime, wHour, wMinute, wSecond, wMilliseconds);
    end;
end;

function  SystemTimeToDateTime(const SystemTime: TSystemTime): TDateTime;
begin
  with SystemTime do
    begin
      result := EncodeDate(wYear, wMonth, wDay);
      result := SysAddDatePlusTime(result, EncodeTime(wHour, wMinute, wSecond, wMilliSeconds));
    end;
end;

function  TrySystemTimeToDateTime(const SystemTime: TSystemTime; out DateTime: TDateTime): boolean;
var TmpTime: TDateTime;
begin
  with SystemTime do
    begin
      result := TryEncodeDate(wYear, wMonth, wDay, DateTime);
      if result then
        begin
          result := TryEncodeTime(wHour, wMinute, wSecond, wMilliSeconds, TmpTime);
          if result then
            DateTime := SysAddDatePlusTime(DateTime, TmpTime);
        end;
    end;
end;
{$endif}

function  DateTimeToStr(const DateTime: TDateTime): string;
begin
  result := SysDTToStr(DateTime, true, true);
end;

function  DateToStr(const DateTime: TDateTime): string;
begin
  result := SysDTToStr(DateTime, true, false);
end;

function  TimeToStr(const DateTime: TDateTime): string;
begin
  result := SysDTToStr(DateTime, false, true);
end;

// Only for 'YYYY/MM/DD hh:mm:ss' (see Date/Time To Str functions)

function  TryStrToDate(const S: string; out Value: TDateTime): boolean;
var Y, M, D: cardinal;
begin
  result := false;
  if length(S)<>10 then exit;
  Y := ord(S[1])*1000+ord(S[2])*100+ord(S[3])*10+ord(S[4])-(48+480+4800+48000);
  M := ord(S[6])*10+ord(S[7])-(48+480);
  D := ord(S[9])*10+ord(S[10])-(48+480);
  // (Reduced checks on year)
  result := (Y<=3000) and (Y>=1) and (M in [1..12]) and (D<=MonthDays[true][M]) and (D<>0);
  if result then
    Value := EncodeDate(Y, M, D);
end;

function  TryStrToTime(const S: string; out Value: TDateTime): boolean;
var HH, MM, SS: cardinal;
begin
  result := false;
  if length(S)<>8 then exit;
  HH := ord(S[1])*10+ord(S[2])-(48+480);
  MM := ord(S[4])*10+ord(S[5])-(48+480);
  SS := ord(S[7])*10+ord(S[8])-(48+480);
  result := (HH<=23) and (MM<=59) and (SS<=59);
  if result then
    Value := EncodeTime(HH, MM, SS, 0);
end;

function  TryStrToDateTime(const S: string; out Value: TDateTime): boolean;
var TimeValue: TDateTime;
begin
  result := false;
  if length(S)<>19 then exit;
  result := TryStrToDate(Copy(S, 1, 10), Value);
  if result then
    begin
      result := TryStrToTime(Copy(S, 12, 8), TimeValue);
      if result then
        SysAddDatePlusTime(Value, TimeValue);
    end;
end;

{$ifdef MSWindows}
function  FileCreate(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): THandle; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
var LastOSError: cardinal;
begin
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_CreateFile{$ELSE}LLCL_CreateFile{$ENDIF}
      (@FileName[1], GENERIC_READ or GENERIC_WRITE,
      0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0, LastOSError);
end;

function  InternalFileOpen(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; Mode: cardinal; var LastOSError: cardinal): THandle;
const
  AccessMode: array[0..2] of cardinal = (GENERIC_READ,GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of cardinal = (0,0,FILE_SHARE_READ,FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_CreateFile{$ELSE}LLCL_CreateFile{$ENDIF}
      (@FileName[1], AccessMode[Mode and 3],
      ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL, 0, LastOSError);
end;

function  FileOpen(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; Mode: cardinal): THandle; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
var LastOSError: cardinal;
begin
  result := InternalFileOpen(FileName, Mode, LastOSError);
end;

procedure FileClose(Handle: THandle);
begin
  LLCL_CloseHandle(Handle);
end;

function  FileSeek(Handle: THandle; Offset, Origin: integer): integer;
begin
  result := LLCL_SetFilePointer(Handle, Offset, nil, Origin);
end;

function  FileSeek(Handle: THandle; Offset: int64; Origin: integer): int64;
var HighVal, LowVal: integer;
begin
  HighVal := integer(int64(Offset shr 32));
  LowVal := Offset and $FFFFFFFF;
  LowVal := LLCL_SetFilePointer(Handle, LowVal, @HighVal, Origin);
  if LowVal = INVALID_SET_FILE_POINTER then
    result := int64(INVALID_SET_FILE_POINTER)
  else
    result := int64(int64(HighVal) shl 32) + int64(LowVal);
end;

function  FileRead(Handle: THandle; var Buffer; Count: cardinal): integer;
begin
  if not LLCL_ReadFile(Handle, Buffer, Count, cardinal(result), nil) then
    result := 0;
end;

function  FileWrite(Handle: THandle; const Buffer; Count: cardinal): integer;
begin
  if not LLCL_WriteFile(Handle, Buffer, Count, cardinal(result), nil) then
    result := 0;
end;

function  SysFileAttributes(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; var LastWriteTime: TFileTime): boolean;
var FileAttribute: TWin32FileAttributeData;
var Handle: THandle;
var FindData: TCustomWin32FindData;
var OutFileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF};
var LastOSError: cardinal;
begin
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_GetFileAttributesEx{$ELSE}LLCL_GetFileAttributesEx{$ENDIF}
      (@FileName[1], GetFileExInfoStandard, @FileAttribute, LastOSError);
  if result then
    begin
      LastWriteTime := FileAttribute.ftLastWriteTime;
      result := ((FileAttribute.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0);
    end
  else
    if (LastOSError=ERROR_SHARING_VIOLATION) or (LastOSError=ERROR_LOCK_VIOLATION) or (LastOSError=ERROR_SHARING_BUFFER_EXCEEDED) then
      begin
        Handle := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_FindFirstNextFile{$ELSE}LLCLS_FindFirstNextFile{$ENDIF}
            (FileName, 0, FindData, OutFileName, LastOSError);
        if Handle<>INVALID_HANDLE_VALUE then
          begin
            LLCL_FindClose(Handle);
            LastWriteTime := FindData.ftLastWriteTime;
            result := ((FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0);
          end;
      end;
end;

function  FileExists(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
var Dummy: TFileTime;
begin
  result := SysFileAttributes(FileName, Dummy);
end;

function  FileGetDate(Handle: THandle): integer;
var FileTime, LocalFileTime: TFileTime;
begin
  if LLCL_GetFileTime(Handle, nil, nil, @FileTime) then
    if LLCL_FileTimeToLocalFileTime(FileTime, LocalFileTime) and
      LLCL_FileTimeToDosDateTime(LocalFileTime, LongRec(result).Hi,
        LongRec(result).Lo) then exit;
  result := -1;
end;

function  FileSetDate(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; Age: integer): integer;
var Handle: THandle;
var LastOSError: cardinal;
begin
  Handle := InternalFileOpen(FileName, fmOpenWrite, LastOSError);
  if Handle = THandle(-1) then
    result := LastOSError
  else
    begin
      result := FileSetDate(Handle, Age);
      FileClose(Handle);
    end;
end;

function  FileSetDate(Handle: THandle; Age: integer): integer;
var LocalFileTime, FileTime: TFileTime;
begin
  if LLCL_DosDateTimeToFileTime(LongRec(Age).Hi, LongRec(Age).Lo, LocalFileTime) and
    LLCL_LocalFileTimeToFileTime(LocalFileTime, FileTime) and
    LLCL_SetFileTime(Handle, nil, nil, @FileTime) then
    result := 0
  else
    result := LLCL_GetLastError();
end;

function  InternalFileAge(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; var LastWriteTime: TFileTime): boolean;
begin
  result := SysFileAttributes(FileName, LastWriteTime);
end;

function  FileAge(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): integer;
var TmpFileTime, LocalFileTime: TFileTime;
begin
  if InternalFileAge(FileName, TmpFileTime) then
    begin
      LLCL_FileTimeToLocalFileTime(TmpFileTime, LocalFileTime);
      if LLCL_FileTimeToDosDateTime(LocalFileTime, LongRec(result).Hi, LongRec(result).Lo) then
        exit;
    end;
  result := -1;
end;

function  FileAge(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; out FileDateTime: TDateTime): boolean;
var TmpFileTime: TFileTime;
var TmpSystemTime: TSystemTime;
begin
  result := InternalFileAge(FileName, TmpFileTime);
  if result then
    begin
      result := LLCL_FileTimeToSystemTime(TmpFileTime, TmpSystemTime);
      if result then
        result := TrySystemTimeToDateTime(TmpSystemTime, FileDateTime);
    end;
end;

function  GetFileVersion(const aFileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): cardinal; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
var Handle, InfoSize, VerSize: cardinal;
var VerBuf: pointer;
var FI: PVSFixedFileInfo;
begin
  result := cardinal(-1);
  InfoSize := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_GetFileVersionInfoSize{$ELSE}LLCL_GetFileVersionInfoSize{$ENDIF}
      (@aFileName[1], Handle);
  if InfoSize<>0 then
    begin
      GetMem(VerBuf, InfoSize);
      if {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_GetFileVersionInfo{$ELSE}LLCL_GetFileVersionInfo{$ENDIF}
          (@aFileName[1], Handle, InfoSize, VerBuf) then
        if {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_VerQueryValue{$ELSE}LLCL_VerQueryValue{$ENDIF}
            (VerBuf, '\', pointer(FI), VerSize) then
          result := FI^.dwFileVersionMS;
      FreeMem(VerBuf);
    end;
end;

function  DeleteFile(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_DeleteFile{$ELSE}LLCL_DeleteFile{$ENDIF}
      (@FileName[1]);
end;

function  RenameFile(const OldName, NewName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_MoveFile{$ELSE}LLCL_MoveFile{$ENDIF}
      (@OldName[1], @NewName[1]);
end;

{$else}     // Linux version of the code:

function  FileCreate(const FileName: string): integer;
begin
  result := open(pointer(FileName), O_RDWR or O_CREAT or O_TRUNC, FileAccessRights);
end;

function  FileOpen(const FileName: string; Mode: cardinal): integer;
const ShareMode: array[0..fmShareDenyNone shr 4] of Byte = (0, F_WRLCK, F_RDLCK, 0);
var FileHandle, Tvar: integer;
    LockVar: TFlock;
    smode: Byte;
begin
  result := -1;
  if FileExists(FileName) and ((Mode and 3) <= fmOpenReadWrite) and
     ((Mode and $F0) <= fmShareDenyNone) then begin
    FileHandle := open(pointer(FileName), (Mode and 3), FileAccessRights);
    if FileHandle = -1 then exit;
    smode := Mode and $F0 shr 4;
    if ShareMode[smode]<>0 then begin
      with LockVar do begin
        l_whence := SEEK_SET;
        l_start := 0;
        l_len := 0;
        l_type := ShareMode[smode];
      end;
      Tvar :=  fcntl(FileHandle, F_SETLK, LockVar);
      if Tvar = -1 then begin
        __close(FileHandle);
        exit;
      end;
    end;
    result := FileHandle;
  end;
end;

procedure FileClose(Handle: integer);
begin
  __close(Handle); // No need to unlock since all locks are released on close.
end;

function  FileSeek(Handle: THandle; Offset, Origin: integer): integer;
begin
  result :=  __lseek(Handle, Offset, Origin);
end;

function  FileSeek(Handle: THandle; Offset: int64; Origin: integer): int64;
begin
  result :=  __lseek64(Handle, Offset, Origin);
end;

function  FileRead(Handle: integer; var Buffer; Count: cardinal): integer;
begin
  result := __read(Handle, Buffer, Count);
end;

function  FileWrite(Handle: integer; const Buffer; Count: cardinal): integer;
begin
  result := __write(Handle, Buffer, Count);
end;

function  FileExists(const FileName: string): boolean;
begin
  result := (euidaccess(pointer(FileName), F_OK) = 0);
end;

function  FileGetDate(Handle: THandle): integer;
var st: TStatBuf;
begin
  if fstat(Handle, st) = 0 then
    result := st.st_mtime else
    result := -1;
end;

function  FileSetDate(const FileName: string; Age: integer): integer;
var ut: TUTimeBuffer;
begin
  result := 0;
  ut.actime := Age;
  ut.modtime := Age;
  if utime(pointer(FileName), @ut) = -1 then
    result := GetLastError;
end;

function  FileAge(const FileName: string): integer;
var st: TStatBuf;
begin
  if stat(pointer(FileName), st) = 0 then
    result := st.st_mtime else
    result := -1;
end;

{$endif}    // End of Linux-specific part

{$IFDEF LLCL_FPC_UNISYS}
// RawByteString version

function  FileCreate(const FileName: rawbytestring): THandle; overload;
begin
  result := FileCreate(unicodestring(FileName));
end;

function  FileOpen(const FileName: rawbytestring; Mode: cardinal): THandle; overload;
begin
  result := FileOpen(unicodestring(FileName), Mode);
end;

function  FileExists(const FileName: rawbytestring): boolean; overload;
begin
  result := FileExists(unicodestring(FileName));
end;

function  FileSetDate(const FileName: rawbytestring; Age: integer): integer; overload;
begin
  result := FileSetDate(unicodestring(FileName), Age);
end;

function  FileAge(const FileName: rawbytestring): integer; overload;
begin
  result := FileAge(unicodestring(FileName));
end;

function  FileAge(const FileName: rawbytestring; out FileDateTime: TDateTime): boolean; overload;
begin
  result := FileAge(unicodestring(FileName), FileDateTime);
end;

function  GetFileVersion(const aFileName: rawbytestring): cardinal; overload;
begin
  result := GetFileVersion(unicodestring(aFileName));
end;

function  DeleteFile(const FileName: rawbytestring): boolean; overload;
begin
  result := DeleteFile(unicodestring(FileName));
end;

function  RenameFile(const OldName, NewName: rawbytestring): boolean; overload;
begin
  result := RenameFile(unicodestring(OldName), unicodestring(NewName));
end;

{$ENDIF LLCL_FPC_UNISYS}

function  FindMatchingFile(var F: {$IFDEF LLCL_FPC_UNISYS}TUnicodeSearchRec{$ELSE}TSearchRec{$ENDIF}): integer;
{$ifdef MSWindows}
var LocalFileTime: TFileTime;
var FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF};
var LastOSError: cardinal;
begin
  with F do begin
    while (FindData.dwFileAttributes and ExcludeAttr)<>0 do
      begin
        if {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_FindFirstNextFile{$ELSE}LLCLS_FindFirstNextFile{$ENDIF}
            ('', FindHandle, FindData, FileName, LastOSError)=0 then
          begin
            result := LastOSError;
            exit;
          end;
        Name := FileName;
      end;
    LLCL_FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    LLCL_FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi, LongRec(Time).Lo);
    Size := int64(int64(FindData.nFileSizeHigh) shl 32) + int64(FindData.nFileSizeLow);
    Attr := FindData.dwFileAttributes;
//    Name := FindData.cFileName;   // (Already done)
  end;
  result := 0;
end;
{$else}
var PtrDirEnt: PDirEnt;
  Scratch: TDirEnt;
  StatBuf: TStatBuf;
  LinkStatBuf: TStatBuf;
  FName: string;
  Attr: integer;
  Mode: mode_t;
begin
  result := -1;
  PtrDirEnt := nil;
  if readdir_r(F.FindHandle, @Scratch, PtrDirEnt)<>0 then
    exit;
  while PtrDirEnt<>nil do begin
    if fnmatch(PChar(F.Pattern), PtrDirEnt.d_name, 0) = 0 then begin
      FName := F.PathOnly + string(PtrDirEnt.d_name);
      if lstat(pointer(FName), StatBuf) = 0 then begin
        Attr := 0;
        Mode := StatBuf.st_mode;
        if S_ISDIR(Mode) then
          Attr := Attr or faDirectory
        else
        if not S_ISREG(Mode) then begin
          if S_ISLNK(Mode) then begin
            Attr := Attr or faSymLink;
            if (stat(pointer(FName), LinkStatBuf) = 0) and S_ISDIR(LinkStatBuf.st_mode) then
                Attr := Attr or faDirectory
          end;
          Attr := Attr or faSysFile;
        end;
        if (PtrDirEnt.d_name[0] = '.') and (PtrDirEnt.d_name[1]<>#0) then begin
          if not ((PtrDirEnt.d_name[1] = '.') and (PtrDirEnt.d_name[2] = #0)) then
            Attr := Attr or faHidden;
        end;
        if euidaccess(pointer(FName), W_OK)<>0 then
          Attr := Attr or faReadOnly;
        if Attr and F.ExcludeAttr = 0 then begin
          F.Size := StatBuf.st_size;
          F.Attr := Attr;
          F.Mode := StatBuf.st_mode;
          F.Name := PtrDirEnt.d_name;
          F.Time := StatBuf.st_mtime;
          result := 0;
          break;
        end;
      end;
    end;
    result := -1;
    if readdir_r(F.FindHandle, @Scratch, PtrDirEnt)<>0 then
      break;
  end // end of While
end;
{$endif}

function  FindFirst(const Path: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; Attr: integer; var F: {$IFDEF LLCL_FPC_UNISYS}TUnicodeSearchRec{$ELSE}TSearchRec{$ENDIF}): integer; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
const faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
{$ifdef MSWindows}
var FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF};
var LastOSError: cardinal;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_FindFirstNextFile{$ELSE}LLCLS_FindFirstNextFile{$ENDIF}
      (Path, 0, F.FindData, FileName, LastOSError);
  if F.FindHandle<>INVALID_HANDLE_VALUE then
    begin
      F.Name := FileName;
      result := FindMatchingFile(F);
      if result<>0 then FindClose(F);
    end
  else
    result := LastOSError;
end;
{$else}
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.PathOnly := ExtractFilePath(Path);
  F.Pattern := ExtractFileName(Path);
  if F.PathOnly = '' then
    F.PathOnly := IncludeTrailingPathDelimiter(GetCurrentDir);
  F.FindHandle := opendir(pointer(F.PathOnly));
  if F.FindHandle<>nil then begin
    result := FindMatchingFile(F);
    if result<>0 then
      FindClose(F);
  end else
    result := GetLastError;
end;
{$endif}

function  FindNext(var F: {$IFDEF LLCL_FPC_UNISYS}TUnicodeSearchRec{$ELSE}TSearchRec{$ENDIF}): integer; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
{$ifdef MSWindows}
var FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF};
var LastOSError: cardinal;
begin
  if {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_FindFirstNextFile{$ELSE}LLCLS_FindFirstNextFile{$ENDIF}
      ('', F.FindHandle, F.FindData, FileName, LastOSError)<>0 then
    begin
      F.Name := FileName;
      result := FindMatchingFile(F);
    end
  else
    result := LastOSError;
end;
{$else}
begin
  result := FindMatchingFile(F);
end;
{$endif}

procedure FindClose(var F: {$IFDEF LLCL_FPC_UNISYS}TUnicodeSearchRec{$ELSE}TSearchRec{$ENDIF}); {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin
{$ifdef MSWindows}
  if F.FindHandle<>INVALID_HANDLE_VALUE then
    begin
      LLCL_FindClose(F.FindHandle);
      F.FindHandle := INVALID_HANDLE_VALUE;
    end;
{$else}
  if F.FindHandle<>nil then
    begin
      closedir(F.FindHandle);
      F.FindHandle := nil;
    end;
{$endif}
end;

function  GetCurrentDir: {$IFDEF FPC_UNICODE_RTL}unicodestring{$ELSE}{$IFDEF LLCL_FPC_CPSTRING}rawbytestring{$ELSE}string{$ENDIF}{$ENDIF};
begin
  GetDir(0, result);
end;

function  SetCurrentDir(const NewDir: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin
  {$ifopt I+}{$define IDef_SetCurrentDir}{$I-}{$endif}
  ChDir(NewDir);
  result := (IOResult()=0);
  {$ifdef IDef_SetCurrentDir}{$I+}{$endif}{$undef IDef_SetCurrentDir}
end;

function  DirectoryExists(const Directory: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
{$ifdef MSWindows}
var code: integer;
begin
  code := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_GetFileAttributes{$ELSE}LLCL_GetFileAttributes{$ENDIF}
      (@Directory[1]);
  result := (code<>INVALID_FILE_ATTRIBUTES) and ((FILE_ATTRIBUTE_DIRECTORY and code)<>0);
end;
{$else}
var st: TStatBuf;
begin
  if stat(pointer(Directory), st) = 0 then
    result := S_ISDIR(st.st_mode) else
    result := False;
end;
{$endif}

function  ForceDirectories({$IFDEF FPC}const {$ENDIF}Dir: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
var E: EInOutError;
var TmpDir: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF};
begin
  result := true;
  TmpDir := ExcludeTrailingPathDelimiter(Dir);
  if TmpDir = '' then begin
    E := EInOutError.Create(LLCL_STR_SYSU_CANTCREATEDIR);
    E.ErrorCode := 3;
    raise E;
  end;
  if DirectoryExists(TmpDir) then exit;
{$ifdef MSWindows}
  if (Length(TmpDir) < 3) or (ExtractFilePath(TmpDir) = TmpDir) then
    result := CreateDir(TmpDir)
  else
{$endif}
    result := ForceDirectories(ExtractFilePath(TmpDir)) and CreateDir(TmpDir);
end;

function  CreateDir(const Dir: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin
{$ifdef MSWindows}
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_CreateDirectory{$ELSE}LLCL_CreateDirectory{$ENDIF}
      (@Dir[1], nil);
{$else}
  __mkdir(pointer(Dir), mode_t(-1)) = 0;
{$endif}
end;

function  RemoveDir(const Dir: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin
{$ifdef MSWindows}
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_RemoveDirectory{$ELSE}LLCL_RemoveDirectory{$ENDIF}
      (@Dir[1]);
{$else}
  result := __rmdir(pointer(Dir)) = 0;
{$endif}
end;

{$IFDEF LLCL_FPC_UNISYS}
// RawByteString version

procedure FindSearchRecRawToUni(const F: TRawByteSearchRec; var FF: TUnicodeSearchRec);
begin
  FF.Time := F.Time;
  FF.Size := F.Size;
  FF.Attr := F.Attr;
  FF.Name := unicodestring(F.Name);
  FF.ExcludeAttr := F.ExcludeAttr;
  FF.FindHandle := F.FindHandle;
  Move(F.FindData, FF.FindData, SizeOf(FF.FindData));
end;

procedure FindSearchRecUniToRaw(const F: TUnicodeSearchRec; var FF: TRawByteSearchRec);
begin
  FF.Time := F.Time;
  FF.Size := F.Size;
  FF.Attr := F.Attr;
  FF.Name := rawbytestring(F.Name);
  FF.ExcludeAttr := F.ExcludeAttr;
  FF.FindHandle := F.FindHandle;
  Move(F.FindData, FF.FindData, SizeOf(FF.FindData));
end;

function  FindFirst(const Path: rawbytestring; Attr: integer; var F: TRawByteSearchRec): integer; overload;
var FF: TUnicodeSearchRec;
begin
  result := FindFirst(unicodestring(Path), Attr, FF);
  if result=0 then
    FindSearchRecUniToRaw(FF, F);
end;

function  FindNext(var F: TRawByteSearchRec): integer; overload;
var FF: TUnicodeSearchRec;
begin
  FindSearchRecRawToUni(F, FF);
  result := Findnext(FF);
  if result=0 then
    FindSearchRecUniToRaw(FF, F);
end;

procedure FindClose(var F: TRawByteSearchRec); overload;
begin
  if F.FindHandle<>INVALID_HANDLE_VALUE then
    begin
      LLCL_FindClose(F.FindHandle);
      F.FindHandle := INVALID_HANDLE_VALUE;
    end;
end;

function  SetCurrentDir(const NewDir: rawbytestring): boolean; overload;
begin
  result := SetCurrentDir(unicodestring(NewDir));
end;

function  DirectoryExists(const Directory: rawbytestring): boolean; overload;
begin
  result := DirectoryExists(unicodestring(Directory));
end;

function  ForceDirectories(const Dir: rawbytestring): boolean; overload;
begin
  result :=  ForceDirectories(unicodestring(Dir));
end;

function  CreateDir(const Dir: rawbytestring): boolean; overload;
begin
  result := CreateDir(unicodestring(Dir));
end;

function  RemoveDir(const Dir: rawbytestring): boolean; overload;
begin
  result := RemoveDir(unicodestring(Dir));
end;

{$ENDIF LLCL_FPC_UNISYS}

function  ExtractFilePath(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
var i: integer;
begin
  i := LastDelimiter({$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}(PathDelim{$ifndef Linux}+DriveDelim{$endif}), FileName);
  result := Copy(FileName, 1, i);
end;

function  ExtractFileDir(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
var i: integer;
begin
  i := LastDelimiter({$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}(PathDelim{$ifndef Linux}+DriveDelim{$endif}), Filename);
  if (i>1) and (FileName[i]=PathDelim) and
     (not (FileName[i-1] in [PathDelim{$ifndef Linux}, DriveDelim{$endif}])) then
    Dec(i);
  result := Copy(FileName, 1, i);
end;

function  ExtractFileName(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
var i: integer;
begin
  i := LastDelimiter({$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}(PathDelim{$ifndef Linux}+DriveDelim{$endif}), FileName);
  result := Copy(FileName, i+1, MaxInt);
end;

function  ExtractFileExt(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
var i: integer;
begin
  i := LastDelimiter({$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}('.' + PathDelim+DriveDelim), FileName);
  if (i>0) and (FileName[i]='.') then
    result := Copy(FileName, i, MaxInt) else
    result := '';
end;

function ExtractFileDrive(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin // naive implementation
{$ifdef MSWindows}
  if (Length(FileName)>=2) and (FileName[2]=DriveDelim) then
    result := Copy(FileName, 1, 2) else
    result := '';
{$else}
  result := '';
{$endif}
end;

function  ChangeFileExt(const FileName, Extension: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
var i: integer;
begin
  i := LastDelimiter({$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}('.' + PathDelim{$ifndef Linux}+DriveDelim{$endif}), Filename);
  if (i = 0) or (FileName[i]<>'.') then i := MaxInt;
  result := Copy(FileName, 1, i-1) + Extension;
end;

function  LastDelimiter(const Delimiters, S: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): integer; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin
  result := Length(S);
  while result>0 do
    if (S[result]<>#0) and (Pos(S[result],Delimiters)=0) then
      Dec(result) else
      break;
end;

function  IsPathDelimiter(const S: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; Index: integer): boolean; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin
  Dec(Index);
  result := (cardinal(Index)<cardinal(Length(S))) and (S[Index+1]=PathDelim);
end;

function  IncludeTrailingPathDelimiter(const S: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin
  result := S;
  if not IsPathDelimiter(result,Length(result)) then
    result := result + PathDelim;
end;

function  ExcludeTrailingPathDelimiter(const S: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin
  result := S;
  if IsPathDelimiter(result, Length(result)) then
    SetLength(result, Length(result)-1);
end;

{$ifdef MSWindows}
function  ExpandFileName(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}): {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
begin
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_GetFullPathName{$ELSE}LLCLS_GetFullPathName{$ENDIF}
      (FileName);
end;

function  GetModuleName(Module: HMODULE): {$IFDEF FPC_UNICODE_RTL}unicodestring{$ELSE}{$IFDEF LLCL_FPC_CPSTRING}rawbytestring{$ELSE}string{$ENDIF}{$ENDIF};
begin
  result := {$IFDEF FPC_UNICODE_RTL}unicodestring{$ELSE}{$IFDEF LLCL_FPC_CPSTRING}rawbytestring{$ELSE}string{$ENDIF}{$ENDIF}(
    {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_GetModuleFileName{$ELSE}LLCLS_GetModuleFileName{$ENDIF}
      (Module));
end;

function  InternalGetDiskSpace(Drive: byte; var TotalSpace, FreeSpaceAvailable: int64): bool;
var sDrive: string;
begin
  if Drive>0 then
    sDrive := char(Drive + pred(ord('A'))) + DriveDelim + PathDelim     // (bug in LVCL)
  else
    sDrive := '';
  result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_GetDiskSpace{$ELSE}LLCLS_GetDiskSpace{$ENDIF}
      ({$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}(sDrive), TotalSpace, FreeSpaceAvailable);
end;

function  DiskFree(Drive: byte): int64;   // (Requires at least Win95 OSR2)
var TotalSpace: int64;
begin
  if not InternalGetDiskSpace(Drive, TotalSpace, result) then
    result := -1;
end;

function  DiskSize(Drive: byte): int64;   // (Requires at least Win95 OSR2)
var FreeSpace: int64;
begin
  if not InternalGetDiskSpace(Drive, result, FreeSpace) then
    result := -1;
end;
{$endif}

{$IFDEF LLCL_FPC_UNISYS}
// RawByteString version

function  ExtractFilePath(const FileName: rawbytestring): rawbytestring; overload;
var i: integer;
begin
  i := LastDelimiter(rawbytestring(PathDelim{$ifndef Linux}+DriveDelim{$endif}), FileName);
  result := Copy(FileName, 1, i);
end;

function  ExtractFileDir(const FileName: rawbytestring): rawbytestring; overload;
var i: integer;
begin
  i := LastDelimiter(rawbytestring(PathDelim{$ifndef Linux}+DriveDelim{$endif}), Filename);
  if (i>1) and (FileName[i]=PathDelim) and
     (not (FileName[i-1] in [PathDelim{$ifndef Linux}, DriveDelim{$endif}])) then
    Dec(i);
  result := Copy(FileName, 1, i);
end;

function  ExtractFileName(const FileName: rawbytestring): rawbytestring; overload;
var i: integer;
begin
  i := LastDelimiter(rawbytestring(PathDelim{$ifndef Linux}+DriveDelim{$endif}), FileName);
  result := Copy(FileName, i+1, MaxInt);
end;

function  ExtractFileExt(const FileName: rawbytestring): rawbytestring; overload;
var i: integer;
begin
  i := LastDelimiter(rawbytestring('.' + PathDelim{$ifndef Linux}+DriveDelim{$endif}), FileName);
  if (i>0) and (FileName[i]='.') then
    result := Copy(FileName, i, MaxInt) else
    result := '';
end;

function ExtractFileDrive(const FileName: rawbytestring): rawbytestring; overload;
begin // naive implementation
{$ifdef MSWindows}
  if (Length(FileName)>=2) and (FileName[2]=DriveDelim) then
    result := Copy(FileName, 1, 2) else
    result := '';
{$else}
  result := '';
{$endif}
end;

function  ChangeFileExt(const FileName, Extension: rawbytestring): rawbytestring; overload;
var i: integer;
begin
  i := LastDelimiter(rawbytestring('.' + PathDelim{$ifndef Linux}+DriveDelim{$endif}), Filename);
  if (i = 0) or (FileName[i]<>'.') then i := MaxInt;
  result := Copy(FileName, 1, i-1) + Extension;
end;

function  LastDelimiter(const Delimiters, S: rawbytestring): integer; overload;
begin
  result := Length(S);
  while result>0 do
    if (S[result]<>#0) and (Pos(S[result],Delimiters)=0) then
      Dec(result) else
      break;
end;

function  IsPathDelimiter(const S: rawbytestring; Index: integer): boolean; overload;
begin
  Dec(Index);
  result := (cardinal(Index)<cardinal(Length(S))) and (S[Index+1]=PathDelim);
end;

function  IncludeTrailingPathDelimiter(const S: rawbytestring): rawbytestring; overload;
begin
  result := S;
  if not IsPathDelimiter(result,Length(result)) then
    result := result + PathDelim;
end;

function  ExcludeTrailingPathDelimiter(const S: rawbytestring): rawbytestring; overload;
begin
  result := S;
  if IsPathDelimiter(result, Length(result)) then
    SetLength(result, Length(result)-1);
end;

{$ifdef MSWindows}

function  ExpandFileName(const FileName: rawbytestring): rawbytestring; overload;
begin
  result := rawbytestring(ExpandFileName(unicodestring(FileName)));
end;

function  SafeLoadLibrary(const FileName: rawbytestring; ErrorMode: UINT = SEM_NOOPENFILEERRORBOX): HMODULE; overload;
begin
  result := SafeLoadLibrary(unicodestring(FileName), ErrorMode);
end;

{$endif}

{$ENDIF LLCL_FPC_UNISYS}

procedure OutOfMemoryError;
begin
  raise Exception.CreateFmt(LLCL_STR_SYSU_OUTOFMEMORY, [203]);
end;

function  SysErrorMessage(ErrorCode: integer): {$IFDEF FPC_UNICODE_RTL}unicodestring{$ELSE}{$IFDEF LLCL_FPC_CPSTRING}rawbytestring{$ELSE}string{$ENDIF}{$ENDIF};
{$ifdef MSWindows}
{$IFNDEF FPC}var L: cardinal;{$ENDIF}
begin
  result := {$IFDEF FPC_UNICODE_RTL}unicodestring{$ELSE}{$IFDEF LLCL_FPC_CPSTRING}rawbytestring{$ELSE}string{$ENDIF}{$ENDIF}(
    {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_FormatMessage{$ELSE}LLCLS_FormatMessage{$ENDIF}
      (FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS or
      FORMAT_MESSAGE_ARGUMENT_ARRAY, nil, ErrorCode, 0, nil));
{$IFNDEF FPC}
  L := length(result);
  while (L > 0) and (ord(result[L]) in [0..32,ord('.')]) do Dec(L);
  SetLength(result, L);
{$ENDIF NFPC}
end;
{$else}
var Buffer: array[0..255] of Char;
begin
  result := strerror_r(ErrorCode, Buffer, sizeof(Buffer));
end;
{$endif}

procedure Abort;
begin
  raise EAbort.Create(LLCL_STR_SYSU_ABORT);
end;

procedure RaiseLastOSError;
var LastError: integer;
var Error: EOSError;
begin
  LastError := LLCL_GetLastError();
  if LastError=0 then exit;
  Error := EOSError.CreateFmt(LLCL_STR_SYSU_OSERROR, [LastError, SysErrorMessage(LastError)]);
  Error.ErrorCode := LastError;
  raise Error;
end;

procedure Sleep(milliseconds: cardinal);
begin
{$ifdef MSWindows}
  LLCL_Sleep(milliseconds);
{$else}
  usleep(milliseconds * 1000);  // usleep is in microseconds
{$endif}
end;

procedure Beep;
begin
  LLCL_MessageBeep(0);
end;

procedure FreeAndNil(var obj);
var tmp: TObject;
begin
  tmp := TObject(obj);
  pointer(obj) := nil;
  tmp.free;
end;

function  AllocMem(Size: nativeuint): pointer;
begin
  GetMem(result, Size);
  FillChar(result^, Size, 0);
end;

function  CompareMem(P1, P2: pointer; Length: integer): boolean;
{$IFDEF FPC}
begin
  result := (CompareByte(P1^, P2^, Length) = 0);
end;
{$ELSE FPC}
asm
  push  ebx
  sub   ecx, 8
  jl    @@Small
  mov   ebx, [eax]         {Compare First 4 Bytes}
  cmp   ebx, [edx]
  jne   @@False
  lea   ebx, [eax+ecx]     {Compare Last 8 Bytes}
  add   edx, ecx
  mov   eax, [ebx]
  cmp   eax, [edx]
  jne   @@False
  mov   eax, [ebx+4]
  cmp   eax, [edx+4]
  jne   @@False
  sub   ecx, 4
  jle   @@True             {All Bytes already Compared}
  neg   ecx                {-(Length-12)}
  add   ecx, ebx           {DWORD Align Reads}
  and   ecx, -4
  sub   ecx, ebx
@@LargeLoop:               {Compare 8 Bytes per Loop}
  mov   eax, [ebx+ecx]
  cmp   eax, [edx+ecx]
  jne   @@False
  mov   eax, [ebx+ecx+4]
  cmp   eax, [edx+ecx+4]
  jne   @@False
  add   ecx, 8
  jl    @@LargeLoop
@@True:
  mov   eax, 1
  pop   ebx
  ret
@@Small:
  add   ecx, 8
  jle   @@True             {Length <= 0}
@@SmallLoop:
  mov   bl, [eax]
  cmp   bl, [edx]
  jne   @@False
  inc   eax
  inc   edx
  dec   ecx
  jnz   @@SmallLoop
  jmp   @@True
@@False:
  xor   eax, eax
  pop   ebx
end;
{$ENDIF FPC}

{$ifdef MSWindows}
function  SafeLoadLibrary(const FileName: {$IFDEF LLCL_FPC_UNISYS}unicodestring{$ELSE}string{$ENDIF}; ErrorMode: UINT = SEM_NOOPENFILEERRORBOX): HMODULE; {$IFDEF LLCL_FPC_UNISYS}overload;{$ENDIF}
var OldMode: UINT;
var FPUControlWord: word;
{$IFDEF FPC}
var SSECSR: DWORD;
{$ELSE FPC}
{$if Declared(GetMXCSR)}
var SSECSR: DWORD;
{$ifend}
{$ENDIF FPC}
begin
  OldMode := SetErrorMode(ErrorMode);
  try
{$IFDEF FPC}
    FPUControlWord := Get8087CW;
    {$ifdef cpui386}
    if Has_SSE_Support then
    {$endif}
      SSECSR := {$if Declared(GetMXCSR)}GetMXCSR{$else}GetSSECSR{$ifend};
{$ELSE FPC}
    {$if Declared(Get8087CW)}
    FPUControlWord := Get8087CW;
    {$else}
    asm
      FNSTCW  FPUControlWord
    end;
    {$ifend}
    {$if Declared(GetMXCSR)}
    SSECSR := GetMXCSR;
    {$ifend}
{$ENDIF FPC}
    try
      result := {$IFDEF LLCL_FPC_SYSRTL}LLCLSys_LoadLibrary{$ELSE}LLCL_LoadLibrary{$ENDIF}(@Filename[1]);
    finally
{$IFDEF FPC}
      Set8087CW(FPUControlWord);
      {$ifdef cpui386}
      if Has_SSE_Support then
      {$endif}
        {$if Declared(SetMXCSR)}SetMXCSR{$else}SetSSECSR{$ifend}(SSECSR);
{$ELSE FPC}
      {$if Declared(Set8087CW)}
      Set8087CW(FPUControlWord);
      {$else}
      asm
        FNCLEX
        FLDCW FPUControlWord
      end;
      {$ifend}
      {$if Declared(setMXCSR)}
      SetMXCSR(SSECSR);
      {$ifend}
{$ENDIF FPC}
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function  CheckWin32Version(aMajor: integer; aMinor: integer = 0): boolean;
begin
  result := (Win32MajorVersion>aMajor) or
    ((Win32MajorVersion=aMajor) and (Win32MinorVersion>=aMinor));
end;
{$else}
function  GetLastError: integer;
begin
  result := __errno_location^;
end;
{$endif}

{ Exception }

constructor Exception.Create(const Msg: string);
begin
  {$ifdef LLCL_OPT_EXCEPTIONS}
  FMessage := Msg;
  {$else}
  LLCL_MessageBox(0, @Msg[1], nil, MB_ICONSTOP or MB_TASKMODAL or MB_DEFAULT_DESKTOP_ONLY);
  Halt(1);    // LVCL uses Halt(230)
  {$endif}
end;

constructor Exception.CreateFmt(const Msg: string; const Args: array of const);
begin
  Create(Format(Msg, Args));
end;

//------------------------------------------------------------------------------

{$ifdef LLCL_OPT_EXCEPTIONS}
{$IFDEF FPC}
procedure ExceptHandler(ExceptObject: TObject; ExceptAddr: pointer; FrameCount: longint; Frames: PPointer);
{$ELSE FPC}
procedure ExceptHandler(ExceptObject: TObject; ExceptAddr: pointer); far;
{$ENDIF FPC}
begin
  if Exception(ExceptObject).FMessage<>'' then
    LLCL_MessageBox(0, @Exception(ExceptObject).FMessage[1], nil, MB_ICONSTOP or MB_TASKMODAL or MB_DEFAULT_DESKTOP_ONLY);
  Halt(1);    // LVCL uses Halt(230)
end;

{$IFDEF FPC}
procedure ErrorHandler(ErrorCode: integer; ErrorAddr, Frame: pointer);
{$ELSE FPC}
procedure ErrorHandler(ErrorCode: integer; ErrorAddr: pointer);
{$ENDIF FPC}
begin
  raise Exception.CreateFmt(LLCL_STR_SYSU_ERROR, [ErrorCode, ErrorAddr]) at ErrorAddr;
end;

{$IFDEF FPC}
procedure AssertErrorHandler(const aMessage, aFilename: shortstring; aLineNumber: longint; aErrorAddr: pointer);
{$ELSE FPC}
procedure AssertErrorHandler(const aMessage, aFilename: string; aLineNumber: integer; aErrorAddr: pointer);
{$ENDIF FPC}
begin
  raise EAssertionFailed.CreateFmt(LLCL_STR_SYSU_ASSERTERROR, [aMessage, aFileName, aLineNumber, aErrorAddr]);
end;
{$endif}

//------------------------------------------------------------------------------

initialization
{$ifdef MSWindows}
  LLCLS_GetOSVersionA(Win32Platform, Win32MajorVersion, Win32MinorVersion,
        Win32BuildNumber, Win32CSDVersion);
{$endif}
{$ifdef LLCL_OPT_EXCEPTIONS}
  ExceptProc := @ExceptHandler;
  ErrorProc := @ErrorHandler;
  AssertErrorProc := @AssertErrorHandler;
  ExceptionClass := Exception;
{$IFNDEF FPC}
  OldErrorMode := LLCL_SetErrorMode(SEM_NOGPFAULTERRORBOX);
{$ENDIF NFPC}
{$endif}

finalization
{$ifdef LLCL_OPT_EXCEPTIONS}
{$IFNDEF FPC}
  LLCL_SetErrorMode(OldErrorMode);
{$ENDIF NFPC}
  ExceptProc := nil;
  ErrorProc := nil;
  AssertErrorProc := nil;
{$endif}

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
