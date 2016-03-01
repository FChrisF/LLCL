unit Unit1;

//
// From original Synopse test program (http://synopse.info/)
//   (Indicate a valid search path for the LLCL files before compiling)
//

{$IFDEF FPC}
  {$mode objfpc}{$H+}
//  {$mode delphi}
//  {$mode objfpc}{$modeswitch unicodestrings}{$H+}   // Requires FPC 2.7.1+
//  {$mode delphiunicode}{$codepage UTF8}             //   (See LLCL README.txt)
{$ENDIF}
{$IFDEF FPC_OBJFPC} {$DEFINE IS_FPC_OBJFPC_MODE} {$ENDIF}

interface

uses
  SysUtils, {$IFDEF FPC}LazUTF8, LCLType,{$ELSE} Variants, XPMan,{$ENDIF}
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Menus;

type
  { TForm1 }
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Edit1: TEdit;
    ComboBox1: TComboBox;
    ListBox1: TListBox;
    Memo1: TMemo;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    GroupBox1: TGroupBox;
    OpenDialog1: TOpenDialog;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    ComboBox2: TComboBox;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    StaticText1: TStaticText;
    ProgressBar1: TProgressBar;
    StaticText2: TStaticText;
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    PopupMenu1: TPopupMenu;
    {$IFDEF FPC}
    {$ELSE}
    XPManifest1: TXPManifest;
    {$ENDIF}
    procedure Button10Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1DblClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
  private
    { Private declarations }
    TrackBar1: TTrackBar;
  // Workaround for FPC (TCheckBox and TRadioButton don't have any alignment property)
  {$IFDEF FPC}
  {$IF Declared(LLCLVersion)}
  protected
    procedure CreateParams(var Params : TCreateParams); override;
  {$IFEND}
  {$ENDIF}
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$IFDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.dfm}
{$ENDIF}

//
// Format an output string with various input values,
//    And add it to Memo1
//
procedure MemoAddLineFmt(MemoCtrl: TMemo; const s: string; const Args: array of const);
begin
  MemoCtrl.Lines.Add(Format(s, Args));
end;

// Workaround for FPC (TCheckBox and TRadioButton don't have any alignment property)
{$IFDEF FPC}
// Sample of how to use specific code for LLCL (Not recommended)
{$IF Declared(LLCLVersion)}
procedure TForm1.CreateParams(var Params : TCreateParams);
begin
  inherited;
  Form1.CheckBox1.Alignment := taLeftJustify;    // Note: TCheckBox has an alignment
  Form1.CheckBox3.Alignment := taLeftJustify;    //    property since Lazarus 1.4
  Form1.RadioButton2.Alignment := taLeftJustify;
end;
{$IFEND}
{$ENDIF}

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Called after form (and its controls) is created, but before it is shown
  //    Timer disabled when application started (see Cancel/Default pushbuttons)
  Timer1.Enabled := false;
  //    Sample of a control created at runtime
  TrackBar1 := TTrackBar.Create(self);
  with TrackBar1 do
    begin
      Name := 'TrackBar1';    // (Optional)
      Left := 184;
      Height := {$IFDEF FPC}22{$ELSE}28{$ENDIF};
      Top := 184;
      Width := 215;
      OnChange := {$IFDEF IS_FPC_OBJFPC_MODE}@{$ENDIF}TrackBar1Change;
      Parent := self;
      TabOrder := ListBox1.TabOrder+1;
    end;
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
  // Should never happen
  ShowMessage('Impossible: invisible control.');
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  // Should never happen
  ShowMessage('Impossible: disabled control.');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // PushButton 1 has been clicked (mouse, keyboard ...)
  //    Adds Edit1 current text to ComboBox1 (choices list) and ListBox1
  ComboBox1.Items.Add(Edit1.Text);
  ListBox1.Items.Add(Edit1.Text);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  // Sets ComboBox1 (edit part) to Edit1 current text
  Edit1.Text := ComboBox1.Text;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  // Clears both ComboBox1 (only choices list) and ListBox1
  ComboBox1.Items.Clear;
  ListBox1.Clear;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  // Sets Edit1 current text to ComboBox1 (edit part)
  ComboBox1.Text := Edit1.Text;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  // PushButton 'Cancel Button' (defined with 'Cancel' property = Escape key)
  //    Clears ProgressBar1 and stops Timer1
  Memo1.Lines.Add('Escape/Cancel');
  if Timer1.Enabled then
    begin
      Timer1.Enabled := false;
      ProgressBar1.Position := 0;
      ShowMessage('Timer is now stopped.');
    end;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  // All CheckBox values set to 'Grayed' (i.e. undefined state)
  CheckBox1.State := cbGrayed;
  CheckBox2.State := cbGrayed;
  CheckBox3.State := cbGrayed;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  // Opens/Closes ComboBox1 choices list
  ComboBox1.DroppedDown := not ComboBox1.DroppedDown;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  // Hides/Shows GroupBox1 and its controls (RadioButtons)
  Memo1.Lines.Add('Button9Click');
  GroupBox1.Visible := not GroupBox1.Visible;
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
  // PushButton 'Default Button' (defined with 'Default' property = Return key)
  //    Starts Timer1
  Memo1.Lines.Add('Return/Default');
  if not Timer1.Enabled then
    begin
      Timer1.Enabled := true;
      ShowMessage('Timer is started. See progress bar...'+sLineBreak+sLineBreak+
                'Escape (Cancel button) to stop it.');
    end;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  // Text has been changed for Edit1
  Memo1.Lines.Add('Edit1: '+Edit1.Text);
end;

procedure TForm1.Edit1DblClick(Sender: TObject);
begin
  // Double (left) click for Edit1
  Memo1.Lines.Add('Edit1DblClick');
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  // New selection for ComboBox1 (form choices list, left click)
  Memo1.Lines.Add('ComboBox1Change '+IntToStr(ComboBox1.ItemIndex));
end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
begin
  // Double (left) click (i.e. new selection) for one line of ListBox1
  Memo1.Lines.Add('ListBox1DblClick '+IntToStr(ListBox1.ItemIndex));
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var s: String;
begin
  // Mouse button down (any button) over Form1
  if ssDouble in Shift then s := ' (Double click)' else s := '';
  MemoAddLineFmt(Memo1,'FormMouseDown at %d %d'+s, [X, Y]);
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  // Mouse button up (any button) over Form1
  MemoAddLineFmt(Memo1,'FormMouseUp at %d %d', [X, Y]);
  // If right button (i.e. right click), shows a popup menu
  if Button=mbRight then
    PopupMenu1.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Keyboard key down (in most of controls)
  //    (Because Form1 has KeyPreview=True property)
  MemoAddLineFmt(Memo1,'FormKeyDown %d', [Key]);
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Keyboard key up (in most of controls)
  //    (Because Form1 has KeyPreview=True property)
  MemoAddLineFmt(Memo1,'FormKeyUp %d', [Key]);
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
  // Keyboard key pressed (in most of controls)
  //    (Because Form1 has KeyPreview=True property)
  //    Only the character code is present here (see FormKeyDown, FormKeyUp)
  MemoAddLineFmt(Memo1,'FormKeyPress #%d ''%s''', [Ord(Key),
    {$if Defined(FPC) and not Defined(UNICODE)}SysToUTF8(Key){$else}Key{$ifend}]);  // Char type is not UTF8
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  // Timer fall
  //    Increments ProgressBar1 with one 'stepit' value (1/10 by default - SetStep to modify it)
  //    (ProgressBar1 automatically resets to 0 when maximum reached)
  ProgressBar1.StepIt;
  Memo1.Lines.Add('Timer Tick: ProgressBar='+IntToStr(ProgressBar1.Position));
end;


procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  // TrackBar position modified
  Memo1.Lines.Add('TrackBar: New value='+IntToStr(TTrackBar(Sender).Position)+'/'+IntToStr(TTrackBar(Sender).Max));
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  // 'Quit' in main menu
  //    End of program
  Application.Terminate;
end;

procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  // Simple main menu selection
  Memo1.Lines.Add('Menu21');
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
begin
  // Simple main menu selection
  Memo1.Lines.Add('Menu22');
end;

procedure TForm1.MenuItem11Click(Sender: TObject);
begin
  // Main menu: Open a file...
  OpenDialog1.Options := OpenDialog1.Options+[ofPathMustExist, ofFileMustExist];
  OpenDialog1.Filter := 'Text files (*.txt)|*.txt|All files|*.*';
  OpenDialog1.FilterIndex := 1;
  OpenDialog1.Title := 'File to open';
  if OpenDialog1.Execute then
    ShowMessage('File to open: '+OpenDialog1.FileName);
end;

procedure TForm1.MenuItem12Click(Sender: TObject);
begin
  // Main menu: Save a File...
  SaveDialog1.Options := SaveDialog1.Options+[ofPathMustExist, ofOverwritePrompt];
  SaveDialog1.Filter := 'Text files (*.txt)|*.txt|Temporary files (*.tmp)|*.tmp|All files|*.*';
  SaveDialog1.FilterIndex := 2;
  SaveDialog1.FileName := 'MyFile.tmp';
  if SaveDialog1.Execute then
    ShowMessage('File to save: '+SaveDialog1.FileName);
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
  // Popup menu selection
  Memo1.Lines.Add('Popup1');
end;

procedure TForm1.MenuItem10Click(Sender: TObject);
begin
  // Popup menu selection
  Memo1.Lines.Add('Popup2');
end;

end.
