unit Forms;

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
    * Bug fix for ShowModal in TCustomForm
    * Modifications and bug fix when application is terminating
   Version 1.01:
    * Bug fix: Color in TCustomForm
    * TForm: 'BorderStyle', 'Position' and 'FormStyle' properties now accessible (design time only)
    * TApplication: AppHandle moved in protected part
   Version 1.00:
    * Old unused properties removed: OldCreateOrder, PixelsPerInch and TextHeight
    * IsAccel function added
    * Icon for TApplication (minimal - see Graphics.pas)
    * SysTray part removed - TTrayIcon created (see ExtCtrls.pas)
    * TApplication: Minimize, Restore, BringToFront added
    * TApplication: MessageBox added
    * TForm: ActiveControl added
    * TForm: sizes more compatible with Delphi and FPC/Lazarus
    * TForm: OnPaint specific
    * TForm: Refresh removed (now in Controls.pas)
    * TApplication: Terminated added
    * TApplication: BiDiMode added (applied to whole application)
    * TApplication: Handle added (only for Delphi)
    * TApplication: MainFormOnTaskBar (only for FPC/Lazarus and recent Delphi) - Requires LLCL_OPT_TOPFORM
    * TApplication: OnMinimize and OnRestore added
}

// Original notes from LVCL

{
         LVCL - Very LIGHT VCL
         ----------------------------

   Tiny replacement for the standard VCL Forms.pas
   Just put the LVCL directory in your Project/Options/Path/SearchPath
   and your .EXE will shrink from 300KB to 30KB

   Notes:
   - implements TApplication + TForm
   - compatible with the standard .DFM files.
   - only use existing properties in your DFM, otherwise you'll get error on startup
     (no Anchor property, e.g.)
   - MinimizeToTray property for easy tray icon implementation (server-aware)

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

{$I LLCLOptions.inc}      // Options

//------------------------------------------------------------------------------

interface

uses
  LLCLOSInt, Windows, {$IFDEF FPC}LCLType, LMessages{$ELSE}ShellAPI, Messages{$ENDIF},
  Classes, SysUtils, Controls, {$ifdef LLCL_OPT_USEMENUS}Menus,{$endif} Graphics;

const
  LLCLVersion = 0102;                 // Can be tested {$IF Declared(...)}
  LLCLOSType  = 'WIN';                //    in user's programs

type
  TFormBorderStyle =
    (bsNone, bsSingle, bsSizeable, bsDialog, bsToolWindow, bsSizeToolWin);
  TPosition =
    (poDesigned, poDefault, poDefaultPosOnly, poDefaultSizeOnly,
     poScreenCenter, poDesktopCenter, poMainFormCenter, poOwnerFormCenter);
  TWindowState =
    (wsNormal, wsMinimized, wsMaximized);     // (wsRestore removed from LVCL)
  TFormStyle =
    (fsNormal, fsMDIChild, fsMDIForm, fsStayOnTop);
  TCloseAction =
    (caNone, caHide, caFree, caMinimize);

  TCustomForm = class(TWinControl)
  private
    fBorderStyle: TFormBorderStyle;
    fClientWidth, fClientHeight: integer;
    fAdjWidth, fAdjHeight: integer; // Internal size adjustements
    fPosition: TPosition;
    fWindowState: TWindowState;
    {$ifdef LLCL_OPT_TOPFORM}
    fFormerWindowState: TWindowState;
    {$endif}
    fFormStyle: TFormStyle;
    fKeyPreview: boolean;
    fClosed: boolean;
    fIsModal: boolean;
    {$ifdef LLCL_OPT_USEMENUS}
    fMenu: TMainMenu;
    fLastMenuIdent: integer;
    fAdjMenu: integer;              // Internal size adjustement
    {$endif}
    fActiveControl: TWinControl;
    fHandleDefButton,             // Default button
    fHandleCurButton: THandle;    // Current highlighted button
    EOnCreate,
    EOnPaint,
    EOnResize,
    EOnDestroy: TNotifyEvent;
    procedure DoCreate;
    procedure SetWindowState(Value: TWindowState);
    procedure SetActiveControl(Value: TWinControl);
  protected
    procedure Load;
    procedure Read(Reader:TReader);
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    procedure CreateHandle; override;
    procedure CreateParams(var Params : TCreateParams); override;
    procedure InvalidateEx(EraseBackGround: boolean); override;
    function  GetSpecTabStop(): boolean; override;
    procedure SetFocusControl(Value: TWinControl);    // To avoid infinite loop with TWinControl focus update
    procedure CallOnPaint;
    procedure WMActivate(var Msg: TWMActivate); message WM_ACTIVATE;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMClose(var Msg: TWMClose); message WM_CLOSE;
    {$ifdef LLCL_OPT_USEMENUS}
    procedure WMCommand(var Msg: TWMCommand); message WM_COMMAND;
    {$endif}
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMMove(var Msg: TWMMove); message WM_MOVE;
    {$ifdef LLCL_OPT_TOPFORM}
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMNCActivate(var Msg: TWMNCActivate); message WM_NCACTIVATE;
    {$endif}
    {$ifdef LLCL_OPT_USEMENUS}
    property  LastMenuIdent: integer read fLastMenuIdent write fLastMenuIdent;
    {$endif}
    property  HandleDefButton: THandle read fHandleDefButton write fHandleDefButton;
    property  HandleCurButton: THandle read fHandleCurButton write fHandleCurButton;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Show; override;
    procedure ShowModal;
    {$ifdef LLCL_OPT_TOPFORM}
    procedure Hide; override;
    {$endif}
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
    procedure Close;
    property  ActiveControl: TWinControl read fActiveControl write SetActiveControl;
    property  KeyPreview: boolean read fKeyPreview write fKeyPreview;
    property  WindowState: TWindowState read fWindowState write SetWindowState;
    property  BorderStyle: TFormBorderStyle read fBorderStyle write fBorderStyle; // Run-time modification ignored; write present only for dynamical control creation purpose
    property  Position: TPosition read fPosition write fPosition;                 // Run-time modification ignored; write present only for dynamical control creation purpose
    property  FormStyle: TFormStyle read fFormStyle write fFormStyle;             // Run-time modification ignored; write present only for dynamical control creation purpose
    {$ifdef LLCL_OPT_USEMENUS}
    property  Menu: TMainMenu read fMenu write fMenu;
    {$endif}
    property  OnCreate: TNotifyEvent read EOnCreate write EOnCreate;
    property  OnPaint: TNotifyEvent read EOnPaint write EOnPaint;
    property  OnResize: TNotifyEvent read EOnResize write EOnResize;
    property  OnDestroy: TNotifyEvent read EOnDestroy write EOnDestroy;
 end;

{$M+} // We use fields like Form1.Button1, so we need to publish them with $M+
  TForm = class(TCustomForm)
  end;
{$M-}

  TApplication = class(TComponent)
  private
    fIcon: TIcon;
    fNonClientMetrics: TCustomNonClientMetrics;
    fTerminated: boolean;
    fPostQuitDone: boolean;
    fMainForm: TCustomForm;
    fShowMainForm: boolean;
    fTitle: string;
    fBiDiMode: TBiDiMode;
{$IFNDEF FPC}
    {$if (CompilerVersion <= 18) and (not Defined(LLCL_OPT_TOPFORM))} // Delphi 2006 or before
      {$define DefNo_MainFormOnTaskBar}
    {$ifend}
{$ENDIF FPC}
    fMainFormOnTaskBar: boolean;
    {$ifdef LLCL_OPT_TOPFORM}
    fHandle: THandle;
    fActiveWindow: THandle;
    fIsMinimizing: boolean;
    {$endif}
    EOnMinimize,
    EOnRestore: TNotifyEvent;
    procedure SetTitle(const Value: string);
    procedure SetBiDiMode(const Value: TBiDiMode);
    {$ifndef DefNo_MainFormOnTaskBar}
    procedure SetMainFormOnTaskBar(Value: boolean);
    {$endif DefNo_MainFormOnTaskBar}
    function  ModalFormsSave(ShowWindowHandle: THandle; var FormsStateList: TList): THandle;
    procedure ModalFormsRestore(ActiveWindowHandle: THandle; var FormsStateList: TList);
    {$ifdef LLCL_OPT_TOPFORM}
    procedure SetVisible(ShowCall: boolean);
    function  TopHandle(): THandle;
    {$endif}
  protected
    function  AppHandle(): THandle;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Initialize;
    {$ifdef LLCL_OPT_TOPFORM}
    procedure CreateHandle;
    {$endif}
    procedure CreateForm(InstanceClass: TComponentClass; var Reference);
    procedure Run;
    procedure ProcessMessages;
    procedure Terminate;
    procedure ShowException(E: Exception);
    function  MessageBox(Text, Caption: PChar; Flags: cardinal {$IFNDEF FPC}= MB_OK{$ENDIF}): integer;
    procedure Minimize;
    procedure Restore;
    procedure BringToFront;
    property  Icon: TIcon read fIcon;
    property  MainForm: TCustomForm read fMainForm;
    property  ShowMainForm: boolean read fShowMainForm write fShowMainForm;
    property  Title: string read fTitle write SetTitle;
    property  BiDiMode: TBiDiMode read fBiDiMode write SetBiDiMode;
    property  Terminated: boolean read fTerminated;
{$IFNDEF FPC}
    // Application handle points to "Top invisible" form or Mainform handle
    // Not used for FPC/Lazarus version, though AppHandle does
    property  Handle: THandle read AppHandle;
{$ENDIF FPC}
    {$ifndef DefNo_MainFormOnTaskBar}
    // Must be set before forms creation
    // Not used for old Delphi version, though fMainFormOnTaskBar does
    property  MainFormOnTaskBar: boolean read fMainFormOnTaskBar write SetMainFormOnTaskBar;
    {$endif DefNo_MainFormOnTaskBar}
    property  OnMinimize: TNotifyEvent read EOnMinimize write EOnMinimize;
    property  OnRestore: TNotifyEvent read EOnRestore write EOnRestore;
 end;

function IsAccel(VK: Word; const Str: string): boolean;
function GetParentForm(aControl: TControl): TCustomForm;

var
  Application:    TApplication;
{$IFDEF FPC}
  RequireDerivedFormResource: boolean = false;  // Unused
{$ENDIF FPC}

//------------------------------------------------------------------------------

implementation

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

{$ifdef LLCL_OPT_USEMENUS}
type
  TPMainMenu = class(TMainMenu);      // To access to protected part
{$endif}

const
{$ifdef LLCL_OPT_TOPFORM}
  TAPPL_CLASS = 'LApplication';       // Delphi uses 'TApplication' and FPC/Lazarus uses 'Window'
{$endif}
  TFORM_CLASS = 'LForm';              // LVCL uses 'LFORM', Delphi uses 'TFormx' and FPC/Lazarus uses 'Window'

const
  LAYOUT_RTL = $00000001;

function RPos(const SubStr : string; const S: string): cardinal; forward;
{$ifdef LLCL_OPT_TOPFORM}
function TAppWndProc(hWnd: THandle; Msg: integer; wParam, lParam: NativeUInt): NativeUInt; stdcall; forward;
{$endif}

//------------------------------------------------------------------------------

{$IFDEF FPC}
// Dummy function to avoid compilation hint (LMessages not used)
function LMessages_Dummy(const Msg: TLMCommand): boolean;
begin
  result := false;
end;
{$ENDIF FPC}

// Right Position (Case Sensitive)
function RPos(const SubStr : string; const S: string): cardinal;
var i1,i2,i3: cardinal;
begin
  result := 0;
  i1 := 1;
  i2 := cardinal(length(S));
  i3 := Pos(SubStr, S);
  while i3>0 do
    begin
      Inc(result, i3);
      Inc(i1, i3);
      Dec(i2, i3);
      if i2=0 then break;
      i3 := Pos(SubStr, Copy(S, i1, i2));
    end;
end;

//------------------------------------------------------------------------------

{ TCustomForm }

constructor TCustomForm.Create(AOwner: TComponent);
begin
  ATType := ATTCustomForm;    // Needed before inherited
  inherited;
  Color := LLCL_GetSysColor(integer(clbtnFace) and $FF);
  fBorderStyle := bsSizeable;
  fPosition := poDesigned;
{$IFDEF FPC}
  if CheckWin32Version(LLCL_WINVISTA_MAJ, LLCL_WINVISTA_MIN) then
    begin
      Font.Name := 'Segoe UI';
      Font.Height := -12;
    end
  else
    begin
      Font.Name := 'Tahoma';
      Font.Height := -11;
    end;
{$ENDIF FPC}
end;

destructor TCustomForm.Destroy;
begin
  if Assigned(EOnDestroy) then
    EOnDestroy(Self);
  inherited;
end;

procedure TCustomForm.Load;
var Reader: TReader;
begin
  Reader := TReader.Create(string(ClassName));
  try
    if Reader.Size>4 then
      if Reader.ReadInteger=ord('T')+(ord('P') shl 8)+(ord('F') shl 16)+(ord('0') shl 24) then
        Read(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TCustomForm.Read(Reader:TReader);
var
  Flags: TFilerFlags;
  Child: integer;
  AName: string;  // (AClass not used)
begin
  Reader.ReadPrefix(Flags, Child);
  Reader.ReadString;
  AName  := Reader.ReadString;
  if not (ffInherited in Flags) then
    Name := AName;
  Reader.Loading(self);
  ReadProperties(Reader, self);
  if Reader.Size-Reader.Position<>0 then
    raise Exception.CreateFmt(LLCL_STR_FORM_RESOURCESIZE, [AName]);
end;

procedure TCustomForm.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..10] of PChar = (
    'ClientWidth', 'ClientHeight',
    'BorderStyle',
    'Position',
    'WindowState',
    'OnCreate', 'OnPaint', 'OnResize', 'OnDestroy',
    'FormStyle',
    'KeyPreview'
  );
begin
  case StringIndex(PropName, Properties) of
    0 : fClientWidth := Reader.IntegerProperty;     // Used internaly
    1 : fClientHeight := Reader.IntegerProperty;    //   later (eventually)
    2 : Reader.IdentProperty(fBorderStyle, TypeInfo(TFormBorderStyle));
    3 : Reader.IdentProperty(fPosition, TypeInfo(TPosition));
    4 : Reader.IdentProperty(fWindowState, TypeInfo(TWindowState));
    5 : TMethod(EOnCreate) := FindMethod(Reader);
    6 : TMethod(EOnPaint) := FindMethod(Reader);
    7 : TMethod(EOnResize) := FindMethod(Reader);
    8 : TMethod(EOnDestroy) := FindMethod(Reader);
    9 : Reader.IdentProperty(fFormStyle, TypeInfo(TFormStyle));
    10: fKeyPreview := Reader.BooleanProperty;
   else inherited;
  end;
end;

procedure TCustomForm.CreateHandle;
var aRect: TRect;
begin
  inherited;
  case fFormStyle of  // no MDI support yet
    fsStayOnTop: SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or
      SWP_NOSIZE or SWP_NOACTIVATE);
  end;
  // Update screen positions
  if LLCL_GetWindowRect(Handle, aRect) then
    SetBounds(aRect.Left, aRect.Top, Width, Height);
  // UI
  if CheckWin32Version(LLCL_WIN2000_MAJ, LLCL_WIN2000_MIN) then
    // (Clear UI states if LLCL_OPT_NESTEDGROUPBOXWINXPFIX activated)
    LLCL_PostMessage(Handle, WM_CHANGEUISTATE, WPARAM({$ifdef LLCL_OPT_NESTEDGROUPBOXWINXPFIX}UIS_CLEAR{$else}UIS_INITIALIZE{$endif} or ((UISF_HIDEFOCUS or UISF_HIDEACCEL) shl 16)), 0);
end;

procedure TCustomForm.CreateParams(var Params : TCreateParams);
var cfStyle, cfExStyle: cardinal;
var SizeAdj: array[0..2] of integer;
begin
  with Application.fNonClientMetrics do
    begin
      FillChar(SizeAdj,SizeOf(SizeAdj),0);
{$IFDEF FPC}
      if CheckWin32Version(LLCL_WINVISTA_MAJ, LLCL_WINVISTA_MIN) and (iBorderWidth>4) then
        begin SizeAdj[0] := 4; SizeAdj[1] := 3; SizeAdj[2] := 1; end;
{$ENDIF FPC}
      {$ifdef LLCL_OPT_USEMENUS}
      if (fMenu<>nil) then
        fAdjMenu := iMenuHeight+(iBorderWidth-SizeAdj[1])-SizeAdj[2];
      {$endif}
      // ClientHeight/Width not present for FPC if empty form,
      //    and not present for Delphi if border style is sizeable
      // Height/Width not present for Delphi if border style is not sizeable
      case fBorderStyle of
        bsSingle, bsDialog: begin
          fAdjWidth := (iBorderWidth-SizeAdj[0])*6;
          fAdjHeight := iCaptionHeight+(iBorderWidth-SizeAdj[0])*7;
{$IFNDEF FPC}
          Width := fClientWidth + fAdjWidth;
          Height := fClientHeight + fAdjHeight{$ifdef LLCL_OPT_USEMENUS} + fAdjMenu{$endif};
{$ENDIF FPC}
        end;
        bsSizeable: begin
          fAdjWidth := (iBorderWidth-SizeAdj[1])*8;
          fAdjHeight := iCaptionHeight+(iBorderWidth-SizeAdj[1])*9-SizeAdj[2];
        end;
{$IFNDEF FPC}
       else begin
         Width := fClientWidth;
         Height := fClientHeight;
       end;
{$ENDIF FPC}
      end;
    end;
  case fPosition of
    poDefault, poDefaultPosOnly: begin
      Left  := integer(CW_USEDEFAULT);
      Top   := integer(CW_USEDEFAULT);
    end;
    poScreenCenter, poDesktopCenter: begin
      Left  := (LLCL_GetSystemMetrics(SM_CXSCREEN)-Width) div 2;
      Top   := (LLCL_GetSystemMetrics(SM_CYSCREEN)-Height) div 2;
    end;
  end;
  inherited;
  case fBorderStyle of
    bsNone    : cfStyle := WS_POPUP;
    bsSingle  : cfStyle := WS_CAPTION or WS_BORDER or WS_SYSMENU or WS_MINIMIZEBOX or WS_MAXIMIZEBOX;
    bsSizeable: cfStyle := WS_OVERLAPPEDWINDOW;
    bsDialog  : cfStyle := WS_DLGFRAME;         // or WS_SYSMENU;  // (Not standard: Close button is missing)
    else        cfStyle := 0;
  end;
  case fBorderStyle of
    bsDialog      : cfExStyle := WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE;
    bsToolWindow,
    bsSizeToolWin : cfExStyle := WS_EX_TOOLWINDOW;
    else            cfExStyle := 0;
  end;
  {$ifdef LLCL_OPT_TOPFORM}
  if (Application.MainForm=nil) and Application.fMainFormOnTaskBar then     // (MainForm=nil -> is creating MainForm)
    cfExStyle := cfExStyle or WS_EX_APPWINDOW;
  {$endif}
  cfStyle := cfStyle or WS_CLIPCHILDREN or WS_CLIPSIBLINGS;
  with Params do
    begin
{$IFDEF FPC}
      Width := Width + fAdjWidth;
      Height := Height + fAdjHeight; // Menu already included
{$ENDIF}
      Style := cfStyle;                             // Replaced
      ExStyle := cfExStyle or WS_EX_CONTROLPARENT;  //  "  "
      {$ifdef LLCL_OPT_TOPFORM}
      WndParent := Application.TopHandle();
      {$endif}
      WinClassName := TFORM_CLASS;
    end;
end;

procedure TCustomForm.DoCreate;       // Create Form and all its Controls
begin
  CreateAllHandles;
  {$ifdef LLCL_OPT_USEMENUS}
  // Note: LLCL doesn't use the "Menu" property eventually present for form in .dfm/.lfm file
  if (fMenu<>nil) and(fBorderStyle<>bsDialog) then
    TPMainMenu(fMenu).SetMainMenuForm(Handle, fLastMenuIdent);
  {$endif}
  if Assigned(EOnCreate) then
    EOnCreate(self);
end;

procedure TCustomForm.InvalidateEx(EraseBackGround: boolean);
var R: TRect;
begin
  // (No inherited)
  R := ClientRect();
  LLCL_InvalidateRect(Handle, @R, EraseBackGround);
end;

procedure TCustomForm.SetWindowState(Value: TWindowState);
begin
  fWindowState := Value;
  if Visible then
    Show;
end;

procedure TCustomForm.SetActiveControl(Value: TWinControl);
begin
  Value.SetFocus();
end;

procedure TCustomForm.Show;
const
  ShowCommands: array[TWindowState] of integer =
    (SW_SHOWNORMAL, SW_MINIMIZE, SW_SHOWMAXIMIZED);
begin
  {$ifdef LLCL_OPT_TOPFORM}
{$IFDEF FPC}
  if self=Application.MainForm then
{$ENDIF}
    Application.SetVisible(true);
  {$endif}
  ShowCommand := ShowCommands[fWindowState];
  inherited;
end;

procedure TCustomForm.ShowModal;
var CurHandle: THandle;
var FormsStateList: TList;
begin
  fIsModal := true;
  fClosed := false;
  CurHandle := Application.ModalFormsSave(Handle, FormsStateList);
  Show;
  repeat
    Application.ProcessMessages;
    if (not fClosed) and (not Application.Terminated) then
      LLCL_WaitMessage;
  until fClosed or Application.Terminated;
  Hide;
  Application.ModalFormsRestore(CurHandle, FormsStateList);
  fIsModal := false;    // (Always by default, for Show)
end;

{$ifdef LLCL_OPT_TOPFORM}
procedure TCustomForm.Hide;
begin
  inherited;
{$IFDEF FPC}
  if self=Application.MainForm then
{$ENDIF}
    Application.SetVisible(false);
end;
{$endif}

procedure TCustomForm.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
  inherited;
  if Handle<>0 then   // May happen before created
    LLCL_MoveWindow(Handle, ALeft, ATop, AWidth{$IFDEF FPC}+fAdjWidth{$ENDIF}, AHeight{$IFDEF FPC}+fAdjHeight{$ENDIF}, true);
end;

procedure TCustomForm.Close;
begin
  if self=Application.MainForm then
    // Don't free the mainform at this step, to avoid nasty internal bugs
    Application.Terminate
  else
    begin
      if fIsModal then
        fClosed := true
      else
        Hide;
    end;
end;

function TCustomForm.GetSpecTabStop(): boolean;
begin
  result := false;
end;

procedure TCustomForm.SetFocusControl(Value: TWinControl);
begin
  fActiveControl := Value;
end;

procedure TCustomForm.CallOnPaint;
begin
  if Assigned(EOnPaint) then
    EOnPaint(self);
end;

procedure TCustomForm.WMActivate(var Msg: TWMActivate);
begin
  inherited;
  if Msg.Active=WA_ACTIVE then
    FormFocus();
end;

procedure TCustomForm.WMSetFocus(var Msg: TWMSetFocus);
begin
  // (No inherited)
  FormFocus();
end;

procedure TCustomForm.WMClose(var Msg: TWMClose);
begin
  // (No inherited, except when application is terminating)
  if Application.Terminated then
    inherited
  else
    Close;
end;

{$ifdef LLCL_OPT_USEMENUS}
procedure TCustomForm.WMCommand(var Msg: TWMCommand);
begin
  inherited;
  if (Msg.Ctl=0) and (fMenu<>nil) then
    TPMainMenu(fMenu).ClickMainMenuForm(Msg.ItemID, Msg.Result);
end;
{$endif}

procedure TCustomForm.WMSize(var Msg: TWMSize);
var TmpMsg: TWMSize;
begin
  if Msg.SizeType<>SIZE_MINIMIZED then
    begin
      // Modify stored sizes (client sizes received)
      Move(Msg, TmpMsg, SizeOf(TmpMsg));
{$IFDEF FPC}
      {$ifdef LLCL_OPT_USEMENUS}
      TmpMsg.Height := TmpMsg.Height + fAdjMenu;
      {$endif}
{$ELSE}
      TmpMsg.Width  := TmpMsg.Width + fAdjWidth;
      TmpMsg.Height := TmpMsg.Height + fAdjHeight{$ifdef LLCL_OPT_USEMENUS} + fAdjMenu{$endif};
{$ENDIF}
      inherited WMSize(TmpMsg);  // L_G: otherwise fHeight/fWidth remains unchanged and WMEraseBkGnd don't fill larger area
      // (Could save Msg sizes in ClientHeight/Width - currently not public)
    end;
  case Msg.SizeType of
  SIZE_MINIMIZED:  fWindowState := wsMinimized;
  SIZE_MAXIMIZED:  fWindowState := wsMaximized;
  SIZE_RESTORED:   fWindowState := wsNormal;
  end;
  if Msg.SizeType<>SIZE_MINIMIZED then
    if Assigned(EOnResize) then
       EOnResize(self);
end;

procedure TCustomForm.WMMove(var Msg: TWMMove);
var TmpMsg: TWMMove;
var aRect: TRect;
begin
  // Modify stored positions (client positions received)
  Move(Msg, TmpMsg, SizeOf(TmpMsg));
  if LLCL_GetWindowRect(Handle, aRect) then
    begin
      TmpMsg.XPos := aRect.Left;
      TmpMsg.YPos := aRect.Top;
    end;
  inherited WMMove(TmpMsg);
end;

{$ifdef LLCL_OPT_TOPFORM}
procedure TCustomForm.WMSysCommand(var Msg: TWMSysCommand);
begin
  if self=Application.MainForm then
    case (Msg.CmdType and $FFF0) of
    SC_MINIMIZE:
      begin
        Application.Minimize;
        exit;
      end;
    // SC_MAXIMIZE: -> just inherited
    SC_RESTORE:
      if fWindowState=wsMinimized then
        begin
          Application.Restore;
          exit;
        end
    end;
  inherited;
end;

procedure TCustomForm.WMNCActivate(var Msg: TWMNCActivate);
begin
  if Msg.Active then
    if not Application.fIsMinimizing then
      Application.fActiveWindow := Handle;    // (Because GetActiveWindow in Minimize won't work if Application is reached via TaskBar)
    // Minor issue: if MainFormOnTaskBar=true, restoring a minimized application
    //    will always activate the MainForm, not the latest active form
  inherited;
end;
{$endif}

{ TApplication }

constructor TApplication.Create(AOwner: TComponent);
const
  ICC_STANDARD_CLASSES  = $4000;
var i: cardinal;
begin
  inherited;
  // Global initializations
  LLCLS_InitCommonControl(ICC_STANDARD_CLASSES);    // Avoid to include ComCtrls just for InitCommonControl
  LLCLS_Init(Win32Platform);
  // Application icon
  fIcon := TIcon.Create;
  fIcon.Handle := LLCL_LoadIcon(hInstance, PChar('MAINICON'));
  if fIcon.Handle=0 then
    fIcon.Handle := LLCL_LoadIcon(hInstance, PChar(IDI_APPLICATION));
  // Default title
  fTitle := LLCLS_GetModuleFileName(hInstance);
  i := RPos(PathDelim, fTitle);
  if i>0 then fTitle := Copy(fTitle, i+1, cardinal(length(fTitle))-i);
  i := RPos('.', fTitle);
  if i>0 then fTitle := Copy(fTitle, 1, i-1);
  {$ifdef LLCL_OPT_TOPFORM}
  // "Top invisible" form
  CreateHandle();
  {$endif}
  // Various
  fShowMainForm := true;
  LLCLS_GetNonClientMetrics(fNonClientMetrics);
end;

destructor TApplication.Destroy;
{$ifndef LLCL_OPT_TOPFORM}
var i: integer;
{$endif}
begin
  fIcon.Free;
  {$ifdef LLCL_OPT_TOPFORM}
  LLCL_SetWindowLongPtr(fHandle, GWL_WNDPROC, NativeUInt(@LLCL_DefWindowProc));
  LLCL_DestroyWindow(TopHandle());
  LLCL_UnregisterClass(TAPPL_CLASS, hInstance);
  {$else}
  for i := 0 to (Components.Count - 1) do
    LLCL_DestroyWindow(TWincontrol(Components[i]).Handle);
  {$endif}
  LLCL_UnregisterClass(TFORM_CLASS, hInstance);
  inherited;
end;

procedure TApplication.Initialize;
var WndClass: TWndClass;
begin
  {$ifdef LLCL_OPT_TOPFORM}
  // Here, sure that Application is fully created (TAppWndProc is using it)
  LLCL_SetWindowLongPtr(fHandle, GWL_WNDPROC, NativeUInt(@TAppWndProc));
  {$endif}
  // (Only one class for TForms, so it can be created here)
  FillChar(WndClass, SizeOf(WndClass), 0);
  WndClass.hInstance := hInstance; // hInstance in System (D2) or SysInit (D5) :(
  with WndClass do begin
//    Style := CS_VREDRAW or CS_HREDRAW;   // No more used, to avoid flicker
    Style := CS_DBLCLKS;
    lpfnWndProc := @LLCL_DefWindowProc;
    cbClsExtra := 16;   // (1 used)
    cbWndExtra := 32;   // (3 used)
    hIcon := self.fIcon.Handle;
    hCursor := LLCL_LoadCursor(0, PChar(IDC_ARROW));
    lpszClassName := TFORM_CLASS;
  end;
  LLCL_RegisterClass(WndClass);
end;

{$ifdef LLCL_OPT_TOPFORM}
function TAppWndProc(hWnd: THandle; Msg: integer; wParam, lParam: NativeUInt): NativeUInt; stdcall;
begin
  result := 0;
  case Msg of
  // WM_SETFOCUS:
  //   "Top invisible" form in rare cases is keeping focus, but
  //   processing WM_SETFOCUS only for these cases is not simple
  //   (especially when application is minimized/restored)
  WM_SYSCOMMAND:
    case WParam and $FFF0 of
      SC_MINIMIZE: begin Application.Minimize; exit; end;
      SC_RESTORE: begin Application.Restore; exit; end;
    end;
  end;
  result := LLCL_DefWindowProc(hWnd, Msg, wParam, lParam);
end;

procedure TApplication.CreateHandle;
var WndClass: TWndClass;
var Style, ExStyle: cardinal;
var SystemMenu: THandle;
begin
  // Application Class
  FillChar(WndClass, SizeOf(WndClass), 0);
  WndClass.hInstance := hInstance;
  with WndClass do begin
    lpfnWndProc := @LLCL_DefWindowProc;
    hIcon := self.fIcon.Handle;
    hCursor := LLCL_LoadCursor(0, PChar(IDC_ARROW));
    lpszClassName := TAPPL_CLASS;
  end;
  // Application "Top invisible" form
  LLCL_RegisterClass(WndClass);
  Style := WS_POPUP or WS_CAPTION or WS_CLIPSIBLINGS or WS_SYSMENU or WS_MINIMIZEBOX;
  ExStyle := 0;
  if (not fMainFormOnTaskBar) then
    ExStyle := ExStyle or WS_EX_APPWINDOW;
  fHandle := LLCL_CreateWindowEx(ExStyle, TAPPL_CLASS, @fTitle[1], Style,
    LLCL_GetSystemMetrics(SM_CXSCREEN) div 2, LLCL_GetSystemMetrics(SM_CYSCREEN) div 2,
    0, 0, 0, 0, WndClass.hInstance, nil);
  SystemMenu := LLCL_GetSystemMenu(fHandle, False);
  LLCL_DeleteMenu(SystemMenu, SC_MAXIMIZE, MF_BYCOMMAND);
  LLCL_DeleteMenu(SystemMenu, SC_SIZE, MF_BYCOMMAND);
  LLCL_DeleteMenu(SystemMenu, SC_MOVE, MF_BYCOMMAND);
  // (ShowWindow depends on forms visible state)
end;
{$endif}

procedure TApplication.CreateForm(InstanceClass: TComponentClass; var Reference);
var Instance: TComponent;
begin
  Instance := TComponent(InstanceClass.NewInstance);
  try
    TComponent(Reference) := Instance;
    Instance.Create(self);    // Forms are relative to Application
    if Instance.InheritsFrom(TCustomForm) then
      begin
        TCustomForm(Instance).Load;
        if fMainForm=nil then // Main form is the first initialized form
          fMainForm := TCustomForm(Instance);
        TCustomForm(Instance).DoCreate;
      end;
  except
    TComponent(Reference) := nil;
    raise;
  end;
end;

function TApplication.AppHandle(): THandle;
begin
  {$ifdef LLCL_OPT_TOPFORM}
  result := fHandle;
  {$else}
  if fMainForm=nil then result := 0
  else result := fMainform.Handle;
  {$endif}
end;

{$ifdef LLCL_OPT_TOPFORM}
function TApplication.TopHandle(): THandle;
begin
  if fMainFormOnTaskBar then
    begin
      if MainForm<>nil then     // (Not if is creating MainForm)
        result := Mainform.Handle
      else
        result := 0;
    end
  else
    result := fHandle;    // AppHandle()
end;
{$endif}

procedure TApplication.SetTitle(const Value: string);
begin
  fTitle := Value;
  {$ifdef LLCL_OPT_TOPFORM}
  LLCLS_SendMessageSetText(fHandle, WM_SETTEXT, Value);
  {$endif}
end;

procedure TApplication.SetBiDiMode(const Value: TBiDiMode);
var LayOutVal: cardinal;
begin
  if Value=fBiDiMode then exit;
  fBiDiMode := Value;
  if Value<>bdLeftToRight then
    LayOutVal := LAYOUT_RTL
  else
    LayOutVal := 0;
  LLCLS_SetProcessDefaultLayout(LayOutVal);
end;

{$ifndef DefNo_MainFormOnTaskBar}
procedure TApplication.SetMainFormOnTaskBar(Value: boolean);
begin
  fMainFormOnTaskBar := Value;
{$ifdef LLCL_OPT_TOPFORM}
  if fMainFormOnTaskBar then
    LLCL_ShowWindow(fHandle, SW_HIDE)
  else
    LLCL_ShowWindow(fHandle, SW_SHOW);
{$endif}
end;
{$endif}

function TApplication.ModalFormsSave(ShowWindowHandle: THandle; var FormsStateList: TList): THandle;
{$ifdef LLCL_OPT_TOPFORM}
var i: integer;
{$endif}
begin
  result := LLCL_GetActiveWindow();
  {$ifdef LLCL_OPT_TOPFORM}
  FormsStateList := TList.Create;
  for i := 0 to ComponentCount-1 do
    with TCustomForm(Components[i]) do
      begin
        FormsStateList.Add(pointer(nativeuint(Enabled)));  // (Ugly hack)
        Enabled := (Handle=ShowWindowHandle);
      end;
  {$else}
  if result<>0 then
    LLCL_EnableWindow(result, false);
  {$endif}
end;

procedure TApplication.ModalFormsRestore(ActiveWindowHandle: THandle; var FormsStateList: TList);
{$ifdef LLCL_OPT_TOPFORM}
var i: integer;
{$endif}
begin
  {$ifdef LLCL_OPT_TOPFORM}
  for i := 0 to ComponentCount-1 do
    with TCustomForm(Components[i]) do
      begin
        if FormsStateList[i]<>nil then
          Enabled := true;
      end;
  FormsStateList.Free;
  {$else}
  if ActiveWindowHandle<>0 then
    LLCL_EnableWindow(ActiveWindowHandle, true);
  {$endif}
  if ActiveWindowHandle<>0 then
    // SetActiveWindow is not possible, because WM_ACTIVATE may have already
    //    been sent before by Windows, when the MessageBox/Modal form was closed
    LLCL_PostMessage(ActiveWindowHandle, WM_ACTIVATE, WA_ACTIVE, 0);
end;

{$ifdef LLCL_OPT_TOPFORM}
// Show or Hide "Top invisible" form (in TaskBar)
procedure TApplication.SetVisible(ShowCall: boolean);
var IsVisible: boolean;
{$IFNDEF FPC}
var i: integer;
{$ENDIF}
begin
  if fMainFormOnTaskBar then exit;        // (Nothing to do)
{$IFNDEF FPC}
  if (not ShowCall) then
    for i := 0 to ComponentCount-1 do     // All the forms hidden ?
      if TCustomForm(Components[i]).Visible then exit;
{$ENDIF}
  IsVisible := LLCL_IsWindowVisible(fHandle);
  if ShowCall then
    begin if (not IsVisible) then LLCL_ShowWindow(fHandle, SW_SHOW); end
  else
    begin if IsVisible then LLCL_ShowWindow(fHandle, SW_HIDE); end;
end;
{$endif}

procedure TApplication.Run;
var i: integer;
begin
  if fMainForm=nil then
    exit;
  for i := 0 to ComponentCount-1 do
    with TCustomForm(Components[i]) do
      if Visible then Show;
  if fShowMainForm and (not fMainForm.Visible) then
    fMainForm.Show;         // For simplification, this sets Visible to true for MainForm
  repeat
    ProcessMessages;
    if not fTerminated then
      LLCL_WaitMessage;
  until fTerminated;
end;

procedure TApplication.ProcessMessages;
var msg: TMsg;
begin
  while LLCL_PeekMessage(msg, 0, 0, 0, PM_REMOVE) do
    if Msg.Message=WM_QUIT then
      begin
        fTerminated := true;
        break;
      end
    else
      begin
        LLCL_TranslateMessage(Msg);
        LLCL_DispatchMessage(Msg);
      end;
end;

procedure TApplication.Terminate;
begin
  if not fPostQuitDone then
    begin
      fPostQuitDone := true;
      LLCL_PostQuitMessage(0);
    end;
end;

procedure TApplication.ShowException(E: Exception);
begin
  MessageBox(@E.Message[1], nil, MB_OK or MB_ICONERROR);
end;

function TApplication.MessageBox(Text, Caption: PChar; Flags: cardinal): integer;
var CurHandle: THandle;
var RTLValue: cardinal;
var FormsStateList: TList;
begin
  if BiDiMode<>bdLeftToRight then
    RTLValue := MB_RTLREADING or MB_RIGHT
  else
    RTLValue := 0;
  CurHandle := Application.ModalFormsSave(0, FormsStateList);
  result := LLCL_MessageBox(CurHandle, Text, Caption, Flags or RTLValue);
  Application.ModalFormsRestore(CurHandle, FormsStateList);
end;

// If not LLCL_OPT_TOPFORM, MainForm is used instead (imperfect workaround)
procedure TApplication.Minimize;
begin
  if fMainFormOnTaskBar then
    LLCL_DefWindowProc(fMainForm.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0)
  else
    begin
      {$ifdef LLCL_OPT_TOPFORM}
      fIsMinimizing := true;
      if fMainForm.Visible then
        begin
          LLCL_SetWindowPos(fHandle, HWND_TOP, fMainForm.Left, fMainForm.Top, fMainForm.Width, 0, SWP_NOACTIVATE);
          LLCL_ShowWindow(fMainForm.Handle, SW_HIDE);
          fMainForm.fFormerWindowState := fMainForm.fWindowState;
          fMainForm.fWindowState := wsMinimized
        end;
      {$endif}
      LLCL_DefWindowProc(AppHandle(), WM_SYSCOMMAND, SC_MINIMIZE, 0);
    end;
  if Assigned(EOnMinimize) then
    EOnMinimize(self);
end;

procedure TApplication.Restore;
begin
  if fMainFormOnTaskBar then
    LLCL_DefWindowProc(fMainForm.Handle, WM_SYSCOMMAND, SC_RESTORE, 0)
  else
    begin
      LLCL_DefWindowProc(AppHandle(), WM_SYSCOMMAND, SC_RESTORE, 0);
      {$ifdef LLCL_OPT_TOPFORM}
      fIsMinimizing := false;
      if fMainForm.Visible then
        LLCL_ShowWindow(fMainForm.Handle, SW_SHOWNA);
      fMainForm.fWindowState:=fMainForm.fFormerWindowState;
      {$endif}
    end;
  {$ifdef LLCL_OPT_TOPFORM}
  if fActiveWindow<>0 then
    LLCL_SetActiveWindow(fActiveWindow);
  {$endif}
  if Assigned(EOnRestore) then
    EOnRestore(self);
end;

procedure TApplication.BringToFront;
begin
  {$ifdef LLCL_OPT_TOPFORM}
  if fActiveWindow<>0 then
    LLCL_SetForegroundWindow(fActiveWindow)
  else
  {$else}
    fMainForm.BringToFront;
  {$endif}
end;

//------------------------------------------------------------------------------

function IsAccel(VK: word; const Str: string): boolean;
begin
  result := LLCLS_IsAccel(VK, Str);
end;

function GetParentForm(aControl: TControl): TCustomForm;
begin
  while aControl.Parent<>nil do
    aControl := aControl.Parent;
  if aControl.InheritsFrom(TCustomForm) then
    result := TCustomForm(aControl) else
    result := nil;
end;

//------------------------------------------------------------------------------

initialization
  Application := TApplication.Create(nil);

finalization
  Application.Free;

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
