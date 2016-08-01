unit LMessages;

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
    * TWMMove, TWMNotify, TWMSysCommand added
   Version 1.00:
    * File creation.

   Notes:
    - specific to FPC/Lazarus (not used with Delphi),
    - only a subset of all TWM/TLMxxxx possible messages,
    - prior to FPC version 2.6.4, messages are incorrect
      for Windows 64. So, they are redefined here in this case.
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

{$IFDEF FPC}
  {$I LLCLFPCInc.inc}   // (for LLCL_REDEFINE_MESS)
{$ENDIF FPC}

{$IFDEF LLCL_REDEFINE_MESS}
// Messages redefinition for FPC < 2.6.4
type

  TDWordFiller = record                   // 4 bytes padding for Windows 64
  {$ifdef cpu64}
    Filler: array[0..3] of byte;
  {$endif}
  end;

  TMessage = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    case integer of
      0: (
        WParam: WPARAM;
        LParam: LPARAM;
        Result: LRESULT; );
      1: (
        WParamLo: word;
        WParamHi: word;
        WParamFiller: TDWordFiller;
        LParamLo: word;
        LParamHi: word;
        LParamFiller: TDWordFiller;
        ResultLo: word;
        ResultHi: word;
        ResultFill: TDWordFiller; );
  end;

  TWMNoParams = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    WUnused: WPARAM;
    LUnused: LPARAM;
    Result: LRESULT;
  end;

  TWMActivate = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    Active: word;
    Minimized: wordbool;
    WParamFiller: TDWordFiller;
    ActiveWindow: HWND;
    Result: LRESULT;
  end;

  TWMClose                = TWMNoParams;

  TWMCommand = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    ItemID: word;
    NotifyCode: word;
    WParamFiller: TDWordFiller;
    Ctl: HWND;
    Result: LRESULT;
  end;

  TWMCtlColor = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    ChildDC: HDC;
    ChildWnd: HWND;
    Result: LRESULT;
  end;

    TWMCtlColorBtn        = TWMCtlColor;
    TWMCtlColorDlg        = TWMCtlColor;
    TWMCtlColorEdit       = TWMCtlColor;
    TWMCtlColorListbox    = TWMCtlColor;
    TWMCtlColorMsgbox     = TWMCtlColor;
    TWMCtlColorScrollbar  = TWMCtlColor;
    TWMCtlColorStatic     = TWMCtlColor;

  TWMDestroy              = TWMNoParams;

  TWMEraseBkgnd = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    DC: HDC;
    LUnused: LPARAM;
    Result: LRESULT;
  end;

  TWMKey = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    CharCode: word;
    Unused: word;
    WParamFiller: TDWordFiller;
    KeyData: longint;
    LParamFiller: TDWordFiller;
    Result: LRESULT;
  end;

    TWMKeyDown            = TWMKey;
    TWMKeyUp              = TWMKey;
    TWMChar               = TWMKey;
    TWMSysKeyDown         = TWMKey;
    TWMSysKeyUp           = TWMKey;
    TWMSysChar            = TWMKey;

  TWMMouse = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    Keys: WPARAM;
    case integer of
    0: (
       XPos: smallint;
       YPos: smallint; );
    1: (
       Pos: TSmallPoint;
       LParamFiller: TDWordFiller;
       Result: LRESULT; );
  end;

    TWMLButtonDown        = TWMMouse;
    TWMLButtonUp          = TWMMouse;
    TWMLButtonDblClk      = TWMMouse;
    TWMMButtonDown        = TWMMouse;
    TWMMButtonUp          = TWMMouse;
    TWMMButtonDblClk      = TWMMouse;
    TWMRButtonDown        = TWMMouse;
    TWMRButtonUp          = TWMMouse;
    TWMRButtonDblClk      = TWMMouse;
    TWMMouseMove          = TWMMouse;

  TWMMove = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    Unused: WPARAM;
    case integer of
    0: (
       XPos: smallint;
       YPos: smallint; );
    1: (
       Pos: TSmallPoint;
       LParamFiller: TDWordFiller;
       Result: LRESULT; );
  end;

  TWMNCHitTest = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    WUnused: WPARAM;
    case integer of
    0: (
       XPos: smallint;
       YPos: smallint; );
    1: (
       Pos: TSmallPoint;
       LParamFiller: TDWordFiller;
       Result: LRESULT; );
  end;

  TWMNotify = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
		IDCtrl: longint;
    WParamFiller: TDWordFiller;
		NMHdr: PNMHdr;
    Result: LRESULT;
	end;

  TWMPaint = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    DC: HDC;
    LUnused: LPARAM;
    Result: LRESULT;
  end;

  TWMScroll = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    ScrollCode: smallint;
    Pos: smallint;
    WParamFiller: TDWordFiller;
    ScrollBar: HWND;
    Result: LRESULT;
  end;

    TWMHScroll            = TWMScroll;
    TWMVScroll            = TWMScroll;

  TWMSetFocus = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    FocusedWnd: HWND;
    LUnused: LPARAM;
    Result: LRESULT;
  end;

  TWMSize = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    SizeType: WPARAM;
    Width: word;
    Height: word;
    LParamFiller: TDWordFiller;
    Result: LRESULT;
  end;

  TWMSysCommand = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    case CmdType: WPARAM of
      SC_HOTKEY: 	(ActivateWindow: HWND);
      SC_KEYMENU: (Key: word);
      SC_CLOSE, SC_HSCROLL, SC_MAXIMIZE, SC_MINIMIZE, SC_MOUSEMENU, SC_MOVE,
			SC_NEXTWINDOW, SC_PREVWINDOW, SC_RESTORE, SC_SCREENSAVE, SC_SIZE, SC_TASKLIST, SC_VSCROLL:
									(XPos: smallint; YPos: smallint; LParamFiller: TDWordFiller; Result: LRESULT; );
  end;

  TWMTimer = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    TimerID: WPARAM;
    TimerProc: TFarProc;
    Result: LRESULT;
  end;
{$ENDIF LLCL_REDEFINE_MESS}

// Missing
type
  TWMNCActivate = record
    Msg: cardinal;
    MsgFiller: TDWordFiller;
    Active: BOOL;
    WParamFiller: TDWordFiller;
    Unused: LParam;
    Result: LRESULT;
  end;

type
  TLMessage               = TMessage;
  TLMNoParams             = TWMNoParams;

  TLMActivate             = TWMActivate;
  TLMNCActivate           = TWMNCActivate;
//  TLMClose                = TWMClose;
  TLMCommand              = TWMCommand;
//    TLMCtlColor           = TWMCtlColor;
//    TLMCtlColorBtn        = TLMCtlColor;
//    TLMCtlColorDlg        = TLMCtlColor;
//    TLMCtlColorEdit       = TLMCtlColor;
//    TLMCtlColorListbox    = TLMCtlColor;
//    TLMCtlColorMsgbox     = TLMCtlColor;
//    TLMCtlColorScrollbar  = TLMCtlColor;
//    TLMCtlColorStatic     = TLMCtlColor;
  TLMDestroy              = TWMDestroy;
  TLMEraseBkgnd           = TWMEraseBkgnd;
  TLMKey                  = TWMKey;
    TLMKeyDown            = TLMKey;
    TLMKeyUp              = TLMKey;
    TLMChar               = TLMKey;
    TLMSysKeyDown         = TLMKey;
    TLMSysKeyUp           = TLMKey;
    TLMSysChar            = TLMKey;
  TLMMouse                = TWMMouse;
    TLMLButtonDown        = TLMMouse;
    TLMLButtonUp          = TLMMouse;
    TLMLButtonDblClk      = TLMMouse;
    TLMMButtonDown        = TLMMouse;
    TLMMButtonUp          = TLMMouse;
    TLMMButtonDblClk      = TLMMouse;
    TLMRButtonDown        = TLMMouse;
    TLMRButtonUp          = TLMMouse;
    TLMRButtonDblClk      = TLMMouse;
    TLMMouseMove          = TLMMouse;
  TLMNCHitTest            = TWMNCHitTest;
  TLMPaint                = TWMPaint;
  TLMScroll               = TWMScroll;
    TLMHScroll            = TLMScroll;
    TLMVScroll            = TLMScroll;
  TLMSetFocus             = TWMSetFocus;
  TLMSize                 = TWMSize;
//  TLMTimer                = TWMTimer;

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
