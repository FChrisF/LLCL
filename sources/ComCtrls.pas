unit ComCtrls;

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
    * TWinControl: notifications for child controls modified
    * TTrackBar: 'Orientation' and 'TickStyle' properties now accessible (design time only)
   Version 1.00:
    * File creation.
    * TProgressBar implemented
    * TTrackBar implemented
    * InitCommonControl function added
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
  TProgressBar = class(TWinControl)
  private
    fMin,
    fMax,
    fPosition,
    fStep: integer;
    procedure SetMin(Value: integer);
    procedure SetMax(Value: integer);
    procedure SetRange(ValueMin, ValueMax: integer);
    function  GetPosition(): integer;
    procedure SetPosition(Value: integer);
    procedure SetStep(Value: integer);
  protected
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure StepIt;
    procedure StepBy(Value: integer);
    property  Min: integer read fMin write SetMin;
    property  Max: integer read fMax write SetMax;
    property  Position: integer read GetPosition write SetPosition;
    property  Step: integer read fStep write SetStep;
  end;

type
  TOrientation = (trHorizontal, trVertical);
  TTickStyle = (tsAuto, tsManual, tsNone);

type
  TTrackBar = class(TWinControl)
  private
    fMin,
    fMax,
    fPosition,
    fFrequency,
    fLineSize, fPageSize: integer;
    fOrientation: TOrientation;
    fTickStyle: TTickStyle;
    fOnChangeOK: boolean;
    EOnChange: TNotifyEvent;
    procedure SetMin(Value: integer);
    procedure SetMax(Value: integer);
    procedure SetRange(ValueMin, ValueMax: integer);
    function  GetPosition(): integer;
    procedure SetPosition(Value: integer);
    procedure SetFrequency(Value: integer);
    procedure SetLineSize(Value: integer);
    procedure SetPageSize(Value: integer);
  protected
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    function  ComponentNotif(var Msg: TMessage): boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    property  Min: integer read fMin write SetMin;
    property  Max: integer read fMax write SetMax;
    property  Position: integer read GetPosition write SetPosition;
    property  Frequency: integer read fFrequency write SetFrequency;
    property  LineSize: integer read fLineSize write SetLineSize;
    property  PageSize: integer read fPageSize write SetPageSize;
    property  Orientation: TOrientation read fOrientation write fOrientation; // Run-time modification ignored; write present only for dynamical control creation purpose
    property  TickStyle: TTickStyle read fTickStyle write fTickStyle;         // Run-time modification ignored; write present only for dynamical control creation purpose
    property  OnChange: TNotifyEvent read EOnChange write EOnChange;
  end;

const
  ICC_LISTVIEW_CLASSES  = $0001;
  ICC_TREEVIEW_CLASSES  = $0002;
  ICC_BAR_CLASSES       = $0004;
  ICC_TAB_CLASSES       = $0008;
  ICC_UPDOWN_CLASS      = $0010;
  ICC_PROGRESS_CLASS    = $0020;
  ICC_STANDARD_CLASSES  = $4000;

function  InitCommonControl(CC: integer): Boolean;

//------------------------------------------------------------------------------

implementation

{$IFNDEF FPC}
uses
  CommCtrl;
{$ENDIF}

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPC}
// Dummy function to avoid compilation hint (LMessages not used)
function LMessages_Dummy(const Msg: TLMCommand): boolean;
begin
  result := false;
end;
{$ENDIF FPC}

{ TProgressBar }

constructor TProgressBar.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTProgressBar;
  TabStop := false;
  fMax := 100;
  fStep := 10;
end;


procedure TProgressBar.CreateHandle;
begin
  InitCommonControl(ICC_PROGRESS_CLASS);
  inherited;
  SetRange(fMin, fMax);
  SetPosition(fPosition);
  SetStep(fStep);
end;

procedure TProgressBar.CreateParams(var Params: TCreateParams);
const PROGRESS_CLASS = 'msctls_progress32';
begin
  inherited;
  with Params do
    begin
      WinClassName := PROGRESS_CLASS;
    end;
end;

procedure TProgressBar.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..3] of PChar = (
    'Min', 'Max', 'Position', 'Step');
begin
  case StringIndex(PropName, Properties) of
    0 : fMin := Reader.IntegerProperty;
    1 : fMax := Reader.IntegerProperty;
    2 : fPosition := Reader.IntegerProperty;
    3 : fStep := Reader.IntegerProperty;
    else inherited;
  end;
end;

procedure TProgressBar.SetMin(Value: integer);
begin
  SetRange(Value, fMax);
end;

procedure TProgressBar.SetMax(Value: integer);
begin
  SetRange(fMin, Value);
end;

procedure TProgressBar.SetRange(ValueMin, ValueMax: integer);
begin
  fMin := ValueMin;
  fMax := ValueMax;
  LLCL_SendMessage(Handle, PBM_SETRANGE, 0, LPARAM(fMin or (fMax shl 16)));
end;

function TProgressBar.GetPosition(): integer;
begin
  fPosition := LLCL_SendMessage(Handle, PBM_GETPOS, 0, 0);
  result := fPosition;
end;

procedure TProgressBar.SetPosition(Value: integer);
begin
  fPosition := Value;
  LLCL_SendMessage(Handle, PBM_SETPOS, WPARAM(fPosition), 0);
end;

procedure TProgressBar.SetStep(Value: integer);
begin
  fStep := Value;
  LLCL_SendMessage(Handle, PBM_SETSTEP, WPARAM(fStep), 0);
end;

procedure TProgressBar.StepIt;
begin
  fPosition := fPosition+fStep;
  LLCL_SendMessage(Handle, PBM_STEPIT, 0, 0);
end;

procedure TProgressBar.StepBy(Value: integer);
begin
  SetPosition(fPosition+Value);
end;

{ TTrackBar }

constructor TTrackBar.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTTrackBar;
  ArrowKeysInternal := true;
  fMax := 10;
  fFrequency := 1;
  fLineSize := 1;
  fPageSize := 2;
  fTickStyle := tsAuto;
end;

procedure TTrackBar.CreateHandle;
begin
  InitCommonControl(ICC_BAR_CLASSES);
  inherited;
  SetRange(fMin, fMax);
  SetPosition(fPosition);
  SetFrequency(fFrequency);
  SetLineSize(fLineSize);
  SetPageSize(fPageSize);
  fOnChangeOK := true;    // OnChange is now OK for being activated
end;

procedure TTrackBar.CreateParams(var Params: TCreateParams);
const TRACKBAR_CLASS = 'msctls_trackbar32';
begin
  inherited;
  with Params do
    begin
      WinClassName := TRACKBAR_CLASS;
      if fOrientation=trVertical then
        Style := Style or TBS_VERT;             // Else TBS_HORZ =0
      case fTickStyle of
      tsAuto:   Style := Style or TBS_AUTOTICKS;
      tsManual: Style := Style or TBS_BOTH;
      else      Style := Style or TBS_NOTICKS;  // Else = tsNone
      end;
      Style := Style or TBS_ENABLESELRANGE      // Not used, but has an impact on size
                {$IFDEF FPC};{$ELSE} or TBS_FIXEDLENGTH;{$ENDIF}
    end;
end;

procedure TTrackBar.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..8] of PChar = (
    'Min', 'Max', 'Position', 'Frequency', 'LineSize', 'PageSize',
    'Orientation', 'TickStyle', 'OnChange');
begin
  case StringIndex(PropName, Properties) of
    0 : fMin := Reader.IntegerProperty;
    1 : fMax := Reader.IntegerProperty;
    2 : fPosition := Reader.IntegerProperty;
    3 : fFrequency := Reader.IntegerProperty;
    4 : fLineSize := Reader.IntegerProperty;
    5 : fPageSize := Reader.IntegerProperty;
    6 : Reader.IdentProperty(fOrientation, TypeInfo(TOrientation));
    7 : Reader.IdentProperty(fTickStyle, TypeInfo(TTickStyle));
    8 : TMethod(EOnChange) := FindMethod(Reader);
    else inherited;
  end;
end;

procedure TTrackBar.SetMin(Value: integer);
begin
  SetRange(Value, fMax);
end;

procedure TTrackBar.SetMax(Value: integer);
begin
  SetRange(fMin, Value);
end;

procedure TTrackBar.SetRange(ValueMin, ValueMax: integer);
begin
  fMin := ValueMin;
  fMax := ValueMax;
  LLCL_SendMessage(Handle, TBM_SETRANGE, 0, LPARAM(fMin or (fMax shl 16)));
end;

function TTrackBar.GetPosition(): integer;
begin
  fPosition := LLCL_SendMessage(Handle, TBM_GETPOS, 0, 0);
  result := fPosition;
end;

procedure TTrackBar.SetPosition(Value: integer);
begin
  fPosition := Value;
  LLCL_SendMessage(Handle, TBM_SETPOS, WPARAM(fPosition), 0);
end;

procedure TTrackBar.SetFrequency(Value: integer);
begin
  fFrequency := Value;
  LLCL_SendMessage(Handle, TBM_SETTICFREQ, WPARAM(fFrequency), 0);
end;

procedure TTrackBar.SetLineSize(Value: integer);
begin
  fLineSize := Value;
  LLCL_SendMessage(Handle, TBM_SETLINESIZE, 0, LPARAM(fLineSize));
end;

procedure TTrackBar.SetPageSize(Value: integer);
begin
  fPageSize := Value;
  LLCL_SendMessage(Handle, TBM_SETPAGESIZE, 0, LPARAM(fPageSize));
end;

// Scroll messages coming from form
function TTrackBar.ComponentNotif(var Msg: TMessage): boolean;
begin
  result := inherited ComponentNotif(Msg);
  case Msg.Msg of
  WM_HSCROLL, WM_VSCROLL:
    if fOnChangeOK and Assigned(EOnChange) then
      EOnChange(Self);
  end;
end;

//------------------------------------------------------------------------------

function InitCommonControl(CC: integer): Boolean;
begin
  result := LLCLS_InitCommonControl(CC);
end;

//------------------------------------------------------------------------------

initialization
  RegisterClasses([TProgressBar, TTrackBar]);

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
