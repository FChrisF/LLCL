unit LLCLZlib;

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
    * Zlib interface for the Light LCL implemented
}

{$IFDEF FPC}
  {$define LLCL_FPC_MODESECTION}
  {$I LLCLFPCInc.inc}             // For mode
  {$undef LLCL_FPC_MODESECTION}
{$ENDIF}
{$ifdef FPC_OBJFPC} {$define LLCL_OBJFPC_MODE} {$endif} // Object pascal mode

{$I LLCLOptions.inc}      // Options

// Zlib option checks
{$if Defined(LLCL_OPT_USEZLIBDLL) and Defined(LLCL_OPT_USEZLIBOBJ)}
  {$error Can't have several Zlib options at the same time}
{$ifend}
{$if Defined(LLCL_OPT_USEZLIBDLLDYN) and (not Defined(LLCL_OPT_USEZLIBDLL))}
  {$error Can't have the dynamic DLL Zlib option without LLCL_OPT_USEZLIBDLL}
{$ifend}

//------------------------------------------------------------------------------

interface

// The destination buffer must be large enough to hold the entire compressed/uncompressed data

function  LLCL_compress(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal): integer;
function  LLCL_compress2(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal; level: integer): integer;
function  LLCL_uncompress(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal): integer;

//------------------------------------------------------------------------------

implementation

{$if Defined(LLCL_OPT_USEZLIBDLLDYN)}
  uses
    LLCLOSInt,
    Windows;
{$ifend LLCL_OPT_USEZLIBDLLDYN}

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

{$if Defined(LLCL_OPT_USEZLIBDLL) or Defined(LLCL_OPT_USEZLIBOBJ)}
type
  PBytef = PByte;
{$IFDEF FPC}
  TAlloc_func = function (opaque: pointer; items, size: cardinal): pointer; cdecl;
  TFree_func = procedure (opaque, ptr: pointer); cdecl;
{$ELSE FPC}
{$if Defined(LLCL_OPT_USEZLIBOBJ)}
  TAlloc_func = function (opaque: pointer; items, size: cardinal): pointer;
  TFree_func = procedure (opaque, ptr: pointer);
{$else LLCL_OPT_USEZLIBOBJ}
  TAlloc_func = function (opaque: pointer; items, size: cardinal): pointer; cdecl;
  TFree_func = procedure (opaque, ptr: pointer); cdecl;
{$ifend LLCL_OPT_USEZLIBOBJ}
{$ENDIF FPC}
  TZStreamRec = packed record
    next_in: PBytef;          // next input byte
    avail_in: cardinal;       // number of bytes available at next_in
    total_in: cardinal;       // total number of input bytes read so far

    next_out: PBytef;         // next output byte should be put there
    avail_out: cardinal;      // remaining free space at next_out
    total_out: cardinal;      // total number of bytes output so far

    msg: PChar;               // last error message, NULL if no error
    internal_state: pointer;  // not visible by applications

    zalloc: TAlloc_func;      // used to allocate the internal state
    zfree: TFree_func;        // used to free the internal state
    opaque: pointer;          // private data object passed to zalloc and zfree

    data_type: integer;       // best guess about the data type: binary or text
    adler: cardinal;          // adler32 value of the uncompressed data
    reserved: cardinal;       // reserved for future use
  end;

{$if Defined(LLCL_OPT_USEZLIBOBJ)}                    // Obj
  const
    zlib_version: ansistring = '1.2.8';
    Z_FINISH      = 4;
    Z_OK          = 0;
    Z_STREAM_END  = 1;
    Z_NEED_DICT   = 2;
    Z_DATA_ERROR  = -3;
    Z_BUF_ERROR   = -5;
    Z_DEFAULT_COMPRESSION = -1;
  {$IFNDEF FPC}
    z_errmsg: array [0..pred(10)] of string = (
      'need dictionary',      // Z_NEED_DICT       2
      'stream end',           // Z_STREAM_END      1
      '',                     // Z_OK              0
      'file error',           // Z_ERRNO         (-1)
      'stream error',         // Z_STREAM_ERROR  (-2)
      'data error',           // Z_DATA_ERROR    (-3)
      'insufficient memory',  // Z_MEM_ERROR     (-4)
      'buffer error',         // Z_BUF_ERROR     (-5)
      'incompatible version', // Z_VERSION_ERROR (-6)
      ''  );
  {$ENDIF NFPC}
  {$IFDEF FPC}
    {$if Defined(CPU64) or Defined(CPU64BITS)}
      {$L ZlibObj\win64\adler32.o}
      {$L ZlibObj\win64\crc32.o}
      {$L ZlibObj\win64\deflate.o}
      {$L ZlibObj\win64\infback.o}
      {$L ZlibObj\win64\inffast.o}
      {$L ZlibObj\win64\inflate.o}
      {$L ZlibObj\win64\inftrees.o}
      {$L ZlibObj\win64\match.o}
      {$L ZlibObj\win64\trees.o}
      {$L ZlibObj\win64\zutil.o}
    {$else}
      {$L ZlibObj\win32\adler32.o}
      {$L ZlibObj\win32\crc32.o}
      {$L ZlibObj\win32\deflate.o}
      {$L ZlibObj\win32\infback.o}
      {$L ZlibObj\win32\inffast.o}
      {$L ZlibObj\win32\inflate.o}
      {$L ZlibObj\win32\inftrees.o}
      {$L ZlibObj\win32\match.o}
      {$L ZlibObj\win32\trees.o}
      {$L ZlibObj\win32\zutil.o}
    {$ifend}
    function  deflateInit_(var strm: TZStreamRec; level: integer; version: PAnsiChar; stream_size: integer): integer; cdecl; external;
    function  deflate(var strm: TZStreamRec; flush: integer): integer; cdecl; external;
    function  deflateEnd(var strm: TZStreamRec): integer; cdecl; external;
    function  inflateInit_(var strm: TZStreamRec; version: PAnsiChar; stream_size: integer): integer; cdecl; external;
    function  inflate(var strm: TZStreamRec; flush: integer): integer; cdecl; external;
    function  inflateEnd(var strm: TZStreamRec): integer; cdecl; external;
    //
    function  zcalloc(opaque: pointer; items, size: cardinal): pointer; cdecl; forward;
    procedure zcfree(opaque, ptr: pointer); cdecl; forward;
    function  _malloc(size: cardinal): pointer; cdecl; [public, alias: '_malloc']; forward;
    procedure _free(ptr: pointer); cdecl; [public, alias: '_free']; forward;
  {$ELSE FPC}
    {$if Defined(CPU64) or Defined(CPU64BITS)}
      {$L ZlibObj\win64\deflate.obj}
      {$L ZlibObj\win64\inflate.obj}
      {$L ZlibObj\win64\inftrees.obj}
      {$L ZlibObj\win64\infback.obj}
      {$L ZlibObj\win64\inffast.obj}
      {$L ZlibObj\win64\trees.obj}
      {$L ZlibObj\win64\compress.obj}
      {$L ZlibObj\win64\adler32.obj}
      {$L ZlibObj\win64\crc32.obj}
    {$else}
      {$L ZlibObj\win32\deflate.obj}
      {$L ZlibObj\win32\inflate.obj}
      {$L ZlibObj\win32\inftrees.obj}
      {$L ZlibObj\win32\infback.obj}
      {$L ZlibObj\win32\inffast.obj}
      {$L ZlibObj\win32\trees.obj}
      {$L ZlibObj\win32\compress.obj}
      {$L ZlibObj\win32\adler32.obj}
      {$L ZlibObj\win32\crc32.obj}
    {$ifend}
    function  deflateInit_(var strm: TZStreamRec; level: integer; version: PAnsiChar; stream_size: integer): integer; external;
    function  deflate(var strm: TZStreamRec; flush: integer): integer; external;
    function  deflateEnd(var strm: TZStreamRec): integer; external;
    function  inflateInit_(var strm: TZStreamRec; version: PAnsiChar; stream_size: integer): integer; external;
    function  inflate(var strm: TZStreamRec; flush: integer): integer; external;
    function  inflateEnd(var strm: TZStreamRec): integer; external;
    //
    function  zcalloc(opaque: pointer; items, size: cardinal): pointer; forward;
    procedure zcfree(opaque, ptr: pointer); forward;
    function  memset(ptr: pointer; value: byte; num: integer): pointer; cdecl; forward;
    procedure memcpy(destination, source: pointer; num: integer); cdecl; forward;
    {$if (not Defined(CPU64)) and (not Defined(CPU64BITS))}
      procedure _llmod; forward;
    {$ifend}
  {$ENDIF FPC}
{$else LLCL_OPT_USEZLIBOBJ}                           // DLL
  const
    zlib_dll      = 'zlib1.dll';
  {$if Defined(LLCL_OPT_USEZLIBDLLDYN)}               // Dynamic DLL
    Z_ERRNO       = -1;
  var
    ZlibDllHandle: HMODULE = 0;
    inflateInit_: function(var strm: TZStreamRec; version: PAnsiChar; stream_size: integer): integer; cdecl;
    inflate:      function(var strm: TZStreamRec; flush: integer): integer; cdecl;
    inflateEnd:   function(var strm: TZStreamRec): integer; cdecl;
    compress:     function(dest: PBytef; var destLen: cardinal; source: PBytef; sourceLen: cardinal): integer; cdecl;
    compress2:    function(dest: PBytef; var destLen: cardinal; source: PBytef; sourceLen: cardinal; level: integer): integer; cdecl;
    uncompress:   function(dest: PBytef; var destLen: cardinal; source: PBytef; sourceLen: cardinal): integer; cdecl;
    function  LLCL_LoadZlib(): boolean; forward;
  {$else LLCL_OPT_USEZLIBDLLDYN}                      // Static DLL
    function  inflateInit_(var strm: TZStreamRec; version: PAnsiChar; stream_size: integer): integer; cdecl; external zlib_dll;
    function  inflate(var strm: TZStreamRec; flush: integer): integer; cdecl; external zlib_dll;
    function  inflateEnd(var strm: TZStreamRec): integer; cdecl; external zlib_dll;
    function  compress(dest: PBytef; var destLen: cardinal; source: PBytef; sourceLen: cardinal): integer; cdecl external zlib_dll;
    function  compress2(dest: PBytef; var destLen: cardinal; source: PBytef; sourceLen: cardinal; level: integer): integer; cdecl external zlib_dll;
    function  uncompress(dest: PBytef; var destLen: cardinal; source: PBytef; sourceLen: cardinal): integer; cdecl external zlib_dll;
  {$ifend LLCL_OPT_USEZLIBDLLDYN}
{$ifend LLCL_OPT_USEZLIBOBJ}
{$else LLCL_OPT_USEZLIBDLL or LLCL_OPT_USEZLIBOBJ}    // PazZlib
uses
  {$IFDEF FPC}PasZlib{$ELSE}SysUtils, gZlib, ZUtil, zCompres, zUnCompr{$ENDIF};
{$ifend LLCL_OPT_USEZLIBDLL or LLCL_OPT_USEZLIBOBJ}

//------------------------------------------------------------------------------

{$if Defined(LLCL_OPT_USEZLIBDLL) or Defined(LLCL_OPT_USEZLIBOBJ)}

// Obj

{$if Defined(LLCL_OPT_USEZLIBOBJ)}
{$IFDEF FPC}
function  zcalloc(opaque: pointer; items, size: cardinal): pointer; cdecl;
begin
  GetMem(result, items * size);
end;
procedure zcfree(opaque, ptr: pointer); cdecl;
begin
  FreeMem(ptr);
end;
// _malloc and _free not used, if zcalloc and zcfree are used
function  _malloc(size: cardinal): pointer; cdecl;
begin
  GetMem(result, size);
end;
procedure _free(ptr: pointer); cdecl;
begin
  FreeMem(ptr);
end;
{$ELSE FPC}
function  zcalloc(opaque: pointer; items, size: cardinal): pointer;
begin
  GetMem(result, items * size);
end;
procedure zcfree(opaque, ptr: pointer);
begin
  FreeMem(ptr);
end;
function  memset(ptr: pointer; value: byte; num: integer): pointer; cdecl;
begin
  FillChar(ptr^, num, value);
  result := ptr;
end;
procedure memcpy(destination, source: pointer; num: integer); cdecl;
begin
  Move(source^, destination^, num);
end;
{$if (not Defined(CPU64)) and (not Defined(CPU64BITS))}
procedure _llmod;
asm
  jmp System.@_llmod;
end;
{$ifend}
{$ENDIF FPC}

function  LLCL_compress(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal): integer;
begin
  result := LLCL_compress2(dest, destLen, source, sourceLen, Z_DEFAULT_COMPRESSION);
end;

function  LLCL_compress2(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal; level: integer): integer;
var ZSR: TZStreamRec;
begin
  FillChar(ZSR, SizeOf(ZSR), 0);
  ZSR.next_in := PBytef(source);
  ZSR.avail_in := sourceLen;
  ZSR.next_out := PBytef(dest);
  ZSR.avail_out := destLen;
  ZSR.zalloc := {$IFDEF LLCL_OBJFPC_MODE}@{$ENDIF}zcalloc;
  ZSR.zfree := {$IFDEF LLCL_OBJFPC_MODE}@{$ENDIF}zcfree;
  result := deflateInit_(ZSR, level, @zlib_version[1], SizeOf(ZSR));
  if result<>Z_OK then exit;
  result := deflate(ZSR, Z_FINISH);
  if result<>Z_STREAM_END then
    begin
      deflateEnd(ZSR);
      if (result=Z_OK) then
        result := Z_BUF_ERROR;
      exit;
    end;
  destLen := ZSR.total_out;
  result := deflateEnd(ZSR);
end;

function  LLCL_uncompress(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal): integer;
var ZSR: TZStreamRec;
begin
  FillChar(ZSR, SizeOf(ZSR), 0);
  ZSR.next_in := PBytef(source);
  ZSR.avail_in := sourceLen;
  ZSR.next_out := PBytef(dest);
  ZSR.avail_out := destLen;
  ZSR.zalloc := {$IFDEF LLCL_OBJFPC_MODE}@{$ENDIF}zcalloc;
  ZSR.zfree := {$IFDEF LLCL_OBJFPC_MODE}@{$ENDIF}zcfree;
  result := inflateInit_(ZSR, @zlib_version[1], SizeOf(ZSR));
  if result<>Z_OK then exit;
  result := inflate(ZSR, Z_FINISH);
  if result<>Z_STREAM_END then
    begin
      inflateEnd(ZSR);
      if (result=Z_NEED_DICT) or ((result=Z_BUF_ERROR) and (sourceLen=0)) then
        result := Z_DATA_ERROR;
      exit;
    end;
  destLen := ZSR.total_out;
  result := inflateEnd(ZSR);
end;

{$else LLCL_OPT_USEZLIBOBJ}

// DLL (static or dynamic)

function  LLCL_compress(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal): integer;
begin
{$if Defined(LLCL_OPT_USEZLIBDLLDYN)}
  if not LLCL_LoadZlib() then
    begin
      result := Z_ERRNO;
      exit;
    end;
{$ifend LLCL_OPT_USEZLIBDLLDYN}
  result := compress(PBytef(dest), destLen, PBytef(source), sourceLen);
end;

function  LLCL_compress2(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal; level: integer): integer;
begin
{$if Defined(LLCL_OPT_USEZLIBDLLDYN)}
  if not LLCL_LoadZlib() then
    begin
      result := Z_ERRNO;
      exit;
    end;
{$ifend LLCL_OPT_USEZLIBDLLDYN}
  result := compress2(PBytef(dest), destLen, PBytef(source), sourceLen, level);
end;

function  LLCL_uncompress(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal): integer;
begin
{$if Defined(LLCL_OPT_USEZLIBDLLDYN)}
  if not LLCL_LoadZlib() then
    begin
      result := Z_ERRNO;
      exit;
    end;
{$ifend LLCL_OPT_USEZLIBDLLDYN}
  result := uncompress(PBytef(dest), destLen, PBytef(source), sourceLen);
end;

{$ifend LLCL_OPT_USEZLIBOBJ}

{$else LLCL_OPT_USEZLIBDLL or LLCL_OPT_USEZLIBOBJ}

// PasZlib

function  LLCL_compress(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal): integer;
begin
{$IFDEF FPC}
  result := compress(PChar(dest), destLen, PChar(source), sourceLen);
{$ELSE FPC}
  result := compress(PBytef(dest), destLen, PByteArray(source)^, sourceLen);
{$ENDIF FPC}
end;

function  LLCL_compress2(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal; level: integer): integer;
begin
{$IFDEF FPC}
  result := compress2(PChar(dest), destLen, PChar(source), sourceLen, level);
{$ELSE FPC}
  result := compress2(PBytef(dest), destLen, PByteArray(source)^, sourceLen, level);
{$ENDIF FPC}
end;

function  LLCL_uncompress(dest: PByte; var destLen: cardinal; source: PByte; sourceLen: cardinal): integer;
begin
{$IFDEF FPC}
  result := uncompress(PChar(dest), destLen, PChar(source), sourceLen);
{$ELSE FPC}
  result := uncompress(PBytef(dest), destLen, PByteArray(source)^, sourceLen);
{$ENDIF FPC}
end;

{$ifend LLCL_OPT_USEZLIBDLL or LLCL_OPT_USEZLIBOBJ}

//------------------------------------------------------------------------------

// Dynamic DLL

{$if Defined(LLCL_OPT_USEZLIBDLLDYN)}
function  LLCL_LoadZlib(): boolean;
begin
  result := false;
  if ZlibDllHandle=0 then
    begin
      inflateInit_ := nil; inflate := nil; inflateEnd := nil;
      compress := nil; compress2 := nil; uncompress := nil;
      ZlibDllHandle := LLCL_LoadLibrary(zlib_dll);
    end;
  if ZlibDllHandle=0 then exit;
  if not Assigned(inflateInit_) then
    {$IFDEF LLCL_OBJFPC_MODE}FARPROC(inflateInit_){$ELSE}@inflateInit_{$ENDIF}
      := LLCL_GetProcAddress(ZlibDllHandle, 'inflateInit_');
  if not Assigned(inflate) then
    {$IFDEF LLCL_OBJFPC_MODE}FARPROC(inflate){$ELSE}@inflate{$ENDIF}
      := LLCL_GetProcAddress(ZlibDllHandle, 'inflate');
  if not Assigned(inflateEnd) then
    {$IFDEF LLCL_OBJFPC_MODE}FARPROC(inflateEnd){$ELSE}@inflateEnd{$ENDIF}
      := LLCL_GetProcAddress(ZlibDllHandle, 'inflateEnd');
  if not Assigned(compress) then
    {$IFDEF LLCL_OBJFPC_MODE}FARPROC(compress){$ELSE}@compress{$ENDIF}
      := LLCL_GetProcAddress(ZlibDllHandle, 'compress');
  if not Assigned(compress) then
    {$IFDEF LLCL_OBJFPC_MODE}FARPROC(compress){$ELSE}@compress{$ENDIF}
      := LLCL_GetProcAddress(ZlibDllHandle, 'compress');
  if not Assigned(compress2) then
    {$IFDEF LLCL_OBJFPC_MODE}FARPROC(compress2){$ELSE}@compress2{$ENDIF}
      := LLCL_GetProcAddress(ZlibDllHandle, 'compress2');
  if not Assigned(uncompress) then
    {$IFDEF LLCL_OBJFPC_MODE}FARPROC(uncompress){$ELSE}@uncompress{$ENDIF}
      := LLCL_GetProcAddress(ZlibDllHandle, 'uncompress');
  if (not Assigned(inflateInit_)) or (not Assigned(inflate)) or (not Assigned(inflateEnd))
    or (not Assigned(compress)) or (not Assigned(compress2)) or (not Assigned(uncompress)) then
      exit;
  result := true;
end;

initialization

finalization
  if ZlibDllHandle<>0 then
    begin
      LLCL_FreeLibrary(ZlibDllHandle);
      ZlibDllHandle := 0;
    end;
{$ifend LLCL_OPT_USEZLIBDLLDYN}

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
