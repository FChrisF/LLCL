unit LazUTF8Classes;

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
   Version 1.00:
    * File creation.
    * TFileStreamUTF8 class (simplified)

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
  Classes;

type
  TFileStreamUTF8 = class(TFileStream)
  private
    fFileNameUTF8: string;
  public
    constructor Create(const AFileName: string; Mode: Word);
    property  FileName: string read fFileNameUTF8;
  end;


//------------------------------------------------------------------------------

implementation

uses
  LazFileUtils;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

//------------------------------------------------------------------------------

constructor TFileStreamUTF8.Create(const AFileName: string; Mode: Word);
var AHandle: THandle;
begin
  fFileNameUTF8 := AFileName;
  if Mode=fmCreate then
    AHandle := FileCreateUTF8(AFileName) else
    AHandle := FileOpenUTF8(AFileName, Mode);
  if AHandle=THandle(-1) then
    raise EStreamError.Create(AFileName)
  else
    THandleStream(self).Create(AHandle);
end;

//------------------------------------------------------------------------------

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.

