unit Graphics;

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
    * TIcon (minimal) added  - Intermediate TGraphicData class created
    * TPicture: Stretch and LoadFromFile added (only for .BMP bitmap files)
    * TPicture: DrawRect in protected part (not standard)
    * TPicture: Bitmap added and all functions deported to TBitmap
    * TBitmap implemented
}

// Original notes from LVCL

{
         LVCL - Very LIGHT VCL
         ----------------------------

   Tiny replacement for the standard VCL Graphics.pas
   Just put the LVCL directory in your Project/Options/Path/SearchPath
   and your .EXE will shrink from 300KB to 30KB

   Notes:
   - implements TBrush+TCanvas+TFont+TPen+TPicture
   - compatible with the standard .DFM files.
   - only use existing properties in your DFM, otherwise you'll get error on startup
   - TFont: only default CharSet is available
   - TPicture is only for bitmap (advice: use UPX to shrink your EXE)

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
  LLCLOSInt, Windows,
  Classes;

type
  TColor = -$7FFFFFFF-1..$7FFFFFFF;

  TFontStyle = (fsBold, fsItalic, fsUnderline, fsStrikeOut);
  TFontStyles = set of TFontStyle;

  TFont = class(TPersistent)
  private
    fHandle: THandle;
    fColor: integer;
    fHeight: integer;
    fName: string;
    fStyle: TFontStyles;
    function  GetHandle(): THandle;
  protected
    procedure  ReadProperty(const PropName: string; Reader: TReader); override;
  public
    destructor Destroy; override;
    procedure Assign(AFont: TFont);
    property  Handle: THandle read GetHandle;
    property  Color: integer read fColor write fColor;
    property  Height: integer read fHeight write fHeight;
    property  Name: string read fName write fName;
    property  Style: TFontStyles read fStyle write fStyle;
  end;

  TStaticHandle = object
  // static object since we don't need to free any memory or read any property
  private
    fHandle: THandle;
    fColor: integer;
    procedure SetValue(var Value: integer; NewValue: integer);
    procedure SetColor(const Value: integer);
  public
    property  Color: integer read fColor write SetColor;
  end;

  TPen = object(TStaticHandle)
  private
    fWidth: integer;
    procedure SetWidth(const Value: integer);
  public
    procedure Select(Canvas: HDC);
    property  Width: integer read fWidth write SetWidth;
  end;

  TBrushStyle = (bsSolid, bsClear, bsHorizontal, bsVertical, bsFDiagonal,
    bsBDiagonal, bsCross, bsDiagCross);

  TBrush = object(TStaticHandle)
  private
    fStyle: TBrushStyle;
    procedure SetStyle(const Value: TBrushStyle);
    function  GetHandle(): THandle;
  public
    property  Style: TBrushStyle read fStyle write SetStyle;
    property  Handle: THandle read GetHandle;
  end;

  TCanvas = class
  private
    fFont: TFont;
    fHandle: THandle;
    procedure SetFont(Value: TFont);
    function  GetFont(): TFont;
  protected
    procedure PrepareText;
  public
    Pen: TPen;
    Brush: TBrush;
    destructor  Destroy; override;
    procedure FillRect(const R: TRect);
    procedure MoveTo(x,y: integer);
    procedure LineTo(x,y: integer);
    procedure Rectangle(x1,y1,x2,y2: integer);
    procedure FrameRect(const Rect: TRect; cl1,cl2: integer);
    procedure TextOut(x,y: integer; const s: string);
    procedure TextRect(const Rect: TRect; x,y: integer; const s:string);
    function  TextWidth(const s: string): integer;
    function  TextHeight(const s: string): integer;
    property  Handle: THandle read fHandle write fHandle;
    property  Font: TFont read GetFont write SetFont;
  end;

  /// used to store graphic data when form loading
  TGraphicData = class(TPersistent)
  private
    fSize: integer;
    fData: pByte;
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
  public
    destructor  Destroy; override;
  end;

  TBitmap = class(TGraphicData)
  private
    function  GetEmpty(): boolean;
    procedure LoadFromMemory(BufferBitmap: pointer; BufferSize: integer);
    procedure DrawRect(const R: TRect; Canvas: TCanvas; Stretch: boolean);
  public
    procedure Assign(ABitmap: TBitmap);
    procedure LoadFromResourceName(Instance: THandle; const ResName: string);
    procedure LoadFromFile(const FileName: string);
    property  Empty: boolean read GetEmpty;
  end;

  /// this TImage component only handle a bitmap
  TPicture = class(TPersistent)
  fBitmap: TBitmap;
  function  GetBitmap(): TBitmap;
  procedure SetBitmap(ABitmap: TBitMap);
  protected
    procedure DrawRect(const R: TRect; Canvas: TCanvas; Stretch: boolean);
  public
    destructor  Destroy; override;
    procedure Assign(APicture: TPicture);
{$IFDEF FPC}
    procedure LoadFromResourceName(Instance: THandle; const ResName: string);
{$ENDIF FPC}
    procedure LoadFromFile(const FileName: string);
    property  Bitmap: TBitmap read GetBitmap write SetBitmap;
  end;

  TIcon = class(TGraphicData)
  private
    fHandle: THandle;
  protected
    procedure SetHandle(Value: THandle); virtual;
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
  public
    destructor Destroy; override;
    property  Handle: THandle read fHandle write SetHandle;
  end;

  PBMP = ^TBMP;
  // match DFM binary content
  TBMP = packed record
    ClassName: string[7]; // "TBitmap"
    Size: integer;
    FileHeader: TBitmapFileHeader;
    InfoHeader: TBitmapInfo;
  end;

  TIconHeader = packed record
    idReserved: Word;       // Reserved (must always be 0)
    idType: Word;           // Image type (1 for icon)
    idCount: Word;          // Number of images
  end;
  TIconDirEntry = packed record
    bWidth: Byte;           // Image width in pixels
    bHeight: Byte;          // Image height in pixels
    bColorCount: Byte;      // Number of colors in color palette (0 if no color palette)
    bReserved: Byte;        // Reserved (must be 0)
    wPlanes: Word;          // Color planes (0 or 1)
    wBitCount: Word;        // Bits per pixel
    dwBytesInRes: DWORD;    // Size of image data
    dwImageOffset: DWORD;   // Offset of BMP/PNG data
  end;
  P1ICO = ^T1ICO;
  T1ICO = packed record
    FullSize: DWORD;
    IconHeader: TIconHeader;
    IconDirEntry: TIconDirEntry;
  end;

const
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

//------------------------------------------------------------------------------

implementation

uses
  SysUtils;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

//------------------------------------------------------------------------------

{ TFont }

destructor TFont.Destroy;
begin
  LLCL_DeleteObject(fHandle);
  inherited;
end;

procedure TFont.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..3] of PChar = (
    'Color', 'Height', 'Name', 'Style');
begin
  case StringIndex(PropName, Properties) of
    0 : fColor := Reader.ColorProperty;
    1 : fHeight := Reader.IntegerProperty;
    2 : fName := Reader.StringProperty;
    3 : Reader.SetProperty(fStyle, TypeInfo(TFontStyle));
   else inherited;
  end;
end;

procedure TFont.Assign(AFont: TFont);
begin
  LLCL_DeleteObject(fHandle);
  fHandle  := 0;
  if Assigned(AFont) then
    begin
      fColor   := AFont.fColor;
      fHeight  := AFont.fHeight;
      fName    := AFont.fName;
      fStyle   := AFont.fStyle;
    end;
end;

function TFont.GetHandle(): THandle;
var LogFont: TCustomLogFont;
begin
  result := 0;
  if fName='' then exit;
  if fHandle=0 then begin
    FillChar(LogFont, SizeOf(LogFont), 0);
    with LogFont do begin
      lfHeight := fHeight;
      if fsBold in fStyle then
        lfWeight := FW_BOLD else
        lfWeight := FW_NORMAL;
      lfItalic := byte(fsItalic in fStyle);
      lfUnderline := byte(fsUnderline in fStyle);
      lfStrikeOut := byte(fsStrikeOut in fStyle);
      lfCharSet := DEFAULT_CHARSET;
    end;
    fHandle := LLCLS_CreateFontIndirect(LogFont, fName);
  end;
  result := fHandle;
end;

{ TStaticHandle }

procedure TStaticHandle.SetColor(const Value: integer);
begin
  SetValue(fColor, Value);
end;

procedure TStaticHandle.SetValue(var Value: integer; NewValue: integer);
begin // tricky procedure for shorter code
  if Value=NewValue then exit;
  if fHandle<>0 then begin
    LLCL_DeleteObject(fHandle);
    fHandle := 0;
  end;
  Value := NewValue;
end;

{ TPen }

procedure TPen.Select(Canvas: HDC);
begin
  if fHandle=0 then begin // create object once
    if Width=0 then
      fWidth := 1;
    fHandle := LLCL_CreatePen(PS_SOLID, Width, Color);
  end;
  LLCL_SelectObject(Canvas, fHandle);
end;

procedure TPen.SetWidth(const Value: integer);
begin
  SetValue(fWidth, Value);
end;

{ TBrush }

procedure TBrush.SetStyle(const Value: TBrushStyle);
begin // tricky conversion of Value into integer for shorter code
  SetValue(PInteger(@fStyle)^, integer(Value));
end;

function TBrush.GetHandle(): THandle;
begin
  if fHandle=0 then // create object once
    case fStyle of
      bsClear: ;
      bsSolid: fHandle := LLCL_CreateSolidBrush(fColor);
    end;
  result := fHandle;
end;

{ TCanvas }

destructor TCanvas.Destroy;
begin
  LLCL_DeleteObject(Brush.fHandle);
  LLCL_DeleteObject(Pen.fHandle);
  fFont.Free;
  inherited;
end;

function TCanvas.GetFont(): TFont;
begin
  if fFont=nil then
    fFont := TFont.Create;
  result := fFont;
end;

procedure TCanvas.SetFont(Value: TFont);
begin
  Font.Assign(Value);
end;

procedure TCanvas.FillRect(const R: TRect);
begin
  LLCL_FillRect(fHandle, R, Brush.GetHandle());
end;

procedure TCanvas.Rectangle(x1,y1,x2,y2: integer);
begin
  Pen.Select(fHandle);
  LLCL_Rectangle(fHandle, x1, y1, x2, y2);
end;

procedure TCanvas.FrameRect(const Rect: TRect; cl1,cl2: integer);
begin
  Pen.Color := cl1;
  MoveTo(Rect.Left, Rect.Bottom);
  LineTo(Rect.Left, Rect.Top);
  LineTo(Rect.Right, Rect.Top);
  Pen.Color := cl2;
  LineTo(Rect.Right, Rect.Bottom);
  LineTo(Rect.Left, Rect.Bottom);
end;

procedure TCanvas.MoveTo(x,y: integer);
begin
  LLCL_MoveToEx(fHandle, x, y, nil);
end;

procedure TCanvas.LineTo(x,y: integer);
begin
  Pen.Select(fHandle);
  LLCL_LineTo(fHandle, x, y);
end;

procedure TCanvas.PrepareText;
begin
  LLCL_SelectObject(fHandle, Font.Handle);
  LLCL_SetBkColor(fHandle, Brush.fColor);
  LLCL_SetTextColor(fHandle, Font.fColor);
end;

procedure TCanvas.TextOut(x,y: integer; const s: string);
begin
  if s='' then exit;
  PrepareText;
  LLCL_TextOut(fHandle, x, y, pointer(s), length(s));
end;

procedure TCanvas.TextRect(const Rect: TRect; x, y: integer; const s: string);
begin
  if s='' then exit;
  PrepareText;
//  DrawText handles line breaks, not ExtTextOut (clip)
//  DrawText(fHandle, pointer(s), length(s), R, DT_LEFT or DT_NOPREFIX or DT_WORDBREAK);
  LLCL_ExtTextOut(fHandle, x, y, ETO_CLIPPED, @Rect, pointer(s), length(s), nil);
end;

function TCanvas.TextWidth(const s: string): integer;
var Size: TSize;
begin
  LLCL_GetTextExtentPoint32(fHandle, pointer(s), length(s), Size);
  result := Size.cX;
end;

function TCanvas.TextHeight(const s: string): integer;
var Size: TSize;
begin
  LLCL_GetTextExtentPoint32(fHandle, pointer(s), length(s), Size);
  result := Size.cY;
end;

{ TGraphicData }

destructor TGraphicData.Destroy;
begin
  if Assigned(fData) then
    FreeMem(fData);
  inherited;
end;

procedure TGraphicData.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..0] of PChar = ('Data');
begin
  case StringIndex(PropName, Properties) of
    0 : fData := Reader.BinaryProperty(fSize);
   else inherited;
  end;
end;

{ TBitmap }

procedure TBitmap.Assign(ABitmap: TBitmap);
begin
  if Assigned(fData) then
    FreeMem(fData);
  if Assigned(ABitmap) then
    begin
      fSize := ABitmap.fSize;
      Move(ABitmap.fData, fData, fSize);
    end
  else
    begin
      fData := nil;
      fSize := 0;
    end;
end;

function  TBitmap.GetEmpty(): boolean;
begin
  result := not Assigned(fData);
end;

procedure TBitmap.DrawRect(const R: TRect; Canvas: TCanvas; Stretch: boolean);
var Width, Height, YCoord: integer;
begin
  if Assigned(fData) and (fSize>=SizeOf(TBitmapFileHeader)) then
  with PBMP(fData)^ do
  if (string(ClassName)='TBitmap') and (FileHeader.bfType=$4D42) then   // 'BM' inversed
    if Stretch then
      begin
        LLCL_SetStretchBltMode(Canvas.Handle, HALFTONE);
        LLCL_StretchDIBits(
        Canvas.Handle,    // handle of device context
        R.Left,           // x-coordinate of upper-left corner of dest. rectangle
        R.Top,            // y-coordinate of upper-left corner of dest. rectangle
        R.Right-R.Left,   // dest. rectangle width
        R.Bottom-R.Top,   // dest. rectangle height
        0, // x-coordinate of lower-left corner of source rect.
        0, // y-coordinate of lower-left corner of source rect.
        InfoHeader.bmiHeader.biWidth,  // source rectangle width
        InfoHeader.bmiHeader.biHeight, // source rectangle height
        {$IFDEF FPC}    // Avoid compilation warnings
        pByte(pByte(@FileHeader)+FileHeader.bfOffBits), // address of array with DIB bits
        {$ELSE FPC}
        pByte(NativeUInt(@FileHeader)+NativeUInt(FileHeader.bfOffBits)), // address of array with DIB bits
        {$ENDIF FPC}
        InfoHeader,     // address of structure with bitmap info.
        DIB_RGB_COLORS, // RGB or palette indices
        SRCCOPY);
      end
    else
      begin
        Width := InfoHeader.bmiHeader.biWidth;
        if Width > (R.Right-R.Left) then Width := (R.Right-R.Left);
        YCoord := 0;
        Height := InfoHeader.bmiHeader.biHeight;
        if Height > (R.Bottom-R.Top) then
          begin
            YCoord := Height - (R.Bottom-R.Top);
            Height := (R.Bottom-R.Top);
          end;
        LLCL_SetDIBitsToDevice(
        Canvas.Handle,  // handle of device context
        R.Left,         // x-coordinate of upper-left corner of dest. rectangle
        R.Top,          // y-coordinate of upper-left corner of dest. rectangle
        Width,          // image width
        Height,         // image height
        0,      // x-coordinate of lower-left corner of source rect.
        YCoord, // y-coordinate of lower-left corner of source rect.
        0,      // first scan line in array
        InfoHeader.bmiHeader.biHeight, // number of scan lines
        {$IFDEF FPC}    // Avoid compilation warnings
        pByte(pByte(@FileHeader)+FileHeader.bfOffBits), // address of array with DIB bits
        {$ELSE FPC}
        pByte(NativeUInt(@FileHeader)+NativeUInt(FileHeader.bfOffBits)), // address of array with DIB bits
        {$ENDIF FPC}
        InfoHeader,     // address of structure with bitmap info.
        DIB_RGB_COLORS  // RGB or palette indices
        );
      end;
end;

procedure TBitmap.LoadFromMemory(BufferBitmap: pointer; BufferSize: integer);
begin
  if Assigned(fData) then
    FreeMem(fData);
  fSize := BufferSize+(SizeOf(PBMP(fData)^.ClassName)+SizeOf(PBMP(fData)^.Size));
  GetMem(fData, fSize);
  with PBMP(fData)^ do begin // mimic .dfm binary stream
    ClassName := 'TBitmap';
    Size := BufferSize;
    Move(BufferBitmap^, FileHeader, BufferSize);
  end;
end;

procedure TBitmap.LoadFromResourceName(Instance: THandle; const ResName: string);
var HResInfo: THandle;
var HGlobal: THandle;
var HRes: pointer;
begin
  HResInfo := LLCL_FindResource(Instance, pointer(ResName), PChar('BMP'));
  if HResInfo<>0 then begin
    HGlobal := LLCL_LoadResource(Instance, HResInfo);
    if HGlobal<>0 then begin
      HRes := LLCL_LockResource(HGlobal);
      if Assigned(HRes) then begin
        LoadFromMemory(HRes, SizeOfResource(Instance, HResInfo));
        LLCL_UnlockResource(NativeUInt(HRes));
      end;
      LLCL_FreeResource(HGlobal);
    end;
  end;
end;

procedure TBitmap.LoadFromFile(const FileName: string);
var FileHandle: THandle;
var LastOSError: cardinal;
var FileSizeHigh, FileSizeLow: DWORD;
var Buffer: pByte;
var BufferSize: integer;
var IsOK: boolean;
begin
  IsOK := false;
  FileHandle := LLCL_CreateFile(@FileName[1], GENERIC_READ,
    0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0, LastOSError);
  if FileHandle<>0 then
    begin
      FileSizeLow := LLCL_GetFileSize(FileHandle, FileSizeHigh);
      if (FileSizeLow>14) and (FileSizeLow<>INVALID_FILE_SIZE) and (FileSizeHigh=0) then    // (bitmap < 4GB)
        if integer(LLCL_SetFilePointer(FileHandle, 0, nil, FILE_BEGIN))<>INVALID_SET_FILE_POINTER then
          begin
            BufferSize := FileSizeLow;
            GetMem(Buffer, BufferSize);
            if LLCL_ReadFile(FileHandle, Buffer^, BufferSize, FileSizeLow, nil) then
              // Minimal check
              if pWord(Buffer)^=$4D42 then    // 'BM' inversed
                begin
                  LoadFromMemory(Buffer, BufferSize);
                  IsOk := true;
                end;
            FreeMem(Buffer);
          end;
      LLCL_CloseHandle(FileHandle);
    end;
  if not IsOK then
    raise EClassesError.Create(LLLC_STR_GRAP_BITMAPFILEERR);
end;

{ TPicture }

destructor TPicture.Destroy;
begin
  if Assigned(fBitmap) then
    fBitmap.Free;
  inherited;
end;

procedure TPicture.Assign(APicture: TPicture);
begin
  if Assigned(APicture) then
    Bitmap.Assign(APicture.Bitmap)
  else
    Bitmap.Assign(nil);
end;

function TPicture.GetBitmap(): TBitmap;
begin
  if not Assigned(fBitmap) then
    fBitmap := TBitmap.Create;
  result := fBitmap;
end;

procedure TPicture.SetBitmap(ABitmap: TBitMap);
begin
  Bitmap.Assign(ABitmap);   // (not fBitmap);
end;

procedure TPicture.DrawRect(const R: TRect; Canvas: TCanvas; Stretch: boolean);
begin
  if Assigned(fBitmap) then
    fBitmap.DrawRect(R, Canvas, Stretch);
end;

{$IFDEF FPC}
procedure TPicture.LoadFromResourceName(Instance: THandle; const ResName: string);
begin
  Bitmap.LoadFromResourceName(Instance, ResName);   // (not fBitmap)
end;
{$ENDIF FPC}

procedure TPicture.LoadFromFile(const FileName: string);
begin
  Bitmap.LoadFromFile(FileName);  // (not fBitmap)
end;

{ TIcon }

destructor TIcon.Destroy;
begin
  if fHandle<>0 then
    LLCL_DestroyIcon(fHandle);
  inherited;
end;

procedure TIcon.ReadProperty(const PropName: string; Reader: TReader);
begin
  inherited;
  // minimal checks, only the first icon and only simple ones
  if fSize>SizeOf(T1ICO) then
    with P1ICO(fData)^ do
      if (FullSize>SizeOf(T1ICO)) and (IconHeader.idCount>=1) and (IconDirEntry.dwBytesInRes>0) and
        (IconDirEntry.dwImageOffset+IconDirEntry.dwBytesInRes<=FullSize) then
        {$IFDEF FPC}    // Avoid compilation warnings
        fHandle := LLCL_CreateIconFromResource(pByte(fData+SizeOf(FullSize)+IconDirEntry.dwImageOffset),
                      IconDirEntry.dwBytesInRes, true, $00030000);
        {$ELSE FPC}
        fHandle := LLCL_CreateIconFromResource(pByte(NativeUInt(fData)+NativeUInt(SizeOf(FullSize))+NativeUInt(IconDirEntry.dwImageOffset)),
                      IconDirEntry.dwBytesInRes, true, $00030000);
        {$ENDIF FPC}
end;

procedure TIcon.SetHandle(Value: THandle);
begin
  fHandle := Value;
end;

//------------------------------------------------------------------------------

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
