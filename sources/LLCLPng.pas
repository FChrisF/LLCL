unit LLCLPng;

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
    * PNG to BMP conversion
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
  SysUtils;

function  PNGToBMP(pPNGData: PByteArray; PNGDataSize: cardinal; var pBMPData: PByteArray; var BMPDataSize: cardinal): boolean;

//------------------------------------------------------------------------------

implementation

uses
  LLCLZlib;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

const
  PNG_IDENT:		array [0..pred(8)] of byte = ($89,$50,$4E,$47,$0D,$0A,$1A,$0A);
  PNG_IHDR:     array [0..pred(4)] of byte = ($49,$48,$44,$52); // 'IHDR'
  PNG_CHUNKS:   array [0..pred(4), 0..pred(4)] of byte = (
                        ($49,$44,$41,$54),  // 'IDAT'
                        ($49,$45,$4E,$44),  // 'IEND'
                        ($50,$4C,$54,$45),  // 'PLTE'
                        ($74,$52,$4E,$53)); // 'tRNS'
type
  TPNGInfos = record
    Width:            cardinal;
    Height:           cardinal;
    BitDepth:         byte;
    ColourType:       byte;
    InterlaceMethod:  byte;
    BitsPerPixel:     cardinal;
    BytesPerPixel:    cardinal;
    RowSize:          cardinal;
    NbrPalEntries:    cardinal;
    Palette:          array [0..pred(4*256)] of byte;
    {$ifndef LLCL_OPT_PNGSIMPLIFIED}
    TranspType:       byte;
    Transp:           array [0..pred(3)] of word;
    Adam7StartPos:    array [0..pred(7)+1] of cardinal;  // (+1 for total length)
    Adam7ColsRows:    array [0..pred(7), 0..1] of cardinal;
    {$endif LLCL_OPT_PNGSIMPLIFIED}
  end;

{$ifndef LLCL_OPT_PNGSIMPLIFIED}
const
  ADAM7ColStart: array [0..pred(7)] of cardinal = (0, 4, 0, 2, 0, 1, 0);
  ADAM7ColIncrm: array [0..pred(7)] of cardinal = (8, 8, 4, 4, 2, 2, 1);
  ADAM7RowStart: array [0..pred(7)] of cardinal = (0, 0, 4, 0, 2, 0, 1);
  ADAM7RowIncrm: array [0..pred(7)] of cardinal = (8, 8, 8, 4, 4, 2, 2);
{$endif LLCL_OPT_PNGSIMPLIFIED}

function  PNGtoBMP_LongArrB(const Buffer: array of byte; Offset: cardinal): cardinal; forward;
function  PNGtoBMP_WordArrB(const Buffer: array of byte; Offset: cardinal): word; forward;
function  PNGtoBMP_SupDiv8(Value: cardinal): cardinal; forward;
function  PNGtoBMP_CheckColour(ColourType, BitDepth: byte): boolean; forward;
function  PNGToBMP_BitsPerPixel(ColourType, BitDepth: byte): cardinal; forward;
function  PNGToBMP_KnownChunk(pChunkIdent: PByteArray): integer; forward;
function  PNGtoBMP_ReverseFilter(const PNGI: TPNGInfos; pScanLines: PByteArray; pData: PByteArray): boolean; forward;
procedure PNGtoBMP_RFOneScanLine(NumScanLine, BytesPerPixel, RowSize: cardinal; FilterType: byte; pDataCur, pDataPrev, pScanLine: PByteArray); forward;
function  PNGtoBMP_PaethPredictor(a, b, c: byte): byte; forward;
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
procedure PNGToBMP_Adam7Values(var PNGI: TPNGInfos); forward;
function  PNGtoBMP_ReverseInterFilter(const PNGI: TPNGInfos; pScanLines: PByteArray; pData: PByteArray): boolean; forward;
function  PNGtoBMP_ComplPow2(Value, Power2: cardinal): cardinal; forward;
procedure PNGtoBMP_CopyBits(pDataIn, pDataOut: pByteArray; OffBitsIn, OffBitsOut, NbrBits: cardinal); forward;
{$endif LLCL_OPT_PNGSIMPLIFIED}
function  PNGtoBMP_CreateBMP(const PNGI: TPNGInfos; pData: PByteArray; var pBMPData: PByteArray; var BMPDataSize: cardinal): boolean; forward;
procedure PNGtoBMP_ArrBLongInv(var Buffer: array of byte; Offset: cardinal; Value: cardinal); forward;
procedure PNGtoBMP_ArrBWordInv(var Buffer: array of byte; Offset: cardinal; Value: word); forward;
procedure PNGtoBMP_SwapRGB(pData: PByteArray; NbrCols: cardinal; ColourType: byte); forward;
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
procedure PNGtoBMP_PaletteGrey(pPalette: PByteArray; BitDepth: byte); forward;
procedure PNGtoBMP_16to8(pData: PByteArray; NbrCols: cardinal; ColourType: byte); forward;
procedure PNGtoBMP_TrueToTrueC(pDataIn: PByteArray; pDataOut: PByteArray; const PNGI: TPNGInfos); forward;
procedure PNGtoBMP_GreyToTrueC(pData: PByteArray; NbrCols: cardinal); forward;
procedure PNGtoBMP_PalToTrueC(pData: PByteArray; const PNGI: TPNGInfos); forward;
function  PNGtoBMP_LongArrBInv(Const Buffer: array of Byte; Const Offset: cardinal): cardinal; forward;
procedure PNGtoBMP_Pal2To4(pData: PByteArray; RowSize: cardinal); forward;
{$endif LLCL_OPT_PNGSIMPLIFIED}

//------------------------------------------------------------------------------

// Converts PNG file data to BMP file data
function  PNGToBMP(pPNGData: PByteArray; PNGDataSize: cardinal; var pBMPData: PByteArray; var BMPDataSize: cardinal): boolean;
var PNGI: TPNGInfos;        // PNG image infos
var PNGDataPos: cardinal;
var ChunkSize: cardinal;
var pIDATData: PByteArray;  // IDAT chunks data, then PNG image data (after filtering + interlace processing)
var IDATDataSize, IDATDataPos: cardinal;
var pScanLines: PByteArray; // PNG scanlines data (after decompression)
var ScanLinesSize: cardinal;
var IsOK: boolean;
var i: cardinal;
begin
  result := false;
  pBMPData := nil;
  BMPDataSize := 0;
  FillChar(PNGI, SizeOf(PNGI), 0);
  // Header analysis
  if PNGDataSize<33 then exit;
  if not CompareMem(@pPNGData^[0], @PNG_IDENT[0], SizeOf(PNG_IDENT)) then exit;
  if not CompareMem(@pPNGData^[12], @PNG_IHDR[0], SizeOf(PNG_IHDR)) then exit;
  PNGI.Width := PNGtoBMP_LongArrB(pPNGData^, 16);
  PNGI.Height := PNGtoBMP_LongArrB(pPNGData^, 20);
  if (PNGI.Width=0) or (PNGI.Height=0) then exit;
  PNGI.BitDepth := pPNGData^[24];
  PNGI.ColourType := pPNGData^[25];
  if not PNGtoBMP_CheckColour(PNGI.ColourType, PNGI.BitDepth) then exit;
  PNGI.BitsPerPixel := PNGToBMP_BitsPerPixel(PNGI.ColourType, PNGI.BitDepth);
  PNGI.BytesPerPixel := PNGtoBMP_SupDiv8(PNGI.BitsPerPixel);
  PNGI.RowSize :=  PNGtoBMP_SupDiv8(PNGI.Width * PNGI.BitsPerPixel);
  PNGI.InterlaceMethod := pPNGData^[28];
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
  if (pPNGData^[26]<>0) or (pPNGData^[27]<>0) or (PNGI.InterlaceMethod>1) then exit;  // Compression, filter and interlace methods
{$else LLCL_OPT_PNGSIMPLIFIED}
  if (pPNGData^[26]<>0) or (pPNGData^[27]<>0) or (PNGI.InterlaceMethod>0) then exit;  // Compression, filter and interlace methods
{$endif LLCL_OPT_PNGSIMPLIFIED}
  // Chunk CRC ignored (1): if wanted, add CRC unit in 'uses'
  //   clause and uncomment the next instruction
  // if CRC32(0, @pPNGData^[12], 13 + 4) <> PNGtoBMP_LongArrB(pPNGData^, 12 + 13 + 4) then exit;
  IDATDataSize := PNGDataSize - 33;   // (enough for all chunks, so enough for IDAT chunks data only too)
  GetMem(pIDATData, IDATDataSize);
  IDATDataPos := 0;
  // Chunks analysis
  IsOK := false;
  PNGDataPos := 33;
  while (PNGDataPos + 12) <= PNGDataSize do
    begin
      ChunkSize := PNGtoBMP_LongArrB(pPNGData^, PNGDataPos);
      // Chunk CRC ignored (2): if wanted, add CRC unit in 'uses'
      //   clause and uncomment the next instructions
      // if (PNGDataPos + ChunkSize + 12 > PNGDataSize) then
      //   IsOk := false
      // else
      //   isOK := (CRC32(0, @pPNGData^[PNGDataPos + 4], ChunkSize + 4) = PNGtoBMP_LongArrB(pPNGData^, PNGDataPos + ChunkSize + 8));
      // if not ISOK then break;
      case PNGToBMP_KnownChunk(@pPNGData^[PNGDataPos + 4]) of
      0:  // IDAT
        begin
          if (IDATDataPos + ChunkSize) > IDATDataSize then break;
          Move(pPNGData^[PNGDataPos + 8], pIDATData^[IDATDataPos], ChunkSize);
          inc(IDATDataPos, ChunkSize);
        end;
      1:  // IEND
        begin
          IsOK := true;
          break;
        end;
      2:  // PLTE
        begin
          PNGI.NbrPalEntries := ChunkSize div 3;
          if PNGI.NbrPalEntries>256 then break;
          for i := 0 to pred(PNGI.NbrPalEntries) do
            begin
              // (RGB <-> BGR swap - BMP bitmap preparation)
              PNGI.Palette[(i*4)    ] := pPNGData^[(PNGDataPos + 8) + (i*3) + 2];
              PNGI.Palette[(i*4) + 1] := pPNGData^[(PNGDataPos + 8) + (i*3) + 1];
              PNGI.Palette[(i*4) + 2] := pPNGData^[(PNGDataPos + 8) + (i*3)    ];
              // (alpha channel = 0 by defaut, for better BMP compatibility)
            end;
        end;
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
      3:  // tRNS
        begin
          case PNGI.ColourType of
          0:    // Greyscale
            begin
              if ChunkSize<>2 then break;
              PNGI.Transp[0] := PNGtoBMP_WordArrB(pPNGData^, PNGDataPos + 8);
              PNGI.Transp[1] := PNGI.Transp[0];
              PNGI.Transp[2] := PNGI.Transp[0];
              PNGI.TranspType := 1;
            end;
          2:    // Truecolour
            begin
              if ChunkSize<>6 then break;
              for i := 0 to pred(3) do
                // (No RGB <-> BGR swap - not necessary)
                PNGI.Transp[i] := PNGtoBMP_WordArrB(pPNGData^, (PNGDataPos + 8) + (i*2));
              PNGI.TranspType := 1;
            end;
          3:    // Indexed-colour (Palette)
            begin
              if ChunkSize>PNGI.NbrPalEntries then break;   // (May have less)
              for i := 0 to pred(PNGI.NbrPalEntries) do
                begin
                  if i<ChunkSize then
                    PNGI.Palette[(i*4) + 3] := pPNGData^[(PNGDataPos + 8) + i]
                  else
                    PNGI.Palette[(i*4) + 3] := 255;
                end;
              PNGI.TranspType := 2;  // (Unused)
            end;
          else  // Error
            break;
          end;
        end;
{$endif LLCL_OPT_PNGSIMPLIFIED}
      end;
      inc(PNGDataPos, ChunkSize + 12);    // +12 for chunk ident + chunk size + chunk crc
    end;
  if IDATDataPos=0 then IsOK := false;
  if (PNGI.ColourType=3) and (PNGI.NbrPalEntries=0) then IsOK:= false;
  if not IsOK then
    begin
      FreeMem(pIDATData);
      exit;
    end;
  // Decompression (Zlib)
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
  if PNGI.InterlaceMethod=0 then
    ScanLinesSize := (1 + PNGI.RowSize) * PNGI.Height    // +1 for the filter type byte
  else
    begin
      PNGToBMP_Adam7Values(PNGI);
      ScanLinesSize := PNGI.Adam7StartPos[7];
    end;
{$else LLCL_OPT_PNGSIMPLIFIED}
  ScanLinesSize := (1 + PNGI.RowSize) * PNGI.Height;    // +1 for the filter type byte
{$endif LLCL_OPT_PNGSIMPLIFIED}
  GetMem(pScanLines, ScanLinesSize);
  IsOK := (LLCL_uncompress(PByte(pScanLines), ScanLinesSize, PByte(pIDATData), IDATDataPos) = 0);   // Z_OK=0
  FreeMem(pIDATData);
  if not IsOK then
    begin
      FreeMem(pScanLines);
      exit;
    end;
  // Scanlines processing (filtering [and interlace])
  IDATDataSize := PNGI.RowSize * PNGI.Height;
  GetMem(pIDATData, IDATDataSize);
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
  if PNGI.InterlaceMethod=0 then  // No interlace method: filtering only
    IsOK := PNGtoBMP_ReverseFilter(PNGI, pScanLines, pIDATData)
  else                            // (Always) Adam7 interlace method
    begin
      if PNGI.BitsPerPixel<8 then
        FillChar(pIDATData^,IDATDataSize, 0);   // Needed before bits copy
      IsOK := PNGtoBMP_ReverseInterFilter(PNGI, pScanLines, pIDATData);
    end;
{$else LLCL_OPT_PNGSIMPLIFIED}
  IsOK := PNGtoBMP_ReverseFilter(PNGI, pScanLines, pIDATData);
{$endif LLCL_OPT_PNGSIMPLIFIED}
  FreeMem(pScanLines);
  if not IsOK then exit;
  // BMP creation
  IsOK := PNGtoBMP_CreateBMP(PNGI, pIDATData, pBMPData, BMPDataSize);
  FreeMem(pIDATData);
  if not IsOK then exit;
  result := true;
end;
// Bytes to Long
function  PNGtoBMP_LongArrB(const Buffer: array of byte; Offset: cardinal): cardinal;
begin
  result := (Buffer[Offset] shl 24) or (Buffer[Offset+1] shl 16) or (Buffer[Offset+2] shl 8) or Buffer[Offset+3];
end;
// Bytes to Word
function  PNGtoBMP_WordArrB(const Buffer: array of byte; Offset: cardinal): word;
begin
  result := (Buffer[Offset] shl 8) or Buffer[Offset+1];
end;
// Div 8 superior
function  PNGtoBMP_SupDiv8(Value: cardinal): cardinal;
begin
  result := (Value + 7) shr 3;
end;
// Checks validity for colour parameters
function  PNGtoBMP_CheckColour(ColourType, BitDepth: byte): boolean;
begin
  case ColourType of
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
  0:        // Greyscale
    result := (BitDepth in [1, 2, 4, 8, 16]);
  2,4,6:    // Truecolour, Greyscale + alpha, Truecolour + alpha
    result := (BitDepth in [8, 16]);
  3:        // Indexed-colour
    result := (BitDepth in [1, 2, 4, 8]);
{$else LLCL_OPT_PNGSIMPLIFIED}
  2,6:      // Truecolour, Truecolour + alpha
    result := (BitDepth = 8);
  3:        // Indexed-colour
    result := (BitDepth in [1, 4, 8]);
{$endif LLCL_OPT_PNGSIMPLIFIED}
  else
    result := false;
  end;
end;
// Computes bits per pixel
function  PNGToBMP_BitsPerPixel(ColourType, BitDepth: byte): cardinal;
begin
  case ColourType of
  2:    result := 3;
  4:    result := 2;
  6:    result := 4;
  else  result := 1;
  end;
  result := result * BitDepth;
end;
// Searches for known chunks (IHDR excluded)
function  PNGToBMP_KnownChunk(pChunkIdent: PByteArray): integer;
var i: integer;
begin
  for i := 0 to pred(4) do
    if PLongword(pChunkIdent)^=PLongword(@PNG_CHUNKS[i])^ then
      begin
        result := i;
        exit;
      end;
  result := -1;
end;
// Reverses filtering (no interlace method)
function  PNGtoBMP_ReverseFilter(const PNGI: TPNGInfos; pScanLines: PByteArray; pData: PByteArray): boolean;
var curpos, outpos, outprev: cardinal;
var FilterType: byte;
var i: cardinal;
begin
  result := true;
  curpos := 0;
  outpos := 0;
  outprev := 0;
  for i := 0 to pred(PNGI.Height) do
    begin
      FilterType := pScanLines^[curpos];
      if FilterType>4 then
        begin
          result := false;
          break;
        end;
      inc(curpos);
      PNGtoBMP_RFOneScanLine(i, PNGI.BytesPerPixel, PNGI.RowSize, FilterType, @pData^[outpos], @pData^[outprev], @pScanLines^[curpos]);
      inc(curpos, PNGI.RowSize);
      outprev := outpos;
      inc(outpos, PNGI.RowSize);
    end;
end;
// Reverses filtering for one scanline
procedure PNGtoBMP_RFOneScanLine(NumScanLine, BytesPerPixel, RowSize: cardinal; FilterType: byte; pDataCur, pDataPrev, pScanLine: PByteArray);
var i: cardinal;
begin
  Move(pScanLine^, pDataCur^, RowSize);
  case FilterType of
  //0:     // None (already done)
  1:    // Sub
    begin
      for i := BytesPerPixel to pred(RowSize) do
        inc(pDataCur^[i], pDataCur^[ i - BytesPerPixel]);
    end;
  2:    // Up
    begin
      if NumScanLine>0 then       // (First scanline already done)
        for i := 0 to pred(RowSize) do
          inc(pDataCur^[i], pDataPrev^[i]);
    end;
  3:    // Average
    begin
      if NumScanLine=0 then       // First scanline
        for i := BytesPerPixel to pred(RowSize) do
          inc(pDataCur^[i], pDataCur^[i - BytesPerPixel] div 2)
      else
        begin
          for i := 0 to pred(BytesPerPixel) do
            inc(pDataCur^[i], pDataPrev^[i] div 2);
          for i := BytesPerPixel to pred(RowSize) do
            inc(pDataCur^[i], (pDataCur^[i - BytesPerPixel] + pDataPrev^[i]) div 2);
        end;
    end;
  4:    // Paeth
    begin
      if NumScanLine=0 then       // First scanline
        for i := BytesPerPixel to pred(RowSize) do
          inc(pDataCur^[i], PNGtoBMP_PaethPredictor(pDataCur^[i - BytesPerPixel], 0, 0))
      else
        begin
          for i := 0 to pred(BytesPerPixel) do
            inc(pDataCur^[i], PNGtoBMP_PaethPredictor(0, pDataPrev^[i], 0));
          for i := BytesPerPixel to pred(RowSize) do
            inc(pDataCur^[i], PNGtoBMP_PaethPredictor(pDataCur^[i - BytesPerPixel], pDataPrev^[i], pDataPrev^[i - BytesPerPixel]));
        end;
    end;
  end;
end;
// Computes Paeth predictor for filter type 4
function  PNGtoBMP_PaethPredictor(a, b, c: byte): byte;
var pa, pb, pc: integer;
begin
  pa := abs(b - c);
  pb := abs(a - c);
  pc := abs(integer(a + b - c - c));
  if (pa <= pb) and (pa <= pc) then
    result := a
  else
    if pb <= pc then
      result := b
    else
      result := c;
end;
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
// Computes values for Adam7 interlace method
procedure PNGToBMP_Adam7Values(var PNGI: TPNGInfos);
const ADAM7LenParam: array [0..pred(7), 0..pred(4)] of cardinal =
  ((7,8,7,8),(3,8,7,8),(3,4,3,8),(1,4,3,4),(1,2,1,4),(0,2,1,2),(0,1,0,2));
var i: integer;
begin
  PNGI.Adam7StartPos[0] := 0;
  for i:= 0 to pred(7) do
    begin
      PNGI.Adam7StartPos[i + 1] := PNGI.Adam7StartPos[i];
      PNGI.Adam7ColsRows[i, 0] := (PNGI.Width + ADAM7ColIncrm[i] - ADAM7ColStart[i] - 1) div ADAM7ColIncrm[i];
      PNGI.Adam7ColsRows[i, 1] := (PNGI.Height + ADAM7RowIncrm[i] - ADAM7RowStart[i] - 1) div ADAM7RowIncrm[i];
      if PNGI.Adam7ColsRows[i, 0]<>0 then
        inc(PNGI.Adam7StartPos[i + 1], (1 + PNGtoBMP_SupDiv8(((PNGI.Width + ADAM7LenParam[i, 0]) div ADAM7LenParam[i, 1]) * PNGI.BitsPerPixel)) * ((PNGI.Height + ADAM7LenParam[i, 2]) div ADAM7LenParam[i, 3]));
    end;
end;
// Reverses interlacing and filtering (Adam7 interlace method)
function  PNGtoBMP_ReverseInterFilter(const PNGI: TPNGInfos; pScanLines: PByteArray; pData: PByteArray): boolean;
var pTMPRowLines, pTMPRowLine1, pTMPRowLine2, pTMPRowSwap: PByteArray;
var curpos, linesize, colout, addout: cardinal;
var FilterType: byte;
var i, j, k: cardinal;
begin
  result := true;
  GetMem(pTMPRowLines, PNGI.RowSize * 2);   // for 2 data lines (current and previous)
  pTmpRowLine1 := @pTMPRowLines^[0];
  pTmpRowLine2 := @pTMPRowLines^[PNGI.RowSize];
  addout := 0;
  for i:=0 to pred(7) do
    if (PNGI.Adam7ColsRows[i, 0]<>0) and (PNGI.Adam7ColsRows[i, 1]<>0) then
      begin
        curpos := PNGI.Adam7StartPos[i];
        linesize := PNGtoBMP_SupDiv8(PNGI.Adam7ColsRows[i, 0] * PNGI.BitsPerPixel);
        for j:=0 to pred(PNGI.Adam7ColsRows[i, 1]) do
          begin
            FilterType := pScanLines^[curpos];
            if FilterType>4 then
                begin
                  result := false;
                  break;
                end;
            inc(curpos);
            PNGtoBMP_RFOneScanLine(j, PNGI.BytesPerPixel, linesize, FilterType, pTmpRowLine1, pTmpRowLine2, @pScanLines^[curpos]);
            colout := ((ADAM7RowStart[i] + (j * ADAM7RowIncrm[i])) * PNGI.Width) + ADAM7ColStart[i];
            if PNGI.BitsPerPixel<8 then
              addout := (colout div PNGI.Width) * PNGtoBMP_ComplPow2(PNGI.Width * PNGI.BitsPerPixel, 8);
            for k := 0 to pred(PNGI.Adam7ColsRows[i, 0]) do
              begin
                if PNGI.BitsPerPixel<8 then
                  PNGtoBMP_CopyBits(pTmpRowLine1, pData, k * PNGI.BitsPerPixel, addout + (colout * PNGI.BitsPerPixel), PNGI.BitsPerPixel)
                else
                  if PNGI.BitsPerPixel=8 then // (faster for 1 byte)
                    pData^[colout * PNGI.BytesPerPixel] := pTmpRowLine1^[k * PNGI.BytesPerPixel]
                  else
                    Move(pTmpRowLine1^[k * PNGI.BytesPerPixel], pData^[colout * PNGI.BytesPerPixel], PNGI.BytesPerPixel);
                inc(colout, ADAM7ColIncrm[i]);
              end;
            inc(curpos, linesize);
            pTMPRowSwap := pTMPRowLine1;
            pTMPRowLine1 := pTMPRowLine2;
            pTMPRowLine2 := pTMPRowSwap;
          end;
      end;
  FreeMem(pTMPRowLines);
end;
// Complement for a power of 2
function  PNGtoBMP_ComplPow2(Value, Power2: cardinal): cardinal;
begin
    result := Value and (Power2 - 1);
    if result <>0 then result := Power2 - result;
end;
// Copies bit per bit
procedure PNGtoBMP_CopyBits(pDataIn, pDataOut: pByteArray; OffBitsIn, OffBitsOut, NbrBits: cardinal);
var posIn, posOut: cardinal;
var i: cardinal;
var b: byte;
begin
  posIn := OffBitsIn; posOut := OffBitsOut;
  for i := 0 to pred(NbrBits) do
    begin
      b := (pDataIn^[posIn shr 3] shr (7 - (posIn and 7))) and 1;
      if b<>0 then  // (faster if nul)
        pDataOut^[posOut shr 3] := pDataOut^[posOut shr 3] or (b shl (7 - (posOut and 7)));
      inc(posIn); inc(posOut);
    end;
end;
{$endif LLCL_OPT_PNGSIMPLIFIED}
// Creates BMP
function  PNGtoBMP_CreateBMP(const PNGI: TPNGInfos; pData: PByteArray; var pBMPData: PByteArray; var BMPDataSize: cardinal): boolean;
const
    BMPHEADER_LEN           = 14;
    BMPDIBHEADER_LEN        = 40;     // (BITMAPINFOHEADER)
    BMPRESOLUTION_DEFAULT   = $0B12;	// Default horizontal/vertical physical resolution
var pIn, pOut: PByteArray;
var BaseSize, RowSize, NewRowSize, NewBitsPerPixel, NewNbrPalEntries: cardinal;
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
var TransformPal, TranspToProcess: boolean;
{$endif LLCL_OPT_PNGSIMPLIFIED}
var i: cardinal;
begin
  result := true;
  NewBitsPerPixel := PNGI.BitsPerPixel;
  RowSize := PNGI.RowSize;
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
  if PNGI.BitDepth=16 then            // Not supported by BMP
    begin
      if PNGI.ColourType in [0, 2, 6] then NewBitsPerPixel := PNGToBMP_BitsPerPixel(PNGI.ColourType, 8);    // (not for ColourType 4, because (*2/2)=1)
      RowSize := PNGtoBMP_SupDiv8(PNGI.Width * NewBitsPerPixel);
    end
  else
    begin
      if (PNGI.ColourType in [0, 3]) and (PNGI.BitDepth=2) then NewBitsPerPixel := 4;   // See hereafter (2 bits per pixel in palette)
      if (PNGI.ColourType=4) and (PNGI.BitDepth=8) then NewBitsPerPixel := 32;  // Transformed in truecolour+alpha
    end;
{$endif LLCL_OPT_PNGSIMPLIFIED}
  NewRowSize := (((PNGI.Width * NewBitsPerPixel) + 31) div 32) * 4;
  NewNbrPalEntries := 0;
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
  TransformPal := false;
  TranspToProcess := false;
  case PNGI.ColourType of
  0:    // Greyscale
    begin
      NewNbrPalEntries := 1 shl PNGI.BitDepth;
      if PNGI.BitDepth=16 then
        if PNGI.TranspType=1 then
          begin
            NewNbrPalEntries := 0;
            TranspToProcess := true;
          end
        else
          NewNbrPalEntries := 1 shl 8;   // BMP doesn't support 16 bits per pixel in palette
    end;
  2:    // Truecolour
    begin
      if PNGI.TranspType=1 then
        TranspToProcess := true;
    end;
  3:    // Indexed-colour (Palette)
    begin
      NewNbrPalEntries := 1 shl PNGI.BitDepth;
    end;
  end;
  BaseSize := BMPHEADER_LEN + BMPDIBHEADER_LEN;
  if NewNbrPalEntries>0 then
    begin
      if PNGI.BitDepth=2 then NewNbrPalEntries := 1 shl 4;    // BMP doesn't support 2 bits per pixel in palette
      if PNGI.ColourType=0 then   // Greyscale
        TransformPal := (PNGI.TranspType=1)
      else                        // Indexed-colour (Palette)
        TransformPal := (PNGI.TranspType<>0);
      if not TransformPal then
        BaseSize := BMPHEADER_LEN + BMPDIBHEADER_LEN + (NewNbrPalEntries * 4);
    end;
  if TranspToProcess or TransformPal then
    begin
      NewBitsPerPixel := 32;
      NewRowSize := PNGI.Width * 4;
    end;
{$else LLCL_OPT_PNGSIMPLIFIED}
  if PNGI.ColourType=3 then         // Indexed-colour (Palette)
    NewNbrPalEntries := 1 shl PNGI.BitDepth;
  BaseSize := BMPHEADER_LEN + BMPDIBHEADER_LEN + (NewNbrPalEntries * 4);
{$endif LLCL_OPT_PNGSIMPLIFIED}
  BMPDataSize := BaseSize + (NewRowSize * PNGI.Height);
  GetMem(pBMPData, BMPDataSize);
  FillChar(pBMPData^, BaseSize, 0);
  // Header
  PNGtoBMP_ArrBWordInv(pBMPData^, 0, $4D42);     // 'BM' inversed
  PNGtoBMP_ArrBLongInv(pBMPData^, 2, BMPDataSize);
  PNGtoBMP_ArrBLongInv(pBMPData^, 10, BaseSize);
  // DIB Header
  PNGtoBMP_ArrBLongInv(pBMPData^, BMPHEADER_LEN + 00, BMPDIBHEADER_LEN);
  PNGtoBMP_ArrBLongInv(pBMPData^, BMPHEADER_LEN + 04, PNGI.Width);
  PNGtoBMP_ArrBLongInv(pBMPData^, BMPHEADER_LEN + 08, PNGI.Height);
  PNGtoBMP_ArrBWordInv(pBMPData^, BMPHEADER_LEN + 12, 1);       // Plane
  PNGtoBMP_ArrBWordInv(pBMPData^, BMPHEADER_LEN + 14, NewBitsPerPixel);
  PNGtoBMP_ArrBLongInv(pBMPData^, BMPHEADER_LEN + 24, BMPRESOLUTION_DEFAULT);
  PNGtoBMP_ArrBLongInv(pBMPData^, BMPHEADER_LEN + 28, BMPRESOLUTION_DEFAULT);
  // Palette (if present)
  if NewNbrPalEntries>0 then
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
    begin
      if PNGI.ColourType=0 then       // Greyscale
        PNGtoBMP_PaletteGrey(@PNGI.Palette, PNGI.BitDepth);
      if not TransformPal then
        Move(PNGI.Palette, pBMPData^[BMPHEADER_LEN + BMPDIBHEADER_LEN], NewNbrPalEntries * 4);
    end;
{$else LLCL_OPT_PNGSIMPLIFIED}
    Move(PNGI.Palette, pBMPData^[BMPHEADER_LEN + BMPDIBHEADER_LEN], NewNbrPalEntries * 4);
{$endif LLCL_OPT_PNGSIMPLIFIED}
  // Bitmap data
  pIn := @pData^[pred(PNGI.Height) * PNGI.RowSize];
  pOut := @pBMPData^[BaseSize];
  for i := 0 to pred(PNGI.Height) do
    begin
      PNGtoBMP_ArrBLongInv(pOut^, NewRowSize-4, 0);   // Clears BMP padded byte(s)
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
      if TranspToProcess then                     // Greyscale 16 bits and truecolour with tRNS chunk
        PNGtoBMP_TrueToTrueC(pIn, pOut, PNGI)
      else
        begin
          // Before
          if PNGI.BitDepth=16 then                // 16 bits per channel (not supported by BMP)
            PNGtoBMP_16to8(pIn, PNGI.Width, PNGI.ColourType);
          // Data move
          Move(pIn^, pOut^, RowSize);             // (Not PNGI.rowsize)
          // After
          if PNGI.ColourType in [2, 6] then       // Truecolour, truecolour + alpha
            PNGtoBMP_SwapRGB(pOut, PNGI.Width, PNGI.ColourType)
          else
            if PNGI.ColourType=4 then             // Greyscale + alpha
              PNGtoBMP_GreyToTrueC(pOut, PNGI.Width)
            else
              if (PNGI.ColourType in [0, 3]) then // Greyscale (-> indexed colour) and indexed colour with 4 colours
                if TransformPal then
                  PNGtoBMP_PalToTrueC(pOut, PNGI)
                else
                  if PNGI.BitDepth=2 then
                    PNGtoBMP_Pal2To4(pOut, PNGI.RowSize);
      end;
{$else LCL_OPT_PNGSIMPLIFIED}
      // Data move
      Move(pIn^, pOut^, RowSize);                 // (Not PNGI.rowsize)
      // After
      if PNGI.ColourType in [2, 6] then           // Truecolour, truecolour + alpha
        PNGtoBMP_SwapRGB(pOut, PNGI.Width, PNGI.ColourType);
{$endif LLCL_OPT_PNGSIMPLIFIED}
      dec(pByte(pIn), PNGI.RowSize);
      inc(pByte(pOut), NewRowSize);
    end;
end;
// Long to Bytes inversed
procedure PNGtoBMP_ArrBLongInv(var Buffer: array of byte; Offset: cardinal; Value: cardinal);
begin
  PLongword(@Buffer[Offset])^ := Value;
end;
// Word to Bytes inversed
procedure PNGtoBMP_ArrBWordInv(var Buffer: array of byte; Offset: cardinal; Value: word);
begin
  PWord(@Buffer[Offset])^ := Value;
end;
// Colour Swap RGB <-> BGR
procedure PNGtoBMP_SwapRGB(pData: PByteArray; NbrCols: cardinal; ColourType: byte);
var pTmpData: PByteArray;
var i, bpc: cardinal;
var b: byte;
begin
  pTmpData := pData;
  if ColourType=2 then bpc := 3 else bpc := 4;    // Truecolour or truecolour+alpha
  for i := 0 to pred(NbrCols) do
    begin
      b := pTmpData^[0];
      pTmpData^[0] := pTmpData^[2];
      pTmpData^[2] := b;
      inc(pByte(pTmpData), bpc);
    end;
end;
{$ifndef LLCL_OPT_PNGSIMPLIFIED}
// Creates palette for greyscale
procedure PNGtoBMP_PaletteGrey(pPalette: PByteArray; BitDepth: byte);
var bd: cardinal;
var i: cardinal;
var b1, b2: byte;
begin
  // Notes: eventual transparency (tRNS chunk) processed in PNGtoBMP_PalToTrueC
  //        greyscale with BitDepth=16 and tRNS chunk processed in PNGtoBMP_TrueToTrueC
  if BitDepth>8 then
    bd := 256               // 16 bits -> 8 bits per channel
  else
    bd := 1 shl BitDepth;
  case BitDepth of
  1:      b1 := $FF;
  2:      b1 := $55;
  4:      b1 := $11;
  else    b1 := $01;
  end;
  b2 := $00;
  for i:=0 to pred(bd) do
    begin
      PNGtoBMP_ArrBLongInv(pPalette^, i * 4, (b2 shl 16) + (b2 shl 8) + b2);
      inc(b2, b1);
    end;
end;
// Reduces 16 bits to 8 bits (channels, alpha)
procedure PNGtoBMP_16to8(pData: PByteArray; NbrCols: cardinal; ColourType: byte);
var pIn, pOut: PByteArray;
var i, NbrTimes: cardinal;
begin
  // Note: for greyscale and truecolour, if tRNS chunk present, processed in PNGtoBMP_TrueToTrueC
  pIn := pData;
  pOut := pData;
  case ColourType of
  2:      NbrTimes := 3;    // Truecolour
  4:      NbrTimes := 2;    // Greyscale + alpha
  6:      NbrTimes := 4;    // Truecolour + alpha
  else    NbrTimes := 1;    // Greyscale
  end;
  NbrTimes := NbrTimes * NbrCols;
  for i := 0 to pred(NbrTimes) do
    begin
      pOut^[0] := pIn^[0];   // Only MSB
      inc(pByte(pIn), 2);
      inc(pByte(pOut));
    end;
end;
// Truecolour (with tRNS chunk) to truecolour + alpha (8 bits)
procedure PNGtoBMP_TrueToTrueC(pDataIn: PByteArray; pDataOut: PByteArray; const PNGI: TPNGInfos);
var pIn, pOut: PByteArray;
var PixelColour: cardinal;
var i: cardinal;
var w1, w2, w3: cardinal;
begin
  // Note: includes also greyscale with BitDepth=16 and tRNS chunk
  pIn := @pDataIn^[pred(PNGI.Width) * PNGI.BytesPerPixel];
  pOut := @pDataOut^[pred(PNGI.Width) * 4];
  for i := 0 to pred(PNGI.Width) do
    begin
      if  PNGI.ColourType=0 then    // Greyscale (only with BitDepth=16 and tRNS chunk)
        begin
          w1 := PNGtoBMP_WordArrB(pIn^, 0);
          w2 := w1; w3 := w1;
          dec(pByte(pIn), 2);
        end
      else                          // Truecolour (BitDepth=8 or 16)
        if PNGI.BitDepth=8 then
          begin
            w1 := pIn^[2];
            w2 := pIn^[1];
            w3 := pIn^[0];
            dec(pByte(pIn), 3);
          end
        else
          begin
            w1 := PNGtoBMP_WordArrB(pIn^, 4);
            w2 := PNGtoBMP_WordArrB(pIn^, 2);
            w3 := PNGtoBMP_WordArrB(pIn^, 0);
            dec(pByte(pIn), 6);
          end;
      if PNGI.BitDepth=16 then
        PixelColour := ((w3 shr 8) shl 16) + ((w2 shr 8) shl 8) + (w1 shr 8)
      else
        PixelColour := (w3 shl 16) + (w2 shl 8) + w1;
      if PNGI.TranspType=1 then
        if (w1<>PNGI.Transp[0]) or (w2<>PNGI.Transp[1]) or (w3<>PNGI.Transp[2])  then
          PixelColour := PixelColour or $FF000000;
      PNGtoBMP_ArrBLongInv(pOut^, 0, PixelColour);
      dec(pByte(pOut), 4);
    end;
end;
// Greyscale + alpha to truecolour + alpha (8 bits)
procedure PNGtoBMP_GreyToTrueC(pData: PByteArray; NbrCols: cardinal);
var pIn, pOut: PByteArray;
var i: cardinal;
var b: byte;
begin
  pIn := @pData^[pred(NbrCols) * 2];
  pOut := @pData^[pred(NbrCols) * 4];
  for i := 0 to pred(NbrCols) do
    begin
      b := pIn^[0];
      PNGtoBMP_ArrBLongInv(pOut^, 0, (pIn^[1] shl 24) + (b shl 16) + (b shl 8) + b);
      dec(pByte(pIn), 2);
      dec(pByte(pOut), 4);
    end;
end;
// Palette (with tRNS chunk) to truecolour + alpha (8 bits)
procedure PNGtoBMP_PalToTrueC(pData: PByteArray; const PNGI: TPNGInfos);
var pIn, pOut: PByteArray;
var PixelBits, NbrPixels, Mask, PixelIndex: byte;
var PixelColour, ColourTransp: cardinal;
var i, j: cardinal;
begin
  // Note: greyscale (-> palette) with BitDepth=16 and tRNS chunk processed in PNGtoBMP_TrueToTrueC
  pIn := @pData^[pred(PNGI.RowSize)];
  pOut := @pData^[pred(PNGI.Width) * 4];
  if PNGI.BitDepth<8 then
    begin
      Mask := Pred(1 shl PNGI.BitDepth);
      PixelBits := pIn^[0];
      NbrPixels := 8 div PNGI.BitDepth;
      // Skip padding bits, if present
      j := PNGtoBMP_ComplPow2(PNGI.Width * PNGI.BitsPerPixel, 8);
      if j>0 then
        for i:=0 to pred(j div PNGI.BitDepth) do
          begin
            PixelBits := PixelBits shr PNGI.BitDepth;
            dec(NbrPixels);
          end;
    end
  else
    begin
      Mask := 0; PixelBits := 0; NbrPixels := 0;  // (to avoid compilation warning)
    end;
  if PNGI.ColourType=0 then   // Greyscale
    ColourTransp := (PNGI.Transp[0] and $FF)
  else                        // Palette
    ColourTransp := ((PNGI.Transp[0] and $FF) shl 16) + ((PNGI.Transp[1] and $FF) shl 8) + (PNGI.Transp[2] and $FF);
  for i := 0 to pred(PNGI.Width) do
    begin
      if PNGI.BitDepth<8 then
        begin
          PixelIndex := PixelBits and Mask;
          PixelBits := PixelBits shr PNGI.BitDepth;
          dec(NbrPixels);
        end
      else
        PixelIndex := pIn^[0];
      PixelColour := PNGtoBMP_LongArrBInv(PNGI.Palette, PixelIndex * 4);
      if PNGI.TranspType=1 then
        if ((PNGI.ColourType=0) and (PixelIndex<>ColourTransp)) or ((PNGI.ColourType=3) and (PixelColour<>ColourTransp)) then
          PixelColour := PixelColour or $FF000000;
      PNGtoBMP_ArrBLongInv(pOut^, 0, PixelColour);
      if (PNGI.BitDepth=8) or (NbrPixels=0) then
        begin
          dec(pByte(pIn), 1);
          if PNGI.BitDepth<8 then
            begin
              PixelBits := pIn^[0];
              NbrPixels := 8 div PNGI.BitDepth;
            end;
        end;
      dec(pByte(pOut), 4);
    end;
end;
// Bytes to Long inversed
function  PNGtoBMP_LongArrBInv(Const Buffer: array of Byte; Const Offset: cardinal): cardinal;
begin
  result := PLongword(@Buffer[Offset])^;
end;
// Palette 2 bits per colour to 4 bits
procedure PNGtoBMP_Pal2To4(pData: PByteArray; RowSize: cardinal);
var pIn, pOut: PByteArray;
var i: cardinal;
var b: byte;
begin
  pIn := @pData^[pred(RowSize)];
  pOut := @pData^[pred(RowSize) * 2];
  for i := 0 to pred(RowSize) do
    begin
      b := pIn^[0];
      PNGtoBMP_ArrBWordInv(pOut^, 0, ((b and $0C) shl 10) + ((b and $03) shl 8) + ((b and $C0) shr 2) + ((b and $30) shr 4)); // (Probably another faster way)
      dec(pByte(pIn));
      dec(pByte(pOut), 2);
    end;
end;
{$endif LLCL_OPT_PNGSIMPLIFIED}

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.

