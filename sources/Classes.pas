unit Classes;

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
    * TReader: ReadStringInts (and StringIntProperty), ReadIntArray added
   Version 1.00:
    * Rect, EStreamError moved from SysUtils to Classes
    * TList reviewed (List, Capacity, ...)
    * TStringList: no more any cast to AnsiStrings
    * TComponent: FindComponent added
    * TComponent: Tag added (removed from TControl)
    * TComponent: CompName renamed in Name (VCL/LCL standard)
    * TComponent: Various modifications (better VCL/LCL standard)
    * TAlignment and TShiftState moved from StdCtrls/Controls to Classes
    * Point and Bounds functions added and Rect modified (VCL/LCL standard)
}

// Original notes from LVCL

{
         LVCL - Very LIGHT VCL
         ----------------------------

   Tiny replacement for the standard VCL Classes.pas
   Just put the LVCL directory in your Project/Options/Directories/SearchPath
   and your .EXE will shrink from 300KB to 30KB

   Notes:
   - implements TComponent+TFileStream+TList+TMemoryStream+TPersistent+TReader
       +TResourceStream+TStream+TStringList
   - compatible with the standard .DFM files
   - only use existing properties in your DFM, otherwise you'll get error on startup
   - TList and TStringList are simplier than standard ones
   - TStrings is not implemented (but mapped to TStringList)
   - TMemoryStream use faster Delphi heap manager, not the slow GlobalAlloc()
   - TThread simple implementation (on Windows only)
   - Cross-Platform: it can be used on (Cross)Kylix under Linux (tested)

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

  Some modifications by Leonid Glazyrin, Feb 2012 <leonid.glazyrin@gmail.com>

  * New types of DFM properties supported: List and Set
  * Some (or maybe all) unsupported (sub)properties in DFM ignored without errors
}

{$IFDEF FPC}
  {$define LLCL_FPC_MODESECTION}
  {$I LLCLFPCInc.inc}             // For mode
  {$undef LLCL_FPC_MODESECTION}
{$ENDIF}

{$I LLCLOptions.inc}      // Options

{.$define debug} // send error messages from TReader in a Console window
{$ifdef debug} {$APPTYPE CONSOLE} {$endif}

{$IFDEF FPC} {$PACKENUM 1} {$ENDIF}   // Mandatory if not in Delphi Mode

//------------------------------------------------------------------------------

interface

uses
  LLCLOSInt, SysUtils,
{$ifdef MSWindows}
  Windows;
{$else}
  Types, LibC;
{$endif}

type
  EClassesError = class(Exception);
  EStreamError = class(Exception);

  TNotifyEvent = procedure(Sender: TObject) of object;

  TPointerList = array of Pointer;
  PPointerList = ^TPointerList;

  TList = class
  private
    fCount: integer;
    fCapacity: integer;
    fOwnObjects: boolean;
    fList: TPointerList;
    procedure FreeObjects(start: integer);
    function  BadIndex(index: integer): boolean;
    procedure Grow;
    procedure SetCount(number: integer);
    procedure SetCapacity(number: integer);
    function  GetItem(index: integer): pointer;
    procedure SetItem(index: integer; item: pointer);
    function  GetList(): PPointerList;
  public
    destructor Destroy; override;
    function  Add(item: pointer): integer;
    procedure Insert(index: integer; item: pointer);
    procedure Remove(item: pointer);
    procedure Delete(index: integer);
    function  IndexOf(item: pointer): integer;
    procedure Clear;
    property  Count: integer read fCount write SetCount;
    property  Capacity: integer read fCapacity write SetCapacity;
    property  Items[index: integer]: pointer read GetItem write SetItem; default;
    // can be used in order to speed up code a little bit (but no index check)
    property  List: PPointerList read GetList;
  end;

  TObjectList = class(TList)
  public
    constructor Create(aOwnObjects: boolean=true);
  end;
  PTObjectList = ^TObjectList;

  TStringList = class;
  TStringListSortCompare = function(List: TStringList; index1, index2: integer): integer;

  TStringList = class
  private
    fCount: integer;
    fCapacity: integer;
    fListStr: array of string;
    // fListObj[] is allocated only if objects are used (not nil)
    fListObj: array of TObject;
    fCaseSensitive: boolean;
    function  BadIndex(index: integer): boolean;
    function  GetString(index: integer): string;
    procedure SetString(index: integer; const s: string);
    function  GetObject(index: integer): TObject;
    procedure SetObject(index: integer; Value: TObject);
    function  GetText(): string;
    procedure SetText(const Value: string);
  protected
    procedure QuickSort(L, R: integer; SCompare: TStringListSortCompare);
  public
    function  Add(const s: string): integer;
    function  AddObject(const s: string; AObject: TObject): integer;
    procedure AddStrings(SomeStrings: TStringList);
    procedure Delete(index: integer);
    function  IndexOf(const s: string): integer;
    function  IndexOfObject(item: pointer): integer;
    function  IndexOfName(const ObjName: string; const Separator: string='='): integer;
    function  ValueOf(const ObjName: string; const Separator: string='='): string;
    function  NameOf(const Value: string; const Separator: string='='): string;
    procedure Clear;
    function  TextLen(): integer;
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
    procedure CustomSort(Compare: TStringListSortCompare);
    property  Count: integer read fCount;
    property  CaseSensitive: boolean read fCaseSensitive write fCaseSensitive;
    property  Strings[index: integer]: string read GetString write SetString; default;
    property  Objects[index: integer]: TObject read GetObject write SetObject;
    property  Text: string read GetText write SetText;
  end;

  TStrings = TStringList; // for easy debugging

const
  fmCreate = $FFFF;

  // used in TStream.Seek()
  soFromBeginning = 0;
  soFromCurrent = 1;
  soFromEnd = 2;

type
  TSeekOrigin = (soBeginning, soCurrent, soEnd);

type
  TStream = class
  protected
    procedure SetPosition(Value: integer); virtual;
    function  GetPosition(): integer; virtual;
    function  GetSize(): integer; virtual;
    procedure SetSize(Value: integer); virtual;
  public
    function  Read(var Buffer; Count: integer): integer; virtual; abstract;
    procedure ReadBuffer(var Buffer; Count: integer);
    function  Write(var Buffer; Count: integer): integer; virtual; abstract;
    function  Seek(Offset: integer; Origin: Word): integer; overload; virtual; abstract;
    function  Seek(Offset: int64; Origin: TSeekOrigin): int64; overload; virtual; abstract;
    procedure Clear;
    procedure LoadFromStream(aStream: TStream); virtual;
    procedure SaveToStream(aStream: TStream); virtual;
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
    function  CopyFrom(Source: TStream; Count: integer): integer;
    property  Size: integer read GetSize write SetSize;
    property  Position: integer read GetPosition write SetPosition;
  end;

  THandleStream = class(TStream)
  private
    fHandle: THandle;
  protected
    procedure SetSize(Value: integer); override;
  public
    constructor Create(aHandle: THandle);
    function  Read(var Buffer; Count: integer): integer; override;
    function  Write(var Buffer; Count: integer): integer; override;
    function  Seek(Offset: integer; Origin: Word): integer; overload; override;
    function  Seek(Offset: int64; Origin: TSeekOrigin): int64; overload; override;
    property  Handle: THandle read fHandle;
  end;

  TFileStream = class(THandleStream)
  private
    fFileName: string;
  protected
{$ifdef Linux} // this special function use stat() instead of seek()
    function  GetSize(): cardinal; override;
{$endif}
  public
    constructor Create(const FileName: string; Mode: Word);
    destructor  Destroy; override;
    property  FileName: string read fFileName;      // (Present in Delphi only since version ?)
  end;

  TCustomMemoryStream = class(TStream)
  protected
    fPosition, fSize: integer;
    fMemory: pointer;
    procedure SetPosition(Value: integer); override;
    function  GetPosition(): integer; override;
    function  GetSize(): integer; override;
    procedure SetSize(Value: integer); override;
  public
    function  Read(var Buffer; Count: integer): integer; override;
    procedure SetPointer(Buffer: pointer; Count: integer);
    function  Seek(Offset: integer; Origin: Word): integer; override;
    procedure SaveToStream(aStream: TStream); override;
    property  Memory: pointer read fMemory;
  end;

  TResourceStream = class(TCustomMemoryStream)
  public
    constructor Create(Instance: THandle; const ResName: string; ResType: PChar);
  end;

  TStreamOwnership = (soReference, soOwned);

  TMemoryStream = class(TCustomMemoryStream)
  protected
    fCapacity: integer;
    procedure SetSize(Value: integer); override;
    procedure SetCapacity(Value: integer);
  public
    destructor  Destroy; override;
    function  Write(var Buffer; Count: integer): integer; override;
    procedure LoadFromStream(aStream: TStream); override;
  end;

{$ifdef MSWindows}
  TFilerFlag = (ffInherited, ffChildPos, ffInline);
  TFilerFlags = set of TFilerFlag;

  PValueType = ^TValueType;
  TValueType = (vaNull, vaList, vaInt8, vaInt16, vaInt32, vaExtended,
    vaString, vaIdent, vaFalse, vaTrue, vaBinary, vaSet, vaLString,
    vaNil, vaCollection, vaSingle, vaCurrency, vaDate, vaWString, vaInt64,
    vaUTF8String, vaUString, vaQWord);

  TComponent = class;

  TReader = class
  private
    fHandle: HGlobal;
    fStart: pByte;
    fPointer: pByte;
    fSize: integer;
    fPosition: integer;
    fNotifyLoaded: TList;
    procedure SetPosition(Value: integer);
    procedure Error(const errMsg: string);
  public
    constructor Create(const ResourceName: string);
    destructor  Destroy; override;
    procedure Loading(AComponent: TComponent);
    function  Read(var Data; DataSize: integer): integer;
    function  EndOfList(): boolean;
    function  ReadValueType(): TValueType;
    function  BooleanProperty(): boolean;
    function  IntegerProperty(): integer;
    function  StringProperty(): string;
    function  StringIntProperty(): string;
    function  ColorProperty(): integer;
    function  BinaryProperty(var Size: integer): pointer;
    procedure IdentProperty(var aValue; aTypeInfo: pointer);
    procedure SetProperty(var ASet; aTypeInfo: pointer);
    function  ReadByte(): byte;
    function  ReadWord(): word;
    function  ReadInteger(): integer;
    function  ReadString(): string;
    function  ReadShortString(): shortstring;
    function  ReadUTF8String(): string;
    function  ReadWString(): string;
    procedure ReadPrefix(var Flags: TFilerFlags; var AChildPos: integer);
    procedure AnyProperty;
    procedure ReadList;
    procedure ReadSet;
    procedure ReadStrings(Strings: TStrings);
    procedure ReadStringInts(Strings: TStrings);
    procedure ReadIntArray(var IntArray: array of integer); // Read an array of integers
    property  Size: integer read fSize;
    property  Position: integer read fPosition write SetPosition;
  end;

  /// in LVCL, TPersistent don't have any RTTI information compiled within
  // - RTTI is not needed with LVCL and will increase code size
  // - if you need RTTI, you should use {$M+} explicitely
  TPersistent = class
  protected
    function  SubProperty(const SubPropName: string): TPersistent; virtual;
    procedure ReadProperty(const PropName: string; Reader: TReader); virtual;
  end;

  TPersistentClass = class of TPersistent;

  TOperation = (opInsert, opRemove);

  TComponent = class(TPersistent)
  private
    fOwner: TComponent;
    fComponents: TObjectList;
    fTag: NativeUInt;
    fName: string;
  protected
    /// Provides the interface for a method that changes the parent of the component
    procedure SetParentComponent(Value: TComponent); virtual;
    /// All properties
    procedure ReadProperties(Reader: TReader; ParentForm: TComponent);
    /// Specific properties
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    /// Indicates the number of components owned by the component
    function  GetComponentCount(): integer;
    // End of loading
    procedure Loaded; virtual;
  public
    /// Allocates memory and constructs a safely initialized instance of a component
    constructor Create(AOwner: TComponent); virtual;
    destructor  Destroy; override;
    /// Returns the parent of the component
    function  GetParentComponent(): TComponent; virtual;
    /// Finds a child component
    function  FindComponent(const CompName: string): TComponent;
    /// Indicates the component that is responsible for streaming and freeing this component
    property  Owner: TComponent read fOwner;
    /// Indicates the number of components owned by the component
    property  ComponentCount: integer read GetComponentCount;
    /// if not nil, lists all components owned by the component
    property  Components: TObjectList read fComponents;
    /// the component name
    property  Name: string read fName write fName;
    /// integer/pointer value
    property  Tag: NativeUInt read fTag write fTag;
  end;

  TComponentClass = class of TComponent;

  /// minimal Threading implementation, using direct Windows API
  TThread = class
  private
    fHandle,
    fThreadID: THandle;
    fFinished,
    fTerminated,
    fSuspended,
    fCreateSuspended,
    fFreeOnTerminate: boolean;
    procedure SetSuspended(Value: boolean);
  protected
    EOnTerminate: TNotifyEvent;
    procedure Execute; virtual; abstract;
    property  Terminated: boolean read fTerminated;
  public
    constructor Create(CreateSuspended: boolean);
    destructor  Destroy; override;
    procedure AfterConstruction; override;
    // Note: Resume and Suspend are deprecated for Delphi 2010+ and FPC/Lazarus 2.4.4+
    procedure Resume;
    procedure Suspend;
    // Start is to be used instead of Resume
{$IFDEF FPC}
    {$define Def_ThreadStart}
{$ELSE FPC}
    {$if CompilerVersion>=21}       // Delphi 2010 or after
      {$define Def_ThreadStart}
    {$ifend}
{$ENDIF FPC}
    {$ifdef Def_ThreadStart}
    procedure Start;
    {$endif}
    function  WaitFor(): cardinal;
    procedure Terminate;
    property  Handle: THandle read fHandle;
    property  ThreadID: THandle read fThreadID;
    property  Suspended: boolean read fSuspended write SetSuspended;
    property  FreeOnTerminate: boolean read fFreeOnTerminate write fFreeOnTerminate;
    property  OnTerminate: TNotifyEvent read EOnTerminate write EOnTerminate;
  end;

  TWaitResult = (wrSignaled, wrTimeout, wrAbandoned, wrError);

  TEvent = class
  protected
    FHandle: THandle;
  public
    constructor Create(EventAttributes: PSecurityAttributes; ManualReset, InitialState: Boolean; const Name: string);
    destructor Destroy; override;
    function  WaitFor(Timeout: LongWord): TWaitResult;
    procedure SetEvent;
    procedure ResetEvent;
{$IFNDEF FPC}
    property  Handle: THandle read FHandle;
{$ENDIF}
  end;

function  FindClass(const AClassName: shortstring): TPersistentClass; overload;
function  FindClass(const AClassName: string): TPersistentClass; overload;
function  GetClass(const AClassName: shortstring): TPersistentClass; overload;
function  GetClass(const AClassName: string): TPersistentClass; overload;
procedure RegisterClass(const AClass: TPersistentClass);
procedure RegisterClasses(const AClasses: array of TPersistentClass);
{$endif}

type
  TAlignment =
    (taLeftJustify, taRightJustify, taCenter);
  TBiDiMode =
    (bdLeftToRight, bdRightToLeft, bdRightToLeftNoAlign, bdRightToLeftReadingOnly);

  TShiftState =
    set of (ssShift, ssAlt, ssCtrl, ssLeft, ssRight, ssMiddle, ssDouble);

function Point(AX, AY: integer): TPoint;
function Rect(ALeft, ATop, ARight, ABottom: integer): TRect;
function Bounds(ALeft, ATop, AWidth, AHeight: integer): TRect;

// (Not VCL/LCL standard)
function StringIndex(const s: string; const p: array of PChar): integer;

{$IFDEF FPC}
var
  MainThreadID: THandle;    { ThreadID of thread that module was initialized in }
{$ENDIF FPC}

//------------------------------------------------------------------------------

implementation

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

type
  TTypeKind = (tkUnknown,tkInteger,tkChar,tkEnumeration,tkFloat,
                tkSet,tkMethod,tkSString,tkLString,tkAString,
                tkWString,tkVariant,tkArray,tkRecord,tkInterface,
                tkClass,tkObject,tkWChar,tkBool,tkInt64,tkQWord,
                tkDynArray,tkInterfaceRaw,tkProcVar,tkUString,tkUChar,
                tkHelper);
  TOrdType = (otSByte, otUByte, otSWord, otUWord, otSLong, otULong);

  PTypeInfo = ^TTypeInfo;
  TTypeInfo = record
    Kind: TTypeKind;
    Name: shortstring;
    // here the type data follows as TTypeData record
  end;

  PTypeData = ^TTypeData;
  TTypeData = packed record   // Only the beginning, and only for enumerations
    OrdType:            TOrdType;
    MinValue,MaxValue:  integer;
    BaseType:           PTypeInfo;
    NameList:           shortstring;
  end;

const
  BooleanIdents: array[Boolean] of String = ('False', 'True');

function  GetTypeData(ptrTypeInfo: PTypeInfo): PTypeData; forward;
function  GetEnumNameValue(ptrTypeInfo: PTypeInfo; const Name: string): integer; forward;
function  GetColorFromIdent(Ident: PChar): integer; forward;
function  ClassSameText(const S1, S2: string): boolean; forward;

{$ifdef MSWindows}
var
  RegisteredClasses: TList = nil;
function  CreateComponent(const AClassName: shortstring; AOwner: TComponent): TComponent; forward;
{$endif}

// Workaround for Unicode FPC when using the standard SysUtils unit
{$if Defined(FPC) and Defined(UNICODE) and Declared(MaxEraCount)}
  {$define Def_FPC_StdSys}
{$ifend}
{$ifdef Def_FPC_StdSys}
function  Class_IntToStr(Value: integer): string; forward;
{$endif}

//------------------------------------------------------------------------------

function GetTypeData(ptrTypeInfo: PTypeInfo): PTypeData;
begin
  result := PTypeData(ptrTypeInfo);
  Inc(PByte(result),1);
  Inc(PByte(result),PByte(result)^+1);
end;

function GetEnumNameValue(ptrTypeInfo: PTypeInfo; const Name: string): integer;
var PS: PShortString;
var PT: PTypeData;
var Count: integer;
begin
  result := -1;
  if length(Name)=0 then exit;
  case ptrTypeInfo^.Kind of
  tkBool:
    begin
      if ClassSameText(BooleanIdents[false], Name) then
        result := 0
      else if ClassSameText(BooleanIdents[true], Name) then
        result := 1;
    end;
  tkEnumeration:
    begin
      PT := GetTypeData(ptrTypeInfo);
      Count := 0;
      PS := @PT^.NameList;
      while PByte(PS)^<>0 do
        begin
          if ClassSameText(string(PS^), Name) then
            begin
              result := Count+PT^.MinValue;
              break;
            end;
          Inc(PByte(PS),PByte(PS)^+1);
          Inc(Count);
        end;
    end;
  end;
end;

function GetColorFromIdent(Ident: PChar): integer;
type
  TIdentMapEntry = packed record
    Value: cardinal;
    Name: PChar;
  end;
const   // Colors duplicated, to avoid to include Graphics
  clBlack   = $000000;
  clMaroon  = $000080;
  clGreen   = $008000;
  clOlive   = $008080;
  clNavy    = $800000;
  clPurple  = $800080;
  clTeal    = $808000;
  clGray    = $808080;
  clSilver  = $C0C0C0;
  clRed     = $0000FF;
  clLime    = $00FF00;
  clYellow  = $00FFFF;
  clBlue    = $FF0000;
  clFuchsia = $FF00FF;
  clAqua    = $FFFF00;
  clLtGray  = $C0C0C0;
  clDkGray  = $808080;
  clWhite   = $FFFFFF;
  clNone    = $1FFFFFFF;
  clDefault = $20000000;
  clScrollBar           = COLOR_SCROLLBAR or $80000000;
  clBackground          = COLOR_BACKGROUND or $80000000;
  clActiveCaption       = COLOR_ACTIVECAPTION or $80000000;
  clInactiveCaption     = COLOR_INACTIVECAPTION or $80000000;
  clMenu                = COLOR_MENU or $80000000;
  clWindow              = COLOR_WINDOW or $80000000;
  clWindowFrame         = COLOR_WINDOWFRAME or $80000000;
  clMenuText            = COLOR_MENUTEXT or $80000000;
  clWindowText          = COLOR_WINDOWTEXT or $80000000;
  clCaptionText         = COLOR_CAPTIONTEXT or $80000000;
  clActiveBorder        = COLOR_ACTIVEBORDER or $80000000;
  clInactiveBorder      = COLOR_INACTIVEBORDER or $80000000;
  clAppWorkSpace        = COLOR_APPWORKSPACE or $80000000;
  clHighlight           = COLOR_HIGHLIGHT or $80000000;
  clHighlightText       = COLOR_HIGHLIGHTTEXT or $80000000;
  clBtnFace             = COLOR_BTNFACE or $80000000;
  clBtnShadow           = COLOR_BTNSHADOW or $80000000;
  clGrayText            = COLOR_GRAYTEXT or $80000000;
  clBtnText             = COLOR_BTNTEXT or $80000000;
  clInactiveCaptionText = COLOR_INACTIVECAPTIONTEXT or $80000000;
  clBtnHighlight        = COLOR_BTNHIGHLIGHT or $80000000;
  cl3DDkShadow          = COLOR_3DDKSHADOW or $80000000;
  cl3DLight             = COLOR_3DLIGHT or $80000000;
  clInfoText            = COLOR_INFOTEXT or $80000000;
  clInfoBk              = COLOR_INFOBK or $80000000;
const   // Value are integer, not enumerates -> no RTTI trick possible
  Colors: array[0..41] of TIdentMapEntry = (
    (Value: clBlack; Name: 'Black'),
    (Value: clMaroon; Name: 'Maroon'),
    (Value: clGreen; Name: 'Green'),
    (Value: clOlive; Name: 'Olive'),
    (Value: clNavy; Name: 'Navy'),
    (Value: clPurple; Name: 'Purple'),
    (Value: clTeal; Name: 'Teal'),
    (Value: clGray; Name: 'Gray'),
    (Value: clSilver; Name: 'Silver'),
    (Value: clRed; Name: 'Red'),
    (Value: clLime; Name: 'Lime'),
    (Value: clYellow; Name: 'Yellow'),
    (Value: clBlue; Name: 'Blue'),
    (Value: clFuchsia; Name: 'Fuchsia'),
    (Value: clAqua; Name: 'Aqua'),
    (Value: clWhite; Name: 'White'),
    (Value: clScrollBar; Name: 'ScrollBar'),
    (Value: clBackground; Name: 'Background'),
    (Value: clActiveCaption; Name: 'ActiveCaption'),
    (Value: clInactiveCaption; Name: 'InactiveCaption'),
    (Value: clMenu; Name: 'Menu'),
    (Value: clWindow; Name: 'Window'),
    (Value: clWindowFrame; Name: 'WindowFrame'),
    (Value: clMenuText; Name: 'MenuText'),
    (Value: clWindowText; Name: 'WindowText'),
    (Value: clCaptionText; Name: 'CaptionText'),
    (Value: clActiveBorder; Name: 'ActiveBorder'),
    (Value: clInactiveBorder; Name: 'InactiveBorder'),
    (Value: clAppWorkSpace; Name: 'AppWorkSpace'),
    (Value: clHighlight; Name: 'Highlight'),
    (Value: clHighlightText; Name: 'HighlightText'),
    (Value: clBtnFace; Name: 'BtnFace'),
    (Value: clBtnShadow; Name: 'BtnShadow'),
    (Value: clGrayText; Name: 'GrayText'),
    (Value: clBtnText; Name: 'BtnText'),
    (Value: clInactiveCaptionText; Name: 'InactiveCaptionText'),
    (Value: clBtnHighlight; Name: 'BtnHighlight'),
    (Value: cl3DDkShadow; Name: '3DDkShadow'),
    (Value: cl3DLight; Name: '3DLight'),
    (Value: clInfoText; Name: 'InfoText'),
    (Value: clInfoBk; Name: 'InfoBk'),
    (Value: clNone; Name: 'None'));
begin
{$ifdef UNICODE}
  if PCardinal(Ident)^=ord('c')+(ord('l') shl 16) then begin
{$else}
  if PWord(Ident)^=ord('c')+(ord('l') shl 8) then begin
{$endif}
    Inc(Ident,2);
    result := high(Colors);
    while result>=0 do
      if StrIComp(Colors[result].Name,Ident)=0 then begin
        cardinal(result) := Colors[result].Value;
        if result<0 then
          result := LLCL_GetSysColor(result and $FF);
        exit;
      end else
      Dec(result);
  end;
  result := clNone;
end;

function ClassSameText(const S1, S2: string): boolean;
begin
  result := (LLCLS_CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, S1, S2)=CSTR_EQUAL);
end;

{$ifdef Def_FPC_StdSys}
function Class_IntToStr(Value: integer): string;
begin
  Str(Value, result);
end;
{$endif Def_FPC_StdSys}

{ TList }

procedure TList.FreeObjects(start: integer);
var i: integer;
begin
  if fOwnObjects then
    for i := start to fCount-1 do
      TObject(fList[i]).Free;
  if fCount > start then
    fCount := start;
end;

function TList.BadIndex(index: integer): boolean;
begin
  result := (index<0) or (index>=fCount);
  // raising error may be removed if unwanted
  if result then
    raise EClassesError.CreateFmt(LLCL_STR_CLAS_TLISTINDEXOUTRANGE, [index]);
end;

procedure TList.Grow;
begin
  if fCapacity>64 then
    Inc(fCapacity, fCapacity shr 2)
  else
    Inc(fCapacity, 16);
  SetLength(fList, fCapacity);  // will set all new entries to nil
end;

procedure TList.SetCount(number: integer);
begin
  if number > fCapacity then
    SetCapacity(number)
  else
    begin
      FreeObjects(number);
      fCount := number;         // may have also fCount < number < fCapacity
    end;
end;

procedure TList.SetCapacity(number: integer);
begin
  if number < fCapacity then
    FreeObjects(number);
  fCapacity := number;
  SetLength(fList, fCapacity);  // will set all new entries to nil
end;

function TList.GetItem(index: integer): pointer;
begin
  if BadIndex(index) then
    result := nil
  else
    result := fList[index];
end;

procedure TList.SetItem(index: integer; item: pointer);
begin
  if BadIndex(index) then
    exit;
  if fOwnObjects then
    TObject(fList[index]).Free;
  fList[index] := item;
end;

function TList.GetList(): PPointerList;
begin
  result := PPointerList(fList);
end;

destructor TList.Destroy;
begin
  FreeObjects(0);
  inherited;        // will do Finalize(fList) in FinalizeRecord
end;

function TList.Add(item: pointer): integer;
begin
  if fCount=fCapacity then
    Grow;
  fList[fCount] := item;
  result := fCount;
  Inc(fCount);
end;

procedure TList.Insert(index: integer; item: pointer);
begin
  if BadIndex(index) then
    exit;
  if fCount=fCapacity then
    Grow;
  if index < fCount then
    Move(fList[index], fList[index+1], (fCount-index)*SizeOf(fList[index]));
  fList[index] := item;
  Inc(fCount);
end;

procedure TList.Remove(item: pointer);
var i: integer;
begin
  i := IndexOf(item);
  if i>=0 then
    Delete(i);
end;

procedure TList.Delete(index: integer);
begin
  if BadIndex(index) then
    exit;
  if fOwnObjects then
    TObject(fList[index]).Free;
  Dec(fCount);
  if index < fCount then
    Move(fList[index + 1], fList[index], (fCount-index)*SizeOf(fList[index]));
end;

function TList.IndexOf(item: pointer): integer;
var i: integer;
begin
  result := -1;
  for i := 0 to fCount-1 do
    if fList[i]=item then
      begin
        result := i;
        exit;
      end;
end;

procedure TList.Clear;
begin
  FreeObjects(0);
  fCapacity := 0;
  Finalize(fList);
end;

{ TObjectList }

constructor TObjectList.Create(aOwnObjects: boolean=true);
begin
  inherited Create;
  fOwnObjects := aOwnObjects;    // do all the magic :)
end;

{ TStringList }

function TStringList.BadIndex(index: integer): boolean;
begin
  result := (index<0) or (index>=fCount);
  // raising error may be removed if unwanted
  if result then
    raise EClassesError.CreateFmt(LLCL_STR_CLAS_TSTRLISTINDEXOUTRANGE, [index]);
end;

function TStringList.GetString(index: integer): string;
begin
  if BadIndex(index) then
    result := ''
  else
    result := fListStr[index];
end;

procedure TStringList.SetString(index: integer; const s: string);
begin
  if BadIndex(index) then
    exit;
  fListStr[index] := s;
end;

function TStringList.GetObject(index: integer): TObject;
begin
  if BadIndex(index) or (index>=length(fListObj)) then
    result := nil
  else
    result := fListObj[index];
end;

procedure TStringList.SetObject(index: integer; Value: TObject);
begin
  if BadIndex(index) or (Value=nil) then
    exit;
  if length(fListObj)<fCapacity then
    SetLength(fListObj, fCapacity);
  if fListObj[index]<>nil then        // fListObj<>nil after SetLength
    fListObj[index].Free;
  fListObj[index] := Value;
end;

function TStringList.Add(const s: string): integer;
begin
  result := AddObject(s, nil);
end;

function TStringList.AddObject(const s: string; AObject: TObject): integer;
begin
  if fCount=fCapacity then
    begin
      if fCapacity>64 then
        Inc(fCapacity, fCapacity shr 2)
      else
        Inc(fCapacity, 16);
      SetLength(fListStr, fCapacity);
    end;
  fListStr[fCount] := s;
  result := fCount;
  Inc(fCount);
  if AObject<>nil then
    Objects[result] := AObject;
end;

procedure TStringList.AddStrings(SomeStrings: TStringList);
var i: integer;
begin
  for i := 0 to SomeStrings.Count-1 do
    AddObject(SomeStrings.Strings[i], SomeStrings.Objects[i]);    // (bug in LVCL)
end;

procedure TStringList.Delete(index: integer);
begin
  if BadIndex(index) then
    exit;
  fListStr[index] := ''; // avoid GPF
  Dec(fCount);
  if index<fCount then
    begin
      Move(fListStr[index + 1], fListStr[index], (fCount-index)*SizeOf(fListStr[index]));
      if fListObj<>nil then
        Move(fListObj[index + 1], fListObj[index], (fCount-index)*SizeOf(fListObj[index]));
    end;
  pointer(fListStr[fCount]) := nil; // avoid GPF
end;

function TStringList.IndexOf(const s: string): integer;
var i: integer;
begin
  result := -1;
  for i := 0 to fCount-1 do
    if fCaseSensitive then
      begin if fListStr[i]=s then begin result := i; exit; end; end
    else
      begin if ClassSameText(fListStr[i], s) then begin result := i; exit; end; end;
end;

function TStringList.IndexOfObject(item: pointer): integer;
var i: integer;
begin
  result := -1;
  if fListObj<>nil then
    for i := 0 to fCount-1 do
      if fListObj[i]=PTObjectList(item)^ then
        begin
          result := i;
          exit;
        end;
end;

function TStringList.IndexOfName(const ObjName: string; const Separator: string='='): integer;
var Tmp: string;
var i: integer;
begin
  result := -1;
  if length(ObjName)>0 then
    begin
      Tmp := ObjName + Separator;
      for i := 0 to fCount-1 do
        if ClassSameText(Copy(fListStr[i], 1, length(Tmp)), Tmp) then
          begin
            result := i;
            exit;
          end;
    end;
end;

function TStringList.ValueOf(const ObjName: string; const Separator: string='='): string;
var i: integer;
begin
  i := IndexOfName(ObjName, Separator);
  if i>=0 then
    result := Copy(fListStr[i], length(ObjName + Separator) + 1, maxInt)
  else
    result := '';
end;

function TStringList.NameOf(const Value: string; const Separator: string='='): string;
var i,j,L: integer;
    P: PChar;
begin
  L := length(Separator)-1;
  for i := 0 to fCount-1 do begin
    j := pos(Separator, fListStr[i]);
    if j=0 then continue;
    P := PChar(pointer(fListStr[i]))+j+L;
    while P^=' ' do Inc(P); // trim left value
    if StrIComp(P,pointer(Value))=0 then begin
      result := Copy(fListStr[i], 1, j-1);
      exit;
    end;
  end;
  result := '';
end;

procedure TStringList.Clear;
begin
  fCount := 0;
  fCapacity := 0;
  Finalize(fListStr);
  Finalize(fListObj);
end;

procedure TStringList.LoadFromFile(const FileName: string);
var F: System.text;
    s: string;
    buf: array[0..4095] of byte;
begin
  Clear;
  {$ifopt I+}{$define IDef_TSLLoadFromFile}{$I-}{$endif}
  Assign(F,FileName);
  SetTextBuf(F,buf);
  Reset(F);
  if ioresult<>0 then exit;
  while not eof(F) do begin
    readln(F, s);
    Add(s);
  end;
  ioresult;
  Close(F);
  ioresult;
  {$ifdef IDef_TSLLoadFromFile}{$I+}{$endif}{$undef IDef_TSLLoadFromFile}
end;

procedure TStringList.SaveToFile(const FileName: string);
var F: System.text;
    i: integer;
    buf: array[0..4095] of byte;
begin
  {$ifopt I+}{$define IDef_TSLSaveToFile}{$I-}{$endif}
  Assign(F,FileName);
  SetTextBuf(F,buf);
  rewrite(F);
  if ioresult<>0 then exit;
  for i := 0 to fCount-1 do
    writeln(F, fListStr[i]);
  ioresult;
  Close(F);
  ioresult; // ignore any error
  {$ifdef IDef_TSLSaveToFile}{$I+}{$endif}{$undef IDef_TSLSaveToFile}
end;

procedure TStringList.QuickSort(L, R: integer; SCompare: TStringListSortCompare);
var I, J, P: integer;
var TmpObj: TObject;
var TmpListStr: string;
begin
  repeat
    I := L;
    J := R;
    P := (L+R) shr 1;
    repeat
      while SCompare(self,I,P)<0 do Inc(I);
      while SCompare(self,J,P)>0 do Dec(J);
      if I <= J then begin
        TmpObj := fListObj[I];
        fListObj[I] := fListObj[J];
        fListObj[J] := TmpObj;
        TmpListStr := fListStr[I];
        fListStr[I] := fListStr[J];
        fListStr[J] := TmpListStr;
        if P=I then
          P := J else
        if P=J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I>J;
    if L<J then QuickSort(L,J,SCompare);
    L := I;
  until I>=R;
end;

procedure TStringList.CustomSort(Compare: TStringListSortCompare);
begin
  if fCount>1 then
    QuickSort(0, fCount-1, Compare);
end;

function TStringList.TextLen(): integer;
var i: integer;
begin
  result := fCount*length(sLineBreak);  // #13#10 size
  for i := 0 to fCount-1 do
    Inc(result, length(fListStr[i]));
end;

function TStringList.GetText(): string;
var i: integer;
begin
  result := '';
  for i := 0 to fCount-1 do
    result := result+fListStr[i]+sLineBreak;
end;

procedure TStringList.SetText(const Value: string);
function GetNextLine(d: pChar; out next: pChar): string;
begin
  next := d;
  while not (d^ in [#0,#10,#13]) do Inc(d);
  System.SetString(result, next, d-next);
  if d^=#13 then Inc(d);
  if d^=#10 then Inc(d);
  if d^=#0 then
    next := nil else
    next := d;
end;
var P: PChar;
begin
  Clear;
  P := pointer(Value);
  while P<>nil do
    Add(GetNextLine(P,P));
end;

{ TStream }

procedure TStream.Clear;
begin
  Position := 0;
  Size := 0;
end;

function TStream.CopyFrom(Source: TStream; Count: integer): integer;
const
  MaxBufSize = $F000*4;   // 240KB buffer (should be fast enough ;)
var
  BufSize, N: integer;
  Buffer: PChar;
begin
  if Count=0 then begin   // Count=0 for whole stream copy
    Source.Position := 0;
    Count := Source.Size;
  end;
  result := Count;
  if Count>MaxBufSize then
    BufSize := MaxBufSize else
    BufSize := Count;
  GetMem(Buffer, BufSize);
  try
    while Count<>0 do begin
      if Count>BufSize then
        N := BufSize else
        N := Count;
      if Source.Read(Buffer^, N)<>N then
        break; // stop on any read error
      if Write(Buffer^, N)<>N then
        break; // stop on any write error
      Dec(Count, N);
    end;
  finally
    FreeMem(Buffer);
  end;
end;

function TStream.GetPosition(): integer;
begin
  result := Seek(0, soFromCurrent);
end;

function TStream.GetSize(): integer;
var Pos: integer;
begin
  Pos := Seek(0, soFromCurrent);
  result := Seek(0, soFromEnd);
  Seek(Pos, soFromBeginning);
end;

procedure TStream.SetPosition(Value: integer);
begin
  Seek(Value, soFromBeginning);
end;

procedure TStream.SetSize(Value: integer);
begin
  // default = do nothing  (read-only streams, etc)
  // descendents should implement this method
end;

procedure TStream.LoadFromFile(const FileName: string);
var F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(F);
  finally
    F.Free;
  end;
end;

procedure TStream.LoadFromStream(aStream: TStream);
begin
  CopyFrom(aStream, 0);         // Count=0 for whole stream copy
end;

procedure TStream.ReadBuffer(var Buffer; Count: integer);
begin
  Read(Buffer, Count);
end;

procedure TStream.SaveToFile(const FileName: string);
var F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(F);
  finally
    F.Free;
  end;
end;

procedure TStream.SaveToStream(aStream: TStream);
begin
  aStream.CopyFrom(self, 0);    // Count=0 for whole stream copy
end;

{ THandleStream }

constructor THandleStream.Create(aHandle: THandle);
begin
  fHandle := aHandle;
end;

function THandleStream.Read(var Buffer; count: integer): integer;
begin
  if (fHandle=0) then
    result := 0 else
    result := FileRead(fHandle, Buffer, Count);
end;

function THandleStream.Seek(Offset: integer; Origin: Word): integer;
begin
  if (fHandle=0) then
    result := 0 else
    result := FileSeek(fHandle, Offset, Origin);
end;

function THandleStream.Seek(Offset: int64; Origin: TSeekOrigin): int64;
begin
  if (fHandle=0) then
    result := 0 else
    result := FileSeek(fHandle, Offset, Ord(Origin));
end;

procedure THandleStream.SetSize(Value: integer);
begin
  Seek(Value, soFromBeginning);
  if (fHandle=0) then
{$ifdef MSWindows}
    if not LLCL_SetEndOfFile(fHandle) then
{$else}
    if ftruncate(fHandle, Value)=-1 then
{$endif}
      raise EStreamError.Create(LLCL_STR_CLAS_SETSIZE);
end;

function THandleStream.Write(var Buffer; Count: integer): integer;
begin
  if (fHandle=0) or (Count<=0) then
    result := 0 else
    result := FileWrite(fHandle, Buffer, Count);
end;

{ TFileStream }

constructor TFileStream.Create(const FileName: string; Mode: Word);
begin
  fFileName := FileName;
  if Mode=fmCreate then
    fHandle := FileCreate(FileName) else
    fHandle := FileOpen(FileName, Mode);
  if fHandle=THandle(-1) then
    begin
      fHandle := 0;
      raise EStreamError.Create({$ifdef Def_FPC_StdSys}ansistring(FileName){$else}FileName{$endif});
    end;
end;

{$ifdef Linux}
function TFileStream.GetSize(): cardinal;
var st: TStatBuf;
begin
  if stat(PChar(fFileName),st)=0 then
    result := st.st_size else
    result := 0;
end;
{$endif}

destructor TFileStream.Destroy;
begin
  FileClose(fHandle);
  inherited;
end;

{$ifdef MSWindows}
{ TReader }

constructor TReader.Create(const ResourceName: string);
var res: THandle;
begin
  res := LLCL_FindResource(hInstance, @ResourceName[1], PChar(RT_RCDATA));
  if res=0 then exit;
  fHandle := LLCL_LoadResource(hInstance,res);
  if fHandle=0 then exit;
  fPointer := LLCL_LockResource(fHandle);
  if fPointer<>nil then
    fSize := SizeOfResource(hInstance,res);
  fStart := fPointer;
  fNotifyLoaded := TList.Create;
end;

destructor TReader.Destroy;
var i: integer;
begin
  if fHandle<>0 then begin
    //UnlockResource(fHandle); not necessary for MSWindows-based applications
    //FreeResource(fHandle);   also obsolete
    for i := 0 to fNotifyLoaded.Count-1 do
      TComponent(fNotifyLoaded.fList[i]).Loaded;
    fNotifyLoaded.Free;
  end;
  inherited;
end;

procedure TReader.SetPosition(Value: integer);
begin
  fPosition := Value;
{$IFDEF FPC}    // Avoid compilation warnings
  fPointer := pByte(fStart+Value);
{$ELSE FPC}
  fPointer := pByte(NativeUInt(fStart)+cardinal(Value));
{$ENDIF FPC}
end;

procedure TReader.Error(const errMsg: string);
begin
  raise EClassesError.Create({$ifdef Def_FPC_StdSys}ansistring(errMsg){$else}errMsg{$endif});
end;

procedure TReader.Loading(AComponent: TComponent);
begin
  fNotifyLoaded.Add(AComponent);
end;

function TReader.Read(var Data; DataSize: integer): integer;
begin
  if fPosition+DataSize<fSize then
    result := DataSize else
    result := fSize-fPosition;
  if result<=0 then exit;
  move(fPointer^,Data,result);
  Inc(fPosition,result);
  Inc(fPointer,result);
end;

function TReader.EndOfList(): boolean;
begin
  result := (fPosition<fSize) and (fPointer^=0);
  if result then begin
    Inc(fPosition);
    Inc(fPointer);
  end;
end;

function TReader.ReadValueType(): TValueType;
begin
  result := PValueType(fPointer)^;
  Inc(fPosition);
  Inc(fPointer);
end;

function TReader.BooleanProperty(): boolean;
var ValueType: TValueType;
begin
  result := false;
  ValueType := ReadValueType();
  case ValueType of
    vaFalse  : result := false;
    vaTrue   : result := true;
    else Error(LLCL_STR_CLAS_BOOL)
  end;
end;

function TReader.IntegerProperty(): integer;
var ValueType: TValueType;
begin
  result := 0;
  ValueType := ReadValueType();
  case ValueType of
    vaInt8  : result := ShortInt(ReadByte());
    vaInt16 : result := ReadWord();
    vaInt32 : result := ReadInteger();
    else Error(LLCL_STR_CLAS_ORDINAL);
  end;
end;

function TReader.StringProperty(): string;
var ValueType: TValueType;
begin
  result := '';
  ValueType := ReadValueType();
  case ValueType of
    vaIdent,
    vaString:     result := ReadString();
    vaUTF8String: result := ReadUTF8String();
    vaWString:    result := ReadWString();
    else raise EClassesError.CreateFmt(LLCL_STR_CLAS_STRING, [integer(ValueType)]);
  end;
end;

function TReader.StringIntProperty(): string;
var ValueType: TValueType;
begin
  result := '';
  ValueType := ReadValueType();
  case ValueType of
    vaIdent,
    vaString:     result := ReadString();
    vaUTF8String: result := ReadUTF8String();
    vaWString:    result := ReadWString();
    vaInt8  : result := {$ifdef Def_FPC_StdSys}Class_IntToStr{$else}IntToStr{$endif}(ShortInt(ReadByte()));
    vaInt16 : result := {$ifdef Def_FPC_StdSys}Class_IntToStr{$else}IntToStr{$endif}(ReadWord());
    vaInt32 : result := {$ifdef Def_FPC_StdSys}Class_IntToStr{$else}IntToStr{$endif}(ReadInteger());
    else raise EClassesError.CreateFmt(LLCL_STR_CLAS_STRING, [integer(ValueType)]);
  end;
end;

function TReader.ColorProperty(): integer;
var ValueType: TValueType;
begin
  result := 0;
  ValueType := ReadValueType();
  case ValueType of
    vaInt16 : result := ReadWord();
    vaInt32 : result := ReadInteger();
    vaIdent : result := GetColorFromIdent(PChar(ReadString()));
    else Error(LLCL_STR_CLAS_COLOR);
  end;
end;

function TReader.BinaryProperty(var Size: integer): pointer;
var ValueType: TValueType;
begin
  result := nil;
  ValueType := ReadValueType();
  case ValueType of
   vaBinary : begin
     Size := ReadInteger();
     GetMem(result,Size);
     Read(result^,Size);
   end;
   else Error(LLCL_STR_CLAS_BINARY);
  end;
end;

procedure TReader.IdentProperty(var aValue; aTypeInfo: pointer);
var ValueType: TValueType;
    V: cardinal;
begin
  ValueType := ReadValueType();
  if ValueType=vaIdent then begin
     V := GetEnumNameValue(aTypeInfo, string(ReadShortString()));
     if V<=255 then begin
       byte(aValue) := V;
       exit;
     end;
  end;
  Error(LLCL_STR_CLAS_IDENT);
end;

procedure TReader.SetProperty(var ASet; aTypeInfo: pointer);
var s: shortstring;
    i: integer;
begin
  if ReadValueType()<>vaSet then
    Error(LLCL_STR_CLAS_SET);
  NativeUInt(ASet) := 0;
  repeat
    s := ReadShortString();
    if s[0]=#0 then break;
    i := GetEnumNameValue(aTypeInfo, string(s));
    if i>=0 then
      NativeUInt(ASet) := NativeUInt(ASet) or (1 shl i);
  until false;
end;

function TReader.ReadByte(): byte;
begin
  result := fPointer^;
  Inc(fPosition);
  Inc(fPointer);
end;

function TReader.ReadWord(): word;
begin
  result := pWord(fPointer)^;
  Inc(fPosition,2);
  Inc(fPointer,2);
end;

function TReader.ReadInteger(): integer;
begin
  result := PInteger(fPointer)^;
  Inc(fPosition,4);
  Inc(fPointer,4);
end;

function TReader.ReadString(): string;
var L: integer;
{$ifdef UNICODE}
var S: ansistring;
{$else}
var S: string;
{$endif}
begin
  L := fPointer^;
  System.SetString(S, PAnsiChar(fPointer)+1, L);
  result := LLCLS_FormStringToString(S);
  Inc(L);
  Inc(fPosition, L);
  Inc(fPointer, L);
end;

function TReader.ReadWString(): string;
var L: integer;
begin
  L := PInteger(fPointer)^;
  Inc(fPointer, 4);
  WideCharLenToStrVar(PWideChar(fPointer), L, result);
  L := L*2;
  Inc(fPosition, L+4);
  Inc(fPointer, L);
end;

function TReader.ReadShortString(): shortstring;
var L: integer;
begin
  L := fPointer^+1;
  move(fPointer^, result, L);
  Inc(fPosition, L);
  Inc(fPointer, L);
end;

function TReader.ReadUTF8String(): string;
var L: integer;
    UTF8S: utf8string;
begin
  L := PInteger(fPointer)^;
  Inc(fPointer, 4);
  System.SetString(UTF8S, PAnsiChar(fPointer), L);
  result := LLCLS_FormUTF8ToString(UTF8S);
  Inc(fPosition, L+4);
  Inc(fPointer, L);
end;

procedure TReader.ReadPrefix(var Flags: TFilerFlags; var AChildPos: integer);
var Prefix: Byte;
begin
  Flags := [];
  if (fSize>1) and (fPointer^ and $F0 = $F0) then begin
    Prefix := Byte(ReadByte() and $0F);
    if (Prefix and Succ(Ord(ffInherited)))>0 then
      Include(Flags,ffInherited);
    if (Prefix and Succ(Ord(ffChildPos)))>0 then
      Include(Flags,ffChildPos);
    if (Prefix and Succ(Ord(ffInline)))>0 then
      Include(Flags,ffInline);
    if ffChildPos in Flags then
      AChildPos := ReadInteger();
  end;
end;

procedure TReader.AnyProperty;
var
  ValueType: TValueType;
begin
  ValueType := ReadValueType();
  case ValueType of
    vaInt8  :     ReadByte();
    vaInt16 :     ReadWord();
    vaInt32 :     ReadInteger();
    vaIdent,
    vaString:     ReadString();
    vaUTF8String: ReadUTF8String();
    vaWString:    ReadWString();
    vaFalse, vaTrue: ;
    else raise EClassesError.CreateFmt(LLCL_STR_CLAS_SETOF, [integer(ValueType)]);
  end;
end;

procedure TReader.ReadList;
begin
  repeat
    AnyProperty;
  until EndOfList();
end;

procedure TReader.ReadSet;
begin
  repeat
    ReadShortString();
  until EndOfList();
end;

procedure TReader.ReadStrings(Strings: TStrings);
var ValueType: TValueType;
    s: string;
begin
  ValueType := ReadValueType();
  if ValueType=vaList then
    repeat
      s := StringProperty();
      Strings.Add(s);
    until EndOfList()
  else Error(LLCL_STR_CLAS_LIST);
end;

// Read strings and integers (hack: integers are stored as strings)
procedure TReader.ReadStringInts(Strings: TStrings);
var ValueType: TValueType;
    s: string;
begin
  ValueType := ReadValueType();
  if ValueType=vaList then
    repeat
      s := StringIntProperty();
      Strings.Add(s);
    until EndOfList()
  else Error(LLCL_STR_CLAS_LIST);
end;

// Read array of integers (array must wide enough)
procedure TReader.ReadIntArray(var IntArray: array of integer);
var ValueType: TValueType;
    i: integer;
begin
  i := 0;
  ValueType := ReadValueType();
  if ValueType=vaList then
    repeat
      IntArray[i ] := IntegerProperty();
      Inc(i);
    until EndOfList()
  else Error(LLCL_STR_CLAS_LIST);
end;

{ TPersistent }

function TPersistent.SubProperty(const SubPropName: string): TPersistent;
begin
  result := nil;
end;

procedure TPersistent.ReadProperty(const PropName: string; Reader: TReader);
// default behavior is to read the property value from Reader and ignore it
var {$ifdef debug}
  Value, Oem: string;
{$endif}
  ValueType: TValueType;
  i: integer;
  SubProp: TPersistent;
begin
  i := pos('.', PropName);
  if i > 0 then
    SubProp := SubProperty(Copy(PropName, 1, i-1))
  else SubProp := nil;
  if SubProp<>nil then
    SubProp.ReadProperty(Copy(PropName, i+1, 200), Reader)
  else
    with Reader do begin
{$ifdef debug}
      ValueType := ReadValueType();
      case ValueType of
        vaInt8   : Value := {$ifdef Def_FPC_StdSys}Class_IntToStr{$else}IntToStr{$endif}(ReadByte());
        vaInt16  : Value := {$ifdef Def_FPC_StdSys}Class_IntToStr{$else}IntToStr{$endif}(ReadWord());
        vaIdent  : Value := '"'+ReadString()+'"';
        vaString : Value := ReadString();
        vaUTF8String: Value := ReadUTF8String();
        vaWString: Value := ReadWString();
        vaFalse  : Value := '"FALSE"';
        vaTrue   : Value := '"TRUE"';
        vaBinary : begin
                    i := ReadInteger(); Value := '('+{$ifdef Def_FPC_StdSys}Class_IntToStr{$else}IntToStr{$endif}(i)+LLCL_STR_CLAS_BYTES;
                    Inc(fPointer,i); Inc(fPosition,i);
                   end;
        vaList: ReadList;
        vaSet:  ReadSet;
        else OutputDebugString(pointer(LLCL_STR_CLAS_BADVALUETYPE+{$ifdef Def_FPC_StdSys}Class_IntToStr{$else}IntToStr{$endif}(ord(ValueType))));
      end;
      Oem := LLCLS_StringToOem(Value);
      writeln(self.ClassName+' '+TComponent(self).Name+'.'+PropName+'='+Oem);
{$else}
      ValueType := ReadValueType();
      case ValueType of // no handler -> ignore this property
        vaInt8:   ReadByte();
        vaInt16:  ReadWord();
        vaIdent,
        vaString: ReadString();
        vaUTF8String: ReadUTF8String();
        vaWString: ReadWString();
        vaFalse, vaTrue: ;
        vaBinary: begin
          i := ReadInteger();
          Inc(fPointer,i);
          Inc(fPosition,i);
        end;
        vaList: ReadList;
        vaSet:  ReadSet;
      else
        raise EClassesError.CreateFmt(LLCL_STR_CLAS_UNKNVALUETYPE, [TComponent(self).Name, PropName, integer(ValueType)]);
      end;
{$endif}
    end; // with Reader do
end;

{ TEvent }

constructor TEvent.Create(EventAttributes: PSecurityAttributes; ManualReset, InitialState: Boolean; const Name: string);
begin
  fHandle := LLCL_CreateEvent(EventAttributes, ManualReset, InitialState, @Name[1]);
end;

destructor TEvent.Destroy;
begin
  LLCL_CloseHandle(fHandle);
end;

procedure TEvent.ResetEvent;
begin
  LLCL_ResetEvent(fHandle);
end;

procedure TEvent.SetEvent;
begin
  LLCL_SetEvent(fHandle);
end;

function TEvent.WaitFor(Timeout: LongWord): TWaitResult;
begin
  case LLCL_WaitForSingleObject(fHandle, Timeout) of
    WAIT_ABANDONED: result := wrAbandoned;
    WAIT_OBJECT_0:  result := wrSignaled;
    WAIT_TIMEOUT:   result := wrTimeout;
    else            result := wrError;
  end;
end;

{ Classes functions }

function FindClass(const AClassName: shortstring): TPersistentClass;
begin
  result := GetClass(AClassName);
  if result=nil then
    raise EClassesError.CreateFmt(LLCL_STR_CLAS_SCLASS, [AClassName]);
end;

function FindClass(const AClassName: string): TPersistentClass;
begin
  result := FindClass(shortString(AClassName));
end;

function GetClass(const AClassName: shortstring): TPersistentClass;
var i: integer;
begin
  if RegisteredClasses=nil then
    RegisteredClasses := TList.Create else
  for i := 0 to RegisteredClasses.Count-1 do begin
    result := TPersistentClass(RegisteredClasses.fList[i]);
{$IFDEF FPC}    // Avoid compilation warnings
    if PShortString(Pointer(Pointer(result)+vmtClassName)^)^=AClassName then
{$ELSE FPC}
    if PShortString(Pointer(NativeUInt(Pointer(result))+cardinal(vmtClassName))^)^=AClassName then
{$ENDIF FPC}
    exit;
  end;
  result := nil;
end;

function GetClass(const AClassName: string): TPersistentClass;
begin
  result := GetClass(shortstring(AClassName));
end;

procedure RegisterClass(const AClass: TPersistentClass);
begin
{$IFDEF FPC}    // Avoid compilation warnings
  if GetClass(PShortString(Pointer(Pointer(AClass)+vmtClassName)^)^)=nil then
{$ELSE FPC}
  if GetClass(PShortString(Pointer(NativeUInt(AClass)+cardinal(vmtClassName))^)^)=nil then
{$ENDIF FPC}
    RegisteredClasses.Add(AClass);
end;

procedure RegisterClasses(const AClasses: array of TPersistentClass);
var i: integer;
begin
  for i := Low(AClasses) to High(AClasses) do
    RegisterClass(AClasses[i]);
end;

function CreateComponent(const AClassName: shortstring; AOwner: TComponent): TComponent;
var RC: TPersistentClass;
begin
  RC := FindClass(AClassName);
  if not RC.InheritsFrom(TComponent) then   // (RC=nil already raises an error in FindClass)
    raise EClassesError.CreateFmt(LLCL_STR_CLAS_SCLASS, [AClassName]);
  result := TComponent(RC.NewInstance);
  result.Create(AOwner);
end;

{ TComponent }

constructor TComponent.Create(AOwner: TComponent);
begin
  if AOwner=nil then exit;
  if AOwner.fComponents=nil then
    AOwner.fComponents := TObjectList.Create;
  AOwner.fComponents.Add(self);
  fOwner := AOwner;
end;

procedure TComponent.ReadProperties(Reader: TReader; ParentForm: TComponent);
var
  Flags: TFilerFlags;
  Position: integer;
  Child: TComponent;
  Field: ^TComponent;
  AName: shortstring;
begin
  while not Reader.EndOfList() do
    ReadProperty(Reader.ReadString(), Reader);
  while not Reader.EndOfList() do begin
    Reader.ReadPrefix(Flags, Position);
    AName := Reader.ReadShortString();        // read ClassName
    Child := CreateComponent(AName, self);
    Child.SetParentComponent(self);
    Reader.Loading(Child);
    AName := Reader.ReadShortString();
    Child.fName := string(AName);
    Child.ReadProperties(Reader, ParentForm);
    Field := ParentForm.FieldAddress(AName);  // all Controls are affected to Form
    if Field<>nil then
      Field^ := Child;
  end;
end;

procedure TComponent.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..0] of PChar = ('Tag');
begin
  case StringIndex(PropName, Properties) of
    0 : Tag := Reader.IntegerProperty;
    else inherited;
  end;
end;

procedure TComponent.Loaded;
begin
end;

procedure TComponent.SetParentComponent(Value:TComponent);
begin
end;

function TComponent.GetParentComponent: TComponent;
begin
  result := fOwner;
end;

destructor TComponent.Destroy;
begin
  fComponents.Free; // free all contained components
  inherited;
end;

function TComponent.GetComponentCount: integer;
begin
  if fComponents=nil then
    result := 0
  else
    result := fComponents.Count;
end;

function TComponent.FindComponent(const CompName: string): TComponent;
var i: integer;
begin
  result := nil;
  if fComponents<>nil then
    for i := 0 to fComponents.Count-1 do
      if ClassSameText(TComponent(fComponents[i]).Name, CompName) then
        begin
          result := TComponent(fComponents[i]);
          break;
      end;
end;

{$endif}

{ TMemoryStream }

procedure TMemoryStream.SetCapacity(Value: integer);
begin
  fCapacity := Value;
  ReallocMem(fMemory,fCapacity);
  if fPosition>=fCapacity then // adjust Position if truncated
    fPosition := fCapacity-1;
  if fSize>=fCapacity then     // adjust Size if truncated
    fSize := fCapacity-1;
end;

procedure TMemoryStream.SetSize(Value: integer);
begin
  if Value>fCapacity then
    SetCapacity(Value+16384); // reserve some space for inplace growing
  fSize := Value;
end;

destructor TMemoryStream.Destroy;
begin
  LLCLS_FreeMemAndNil(fMemory);
  inherited;
end;

function TMemoryStream.Write(var Buffer; Count: integer): integer;
var Pos: integer;
begin
  if (FPosition>=0) and (Count>0) then begin
    Pos := FPosition+Count;
    if Pos>FSize then begin
      if Pos>FCapacity then
        if Pos>65536 then // growing by 16KB chunck up to 64KB, then by 1/4 of size
          SetCapacity(Pos+Pos shr 2) else
          SetCapacity(Pos+16384);
      FSize := Pos;
    end;
    Move(Buffer, (PAnsiChar(Memory)+FPosition)^, Count);
    FPosition := Pos;
    result := Count;
  end else
    result := 0;
end;

procedure TMemoryStream.LoadFromStream(aStream: TStream);
var L: integer;
begin
  if aStream=nil then exit;
  L := aStream.Size;
  SetCapacity(L);
  aStream.Position := 0;
  if (L<>0) and (aStream.Read(Memory^,L)<>L) then
    raise EStreamError.Create(LLCL_STR_CLAS_LOAD);
  fPosition := 0;
  fSize := L;
end;

{ TResourceStream }

constructor TResourceStream.Create(Instance: THandle;
  const ResName: string; ResType: PChar);
// just a copy from resource to local TMemoryStream -> shorter code
var HResInfo: THandle;
    HGlobal: THandle;
begin
  HResInfo := LLCL_FindResource(Instance, @ResName[1], PChar(ResType));
  if HResInfo=0 then
    exit;
  HGlobal := LLCL_LoadResource(HInstance, HResInfo);
  if HGlobal=0 then
    exit;
  SetPointer(LLCL_LockResource(HGlobal), SizeOfResource(Instance, HResInfo));
  FPosition := 0;
end;

{$ifdef MSWindows}
{ TThread }

function ThreadProc(Thread: TThread): integer;
var FreeThread: boolean;
begin
  result := 0;  // default ExitCode
  if (not Thread.fTerminated) then
    try
      try
        Thread.Execute;
      except
        on Exception do
          result := -1;
      end;
    finally
      FreeThread := Thread.fFreeOnTerminate;
      if Assigned(Thread.OnTerminate) then
        try
          // Caution: OnTerminate is called in the thread task
          Thread.OnTerminate(Thread);
        except
          Thread.OnTerminate := nil;
        end;
      Thread.fFinished := true;
      if FreeThread then
        Thread.Free;
      EndThread(result);
    end;
end;

constructor TThread.Create(CreateSuspended: boolean);
begin
  IsMultiThread := true; // for FastMM4 locking, e.g.
  inherited Create;
  fSuspended := CreateSuspended;
  fCreateSuspended := CreateSuspended;
  fHandle := BeginThread(nil, 0, TThreadFunc(@ThreadProc), Pointer(self), CREATE_SUSPENDED, fThreadID);
  if fHandle = 0 then
    raise Exception.Create({$ifdef Def_FPC_StdSys}ansistring{$else}string{$endif}(SysErrorMessage(LLCL_GetLastError())));
  LLCL_SetThreadPriority(fHandle, THREAD_PRIORITY_NORMAL);
end;

destructor TThread.Destroy;
begin
  if (fThreadID<>0) and (not fFinished) then  // Impossible if called inside ThreadProc
    begin
      Terminate;
      if fSuspended then
        Resume;
      WaitFor;
    end;
  if fHandle<>0 then
    LLCL_CloseHandle(fHandle);
  inherited Destroy;
end;

procedure TThread.AfterConstruction;
begin
  if not fCreateSuspended then
    Resume;
end;

procedure TThread.Resume;
var SuspCount: integer;
begin
  SuspCount := LLCL_ResumeThread(fHandle);  // returns the thread's previous suspend count
  if (SuspCount=0) or (SuspCount=1) then    // (-1 indicates an error)
    fSuspended := false;
end;

procedure TThread.SetSuspended(Value: boolean);
begin
  if Value<>fSuspended then
    if Value then
      Suspend else
      Resume;
end;

procedure TThread.Suspend;
begin
  if LLCL_SuspendThread(fHandle)<>DWORD(-1) then  // (-1 indicates an error)
    fSuspended := true;
end;

{$ifdef Def_ThreadStart}
procedure TThread.Start;
begin
  Resume;
end;
{$endif}

procedure TThread.Terminate;
begin
  fTerminated := true;
end;

function TThread.WaitFor: cardinal;
begin
  LLCL_WaitForSingleObject(fHandle, INFINITE);
  LLCL_GetExitCodeThread(fHandle, result);
end;

{ TCustomMemoryStream }

function TCustomMemoryStream.GetPosition(): integer;
begin
  result := fPosition;
end;

function TCustomMemoryStream.GetSize(): integer;
begin
  result := fSize;
end;

function TCustomMemoryStream.Read(var Buffer; Count: integer): integer;
begin
  if Memory<>nil then
  if (FPosition>=0) and (Count>0) then begin
    result := FSize - FPosition;
    if result>0 then begin
      if result>Count then result := Count;
      Move((PAnsiChar(Memory)+FPosition)^, Buffer, result);
      Inc(FPosition, result);
      Exit;
    end;
  end;
  result := 0;
end;

procedure TCustomMemoryStream.SaveToStream(aStream: TStream);
begin
  if (FSize<>0) and (aStream<>nil) and (Memory<>nil) then
    aStream.Write(Memory^, FSize);
end;

function TCustomMemoryStream.Seek(Offset: integer; Origin: Word): integer;
begin
  result := Offset; // default is soFromBeginning
  case Origin of
    soFromEnd:       Inc(result, fSize);
    soFromCurrent:   Inc(result, fPosition);
  end;
  if result<=fSize then
    fPosition := result else begin
    result := fSize;
    fPosition := fSize;
  end;
end;

procedure TCustomMemoryStream.SetPointer(Buffer: pointer; Count: integer);
begin
  fMemory := Buffer;
  fSize := Count;
end;

procedure TCustomMemoryStream.SetPosition(Value: integer);
begin
  if Value>fSize then
    Value := fSize;
  fPosition := Value;
end;

procedure TCustomMemoryStream.SetSize(Value: integer);
begin
  fSize := Value;
end;
{$endif}

//------------------------------------------------------------------------------

function Point(AX, AY: integer): TPoint;
begin
  result.x := AX;
  result.y := AY;
end;

function Rect(ALeft, ATop, ARight, ABottom: integer): TRect;
begin
  result.Left   := ALeft;
  result.Top    := ATop;
  result.Right  := ARight;
  result.Bottom := ABottom;
end;

function Bounds(ALeft, ATop, AWidth, AHeight: integer): TRect;
begin
  result.Left   := ALeft;
  result.Top    := ATop;
  result.Right  := ALeft + AWidth;
  result.Bottom := ATop + AHeight;
end;

// (Not VCL/LCL standard)

function StringIndex(const s: string; const p: array of PChar): integer;
begin
  result := High(p);
  while (result>=0) and (StrIComp(p[result], pointer(s))<>0) do
    Dec(result);
end;

//------------------------------------------------------------------------------

initialization
{$IFDEF FPC}
  MainThreadID := LLCL_GetCurrentThreadID();
{$ENDIF FPC}

finalization
  RegisteredClasses.Free;

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
