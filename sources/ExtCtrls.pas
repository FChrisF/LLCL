unit ExtCtrls;

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
    * TRadioGroup added (not enabled by default - see LLCLOptions.inc)
   Version 1.01:
    * TImage: Changed added (when bitmap data are changed)
    * TImage: SetStretch modified
    * LLCL_OPT_USEIMAGE option added (enabled by default - see LLCLOptions.inc)
   Version 1.00:
    * TImage: Show and Hide added (see TGraphicControl)
    * TImage: Stretch added
    * TTimer implemented
    * TTrayIcon implemented (MinimizeToTray removed from Forms.pas)
}

// Original notes from LVCL

{
         LVCL - Very LIGHT VCL
         ----------------------------

   Tiny replacement for the standard VCL ExtCtrls.pas
   Just put the LVCL directory in your Project/Options/Path/SearchPath
   and your .EXE will shrink from 300KB to 30KB

   Notes:
   - implements TImage
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
}

{$IFDEF FPC}
  {$define LLCL_FPC_MODESECTION}
  {$I LLCLFPCInc.inc}             // For mode
  {$undef LLCL_FPC_MODESECTION}
{$ENDIF}
{$ifdef FPC_OBJFPC} {$define LLCL_OBJFPC_MODE} {$endif} // Object pascal mode

{$I LLCLOptions.inc}      // Options

//------------------------------------------------------------------------------

interface

uses
  LLCLOSInt, Windows, {$IFDEF FPC}LMessages{$ELSE}Messages, ShellAPI{$ENDIF},
  Classes, Controls,
  {$ifdef LLCL_OPT_USEMENUS}Menus,{$endif}
  {$ifdef LLCL_OPT_USERADIOGROUP} StdCtrls,{$endif}
  Graphics;

type

{$ifdef LLCL_OPT_USEIMAGE}
  TImage = class(TGraphicControl)
  private
    fPicture: TPicture;
    fStretch: boolean;
    function  GetPicture(): TPicture;
    procedure SetPicture(APicture: TPicture);
    procedure SetStretch(const Value: boolean);
    procedure Changed(Sender: TObject);
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    function  SubProperty(const SubPropName: string): TPersistent; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property  Picture: TPicture read GetPicture write SetPicture;
    property  Stretch: boolean read fStretch write SetStretch;
  end;
{$endif LLCL_OPT_USEIMAGE}

  TTimer = class(TNonVisualControl)
  private
    fRunning: boolean;
    fEnabled: boolean;
    fInterval: integer;
    EOnTimer: TNotifyEvent;
    procedure SetEnabled(const Value: boolean);
    procedure SetInterval(const Value: integer);
    procedure TimerStatus();
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    procedure ControlInit(RuntimeCreate: boolean); override;
    procedure ControlCall(var Msg: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property  Enabled: boolean read fEnabled write SetEnabled;
    property  Interval: integer read fInterval write SetInterval;
    property  OnTimer: TNotifyEvent read EOnTimer write EOnTimer;
  end;

  TBalloonFlags = (bfNone, bfInfo, bfWarning, bfError);

  TTrayIcon = class;
  TIconST = class(TIcon)
  private
    fParent: TTrayIcon;
  protected
    procedure SetHandle(Value: THandle); override;
  end;

  TTrayIcon = class(TNonVisualControl)
  private
    fSysTrayInfo: TCustomNotifyIconData;
    fIsTrayCreated: boolean;
    fIcon: TIconST;
    fHint: string;
    fVisible: boolean;
    {$ifdef LLCL_OPT_USEMENUS}
    fPopUpMenu: TPopupMenu;
    fPopUpMenuName: string;   // Eventual loaded PopUpMenu name
    {$endif}
    // Balloons (balloon notifications in taskbar) are only possible for
    //   Windows version >= Windows 2000 (BalloonTimeout only for 2000 and XP)
    fBalloonFlags: TBalloonFlags;
    fBalloonHint: string;
    fBalloonTimeout: integer;
    fBalloonTitle: string;
    EOnDblClick: TNotifyEvent;
    procedure SetHint(const Value: string);
    function  GetICon(): TIcon;
    procedure SetIcon(const Value: TIcon);
    procedure UpdateIcon;
    procedure SetVisible(Value: boolean);
    procedure CreateSysTray;
    procedure DeleteSysTray;
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    function  SubProperty(const SubPropName: string): TPersistent; override;
    procedure ControlInit(RuntimeCreate: boolean); override;
    procedure ControlCall(var Msg: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Show;           // LCL, but non VCL
    procedure Hide;           //    standard
    procedure ShowBalloonHint;
    property  Icon: TIcon read GetIcon write SetIcon;
    property  Hint: string read fHint write SetHint;
    property  Visible: boolean read fVisible write SetVisible;
    {$ifdef LLCL_OPT_USEMENUS}
    property  PopUpMenu: TPopupMenu read fPopUpMenu write fPopUpMenu;
    {$endif}
    property  BalloonFlags: TBalloonFlags read fBalloonFlags write fBalloonFlags;
    property  BalloonHint: string read fBalloonHint write fBalloonHint;
    property  BalloonTimeout: integer read fBalloonTimeout write fBalloonTimeout;
    property  BalloonTitle: string read fBalloonTitle write fBalloonTitle;
    property  OnDblClick: TNotifyEvent read EOnDblClick write EOnDblClick;
  end;

{$ifdef LLCL_OPT_USERADIOGROUP}
  TRadioGroupStrings = class(TCtrlStrings)   // (not standard)
  public
    function  Add(const S: string): integer; override;
    procedure Clear; override;
    property  Items[index: integer]: string read GetString; default;
  end;

  TColumnLayout = (clHorizontalThenVertical, clVerticalThenHorizontal);

  TRadioGroup = class(TGroupBox)
  private
    fItems: TRadioGroupStrings;
    fItemIndex: integer;
    fColumns: integer;
    fColumnLayout: TColumnLayout;     // also used internally for Delphi
    function  GetItemIndex(): integer;
    procedure SetItemIndex(Value: integer);
    procedure SetColumns(Value: integer);
    procedure SetRadioBPos();
    procedure CreateRadioB(const sCaption: string; nTabOrder: integer);
    procedure RadioBClick(Sender: TObject);
    {$IFDEF FPC}
    procedure SetColumnLayout(AValue: TColumnLayout);
    {$ENDIF}
  protected
    procedure CreateHandle; override;
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    function  SubProperty(const SubPropName: string): TPersistent; override;
    procedure ClickCall(ChangeFocus: boolean; DoSetFocus: boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property  Items: TRadioGroupStrings read fItems;
    property  ItemIndex: integer read GetItemIndex write SetItemIndex;
    property  Columns: integer read fColumns write SetColumns;
    {$IFDEF FPC}
    property  ColumnLayout: TColumnLayout read fColumnLayout write SetColumnLayout;
    {$ENDIF}
  end;
{$endif LLCL_OPT_USERADIOGROUP}

//------------------------------------------------------------------------------

implementation

uses
  SysUtils, Forms;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

{$ifdef LLCL_OPT_USEIMAGE}
type
  TPPicture = class(TPicture);          // To access to protected part
{$endif LLCL_OPT_USEIMAGE}

{$ifdef LLCL_OPT_USERADIOGROUP}
  TPRadioButton = class(TRadioButton);  // To access to protected part
{$endif LLCL_OPT_USERADIOGROUP}

const
  NIF_MESSAGE   = $00000001;      // SysTray
  NIF_ICON      = $00000002;
  NIM_SETFOCUS  = $00000003;
  NIF_TIP       = $00000004;
  NIF_STATE     = $00000008;
  NIF_INFO      = $00000010;
  NIIF_NONE     = $00000000;
  NIIF_INFO     = $00000001;
  NIIF_WARNING  = $00000002;
  NIIF_ERROR    = $00000003;
  NIM_ADD       = $00000000;
  NIM_MODIFY    = $00000001;
  NIM_DELETE    = $00000002;

//------------------------------------------------------------------------------

{$IFDEF FPC}
// Dummy function to avoid compilation hint (LMessages not used, NIM_SETFOCUS and NIF_STATE not used)
function LMessages_Dummy(const Msg: TLMCommand): boolean;
begin
  result := false;
  if (Msg.Msg = NIM_SETFOCUS) or (Msg.Msg = NIF_STATE) then
    result := false;
end;
{$ENDIF FPC}

{$ifdef LLCL_OPT_USEIMAGE}
{ TImage }

constructor TImage.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTImage;
end;

destructor TImage.Destroy;
begin
  if fPicture<>nil then
    fPicture.Free;
  inherited;
end;

function TImage.GetPicture(): TPicture;
begin
  if fPicture=nil then
    fPicture := TPicture.Create;
  fPicture.OnChange := {$IFDEF LLCL_OBJFPC_MODE}@{$ENDIF}Changed;
  result := fPicture;
end;

procedure TImage.SetPicture(APicture: TPicture);
begin
  Picture.Assign(APicture);   // (not fPicture);
end;

procedure TImage.SetStretch(const Value: boolean);
begin
  if fStretch=Value then exit;
  fStretch := Value;
  Changed(self);
end;

procedure TImage.Changed(Sender: TObject);
begin
  if Visible then
    InvalidateEx(true);
end;

procedure TImage.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..0] of PChar = ('Stretch');
begin
  case StringIndex(PropName, Properties) of
    0 : fStretch := Reader.BooleanProperty;
    else inherited;
  end;
end;

function TImage.SubProperty(const SubPropName: string): TPersistent;
const SubProperties: array[0..0] of PChar = ('Picture');
begin
  case StringIndex(SubPropName, SubProperties) of
   0 : result := Picture.Bitmap;
   else result := inherited SubProperty(SubPropName);
  end;
end;

procedure TImage.Paint;
begin
  if fPicture<>nil then
    TPPicture(fPicture).DrawRect(ClientRect, Canvas, fStretch); // not VCL standard, but works for BITMAP
end;
{$endif LLCL_OPT_USEIMAGE}

{ TTimer }

constructor TTimer.Create(AOwner: TComponent);
begin
  ATType := ATTTimer;
  fEnabled := true;
  fInterval := 1000;
  inherited;    // After (ControlInit called after create at runtime)
end;

destructor TTimer.Destroy;
begin
  if fRunning then
    fRunning := LLCL_KillTimer(Parent.Handle, ControlIdent);
  inherited;
end;

procedure TTimer.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..2] of PChar = (
    'Enabled', 'Interval', 'OnTimer');
begin
  case StringIndex(PropName, Properties) of
    0 : fEnabled := Reader.BooleanProperty;
    1 : fInterval := Reader.IntegerProperty;
    2 : TMethod(EOnTimer) := FindMethod(Reader);
    else inherited;
  end;
end;

procedure TTimer.ControlInit(RuntimeCreate: boolean);
begin
  TimerStatus();
end;

procedure TTimer.ControlCall(var Msg: TMessage);
begin
  if Assigned(EOnTimer) then
    EOnTimer(self);
end;

procedure TTimer.TimerStatus();
begin
  if fRunning then
    fRunning := LLCL_KillTimer(Parent.Handle, ControlIdent);
  if fEnabled and (fInterval<>0) then
    fRunning := (LLCL_SetTimer(Parent.Handle, ControlIdent, fInterval, nil)<>0);
end;

procedure TTimer.SetEnabled(const Value: boolean);
begin
  if fEnabled=Value then exit;
  fEnabled := Value;
  TimerStatus();
end;

procedure TTimer.SetInterval(const Value: integer);
begin
  if fInterval=Value then exit;
  fInterval := Value;
  TimerStatus();
end;

{ TTrayIcon }

procedure TIconST.SetHandle(Value: THandle);
begin
  inherited;
  fParent.UpdateIcon;
end;

constructor TTrayIcon.Create(AOwner: TComponent);
begin
  ATType := ATTTrayIcon;
  fBalloonTimeout := 3000;
  inherited;    // After (ControlInit called after create at runtime)
end;

destructor TTrayIcon.Destroy;
begin
  DeleteSysTray;
  if fIcon<>nil then
    fIcon.Free;
  inherited;
end;

procedure TTrayIcon.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..7] of PChar = (
    'Visible', 'Hint', 'PopUpMenu', 'BalloonFlags', 'BalloonHint',
    'BalloonTimeout', 'BalloonTitle', 'OnDblClick');
begin
  case StringIndex(PropName, Properties) of
    0 : fVisible := Reader.BooleanProperty;
    1 : fHint := Reader.StringProperty;
    {$ifdef LLCL_OPT_USEMENUS}
    2 : fPopUpMenuName := Reader.StringProperty;
    {$endif}
    3 : Reader.IdentProperty(fBalloonFlags, TypeInfo(TBalloonFlags));
    4 : fBalloonHint := Reader.StringProperty;
    5 : fBalloonTimeout := Reader.IntegerProperty;
    6 : fBalloonTitle := Reader.StringProperty;
    7 : TMethod(EOnDblClick)  := FindMethod(Reader);
    else inherited;
  end;
end;

function TTrayIcon.SubProperty(const SubPropName: string): TPersistent;
const SubProperties: array[0..0] of PChar = ('Icon');
begin
  case StringIndex(SubPropName, SubProperties) of
  0 : result := Icon;
   else result := inherited SubProperty(SubPropName);
  end;
end;

procedure TTrayIcon.ControlInit(RuntimeCreate: boolean);
begin
  {$ifdef LLCL_OPT_USEMENUS}
  if fPopUpMenuName<>'' then
    fPopUpMenu := TPopUpMenu(Parent.FindComponent(fPopUpMenuName));
  {$endif}
  if Visible then
    CreateSysTray;
end;

procedure TTrayIcon.SetHint(const Value: string);
begin
  fHint := Value;
  fSysTrayInfo.uFlags := NIF_TIP;
  if fIsTrayCreated then
    LLCLS_Shell_NotifyIcon(NIM_MODIFY, @fSysTrayInfo, CheckWin32Version(LLCL_WIN2000_MAJ, LLCL_WIN2000_MIN), fHint);
end;

function TTrayIcon.GetIcon(): TIcon;
begin
  if fIcon=nil then
    begin
      fIcon := TIconST.Create;
      fIcon.fParent := self;
    end;
  result := TIcon(fIcon);
end;

procedure TTrayIcon.SetIcon(const Value: TIcon);
begin
  fIcon := TIconST(Value);
  fIcon.fParent := self;
  UpdateIcon;
end;

procedure TTrayIcon.UpdateIcon;
begin
  with fSysTrayInfo do
    begin
      uFlags := NIF_ICON;
      if fIcon<>nil then
        hIcon := fIcon.Handle;
    end;
  if fIsTrayCreated then
    if fSysTrayInfo.hIcon<>0 then
      LLCLS_Shell_NotifyIcon(NIM_MODIFY, @fSysTrayInfo, CheckWin32Version(LLCL_WIN2000_MAJ, LLCL_WIN2000_MIN), '');
end;

procedure TTrayIcon.SetVisible(Value: boolean);
begin
  if Value then Show
  else Hide;
end;

procedure TTrayIcon.Show;
begin
  fVisible := true;   // (fVisible, not Visible - see SetVisible)
  CreateSysTray;
end;

procedure TTrayIcon.Hide;
begin
  fVisible := false;  // (fVisible, not Visible - see SetVisible)
  DeleteSysTray;
end;

procedure TTrayIcon.CreateSysTray;
begin
  if Parent=nil then  // Using MainForm window for receiving
    exit;             //    all Systray messages in LLCL
  if not fIsTrayCreated then begin
    FillChar(fSysTrayInfo, SizeOf(fSysTrayInfo),0);
    with fSysTrayInfo do begin
      // cbSize filled in LLCLS_Shell_NotifyIcon
      Wnd    := Parent.Handle;
      uID    := ControlIdent;
      if fIcon<>nil then
        hIcon  := fIcon.Handle;
      uCallbackMessage := WM_TRAYICON;
      uFlags := NIF_TIP or NIF_ICON or NIF_MESSAGE;
    end;
    LLCLS_Shell_NotifyIcon(NIM_ADD, @fSysTrayInfo, CheckWin32Version(LLCL_WIN2000_MAJ, LLCL_WIN2000_MIN), fHint);
    fIsTrayCreated := true;
  end;
end;

procedure TTrayIcon.DeleteSysTray;
begin
  if fIsTrayCreated then begin
    LLCLS_Shell_NotifyIcon(NIM_DELETE, @fSysTrayInfo, CheckWin32Version(LLCL_WIN2000_MAJ, LLCL_WIN2000_MIN), '');
    fIsTrayCreated := false;
  end;
end;

procedure TTrayIcon.ControlCall(var Msg: TMessage);
{$ifdef LLCL_OPT_USEMENUS}
var CursorPos: TPoint;
{$endif}
begin
  if not fIsTrayCreated then
    exit;
  case Msg.lParam of
  WM_LBUTTONUP:
    if Assigned(OnClick) then
      begin
        LLCL_SetForegroundWindow(Parent.Handle);
        OnClick(self);
      end;
  WM_LBUTTONDBLCLK:
    if Assigned(EOnDblClick) then
      begin
        LLCL_SetForegroundWindow(Parent.Handle);
        EOnDblClick(self);
      end;
  {$ifdef LLCL_OPT_USEMENUS}
  WM_RBUTTONUP:
    if Assigned(fPopUpMenu) then
      begin
        GetCursorPos(CursorPos);
        LLCL_SetForegroundWindow(Parent.Handle);
        Application.ProcessMessages;
        fPopUpMenu.Popup(CursorPos.x, CursorPos.y);
        LLCL_PostMessage(Parent.Handle, WM_NULL, 0, 0);
      end;
  {$endif}
  end;
end;

procedure TTrayIcon.ShowBalloonHint;
const
  SYSTEM_INFOFLAGS: array[Low(TBalloonFlags)..High(TBalloonFlags)] of cardinal = (
      NIIF_NONE, NIIF_INFO, NIIF_WARNING, NIIF_ERROR);
begin
  fSysTrayInfo.uFlags := NIF_INFO;
  if fIsTrayCreated then
    LLCLS_Shell_NotifyIconBalloon(NIM_MODIFY, @fSysTrayInfo, CheckWin32Version(LLCL_WIN2000_MAJ, LLCL_WIN2000_MIN), SYSTEM_INFOFLAGS[fBalloonFlags], fBalloonTimeout, fBalloonTitle, fBalloonHint);
end;

{$ifdef LLCL_OPT_USERADIOGROUP}
{ TRadioGroupStrings }

function TRadioGroupStrings.Add(const S: string): integer;
begin
  with TRadioGroup(fParentCtrl) do
    begin
      CreateRadioB(S, ControlCount);
      SetRadioBPos();
      TRadioButton(Controls[Pred(ControlCount)]).Visible := true;
    end;
  result := inherited Add(S);
end;

procedure TRadioGroupStrings.Clear;
var i: integer;
begin
  with TRadioGroup(fParentCtrl) do
    begin
      for i := 0 to Pred(ControlCount) do
        LLCL_DestroyWindow(TRadioButton(Controls[i]).Handle);
      Controls.Clear;
      fItemIndex := -1;
    end;
  inherited;
end;

{ TRadioGroup }

constructor TRadioGroup.Create(AOwner: TComponent);
begin
  inherited;
//  ATType := ATTRadioGroup;    // (not used - keep GroupBox type and behavior)
  fItems := TRadioGroupStrings.Create(self);
  fItemIndex := -1;
  fColumns := 1;
  fColumnLayout := {$IFDEF FPC}clHorizontalThenVertical{$ELSE}clVerticalThenHorizontal{$ENDIF}
end;

procedure TRadioGroup.CreateHandle;
var i: integer;
begin
  inherited;
  // Creates RadioButtons
  for i := 0 to Pred(fItems.Count) do
    CreateRadioB(fItems[i], i);
  SetRadioBPos();
  if fItemIndex>=0 then     // (avoid RadioBClick);
    TRadioButton(Controls[fItemIndex]).Checked := true;
  for i := 0 to Pred(fItems.Count) do
    TRadioButton(Controls[i]).Visible := true;
end;

procedure TRadioGroup.CreateRadioB(const sCaption: string; nTabOrder: integer);
var RBTmp: TRadioButton;
begin
  RBTmp := TRadioButton.Create(self);
  RBTmp.Caption := sCaption;
  RBTmp.TabOrder := nTabOrder;
  RBTMP.Visible := false;;
  RBTMP.OnClick := {$IFDEF LLCL_OBJFPC_MODE}@{$ENDIF}RadioBClick;
  RBTMP.Parent := self;
end;

destructor TRadioGroup.Destroy;
begin
  fItems.Free;
  inherited;
end;

function TRadioGroup.GetItemIndex(): integer;
var i: integer;
begin
  fItemIndex := -1;
  for i := 0 to Pred(ControlCount) do
    if TRadioButton(Controls[i]).Checked then
      begin
        fItemIndex := i;
        break;
      end;
  result := fItemIndex;
end;

procedure TRadioGroup.SetItemIndex(Value: integer);
var i: integer;
begin
  fItemIndex := Value;
  if fItemIndex=-1 then
    begin
      i := GetItemIndex();
      if i>=0 then
        TRadioButton(Controls[i]).Checked := false;
      RadioBClick(self);
    end
  else
    TPRadioButton(Controls[Value]).ClickCall(false, false); // raise an error for incorrect index
end;

procedure TRadioGroup.SetColumns(Value: integer);
begin
  if Value<1 then
    raise Exception.CreateFmt(LLCL_STR_EXCT_RGROUPCOLUMN, [Value])
  else
    begin
      fColumns := Value;
      SetRadioBPos();
    end;
end;

// Positions of RadioButtons are slightly different than for LCL/VCL
procedure TRadioGroup.SetRadioBPos();
const WidthMargin = 8;
const HeightMargin = 10;
var WPosHandle: HDWP;
var nCol, nRow: integer;
var nTop, nLeft, nTopStart: integer;
var IncWidth, IncHeight: integer;
var i, iItemBreak: integer;
begin
  if ControlCount = 0 then exit;
  nCol := fColumns;
  if fColumnLayout=clHorizontalThenVertical then
    begin
      if ControlCount<nCol then nCol := ControlCount;       // Specific to FPC, but clHorizontalThenVertical is already specific to FPC
      nRow := (ControlCount + Pred(nCol)) div nCol;
      iItemBreak := nCol;
    end
  else
    begin
      nRow := (ControlCount + Pred(nCol)) div nCol;
{$IFDEF FPC}
      // Re-computes real number of columns
      nCol := (ControlCount + Pred(nRow)) div nRow;
{$ENDIF}
      iItemBreak := nRow;
    end;
  IncWidth := (Width - (WidthMargin * 2)) div nCol;
  IncHeight := (Height - (HeightMargin * 2)) div nRow;
  nTopStart := HeightMargin + (IncHeight div 2);
  nTop := nTopStart - IncHeight;
  nLeft := WidthMargin - IncWidth;
  WPosHandle := LLCL_BeginDeferWindowPos(ControlCount);
  if WPosHandle = 0 then exit;
  for i := 0 to Pred(ControlCount) do
    begin
      if (i mod iItemBreak)=0 then
        if fColumnLayout=clHorizontalThenVertical then
          begin
            nTop := nTop + IncHeight;
            nLeft := WidthMargin;
          end
        else
          begin
            nTop := nTopStart;
            nLeft := nLeft + IncWidth;
          end
      else
        if fColumnLayout=clHorizontalThenVertical then
          nLeft := nLeft + IncWidth
        else
          nTop := nTop + IncHeight;
      with TRadioButton(Controls[i]) do
        LLCL_DeferWindowPos(WPosHandle, Handle, 0, nLeft, nTop, Width, Height, SWP_NOZORDER or SWP_NOACTIVATE);
    end;
  LLCL_EndDeferWindowPos(WPosHandle);
end;

procedure TRadioGroup.RadioBClick(Sender: TObject);
begin
  if Assigned(OnClick) then
    OnClick(self);
end;

procedure TRadioGroup.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..2] of PChar = ('ItemIndex', 'Columns', 'ColumnLayout');
begin
  case StringIndex(PropName, Properties) of
    0 : fItemIndex := Reader.IntegerProperty;
    1 : fColumns := Reader.IntegerProperty;
    2 : Reader.IdentProperty(fColumnLayout, TypeInfo(TColumnLayout));
    else inherited;
  end;
end;

function TRadioGroup.SubProperty(const SubPropName: string): TPersistent;
const SubProperties: array[0..0] of PChar = ('Items');
begin
  case StringIndex(SubPropName, SubProperties) of
   0 : result := fItems;
   else result := inherited SubProperty(SubPropName);
  end;
end;

procedure TRadioGroup.ClickCall(ChangeFocus: boolean; DoSetFocus: boolean);
var OnClickSave: TNotifyEvent;
begin
  OnClickSave := OnClick;
  OnClick := nil;
  inherited;
  OnClick := OnClickSave;
end;

{$IFDEF FPC}
procedure TRadioGroup.SetColumnLayout(AValue: TColumnLayout);
begin
  fColumnLayout := AValue;
  SetRadioBPos();
end;
{$ENDIF}
{$endif LLCL_OPT_USERADIOGROUP}

//------------------------------------------------------------------------------

initialization
  RegisterClasses([TTimer, TTrayIcon
    {$ifdef LLCL_OPT_USEIMAGE}, TImage{$endif}
    {$ifdef LLCL_OPT_USERADIOGROUP}, TRadioGroup{$endif}
      ]);

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
