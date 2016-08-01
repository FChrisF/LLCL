unit LCLType;

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
    * RT_**** constants added (point to Windows declarations)
   Version 1.00:
    * File creation.

   Notes:
    - very basic unit specific to FPC/Lazarus (not used with Delphi).
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
  Windows;

type
  TCreateParams = record            // Not present in Control.pas for FPC/Lazarus
    Caption:        PChar;
    Style:          cardinal;
    ExStyle:        cardinal;
    X, Y:           integer;
    Width, Height:  integer;
    WndParent:      HWnd;
    Param:          pointer;
    WindowClass:    TWndClass;
    WinClassName:   array[0..63] of Char;
  end;

const
  RT_CURSOR         = Windows.RT_CURSOR;
  RT_BITMAP         = Windows.RT_BITMAP;
  RT_ICON           = Windows.RT_ICON;
  RT_MENU           = Windows.RT_MENU;
  RT_DIALOG         = Windows.RT_DIALOG;
  RT_STRING         = Windows.RT_STRING;
  RT_FONTDIR        = Windows.RT_FONTDIR;
  RT_FONT           = Windows.RT_FONT;
  RT_ACCELERATOR    = Windows.RT_ACCELERATOR;
  RT_RCDATA         = Windows.RT_RCDATA;
  RT_MESSAGETABLE   = Windows.RT_MESSAGETABLE;
  RT_GROUP_CURSOR   = Windows.RT_GROUP_CURSOR;
  RT_GROUP_ICON     = Windows.RT_GROUP_ICON;
  RT_VERSION        = Windows.RT_VERSION;

//------------------------------------------------------------------------------

implementation

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
