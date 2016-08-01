unit Menus;

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
    * TMenuItem, TMenu, TMainMenu and TPopupMenu implemented
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
  LLCLOSInt, Windows,
  Classes, Controls;

type
  TMenuItem = class(TControl)
  private
    fItems: TList;
    fHandle: THandle;
    fMenuIdent: integer;
    fCaption: string;
    fEnabled,
    fChecked,
    fAutoCheck: boolean;
    function  GetItem(Index: integer): TMenuItem;
    procedure SetCaption(const Value: string);
    procedure SetEnabled(Value: boolean);
    procedure SetChecked(Value: boolean);
    procedure SetMenuItem(ParentMenuHandle: THandle; FirstCallType: integer; var MenuIdent: integer);
    function  ClickMenuItem(MenuIdent: integer): boolean;
  protected
    procedure ReadProperty(const PropName: string; Reader: TReader); override;
    procedure SetParentComponent(Value: TComponent); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property  Items[Index: integer]: TMenuItem read GetItem; default;
    property  Handle: THandle read fHandle;
    property  Caption: string read fCaption write SetCaption;
    property  Enabled: boolean read fEnabled write SetEnabled;
    property  Checked: boolean read fChecked write SetChecked;
    property  AutoCheck: boolean read fAutoCheck write fAutoCheck;
  end;

  TMenu = class(TControl)
  private
    fHandle: THandle;
    fItems: TMenuItem;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property  Handle: THandle read fHandle;
    property  Items: TMenuItem read fItems;
  end;

  TMainMenu = class(TMenu)
  protected
    procedure SetParentComponent(Value: TComponent); override;
    procedure SetMainMenuForm(FormHandle: THandle; var BaseMenuIdent: integer);
    procedure ClickMainMenuForm(MsgItemID: word; var MsgResult: LRESULT);
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TPopupMenu = class(TMenu)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Popup(X, Y: integer);
  end;

//------------------------------------------------------------------------------

implementation

uses
  Forms;

{$IFDEF FPC}
  {$PUSH} {$HINTS OFF}
{$ENDIF}

type
  TPCustomForm = class(TCustomForm);  // To access to protected part

const
  SMFC_NOTFIRSTCALL     = 0;
  SMFC_MAINMENU         = 1;
  SMFC_POPUPMENU        = 2;

//------------------------------------------------------------------------------

{ TMenuItem }

constructor TMenuItem.Create(AOwner: TComponent);
begin
  inherited;
  fItems := TList.Create;
  fEnabled := true;
  ATType := ATTMenuItem;
end;

destructor TMenuItem.Destroy;
begin
  if fHandle<>0 then
    LLCL_DestroyMenu(fHandle);
  fHandle := 0;
  fItems.Free;
  inherited;
end;

procedure TMenuItem.ReadProperty(const PropName: string; Reader: TReader);
const Properties: array[0..3] of PChar = (
  'Caption', 'Enabled', 'Checked', 'AutoCheck');
begin
  case StringIndex(PropName, Properties) of
    0 : fCaption := Reader.StringProperty;
    1 : fEnabled := Reader.BooleanProperty;
    2 : fChecked := Reader.BooleanProperty;
    3 : fAutoCheck := Reader.BooleanProperty;
    else inherited;
  end;
end;

procedure TMenuItem.SetParentComponent(Value: TComponent);
begin
  inherited;
  if Value<>nil then
    if Value.InheritsFrom(TMenu) then   // TMainMenu or TPopupMenu
      TMenu(Value).fItems.fITems.Add(self)
    else                                // TMenuItem
      TMenuItem(Value).fITems.Add(self);
end;

function TMenuItem.GetItem(Index: integer): TMenuItem;
begin
  result := TMenuItem(fItems[Index]);
end;

procedure TMenuItem.SetCaption(const Value: string);
var Flags: integer;
begin
  fCaption := Value;
  Flags := MF_STRING;
  if fEnabled then
    Flags := Flags or MF_ENABLED
  else
    Flags := Flags or MF_GRAYED;
  if fChecked then
    Flags := Flags or MF_CHECKED
  else
    Flags := Flags or MF_UNCHECKED;
  LLCL_ModifyMenu(fHandle, fMenuIdent, MF_BYCOMMAND or Flags, 0, @fCaption[1]);
end;

procedure TMenuItem.SetEnabled(Value: boolean);
var Flags: integer;
begin
  fEnabled := Value;
  if fEnabled then
    Flags := MF_ENABLED
  else
    Flags := MF_GRAYED;
  LLCL_EnableMenuItem(fHandle, fMenuIdent, MF_BYCOMMAND or Flags);
end;

procedure TMenuItem.SetChecked(Value: boolean);
var Flags: integer;
begin
  fChecked := Value;
  if fChecked then
    Flags := MF_CHECKED
  else
    Flags := MF_UNCHECKED;
  LLCL_CheckMenuItem(fHandle, fMenuIdent, MF_BYCOMMAND or Flags);
end;

procedure TMenuItem.SetMenuItem(ParentMenuHandle: THandle; FirstCallType: integer; var MenuIdent: integer);
var aHandle: THandle;
var Flags: integer;
var i: integer;
begin
  Flags := MF_STRING;
  if FirstCallType=SMFC_NOTFIRSTCALL then
    begin
      if fCaption='-' then
        Flags := Flags or MF_SEPARATOR
      else
        begin
          if fEnabled then
            Flags := Flags or MF_ENABLED
          else
            Flags := Flags or MF_GRAYED;
          if fChecked then
            Flags := Flags or MF_CHECKED;
        end;
    end;
  if fItems.Count=0 then
    begin
      fHandle := ParentMenuHandle;
      Inc(MenuIdent);
      fMenuIdent := MenuIdent;
      aHandle := fMenuIdent;
    end
  else
    begin
      if FirstCallType=SMFC_MAINMENU then
        fHandle := LLCL_CreateMenu()
      else
        fHandle := LLCL_CreatePopupMenu();
      for i := 0 to fItems.Count-1 do
        TMenuItem(fItems[i]).SetMenuItem(fHandle, SMFC_NOTFIRSTCALL, MenuIdent);
      Flags := Flags or MF_POPUP;
      aHandle := fHandle;
    end;
  if FirstCallType=SMFC_NOTFIRSTCALL then
    LLCL_AppendMenu(ParentMenuHandle, Flags, aHandle, @fCaption[1]);
end;

function TMenuItem.ClickMenuItem(MenuIdent: integer): boolean;
var i: integer;
begin
  result := true;
  if fMenuIdent = MenuIdent then
    begin
      if fAutoCheck then
        Checked := (not fChecked);
      if Assigned(OnClick) then
        OnClick(self);
      exit;
    end;
  for i := 0 to fItems.Count-1 do
    if TMenuItem(fItems[i]).ClickMenuItem(MenuIdent) then
      exit;
  result := false;
end;

{ TMenu }

constructor TMenu.Create(AOwner: TComponent);
begin
  inherited;
  fItems := TMenuItem.Create(self);
end;

destructor TMenu.Destroy;
begin
  if fHandle<>0 then
    LLCL_DestroyMenu(fHandle);
  fHandle := 0;
  inherited;
end;

{ TMainMenu }

constructor TMainMenu.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTMainMenu
end;

procedure TMainMenu.SetParentComponent(Value: TComponent);
begin
  inherited;
  TCustomForm(Parent).Menu := self;
end;

procedure TMainMenu.SetMainMenuForm(FormHandle: THandle; var BaseMenuIdent: integer);
begin
  if fHandle=0 then
    begin
      Items.SetMenuItem(0, SMFC_MAINMENU, BaseMenuIdent);
      fHandle := Items.Handle;
    end;
  LLCL_SetMenu(FormHandle, fHandle);
  LLCL_DrawMenuBar(fHandle);
end;

procedure TMainMenu.ClickMainMenuForm(MsgItemID: word; var MsgResult: LRESULT);
begin
  if fHandle<>0 then
    if Items.ClickMenuItem(MsgItemID) then
      MsgResult := 0;
end;

{ TPopupMenu }

constructor TPopupMenu.Create(AOwner: TComponent);
begin
  inherited;
  ATType := ATTPopupMenu
end;

procedure TPopupMenu.Popup(X, Y: integer);
var MenuItemChoice: integer;
var i: integer;
begin
  if fHandle=0 then
    begin
      i := TPCustomForm(Parent).LastMenuIdent;
      Items.SetMenuItem(0, SMFC_POPUPMENU, i);
      TPCustomForm(Parent).LastMenuIdent := i;
      fHandle := Items.Handle;
    end;
  if fHandle<>0 then
    begin
      MenuItemChoice := integer(LLCL_TrackPopupMenu(fHandle,
        TPM_LEFTALIGN or TPM_LEFTBUTTON or TPM_NONOTIFY or TPM_RETURNCMD,
        X, Y, 0, TCustomForm(Parent).Handle, nil));
      if MenuItemChoice<>0 then
        Items.ClickMenuItem(MenuItemChoice);
    end;
end;

//------------------------------------------------------------------------------

initialization
  RegisterClasses([TMenuItem, TMainMenu, TPopupMenu]);

{$IFDEF FPC}
  {$POP}
{$ENDIF}

end.
