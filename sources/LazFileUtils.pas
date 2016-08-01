unit LazFileUtils;

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
    * DeleteFileUTF8 and RenameFileUTF8 added
   Version 1.01:
   Version 1.00:
    * File creation.
    * UTF8 file functions (equivalent of SysUtils ones)

   Notes:
    - specific to FPC/Lazarus (not used with Delphi).
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

function  FileCreateUTF8(const FileName: string) : THandle;
function  FileOpenUTF8(const FileName: string; Mode: cardinal) : THandle;
function  FileExistsUTF8(const Filename: string): boolean;
function  FileSetDateUTF8(const FileName: string; Age: integer): integer;
function  FileAgeUTF8(const FileName: string): integer;
function  FindFirstUTF8(const Path: string; Attr: longint; out Rslt: TSearchRec): longint;
function  FindNextUTF8(var Rslt: TSearchRec): longint;
procedure FindCloseUTF8(var F: TSearchrec);
function  FileSizeUTF8(const Filename: string): int64;
function  GetCurrentDirUTF8(): string;
function  SetCurrentDirUTF8(const NewDir: string): boolean;
function  DirectoryExistsUTF8(const Directory: string): boolean;
function  ForceDirectoriesUTF8(const Dir: string): boolean;
function  CreateDirUTF8(const Dir: string): boolean;
function  RemoveDirUTF8(const Dir: string): boolean;
function  DeleteFileUTF8(const FileName: string): boolean;
function  RenameFileUTF8(const OldName, NewName: string): boolean;
// (No GetFileVersionUTF8 function)

//------------------------------------------------------------------------------

implementation

uses
  LLCLOSInt, Windows;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

function  LFUFindMatchingFile(var F: TSearchRec): integer; forward;
function  LFUInternalFileOpen(const FileName: string; Mode: cardinal; var LastOSError: cardinal) : THandle; forward;
function  LFUInternalFileAge(const FileName: string; var LastWriteTime: TFileTime): boolean; forward;
function  LFUSysFileAttributes(const FileName: string; var LastWriteTime: TFileTime): boolean; forward;

//------------------------------------------------------------------------------

function  FileCreateUTF8(const FileName: string) : THandle;
var LastOSError: cardinal;
begin
  result := LLCL_CreateFile(@FileName[1], GENERIC_READ or GENERIC_WRITE,
    0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0, LastOSError);
end;

function  LFUInternalFileOpen(const FileName: string; Mode: cardinal; var LastOSError: cardinal) : THandle;
const
  AccessMode: array[0..2] of cardinal = (GENERIC_READ, GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of cardinal = (0, 0, FILE_SHARE_READ, FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  result := LLCL_CreateFile(@FileName[1], AccessMode[Mode and 3],
    ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL, 0, LastOSError);
end;

function  FileOpenUTF8(const FileName: string; Mode: cardinal) : THandle;
var LastOSError: cardinal;
begin
  result := LFUInternalFileOpen(FileName, Mode, LastOSError);
end;

function  FileExistsUTF8(const Filename: string): boolean;
var Dummy: TFileTime;
begin
  result := LFUSysFileAttributes(FileName, Dummy);
end;

function  FileSetDateUTF8(const FileName: string; Age: integer): integer;
var Handle: THandle;
var LastOSError: cardinal;
begin
  Handle := LFUInternalFileOpen(FileName, fmOpenWrite, LastOSError);
  if Handle = THandle(-1) then
    result := LastOSError
  else
    begin
      result := FileSetDate(Handle, Age);
      FileClose(Handle);
    end;
end;

function  FileAgeUTF8(const FileName: string): integer;
var TmpFileTime, LocalFileTime: TFileTime;
begin
  if LFUInternalFileAge(FileName, TmpFileTime) then
    begin
      LLCL_FileTimeToLocalFileTime(TmpFileTime, LocalFileTime);
      if LLCL_FileTimeToDosDateTime(LocalFileTime, LongRec(result).Hi, LongRec(result).Lo) then
        exit;
    end;
  result := -1;
end;

function  FindFirstUTF8(const Path: string; Attr: longint; out Rslt: TSearchRec): longint;
const faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
var FileName: string;
var LastOSError: cardinal;
begin
  Rslt.ExcludeAttr := not Attr and faSpecial;
  Rslt.FindHandle := LLCLS_FindFirstNextFile(Path, 0, Rslt.FindData, FileName, LastOSError);
  if Rslt.FindHandle<>INVALID_HANDLE_VALUE then
    begin
      Rslt.Name := {$if Defined(UNICODE) and (not Defined(FPC_UNICODE_RTL))}utf8string(FileName){$else}FileName{$ifend};
      result := LFUFindMatchingFile(Rslt);
      if result<>0 then FindCloseUTF8(Rslt);
    end
  else
    result := LastOSError;
end;

function  FindNextUTF8(var Rslt: TSearchRec): longint;
var FileName: string;
var LastOSError: cardinal;
begin
  if LLCLS_FindFirstNextFile('', Rslt.FindHandle, Rslt.FindData, FileName, LastOSError)<>0 then
    begin
      Rslt.Name := {$if Defined(UNICODE) and (not Defined(FPC_UNICODE_RTL))}utf8string(FileName){$else}FileName{$ifend};
      result := LFUFindMatchingFile(Rslt);
    end
  else
    result := LastOSError;
end;

procedure FindCloseUTF8(var F: TSearchrec);
begin
  if F.FindHandle<>INVALID_HANDLE_VALUE then
    begin
      LLCL_FindClose(F.FindHandle);
      F.FindHandle := INVALID_HANDLE_VALUE;
    end;
end;

// (FileSize for Fileutil and FileSizeUTF8 for LazFileUtils)
function  FileSizeUTF8(const Filename: string): int64;
var FileAttribute: TWin32FileAttributeData;
var LastOSError: cardinal;
begin
  if LLCL_GetFileAttributesEx(@FileName[1], GetFileExInfoStandard, @FileAttribute, LastOSError) then
    result := int64(int64(FileAttribute.nFileSizeHigh) shl 32) + int64(FileAttribute.nFileSizeLow)
  else
    result := -1;
end;

function  GetCurrentDirUTF8(): string;
begin
  result := LLCLS_GetCurrentDirectory();
end;

function  SetCurrentDirUTF8(const NewDir: string): boolean;
begin
  result := LLCL_SetCurrentDirectory(@NewDir[1]);
end;

function  DirectoryExistsUTF8(const Directory: string): boolean;
var code: integer;
begin
  code := LLCL_GetFileAttributes(@Directory[1]);
  result := (code<>INVALID_FILE_ATTRIBUTES) and ((FILE_ATTRIBUTE_DIRECTORY and code)<>0);
end;

function  ForceDirectoriesUTF8(const Dir: string): boolean;
var E: EInOutError;
var TmpDir: string;
begin
  result := true;
  TmpDir := ExcludeTrailingPathDelimiter(Dir);
  if TmpDir = '' then begin
    E := EInOutError.Create(LLCL_STR_SYSU_CANTCREATEDIR);
    E.ErrorCode := 3;
    raise E;
  end;
  if DirectoryExistsUTF8(TmpDir) then exit;
  if (Length(TmpDir) < 3) or (ExtractFilePath(TmpDir) = TmpDir) then
    result := CreateDirUTF8(TmpDir)
  else
    result := ForceDirectories(ExtractFilePath(TmpDir)) and CreateDirUTF8(TmpDir);
end;

function  CreateDirUTF8(const Dir: string): boolean;
begin
  result := LLCL_CreateDirectory(@Dir[1], nil);
end;

function  RemoveDirUTF8(const Dir: string): boolean;
begin
  result := LLCL_RemoveDirectory(@Dir[1]);
end;

function  DeleteFileUTF8(const FileName: string): boolean;
begin
  result := LLCL_DeleteFile(@FileName[1]);
end;

function  RenameFileUTF8(const OldName, NewName: string): boolean;
begin
  result := LLCL_MoveFile(@OldName[1], @NewName[1]);
end;

//------------------------------------------------------------------------------

function  LFUFindMatchingFile(var F: TSearchRec): integer;
var LocalFileTime: TFileTime;
var FileName: string;
var LastOSError: cardinal;
begin
  with F do begin
    while (FindData.dwFileAttributes and ExcludeAttr)<>0 do
      begin
        if LLCLS_FindFirstNextFile('', FindHandle, FindData, FileName, LastOSError)=0 then
          begin
            result := LastOSError;
            exit;
          end;
        Name := {$if Defined(UNICODE) and (not Defined(FPC_UNICODE_RTL))}utf8string(FileName){$else}FileName{$ifend};
      end;
    LLCL_FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    LLCL_FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi, LongRec(Time).Lo);
    Size := int64(int64(FindData.nFileSizeHigh) shl 32) + int64(FindData.nFileSizeLow);
    Attr := FindData.dwFileAttributes;
//    Name := FindData.cFileName;   // (Already done)
  end;
  result := 0;
end;

function  LFUInternalFileAge(const FileName: string; var LastWriteTime: TFileTime): boolean;
begin
  result := LFUSysFileAttributes(FileName, LastWriteTime);
end;

function  LFUSysFileAttributes(const FileName: string; var LastWriteTime: TFileTime): boolean;
var FileAttribute: TWin32FileAttributeData;
var Handle: THandle;
var FindData: TCustomWin32FindData;
var OutFileName: string;
var LastOSError: cardinal;
begin
  result := LLCL_GetFileAttributesEx(@FileName[1], GetFileExInfoStandard, @FileAttribute, LastOSError);
  if result then
    begin
      LastWriteTime := FileAttribute.ftLastWriteTime;
      result := ((FileAttribute.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0);
    end
  else
    if (LastOSError=ERROR_SHARING_VIOLATION) or (LastOSError=ERROR_LOCK_VIOLATION) or (LastOSError=ERROR_SHARING_BUFFER_EXCEEDED) then
      begin
        Handle := LLCLS_FindFirstNextFile(FileName, 0, FindData, OutFileName, LastOSError);
        if Handle<>INVALID_HANDLE_VALUE then
          begin
            LLCL_FindClose(Handle);
            LastWriteTime := FindData.ftLastWriteTime;
            result := ((FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0);
          end;
      end;
end;

//------------------------------------------------------------------------------

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
