unit StdCtrls;

{
         LLCL - FPC/Lazarus Light LCL
               based upon
         LVCL - Very LIGHT VCL
         ----------------------------

    This file is a part of the Light LCL (LLCL).

    This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

    This Source Code Form is “Incompatible With Secondary Licenses”,
  as defined by the Mozilla Public License, v. 2.0.

  Copyright (c) 2015 ChrisF

  Based upon the Very LIGHT VCL (LVCL):
  Copyright (c) 2008 Arnaud Bouchez - http://bouchez.info
  Portions Copyright (c) 2001 Paul Toth - http://tothpaul.free.fr

   Version 1.00:
    * TStaticText implemented
    * TMemo: ScrollBars and WordWrap (design time only), WantReturns and WantTabs added
    * TMemo: very limited support for Lines[] properties added
    * TEdit, TMemo, TStaticText, TLabel: 'Alignment' property (design time only) added
    * TEdit: OnChange added
    * TLabel: Show and Hide added (see TGraphicControl)
    * TLabel: WordWrap added (design time only)
    * TButton: Default and Cancel added (see Controls.pas)
    * TRadioButton: auto switch (see Controls.pas)
    * TComboBox: SelectAll added
    * TComboBox: OnChange extended (keyboard character)
    * TEdit, TMemo, TComboBox: Ctrl+A support added (not standard for old versions of Delphi)
    * TLabel, TButton, TCheckBox, TRadioButton, TGroupBox, TStaticText: AutoSize added (see Controls.pas)
}

// Original notes from LVCL

{
         LVCL - Very LIGHT VCL
         ----------------------------

   Tiny replacement for the standard VCL StdCtrls.pas
   Just put the LVCL directory in your Project/Options/Path/SearchPath
   and your .EXE will shrink from 300KB to 30KB

   Notes:
   - implements TButton+TCheckBox+TEdit+TLabel+TMemo
   - for TMemo: use global Text property, as there's no Lines[] property;
     don't set anything in Lines property in IDE
   - compatible with the standard .DFM files.
   - only use existing properties in your DFM, otherwise you'll get error on startup
     (no Anchor, e.g.)

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

  * TCheckBox: new properties: 'Alignment', 'State', 'AllowGrayed' (3-states style)
  * TRadioButton (auto-switching and groups not implemented)
  * TGroupBox
  * TListBox, TComboBox (and parent TCustomBox)
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
  Classes, Controls;

type
{$ifdef  LLCL_OPT_STDLABEL}
  TLabel = class(TGraphicControl)
  private
    fAlignment: TAlignment;
    fWordWrap: boolean;
    procedure PaintText(AddFlags: cardinal; var R: TRect);
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    procedure ControlInit(RuntimeCreate: boolean); override;
    procedure SetColor(Value: integer); override;
    procedure SetCaption(const Value: string); override;
    procedure Paint; override;
    procedure UpdateTextSize();
  public
    constructor Create(AOwner: TComponent); override;
  end;
{$endif}

  TButton = class(TWinControl)
  private
    fDefault: boolean;
    fCancel: boolean;
  protected
    procedure CreateHandle; override;
    procedure CreateParams(var Params : TCreateParams); override;
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    function  SpecialKeyProcess(var CharCode: Word): TKeyProcess; override;
    procedure AdjustTextSize(var Size: TSize); override;
  public
    constructor Create(AOwner: TComponent); override;
    property  Default: boolean read fDefault write fDefault;
    property  Cancel: boolean read fCancel write fCancel;
  end;

  TEdit = class(TWinControl)
  private
    fPassWordChar: char;
    fReadOnly: boolean;
    fAlignment: TAlignment;
    fCreateFlags: cardinal;
    fOnChangeOK: boolean;
    EOnChange: TNotifyEvent;
    procedure SetReadOnly(Value: boolean);
  protected
    procedure CreateHandle; override;
    procedure CreateParams(var Params : TCreateParams); override;
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    function  GetText(): string;
    procedure SetText(const Value: string);
    procedure ComponentNotif(var Msg: TMessage); override;
    function  SpecialKeyProcess(var CharCode: Word): TKeyProcess; override;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SelectAll;
    property  Text: string read GetText write SetText;
    property  ReadOnly: boolean read fReadOnly write SetReadOnly;
    property  InitialAlignment: TAlignment read fAlignment write fAlignment;  // (For Delphi)
    property  OnChange: TNotifyEvent read EOnChange write EOnChange;
  end;

  TMemo = class;

  TMemoLines = class(TPersistent)   // For a limited support of Memo.Lines
  protected                         //
    fMemo: TMemo;                   //   Currently, only: Add, Clear methods
    fStrings: TStringList;          //     and: Strings property when loaded
    procedure SetStrings(StringList: TStrings);
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
  public
    constructor Create(Memo: TMemo);
    destructor  Destroy; override;
    function  Add(const S: string): integer;
    procedure Clear;
    property  Strings: TStrings read fStrings write SetStrings;
  end;

  TScrollStyle = (ssNone, ssHorizontal, ssVertical, ssBoth);

  TMemo = class(TEdit)
  protected
    fScrollBars: TScrollStyle;
    fWordWrap: boolean;
    fLines: TMemoLines;
    fWantReturns: boolean;
    fWantTabs: boolean;
    procedure CreateHandle; override;
    procedure CreateParams(var Params : TCreateParams); override;
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    function  SubProperty(const SubPropName: string): TPersistent; override;
    function  SpecialKeyProcess(var CharCode: Word): TKeyProcess; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Clear;
    property  Lines: TMemoLines read fLines;
    property  WantReturns: boolean read fWantReturns write fWantReturns;
    property  WantTabs: boolean read fWantTabs write fWantTabs;
  end;

  TCheckBoxState = (cbUnchecked, cbChecked, cbGrayed);

  TCheckBox = class(TWinControl)
  private
    fState: TCheckBoxState;
    fAllowGrayed: boolean;
    fAlignment: TAlignment;     // default = taRightJustify  (taCenter not possible)
    fCreateFlags: cardinal;
    procedure SetChecked(const Value: boolean);
    function  GetChecked(): boolean;
    procedure SetState(const Value: TCheckBoxState);
    procedure SetAllowGrayed(Value: boolean);
    function  GetState(): TCheckBoxState;
  protected
    procedure CreateHandle; override;
    procedure CreateParams(var Params : TCreateParams); override;
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    procedure ComponentNotif(var Msg: TMessage); override;
    procedure AdjustTextSize(var Size: TSize); override;
  public
    constructor Create(AOwner: TComponent); override;
    property  Checked: boolean read GetChecked write SetChecked;
    property  State: TCheckBoxState read GetState write SetState;
    property  AllowGrayed: boolean read fAllowGrayed write SetAllowGrayed;
    property  InitialAlignment: TAlignment read fAlignment write fAlignment;  // (For FPC)
  end;

  TRadioButton = class(TCheckBox) //should be vice versa
  protected
    procedure CreateParams(var Params : TCreateParams); override;
    function  SpecialKeyProcess(var CharCode: Word): TKeyProcess; override;
    function  GetSpecTabStop(): boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TGroupBox = class(TWinControl)
  protected
    procedure CreateHandle; override;
    procedure CreateParams(var Params : TCreateParams); override;
    function  GetSpecTabStop(): boolean; override;
    procedure AdjustTextSize(var Size: TSize); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TCustomBox = class;

  TBoxStrings = class(TPersistent)
  protected
    fBox: TCustomBox;
    fStrings: TStringList;
    procedure SetStrings(StringList: TStrings);
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    function  GetItem(n: integer): string;
  public
    constructor Create(Box: TCustomBox);
    destructor  Destroy; override;
    function  Add(const S: string): integer;
    procedure Clear;
    property  Strings: TStrings read fStrings write SetStrings;
    property  Items[n: integer]: string read GetItem; default;
  end;

  TCustomBox = class(TWinControl)
  private
    fCreateFlags:  cardinal;
  protected
    fAddLineMsg:   cardinal;
    fResetMsg:     cardinal;
    fGetIndexMsg:  cardinal;
    fSetIndexMsg:  cardinal;
    fGetCountMsg:  cardinal;
    fDropDownHeight: integer;
    fItems: TBoxStrings;
    fItemIndex: integer;
    fSorted: boolean;
    function  GetItems(): TStrings;
    procedure SetItems(AItems: TStrings);
    function  GetCount(): integer; virtual;
    procedure SetItemIndex(Value: integer); virtual;
    procedure CreateHandle; override;
    procedure CreateParams(var Params : TCreateParams); override;
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    function  SubProperty(const SubPropName: string): TPersistent; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Clear;
    property  Items: TBoxStrings read fItems;
    property  ItemCount: integer read GetCount;
    property  ItemIndex: integer read fItemIndex write SetItemIndex;
    property  ItemStrings: TStrings read GetItems write SetItems;
  end;

  TComboBoxStyle =
    (csDropDown, csSimple, csDropDownList, csOwnerDrawFixed, csOwnerDrawVariable);

  TComboBox = class(TCustomBox)
  private
    fStyle: TComboBoxStyle;
    fEditCBWndProc,
    fListCBWndProc: TFNWndProc;
    fhWndItem,              // Edit sub control
    fhWndList: THandle;     // Listbox sub control
    fListLastKeyDown: word; // Last key down received for listbox (used only for csDropDownList case)
    fOnChangeOK: boolean;
    EOnChange: TNotifyEvent;
    function  GetDroppedDown(): boolean;
    procedure SetDroppedDown(Value: boolean);
    function  IsListDroppedDown(): boolean;
    procedure CallOnChange;
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    procedure CreateHandle; override;
    procedure CreateParams(var Params : TCreateParams); override;
    function  GetText(): string;
    procedure SetText(const Value: string);
    function  ColorForSubCont(SubContMsg: integer; SubConthWnd: THandle): boolean; override;
    procedure ComponentNotif(var Msg: TMessage); override;
    function  SpecialKeyProcess(var CharCode: Word): TKeyProcess; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure SelectAll;
    property  Text: string read GetText write SetText;
    property  DroppedDown: boolean read GetDroppedDown write SetDroppedDown;
    property  OnChange: TNotifyEvent read EOnChange write EOnChange;
  end;

  TListBox = class(TCustomBox)
  protected
    procedure CreateParams(var Params : TCreateParams); override;
    procedure ComponentNotif(var Msg: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TStaticBorderStyle =
    (sbsNone, sbsSingle, sbsSunken);

  TStaticText = class(TWinControl)
  private
    fBorderStyle: TStaticBorderStyle;
    fAlignment: TAlignment;
  protected
    procedure CreateParams(var Params : TCreateParams); override;
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    procedure AdjustTextSize(var Size: TSize); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{$ifndef  LLCL_OPT_STDLABEL}
  TLabel = class(TStaticText);
{$endif}

//------------------------------------------------------------------------------

implementation

uses
  Forms, Graphics;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

type
  TPCustomForm = class(TCustomForm);  // To access to protected part
  TPCanvas = class(TCanvas);          // To access to protected part
  TPComboBox = class(TComboBox);      // To access to protected part

const
  BUTTON_CTRLCLASS    = 'BUTTON';
  EDIT_CTRLCLASS      = 'EDIT';
  STATIC_CTRLCLASS    = 'STATIC';
  COMBOBOX_CTRLCLASS  = 'COMBOBOX';
  LISTBOX_CTRLCLASS   = 'LISTBOX';

//------------------------------------------------------------------------------

{$IFDEF FPC}
// Dummy function to avoid compilation hint (LMessages not used)
function LMessages_Dummy(const Msg: TLMCommand): boolean;
begin
  result := false;
end;
{$ENDIF FPC}

{ TButton }

constructor TButton.Create(AOwner:TComponent);
begin
  inherited;
  ATType := ATTButton;
  Transparent := true;  // do not use color
end;

procedure TButton.CreateHandle;
var ParentForm: TCustomForm;
begin
  inherited;
  if fDefault then
    if GetVisualParentForm(TControl(ParentForm)) then
      TPCustomForm(ParentForm).HandleDefButton := Handle;
end;

procedure TButton.CreateParams(var Params : TCreateParams);
begin
  inherited;
  with Params do
    begin
      // (BS_DEFPUSHBUTTON style for fDefault buttons is processed within
      //  TWinControl.WMSetFocus - See TWinControl.UpdButtonHighlight)
      WinClassName := BUTTON_CTRLCLASS;
    end;
end;

procedure TButton.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..1] of PChar = (
    'Default', 'Cancel');
begin
  case StringIndex(PropName, Properties) of
    0 : fDefault := Reader.BooleanProperty;
    1 : fCancel := Reader.BooleanProperty;
    else inherited;
  end;
end;

function TButton.SpecialKeyProcess(var CharCode: Word): TKeyProcess;
begin
  result := inherited SpecialKeyProcess(CharCode);  // tkStandard by default
  // Note: Clicks(=VK_SPACES) for windows buttons classes (Buttons, CheckBoxes,
  //       RadioButtons) are processed through BN_CLICKED messages
  if CharCode = VK_RETURN then
    result := tkNoEnterDef;
end;

procedure TButton.AdjustTextSize(var Size: TSize);
begin
  Inc(Size.cx, 26); Inc(Size.cy, 10);
end;

{ TEdit }

constructor TEdit.Create(AOwner:TComponent);
begin
  inherited;
  ATType := ATTEdit;
  Color := LLCL_GetSysColor(integer(clWindow) and $FF);
  ArrowKeysInternal := true;    // Both for Edit and Memo
end;

procedure TEdit.CreateHandle;
begin
  inherited;
  fOnChangeOK := true;    // OnChange is now OK for being activated
  if fReadOnly then
    SetReadOnly(fReadOnly);
end;

procedure TEdit.CreateParams(var Params : TCreateParams);
const EAlignStyle: array[TAlignment] of cardinal =(ES_LEFT , ES_RIGHT, ES_CENTER);
begin
  inherited;
  if fCreateFlags=0 then begin
    fCreateFlags := ES_AUTOHSCROLL;
    if fPassWordChar='*' then
      fCreateFlags := fCreateFlags or ES_PASSWORD;
  end;
  fCreateFlags := fCreateFlags or EAlignStyle[fAlignment];
  with Params do
    begin
      Style := Style or fCreateFlags;
      ExStyle := WS_EX_CLIENTEDGE;
      WinClassName := EDIT_CTRLCLASS;
    end;
end;

// WM_COMMAND message coming from form
procedure TEdit.ComponentNotif(var Msg: TMessage);
begin
  inherited;
  case TWMCommand(Msg).NotifyCode of
  EN_CHANGE:
    if fOnChangeOK and Assigned(EOnChange) then
      EOnChange(self);
  end;
end;

function TEdit.SpecialKeyProcess(var CharCode: Word): TKeyProcess;
begin
  result := inherited SpecialKeyProcess(CharCode);  // tkStandard by default
  // Ctrl+A = Select All
  if CharCode=cardinal(^A) then
    begin
      SelectAll();
      result := tkSkip;
    end;
end;

procedure TEdit.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
  if ATType=ATTEdit then    // Not for Memo
    if not Focused() then
      SelectAll();
end;

function TEdit.GetText(): string;
begin
  result := LLCLS_SendMessageGetText(Handle);
end;

procedure TEdit.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..3] of PChar = (
    'OnChange', 'PasswordChar', 'ReadOnly', 'Alignment');
var Tmp: string;
begin
  case StringIndex(PropName, Properties) of
    0 : TMethod(EOnChange) := FindMethod(Reader);
    1 : begin
          Tmp := Reader.StringProperty;
          if Tmp<>'' then
            fPassWordChar := Tmp[1];
        end;
    2 : fReadOnly := Reader.BooleanProperty;
    3 : Reader.IdentProperty(fAlignment, TypeInfo(TAlignment));
    else inherited;
  end;
end;

procedure TEdit.SelectAll;
begin
  LLCL_SendMessage(Handle, EM_SETSEL, 0, LPARAM(-1));
end;

procedure TEdit.SetReadOnly(Value: boolean);
begin
  LLCL_SendMessage(Handle, EM_SETREADONLY, WPARAM(Ord(Value)), 0);
  fReadOnly := Value;
end;

procedure TEdit.SetText(const Value: string);
begin
  Caption := Value;
end;

{ TMemoLines }

constructor TMemoLines.Create(Memo: TMemo);
begin
  inherited Create;
  fStrings := TStringList.Create;
  fMemo := Memo;
end;

procedure TMemoLines.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..0] of PChar = ('Strings');
begin
  case StringIndex(PropName, Properties) of
    0 : Reader.ReadStrings(fStrings);
    else inherited;
  end;
end;

procedure TMemoLines.SetStrings(StringList: TStrings);
begin
  if StringList = fStrings then exit;
  fStrings := StringList;
end;

function TMemoLines.Add(const S: string): integer;
var len: integer;
var SS: string;
begin
  len := LLCL_SendMessage(fMemo.Handle, WM_GETTEXTLENGTH, 0, 0);
  LLCL_SendMessage(fMemo.Handle, EM_SETSEL, WPARAM(len), LPARAM(len));
  SS := S+sLineBreak;
  LLCLS_SendMessageSetText(fMemo.Handle, EM_REPLACESEL, SS);
  result := fStrings.Add(S);
end;

procedure TMemoLines.Clear;
begin
  LLCL_SendMessage(fMemo.Handle, WM_SETTEXT, 0, 0);     // LLCLS_SendMessageSetText not used here
  fStrings.Clear;
end;

destructor TMemoLines.Destroy;
begin
  fStrings.Free;
  inherited;
end;

{ TMemo }

constructor TMemo.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTMemo;
  fWordWrap := true;
  fLines := TMemoLines.Create(self);
  fWantReturns := true;
end;

procedure TMemo.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..3] of PChar = (
    'ScrollBars', 'WordWrap', 'WantReturns', 'WantTabs');
begin
  case StringIndex(PropName, Properties) of
    0 : Reader.IdentProperty(fScrollBars, TypeInfo(TScrollStyle));
    1 : fWordWrap := Reader.BooleanProperty;
    2 : fWantReturns := Reader.BooleanProperty;
    3 : fWantTabs := Reader.BooleanProperty;
    else inherited;
  end;
end;

procedure TMemo.CreateHandle;
begin
  inherited;
  SetText(fLines.Strings.Text);
end;

procedure TMemo.CreateParams(var Params : TCreateParams);
begin
  fCreateFlags := ES_MULTILINE or ES_WANTRETURN;
  case fScrollBars of
  ssHorizontal: fCreateFlags := fCreateFlags or WS_HSCROLL;
  ssVertical:   fCreateFlags := fCreateFlags or WS_VSCROLL;
  ssBoth:       fCreateFlags := fCreateFlags or WS_HSCROLL or WS_VSCROLL;
  end;
  if not fWordWrap then
    fCreateFlags := fCreateFlags or ES_AUTOVSCROLL;
  inherited;
end;

function TMemo.SubProperty(const SubPropName: string): TPersistent;
const SubProperties: array[0..0] of PChar = ('Lines');
begin
  case StringIndex(SubPropName, SubProperties) of
   0 : result := fLines;
   else result := inherited SubProperty(SubPropName);
  end;
end;

function TMemo.SpecialKeyProcess(var CharCode: Word): TKeyProcess;
begin
  result := inherited SpecialKeyProcess(CharCode);  // tkStandard by default, and TEdit result then
  if CharCode=VK_RETURN then
    if fWantReturns then
      result := tkForceStandard
    else
      result := tkSkipNonEnterDef
  else
    if CharCode=VK_TAB then
      if fWantTabs then
        result := tkForceStandard;
end;

procedure TMemo.Clear;
begin
  fLines.Clear;
end;

destructor TMemo.Destroy;
begin
  fLines.Free;
  inherited;
end;

{ TCheckBox }

constructor TCheckBox.Create(AOwner:TComponent);
begin
  inherited;
  ATType := ATTCheckBox;
  fAlignment := taRightJustify;
  AutoSize := true;
end;

procedure TCheckBox.CreateHandle;
begin
  inherited;
  State := fState;
end;

const
  CBAlignStyle: array[TAlignment] of cardinal = (BS_LEFTTEXT, 0, 0);
  CBGrayStyle: array[boolean] of cardinal = (BS_AUTOCHECKBOX, BS_AUTO3STATE);

procedure TCheckBox.CreateParams(var Params : TCreateParams);
begin
  if fCreateFlags=0 then
    fCreateFlags := CBGrayStyle[fAllowGrayed] or CBAlignStyle[fAlignment];
  inherited;
  with Params do
    begin
      Style := Style or fCreateFlags;
      WinClassName := BUTTON_CTRLCLASS;
    end;
end;

function TCheckBox.GetChecked(): boolean;
begin
  result := boolean(GetState());
end;

function TCheckBox.GetState(): TCheckBoxState;
begin
  result := TCheckBoxState(LLCL_SendMessage(Handle, BM_GETCHECK, 0, 0));
end;

procedure TCheckBox.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..3] of PChar = (
    'Checked', 'Alignment', 'State', 'AllowGrayed');
var b: boolean;
begin
  case StringIndex(PropName, Properties) of
    0 : begin
          b := Reader.BooleanProperty;
          if fState<>cbGrayed then
            fState := TCheckBoxState(b);
        end;
    1 : Reader.IdentProperty(fAlignment, TypeInfo(TAlignment));
    2 : Reader.IdentProperty(fState, TypeInfo(TCheckBoxState));
    3 : fAllowGrayed := Reader.BooleanProperty;
    else inherited;
  end;
end;

// Used internally to force check/uncheck (Null Msg)
procedure TCheckBox.ComponentNotif(var Msg: TMessage);
begin
  if Msg.Msg=0 then
    Checked := (not Checked)
  else
    inherited;
end;

procedure TCheckBox.AdjustTextSize(var Size: TSize);
var minHeight: integer;
begin
  Inc(Size.cx, LLCL_GetSystemMetrics(SM_CXMENUCHECK)+5); Inc(Size.cy, 4);
  minHeight := LLCL_GetSystemMetrics(SM_CYMENUCHECK);
  if Size.cy<minHeight then
    Size.cy := minHeight;
end;

procedure TCheckBox.SetChecked(const Value: boolean);
begin
  SetState(TCheckBoxState(Value));
end;

procedure TCheckBox.SetState(const Value: TCheckBoxState);
var b: boolean;
begin
  b := (Value = cbGrayed) and (not fAllowGrayed);
  if b then SetAllowGrayed(true);   // need to set Grayed state
  LLCL_SendMessage(Handle, BM_SETCHECK, WPARAM(NativeUInt(Value)), 0);
  if b then SetAllowGrayed(false);  // style switches back, but state persists!
end;

procedure TCheckBox.SetAllowGrayed(Value: boolean);
var i: NativeUInt;
const StyleMask = $F;
begin
  if fAllowGrayed = Value then exit;
  fAllowGrayed := Value;
  i := LLCL_GetWindowLongPtr(Handle, GWL_STYLE);
  // if (i and StyleMask)<>GrayStyle[fAllowGrayed] then //no need to check
  // switch between 2-state and 3-state CheckBox autoswitching style
  LLCL_SetWindowLongPtr(Handle, GWL_STYLE, NativeUInt(i and cardinal(not StyleMask) or CBGrayStyle[fAllowGrayed]));
end;

{ TRadioButton }

constructor TRadioButton.Create(AOwner:TComponent);
begin
  inherited;
  ATType := ATTRadioButton;
  TabStop := false;
  AutoSize := true;
end;

procedure TRadioButton.CreateParams(var Params : TCreateParams);
begin
  fCreateFlags := BS_RADIOBUTTON or CBAlignStyle[fAlignment];
  inherited;
end;

function TRadioButton.SpecialKeyProcess(var CharCode: Word): TKeyProcess;
begin
  result := inherited SpecialKeyProcess(CharCode);  // tkStandard by default
  if CharCode=VK_SPACE then
    begin
      CharCode := VK_RETURN;
      result := tkNoEnterDef;
    end;
end;

function TRadioButton.GetSpecTabStop(): boolean;
begin
  result := Checked;
end;

{ TGroupBox }

constructor TGroupBox.Create(AOwner:TComponent);
begin
  inherited;
  ATType := ATTGroupBox;
  TabStop := false;
end;

procedure TGroupBox.CreateHandle;
begin
  inherited;
  if (not HasDesignColor) then Color := Parent.Color;   // To be able to forward it easily to casual child controls
  CreateAllHandles;
end;

procedure TGroupBox.CreateParams(var Params : TCreateParams);
begin
  inherited;
  with Params do
    begin
      Style := Style or BS_GROUPBOX;
      ExStyle := WS_EX_CONTROLPARENT;
      WinClassName := BUTTON_CTRLCLASS;
    end;
end;

function TGroupBox.GetSpecTabStop(): boolean;
begin
  result := true;
end;

procedure TGroupBox.AdjustTextSize(var Size: TSize);
begin
  Inc(Size.cx, 19); Inc(Size.cy, 4);
end;

{$ifdef  LLCL_OPT_STDLABEL}
{ TLabel }

constructor TLabel.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTLabel;
  Transparent := true;
  AutoSize := true;
end;

procedure TLabel.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..1] of PChar = ('Alignment', 'WordWrap');
begin
  case StringIndex(PropName, Properties) of
    0 : Reader.IdentProperty(fAlignment, TypeInfo(TAlignment));
    1 : fWordWrap := Reader.BooleanProperty;
    else inherited;
  end;
end;

procedure TLabel.ControlInit(RuntimeCreate: boolean);
begin
  if AutoSize then
    UpdateTextSize();
  inherited;
end;

// Paint text, or get needed text size
procedure TLabel.PaintText(AddFlags: cardinal; var R: TRect);
const LAlignStyle: array[TAlignment] of cardinal =(DT_LEFT , DT_RIGHT, DT_CENTER);
var fFlags: cardinal;
begin
  fFlags := DT_EXPANDTABS or LAlignStyle[fAlignment];
  if fWordWrap then
    fFlags := fFlags or DT_WORDBREAK;
  with TPCanvas(Canvas) do begin
    if Font.Handle=0 then
      Font.Assign(self.Font);
    Brush.Style := bsSolid;       // (Issue with bsClear for fonts with big size)
    if Transparent then
      Brush.Color := self.Parent.Color
    else
      begin
        Brush.Color := self.Color;
        if (AddFlags and DT_CALCRECT)=0 then
          FillRect(R);
      end;
    PrepareText;
    LLCL_DrawText(Handle, @Caption[1], -1, R, fFlags or AddFlags);
  end;
end;

procedure TLabel.Paint;
var R: TRect;
begin
  R := ClientRect();
  PaintText(0, R);
end;

procedure TLabel.UpdateTextSize();
var R: TRect;
begin
  if Parent=nil then exit;
  R := ClientRect();
  Canvas.Handle := LLCL_GetDC(Parent.Handle); // Not called inside a WM_PAINT message
  PaintText(DT_CALCRECT, R);                    // No update, only size compute
  LLCL_ReleaseDC(Parent.Handle, Canvas.Handle);
  SetBounds(Left, Top, R.Right-Left, R.Bottom-Top);
end;

procedure TLabel.SetColor(Value: integer);
begin
  inherited;
  InvalidateEx(not Visible);
end;

procedure TLabel.SetCaption(const Value: string);
begin
  inherited;
  if AutoSize then
    UpdateTextSize()        // InvalidateEx called through SetBounds
  else
    InvalidateEx(not Visible);
end;
{$endif}

{ TBoxStrings }

constructor TBoxStrings.Create(Box: TCustomBox);
begin
  inherited Create;
  fStrings := TStringList.Create;
  fBox := Box;
end;

destructor TBoxStrings.Destroy;
begin
  fStrings.Free;
  inherited;
end;

function TBoxStrings.Add(const S: string): integer;
begin
  fStrings.Add(S);
  result := LLCLS_SendMessageSetText(fBox.Handle, fBox.fAddLineMsg, S);
end;

procedure TBoxStrings.Clear;
var s: string;
begin
  fStrings.Clear;
  s := ''; // (to avoid compilation warning)
  if fbox.ATType=ATTComboBox then
    s := LLCLS_SendMessageGetText(fBox.Handle);
  LLCL_SendMessage(fBox.Handle, cardinal(fBox.fResetMsg), 0, 0);  // LLCLS_SendMessageSetText not used here
  if fbox.ATType=ATTComboBox then
    LLCLS_SendMessageSetText(fBox.Handle, WM_SETTEXT, s);
end;

procedure TBoxStrings.SetStrings(StringList: TStrings);
// seems to be very unoptimal, but there's no TStringList.Assign !
var i: integer;
begin
  if StringList = fStrings then exit;
  Clear;
  for i := 0 to StringList.Count-1 do
    Add(StringList[i]);
end;

function TBoxStrings.GetItem(n: integer): string;
begin
  result := fStrings[n];
end;

procedure TBoxStrings.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..0] of PChar = ('Strings');
begin
  case StringIndex(PropName, Properties) of
    0 : Reader.ReadStrings(fStrings);
    else inherited;
  end;
end;

{ TCustomBox }

constructor TCustomBox.Create(AOwner: TComponent);
begin
  inherited;
  Color := LLCL_GetSysColor(integer(clWindow) and $FF);
  fItems := TBoxStrings.Create(self);
  fItemIndex := -1;
  ArrowKeysInternal := true;    // Both for ListBox and ComboBox
end;

procedure TCustomBox.CreateHandle;
  var i: integer;
begin
  inherited;
  for i := 0 to fItems.Strings.Count-1 do
    LLCLS_SendMessageSetText(Handle, fAddLineMsg, fItems.Strings[i]);
  SetItemIndex(fItemIndex);
end;

procedure TCustomBox.CreateParams(var Params : TCreateParams);
begin
  inherited;
  with Params do
    begin
      Style := Style or fCreateFlags;
      ExStyle := WS_EX_CLIENTEDGE;
      Height := Height + fDropDownHeight;
      if ATType = ATTComboBox then
        WinClassName := COMBOBOX_CTRLCLASS
      else
        WinClassName := LISTBOX_CTRLCLASS;
    end;
end;

procedure TCustomBox.Clear;
begin
  fItems.fStrings.Clear;
  LLCL_SendMessage(Handle, cardinal(fResetMsg), 0, 0);  // LLCLS_SendMessageSetText not used here
end;

destructor TCustomBox.Destroy;
begin
  fItems.Free;
  inherited;
end;

function TCustomBox.GetItems(): TStrings;
begin
  result := fItems.Strings;
end;

procedure TCustomBox.SetItems(AItems: TStrings);
begin
  fItems.Strings := AItems;
end;

function TCustomBox.GetCount(): integer;
begin
  result := LLCL_SendMessage(Handle, cardinal(fGetCountMsg), 0, 0);
  Assert(result = fItems.Strings.Count);
end;

procedure TCustomBox.SetItemIndex(Value: integer);
begin
  LLCL_SendMessage(Handle, cardinal(fSetIndexMsg), WPARAM(Value), 0);
  fItemIndex := Value;
end;

procedure TCustomBox.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..1] of PChar = ('ItemIndex', 'Sorted');
begin
  case StringIndex(PropName, Properties) of
    0 : fItemIndex := Reader.IntegerProperty;
    1 : fSorted := Reader.BooleanProperty;
    else inherited;
  end;
end;

function TCustomBox.SubProperty(const SubPropName: string): TPersistent;
const SubProperties: array[0..0] of PChar = ('Items');
begin
  case StringIndex(SubPropName, SubProperties) of
   0 : result := fItems;
   else result := inherited SubProperty(SubPropName);
  end;
end;

{ TComboBox }

// Call "simulated" dispatch
function ECBWP_CallDisp(const obj: TObject; hWnd: THandle; Msg: cardinal; var awParam: NativeUInt; alParam: NativeUInt): boolean;
var dsp: TMessage;
begin
  dsp.Msg := Msg;
  dsp.wParam := WPARAM(awParam);
  dsp.lParam := LPARAM(alParam);
  dsp.result := 0;
  TPComboBox(obj).KeyboardMsg := 1;
  obj.Dispatch(dsp);
  result := (TPComboBox(obj).KeyboardMsg=2);    // Do not PostProcess
  TPComboBox(obj).KeyboardMsg := 0;
  awParam := dsp.wParam;    // This parameter may be changed in keyboard messages
end;

// Callback function for Combobox sub controls (Edit and ListBox)
function ECBWndProc(hWnd: THandle; Msg: cardinal; awParam, alParam: NativeUInt): NativeUInt; stdcall;
var obj: TObject;
var CBWndProc: TFNWndProc;
var IsForEdit: boolean;
begin
  CBWndProc := nil;
  obj := TObject(LLCL_GetWindowLongPtr(hWnd, GWL_USERDATA));
  if Assigned(obj) then
    begin
      IsForEdit := (hWnd=TComboBox(obj).fhWndItem);
      if IsForEdit then
        CBWndProc := TComboBox(obj).fEditCBWndProc
      else
        CBWndProc := TComboBox(obj).fListCBWndProc;
      case Msg of
      WM_KEYDOWN, WM_KEYUP, WM_CHAR,
      WM_SYSKEYDOWN, WM_SYSKEYUP, WM_SYSCHAR:
        begin
          if IsForEdit then
            begin
              result := 0;
              if ECBWP_CallDisp(obj, TComboBox(obj).Handle, Msg, awParam, alParam) then
                exit;   // Do not PostProcess
              case awParam of
              VK_RETURN, VK_ESCAPE, VK_TAB: // Specific keys to skip
                if not TComboBox(obj).IsListDroppedDown then  // If list not currently displayed
                  exit;
              end;
            end
          else
            begin
              case Msg of
              WM_KEYDOWN:
                TComboBox(obj).fListLastKeyDown := awParam;
              end;
            end;
        end;
      WM_LBUTTONDOWN, WM_LBUTTONUP, WM_LBUTTONDBLCLK,
      WM_RBUTTONDOWN, WM_RBUTTONUP, WM_RBUTTONDBLCLK:
        if IsForEdit or (not TComboBox(obj).IsListDroppedDown) then
          ECBWP_CallDisp(obj, TComboBox(obj).Handle, Msg, awParam, alParam);
      end;
    end;
  if not Assigned(CBWndProc) then
    result := LLCL_DefWindowProc(hWnd, Msg, awParam, alParam)
  else
    result := LLCL_CallWindowProc({$IFDEF FPC}TFNWndProc(CBWndProc){$ELSE}CBWndProc{$ENDIF}, hWnd, Msg, awParam, alParam);
end;

constructor TComboBox.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTComboBox;
end;

procedure TComboBox.CreateHandle;
var Info: TComboboxInfo;
begin
  inherited;
  LLCLS_SendMessageSetText(Handle, WM_SETTEXT, Caption);    // Caption used to store text
  fOnChangeOK := true;    // OnChange is now OK for being activated (In fact, not really necessary becauses child controls are subclasses only after)
  // Gets interesting sub control handles (Edit and List)
  Info.cbSize := SizeOf(Info);
  if LLCL_GetComboBoxInfo(Handle, Info) then
    begin
      fhWndItem := Info.hWndItem;
      fhWndList := Info.hWndList;
    end;
  // Subclasses Edit and Listbox control inside
  //    Combobox, to get keyboard and mouse entries
  if (fStyle in [csDropDown, csSimple]) and (fhWndItem<>0) then
    begin
      fEditCBWndProc := TFNWndProc(LLCL_SetWindowLongPtr(fhWndItem, GWL_WNDPROC, NativeUInt(@ECBWndProc)));
      LLCL_SetWindowLongPtr(fhWndItem, GWL_USERDATA, NativeUInt(self));
    end;
  if (fhWndList<>0) then
    begin
      fListCBWndProc := TFNWndProc(LLCL_SetWindowLongPtr(fhWndList, GWL_WNDPROC, NativeUInt(@ECBWndProc)));
      LLCL_SetWindowLongPtr(fhWndList, GWL_USERDATA, NativeUInt(self));
    end;
end;

procedure TComboBox.CreateParams(var Params : TCreateParams);
//TComboBoxStyle = (csDropDown, csSimple, csDropDownList, csOwnerDrawFixed, csOwnerDrawVariable);
const ComboBoxStyleFlag: array[TComboBoxStyle] of cardinal =
  (CBS_DROPDOWN, CBS_SIMPLE, CBS_DROPDOWNLIST, CBS_OWNERDRAWFIXED, CBS_OWNERDRAWVARIABLE);
begin
  fCreateFlags := WS_VSCROLL or CBS_AUTOHSCROLL or CBS_HASSTRINGS or CBS_NOINTEGRALHEIGHT;
  fAddLineMsg := CB_ADDSTRING;
  fResetMsg := CB_RESETCONTENT;
  fGetIndexMsg := CB_GETCURSEL;
  fSetIndexMsg := CB_SETCURSEL;
  fGetCountMsg := CB_GETCOUNT;
  if fSorted then
    fCreateFlags := fCreateFlags or CBS_SORT;
  fCreateFlags := fCreateFlags or ComboBoxStyleFlag[fStyle];
  if fStyle<>csSimple then
    fDropDownHeight := 200;   // Maybe, not the best solution?!?
  if fStyle=csDropDownList then
    KeyboardMsg := 3;         // Specific (for TWinControl.WMKeyDown: no duplicate WMKeyDown message in this case)
  inherited;
end;

procedure TComboBox.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..1] of PChar = ('OnChange', 'Style');
begin
  case StringIndex(PropName, Properties) of
    0 : TMethod(EOnChange) := FindMethod(Reader);
    1 : Reader.IdentProperty(fStyle, TypeInfo(TComboBoxStyle));
    else inherited;
  end;
end;

procedure TComboBox.SelectAll;
begin
  if fhWndItem<>0 then
    LLCL_SendMessage(fhWndItem, EM_SETSEL, 0, LPARAM(-1));
end;

procedure TComboBox.SetDroppedDown(Value: boolean);
var R: TRect;
begin
  LLCL_SendMessage(Handle, CB_SHOWDROPDOWN, WPARAM(ord(Value)), 0);
  R := ClientRect();
  LLCL_InvalidateRect(Handle, @R, true);
end;

function TComboBox.IsListDroppedDown(): boolean;  // For Edit sub control
begin
  if fStyle = csSimple then   // csSimple
    result := false
  else                        // csDropDown
    result := DroppedDown;
end;

function TCombobox.ColorForSubCont(SubContMsg: integer; SubConthWnd: THandle): boolean;
begin
  result := ((SubContMsg=WM_CTLCOLOREDIT) and (SubConthWnd=fhWndItem)) or
            ((SubContMsg=WM_CTLCOLORLISTBOX) and (SubConthWnd=fhWndList));
end;

function TComboBox.GetText(): string;
begin
  result := LLCLS_SendMessageGetText(Handle);
end;

procedure TComboBox.SetText(const Value: string);
begin
  Caption := Value;
end;

function TComboBox.GetDroppedDown(): boolean;
begin
  result := boolean(LLCL_SendMessage(Handle, CB_GETDROPPEDSTATE, 0, 0));
end;

procedure TComboBox.CallOnChange;
begin
  if fOnChangeOK and Assigned(EOnChange) then
    EOnChange(self);
end;

function TComboBox.SpecialKeyProcess(var CharCode: Word): TKeyProcess;
begin
  result := inherited SpecialKeyProcess(CharCode);  // tkStandard by default
  case CharCode of
  VK_RETURN, VK_ESCAPE, VK_TAB: // (Not completely LCL standard for TAB)
    if IsListDroppedDown or ((fStyle=csDropDownList) and (fListLastKeyDown<>CharCode)) then
      result := tkForceStandard;
  cardinal(^A):                 // Ctrl+A = Select All
    begin
      SelectAll();
      result := tkSkip;
    end;
  end;
end;

// WM_COMMAND message coming from form
procedure TComboBox.ComponentNotif(var Msg: TMessage);
begin
  inherited;
  case TWMCommand(Msg).NotifyCode of
  CBN_SELCHANGE, CBN_EDITCHANGE:
    begin
      if TWMCommand(Msg).NotifyCode=CBN_EDITCHANGE then
        fItemIndex := -1  // At this step windows control is not updated, and CB_GETCURSEL (possibly in OnChange) won't work
      else
        fItemIndex := LLCL_SendMessage(Handle, cardinal(fGetIndexMsg), 0, 0);
      CallOnChange;
    end;
  CBN_CLOSEUP:
    fListLastKeyDown := 0;    // Clear it
  end;
end;

destructor TComboBox.Destroy;
begin
  if Assigned(fEditCBWndProc) then
    LLCL_SetWindowLongPtr(fhWndItem, GWL_WNDPROC, NativeUInt(fEditCBWndProc));
  if Assigned(fListCBWndProc) then
    LLCL_SetWindowLongPtr(fhWndList, GWL_WNDPROC, NativeUInt(fListCBWndProc));
  inherited;
end;

{ TListBox }

constructor TListBox.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTListBox;
end;

procedure TListBox.CreateParams(var Params : TCreateParams);
begin
  fCreateFlags := WS_VSCROLL or LBS_HASSTRINGS or LBS_NOINTEGRALHEIGHT or LBS_NOTIFY;
  fAddLineMsg := LB_ADDSTRING;
  fResetMsg := LB_RESETCONTENT;
  fGetIndexMsg := LB_GETCURSEL;
  fSetIndexMsg := LB_SETCURSEL;
  fGetCountMsg := LB_GETCOUNT;
  if fSorted then
    fCreateFlags := fCreateFlags or LBS_SORT;
  inherited;
end;

// WM_COMMAND message coming from form
procedure TListBox.ComponentNotif(var Msg: TMessage);
begin
  inherited;
  case TWMCommand(Msg).NotifyCode of
  LBN_SELCHANGE:
    fItemIndex := LLCL_SendMessage(Handle, cardinal(fGetIndexMsg), 0, 0);
  end;
end;

{ TStaticText }

constructor TStaticText.Create(AOwner:TComponent);
begin
  inherited;
  ATType := ATTStaticText;
  Transparent := true;
  TabStop := false;
{$IFNDEF FPC}
  AutoSize := true;
{$ENDIF}
end;

procedure TStaticText.CreateParams(var Params : TCreateParams);
var stStyle: cardinal;
begin
  inherited;
  case fBorderStyle of
    sbsSingle : stStyle := WS_BORDER;
    sbsSunKen : stStyle := SS_SUNKEN;
    else        stStyle := 0;
  end;
  case fAlignment of
    taRightJustify: stStyle := stStyle or SS_RIGHT;
    taCenter:       stStyle := stStyle or SS_CENTER;
  end;
  with Params do
    begin
      Style := Style or WS_CLIPCHILDREN or stStyle or SS_NOTIFY;
      WinClassName := STATIC_CTRLCLASS;
    end;
end;

procedure TStaticText.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..1] of PChar = (
    'BorderStyle', 'Alignment');
begin
  case StringIndex(PropName, Properties) of
    0 : Reader.IdentProperty(fBorderStyle, TypeInfo(TStaticBorderStyle));
    1 : Reader.IdentProperty(fAlignment, TypeInfo(TAlignment));
    else inherited;
  end;
end;

procedure TStaticText.AdjustTextSize(var Size: TSize);
begin
  Inc(Size.cy, 1);
  if fBorderStyle<>sbsNone then
    begin Inc(Size.cx, 2); Inc(Size.cy, 3); end;
end;

//------------------------------------------------------------------------------

const
  StdCtrlsClasses: array[0..9] of TPersistentClass =
    (TLabel, TButton, TEdit, TCheckBox, TRadioButton, TGroupBox, TMemo,
     TComboBox, TListBox, TStaticText);

initialization
  RegisterClasses(StdCtrlsClasses);

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
