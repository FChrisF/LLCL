unit FileUtil;

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
    * UTF8 file functions (equivalent of SysUtils ones - mapped to LazFileutils)
    * Some other ones (SysToUTF8, UTF8ToSys)

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
function  FileSize(const Filename: string): int64;
function  GetCurrentDirUTF8(): string;
function  SetCurrentDirUTF8(const NewDir: string): boolean;
function  DirectoryExistsUTF8(const Directory: string): boolean;
function  ForceDirectoriesUTF8(const Dir: string): boolean;
function  CreateDirUTF8(const Dir: string): boolean;
function  RemoveDirUTF8(const Dir: string): boolean;
function  DeleteFileUTF8(const FileName: string): boolean;
function  RenameFileUTF8(const OldName, NewName: string): boolean;
// (No GetFileVersionUTF8 function)

function  SysErrorMessageUTF8(ErrorCode: integer): string;

{$IFDEF UNICODE}
function  UTF8ToSys(const S: utf8string): ansistring;
function  SysToUTF8(const S: ansistring): utf8string;
{$ELSE UNICODE}
function  UTF8ToSys(const S: string): string;
function  SysToUTF8(const S: string): string;
{$ENDIF UNICODE}

//------------------------------------------------------------------------------

implementation

uses
  LazFileUtils, LazUTF8;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

function  FileCreateUTF8(const FileName: string) : THandle;
begin
  result := LazFileUtils.FileCreateUTF8(FileName);
end;

function  FileOpenUTF8(const FileName: string; Mode: cardinal) : THandle;
begin
  result := LazFileUtils.FileOpenUTF8(FileName, Mode);
end;

function  FileExistsUTF8(const Filename: string): boolean;
begin
  result := LazFileUtils.FileExistsUTF8(Filename);
end;

function  FileSetDateUTF8(const FileName: string; Age: integer): integer;
begin
  result := LazFileUtils.FileSetDateUTF8(Filename, Age);
end;

function  FileAgeUTF8(const FileName: string): integer;
begin
  result := LazFileUtils.FileAgeUTF8(Filename);
end;

function  FindFirstUTF8(const Path: string; Attr: longint; out Rslt: TSearchRec): longint;
begin
  result := LazFileUtils.FindFirstUTF8(Path, Attr, Rslt);
end;

function  FindNextUTF8(var Rslt: TSearchRec): longint;
begin
  result := LazFileUtils.FindNextUTF8(Rslt);
end;

procedure FindCloseUTF8(var F: TSearchrec);
begin
  LazFileUtils.FindCloseUTF8(F);
end;

// (FileSize for Fileutil and FileSizeUTF8 for LazFileUtils)
function  FileSize(const Filename: string): int64;
begin
  result := LazFileUtils.FileSizeUTF8(Filename);
end;

function  GetCurrentDirUTF8(): string;
begin
  result := LazFileUtils.GetCurrentDirUTF8();
end;

function  SetCurrentDirUTF8(const NewDir: string): boolean;
begin
  result := LazFileUtils.SetCurrentDirUTF8(NewDir);
end;

function  DirectoryExistsUTF8(const Directory: string): boolean;
begin
  result := LazFileUtils.DirectoryExistsUTF8(Directory);
end;

function  ForceDirectoriesUTF8(const Dir: string): boolean;
begin
  result := LazFileUtils.ForceDirectoriesUTF8(Dir);
end;

function  CreateDirUTF8(const Dir: string): boolean;
begin
  result := LazFileUtils.CreateDirUTF8(Dir);
end;

function  RemoveDirUTF8(const Dir: string): boolean;
begin
  result := LazFileUtils.RemoveDirUTF8(Dir);
end;

function  DeleteFileUTF8(const FileName: string): boolean;
begin
  result := LazFileUtils.DeleteFileUTF8(FileName);
end;

function  RenameFileUTF8(const OldName, NewName: string): boolean;
begin
  result := LazFileUtils.RenameFileUTF8(OldName, NewName);
end;

//------------------------------------------------------------------------------

// (Functions belonging to LazUTF8)

function  SysErrorMessageUTF8(ErrorCode: integer): string;
begin
  result := LazUTF8.SysErrorMessageUTF8(ErrorCode);
end;

{$IFDEF UNICODE}
function  UTF8ToSys(const S: utf8string): ansistring;
{$ELSE UNICODE}
function UTF8ToSys(const S: string): string;
{$ENDIF UNICODE}
begin
  result := LazUTF8.UTF8ToSys(S);
end;

{$IFDEF UNICODE}
function  SysToUTF8(const S: ansistring): utf8string;
{$ELSE UNICODE}
function SysToUTF8(const S: string): string;
{$ENDIF UNICODE}
begin
  result := LazUTF8.SysToUTF8(S);
end;

//------------------------------------------------------------------------------

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
