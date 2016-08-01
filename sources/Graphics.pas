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

    This Source Code Form is "Incompatible With Secondary Licenses",
  as defined by the Mozilla Public License, v. 2.0.

  Copyright (c) 2015-2016 ChrisF

  Based upon the Very LIGHT VCL (LVCL):
  Copyright (c) 2008 Arnaud Bouchez - http://bouchez.info
  Portions Copyright (c) 2001 Paul Toth - http://tothpaul.free.fr

   Version 1.02:
   Version 1.01:
    * TBitmap: PNG files support added (not enabled by default - see LLCL_OPT_PNGSUPPORT/LLCL_OPT_PNGSIMPLIFIED in LLCLOptions.inc)
    * TBitmap: transparent bitmap support added (not enabled by default - see LLCL_OPT_IMGTRANSPARENT in LLCLOptions.inc)
    * TGraphicData: ClearData added
    * TGraphicData, TPicture: OnChange added (when bitmap data are changed)
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
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
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
    EOnChange: TNotifyEvent;
    procedure ClearData();
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    property  BinaryData: pByte read fData write fData;       // (Not standard)
    property  BinaryDataSize: integer read fSize write fSize; //    "   "
  public
    destructor  Destroy; override;
    property  OnChange: TNotifyEvent read EOnChange write EOnChange;
  end;

  TBitmap = class(TGraphicData)
  private
{$IFDEF LLCL_OPT_IMGTRANSPARENT}
    TranspType: integer;
{$ENDIF LLCL_OPT_IMGTRANSPARENT}
    function  GetEmpty(): boolean;
    procedure DrawRect(const R: TRect; Canvas: TCanvas; Stretch: boolean);
    procedure MoveToData(BufferBitmap: pointer; BufferSize: integer);
{$IFDEF LLCL_OPT_PNGSUPPORT}
    function  ConvertFromPNG(): boolean;
{$ENDIF LLCL_OPT_PNGSUPPORT}
{$IFDEF LLCL_OPT_IMGTRANSPARENT}
    procedure TranspPreProcess();
    function  TranspProcess(DestHDC: HDC; const R: TRect; Stretch: boolean): boolean;
{$ENDIF LLCL_OPT_IMGTRANSPARENT}
  protected
{$IFDEF LLCL_OPT_PNGSUPPORT}
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
{$ENDIF LLCL_OPT_PNGSUPPORT}
    function  LoadFromMemory(BufferBitmap: pointer; BufferSize: integer): boolean;
  public
    procedure Assign(ABitmap: TBitmap);
    procedure LoadFromResourceName(Instance: THandle; const ResName: string);
    procedure LoadFromFile(const FileName: string);
    property  Empty: boolean read GetEmpty;
  end;

  /// this TImage component only handle a bitmap
  TPicture = class(TPersistent)
  private
    fBitmap: TBitmap;
    EOnChange: TNotifyEvent;
    function  GetBitmap(): TBitmap;
    procedure SetBitmap(ABitmap: TBitmap);
    procedure SetOnChange(Value: TNotifyEvent);
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
    property  OnChange: TNotifyEvent read EOnChange write SetOnChange;
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
{$IFDEF LLCL_OPT_PNGSUPPORT}
  LLCLPng,
{$ENDIF LLCL_OPT_PNGSUPPORT}
  SysUtils;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

type
  PBMP = ^TBMP;
  // match DFM binary content
  TBMP = packed record
    ClassName:  string[7];   // "TBitmap"
    Size:       integer;
    FileHeader: TBitmapFileHeader;
    InfoHeader: TBitmapInfo;
  end;
const
  TBMP_HEADERSIZE = 8 + 4;  // SizeOf(TBMP.ClassName) + SizeOf(TBMP.Size);

{$IFDEF LLCL_OPT_PNGSUPPORT}
type
  TPNGFileData = packed record
    Signature1: Longword;
    Signature2: Longword;
    Data:       array [0..0] of byte;
  end;
  PPNG = ^TPNG;
  TPNG = packed record
    ClassName:  string[23];  // "TPortableNetworkGraphic"
    Size:       integer;
    FileData:   TPNGFileData;
  end;
const
  TPNG_HEADERSIZE = 24 + 4; // SizeOf(TPNG.ClassName) + SizeOf(TPNG.Size);
{$ENDIF LLCL_OPT_PNGSUPPORT}

type
  TIconHeader = packed record
    idReserved: Word;       // Reserved (must always be 0)
    idType:     Word;       // Image type (1 for icon)
    idCount:    Word;       // Number of images
  end;
  TIconDirEntry = packed record
    bWidth:         Byte;   // Image width in pixels
    bHeight:        Byte;   // Image height in pixels
    bColorCount:    Byte;   // Number of colors in color palette (0 if no color palette)
    bReserved:      Byte;   // Reserved (must be 0)
    wPlanes:        Word;   // Color planes (0 or 1)
    wBitCount:      Word;   // Bits per pixel
    dwBytesInRes:   DWORD;  // Size of image data
    dwImageOffset:  DWORD;  // Offset of BMP/PNG data
  end;
  P1ICO = ^T1ICO;
  T1ICO = packed record
    FullSize:     DWORD;
    IconHeader:   TIconHeader;
    IconDirEntry: TIconDirEntry;
  end;

const
  TBITMAPNAME       = 'TBitmap';
  TBITMAPIDENT      = $4D42;      // 'BM' inversed
{$IFDEF LLCL_OPT_PNGSUPPORT}
  TPNGGRAPHICNAME   = 'TPortableNetworkGraphic';
  TPNGSIGNATURE1    = $474E5089;  // #89'PNG' inversed
{$ENDIF LLCL_OPT_PNGSUPPORT}

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
  LLCL_FillRect(fHandle, R, Brush.Handle);
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
  ClearData();
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

procedure TGraphicData.ClearData();
begin
  LLCLS_FreeMemAndNil(fData);
  fSize := 0;
  if Assigned(EOnChange) then
    EOnChange(self);
end;

{ TBitmap }

procedure TBitmap.Assign(ABitmap: TBitmap);
begin
  ClearData();
  {$IFDEF LLCL_OPT_IMGTRANSPARENT}
  TranspType := 0;
  {$ENDIF LLCL_OPT_IMGTRANSPARENT}
  if Assigned(ABitmap) then
    begin
      fSize := ABitmap.fSize;
      GetMem(fData, fSize);
      Move(ABitmap.fData, fData, fSize);
      // (No ConvertFromPNG call, because it's not supposed to be possible here)
    end;
end;

function  TBitmap.GetEmpty(): boolean;
begin
  result := not Assigned(fData);
end;

procedure TBitmap.DrawRect(const R: TRect; Canvas: TCanvas; Stretch: boolean);
var Width, Height, YCoord: integer;
begin
  if Assigned(fData) and (fSize>=(TBMP_HEADERSIZE + SizeOf(TBitmapFileHeader))) then
  with PBMP(fData)^ do
  if (string(ClassName)=TBITMAPNAME) and (FileHeader.bfType=TBITMAPIDENT) then
    begin
      YCoord := 0;
      Width := R.Right - R.Left;
      Height := R.Bottom - R.Top;
      if Stretch then
        LLCL_SetStretchBltMode(Canvas.Handle, HALFTONE)
      else
        begin
          if InfoHeader.bmiHeader.biWidth<Width then
            Width := InfoHeader.bmiHeader.biWidth;
          if InfoHeader.bmiHeader.biHeight<Height then
            Height := InfoHeader.bmiHeader.biHeight
          else
            YCoord := InfoHeader.bmiHeader.biHeight - Height;
        end;
      {$IFDEF LLCL_OPT_IMGTRANSPARENT}
      if InfoHeader.bmiHeader.biBitCount=32 then
        begin
          if TranspType=0 then
            TranspPreProcess();
          if TranspType>=2 then
            begin
              // (Rect used though not really corresponding - Width<>Right and Height<>Bottom);
              TranspProcess(Canvas.Handle, Rect(R.Left, R.Top, Width, Height), Stretch);
              exit;
            end;
        end;
      {$ENDIF LLCL_OPT_IMGTRANSPARENT}
      if Stretch then
        LLCL_StretchDIBits(
          Canvas.Handle,  // handle of device context
          R.Left,         // x-coordinate of upper-left corner of dest. rectangle
          R.Top,          // y-coordinate of upper-left corner of dest. rectangle
          Width,          // dest. rectangle width
          Height,         // dest. rectangle height
          0,      // x-coordinate of lower-left corner of source rect.
          YCoord, // y-coordinate of lower-left corner of source rect.
          InfoHeader.bmiHeader.biWidth,  // source rectangle width
          InfoHeader.bmiHeader.biHeight, // source rectangle height
          {$IFDEF FPC}    // Avoid compilation warnings
          pByte(pByte(@FileHeader) + FileHeader.bfOffBits), // address of array with DIB bits
          {$ELSE FPC}
          pByte(NativeUInt(@FileHeader) + NativeUInt(FileHeader.bfOffBits)),  // address of array with DIB bits
          {$ENDIF FPC}
          InfoHeader,     // address of structure with bitmap info.
          DIB_RGB_COLORS, // RGB or palette indices
          SRCCOPY)
      else
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
          pByte(pByte(@FileHeader) + FileHeader.bfOffBits), // address of array with DIB bits
          {$ELSE FPC}
          pByte(NativeUInt(@FileHeader) + NativeUInt(FileHeader.bfOffBits)),  // address of array with DIB bits
          {$ENDIF FPC}
          InfoHeader,     // address of structure with bitmap info.
          DIB_RGB_COLORS  // RGB or palette indices
          );
    end;
end;

procedure TBitmap.MoveToData(BufferBitmap: pointer; BufferSize: integer);
begin
  ClearData();
  {$IFDEF LLCL_OPT_IMGTRANSPARENT}
  TranspType := 0;
  {$ENDIF LLCL_OPT_IMGTRANSPARENT}
  fSize := TBMP_HEADERSIZE + BufferSize;
  GetMem(fData, fSize);
  with PBMP(fData)^ do begin // mimic .dfm binary stream
    ClassName := TBITMAPNAME;
    Size := BufferSize;
    Move(BufferBitmap^, FileHeader, BufferSize);
  end;
end;

{$IFDEF LLCL_OPT_PNGSUPPORT}
function  TBitmap.ConvertFromPNG(): boolean;
var BufferBitmap: PByteArray;
var BufferSize: cardinal;
begin
  result := false;
  if Assigned(fData) and (fSize>=(TPNG_HEADERSIZE + SizeOf(TPNGFileData))) then
  with PPNG(fData)^ do
  if (string(ClassName)=TPNGGRAPHICNAME) and (FileData.Signature1=TPNGSIGNATURE1) then
    begin
      if PNGToBMP(@FileData, Size, BufferBitmap, BufferSize) then
        begin
          MoveToData(BufferBitmap, BufferSize);
          FreeMem(BufferBitmap);
          result := true;
        end;
    end;
  if not result then
    ClearData();
end;

procedure TBitmap.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..0] of PChar = ('Data');
begin
  case StringIndex(PropName, Properties) of
    0 : begin
          inherited;
          if (fSize>=(TPNG_HEADERSIZE + SizeOf(TPNGFileData))) and (PPNG(fData)^.FileData.Signature1=TPNGSIGNATURE1) then
            ConvertFromPNG();
        end;
    else inherited;
  end;
end;
{$ENDIF LLCL_OPT_PNGSUPPORT}

{$IFDEF LLCL_OPT_IMGTRANSPARENT}
procedure TBitmap.TranspPreProcess();
var pData, pDataTmp, pDataLoop: pByteArray;
var NbrPixels: integer;
var bAlpha: byte;
var IsTransp: boolean;
var i1, i2: integer;
begin
  IsTransp := false;
  TranspType := 1;
  if CheckWin32Version(LLCL_WIN2000_MAJ, LLCL_WIN2000_MIN) and LLCLS_CheckAlphaBlend() then
    begin
      with PBMP(fData)^ do
        begin
          NbrPixels := InfoHeader.bmiHeader.biHeight * InfoHeader.bmiHeader.biWidth;
          GetMem(pDataTmp, NbrPixels * 4);
          {$IFDEF FPC}    // Avoid compilation warnings
          pData := pByteArray(pByte(@FileHeader) + FileHeader.bfOffBits);
          {$ELSE FPC}
          pData := pByteArray(NativeUInt(@FileHeader) + NativeUInt(FileHeader.bfOffBits));
          {$ENDIF FPC}
        end;
      Move(pData^, pDataTmp^, NbrPixels * 4);
      pDataLoop := pDataTmp;
      // Premultiply for AlphaBlend
      for i1 := 0 to NbrPixels-1 do
        begin
          bAlpha := pDataLoop^[3];
          if bAlpha=0 then
            PLongword(pDataLoop)^ := 0
          else
            begin
              IsTransp := true;
              if bAlpha<>$FF then
                for i2 := 0 to 2 do
                  pDataLoop^[i2] := (pDataLoop^[i2] * bAlpha) div $FF;
            end;
          inc(pByte(pDataLoop), 4);
        end;
      if IsTransp then
        begin
          TranspType := 2;
          Move(pDataTmp^, pData^, NbrPixels * 4);
        end;
      FreeMem(pDataTmp);
    end;
end;

function  TBitmap.TranspProcess(DestHDC: HDC; const R: TRect; Stretch: boolean): boolean;
var BMPHDC: HDC;
var BMPHandle: HBITMAP;
var ftn: BLENDFUNCTION;
var BMPWidth, BMPHeight: integer;
begin
  ftn.BlendOp := AC_SRC_OVER;
  ftn.BlendFlags := 0;
  ftn.SourceConstantAlpha := $FF;
  ftn.AlphaFormat := AC_SRC_ALPHA;
  with PBMP(fData)^ do
    begin
      BMPHDC := LLCL_CreateCompatibleDC(DestHDC);
      {$IFDEF FPC}    // Avoid compilation warnings
      BMPHandle := LLCL_CreateDIBitmap(DestHDC, @InfoHeader, CBM_INIT, pByte(pByte(@FileHeader) + FileHeader.bfOffBits), @InfoHeader, DIB_RGB_COLORS);
      {$ELSE FPC}
      BMPHandle := LLCL_CreateDIBitmap(DestHDC, @InfoHeader, CBM_INIT, pByte(NativeUInt(@FileHeader) + NativeUInt(FileHeader.bfOffBits)), @InfoHeader, DIB_RGB_COLORS);
      {$ENDIF FPC}
      LLCL_SelectObject(BMPHDC, BMPHandle);
      BMPWidth := InfoHeader.bmiHeader.biWidth;
      BMPHeight := InfoHeader.bmiHeader.biHeight;
      if not Stretch then
        begin
          if BMPWidth>R.Right then BMPWidth := R.Right;
          if BMPHeight>R.Bottom then BMPHeight := R.Bottom;
        end;
      result := LLCLS_AlphaBlend(DestHDC, R.Left, R.Top, R.Right, R.Bottom, BMPHDC, 0, 0, BMPWidth, BMPHeight, ftn);
      LLCL_DeleteObject(BMPHandle);
      LLCL_DeleteDC(BMPHDC);
    end;
end;
{$ENDIF LLCL_OPT_IMGTRANSPARENT}

function  TBitmap.LoadFromMemory(BufferBitmap: pointer; BufferSize: integer): boolean;
begin
  result := true;
  ClearData();
  // minimal checks
  if (BufferSize>=SizeOf(TBitmapFileHeader)) and (PWord(BufferBitmap)^=TBITMAPIDENT) then
    MoveToData(BufferBitmap, BufferSize)
  else
{$IFDEF LLCL_OPT_PNGSUPPORT}
    if (BufferSize>=SizeOf(TPNGFileData)) and (PLongword(BufferBitmap)^=TPNGSIGNATURE1) then
      begin
        fSize := TPNG_HEADERSIZE + BufferSize;
        GetMem(fData, fSize);
        with PPNG(fData)^ do begin
          ClassName := TPNGGRAPHICNAME;
          Size := BufferSize;
          Move(BufferBitmap^, FileData, BufferSize);
          result := ConvertFromPNG();   // (fData and fSize cleared inside ConvertFromPNG, if not OK)
        end;
      end
    else
{$ENDIF LLCL_OPT_PNGSUPPORT}
      result := false;
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
        // LLCL_UnlockResource(NativeUInt(HRes)); obsolete for Windows 32/64
      end;
      // LLCL_FreeResource(HGlobal); obsolete for Windows 32/64
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
      if (FileSizeLow>8) and (FileSizeLow<>INVALID_FILE_SIZE) and (FileSizeHigh=0) then    // (data < 4GB)
        if integer(LLCL_SetFilePointer(FileHandle, 0, nil, FILE_BEGIN))<>INVALID_SET_FILE_POINTER then
          begin
            BufferSize := FileSizeLow;
            GetMem(Buffer, BufferSize);
            if LLCL_ReadFile(FileHandle, Buffer^, BufferSize, FileSizeLow, nil) then
              IsOK := LoadFromMemory(Buffer, BufferSize);
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

procedure TPicture.SetBitmap(ABitmap: TBitmap);
begin
  Bitmap.Assign(ABitmap);   // (not fBitmap);
end;

procedure TPicture.SetOnChange(Value: TNotifyEvent);
begin
  Bitmap.OnChange := Value;       // (not fBitmap)
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
        (IconDirEntry.dwImageOffset + IconDirEntry.dwBytesInRes<=FullSize) then
        {$IFDEF FPC}    // Avoid compilation warnings
        fHandle := LLCL_CreateIconFromResource(pByte(fData + SizeOf(FullSize) + IconDirEntry.dwImageOffset),
                      IconDirEntry.dwBytesInRes, true, $00030000);
        {$ELSE FPC}
        fHandle := LLCL_CreateIconFromResource(pByte(NativeUInt(fData) + NativeUInt(SizeOf(FullSize)) + NativeUInt(IconDirEntry.dwImageOffset)),
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
