unit XPMan;

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
    * TXPManifest implemented

   Notes:
    - specific to Delphi (not used with FPC/Lazarus).
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
  TXPManifest = class(TComponent)
  end;

//------------------------------------------------------------------------------

implementation

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

{$R Vista.res}
//{$R VistaAdm.res}

//------------------------------------------------------------------------------

initialization
  RegisterClasses([TXPManifest]);

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
