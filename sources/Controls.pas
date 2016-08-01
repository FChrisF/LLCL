unit Controls;

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
    * Some improvements for controls created at runtime
    * Support for TRadioGroup
   Version 1.01:
    * Bug fix and modification: background color support
    * TStringGrid and TSelectDirectoryDialog control types added
    * TWinControl: notifications for child controls modified
    * Bug fix for nested groupboxes with Windows XP (not enabled by default - see LLCL_OPT_NESTEDGROUPBOXWINXPFIX option)
    * KeysToShiftState/KeyDataToShiftState moved to LLCLOSInt
    * TVisualControl: 'Alignment' property added (not standard - design time only)
    * TWinControl: modifications in WMEraseBkGnd, WMPaint and ColorCall
    * TWinControl: DoubleBuffered added, used only by Forms (not enabled by default - see LLCL_OPT_DOUBLEBUFF option)
    * TWinControl: WM_SIZE and WM_MOVE taken into account only by Forms
    * TWinControl: fix for StaticText control when size is modified
   Version 1.00:
    * TWinControl: BringToFront (not standard)
    * TWinControl: TabStop and ControlCount properties
    * TWinControl: Focus and keyboard support (tabulations, arrow keys and accelerators/mnemonics)
    * TWinControl: Focused method
    * TWinControl: Mouse messages modified
    * Background and font colors support
    * TCustomControl renamed in TVisualControl - TNonVisualControl added
      TCustomControl is now a subclass of TWinControl (Delphi and FPC compliant)
    * OnPaint specific to forms (See Forms)
    * TMouse (minimal) added
    * CreateHandle modified - CreateParams added
    * Sizes and positions dynamically modifiable
    * Dynamic creation for controls (limited)
    * TVisualControl: AutoSize added for TButton, TCheckBox, TLabel, TRadioButton, TGroupBox, TStaticText (design time only)
    * TVisualControl: Refresh, Repaint and Update added (not standard - in TControl) (Refresh removed from Forms.pas)
    * GetParentForm moved form Controls to Forms
}

// Original notes from LVCL

{
         LVCL - Very LIGHT VCL
         ----------------------------

   Tiny replacement for the standard VCL Controls.pas
   Just put the LVCL directory in your Project/Options/Path/SearchPath
   and your .EXE will shrink from 300KB to 30KB

   Notes:
   - implements TControl+TCustomControl+TGraphicControl+TWinControl
   - compatible with the standard .DFM files.
   - only use existing properties in your DFM, otherwise you'll get error on startup

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

  Some modifications by Leonid Glazyrin, Feb 2012 <leonid.glazyrin@gmail.com>

  * New TWinControl.Enabled property. Both Enabled and Visible loads from DFM
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
  LLCLOSInt, Windows, {$IFDEF FPC}LCLType, LMessages{$ELSE}Messages{$ENDIF},
  Classes, Graphics;

const
  WM_TRAYICON = WM_USER + 125;    // Default messages used inside the MainForm
                                  // windows callback function for TrayIcon
type
  // All known internal control types
  TAllControlTypes = (ATTNone, ATTCustomForm, ATTLabel, ATTButton, ATTEdit, ATTCheckBox,
    ATTRadioButton, ATTGroupBox, ATTMemo, ATTComboBox, ATTListBox, ATTStaticText,
    ATTImage, ATTProgressBar, ATTTrackBar, ATTMenuItem, ATTMainMenu, ATTPopupMenu,
    ATTTimer, ATTTrayIcon, ATTOpenDialog, ATTSaveDialog, ATTSelectDirectoryDialog,
    ATTStringGrid, ATTRadioGroup);    // (ATTRadioGroup not used)

  TMouseButton = (mbLeft, mbRight, mbMiddle);

  TKeyPressEvent = procedure (Sender: TObject; var Key: Char) of object;
  TKeyEvent = procedure (Sender: TObject; var Key: Word; Shift: TShiftState) of object;
  TMouseEvent = procedure (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer) of object;

{$IFNDEF FPC}             // TCreateParams is declared in LCLType for FPC/Lazarus
  TCreateParams = record
    Caption: PChar;
    Style: cardinal;
    ExStyle: cardinal;
    X, Y: integer;
    Width, Height: integer;
    WndParent: HWnd;
    Param: pointer;
    WindowClass: TWndClass;
    WinClassName: array[0..63] of Char;
  end;
{$ENDIF}

{$IFDEF FPC}{$M+}{$ENDIF} // We need to publish them with $M+ (If FPC not in Delphi mode)
  TControl = class;
{$IFDEF FPC}{$M-}{$ENDIF}

  TWinControl = class;

  TControl = class(TComponent)
  private
    fParent: TWinControl;
    fATType: TAllControlTypes;
    fLoaded: boolean;
    EOnClick: TNotifyEvent;
    procedure SetParent(Value: TWinControl);
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    function  FindMethod(Reader: TReader): TMethod;
    procedure SetParentComponent(Value: TComponent); override;
    procedure Loaded; override;
    property  ATType: TAllControlTypes read fATType write fATType;
  public
    property  Parent: TWinControl read fParent write SetParent;
    property  OnClick: TNotifyEvent read EOnClick write EOnClick;
  end;

  TNonVisualControl = class(TControl)
  private
    fControlIdent: integer;
  protected
    procedure SetParentComponent(Value: TComponent); override;
    procedure ControlInit(RuntimeCreate: boolean); virtual; abstract; // Abstract: nothing common
    procedure ControlCall(var Msg: TMessage); virtual; abstract;      //
    property  ControlIdent: integer read fControlIdent;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TVisualControl = class(TControl)
  private
    fCanvas: TCanvas;
    fFont: TFont;
    fParentFont: boolean;
    fColor: integer;
    fHasDesignColor: boolean;       // True if color is specified at design time (i.e. present in form data)
    fLeft, fTop,
    fWidth, fHeight: integer;
    fVisible,
    fTransparent: boolean;
    fCaption: string;
    fAlignment: TAlignment;
    fShowCommand: integer;
    fAutoSize: boolean;
    EOnShow: TNotifyEvent;
    function  GetFont(): TFont;
    procedure SetFont(Value: TFont);
    function  GetCanvas(): TCanvas;
    procedure SetVisible(Value: boolean);
    procedure UpdPosInGroup(SizPosType: integer);
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    function  SubProperty(const SubPropName: string): TPersistent; override;
    procedure SetColor(Value: integer); virtual;
    procedure SetCaption(const Value: string); virtual;
    procedure InvalidateEx(EraseBackGround: boolean); virtual;
    function  GetVisualParentForm(var aForm: TControl): boolean;
    function  IsVisualParentFormLoaded(): boolean;
    procedure SetLeft(Value: integer);
    procedure SetTop(Value: integer);
    procedure SetWidth(Value: integer); virtual;
    procedure SetHeight(Value: integer); virtual;
    property  HasDesignColor: boolean read fHasDesignColor write fHasDesignColor;
    property  ShowCommand: integer read fShowCommand write fShowCommand;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Invalidate;
    procedure Update; virtual;
    procedure Repaint;
    procedure Refresh;
    function  ClientRect(): TRect; virtual;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
    property  Font: TFont read GetFont write SetFont;
    property  Canvas: TCanvas read GetCanvas;   // (Not VCL/LCL standard)
    property  Left: integer read fLeft write SetLeft;
    property  Top: integer read fTop write SetTop;
    property  Width: integer read fWidth write SetWidth;
    property  Height: integer read fHeight write SetHeight;
    property  Color: integer read fColor write SetColor;
    property  Transparent: boolean read fTransparent write fTransparent;
    property  Caption: string read fCaption write SetCaption;
    property  Alignment: TAlignment read fAlignment write fAlignment;   // Runtime modification ignored; write present only for dynamical control creation purpose
    property  Visible: boolean read fVisible write SetVisible;
    property  AutoSize: boolean read fAutoSize write fAutoSize;
    property  ParentFont: boolean read fParentFont write fParentFont;
    property  OnShow: TNotifyEvent read EOnShow write EOnShow;
  end;

  TGraphicControl = class(TVisualControl)
    procedure CheckCallPaint(AHandle: THandle);
  protected
    procedure SetParentComponent(Value: TComponent); override;
    procedure ControlInit(RuntimeCreate: boolean); virtual;
    procedure Paint; virtual; abstract;   // Abstract: specific
  public
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
    procedure Show; override;
    procedure Hide; override;
  end;

  TControlStyle = set of (csAcceptsControl, csCaptureMouse, csClickEvents,
    csFramed, csSetCaption, csOpaque, cdDoubleClicks);
  TControlState = set of (csLButtonDown, csClicked, csPalette, csReadingState,
    csAlignmentNeeded, csFocusing, csCreating, csPaintCopy, csCustomPaint,
    csDestroyingHandle, csDocking);
  TBorderStyle = (bsNone, bsSingle);

  TNewFocusType = (tftCurrent, tftNext, tftPrev, tftNextGroup, tftPrevGroup);
  TKeyProcess = (tkStandard, tkSkip, tkForceStandard, tkNoEnterDef,
    tkSkipNonEnterDef);

  TWinControl = class(TVisualControl)
  private
    fHandle: THandle;
    fControls: TList;
    fGraphics: TList;                 // Visuals but not standard Windows controls
    fNonVisuals: TList;               // Non visual controls
    fLastNonVisualIdent: integer;     //     "        "
    fEnabled: boolean;
    fTabOrder: integer;
    fTabStop: boolean;
    fRealTabOrder: boolean;
    fArrowKeysInternal: boolean;      // Controls using arrow keys internally
    fSpecTabStop: boolean;            // For specific TabStop
    fKeyboardMsg: byte;               // Specific for keyboard messages (see TComboBox): 0=Standard, 1=Do not Inherit, 2=Do not PostProcess, 3+=Specific
    fTabTestFirstCtrl: TWinControl;
    fOldProc: TFNWndProc;
    fClicked: boolean;
    fDoubleBuffered: boolean;
    EOnKeyPress: TKeyPressEvent;
    EOnKeyDown: TKeyEvent;
    EOnKeyUp: TKeyEvent;
    EOnMouseDown: TMouseEvent;
    EOnMouseUp: TMouseEvent;
    EOnDblClick: TNotifyEvent;
    procedure SetEnabled(Value: boolean);
    function  GetCCount(): integer;
    procedure SetCCount(Number: integer);
    procedure ClearUI(UIType: integer);
    procedure NewFormFocus(NewFocus: TNewFocusType);
    function  NewParentFocus(NewFocus: TNewFocusType; ContTabOrder: integer; var NewControl: TWinControl; UpperAllowed: boolean): boolean;
    procedure UpdateFormFocus();
    function  FormAccelControl(var Msg: TWMKey): boolean;
    function  DefCanButton(const CharCode: Word): boolean;
    procedure UpdButtonHighlight();
    function  GetLastTabOrder(): integer;
    procedure AfterModifyTabOrder(OldTabOrder: integer; NewTabOrder: integer; const AControl: TWinControl);
    function  ForWMKeyDownUpForm(var Msg: TWMKey; UpOrDown: integer): boolean;
    function  ForWMKeyDownUp(var Msg: TWMKey; EOnForKeyDownUp: TKeyEvent): boolean;
    function  ForWMChar(var Msg: TWMKey; EOnForKeyPress: TKeyPressEvent): boolean;
    procedure ForControlCall(var Msg: TMessage; CControlIdent: integer; CATType: TAllControlTypes);
    function  GetChildControl(Value: THandle): integer;
    procedure UpdTextSize(const Value: string);
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    procedure SetParentComponent(Value: TComponent); override;
    procedure CreateHandle; virtual;
    procedure CreateAllHandles;
    procedure HandleNeeded;
    procedure CreateParams(var Params: TCreateParams); virtual;
    procedure SetHandle(Value: THandle);
    procedure SetColor(Value: integer); override;
    procedure SetCaption(const Value: string); override;
    function  GetTabOrder(): integer;
    procedure SetTabOrder(Value: integer);
    procedure ClickCall(ChangeFocus: boolean; DoSetFocus: boolean); virtual;
    function  ColorCall(var Msg: TWMCtlColorStatic): boolean;
    function  ColorForSubCont(SubContMsg: integer; SubConthWnd: THandle): boolean; virtual;
    procedure FormFocus();
    function  SpecialKeyProcess(var CharCode: Word): TKeyProcess; virtual;
    function  GetSpecTabStop(): boolean; virtual;
    function  ForwardChildMsg(var Msg: TMessage; WndChild: THandle): boolean; virtual;
    function  ComponentNotif(var Msg: TMessage): boolean; virtual;
    procedure AdjustTextSize(var Size: TSize); virtual;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;   // Used in Grids, if "DefNo_StdMouseMessages"
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;         // Used in Grids, if "DefNo_StdMouseMessages"
    procedure WMRButtonDown(var Msg: TWMRButtonDown); message WM_RBUTTONDOWN;   // Used in Grids, if "DefNo_StdMouseMessages"
    procedure WMRButtonUp(var Msg: TWMRButtonUp); message WM_RBUTTONUP;         // Used in Grids, if "DefNo_StdMouseMessages"
    procedure WMLDblClick(var Msg: TWMLButtonDblClk); message WM_LBUTTONDBLCLK; // Used in Grids, if "DefNo_StdMouseMessages"
    procedure WMRDblClick(var Msg: TWMRButtonDblClk); message WM_RBUTTONDBLCLK; // Used in Grids, if "DefNo_StdMouseMessages"
    procedure WMChar(var Msg: TWMChar); message WM_CHAR;
    procedure WMKeyDown(var Msg: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Msg: TWMKeyUp); message WM_KEYUP;
    procedure WMSysKeyDown(var Msg: TWMSysKeyDown); message WM_SYSKEYDOWN;
    procedure WMSysKeyUp(var Msg: TWMSysKeyUp); message WM_SYSKEYUP;
    procedure WMSysChar(var Msg: TWMSysChar); message WM_SYSCHAR;
//    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;  // Used in Forms, if "top invisible" form (but not here)
//    procedure WMNCActivate(var Msg: TWMNCActivate); message WM_NCACTIVATE;  // Used in Forms, if "top invisible" form (but not here)
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMDestroy(var Msg: TWMDestroy); message WM_DESTROY;
//    procedure WMActivate(var Msg: TWMActivate); message WM_ACTIVATE;  // Used in Forms (but not here)
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;  // Used also in StdCtrls and Forms
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMColorStatic(var Msg: TWMCtlColorStatic); message WM_CTLCOLORSTATIC;
    procedure WMColorEdit(var Msg: TWMCtlColorEdit); message WM_CTLCOLOREDIT;
    procedure WMColorListBox(var Msg: TWMCtlColorListBox); message WM_CTLCOLORLISTBOX;
    procedure WMColorButton(var Msg: TWMCtlColorBtn); message WM_CTLCOLORBTN;
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
    procedure WMTray(var Msg: TMessage); message WM_TRAYICON;       // Used also in ExtCtrls indirectly
//    procedure WMClose(var Msg: TWMClose); message WM_CLOSE;       // Used in Forms (but not here)
    procedure WMCommand(var Msg: TWMCommand); message WM_COMMAND;   // Used also in StdCtrls (Edit, ComboBox and ListBox indirectly) and Forms
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;            // Used also in Forms
    procedure WMMove(var Msg: TWMMove); message WM_MOVE;            // Used also in Forms
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMMouseMove(var Msg: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMHScroll(var Msg: TWMHScroll); message WM_HSCROLL;   // Used also in ComCtrls (TrackBar indirectly)
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;   // Used also in ComCtrls (TrackBar indirectly)
    procedure WMNotify(var Msg: TWMNotify); message WM_NOTIFY;      // Used also in Grids (StringGrid indirectly)
    property  ArrowKeysInternal: boolean read fArrowKeysInternal write fArrowKeysInternal;
    property  SpecTabStop: boolean read GetSpecTabStop write fSpecTabStop;
    property  KeyboardMsg: byte read fKeyboardMsg write fKeyboardMsg;   // (Not LCL/VCL standard)
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure DefaultHandler(var Message); override;
    procedure Update; override;
    function  ClientRect(): TRect; override;
    procedure Show; override;
    procedure Hide; override;
    function  CanFocus(): boolean;
    function  Focused(): boolean;
    procedure SetFocus();
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
    procedure BringToFront;       // (Theoretically in TControl)
    property  TabOrder: integer read GetTabOrder write SetTabOrder;
    property  TabStop: boolean read fTabStop write fTabStop;
    property  Handle: THandle read fHandle write SetHandle;
    property  Enabled: boolean read fEnabled write SetEnabled;
    property  Controls: TList read fControls;
    property  ControlCount: integer read GetCCount write SetCCount;
    property  DoubleBuffered: boolean read fDoubleBuffered write fDoubleBuffered;
    property  OnKeyPress: TKeyPressEvent read EOnKeyPress write EOnKeyPress;
    property  OnKeyDown: TKeyEvent read EOnKeyDown write EOnKeyDown;
    property  OnKeyUp: TKeyEvent read EOnKeyUp write EOnKeyUp;
    property  OnMouseDown: TMouseEvent read EOnMouseDown write EOnMouseDown;
    property  OnMouseUp: TMouseEvent read EOnMouseUp write EOnMouseUp;
    property  OnDblClick: TNotifyEvent read EOnDblClick write EOnDblClick;
  end;

  TCustomControl = class(TWinControl);

  TMouse = class
  private
    function  GetCursorPos: TPoint;
    procedure SetCursorPos(ACursPos: TPoint);
  public
    property  CursorPos: TPoint read GetCursorPos write SetCursorPos;
  end;

var
  NewStyleControls: boolean = true;
  Mouse: TMouse;

//------------------------------------------------------------------------------

implementation

uses
  Forms, StdCtrls, SysUtils;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

type
  TPCustomForm = class(TCustomForm);  // To access to protected part

const
  USP_INGROUPLEFT       = 1;
  USP_INGROUPTOP        = 2;

  UITYPE_ACCELERATOR    = 0;
  UITYPE_FOCUS          = 1;

  // Can contain controls
  TContainControls = [ATTCustomForm, ATTGroupBox];
  // Click on control doesn't set focus
  TNonClickFocusCtrl = [ATTCustomForm, ATTStaticText, ATTProgressBar];

function TWCWndProc(hWnd: THandle; Msg: cardinal; awParam, alParam: NativeUInt): NativeUInt; stdcall; forward;

//------------------------------------------------------------------------------

{$IFDEF FPC}
// Dummy function to avoid compilation hint (LMessages not used)
function LMessages_Dummy(const Msg: TLMCommand): boolean;
begin
  result := false;
end;
{$ENDIF FPC}

function TWCWndProc(hWnd: THandle; Msg: cardinal; awParam, alParam: NativeUInt): NativeUInt; stdcall;
var obj: TObject;
    dsp: TMessage;
begin
  obj := TObject(LLCL_GetWindowLongPtr(hWnd, GWL_USERDATA)); // faster than GetProp()
  if not Assigned(obj) then
    result := LLCL_DefWindowProc(hWnd, Msg, WPARAM(awParam), LPARAM(alParam))
  else
    begin
      dsp.Msg := Msg;
      dsp.wParam := WPARAM(awParam);
      dsp.lParam := LPARAM(alParam);
      dsp.result := 0;
      obj.Dispatch(dsp);
      result := dsp.result;
    end;
end;

{ TControl }

procedure TControl.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..0] of PChar = ('OnClick');
begin
  case StringIndex(PropName, Properties) of
    0 : TMethod(EOnClick) := FindMethod(Reader);
    else inherited;
  end;
end;

function TControl.FindMethod(Reader: TReader): TMethod;
var AComponent: TComponent;
    AName: shortstring;
begin
  if Reader.ReadValueType in [vaString, vaIdent] then begin
    AName := Reader.ReadShortString;
    AComponent := self;
    while AComponent<>nil do begin
      result.Data := AComponent;
      result.Code := AComponent.MethodAddress(AName);
      if result.Code<>nil then exit;
      AComponent := AComponent.Owner;
    end;
  end;
  raise EClassesError.Create(LLCL_STR_CTRL_METHOD);
end;

procedure TControl.SetParent(Value: TWinControl);
begin
  SetParentComponent(Value);
end;

procedure TControl.SetParentComponent(Value: TComponent);
var aValue: TComponent;
begin
  inherited;
  fParent := nil;
  aValue := Value;
  while (aValue<>nil) and not aValue.InheritsFrom(TWinControl) do
    aValue := aValue.GetParentComponent;
  if aValue<>nil then
    fParent := TWinControl(aValue);
end;

procedure TControl.Loaded;
begin
  inherited;
  fLoaded := true;  // Used only for forms (for controls created at runtime)
end;

{ TNonVisualControl }

constructor TNonVisualControl.Create(AOwner: TComponent);
var ParentControl: TControl;
begin
  inherited;
  if AOwner=nil then
    ParentControl := Application.MainForm
  else
    ParentControl := TControl(AOwner);      // (A form is expected)
  if ParentControl.fLoaded then             // Control created at runtime
    begin
      SetParentComponent(ParentControl);
      ControlInit(true);
    end;
end;

procedure TNonVisualControl.SetParentComponent(Value: TComponent);
begin
  inherited;
  fParent.fNonVisuals.Add(self);
  Inc(fParent.fLastNonVisualIdent);
  fControlIdent := fParent.fLastNonVisualIdent;
end;

{ TVisualControl }

constructor TVisualControl.Create(AOwner: TComponent);
begin
  inherited;
  fParentFont := true;  // default value
  if not (ATType=ATTCustomForm) then
    fVisible := true;
end;

destructor TVisualControl.Destroy;
begin
  fFont.Free;
  fCanvas.Free;
  inherited;
end;

procedure TVisualControl.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..11] of PChar = (
    'Left', 'Top',
    'Width', 'Height',
    'Color',
    'Transparent',
    'Caption',
    'ParentFont',
    'Visible',
    'AutoSize',
    'Alignment',
    'OnShow'
    );
begin
  case StringIndex(PropName, Properties) of
    0 : begin
          fLeft := Reader.IntegerProperty;
          UpdPosInGroup(USP_INGROUPLEFT);   // FPC only
        end;
    1 : begin
          fTop := Reader.IntegerProperty;
          UpdPosInGroup(USP_INGROUPTOP);    // FPC only
        end;
    2 : fWidth := Reader.IntegerProperty;
    3 : fHeight := Reader.IntegerProperty;
    4 :
        begin
          fColor := Reader.ColorProperty;
          fHasDesignColor := true;
        end;
    5 : fTransparent := Reader.BooleanProperty;
    6 : fCaption := Reader.StringProperty;
    7 : fParentFont := Reader.BooleanProperty;
    8 : fVisible := Reader.BooleanProperty;
    9 : fAutoSize := Reader.BooleanProperty;
    10: Reader.IdentProperty(fAlignment, TypeInfo(TAlignment));   // ('Alignment' no standard)
    11: TMethod(EOnShow) := FindMethod(Reader);
    else inherited;
  end;
end;

function TVisualControl.SubProperty(const SubPropName: string): TPersistent;
const SubProperties: array[0..0] of PChar = ('Font');
begin
  case StringIndex(SubPropName, SubProperties) of
  0 : begin
        if fFont=nil then
          fFont := TFont.Create;
        result := fFont;
      end;
   else result := inherited SubProperty(SubPropName);
  end;
end;

// FPC: Control positions update, if in GroupBox
procedure TVisualControl.UpdPosInGroup(SizPosType: integer);
begin
{$IFDEF FPC}
  if (fParent=nil) or (fParent=self) then exit;
  if (fParent.ATType=ATTGroupBox) then
    if SizPosType = USP_INGROUPLEFT then    // Left
      Inc(fLeft, 2)
    else                                    // Top
      Inc(fTop, 16);
{$ENDIF FPC}
end;

procedure TVisualControl.SetColor(Value: integer);
begin
  fColor := Value;
  Canvas.Brush.Color := Value;
end;

procedure TVisualControl.SetCaption(const Value: string);
begin
  fCaption := Value;
end;

procedure TVisualControl.InvalidateEx(EraseBackGround: boolean);
var R: TRect;
begin
  if fParent=nil then exit;
  R := ClientRect();
  LLCL_InvalidateRect(fParent.Handle, @R, EraseBackGround);
end;

// Gets parent form (not only direct parent)
function TVisualControl.GetVisualParentForm(var aForm: TControl): boolean;
begin
  aForm := GetParentForm(self);
  result := (aForm<>nil) and (aForm<>self);
end;

// Is parent form loaded (for controls created at runtime) ?
function TVisualControl.IsVisualParentFormLoaded(): boolean;
var ParentForm: TCustomForm;
begin
  if GetVisualParentForm(TControl(ParentForm)) then
    result := ParentForm.fLoaded
  else
    result := false;
end;

procedure TVisualControl.SetLeft(Value: integer);
begin
  SetBounds(Value, fTop, fWidth, fHeight);
end;

procedure TVisualControl.SetTop(Value: integer);
begin
  SetBounds(fLeft, Value, fWidth, fHeight);
end;

procedure TVisualControl.SetWidth(Value: integer);
begin
  SetBounds(fLeft, fTop, Value, fHeight);
end;

procedure TVisualControl.SetHeight(Value: integer);
begin
  SetBounds(fLeft, fTop, fWidth, Value);
end;

function TVisualControl.GetFont(): TFont;
begin
  if fFont=nil then begin
    if fParentFont and (fParent<>nil) then begin
      result := fParent.Font;
      exit;
    end;
    fFont := TFont.Create;
  end;
  result := fFont;
end;

procedure TVisualControl.SetFont(Value: TFont);
begin
  fParentFont := false; // to create a custom font
  Font.Assign(Value);
end;

function TVisualControl.GetCanvas(): TCanvas;
begin
  if fCanvas=nil then
    fCanvas := TCanvas.Create;
  result := fCanvas;
end;

procedure TVisualControl.SetVisible(Value: boolean);
begin
  if Value then Show
  else Hide;
end;

procedure TVisualControl.Update;
begin
  if fParent<>nil then Parent.Update;
end;

procedure TVisualControl.Invalidate;
begin
  InvalidateEx(not Transparent);
end;

procedure TVisualControl.Repaint;
begin
  Invalidate;
  Update;
end;

procedure TVisualControl.Refresh;
begin
  Repaint;
end;

function TVisualControl.ClientRect(): TRect;
begin
  result := Bounds(fLeft, fTop, fWidth, fHeight);
end;

procedure TVisualControl.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
  fLeft   := ALeft;
  fTop    := ATop;
  fWidth  := AWidth;
  fHeight := AHeight;
end;

procedure TVisualControl.Show;
begin
  fVisible := true;   // (fVisible, not Visible - see SetVisible)
end;

procedure TVisualControl.Hide;
begin
  fVisible := false;   // (fVisible, not Visible - see SetVisible)
end;

{ TGraphicControl }

procedure TGraphicControl.SetParentComponent(Value: TComponent);
begin
  inherited;
  if fParent<>nil then begin
    fParent.fGraphics.Add(self);
  end;
  if IsVisualParentFormLoaded then   // Control created at runtime
    ControlInit(true);
end;

procedure TGraphicControl.ControlInit(RuntimeCreate: boolean);
begin
  if RunTimeCreate then
    if Visible then Show;
end;

// Calls paint only if needed
procedure TGraphicControl.CheckCallPaint(AHandle: THandle);
begin
  if Visible then
    if LLCL_RectVisible(AHandle, ClientRect()) then   // Pb2 for GroupBox -> Not relevant
      begin
        Canvas.Handle := AHandle;
        Paint;
      end;
end;

procedure TGraphicControl.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
  if Visible then
    InvalidateEx(true);
  inherited;
  if Visible then
    InvalidateEx(false);
end;

procedure TGraphicControl.Show;
begin
  inherited;
  InvalidateEx(false);
end;

procedure TGraphicControl.Hide;
begin
  inherited;
  InvalidateEx(true);
end;

{ TWinControl }

constructor TWinControl.Create(AOwner: TComponent);
begin
  inherited;
  fShowCommand := SW_SHOW;
  fControls := TList.Create;
  fGraphics := TList.Create;
  fNonVisuals := TList.Create;
  fEnabled := true;
  fTabStop := true;
end;

destructor TWinControl.Destroy;
begin
  Handle := 0;
  fControls.Free;
  fGraphics.Free;
  fNonVisuals.Free;
  inherited;
end;

procedure TWinControl.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..9] of PChar = (
    'Text',
    'TabOrder', 'TabStop', 'Enabled',
    'OnKeyPress', 'OnKeyDown', 'OnKeyUp',
    'OnMouseDown', 'OnMouseUp', 'OnDblClick'
    );
begin
  case StringIndex(PropName, Properties) of
    0 : fCaption := Reader.StringProperty;          // ('Text' no standard for TWinControl)
    1 : TabOrder := Reader.IntegerProperty;
    2 : fTabStop := Reader.BooleanProperty;
    3 : fEnabled := Reader.BooleanProperty;
    4 : TMethod(EOnKeyPress)  := FindMethod(Reader);
    5 : TMethod(EOnKeyDown)   := FindMethod(Reader);
    6 : TMethod(EOnKeyUp)     := FindMethod(Reader);
    7 : TMethod(EOnMouseDown) := FindMethod(Reader);
    8 : TMethod(EOnMouseUp)   := FindMethod(Reader);
    9 : TMethod(EOnDblClick)  := FindMethod(Reader);
    else inherited;
  end;
end;

procedure TWinControl.SetParentComponent(Value: TComponent);
begin
  inherited;
  if fParent<>nil then begin
    fParent.fControls.Add(self);
  end;
  if IsVisualParentFormLoaded then   // Control created at runtime
    begin
      HandleNeeded;
      if fParent<>nil then
        fTabOrder := fparent.GetLastTabOrder()+1;   // Not TabOrder (->SetTabOrder)
    end;
end;

procedure TWinControl.CreateHandle;
var CCreateParams: TCreateParams;
begin
  CreateParams(CCreateParams);
  with CCreateParams do
    Handle := LLCL_CreateWindowEx(ExStyle, @WinClassName, Caption,
    Style, X, Y, Width, Height, WndParent, 0, WindowClass.hInstance, Param);
  Canvas.Brush.Color := fColor;
  UpdTextSize(Caption);
end;

procedure TWinControl.CreateAllHandles;
var i: integer;
begin
  HandleNeeded;
  for i := 0 to fControls.Count-1 do
    with TWinControl(fControls[i]) do
      HandleNeeded;
end;

procedure TWinControl.HandleNeeded;
var i: integer;
begin
  if fParent<>nil then
    fParent.HandleNeeded;
  if fHandle=0 then
    begin
      CreateHandle;
      if ATType=ATTCustomForm then            // Inits graphical and non visual controls too
        begin
          for i := 0 to fGraphics.Count-1 do
            TGraphicControl(fGraphics[i]).ControlInit(false);
          for i := 0 to fNonVisuals.Count-1 do
            TNonVisualControl(fNonVisuals[i]).ControlInit(false);
        end;
    end;
end;

procedure TWinControl.CreateParams(var Params: TCreateParams);
begin
  FillChar(Params, SizeOf(Params), 0);
  with Params do
    begin
      Caption := @fCaption[1];
      Style := WS_CHILD;
      if Visible then
        Style := Style or WS_VISIBLE;
      X := fLeft;
      Y := fTop;
      Width := fWidth;
      Height := fHeight;
      if fParent<>nil then
        WndParent := fParent.Handle;
      WindowClass.hInstance := hInstance;
    end;
end;

procedure TWinControl.SetHandle(Value: THandle);
begin
  if fHandle<>0 then begin
    LLCL_SetWindowLongPtr(fHandle, GWL_WNDPROC, NativeUInt(fOldProc));
    LLCL_DestroyWindow(fHandle);
  end;
  fHandle := Value;
  if fHandle<>0 then begin
    fOldProc := TFNWndProc(LLCL_GetWindowLongPtr(fHandle, GWL_WNDPROC));
    LLCL_SetWindowLongPtr(fHandle, GWL_USERDATA, NativeUInt(self)); // faster than SetProp()
    LLCL_SetWindowLongPtr(fHandle, GWL_WNDPROC, NativeUInt(@TWCWndProc));
    {$ifdef LLCL_OPT_NESTEDGROUPBOXWINXPFIX}
    if not (ATType=ATTGroupBox) then
    {$endif}
      LLCL_SendMessage(fHandle, WM_SETFONT, WPARAM(Font.Handle), 0);
    SetEnabled(fEnabled);
  end;
end;

procedure TWinControl.SetColor(Value: integer);
begin
  inherited;
  if fHandle=0 then exit;   // (may be called in create constructor)
  if ATType in TContainControls then
    LLCL_RedrawWindow(fHandle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN);
  LLCL_InvalidateRect(fHandle, nil, true);
end;

procedure TWinControl.SetCaption(const Value: string);
begin
  inherited;
  if fHandle=0 then exit;   // (later when created at runtime)
    begin
      UpdTextSize(Value);
      LLCLS_SendMessageSetText(fHandle, WM_SETTEXT, Value);
    end;
end;

function TWinControl.GetTabOrder(): integer;
begin
  if fRealTabOrder then
    result := fTabOrder
  else
    result := -1;
end;

procedure TWinControl.SetTabOrder(Value: integer);
begin
  if IsVisualParentFormLoaded then   // Control created at runtime
    if fParent<>nil then
      fParent.AfterModifyTabOrder(fTabOrder, Value, self);
  fTabOrder := Value;
  fRealTabOrder := true;
end;

procedure TWinControl.ClickCall(ChangeFocus: boolean; DoSetFocus: boolean);
var i: integer;
begin
  if ChangeFocus then
    if DoSetFocus then
      SetFocus()
    else
      UpdateFormFocus();
  if ATType=ATTRadioButton then   // Checks this one, and unchecks others
    if fParent<>nil then
      with fParent do
        for i := 0 to fControls.Count-1 do
          if (TControl(fControls[i]).ATType=ATTRadioButton) then
            TRadioButton(fControls[i]).Checked := (TWinControl(fControls[i])=self);
  if Assigned(EOnClick) then
    EOnClick(self);
end;

function TWinControl.ColorCall(var Msg: TWMCtlColorStatic): boolean;
var AColor: integer;
var AHandle: THandle;
var i: integer;
begin
  result := true;
  for i := 0 to fControls.Count-1 do
    begin
      if (Msg.ChildWnd=TWinControl(fControls[i]).Handle) or
        TWinControl(fControls[i]).ColorForSubCont(Msg.Msg, Msg.ChildWnd) then
        with TWinControl(fControls[i]) do
          begin
            {$ifdef LLCL_OPT_NESTEDGROUPBOXWINXPFIX}
            if ATType=ATTGroupBox then
              LLCL_SelectObject(Msg.ChildDC, Font.Handle);
            {$endif}
            if fParentFont then
              AColor := fParent.Font.Color    // (fParent<>nil)
            else
              AColor := Font.Color;
            LLCL_SetTextColor(Msg.ChildDC, AColor);
            if (ATType in [ATTButton, ATTCheckBox, ATTRadioButton, ATTGroupBox, ATTTrackBar])
              or ((ATType=ATTStaticText) and Transparent) then
                begin
                  AColor := fParent.Color;    // (fParent<>nil)
                  AHandle := fParent.Canvas.Brush.Handle;
                end
            else
              begin
                AColor := Color;
                AHandle := Canvas.Brush.Handle;
              end;
            LLCL_SetBkColor(Msg.ChildDC, AColor);
            Msg.Result := LRESULT(AHandle);
            exit;
          end;
    end;
  result := false;
end;

// Color for a sub control (ComboBox) ?
function TWinControl.ColorForSubCont(SubContMsg: integer; SubConthWnd: THandle): boolean;
begin
  result := false;
end;

// Retrieves and set focus for current focused control
procedure TWinControl.FormFocus();
begin
  NewFormFocus(tftCurrent);
end;

// Processing for special keys (Return, Escape, Tabulation)
function TWinControl.SpecialKeyProcess(var CharCode: Word): TKeyProcess;
begin
  result := tkStandard;   // Standard (i.e. none), by default
end;

// Call to forward messages to the concerned child control
function TWinControl.ForwardChildMsg(var Msg: TMessage; WndChild: THandle): boolean;
var ChildIndex: integer;
begin
  result := true;
  if WndChild<>0 then
    begin
      ChildIndex := GetChildControl(WndChild);
      // Forwards messages to the concerned child control
      if (ChildIndex>=0) then
        with TWinControl(fControls[ChildIndex]) do
          result := ComponentNotif(Msg);
    end;
end;

// Messages forwarded to the concerned child control (received in parent form - equivalent of CN_* messages)
function TWinControl.ComponentNotif(var Msg: TMessage): boolean;
begin
  result := true;
end;

// Text size adjustement
procedure TWinControl.AdjustTextSize(var Size: TSize);
begin
end;

procedure TWinControl.SetEnabled(Value: boolean);
begin
  fEnabled := Value;
  if fHandle=0 then exit;   // (later when created at runtime)
  LLCL_EnableWindow(fHandle, Value);
  if (not Value) and Focused() then
    NewFormFocus(tftNextGroup);
end;

function TWinControl.GetCCount(): integer;
begin
  result := fControls.Count;
end;

procedure TWinControl.SetCCount(Number: integer);
begin
  fControls.Count := Number;
end;

procedure TWinControl.ClearUI(UIType: integer);
var i: integer;
begin
  if CheckWin32Version(LLCL_WIN2000_MAJ, LLCL_WIN2000_MIN) then
    begin
      if UIType=UITYPE_ACCELERATOR then
        i := UISF_HIDEACCEL else
        i := UISF_HIDEFOCUS;
      LLCL_PostMessage(Handle, WM_CHANGEUISTATE, UIS_CLEAR or (i shl 16), 0);
    end;
end;

// Focus for new control (or current control) in form
procedure TWinControl.NewFormFocus(NewFocus: TNewFocusType);
var ParentForm: TCustomForm;
var NewCallFocus: TNewFocusType;
var aControl, NewControl: TWinControl;
var CurTabOrder: integer;
begin
  if not GetVisualParentForm(TControl(ParentForm)) then
    if ATType=ATTCustomForm then
      ParentForm := TCustomForm(self)
    else
      exit;
  NewCallFocus := NewFocus;
  aControl := ParentForm.ActiveControl; // Current control with focus in form
  if aControl=nil then
    begin
      if NewCallFocus=tftCurrent then
        NewCallFocus := tftNextGroup;
      CurTabOrder := -1;
      aControl := ParentForm;
    end
  else
    begin
      if NewCallFocus=tftCurrent then
        begin
          aControl.SetFocus();
          exit;
        end;
      // Specific case: next tabulation directly for a container (GroupBox)
      if (aControl.ATType in [ATTGroupBox]) and (NewCallFocus=tftNextGroup) then
        CurTabOrder := -1
      else
        begin
          CurTabOrder := aControl.fTabOrder;
          aControl := aControl.fParent;
        end;
    end;
  if aControl<>nil then
    with aControl do
      if NewParentFocus(NewCallFocus, CurTabOrder, NewControl, true) then
        NewControl.SetFocus();
end;

// Focus for new control in parent (Can be recursively called)
function TWinControl.NewParentFocus(NewFocus: TNewFocusType; ContTabOrder: integer; var NewControl: TWinControl; UpperAllowed: boolean): boolean;
var CurTabOrder, NewTabOrder, NewOverTabOrder: integer;
var NewIndex, NewOverIndex: integer;
var FirstCtrlCall: boolean;
var i: integer;
begin
  result := false;
  // Init values
  CurTabOrder := ContTabOrder;
  if NewFocus in [tftNext, tftNextGroup] then
    begin
      if CurTabOrder<0 then CurTabOrder := -1;
      NewTabOrder := 999999;
      NewOverTabOrder := 999999;
    end
  else
    begin
      if CurTabOrder<0 then CurTabOrder := 999999;
      NewTabOrder := -1;
      NewOverTabOrder := -1;
    end;
  NewIndex := -1;
  NewOverIndex := -1;
  // Loop through parent controls, to find new one
  for i := 0 to fControls.Count-1 do
    with TWinControl(fControls[i]) do
      if CanFocus() then
        // Previous
        if (NewFocus=tftNext) or ((NewFocus=tftNextGroup) and SpecTabStop) then
          begin
            if (fTabOrder>CurTabOrder) and (fTabOrder<NewTabOrder) then
              begin NewTabOrder := fTabOrder; NewIndex := i; end;
            if (fTabOrder<CurTabOrder) and (fTabOrder<NewOverTabOrder) then
              begin NewOverTabOrder := ftabOrder; NewOverIndex := i; end;
          end
        // Next
        else
          if (NewFocus=tftPrev) or ((NewFocus=tftPrevGroup) and SpecTabStop) then
            begin
              if (fTabOrder<CurTabOrder) and (fTabOrder>NewTabOrder) then
                begin NewTabOrder := fTabOrder; NewIndex := i; end;
              if (fTabOrder>CurTabOrder) and (fTabOrder>NewOverTabOrder) then
                begin NewOverTabOrder := ftabOrder; NewOverIndex := i; end;
            end;
  // Specific cases first
  // A: 0 0 - Only one (current) control and arrow keys, so stay
  if (NewFocus in [tftNext, tftPrev]) and (NewIndex<0) and (NewOverIndex<0) then
    exit;
  // T: 0 x - Not found (2 cases), so try with parent, or stay if only one (current) control
  if (NewIndex<0) and (NewFocus in [tftNextGroup, tftPrevgroup]) then
    if (fParent<>nil) and UpperAllowed then
      begin
        with fParent do
          result := NewParentFocus(NewFocus, self.fTabOrder, NewControl, true);
        exit;
      end
    else
      if NewOverIndex<0 then
        exit;
  // At this step, at least one solution is possible (i.e. NewIndex and/or NewOverIndex)
  // Over if not direct
  if NewIndex<0 then
    NewIndex := NewOverIndex;
  // General case
  if (NewIndex>=0) then     // Sanity
    with TWinControl(fControls[NewIndex]) do
      // Container (Groupbox) and tabulation, so search in lower level
      if ((NewFocus in [tftNextGroup, tftPrevGroup]) and (not fTabStop) and (ATType in [ATTGroupBox])) then
        begin
          FirstCtrlCall := false;
          if fTabTestFirstCtrl=nil then
            begin
              FirstCtrlCall := true;
              fTabTestFirstCtrl := TWinControl(self.fControls[NewIndex]);
            end;
          if FirstCtrlCall or (fTabTestFirstCtrl<>TWinControl(self.fControls[NewIndex])) then
            result := NewParentFocus(NewFocus, -1, NewControl, true);
          if FirstCtrlCall then
            fTabTestFirstCtrl := nil;
        end
      else
        begin
          NewControl := TWinControl(self.fControls[NewIndex]);
          result := true;
        end;
end;

// Control has focus
procedure TWinControl.UpdateFormFocus();
var ParentForm: TCustomForm;
begin
  if GetVisualParentForm(TControl(ParentForm)) then
    TPCustomForm(ParentForm).SetFocusControl(self);
end;

// Generic TabStop (Specific for some controls)
function TWinControl.GetSpecTabStop(): boolean;
begin
  result := TabStop;
end;

// Control corresponding to accelerator (Alt+Char) in form ?
function TWinControl.FormAccelControl(var Msg: TWMKey): boolean;
var NewControl: TWinControl;
var DummyMsg: TMessage;
var i: integer;
begin
  result := false;
  for i := 0 to fControls.Count-1 do
    with TWinControl(fControls[i]) do
      begin
        if (ATType in [ATTButton, ATTCheckBox, ATTRadioButton, ATTGroupBox]) then
          if IsAccel(Msg.CharCode, fCaption) and CanFocus() then
            begin
              case ATType of
              ATTButton:
                ClickCall(false, false);
              ATTCheckBox, ATTRadioButton:
                begin
                  ClickCall(true, true);
                  if ATType=ATTCheckBox then
                    begin
                      FillChar(DummyMsg, SizeOf(DummyMsg), 0);
                      ComponentNotif(DummyMsg);
                    end;
                end;
              ATTGroupBox:
                if NewParentFocus(tftNextGroup, -1, NewControl, false) then
                  NewControl.SetFocus();
              end;
              result := true;
              break;
            end;
        if (ATType in [ATTGroupBox]) then
          if FormAccelControl(Msg) then
            begin
              result := true;
              break;
            end;
      end;
end;

function TWinControl.DefCanButton(const CharCode: Word): boolean;
var i: integer;
begin
  result := false;
  for i := 0 to fControls.Count-1 do
    if TWinControl(fControls[i]).ATType=ATTButton then
      with TButton(fControls[i]) do
        if (((CharCode=VK_RETURN) and Default) or
           ((CharCode=VK_ESCAPE) and Cancel)) and CanFocus() then
            begin
              ClickCall(false, false);
              result := true;
              break;
            end;
end;

procedure TWinControl.UpdButtonHighlight();
var ParentForm: TCustomForm;
var HandleNewButton, HandleCurButton: THandle;
begin
  if not GetVisualParentForm(TControl(ParentForm)) then exit;
  if ATType=ATTButton then
    HandleNewButton := fHandle
  else
    HandleNewButton := TPCustomForm(ParentForm).HandleDefButton;
  HandleCurButton := TPCustomForm(ParentForm).HandleCurButton;
  if HandleNewButton=HandleCurButton then exit;
  if HandleCurButton<>0 then
    LLCL_SendMessage(HandleCurButton, BM_SETSTYLE, BS_PUSHBUTTON, LPARAM(integer(true)));
  if HandleNewButton<>0 then
    LLCL_SendMessage(HandleNewButton, BM_SETSTYLE, BS_DEFPUSHBUTTON, LPARAM(integer(true)));
   TPCustomForm(ParentForm).HandleCurButton := HandleNewButton;
end;

// Last (i.e. highest) TabOrder value from all child controls (runtime)
function TWinControl.GetLastTabOrder(): integer;
var i: integer;
begin
  result := -1;
  for i := 0 to fControls.Count-1 do
    with TWinControl(fControls[i]) do
      if fTabOrder>result then result := fTabOrder;
end;

// After having modified TabOrder value for one child control (runtime)
procedure TWinControl.AfterModifyTabOrder(OldTabOrder: integer; NewTabOrder: integer; const AControl: TWinControl);
var i: integer;
begin
  if OldTabOrder=NewTabOrder then exit;   // Not necessary
  for i := 0 to fControls.Count-1 do
    if TWinControl(fControls[i])<>self then
      with TWinControl(fControls[i]) do
        if NewTabOrder>OldTabOrder then
          begin
            if (fTabOrder<=NewTabOrder) and (fTabOrder>OldTabOrder) then Dec(fTabOrder);
          end
        else
          begin
            if (fTabOrder>=NewTabOrder) and (fTabOrder<OldTabOrder) then Inc(fTabOrder);
          end;
end;

function TWinControl.ForWMKeyDownUpForm(var Msg: TWMKey; UpOrDown: integer): boolean;
var ParentForm: TCustomForm;
begin
  result := false;
  // First, OnKeyUp/Down for parent form if KeyPreview
  if GetVisualParentForm(TControl(ParentForm)) and ParentForm.KeyPreview then
    result := ParentForm.ForWMKeyDownUpForm(Msg, UpOrDown);
  // Then, OnKeyUp/Down for control
  if not result then
    if UpOrDown=0 then
      result := ForWMKeyDownUp(Msg, EOnKeyDown)
    else
      result := ForWMKeyDownUp(Msg, EOnKeyUp);
  if result and (fKeyboardMsg=1) and (ATType<>ATTCustomForm) then
    fKeyboardMsg := 2;   // Do not PostProcess
end;

function TWinControl.ForWMKeyDownUp(var Msg: TWMKey; EOnForKeyDownUp: TKeyEvent): boolean;
begin
  if Assigned(EOnForKeyDownUp) then
    EOnForKeyDownUp(self, Msg.CharCode, TShiftState(LLCLS_KeyDataToShiftState(Msg.KeyData)));
  result := (Msg.CharCode=0);
end;

function TWinControl.ForWMChar(var Msg: TWMKey; EOnForKeyPress: TKeyPressEvent): boolean;
var Key, KeySent: Char;
begin
  Key := LLCLS_CharCodeToChar(Msg.CharCode);   // no way to convert it, as char only is expected
  KeySent := Key;
  if Assigned(EOnForKeyPress) then
    begin
      EOnForKeyPress(self, KeySent);
      if KeySent<>Key then
        Msg.CharCode := Word(KeySent);
    end;
  result := (KeySent=#0);
  if result and (fKeyboardMsg=1) then
    fKeyboardMsg := 2;   // Do not PostProcess
end;

procedure TWinControl.ForControlCall(var Msg: TMessage; CControlIdent: integer; CATType: TAllControlTypes);
var i: integer;
begin
  for i := 0 to fNonVisuals.Count-1 do
    if (TNonVisualControl(fNonVisuals[i]).fControlIdent=CControlIdent) and
        (TNonVisualControl(fNonVisuals[i]).ATType=CATType) then
      begin
        TNonVisualControl(fNonVisuals[i]).ControlCall(Msg);
        break;
      end;
end;

function TWinControl.GetChildControl(Value: THandle): integer;
var i: integer;
begin
  result := -1;
  for i := 0 to fControls.Count-1 do
    with TWinControl(fControls[i]) do
      if Value=Handle then
        begin
          result := i;
          break;
        end;
end;

// Text size update (AutoSize)
procedure TWinControl.UpdTextSize(const Value: string);
var Size: TSize;
begin
  if ATType in [ATTButton, ATTCheckBox, ATTRadioButton, ATTGroupBox, ATTStaticText] then    // (ATTLabel omitted, because TLabel is not a TWinControl)
    if fAutoSize and LLCLS_GetTextSize(fHandle, Value, Font.Handle, Size) then
      begin
        AdjustTextSize(Size);
        SetBounds(fLeft, fTop, Size.cx, Size.cy);
      end;
end;

procedure TWinControl.DefaultHandler(var Message);
begin
  with TMessage(Message) do
    result := LLCL_CallWindowProc({$IFDEF FPC}TFNWndProc(fOldProc){$ELSE}fOldProc{$ENDIF}, fHandle, Msg, wParam, lParam);
end;

procedure TWinControl.Update;
begin
  // (No inherited)
  LLCL_UpdateWindow(fHandle);
end;

function TWinControl.ClientRect(): TRect;
begin
  LLCL_GetClientRect(fHandle, result);
end;

procedure TWinControl.Show;
begin
  inherited;
  if fHandle=0 then exit;   // (later when created at runtime)
  LLCL_ShowWindow(fHandle, fShowCommand);
  if Assigned(EOnShow) then
    EOnShow(self);
end;

procedure TWinControl.Hide;
begin
  inherited;
  if fHandle=0 then exit;   // (later when created at runtime)
  LLCL_ShowWindow(fHandle, SW_HIDE);
  if Focused() then
    NewFormFocus(tftNextGroup);
end;

// (Can be recursively called)
function TWinControl.CanFocus(): boolean;
begin
  result := Visible and Enabled;
  if result and (fParent<>nil) then
    if fParent.ATType<>ATTCustomForm then
      result := fParent.CanFocus();
end;

// (Not exactly LLCL_GetFocus()=fHandle)
function TWinControl.Focused(): boolean;
var ParentForm: TCustomForm;
begin
  if not GetVisualParentForm(TControl(ParentForm)) then
    result := false
  else
    result := (ParentForm.ActiveControl=self);
end;

procedure TWinControl.SetFocus();
begin
  if CanFocus() then
    begin
      LLCL_SetFocus(fHandle);
      UpdateFormFocus();
    end;
end;

procedure TWinControl.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
  inherited;
  if fHandle=0 then exit;   // (later when created at runtime)
  if ATType<>ATTCustomForm then     // Done inside Forms for them
    LLCL_MoveWindow(fHandle, ALeft, ATop, AWidth, AHeight, true);
end;

procedure TWinControl.BringToFront;
begin
  LLCL_SetForegroundWindow(fHandle);
end;

procedure TWinControl.WMLButtonDown(var Msg: TWMLButtonDown);
begin
  if ATType<>ATTGroupBox then // Because of WM_NCHitTest message modification
    inherited;
  // Updates Form focus control
  if not (ATType in TNonClickFocusCtrl) then  // (CanFocus is implicit)
    UpdateFormFocus();
  // Prepares click state for control
  fClicked := true;
  // OnMouseDown for control
  if Assigned(EOnMouseDown) then
    EOnMouseDown(self, mbLeft, TShiftState(LLCLS_KeysToShiftState(Msg.Keys)), Msg.XPos, Msg.YPos);
end;

procedure TWinControl.WMLButtonUp(var Msg: TWMLButtonUp);
begin
  if ATType<>ATTGroupBox then   // Because of WM_NCHitTest message modification
    inherited;
  // Note: Clicks for Windows button classes (Button, CheckBox, RadioButton and
  //   StaticText, but not GroupBox) are processed through BN_CLICKED messages
  // Click for control ?
  if fClicked and ((cardinal(Msg.XPos)<cardinal(fWidth)) and (cardinal(Msg.YPos)<cardinal(fHeight))) then
    ClickCall((not (ATType in TNonClickFocusCtrl)), false);
  // No more in click state
  fClicked := false;
  // OnMouseUp for control
  if Assigned(EOnMouseUp) then
    EOnMouseUp(self, mbLeft, TShiftState(LLCLS_KeysToShiftState(Msg.Keys)), Msg.XPos, Msg.YPos);
end;

procedure TWinControl.WMRButtonDown(var Msg: TWMRButtonDown);
begin
  inherited;
  // OnMouseDown for control
  if Assigned(EOnMouseDown) then
    EOnMouseDown(self, mbRight, TShiftState(LLCLS_KeysToShiftState(Msg.Keys)), Msg.XPos, Msg.YPos);
end;

procedure TWinControl.WMRButtonUp(var Msg: TWMRButtonUp);
begin
  inherited;
  // OnMouseUp only for control (no click for right button)
  if Assigned(EOnMouseUp) then
    EOnMouseUp(self, mbRight, TShiftState(LLCLS_KeysToShiftState(Msg.Keys)), Msg.XPos, Msg.YPos);
end;

procedure TWinControl.WMLDblClick(var Msg: TWMLButtonDblClk);
begin
  if ATType<>ATTGroupBox then // Because of WM_NCHitTest message modification
    inherited;
  // Windows button classes don't have double click, but 2 normal clicks
  fClicked := (ATType in [ATTButton, ATTCheckBox, ATTRadioButton]);
  // OnMouseDown for control added
  //    and OnDblClick processed, except for buttons
  //    (Order different for Delphi and FPC)
{$IFDEF FPC}
  if Assigned(EOnMouseDown) then
    EOnMouseDown(self, mbLeft, TShiftState(LLCLS_KeysToShiftState(Msg.Keys)) + [ssDouble], Msg.XPos, Msg.YPos);
  if not (ATType in [ATTButton]) then
    if Assigned(EOnDblClick) then
      EOnDblClick(self);
{$ELSE FPC}
  if not (ATType in [ATTButton]) then
    if Assigned(EOnDblClick) then
      EOnDblClick(self);
  if Assigned(EOnMouseDown) then
    EOnMouseDown(self, mbLeft, TShiftState(LLCLS_KeysToShiftState(Msg.Keys)) + [ssDouble], Msg.XPos, Msg.YPos);
{$ENDIF}
end;

procedure TWinControl.WMRDblClick(var Msg: TWMRButtonDblClk);
begin
  inherited;
  // Replaced by OnMouseDown for control (no double click for right button)
  if Assigned(EOnMouseDown) then
    EOnMouseDown(self, mbRight, TShiftState(LLCLS_KeysToShiftState(Msg.Keys)) + [ssDouble], Msg.XPos, Msg.YPos);
end;

procedure TWinControl.WMChar(var Msg: TWMChar);
var ParentForm: TCustomForm;
var TabFocusType: TNewFocusType;
var KeyProcess: TKeyProcess;
begin
  // Only for those concerned
  if Msg.CharCode<>VK_TAB then
    begin
      // First, OnKeyPress for parent form if KeyPreview
      if GetVisualParentForm(TControl(ParentForm)) and ParentForm.KeyPreview then
        if ForWMChar(Msg, ParentForm.EOnKeyPress) then
          exit;
      // Then, OnKeyPress for control
      if ForWMChar(Msg, EOnKeyPress) then
        exit;
    end;
  // Special keys processing type (tkStandard by default)
  KeyProcess := SpecialKeyProcess(Msg.CharCode);
  // Skip ?
  if KeyProcess=tkSkip then
    begin
      fKeyboardMsg := 2;   // Do not PostProcess
      exit;
    end;
  // (No WMChar message for arrow keys. Corrresponding scan
  //   codes 37/38/39/40 are for "% & ' (" characters)
  // Standard keys forced
  if (not (Msg.CharCode in [VK_RETURN, VK_ESCAPE, VK_TAB])) or
    (KeyProcess=tkForceStandard) then
    begin
      if fKeyboardMsg<>1 then
        inherited;
    end
  else
    // Special processing for Enter (Default), Escape (Cancel) or Tabulation
    begin
      // Enter for some specific controls (no enter=default)
      if (Msg.CharCode=VK_RETURN) and (KeyProcess=tkNoEnterDef) then
        begin
          ClickCall(false, false);
          if fKeyboardMsg<>1 then
            inherited;
          exit;
        end;
      case Msg.CharCode of
      VK_RETURN, VK_ESCAPE:   // Enter (default), Escape (cancel)
        // Form key processing (parent form already searched before)
        // (Not standard: Enter(default), Escape (cancel)
        //   are processed after WM_KEYUP in LCL)
        if (ParentForm<>nil) and (ParentForm<>self) then
          if not ParentForm.DefCanButton(Msg.CharCode) then
            if not ((Msg.CharCode=VK_RETURN) and (KeyProcess=tkSkipNonEnterDef)) then
              if fKeyboardMsg<>1 then
                inherited;
      else
        begin
          // UI indicators...
          ClearUI(UITYPE_FOCUS);
          case Msg.CharCode of
          VK_TAB:                 // Tabulation
            begin
              if ssShift in TShiftState(LLCLS_KeyDataToShiftState(Msg.KeyData)) then
                TabFocusType := tftPrevGroup    // Shift tabulation (previous group control)
              else
                TabFocusType := tftNextGroup;   // Tabulation (next group control)
              NewFormFocus(TabFocusType);
            end;
          end;
        end;
      end;
    end;
end;

procedure TWinControl.WMKeyDown(var Msg: TWMKeyDown);
begin
  // Arrow keys - before (no WMChar message for them)
  if (Msg.CharCode in [VK_LEFT, VK_UP, VK_RIGHT, VK_DOWN])
    and (not fArrowKeysInternal) then // for controls not processing arrow keys internally
    // UI indicators...
    ClearUI(UITYPE_FOCUS);
  // ComboBox may receive it twice, so skip one
  if not ((ATType=ATTComboBox) and (fKeyboardMsg=0)) then
    if ForWMKeyDownUpForm(Msg, 0) then    // 0=Down
      exit;
  if fKeyboardMsg<>1 then
    inherited;
  // Arrow keys - after (tested again because Msg.Charcode may have been changed in user's code)
  if (Msg.CharCode in [VK_LEFT, VK_UP, VK_RIGHT, VK_DOWN])
    and (not fArrowKeysInternal) then // for controls not processing arrow keys internally
    case Msg.CharCode of
    VK_LEFT, VK_UP:         // Previous control
      NewFormFocus(tftPrev);
    VK_RIGHT, VK_DOWN:      // Next control
      NewFormFocus(tftNext);
    end;
end;

procedure TWinControl.WMKeyUp(var Msg: TWMKeyUp);
begin
  if ForWMKeyDownUpForm(Msg, 1) then    // 1=Up
    exit;
  if fKeyboardMsg<>1 then
    inherited;
end;

procedure TWinControl.WMSysKeyDown(var Msg: TWMSysKeyDown);
begin
  // UI indicators...
  if ssAlt in TShiftState(LLCLS_KeyDataToShiftState(Msg.KeyData)) then
    ClearUI(UITYPE_ACCELERATOR);
  if ForWMKeyDownUpForm(Msg, 0) then    // 0=Down
    exit;
  if fKeyboardMsg<>1 then
    inherited;
end;

procedure TWinControl.WMSysKeyUp(var Msg: TWMSysKeyUp);
begin
  if ForWMKeyDownUpForm(Msg, 1) then    // 1=Up
    exit;
  if fKeyboardMsg<>1 then
    inherited;
end;

procedure TWinControl.WMSysChar(var Msg: TWMSysChar);
var ParentForm: TCustomForm;
begin
  // Accelerator for the form ?
  if GetVisualParentForm(TControl(ParentForm)) then
    if TWinControl(ParentForm).FormAccelControl(Msg) then
      begin
        if fKeyboardMsg=1 then
          fKeyboardMsg := 2;   // Do not PostProcess
        exit;
      end;
  if fKeyboardMsg<>1 then
    inherited;
end;

procedure TWinControl.WMPaint(var Msg: TWMPaint);
var PSForm: TPaintStruct;
{$ifdef LLCL_OPT_DOUBLEBUFF}
var hSaveHDC: HDC;
var hMemBMP, hSaveObj: HGDIOBJ;
var FormRect: TRECT;
{$endif}
var i: integer;
begin
  if (fGraphics.Count>0) or (ATType=ATTCustomForm) then   // Only if graphical controls are present, or possible OnPaint event
    with Canvas do
      begin
{$ifdef LLCL_OPT_DOUBLEBUFF}
        hSaveHDC := 0; hMemBMP := 0; hSaveObj := 0;       // (to avoid compilation warning)
{$endif}
        if ATType=ATTCustomForm then
          begin
            Handle := LLCL_BeginPaint(self.fHandle, PSForm);
{$ifdef LLCL_OPT_DOUBLEBUFF}
            if fDoubleBuffered then
              begin
                FormRect := ClientRect();
                hSaveHDC := Handle;
                Handle := LLCL_CreateCompatibleDC(hSaveHDC);
                hMemBMP := LLCL_CreateCompatibleBitmap(hSaveHDC, FormRect.Right - FormRect.Left, FormRect.Bottom - FormRect.Top);
                hSaveObj := LLCL_SelectObject(Handle, hMemBMP);
              end;
{$endif}
            LLCL_FillRect(Handle, PSForm.rcPaint, Brush.Handle);  // (See WM_ERASEBKGND)
          end
        else
          Handle := LLCL_GetDC(self.fHandle);     // Pb1 for GroupBox -> Flickering
        for i := 0 to fGraphics.Count-1 do
          with TGraphicControl(fGraphics[i]) do
            CheckCallPaint(Handle);
        if ATType=ATTCustomForm then
          begin
            TPCustomForm(self).CallOnPaint;       // Currently, only Forms can have this property
{$ifdef LLCL_OPT_DOUBLEBUFF}
            if fDoubleBuffered then
              begin
                LLCL_BitBlt(hSaveHDC, PSForm.rcPaint.Left, PSForm.rcPaint.Top, PSForm.rcPaint.Right - PSForm.rcPaint.Left, PSForm.rcPaint.Bottom - PSForm.rcPaint.Top, Handle, PSForm.rcPaint.Left, PSForm.rcPaint.Top, SRCCOPY);
                LLCL_SelectObject(Handle, hSaveObj);
                LLCL_DeleteObject(hMemBMP);
                LLCL_DeleteDC(Handle);
              end;
{$endif}
            LLCL_EndPaint(self.fHandle, PSForm);
            // (No inherited)
            exit;
          end
        else
          LLCL_ReleaseDC(self.fHandle, Handle);
      end;
  inherited;
end;

procedure TWinControl.WMDestroy(var Msg: TWMDestroy);
begin
  inherited;
  fHandle := 0;
end;

procedure TWinControl.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
  UpdButtonHighlight();
end;

procedure TWinControl.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var CtlOrParent: TWinControl;
begin
  // Modified for some TWinControls
  if ATType=ATTCustomForm then
    Msg.Result := 1                   // (Done inside WM_PAINT)
  else
    if (ATType=ATTGroupBox) or ((ATType=ATTComboBox) and (TComboBox(self).Style=csSimple)) then
      begin
        if (ATType=ATTComboBox) then
          CtlOrParent := fParent      // (fParent<>nil)
        else
          CtlOrParent := self;
        LLCL_FillRect(Msg.DC, ClientRect(), CtlOrParent.Canvas.Brush.Handle);
        Msg.Result := 1;
      end
    else
      inherited;
end;

procedure TWinControl.WMColorStatic(var Msg: TWMCtlColorStatic);
begin
  if not ColorCall(Msg) then
    inherited;
end;

procedure TWinControl.WMColorEdit(var Msg: TWMCtlColorEdit);
begin
  if not ColorCall(Msg) then
    inherited;
end;

procedure TWinControl.WMColorListBox(var Msg: TWMCtlColorListBox);
begin
  if not ColorCall(Msg) then
    inherited;
end;

procedure TWinControl.WMColorButton(var Msg: TWMCtlColorBtn);
begin
  if not ColorCall(Msg) then
    inherited;
end;

procedure TWinControl.WMTimer(var Msg: TWMTimer);
begin
  inherited;
  ForControlCall(TMessage(Msg), Msg.TimerID, ATTTimer);
end;

procedure TWinControl.WMTray(var Msg: TMessage);
begin
  inherited;
  ForControlCall(TMessage(Msg), Msg.wParam, ATTTrayIcon);
end;

procedure TWinControl.WMCommand(var Msg: TWMCommand);
var ChildIndex: integer;
begin
  inherited;
  if Msg.Ctl<>0 then
    begin
      ChildIndex := GetChildControl(Msg.Ctl);
      if ChildIndex>=0 then
        with TWinControl(fControls[ChildIndex]) do
          case Msg.NotifyCode of
          BN_CLICKED:
            begin
              ClickCall(false, false);
              // No more in click state
              fClicked := false;
            end;
          else
            ComponentNotif(TMessage(Msg));
          end;
    end;
end;

procedure TWinControl.WMSize(var Msg: TWMSize);
begin
  inherited;
  // Currently unused for other controls, because
  //   only the client area is concerned
  if ATType=ATTCustomForm then
    begin
      fWidth  := Msg.Width;
      fHeight := Msg.Height;
    end
  else
    // Forces redraw
    if ATType=ATTStaticText then
      Caption := fCaption;
end;

procedure TWinControl.WMMove(var Msg: TWMMove);
begin
  inherited;
  // Currently unused for other controls, because
  //   only the client area is concerned
  if ATType=ATTCustomForm then
    begin
      fLeft := Msg.XPos;
      fTop  := Msg.YPos;
    end;
end;

procedure TWinControl.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  // To allow GroupBox to receive mouse messages
  if ATType=ATTGroupBox then
    if Msg.Result=HTTRANSPARENT then Msg.Result := HTCLIENT;
end;

procedure TWinControl.WMMouseMove(var Msg: TWMMouseMove);
begin
  if ATType<>ATTGroupBox then // Because of WM_NCHitTest message modification
    inherited;
end;

procedure TWinControl.WMHScroll(var Msg: TWMHScroll);
begin
  inherited;
  ForwardChildMsg(TMessage(Msg), Msg.ScrollBar);
end;

procedure TWinControl.WMVScroll(var Msg: TWMVScroll);
begin
  inherited;
  ForwardChildMsg(TMessage(Msg), Msg.ScrollBar);
end;

procedure TWinControl.WMNotify(var Msg: TWMNotify);
begin
  if ForwardChildMsg(TMessage(Msg), Msg.NMHdr^.hwndFrom) then
    inherited;
end;

{ TMouse }

function TMouse.GetCursorPos(): TPoint;
begin
  LLCL_GetCursorPos(result);
end;

procedure TMouse.SetCursorPos(ACursPos: TPoint);
begin
  LLCL_SetCursorPos(ACursPos.X, ACursPos.Y)
end;

//------------------------------------------------------------------------------

initialization
  Mouse := TMouse.Create;

finalization
  Mouse.Free;

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
