unit Grids;

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
    * Bug fix for ColCount and RowCount modification
   Version 1.01:
    * File creation.
    * TStringGrid implemented
}

{$IFDEF FPC}
  {$define LLCL_FPC_MODESECTION}
  {$I LLCLFPCInc.inc}             // For mode
  {$undef LLCL_FPC_MODESECTION}
{$ENDIF}

{$I LLCLOptions.inc}      // Options

//------------------------------------------------------------------------------

interface

// Various conditional options
//   Undefining following: better TStringGrid compatibility, bigger executable
{$define DefNo_DefaultRowHeight}    // No DefaultRowHeight support (for instance to allow possible use of ImageList in ListView control)
{$define DefNo_ColumnSort}          // No column sort
{$define DefNo_StdMouseMessages}    // No mouse messages standardization
{$define DefNo_HeaderSupport}       // No specific header support
{$define DefNo_Column1Edit}         // No edition possible for 1st column
//   Undefining following: better ListView compatibility, slightly bigger executable
{$define DefNo_RightClickSelect}    // No right-click allowed to select (need to undefine DefNo_StdMouseMessages for full support)
{$define DefNo_CtrlASelectAll}      // No Ctrl+A to select all

// All previous options
{$ifdef LLCL_OPT_GRIDSOPT_ALL}
  {$define LLCL_OPT_GRIDSOPT_2}
  {$define LLCL_OPT_GRIDSOPT_LV}
{$endif}
// TStringGrid compatibility Level 2
{$ifdef LLCL_OPT_GRIDSOPT_2}
  {$define LLCL_OPT_GRIDSOPT_1}
  {$undef DefNo_StdMouseMessages}{$undef DefNo_HeaderSupport}{$undef DefNo_Column1Edit}
{$endif}
// TStringGrid compatibility Level 1
{$ifdef LLCL_OPT_GRIDSOPT_1}
  {$undef DefNo_DefaultRowHeight}{$undef DefNo_ColumnSort}
{$endif}
// ListView compatibility
{$ifdef LLCL_OPT_GRIDSOPT_LV}
  {$undef DefNo_RightClickSelect}{$undef DefNo_CtrlASelectAll}
{$endif}

uses
  LLCLOSInt, Windows, {$IFDEF FPC}LCLType, LMessages{$ELSE}Messages{$ENDIF},
  Classes, Controls, Graphics;

type
  TGridOption = (goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine,
    goRangeSelect, goDrawFocusSelected, goRowSizing, goColSizing, goRowMoving,
    goColMoving, goEditing, goTabs, goRowSelect, goAlwaysShowEditor, goThumbTracking);
  TGridOptions = set of TGridOption;
  TSortOrder = (soAscending, soDescending);

  TGridCoord = record
    X: integer;
    Y: integer;
  end;
  TGridRect = record
    case Integer of
      0: (Left, Top, Right, Bottom: integer);
      1: (TopLeft, BottomRight: TGridCoord);
  end;

  TOnSelectCellEvent = procedure (Sender: TObject; ACol, ARow: integer; var CanSelect: boolean) of object;
  TOnCompareCells = procedure (Sender: TObject; ACol, ARow, BCol, BRow: integer; var Result: integer) of object;
  THdrEvent = procedure(Sender: TObject; IsColumn: boolean; Index: integer) of object;
  TGetEditEvent = procedure (Sender: TObject; ACol, ARow: integer; var Value: string) of object;
  TSetEditEvent = procedure (Sender: TObject; ACol, ARow: integer; const Value: string) of object;

  // (No intermediate classes used)
  TStringGrid = class(TWinControl)
  private
    fColCount,
    fRowCount: integer;
    fDefaultColWidth,
    fDefaultRowHeight: integer;
    fFixedCols,
    fFixedRows: integer;
    fRealFixedRows: integer;      // (No RealFixedCols property as FixedCols is ignored)
    fOptions: TGridOptions;
    fColWidths: array of integer;
    fRowHeights: array of integer;
    fHasInitColWidths,
    fHasInitRowHeights: boolean;
    fCol,
    fRow: integer;
    fSelection: TGridRect;
    fInitialCells: TStringList;
    {$ifndef DefNo_DefaultRowHeight}
    fImageListHandle: HIMAGELIST;
    {$endif DefNo_DefaultRowHeight}
    EOnSelectCell: TOnSelectCellEvent;
    fSortOrder: TSortOrder;           // Theoretically, only for
    fColumnClickSorts: boolean;       //   FPC/Lazarus (not for Delphi)
    fSortColumn: integer;             //      "                   "
    EOnCompareCells: TOnCompareCells; //      "                   "
    EOnHeaderClick: THdrEvent;        //      "                   "
    EOnGetEditText: TGetEditEvent;
    EOnSetEditText: TSetEditEvent;
    // (internals)
    fRowSelect: boolean;
    fCurCtrlState: integer;           // 0=None, 1=Ctrl+A, 2=Ctrl+Other (Click, Space, ...)
    fLastItemFocused: integer;
    {$ifndef DefNo_HeaderSupport}
    fhWndHeader: THandle;
    fHeaderWndProc: TFNWndProc;
    {$else DefNo_HeaderSupport}
    hWndHeader: THandle;
    {$endif DefNo_HeaderSupport}
    //
    procedure AddCols(Value: integer; Base: integer; UseDefColWidth: boolean);
    procedure DelCols(Value: integer; Base: integer);
    procedure AddRows(Value: integer; Base: integer; UseDefRowHeight: boolean);
    procedure DelRows(Value: integer; Base: integer);
    procedure SetColCount(AValue: integer);
    procedure SetRowCount(AValue: integer);
    procedure SetDefaultColWidth(AValue: integer);
    procedure SetDefaultRowHeight(AValue: integer);
    function  GetColWidths(Index: integer): integer;
    procedure SetColWidths(Index: integer; Value: integer);
    function  GetRowHeights(Index: integer): integer;
    procedure SetRowHeights(Index: integer; Value: integer);
    function  GetCells(ACol, ARow: integer): string;
    procedure SetCells(ACol, ARow: integer; const Value: string);
    function  GetInitialCellsIndex(ACol, ARow: integer): integer;
    function  GetInitialCells(ACol, ARow: integer): string;
    procedure SetInitialCells(ACol, ARow: integer; const Value: string);
    function  GetCols(Index: integer): TStringList;
    procedure SetCols(Index: integer; Value: TStringList);
    function  GetRows(Index: integer): TStringList;
    procedure SetRows(Index: integer; Value: TStringList);
    procedure SetCol(AValue: integer);
    function  GetRow(): integer;
    procedure SetRow(AValue: integer);
    function  GetSelection(): TGridRect;
    function  NewRealFixedRows(NewValue: integer): integer;
    procedure UpdRealFixedRows(NewValue: integer);
    function  CheckColRow(ACol, ARow: integer; Mode: integer): boolean;
    function  IsColumnOK(ACol: integer): boolean;
    procedure UpdateHeaderStyle();
    procedure ModifyHeaderStyle(AValue: cardinal; AMask: cardinal);
    procedure SetColumnClickSorts(AValue: boolean);
    {$ifndef DefNo_ColumnSort}
    procedure ModifyHeaderColFmt(ACol: integer; AMode: integer);
    procedure CallSort(FormerSortColumn: integer);
    {$endif DefNo_ColumnSort}
    procedure RestoreLastFocusedItem();
    function  ProcessNotification(var Msg: TMessage; IsForHeader: boolean): boolean;
    {$ifndef DefNo_Column1Edit}
    procedure CallEditCurRow();
    {$endif DefNo_Column1Edit}
    {$ifndef DefNo_HeaderSupport}
    procedure ForMouseButton(MouseButton: TMouseButton; ShiftState: TShiftState; alParam: NativeUInt; EOnMouse: TMouseEvent);
    function  GethWndHeader(): THandle;
    procedure SethWndHeader(Value: THandle);
    property  hWndHeader: THandle read GethWndHeader write SethWndHeader;
    {$endif DefNo_HeaderSupport}
  protected
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    {$if (not Defined(DefNo_CtrlASelectAll)) or (not Defined(DefNo_Column1Edit))}
    function  SpecialKeyProcess(var CharCode: Word): TKeyProcess; override;
    {$ifend}
    procedure SetColor(AValue: integer); override;
    {$if (not Defined(DefNo_HeaderSupport)) or (not Defined(DefNo_Column1Edit))}
    function  ForwardChildMsg(var Msg: TMessage; WndChild: THandle): boolean; override;
    {$ifend}
    function  ComponentNotif(var Msg: TMessage): boolean; override;
    {$ifndef DefNo_StdMouseMessages}
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;   // (received only with DblClick)
    procedure WMRButtonDown(var Msg: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMRButtonUp(var Msg: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMLDblClick(var Msg: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMRDblClick(var Msg: TWMRButtonDblClk); message WM_RBUTTONDBLCLK;
    {$endif DefNo_StdMouseMessages}
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure SortColRow(IsColumn: boolean; Index: integer);      // Only for columns (i.e. IsColumn=true)
    property  Options: TGridOptions read fOptions write fOptions; // Run-time modification ignored; write present only for dynamical control creation purpose
    property  ColCount: integer read fColCount write SetColCount;
    property  RowCount: integer read fRowCount write SetRowCount;
    property  DefaultColWidth: integer read fDefaultColWidth write SetDefaultColWidth;
    property  DefaultRowHeight: integer read fDefaultRowHeight write SetDefaultRowHeight;   // LLCL: Fixed row (i.e. title) not concerned
    property  ColWidths[Index: integer]: integer read GetColWidths write SetColWidths;
    property  RowHeights[Index: integer]: integer read GetRowHeights write SetRowHeights;   // LLCL: Ignored
    property  FixedRows: integer read fFixedRows write fFixedRows;  // LLCL: Just 0 or (<>0=)1 - Run-time modification ignored; write present only for dynamical control creation purpose
    property  FixedCols: integer read fFixedCols write fFixedCols;  // LLCL: Ignored
    property  Cells[ACol, ARow: integer]: string read GetCells write SetCells;
    property  Cols[Index: integer]: TStringList read GetCols write SetCols;
    property  Rows[Index: integer]: TStringList read GetRows write SetRows;
    property  Col: integer read fCol write SetCol;                  // LLCL: (mainly) Ignored
    property  Row: integer read GetRow write SetRow;
    property  Selection: TGridRect read GetSelection;
    property  OnSelectCell: TOnSelectCellEvent read EOnSelectCell write EOnSelectCell;
    property  SortOrder: TSortOrder read fSortOrder write fSortOrder;
    property  SortColumn: integer read fSortColumn;
    property  ColumnClickSorts: boolean read fColumnClickSorts write SetColumnClickSorts;
    property  OnCompareCells: TOnCompareCells read EOnCompareCells write EOnCompareCells;
    property  OnHeaderClick: THdrEvent read EOnHeaderClick write EOnHeaderClick;
    property  OnGetEditText: TGetEditEvent read EOnGetEditText write EOnGetEditText;
    property  OnSetEditText: TSetEditEvent read EOnSetEditText write EOnSetEditText;
  end;

//------------------------------------------------------------------------------

implementation

uses
{$IFNDEF FPC}
  CommCtrl,
{$ENDIF}
  SysUtils;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

{$IFDEF FPC}
// Some ListView constants
//   - to avoid CommCtrl: conflict with Variants unit
//   - and to avoid warnings (range check error)
const
  LVS_EX_GRIDLINES              = $00000001;
  LVS_EX_HEADERDRAGDROP         = $00000010;
  LVS_EX_FULLROWSELECT          = $00000020;
  LVM_FIRST                     = $1000;
  LVM_GETHEADER                 = (LVM_FIRST + 31);
  LVM_SETEXTENDEDLISTVIEWSTYLE  = (LVM_FIRST + 54);
  LVN_FIRST                     = UINT(- 100);
  LVN_ITEMCHANGING              = UINT(LVN_FIRST - 0);
  LVN_ITEMCHANGED               = UINT(LVN_FIRST - 1);
{$ifndef DefNo_ColumnSort}
  LVN_COLUMNCLICK               = UINT(LVN_FIRST - 8);
{$endif DefNo_ColumnSort}
{$ifndef DefNo_Column1Edit}
  LVN_KEYDOWN                   = UINT(LVN_FIRST - 55);
  LVN_BEGINLABELEDITA           = UINT(LVN_FIRST - 5);
  LVN_BEGINLABELEDITW           = UINT(LVN_FIRST - 75);
  LVN_ENDLABELEDITA             = UINT(LVN_FIRST - 6);
  LVN_ENDLABELEDITW             = UINT(LVN_FIRST - 76);
{$endif DefNo_Column1Edit}
  NM_FIRST                      = 0;
  NM_CLICK                      = UINT(NM_FIRST - 2);
{$ifndef DefNo_StdMouseMessages}
  NM_DBLCLK                     = UINT(NM_FIRST - 3);
  NM_RCLICK                     = UINT(NM_FIRST - 5);
  NM_RDBLCLK                    = UINT(NM_FIRST - 6);
{$else DefNo_StdMouseMessages}
{$ifndef DefNo_Column1Edit}
  NM_DBLCLK                     = UINT(NM_FIRST - 3);
{$endif DefNo_Column1Edit}
{$endif DefNo_StdMouseMessages}
{$ENDIF FPC}
// Missing ListView constants
const
{$ifndef DefNo_ColumnSort}
  LVM_SORTITEMSEX               = (LVM_FIRST + 81);
	HDF_SORTUP			              = $0400;
	HDF_SORTDOWN		              = $0200;
{$endif DefNo_ColumnSort}
  HDS_NOSIZING                  = $0800;
  LVKF_ALT                      = $0001;
  LVKF_CONTROL                  = $0002;
  LVKF_SHIFT                    = $0004;

{$ifndef DefNo_StdMouseMessages}
type
  TNMItemActivate = record
    hdr:              NMHDR;
    iItem:            integer;
    iSubItem:         integer;
    uNewState:        cardinal;
    uOldState:        cardinal;
    uChanged:         cardinal;
    ptAction:         TPOINT;
    lParam:           LPARAM;
    uKeyFlags:        cardinal
  end;
  PNMItemActivate = ^TNMItemActivate;
{$endif DefNo_StdMouseMessages}

{$ifndef DefNo_Column1Edit}
  TNMLVKeyDown = record
    hdr:              NMHDR;
    wVKey:            Word;
    flags:            cardinal;
  end;
  PNMLVKeyDown = ^TNMLVKeydown;

  TNMLVDispInfo = record
    hdr:              NMHDR;
    item:             LV_ITEM;
  end;
  PNMLVDispInfo = ^TNMLVDispInfo;
{$endif DefNo_Column1Edit}

procedure LV_SetColumnTitleText(hwndLV: HWND; iCol: integer; sText: string); forward;
procedure LV_SetItemText(hwndLV: HWND; iItem, iSubItem: integer; sText: string); forward;
procedure LV_SetItemState(hwndLV: HWND; iItem: integer; state, stateMask: cardinal); forward;
{$ifndef DefNo_ColumnSort}
function  LV_CompareFunc(iItem1: LPARAM; iItem2: LPARAM; Handle: LPARAM): integer; stdcall; forward;
{$endif DefNo_ColumnSort}
function  LV_KeysToShiftState(Keys: cardinal): TShiftState; forward;

{$ifndef DefNo_HeaderSupport}
function  ELVWndProc(hWnd: THandle; Msg: cardinal; awParam, alParam: NativeUInt): NativeUInt; stdcall; forward;
{$endif DefNo_HeaderSupport}

// Workaround for Unicode FPC when using the standard SysUtils unit
{$if Defined(FPC) and Defined(UNICODE) and Declared(MaxEraCount)}
  {$define Def_FPC_StdSys}
{$ifend}
{$ifdef Def_FPC_StdSys}
function  Grids_IntToStr(Value: integer): string; forward;
function  Grids_StrToInt(const S: string): integer; forward;
{$endif}

//------------------------------------------------------------------------------

{$IFDEF FPC}
// Dummy function to avoid compilation hint (LMessages not used)
function LMessages_Dummy(const Msg: TLMCommand): boolean;
begin
  result := false;
end;
{$ENDIF FPC}

procedure LV_SetColumnTitleText(hwndLV: HWND; iCol: integer; sText: string);
var lvc: LV_COLUMN;
begin
  FillChar(lvc, SizeOf(lvc), 0);
  lvc.mask := LVCF_TEXT;
  // lvc.pszText set in function call
  LLCLS_LV_SetColumnWithTitleText(2, hwndLV, iCol, lvc, sText);   // 2=SETCOLUMN
end;

procedure LV_SetItemText(hwndLV: HWND; iItem, iSubItem: integer; sText: string);
var lvi: LV_ITEM;
begin
  FillChar(lvi, SizeOf(lvi), 0);
  lvi.mask := LVIF_TEXT;
  lvi.iItem := iItem;
  lvi.iSubItem := iSubItem;
  // lvi.pszText set in function call
  LLCLS_LV_SetItemWithText(2, hwndLV, lvi, sText);  // 2=SETTITEM
end;

procedure LV_SetItemState(hwndLV: HWND; iItem: integer; state, stateMask: cardinal);
var lvi: LV_ITEM;
begin
  // ListView_SetItemState(hwndLV, iItem, state, stateMask);
  FillChar(lvi, SizeOf(lvi), 0);
  lvi.state := state;
  lvi.stateMask := stateMask;
  LLCL_SendMessage(hwndLV, LVM_SETITEMSTATE, iItem, LPARAM(@lvi));
end;

{$ifndef DefNo_ColumnSort}
// Callback function for Listview sorting
function  LV_CompareFunc(iItem1: LPARAM; iItem2: LPARAM; Handle: LPARAM): integer; stdcall;
var obj: TObject;
var i1, i2: integer;
var s1, s2: string;
begin
  result := 0;
  obj := TObject(LLCL_GetWindowLongPtr(THandle(Handle), GWL_USERDATA));
  if Assigned(obj) then
    with TStringGrid(obj) do
      begin
        i1 := iItem1 + fRealFixedRows;
        i2 := iItem2 + fRealFixedRows;
        if (i1<fRowCount) and (i2<fRowCount)  // Sanity
          and IsColumnOK(fSortColumn) then    //
          begin
            if Assigned(EOnCompareCells) then
              EOnCompareCells(obj, fSortColumn, i1, fSortColumn, i2, result)
            else
              begin
                s1 := Cells[fSortColumn, i1];
                s2 := Cells[fSortColumn, i2];
                result := LLCLS_CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, s1, s2) - 2;
                if fSortOrder=soDescending then
                  result := -result;
              end;
          end;
      end;
end;
{$endif DefNo_ColumnSort}

// Similar to LLCLS_KeysToShiftState
function  LV_KeysToShiftState(Keys: cardinal): TShiftState;
begin
  result := [];
  if Keys and LVKF_SHIFT<>0 then Include(result, ssShift);
  if Keys and LVKF_CONTROL<>0 then Include(result, ssCtrl);
  if Keys and LVKF_ALT<>0 then Include(result, ssAlt);
end;

{$ifndef DefNo_HeaderSupport}
// Callback function for Listview Header Control (StringGrid)
function  ELVWndProc(hWnd: THandle; Msg: cardinal; awParam, alParam: NativeUInt): NativeUInt; stdcall;
var obj: TObject;
var LVWndProc: TFNWndProc;
var MouseButton: TMouseButton;
begin
  LVWndProc := nil;
  obj := TObject(LLCL_GetWindowLongPtr(hWnd, GWL_USERDATA));
  if Assigned(obj) then
    with TStringGrid(obj) do
      begin
        LVWndProc := fHeaderWndProc;
        case Msg of
        WM_LBUTTONDOWN, WM_LBUTTONUP, WM_LBUTTONDBLCLK,
        WM_RBUTTONDOWN, WM_RBUTTONUP, WM_RBUTTONDBLCLK:
          begin
            case Msg of
            WM_LBUTTONDOWN, WM_LBUTTONUP, WM_LBUTTONDBLCLK:
              begin
                MouseButton := mbLeft;
                SetFocus;
              end
            else
              MouseButton := mbRight;
            end;
            case Msg of
            WM_LBUTTONDOWN, WM_RBUTTONDOWN:
                ForMouseButton(MouseButton, TShiftState(LLCLS_KeysToShiftState(awParam)), alParam, OnMouseDown);
            WM_LBUTTONUP, WM_RBUTTONUP:
                ForMouseButton(MouseButton, TShiftState(LLCLS_KeysToShiftState(awParam)), alParam, OnMouseUp);
            WM_LBUTTONDBLCLK, WM_RBUTTONDBLCLK:
                begin
{$IFDEF FPC}
                  ForMouseButton(MouseButton, TShiftState(LLCLS_KeysToShiftState(awParam)) + [ssDouble], alParam, OnMouseDown);
                  if (Msg=WM_LBUTTONDBLCLK) and Assigned(OnDblClick) then
                    OnDblClick(TStringGrid(obj));
{$ELSE FPC}
                  if (Msg=WM_LBUTTONDBLCLK) and Assigned(OnDblClick) then
                    OnDblClick(TStringGrid(obj));
                  ForMouseButton(MouseButton, TShiftState(LLCLS_KeysToShiftState(awParam)) + [ssDouble], alParam, OnMouseDown);
{$ENDIF}
                end;
            end;
          end;
        end;
      end;
  if not Assigned(LVWndProc) then
    result := LLCL_DefWindowProc(hWnd, Msg, awParam, alParam)
  else
    result := LLCL_CallWindowProc({$IFDEF FPC}TFNWndProc(LVWndProc){$ELSE}LVWndProc{$ENDIF}, hWnd, Msg, awParam, alParam);
end;
{$endif DefNo_HeaderSupport}

{$ifdef Def_FPC_StdSys}
function  Grids_IntToStr(Value: integer): string;
begin
  Str(Value, result);
end;

function  Grids_StrToInt(const S: string): integer;
var E: integer;
begin
  Val(S, result, E);
  if E<>0 then
    result := 0;
end;
{$endif Def_FPC_StdSys}

{ TStringGrid }

constructor TStringGrid.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTStringGrid;
  fColCount := 5;
  fRowCount := 5;
  fFixedCols := 1;
  fFixedRows := 1;
  {$ifndef DefNo_ColumnSort}
  fSortColumn := -1;
  {$endif DefNo_ColumnSort}
  fDefaultColWidth := 64;
  fDefaultRowHeight := {$IFDEF FPC}20{$ELSE}24{$ENDIF};
  fOptions := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect];
  SetLength(fColWidths, 0);
  SetLength(fRowHeights, 0);
  ArrowKeysInternal := true;
  Color := LLCL_GetSysColor(integer(clWindow) and $FF);
  fInitialCells := TStringList.Create;
end;

procedure TStringGrid.CreateHandle;
const
  ICC_LISTVIEW_CLASSES  = $0001;    // (See remark for InitCommonControl)
var PostExStyle: cardinal;
var i: integer;
begin
  LLCLS_InitCommonControl(ICC_LISTVIEW_CLASSES);    // Avoid to include ComCtrls just for InitCommonControl
  inherited;
  PostExStyle := 0;
  if (goVertLine in fOptions) or (goHorzLine in fOptions) then
    PostExStyle := PostExStyle or LVS_EX_GRIDLINES;
  if goRowSelect in fOptions then
    begin
      PostExStyle := PostExStyle or LVS_EX_FULLROWSELECT;
      fRowSelect := true;
    end;
  if goColMoving in fOptions then
    PostExStyle := PostExStyle or LVS_EX_HEADERDRAGDROP;
  if PostExStyle<>0 then
    // ListView_SetExtendedListViewStyle(Handle, PostExStyle);
    LLCL_SendMessage(Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, PostExStyle);
  // Default
  SetLength(fColWidths, fColCount);
  SetLength(fRowHeights, fRowCount);
  SetDefaultRowHeight(fDefaultRowHeight);
  // Colors
  if HasDesignColor or (not ParentFont) then
    SetColor(Color);
  // Columns and Rows
  if (fColCount>0) then
    AddCols(fColCount, 0, (not fHasInitColWidths));
  if (fRowCount - fRealFixedRows)>0 then      // fRealFixedRows has been set in CreateParams
    AddRows(fRowCount - fRealFixedRows, 0, (not fHasInitRowHeights));
  // Header
  UpdateHeaderStyle();
  // Initial Selection
  if fRowCount>fRealFixedRows then Row := fRealFixedRows;
  if fColCount>0 then Col := 0;
  // Initial Cell values
  if fInitialCells.Count>0 then
    begin
      for i := 0 to pred({$ifdef Def_FPC_StdSys}Grids_StrToInt{$else}StrToInt{$endif}(fInitialCells[0])) do
        SetCells({$ifdef Def_FPC_StdSys}Grids_StrToInt{$else}StrToInt{$endif}(fInitialCells[1 + (i*3) + 0]), {$ifdef Def_FPC_StdSys}Grids_StrToInt{$else}StrToInt{$endif}(fInitialCells[1 + (i*3) + 1]), fInitialCells[1 + (i*3) + 2]);
      fInitialCells.Clear;
    end;
{$ifndef DefNo_ColumnSort}
  // Sort
  if IsColumnOK(fSortColumn) then
    CallSort(-1);
{$endif DefNo_ColumnSort}
end;

procedure TStringGrid.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
    begin
      WinClassName := WC_LISTVIEW;
      Style := Style or LVS_REPORT;
      fRealFixedRows := NewRealFixedRows(fFixedRows);
      if fRealFixedRows=0 then
        Style := Style or LVS_NOCOLUMNHEADER;
      if not (goRangeSelect in fOptions) then
        Style := Style or LVS_SINGLESEL;
      if goRowSelect in fOptions then
        Style := Style or LVS_SHOWSELALWAYS;
      {$ifndef DefNo_Column1Edit}
      if goEditing in fOptions then
        Style := Style or LVS_EDITLABELS;
      {$endif DefNo_Column1Edit}
      ExStyle := ExStyle or WS_EX_STATICEDGE;
    end;
end;

procedure TStringGrid.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..15] of PChar = (
    'ColCount', 'RowCount', 'FixedCols', 'FixedRows', 'DefaultColWidth', 'DefaultRowHeight','Options',
    'ColWidths', 'RowHeights', 'Cells', 'OnSelectCell', 'OnGetEditText', 'OnSetEditText', 'OnCompareCells', 'OnHeaderClick', 'ColumnClickSorts');
begin
  case StringIndex(PropName, Properties) of
    0 : fColCount := Reader.IntegerProperty;
    1 : fRowCount := Reader.IntegerProperty;
    2 : fFixedCols := Reader.IntegerProperty;
    3 : fFixedRows := Reader.IntegerProperty;
    4 : fDefaultColWidth := Reader.IntegerProperty;
    5 : fDefaultRowHeight := Reader.IntegerProperty;
    6 : Reader.SetProperty(fOptions, TypeInfo(TGridOption));
    7 : if fColCount>0 then
          begin
            SetLength(fColWidths, fColCount);
            Reader.ReadIntArray(fColWidths);
            fHasInitColWidths := true;
          end;
    8 : if fRowCount>0 then
          begin
            SetLength(fRowHeights, fRowCount);
            Reader.ReadIntArray(fRowHeights);
            fHasInitRowHeights := true;
          end;
    9 : Reader.ReadStringInts(fInitialCells);
    10: TMethod(EOnSelectCell)  := FindMethod(Reader);
    11: TMethod(EOnGetEditText)  := FindMethod(Reader);
    12: TMethod(EOnSetEditText)  := FindMethod(Reader);
    13: TMethod(EOnCompareCells) := FindMethod(Reader);
    14: TMethod(EOnHeaderClick)  := FindMethod(Reader);
    15: fColumnClickSorts := Reader.BooleanProperty;
    else inherited;
  end;
end;

destructor TStringGrid.Destroy;
begin
  hWndHeader := 0;
  fInitialCells.Free;
  // fImageListHandle is supposed to be destroyed by Windows when the ListView control is destroyed
  inherited;
end;

{$if (not Defined(DefNo_CtrlASelectAll)) or (not Defined(DefNo_Column1Edit))}
function  TStringGrid.SpecialKeyProcess(var CharCode: Word): TKeyProcess;
begin
  result := inherited SpecialKeyProcess(CharCode);  // tkStandard by default
  {$ifndef DefNo_CtrlASelectAll}
  // Ctrl+A = Select All
  if CharCode=cardinal(^A) then
    begin
      // Select all (don't change focus)
      fCurCtrlState := 1;
      LV_SetItemState(Handle, -1, LVIS_SELECTED , LVIS_SELECTED);
      fCurCtrlState := 0;
      result := tkSkip;
    end;
  {$endif DefNo_CtrlASelectAll}
  {$ifndef DefNo_Column1Edit}
  // Enter (processed in ProcessNotification);
  if CharCode=VK_RETURN then
    if goEditing in fOptions then
      result := tkForceStandard ;
  {$endif DefNo_Column1Edit}
end;
{$ifend}

procedure TStringGrid.SetColor(AValue: integer);
var AColor: integer;
begin
  inherited;
  if Handle=0 then exit;  // Because may be called before created
  // ListView_SetBkColor(Handle, Color);
  LLCL_SendMessage(Handle, LVM_SETBKCOLOR, 0, Color);
  // ListView_SetTextBkColor(Handle, Color);
  LLCL_SendMessage(Handle, LVM_SETTEXTBKCOLOR, 0, Color);
  AColor := Font.Color;
  if ParentFont and (Parent<>nil) then
    AColor := Parent.Font.Color;
  // ListView_SetTextColor(Handle, AColor);
  LLCL_SendMessage(Handle, LVM_SETTEXTCOLOR, 0, AColor);
  // Forces full paint
  LLCL_InvalidateRect(Handle, nil, true);
end;

{$if (not Defined(DefNo_HeaderSupport)) or (not Defined(DefNo_Column1Edit))}
function  TStringGrid.ForwardChildMsg(var Msg: TMessage; WndChild: THandle): boolean;
begin
  // (No inherited - TStringGrid has not child controls)
  result := (hWndHeader<>0) and (WndChild=hWndHeader);
  if result then
    result := ProcessNotification(Msg, true);
end;
{$ifend}

function  TStringGrid.ComponentNotif(var Msg: TMessage): boolean;
begin
  result := inherited ComponentNotif(Msg);
  if result then
    result := ProcessNotification(Msg, false);
end;

{$ifndef DefNo_StdMouseMessages}
// All mouse messages for Listview are processed only in ComponentNotif
//   because ListView eats/interprets them
// For instance, for a left button click the received messages are:
//   WM_NOTIFY(NM_CLICK), then WM_LBUTTONDOWN (WM_LBUTTONUP absent and WM_LBUTTONDOWN after click)
//
// On the contrary, all all mouse messages for Listview Control Header
//   are processed through the specific callback function (see ELVWndProc)
procedure TStringGrid.WMLButtonDown(var Msg: TWMLButtonDown);
begin
  DefaultHandler(Msg);  // (Processed in ComponentNotif)
end;

procedure TStringGrid.WMLButtonUp(var Msg: TWMLButtonUp);
begin
  DefaultHandler(Msg);  // (Processed in ComponentNotif)
end;

procedure TStringGrid.WMRButtonDown(var Msg: TWMRButtonDown);
begin
  DefaultHandler(Msg);  // (Processed in ComponentNotif)
end;

procedure TStringGrid.WMRButtonUp(var Msg: TWMRButtonUp);
begin
  DefaultHandler(Msg);  // (Processed in ComponentNotif)
end;

procedure TStringGrid.WMLDblClick(var Msg: TWMLButtonDblClk);
begin
  DefaultHandler(Msg);  // (Processed in ComponentNotif)
end;

procedure TStringGrid.WMRDblClick(var Msg: TWMRButtonDblClk);
begin
  DefaultHandler(Msg);  // (Processed in ComponentNotif)
end;
{$endif DefNo_StdMouseMessages}

procedure TStringGrid.AddCols(Value: integer; Base: integer; UseDefColWidth: boolean);
var lvc: LV_COLUMN;
var i: integer;
begin
  if Handle=0 then exit;  // Because may be called before created
  FillChar(lvc, SizeOf(lvc), 0);
  for i:=0 to pred(Value) do
    begin
      lvc.mask := LVCF_FMT or LVCF_WIDTH or LVCF_TEXT or LVCF_SUBITEM;
      lvc.fmt := LVCFMT_LEFT;       // (could be changed)
      // lvc.pszText set in function call
      lvc.cchTextMax := LLCLC_LISTVIEW_MAXCHAR;
      lvc.iSubItem := Base + i;
      if UseDefColWidth then
        fColWidths[lvc.iSubItem] := fDefaultColWidth;
      lvc.cx := fColWidths[lvc.iSubItem];
      // ListView_InsertColumn(Handle, lvc.iSubItem, lvc);
      LLCLS_LV_SetColumnWithTitleText(1, Handle, lvc.iSubItem, lvc, '');   // 1=INSERTCOLUMN
    end;
end;

procedure TStringGrid.DelCols(Value: integer; Base: integer);
var i, TmpValue: integer;
begin
  if Handle=0 then exit;  // Because may be called before created
  TmpValue := Value;
  if (Base-Value)<0 then TmpValue := Base;    // Sanity
  for i:=0 to pred(TmpValue) do
    // ListView_DeleteColumn(Handle, Base-i);
    LLCL_SendMessage(Handle, LVM_DELETECOLUMN, pred(Base-i), 0);
end;

procedure TStringGrid.AddRows(Value: integer; Base: integer; UseDefRowHeight: boolean);
var lvi: LV_ITEM;
var i: integer;
begin
  if Handle=0 then exit;  // Because may be called before created
  FillChar(lvi, SizeOf(lvi), 0);
  for i:=0 to pred(Value) do
    begin
      lvi.mask := LVIF_TEXT or LVIF_DI_SETITEM;
      // lvi.pszText set in function call
      lvi.cchTextMax := LLCLC_LISTVIEW_MAXCHAR;
      lvi.iItem := Base + i;
      if UseDefRowHeight then
        fRowHeights[lvi.iItem] := fDefaultRowHeight;
      // ListView_InsertItem(Handle, lvi);
      LLCLS_LV_SetItemWithText(1, Handle, lvi, '');  // 1=INSERTITEM
    end;
end;

procedure TStringGrid.DelRows(Value: integer; Base: integer);
var i, TmpValue: integer;
begin
  if Handle=0 then exit;  // Because may be called before created
  TmpValue := Value;
  if (Base-Value)<0 then TmpValue := Base;    // Sanity
  if TmpValue=Base then
    // ListView_DeleteAllItems(Handle)
    LLCL_SendMessage(Handle, LVM_DELETEALLITEMS, 0, 0)
  else
    for i:=0 to pred(TmpValue) do
      // ListView_DeleteItem(Handle, Base-i);
      LLCL_SendMessage(Handle, LVM_DELETEITEM, pred(Base-i), 0);
end;

procedure TStringGrid.SetColCount(AValue: integer);
var TmpValue, SavColCount: integer;
begin
  SavColCount := fColCount;
  if AValue<0 then TmpValue := 0 else TmpValue := AValue;
  SetLength(fColWidths, TmpValue);
  fColCount := TmpValue;
  if TmpValue>SavColCount then
    AddCols(TmpValue - SavColCount, SavColCount, true)
  else
    if TmpValue<SavColCount then
      DelCols(SavColCount - TmpValue, SavColCount);
end;

procedure TStringGrid.SetRowCount(AValue: integer);
var TmpValue, SavRowCount: integer;
begin
  SavRowCount := fRowCount - fRealFixedRows;
  if AValue<0 then TmpValue := 0 else TmpValue := aValue;
  SetLength(fRowHeights, TmpValue);
  fRowCount := TmpValue;
  UpdRealFixedRows(NewRealFixedRows(fFixedRows));
  TmpValue := TmpValue - fRealFixedRows;
  if TmpValue>SavRowCount then
    begin
      AddRows(TmpValue - SavRowCount, SavRowCount, true);
      // Update selection if necessary
      if fRow<fRealFixedRows then
        Row := fRealFixedRows;
    end
  else
    if TmpValue<SavRowCount then
      begin
        DelRows(SavRowCount - TmpValue, SavRowCount);
        // Update selection if necessary
        if fRow>=fRowCount then
          Row := fRowCount - 1;
      end;
end;

procedure TStringGrid.SetDefaultColWidth(AValue: integer);
var i: integer;
begin
  for i:=0 to pred(fColCount) do
    SetColWidths(i, AValue);
end;

procedure TStringGrid.SetDefaultRowHeight(AValue: integer);
var i: integer;
begin
  for i:=0 to pred(fRowCount) do
    SetRowHeights(i, AValue);
{$ifndef DefNo_DefaultRowHeight}
  if Handle=0 then exit;  // Because may be called before created
  if fImageListHandle<>0 then
    LLCLS_LV_ImageList_Destroy(fImageListHandle);
  i := AValue;
  if i>=1 then i := i - 1;
  fImageListHandle := LLCLS_LV_ImageList_Create(1 , i, ILC_COLOR4, 10, 10);
  // ListView_SetImageList(Handle, fImageListHandle, LVSIL_SMALL);
  LLCL_SendMessage(Handle, LVM_SETIMAGELIST, LVSIL_SMALL, LPARAM(fImageListHandle));
{$endif DefNo_DefaultRowHeight}
end;

function  TStringGrid.GetColWidths(Index: integer): integer;
var lvc: LV_COLUMN;
begin
  result := fColWidths[Index];
  if Handle=0 then exit;  // Because may be called before created
  FillChar(lvc, SizeOf(lvc), 0);
  lvc.mask := LVCF_WIDTH;
  // ListView_GetColumn(Handle, Index, lvc);
  LLCL_SendMessage(Handle, LVM_GETCOLUMN, Index, LPARAM(@lvc));
  result := lvc.cx;
  fColWidths[Index] := result;
end;

procedure TStringGrid.SetColWidths(Index: integer; Value: integer);
var lvc: LV_COLUMN;
begin
  fColWidths[Index] := Value;
  if Handle=0 then exit;  // Because may be called before created
  FillChar(lvc, SizeOf(lvc), 0);
  lvc.mask := LVCF_WIDTH;
  lvc.cx := Value;
  // ListView_SetColumn(Handle, Index, lvc);
  LLCL_SendMessage(Handle, LVM_SETCOLUMN, Index, LPARAM(@lvc));
end;

function  TStringGrid.GetRowHeights(Index: integer): integer;
begin
  result := fRowHeights[Index];
end;

procedure TStringGrid.SetRowHeights(Index: integer; Value: integer);
begin
  fRowHeights[Index] := Value;
end;

function  TStringGrid.GetCells(ACol, ARow: integer): string;
begin
  CheckColRow(ACol, ARow, 1+2);   // 1+2: Check Column and Row
  if Handle=0 then    // Because may be called before created
    begin
      result := GetInitialCells(ACol, ARow);
      exit;
    end;
  if (fRealFixedRows>0) and (ARow=0) then
    result := LLCLS_LV_GetColumnTitleText(Handle, ACol)
  else
    result := LLCLS_LV_GetItemText(Handle, ARow - fRealFixedRows, ACol);
end;

procedure TStringGrid.SetCells(ACol, ARow: integer; const Value: string);
begin
  CheckColRow(ACol, ARow, 1+2);   // 1+2: Check Column and Row
  if Handle=0 then    // Because may be called before created
    begin
      SetInitialCells(ACol, ARow, Value);
      exit;
    end;
  if (fRealFixedRows>0) and (ARow=0) then
    LV_SetColumnTitleText(Handle, ACol, Value)
  else
    // ListView_SetItemText(Handle, ARow - fRealFixedRows, ACol, @Value[1]);
    LV_SetItemText(Handle, ARow - fRealFixedRows, ACol, Value);
end;

function  TStringGrid.GetInitialCellsIndex(ACol, ARow: integer): integer;
var i: integer;
begin
  result := -1;
  if fInitialCells.Count>0 then
    for i := 0 to pred({$ifdef Def_FPC_StdSys}Grids_StrToInt{$else}StrToInt{$endif}(fInitialCells[0])) do
      if ({$ifdef Def_FPC_StdSys}Grids_StrToInt{$else}StrToInt{$endif}(fInitialCells[1 + (i*3) + 0])=ACol) and ({$ifdef Def_FPC_StdSys}Grids_StrToInt{$else}StrToInt{$endif}(fInitialCells[1 + (i*3) + 1])=ARow) then
        begin
          result := i;
          break;
        end;
end;

// Gets initial cells value (instead of cells value)
function  TStringGrid.GetInitialCells(ACol, ARow: integer): string;
var i: integer;
begin
  result := '';
  i := GetInitialCellsIndex(ACol, ARow);
  if i>=0 then
    result := fInitialCells[1 + (i*3) + 2];
end;

// Sets initial cells value (instead of cells value)
procedure TStringGrid.SetInitialCells(ACol, ARow: integer; const Value: string);
var i: integer;
begin
  i := GetInitialCellsIndex(ACol, ARow);
  if i>=0 then
    fInitialCells[1 + (i*3) + 2] := Value
  else
    begin
      if fInitialCells.Count=0 then
        fInitialCells.Add('1')
      else
        fInitialCells[0] := {$ifdef Def_FPC_StdSys}Grids_IntToStr{$else}IntToStr{$endif}({$ifdef Def_FPC_StdSys}Grids_StrToInt{$else}StrToInt{$endif}(fInitialCells[0]) + 1);
      fInitialCells.Add({$ifdef Def_FPC_StdSys}Grids_IntToStr{$else}IntToStr{$endif}(ACol));
      fInitialCells.Add({$ifdef Def_FPC_StdSys}Grids_IntToStr{$else}IntToStr{$endif}(ARow));
      fInitialCells.Add(Value);
    end;
end;

function  TStringGrid.GetCols(Index: integer): TStringList;
var i: integer;
begin
  result := TStringList.Create;
  for i:=0 to pred(fColCount) do
    result.Add(GetCells(Index, i));
end;

procedure TStringGrid.SetCols(Index: integer; Value: TStringList);
var i: integer;
begin
  for i:=0 to pred(fColCount) do
    SetCells(Index, i, Value[i]);
end;

function  TStringGrid.GetRows(Index: integer): TStringList;
var i: integer;
begin
  result := TStringList.Create;
  for i:=0 to pred(fRowCount) do
    result.Add(GetCells(i, Index));
end;

procedure TStringGrid.SetRows(Index: integer; Value: TStringList);
var i: integer;
begin
  for i:=0 to pred(fColCount) do
    SetCells(i, Index, Value[i]);
end;

procedure TStringGrid.SetCol(AValue: integer);
var TmpValue: integer;
begin
  TmpValue := AValue;
{$IFDEF FPC}
  if TmpValue>=fColCount then TmpValue := fColCount - 1;  // Order
  if TmpValue<0 then TmpValue := 0;                       //   matters
{$ELSE}
  CheckColRow(0, TmpValue, 1);    // 1: Check Column only
{$ENDIF}
  fCol := TmpValue;
end;

function  TStringGrid.GetRow(): integer;
var i: integer;
begin
  result := fRow;
  if Handle=0 then exit;  // Because may be called before created
  // ListView_GetNextItem(Handle, -1, LVNI_SELECTED or LVNI_FOCUSED);
  i := LLCL_SendMessage(Handle, LVM_GETNEXTITEM, -1, LVNI_SELECTED or LVNI_FOCUSED);
  if i<0 then
    // ListView_GetNextItem(Handle, -1, LVNI_FOCUSED);
    i := LLCL_SendMessage(Handle, LVM_GETNEXTITEM, -1, LVNI_FOCUSED);
  if i<0 then i:=0;
  fRow := i + fRealFixedRows;
  result := fRow;
end;

procedure TStringGrid.SetRow(AValue: integer);
var TmpValue: integer;
begin
  TmpValue := AValue;
{$IFDEF FPC}
  if TmpValue>=fRowCount then TmpValue := fRowCount - 1;  // Order
  if TmpValue<0 then TmpValue := 0;                       //   matters
{$ELSE}
  CheckColRow(0, TmpValue, 2);    // 2: Check Row only
{$ENDIF}
  if (fRealFixedRows>0) and (TmpValue<fRealFixedRows) then
    if fRowCount>fRealFixedRows then
      TmpValue := fRealFixedRows
    else
      TmpValue := 0;
  fRow := TmpValue;
  if Handle=0 then exit;  // Because may be called before created
  // Unselect all
  LV_SetItemState(Handle, -1, 0, LVIS_SELECTED or LVIS_FOCUSED);
  // Select it
  if fRow>=fRealFixedRows then
    if (fRow - fRealFixedRows)<fRowCount then
      begin
        // ListView_EnsureVisible(Handle, fRow - fRealFixedRows, false);
        LLCL_SendMessage(Handle, LVM_ENSUREVISIBLE, fRow - fRealFixedRows, Ord(false));
        LV_SetItemState(Handle, fRow - fRealFixedRows, LVIS_SELECTED or LVIS_FOCUSED, LVIS_SELECTED or LVIS_FOCUSED);
      end;
end;

function  TStringGrid.GetSelection(): TGridRect;
var i: integer;
begin
  result := fSelection;
  if Handle=0 then exit;  // Because may be called before created
  // ListView_GetNextItem(Handle, -1, LVNI_SELECTED);
  i := LLCL_SendMessage(Handle, LVM_GETNEXTITEM, -1, LVNI_SELECTED);
  if i<0 then exit;   // Sanity
  fSelection.Left := 0;
  fSelection.Top := i + fRealFixedRows;
  while i>=0 do
    begin
      if fRowSelect then
        fSelection.Right := fColCount - 1
      else
        fSelection.Right := 0;
      fSelection.Bottom := i + fRealFixedRows;
      // ListView_GetNextItem(Handle, i, LVNI_SELECTED);
      i := LLCL_SendMessage(Handle, LVM_GETNEXTITEM, i, LVNI_SELECTED);
    end;
  result := fSelection;
end;

// Computes new RealFixed value
function  TStringGrid.NewRealFixedRows(NewValue: integer): integer;
begin
  result := 0;
  if NewValue>0 then
    if fRowCount>=1 then  // Always 1 max
      result := 1;        //   in LLCL
end;

// Updates RealFixed value
procedure TStringGrid.UpdRealFixedRows(NewValue: integer);
var i: NativeUInt;
begin
  if NewValue = fRealFixedRows then exit;
  fRealFixedRows := NewValue;
  if Handle=0 then exit;  // Because may be called before created
  i := LLCL_GetWindowLongPtr(Handle, GWL_STYLE);
  if NewValue=0 then
    LLCL_SetWindowLongPtr(Handle, GWL_STYLE, i or LVS_NOCOLUMNHEADER)
  else
    begin
      LLCL_SetWindowLongPtr(Handle, GWL_STYLE, i and (not LVS_NOCOLUMNHEADER));
      UpdateHeaderStyle();
    end;
end;

// Raises an error if ACol or/and ARow incorrect
function  TStringGrid.CheckColRow(ACol, ARow: integer; Mode: integer): boolean;
begin
  result := true;
  if (Mode and 1)<>0 then
    result := (fColWidths[ACol]=0);
  if (Mode and 2)<>0 then
    result := (fRowHeights[ARow]=0);
end;

// Checks if Acol is correct (no error raised)
function  TStringGrid.IsColumnOK(ACol: integer): boolean;
begin
  result := (ACol>=0) and (ACol<fColCount);
end;

// Modifies Listview header style
procedure TStringGrid.ModifyHeaderStyle(AValue: cardinal; AMask: cardinal);
begin
  if fRealFixedRows>0 then
    begin
      if hWndHeader=0 then
        // ListView_GetHeader(Handle);
        hWndHeader := LLCL_SendMessage(Handle, LVM_GETHEADER, 0, 0);
      if hWndHeader<>0 then
        LLCL_SetWindowLongPtr(hWndHeader, GWL_STYLE,
          (LLCL_GetWindowLongPtr(hWndHeader, GWL_STYLE) or AValue) and (not AMask));
    end
  else
    hWndHeader := 0;
end;

// Updates Listview header style (after header creation)
procedure TStringGrid.UpdateHeaderStyle();
begin
{$ifndef DefNo_ColumnSort}
  SetColumnClickSorts(fColumnClickSorts);
{$else DefNo_ColumnSort}
  ModifyHeaderStyle(0, HDS_BUTTONS);
{$endif DefNo_ColumnSort}
  if not (goColSizing in fOptions) then
    ModifyHeaderStyle(HDS_NOSIZING, 0);   // Only for Vista+
end;

{$ifndef DefNo_ColumnSort}
// Modifies Listview header format for a column (Only for ComCtl32 version 6.00+)
procedure TStringGrid.ModifyHeaderColFmt(ACol: integer; AMode: integer);
var HDI: THDITEM;
begin
  if fRealFixedRows>0 then
    begin
      if hWndHeader<>0 then
        begin
          FillChar(HDI, SizeOf(HDI), 0);
        	HDI.Mask := HDI_FORMAT;
          // Header_GetItem(hHeader, ACol, HDI)
          if boolean(LLCL_SendMessage(hWndHeader, HDM_GETITEM, WParam(ACol), LParam(@HDI))) then
            begin
              case AMode of
              0:    // Ascending order
            		HDI.fmt := (HDI.fmt and (not HDF_SORTDOWN)) or HDF_SORTUP;
              1:    // Descending order
            		HDI.fmt := (HDI.fmt or HDF_SORTDOWN) and (not HDF_SORTUP);
              else  // No order
            		HDI.fmt := HDI.fmt and (not (HDF_SORTDOWN or HDF_SORTUP));
              end;
            end;
          // Header_SetItem(hHeader, ACol, HDI)
          LLCL_SendMessage(hWndHeader, HDM_SETITEM, WParam(ACol), LParam(@HDI));
        end;
    end;
end;

procedure TStringGrid.SetColumnClickSorts(AValue: boolean);
begin
  fColumnClickSorts := AValue;
  if Handle=0 then exit;  // Because may be called before created
  if AValue then
    ModifyHeaderStyle(HDS_BUTTONS, 0)
  else
    begin
      if Assigned(OnHeaderClick) then
        ModifyHeaderStyle(HDS_BUTTONS, 0)
      else
        ModifyHeaderStyle(0, HDS_BUTTONS);
      if IsColumnOK(fSortColumn) then
        ModifyHeaderColFmt(fSortColumn, -1);   // -1 = no order
    end;
end;

// Sort call
procedure TStringGrid.CallSort(FormerSortColumn: integer);
begin
  if FormerSortColumn<>fSortColumn then
    if IsColumnOK(FormerSortColumn) then
      ModifyHeaderColFmt(FormerSortColumn, -1);   // -1 = no order
  ModifyHeaderColFmt(fSortColumn, Ord(fSortOrder));
  // ListView_SortItemsEx(Handle, Handle, @LV_CompareFunc);
  LLCL_SendMessage(Handle, LVM_SORTITEMSEX, Handle, LPARAM(@LV_CompareFunc));
end;
{$else DefNo_ColumnSort}
procedure TStringGrid.SetColumnClickSorts(AValue: boolean);
begin
  fColumnClickSorts := AValue;
end;
{$endif DefNo_ColumnSort}

// Restores focus to last item having it
procedure TStringGrid.RestoreLastFocusedItem;
begin
  fCurCtrlState := 2;
  LV_SetItemState(Handle, fLastItemFocused, LVIS_FOCUSED, LVIS_FOCUSED);
  fCurCtrlState := 0;
end;

// Processes notification (for Listview or Header Control)
function  TStringGrid.ProcessNotification(var Msg: TMessage; IsForHeader: boolean): boolean;
var nItem, nSubItem: integer;
var lChangeAllowed: boolean;
{$ifndef DefNo_ColumnSort}
var SortColumnSave: integer;
{$endif DefNo_ColumnSort}
{$ifndef DefNo_StdMouseMessages}
var MouseButton: TMouseButton;
var ShiftState: TShiftState;
{$endif DefNo_StdMouseMessages}
{$ifndef DefNo_Column1Edit}
var CellValue: string;
{$endif DefNo_Column1Edit}
var uOldState, uNewState: cardinal;
begin
  result := true;
  case TWMNotify(Msg).NMHdr^.code of
  LVN_ITEMCHANGING:
    begin
      nItem := PNMListView(Msg.lParam)^.iItem;
      if nItem>=0 then
        begin
          lChangeAllowed := true;
          uOldState := PNMListView(Msg.lParam)^.uOldState;
          uNewState := PNMListView(Msg.lParam)^.uNewState;
          // Ctrl+Click/Space not allowed for selection/unselection
{$ifdef DefNo_RightClickSelect}
          if ((LLCL_GetKeyState(VK_CONTROL)<0) or (LLCL_GetKeyState(VK_RBUTTON)<0)) and (fCurCtrlState=0) then
{$else DefNo_RightClickSelect}
          if (LLCL_GetKeyState(VK_CONTROL)<0) and (fCurCtrlState=0) then
{$endif DefNo_RightClickSelect}
            begin
              // No more selected - forces to selected again
              if (((uOldState and LVIS_SELECTED)<>0) and ((uNewState and LVIS_SELECTED)=0))
                or
              // Newly selected - forces to not selected again
                 (((uOldState and LVIS_SELECTED)=0) and ((uNewState and LVIS_SELECTED)<>0)) then
                    lChangeAllowed := false;
{$ifdef DefNo_RightClickSelect}
              // RightClick
              if LLCL_GetKeyState(VK_RBUTTON)<0 then
                lChangeAllowed := false;
{$endif DefNo_RightClickSelect}
              // Newly focused
              if ((uOldState and LVIS_FOCUSED)=0) and ((uNewState and LVIS_FOCUSED)<>0) then
                  begin
                    lChangeAllowed := false;
                    RestoreLastFocusedItem();
                  end;
              if (not lChangeAllowed) then
                begin
                  Msg.result := LRESULT(true);
                  result := false;
                  exit;
                end;
            end;
          // OnSelectCell event (may append more than once, especially if click on selected item)
          if ((uNewState and LVIS_SELECTED)<>0) then
            begin
              if Assigned(EOnSelectCell) then
                begin
                  if fRealFixedRows>0 then nItem := nItem + 1;
                  nSubItem := PNMListView(Msg.lParam)^.iSubItem;
                  EOnSelectCell(self, nSubItem, nItem, lChangeAllowed);
                  if (not lChangeAllowed) then
                    begin
                      RestoreLastFocusedItem();
                      Msg.result := LRESULT(true);
                      result := false;
                    end;
                end;
            end;
        end;
    end;
  LVN_ITEMCHANGED:
    begin
      nItem := PNMListView(Msg.lParam)^.iItem;
      if nItem>=0 then
        begin
          if (LLCL_GetKeyState(VK_CONTROL)>=0) and (fCurCtrlState=0) then
            // Save last focused item
            if (PNMListView(Msg.lParam)^.uNewState and LVIS_FOCUSED)<>0 then
              fLastItemFocused := nItem;
        end;
    end;
{$ifndef DefNo_ColumnSort}
  LVN_COLUMNCLICK:    // Column title click
    begin
      // (no mouse button down/up events for title)
      nSubItem := PNMListView(Msg.lParam)^.iSubItem;
      if IsColumnOK(nSubItem) then
        begin
          if fColumnClickSorts then
            begin
              SortColumnSave := fSortColumn;
              if nSubItem=fSortColumn then
                begin
                  // Inverses order
                  if fSortOrder=soAscending then
                    fSortOrder := soDescending
                  else
                    fSortOrder := soAscending;
                end
              else
                begin
                  fSortColumn := nSubItem;
                  fSortOrder := soAscending;
                end;
              CallSort(SortColumnSave);
              SetRow(Row);      // Re-focus on current selected row (only one, even if several are selected)
            end;
          if Assigned(OnHeaderClick) then
            OnHeaderClick(self, true, nSubItem);
        end;
    end;
{$endif DefNo_ColumnSort}
{$ifndef DefNo_StdMouseMessages}
  NM_CLICK, NM_DBLCLK, NM_RCLICK, NM_RDBLCLK:
    begin
      // Note concerning Listview Header Control (i.e. first row, if have fixed rows):
      //   OnMouseDown/OnMouseUp and OnClick/OnDblClick events not generated
      if IsForHeader then exit; // (Got only NM_RCLICK for Listview Header)
      if (TWMNotify(Msg).NMHdr^.code=NM_CLICK) or (TWMNotify(Msg).NMHdr^.code=NM_DBLCLK) then MouseButton := mbLeft else MouseButton := mbRight;
      ShiftState := LV_KeysToShiftState(PNMItemActivate(Msg.lParam)^.uKeyFlags);
      //   for valid item/subitem (equivalent to AllowOutboundEvents=false)
      nItem := PNMListView(Msg.lParam)^.iItem;
{$IFNDEF FPC}
      // Delphi: double-click before mouse button down
      if nItem>=0 then
        case TWMNotify(Msg).NMHdr^.code of
        NM_DBLCLK:
          begin
            if Assigned(OnDblClick) then
              if not (ssCtrl in ShiftState) then
                OnDblClick(self);
{$ifndef DefNo_Column1Edit}
            if goEditing in fOptions then
              CallEditCurRow();
{$endif DefNo_Column1Edit}
          end;
        end;
{$ENDIF NFPC}
      // mouse button down
      if Assigned(OnMouseDown) then
        OnMouseDown(self, MouseButton, ShiftState, PNMItemActivate(Msg.lParam)^.ptAction.X, PNMItemActivate(Msg.lParam)^.ptAction.Y);
      // click and double-click
      if nItem>=0 then
        case TWMNotify(Msg).NMHdr^.code of
        NM_CLICK:
          if Assigned(OnClick) then
            if not (ssCtrl in ShiftState) then
              OnClick(self);
{$ifndef DefNo_RightClickSelect}
        // In LLCL, right-click can also select an item
        NM_RCLICK:
          if Assigned(OnClick) then
            if (not (ssCtrl in ShiftState)) and (not (ssShift in ShiftState)) then
              OnClick(self);
{$endif DefNo_RightClickSelect}
{$IFDEF FPC}
        // Free Pascal: double-click between mouse button down/up
        NM_DBLCLK:
          begin
            if Assigned(OnDblClick) then
              if not (ssCtrl in ShiftState) then
                OnDblClick(self);
{$ifndef DefNo_Column1Edit}
            if goEditing in fOptions then
              CallEditCurRow();
{$endif DefNo_Column1Edit}
          end;
{$ENDIF FPC}
        end;
      // mouse button up
      if Assigned(OnMouseUp) then
        OnMouseUp(self, MouseButton, ShiftState, PNMItemActivate(Msg.lParam)^.ptAction.X, PNMItemActivate(Msg.lParam)^.ptAction.Y);
    end;
{$else DefNo_StdMouseMessages}
  NM_CLICK:       // Left double-click processed in this case in standard WMLDblClick (Control.pas)
    begin
      if Assigned(OnClick) then
        OnClick(self);
    end;
{$endif DefNo_StdMouseMessages}
{$ifndef DefNo_Column1Edit}
  LVN_KEYDOWN:
    begin
      if IsForHeader then exit;
      if goEditing in fOptions then
        if (PNMLVKeyDown(Msg.lParam)^.wVKey=VK_RETURN) or (PNMLVKeyDown(Msg.lParam)^.wVKey=VK_F2) then
          CallEditCurRow();
    end;
  LVN_BEGINLABELEDITA, LVN_BEGINLABELEDITW:
    begin
      if Assigned(OnGetEditText) then
        begin
          nItem := PNMLVDispInfo(Msg.lParam)^.item.iItem;
          if fRealFixedRows>0 then nItem := nItem + 1;
          nSubItem := PNMLVDispInfo(Msg.lParam)^.item.iSubItem;
          CellValue := Cells[nSubItem, nItem];
          OnGetEditText(self, nSubItem, nItem, CellValue);
          // (Can't update text if modified during OnGetEditText call)
        end;
    end;
  LVN_ENDLABELEDITA, LVN_ENDLABELEDITW:
    begin
      if Assigned(OnSetEditText) then
        begin
          nItem := PNMLVDispInfo(Msg.lParam)^.item.iItem;
          if fRealFixedRows>0 then nItem := nItem + 1;
          nSubItem := PNMLVDispInfo(Msg.lParam)^.item.iSubItem;
          if PNMLVDispInfo(Msg.lParam)^.item.pszText<>nil then
            begin
              if TWMNotify(Msg).NMHdr^.code=LVN_ENDLABELEDITA then
                CellValue := LLCLS_GetTextAPtr(PAnsiChar(PNMLVDispInfo(Msg.lParam)^.item.pszText))
              else
                CellValue := LLCLS_GetTextWPtr(PWideChar(PNMLVDispInfo(Msg.lParam)^.item.pszText));
              Cells[nSubItem, nItem] := CellValue;
              OnSetEditText(self, nSubItem, nItem, CellValue);
              // (Called only once when editing is done - like OnEditingDone)
            end;
        end;
    end;
{$endif DefNo_Column1Edit}
  end;
end;

{$ifndef DefNo_Column1Edit}
procedure TStringGrid.CallEditCurRow();
var nItem: integer;
begin
  nItem := Row;
  if fRealFixedRows>0 then nItem := nItem - 1;
  if nItem>=0 then
    // ListView_EditLabel(Handle, iItem);
    LLCL_PostMessage(Handle, LVM_EDITLABEL, nItem, 0);
end;
{$endif DefNo_Column1Edit}

{$ifndef DefNo_HeaderSupport}
// Mouse events call
procedure TStringGrid.ForMouseButton(MouseButton: TMouseButton; ShiftState: TShiftState; alParam: NativeUInt; EOnMouse: TMouseEvent);
begin
  if Assigned(EOnMouse) then
    EOnMouse(self, MouseButton, ShiftState, TSmallPoint(cardinal(alParam)).X, TSmallPoint(cardinal(alParam)).Y);
end;

// Header Control property
function  TStringGrid.GethWndHeader(): THandle;
begin
  if fhWndHeader=0 then
    begin
      // ListView_GetHeader(Handle);
      fhWndHeader := LLCL_SendMessage(Handle, LVM_GETHEADER, 0, 0);
      if fhWndHeader<>0 then
        begin
          fHeaderWndProc := TFNWndProc(LLCL_SetWindowLongPtr(fhWndHeader, GWL_WNDPROC, NativeUInt(@ELVWndProc)));
          LLCL_SetWindowLongPtr(fhWndHeader, GWL_USERDATA, NativeUInt(self));
        end;
    end;
  result := fhWndHeader;
end;

procedure TStringGrid.SethWndHeader(Value: THandle);
begin
  if Value=0 then
    begin
      if Assigned(fHeaderWndProc) then
        LLCL_SetWindowLongPtr(fhWndHeader, GWL_WNDPROC, NativeUInt(fHeaderWndProc));
      fHeaderWndProc := nil;
    end;
  fhWndHeader := Value;
end;
{$endif DefNo_HeaderSupport}

// Public method
procedure TStringGrid.SortColRow(IsColumn: boolean; Index: integer);
{$ifndef DefNo_ColumnSort}
var SortColumnSave: integer;
{$endif DefNo_ColumnSort}
begin
{$ifndef DefNo_ColumnSort}
  // Only for columns
  if not IsColumn then exit;
  CheckColRow(0, Index, 1);    // 1: Check Column only
  SortColumnSave := fSortColumn;
  fSortColumn := Index;
  if Handle=0 then exit;  // Because may be called before created
  CallSort(SortColumnSave);
{$endif DefNo_ColumnSort}
end;

//------------------------------------------------------------------------------

initialization
  RegisterClasses([TStringGrid]);

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
